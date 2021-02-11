function! s:openPostTriageTerminal(cmd, tabcd, job) abort
	if !exists(':terminal')
		return
	endif

	if empty(a:job) && has_key(g:, 'weka_ticketKey')
		let l:job = g:weka_ticketKey
	else
		let l:job = a:job
	endif

	let l:command = printf('$WEKA_POST_TRIAGE_PATH/post-triage %s %s', a:cmd, shellescape(l:job))

	if a:tabcd
		tabnew
		tcd $WEKA_POST_TRIAGE_PATH
		edit post_triage/triages/
	endif

	let l:origWinId = win_getid()
	if has('nvim')
		botright new
		call termopen(l:command)
		" normal! A
		normal! G
	else
		botright call term_start(['/bin/sh', '-c', l:command])
	endif
	call win_gotoid(l:origWinId)
endfunction

command! -bar -bang -nargs=? WekaPostTriageInteractive call s:openPostTriageTerminal('interactive', <bang>0, <q-args>)
command! -bar -nargs=? WekaPostTriageExplore call s:openPostTriageTerminal('explore', 0, <q-args>)

" autocmd FileType wekaticket let b:terminalogy_templates['diag-scripts'] = extend({
			" \ 'command': printf('./teka -q diag-scripts %s 2>/dev/null', g:weka_ticketKey),
			" \ }, b:terminalogy_basic)
autocmd FileType wekaticket let b:terminalogy_templates['post-triage'] = extend(extend({
			\ 'command': printf('$WEKA_POST_TRIAGE_PATH/post-triage run --format=jira %s 2>/dev/null', g:weka_ticketKey),
			\ }, b:terminalogy_basic), {
			\ 'linesAbove': ['{noformat}'],
			\ 'linesBetween': ['{noformat}'],
			\ 'linesBelow': [],
			\ })
