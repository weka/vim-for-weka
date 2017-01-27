if !exists('b:terminalogy_templates')
	let b:terminalogy_templates = {}
endif

setlocal textwidth=0
let b:weka_ticketKey = matchstr(bufname(''), '\v\CWEKAPP-\d+')
let s:tdekaCommand = get(g:, 'weka_useDeka', 0) ? './deka' : './teka.py'

if get(g:, 'weka_ticketFiletype_changeDir') && exists('$WEKAPP_PATH')
	cd $WEKAPP_PATH
endif

let b:terminalogy_basic = {
			\ 'linesAbove': ['{noformat}'],
			\ 'linesBelow': ['{noformat}'],
			\ 'runInDir': weka#wekaProjectPathOrGlobal(),
			\ 'implicitFilters': ['sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"'],
			\ }

let b:terminalogy_templates.testlight = extend({
			\ 'command': printf('%s -q logs %s testlight.log | awk -F\| ''/\0/ {print $1" | "$2" | "$7}''', s:tdekaCommand, b:weka_ticketKey),
			\ }, b:terminalogy_basic)

let b:terminalogy_templates.artifacts = extend({
			\ 'command': printf('%s -q logs %s-\1 \2 | awk -F\| ''/\0/''', s:tdekaCommand, b:weka_ticketKey),
			\ 'complete_2': [
			\	'boot.log',
			\	'exceptions.log',
			\	'kernel.log',
			\	'kernel_sibling.log',
			\	'output.log',
			\   'shelld.log',
			\   'supervisord.log',
			\	'syslog.log',
			\	'syslog_sibling.log',
			\   'system_events.log',
			\   'talker.log',
			\   'wekamond.log',
			\ ],
			\ }, b:terminalogy_basic)

function! s:readTracesToBuffer() abort
	let l:viewerOutput = shellescape(weka#wekaProjectPathOrGlobal()).'/viewer.output'
	let l:lastLine = str2nr(system('awk "/# FILTER:/ {print NR}" '.l:viewerOutput.'| tail -1'))
	execute 'read !echo {noformat}; awk "'.l:lastLine.'<=NR" '.l:viewerOutput.'; echo {noformat}'
endfunction
command! -buffer WekaPasteTraces call s:readTracesToBuffer()
