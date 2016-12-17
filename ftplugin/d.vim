if weka#isPathInWekaProject()
	if !exists('g:ale_linters')
		let g:ale_linters = {}
	endif
	let g:ale_linters.d = ['weka_ldc']
endif
