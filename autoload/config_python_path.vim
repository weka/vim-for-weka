function! config_python_path#configForPythonInVim()
	let s:wekaProjectPath = weka#wekaProjectPath()
	if !empty(s:wekaProjectPath)
		let s:wekaProjectPath = '"'.escape(s:wekaProjectPath, '\"').'"'
		let s:cmd = printf('if %s not in sys.path: sys.path.append(%s)', s:wekaProjectPath, s:wekaProjectPath)
		if has('python')
			python import sys
			execute 'python '.s:cmd
			python __import__('deps')
		endif
		if has('python3')
			python3 import sys
			execute 'python3 '.s:cmd
			python3 __import__('deps')
		endif
	endif
endfunction

function! config_python_path#configForLanguageClient()
	if exists('g:LanguageClient_serverCommands.python')
		if g:LanguageClient_serverCommands.python == ['pyls']
			if !empty(weka#wekaProjectPath())
				let g:LanguageClient_serverCommands.python = [weka#vfwScriptPath('pyls-for-weka')]
			endif
		endif
	endif
endfunction
