function! weka#investigate#openInvestigateTui(job) abort
	if !exists(':terminal')
		return
	endif

	if empty(a:job) && has_key(g:, 'weka_ticketKey')
		let l:job = g:weka_ticketKey
	else
		let l:job = a:job
	endif

	let l:command = weka#tekaCommand('investigate '.shellescape(l:job))

	if has('nvim')
		new
		call termopen(l:command)
		normal! A
	else
		call term_start(l:command)
	endif

endfunction
