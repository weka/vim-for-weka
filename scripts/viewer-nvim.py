#!/usr/bin/python

from time import sleep
import re
import os

from plumbum import cli, local, BG
from neovim import socket_session, Nvim


def find_nvim_servers():
    for nvim_server_path in local.path('/tmp').glob('nvim*/0'):
        nvim = Nvim.from_session(socket_session(str(nvim_server_path)))
        if nvim.eval('weka#isPathInWekaProject()'):
            yield nvim


ppid_patern = re.compile(r'PPid:\s+(\d+)')


def find_weka_dir():
    def iter_parents(pid):
        procdir = local.path('/proc') / pid
        args = procdir.join('cmdline').read().decode('utf8').split('\0')
        cwd = local.path(os.readlink(str(procdir / 'cwd')))
        yield cwd, args
        m = ppid_patern.search(procdir.join('status').read().decode('utf8'))
        ppid = int(m.group(1))
        if 1 < ppid:
            for item in iter_parents(ppid):
                yield item

    def find_relevant_arg(args):
        for arg in args:
            if arg.startswith('-m'):
                arg = arg[2:]
            if arg.split('/')[-1] in ('viewer', 'teka.py', 'deka'):
                return arg

    for cwd, args in iter_parents(os.getpid()):
        relevant_arg = find_relevant_arg(args)
        if relevant_arg:
            script_path = cwd / relevant_arg
            wekapp_dir = script_path / '..'
            return wekapp_dir


class Main(cli.Application):
    def main(self, path, line):
        nvim_servers = list(find_nvim_servers())
        assert len(nvim_servers) <= 1

        command = 'edit %s | %s' % (path, line)
        if nvim_servers:
            nvim = nvim_servers[0]
            nvim.command(command)
        else:
            with local.cwd(find_weka_dir()):
                local['nvim-qt']['--', '-c', command] & BG
                sleep(1)

if __name__ == '__main__':
    Main.run()
