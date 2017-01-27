let s:timestampAwkPattern = '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}(,[0-9]+)?'

function! s:parseLine(line) abort
	let l:line = substitute(a:line, nr2char(13), '', 'g')
	let l:match = matchlist(l:line, '\v(.{-1,})\((\d+)\): Error: (.*)$')
	if !empty(l:match)
		return {
					\ 'filename': l:match[1],
					\ 'lnum': str2nr(l:match[2]),
					\ 'text': l:match[3],
					\ }
	endif
endfunction

function! weka#log_parsing#fillQuickfixFromBuildLog(jump) abort
	echo 'Fetching compilation errors from build server'
	let l:lines = weka#tdeka('-q bs --no-tmux -n "grep ../logs/build.log -e Error:" | sed "s/.*<<\(.*Error.*\)>>/\1/p" -n')
	let l:entries = map(l:lines, 's:parseLine(v:val)')
	let l:entries = filter(l:entries, '!empty(v:val)')
	echo 'Found '.len(l:entries).' compilation errors'
	call setqflist(l:entries)
	if !empty(l:entries) && a:jump
		cc 1
	endif
endfunction

function! weka#log_parsing#logsFile(filename) abort
	let l:logsDir = get(g:, 'weka_logsDir', '~/tmp/weka/logs')
	return globpath(l:logsDir, a:filename)
endfunction

function! weka#log_parsing#testlightSessions() abort
	let l:logFile = weka#log_parsing#logsFile('testlight.log')
	let l:awkCommand = '$3 ~ /root/ && $7 ~ /Logging configured/ {print NR-1"\t"$1}'
	let l:result = []
	for l:line in systemlist(['awk', '--field-separator=|', l:awkCommand, l:logFile])
		let l:match = matchlist(l:line, '\v\C(\d+)\t([0-9-]+ [0-9:,]+)$')
		call add(l:result, {'line': str2nr(l:match[1]), 'timestamp': l:match[2]})
	endfor
	return l:result
endfunction

function! weka#log_parsing#lastTestlightSessionStartLine() abort
	return max(map(weka#log_parsing#testlightSessions(), 'v:val.line'))
endfunction

" Leave source empty to read from local log
function! weka#log_parsing#fillQuickfixFromTestlightErrors(source, jump) abort
	if empty(a:source)
		let l:logFile = weka#log_parsing#logsFile('testlight.log')
		let l:lastSessionStartLine = weka#log_parsing#lastTestlightSessionStartLine()
		let l:logFetchingCommand = 'awk "'.l:lastSessionStartLine.'<=NR" '.l:logFile
	else
		let l:logFetchingCommand = weka#tdekaCommand('-q logs '.shellescape(a:source).' testlight.log')
	endif

	let l:wekaProjectPath = weka#wekaProjectPathOrGlobal()
	" Clear the flag before printing and set it after, so that the lines that
	" set and clear the flag will not be printed.
	let l:awkCommand = '/'.s:timestampAwkPattern.'/ {now_reading = 0} now_reading == 1 {print} /^Traceback/ {now_reading = 1}'
	let l:entries = []
	for l:line in systemlist(printf('%s | awk --field-separator=\| %s', l:logFetchingCommand, shellescape(l:awkCommand)))
		let l:match = matchlist(l:line, '\v(\S+\.py):(\d+)\s+\.{2,}\s+(.*)')
		if empty(l:match)
			let l:match = matchlist(l:line, '\v\@(\S+\.d)\((\d+)\): (.*)$')
		endif
		if !empty(l:match)
			let l:entry = {
						\ 'filename': l:match[1],
						\ 'lnum': str2nr(l:match[2]),
						\ 'text': l:match[3],
						\ }
			if l:entry.filename[0] != '/'
				let l:entry.filename = globpath(l:wekaProjectPath, l:entry.filename)
			endif
			if l:entry.filename[0 : len(l:wekaProjectPath) - 1] == l:wekaProjectPath
				call add(l:entries, l:entry)
				continue
			endif
		endif

		call add(l:entries, {'text': l:line})
	endfor
	call setqflist(l:entries)
	if !empty(l:entries) && a:jump
		cc 1
	endif
endfunction
