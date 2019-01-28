Vim for Weka
============

A collection of Vim configurations for Weka developers.

If you want to add things to this repository, Please read
[CONTRIBUTING.md](CONTRIBUTING.md) first.

Features
========

* ALE linter that uses Weka's LDC fork and sets Weka's import paths. It is set
  automatically to replace the default DMD-based linter when editing D files in
  the Weka project directory.

    Requirements & configurations:
    * ALE(obviously) - https://github.com/w0rp/ale
    * Build Weka's LDC fork - https://github.com/weka-io/ldc
      * On Mac with Homebrew, `brew tap weka-io/homebrew-ldc && brew install ldc-weka`
    * In your vimrc, set `g:weka_ldcPath` to the path of LDC2 binary you built

* Setting Python paths so that [JEDI](https://github.com/davidhalter/jedi-vim)
  can perform autocompletion correctly.

    * `scripts/pyls-for-weka` does similar things for [Python Language
      Server](https://github.com/palantir/python-language-server), and if you
      have configured
      [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim)
      to use PyLS it'll automatically set it to use this version when you open
      Vim in the Weka project directory.

* `:WekaBuildErrors` command: fills the quickfix list with compilation errors
  fetched from the build server.

* `:WekaTestErrors` command: fills the quickfix list with Python exceptions
  from `testlight.log`.

    * Set `g:weka_logsDir` to the dir containing the log files. The default is
      `~/tmp/weka/logs`.
    * Provide a job key as argument to fetch logs from a Bamboo/Reggie build.
    * If the _wekaticet_ feature is set, and you are editing a ticket, running
      without arguments will fetch the logs of the ticket you are editing.

* `:WekaTekaErrors` command: does the same thing for `teka.log`.

* `scripts/viewer-nvim.py` - a script for opening Neovim from the trace
  viewer(when pressing `V`).

    Requirements & configurations:
    * `pip install plumbum`
    * `pip install neovim`
    * When running the viewer, set the `WEKA_SRC_VIEWER` to the path of the
      script.

    The script can run with both Python2 and Python3, but you'll need to
    install the `plumbum` and `neovim` packages for the version you use. To
    force the script to run with the specific version, set `WEKA_SRC_VIEWER` to
    launch the specific Python interpreter:
    ```
    export WEKA_SRC_VIEWER='python3 /path/to/viewer-nvim.py'
    ```
* The `wekaticket` filetype - need to set `g:weka_ticketFiletype`

    Activated when opening Vim to edit a comment in a JIRA ticket with a plugin
    that can open Vim from the browser. Currently supported plugins:
    * [It's All Text!](https://addons.mozilla.org/en-US/firefox/addon/its-all-text/)
    * [Textern](https://addons.mozilla.org/en-US/firefox/addon/textern/)

    Note that this filetype is only useful if you have the `$WEKAPP_PATH`
    environment path set to path of the Weka project root. Without it, it won't
    be able to run `./teka`.

    If you set `g:weka_ticketFiletype_changeDir` and have the environment
    variable `$WEKAPP_PATH` set to the path of the project root, entering the
    `wekaticket` filetype will automatically move you to the weka project root.
    This is useful for copying pieces of code from the project to the comment.

    The `:WekaPasteTraces` command will paste to then next line the last trace
    dump from `viewer.output`.

    The following [Terminalogy](https://github.com/idanarye/vim-terminalogy)
    templates will be added:
    * `testlight` - read the `testlight.log`, with an `awk` filter to remove
      the clutter columns.
    * `teka` - same thing for `teka.log`.
    * `jrpc` - same thing for `jrpc.log`.
    * `objects-log` - same thing for `objects.log`, where the **changes** in configuration are logged.
    * `objects-yaml` - same thing for `objects.yaml.log`, where the **final** configuration is dumped.
    * `artifacts` - generic template for reading artifacts. Supports completion
      for the artifacts in S3.

* `:WekaInvestigate` command: opens `teka investigate` terminal.

    * Requires Neovim or Vim8 with the terminal feature(`:echo has('terminal')`)
    * Provide a job key as argument to investigate Bamboo/Reggie build.
    * If the _wekaticet_ feature is set, and you are editing a ticket, running
      without arguments will investigate the ticket you are editing.
