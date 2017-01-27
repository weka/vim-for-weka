function! s:detect() abort
	if get(g:, 'weka_ticketFiletype')
		set filetype=wekaticket
	endif
endfunction

au BufReadPost,BufNewFile /home/idanarye/.mozilla/firefox/**/itsalltext/wekaio.atlassian.*.txt call s:detect()
