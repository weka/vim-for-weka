" Shamelessly copied from the original DMD linter in ALE

function! ale_linters#d#weka_ldc#GetCommand(buffer)
    let l:wrapper_script = weka#vfwScriptPath('weka-ldc-wrapper')

    let l:command = l:wrapper_script . ' -o- -vcolumns -c'

    let l:ldc = get(g:, 'weka_ldcPath', 'ldc2')
    let l:command = 'WEKA_LDC=' . shellescape(l:ldc) . ' ' . l:command

    return l:command
endfunction

function! ale_linters#d#weka_ldc#Handle(buffer, lines)
    " Matches patterns lines like the following:
    " /tmp/tmp.qclsa7qLP7/file.d(1): Error: function declaration without return type. (Note that constructors are always named 'this')
    " /tmp/tmp.G1L5xIizvB.d(8,8): Error: module weak_reference is in file 'dstruct/weak_reference.d' which cannot be read
    let l:pattern = '^[^(]\+(\([0-9]\+\)\,\?\([0-9]*\)): \([^:]\+\): \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            break
        endif

        let l:line = l:match[1] + 0
        let l:column = l:match[2] + 0
        let l:type = l:match[3]
        let l:text = l:match[4]

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': bufnr('%'),
        \   'lnum': l:line,
        \   'vcol': 0,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('d', {
\   'name': 'weka_ldc',
\   'output_stream': 'stderr',
\   'executable': 'dmd',
\   'command_callback': 'ale_linters#d#weka_ldc#GetCommand',
\   'callback': 'ale_linters#d#weka_ldc#Handle',
\})
