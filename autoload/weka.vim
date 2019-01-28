function! weka#wekaProjectPath() abort
    let l:path = expand('%:p:h')
    if empty(l:path)
        let l:path = getcwd()
    endif
    while empty(globpath(l:path, 'weka_version'))
        if l:path == fnamemodify(l:path, ':h')
            " This is the end - revert to default
            return $WEKAPP_PATH
        endif
        let l:path = fnamemodify(l:path, ':h')
    endwhile
    return l:path
endfunction

function! weka#isPathInWekaProject() abort
    return !empty(weka#wekaProjectPath())
endfunction

function! weka#wekaProjectPathOrGlobal() abort
    let l:wekaProjectPath = weka#wekaProjectPath()
    if empty(l:wekaProjectPath)
        return $WEKAPP_PATH
    else
        return l:wekaProjectPath
    endif
endfunction

function! weka#tekaCommand(cmd) abort
    let l:wekaProjectPath = weka#wekaProjectPath()
    let l:tool = './teka'
    return printf('cd %s; %s %s', shellescape(l:wekaProjectPath), l:tool, a:cmd)
endfunction

function! weka#teka(cmd) abort
    return systemlist(weka#tekaCommand(a:cmd))
endfunction

function! weka#vfwScriptPath(name) abort
    for l:parent in split(&runtimepath, ',')
        " Expand the path to deal with ~ issues.
        let l:path = expand(l:parent . '/scripts/' . a:name)

        if filereadable(l:path)
            return l:path
        endif
    endfor
endfunction
