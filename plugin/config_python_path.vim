if has('python') || has('python3')
	let s:wekaProjectPath = weka#wekaProjectPath()
	if !empty(s:wekaProjectPath)
		let s:wekaProjectPath = '"'.escape(s:wekaProjectPath, '\"').'"'
		let s:cmd = printf('if %s not in sys.path: sys.path.append(%s)', s:wekaProjectPath, s:wekaProjectPath)
		if has('python')
			python import sys
			execute 'python '.s:cmd
		endif
		if has('python3')
			python3 import sys
			execute 'python3 '.s:cmd
		endif
	endif
endif
