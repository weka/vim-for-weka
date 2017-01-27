function! weka#wekaProjectPath() abort
	let l:path = expand('%:p:h')
	if empty(l:path)
		let l:path = getcwd()
	endif
	while empty(globpath(l:path, 'weka_version'))
		if l:path == fnamemodify(l:path, ':h')
			" This is the end...
			return ''
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

function! weka#tdekaCommand(cmd) abort
	let l:wekaProjectPath = weka#wekaProjectPath()
	if get(g:, 'weka_useDeka', 0)
		let l:tool = './deka'
	else
		let l:tool = './teka.py'
	endif
	return printf('cd %s; %s %s', shellescape(l:wekaProjectPath), l:tool, a:cmd)
endfunction

function! weka#tdeka(cmd) abort
	return systemlist(weka#tdekaCommand(a:cmd))
endfunction
