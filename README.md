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

* `:WekaBuildErrors` command: fills the quickfix list with compilation errors
  fetched from the build server.

    * Set `g:weka_useDeka` to `1` to use `deka` instead of `teka`.

* `:WekaTestErrors` command: fills the quickfix list with Python exceptions
  from `testlight.log`.

    * Set `g:weka_logsDir` to the dir containing the log files. The default is
      `~/tmp/weka/logs`.
    * Provide a build key as argument to fetch logs from a Bamboo/Reggie build.
    * If the _wekaticet_ feature is set, and you are editing a ticket, running
      without arguments will fetch the logs of the ticket you are editing.
    * Set `g:weka_useDeka` to `1` to use `deka logs` instead of `teka logs`
      when fetching from S3.

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
* The `wekaticket` - need to set `g:weka_ticketFiletype`

    Activated when opening Vim to edit a comment in a JIRA ticket with a plugin
    that can open Vim from the browser. Currently supported plugins:
    * [It's All Text!](https://addons.mozilla.org/en-US/firefox/addon/its-all-text/)

    Note that this filetype is only useful if you have the `$WEKAPP_PATH`
    environment path set to path of the Weka project root. Without it, it won't
    be able to run `./teka.py`/`./deka`.

    If you set `g:weka_ticketFiletype_changeDir` and have the environment
    variable `$WEKAPP_PATH` set to the path of the project root, entering the
    `wekaticket` filetype will automatically move you to the weka project root.
    This is useful for copying pieces of code from the project to the comment.

    The `:WekaPasteTraces` command will paste to then next line the last trace
    dump from `viewer.output`.

    The following [Terminalogy](https://github.com/idanarye/vim-terminalogy)
    templates will be added:
    * `testlight` - read the `testlight`, with an `awk` filter to remove the
      clutter columns.
    * `artifacts` - read artifacts of one of the hosts. The first argument is
      the host number, and the second is the name of the artifact.
