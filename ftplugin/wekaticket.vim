if !exists('b:terminalogy_templates')
	let b:terminalogy_templates = {}
endif

setlocal textwidth=0
let g:weka_ticketKey = matchstr(bufname(''), '\v\C(WEKAPP|REG)-\d+')
if empty(g:weka_ticketKey) && exists('$GHOST_TEXT_TITLE')
	let g:weka_ticketKey = matchstr($GHOST_TEXT_TITLE, '\v\C(WEKAPP|REG)-\d+')
endif
if !empty(g:weka_ticketKey)
	WekaLoadTicketInfo
endif

if get(g:, 'weka_ticketFiletype_changeDir') && exists('$WEKAPP_PATH')
	cd $WEKAPP_PATH
endif

let b:terminalogy_basic = {
			\ 'linesAbove': ['{noformat}'],
			\ 'linesBetween': [''],
			\ 'linesBelow': ['{noformat}'],
			\ 'runInDir': weka#wekaProjectPathOrGlobal(),
			\ 'implicitFilters': ['sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"'],
			\ }

let b:terminalogy_templates.teka = extend({
			\ 'command': printf('./teka -q logs %s teka.log 2>/dev/null | awk -F\| ''/\0/'' | cut -d\| -f1,2,7-', g:weka_ticketKey),
			\ }, b:terminalogy_basic)

let b:terminalogy_templates.testlight = extend({
			\ 'command': printf('./teka -q logs %s testlight.log 2>/dev/null | awk -F\| ''/\0/'' | cut -d\| -f1,2,7-', g:weka_ticketKey),
			\ }, b:terminalogy_basic)

let b:terminalogy_templates['testlight-chain'] = extend({
			\ 'command': printf('for logfile in testlight.log{.{\1..1},}; do ./teka -q logs %s $logfile 2>/dev/null; done | awk -F\| ''/\0/'' | cut -d\| -f1,2,7-', g:weka_ticketKey),
			\ }, b:terminalogy_basic)

let b:terminalogy_templates.jrpc = extend({
			\ 'command': printf('./teka -q logs %s logs/jrpc.log 2>/dev/null | awk -F\| ''/\0/'' | cut -d\| -f1,2,6,7-', g:weka_ticketKey),
			\ }, b:terminalogy_basic)

let b:terminalogy_templates['objects-log'] = extend({
			\ 'command': printf('./teka -q logs %s logs/objects.log 2>/dev/null | awk -F\| ''/\0/'' | cut -d\| -f1,7-', g:weka_ticketKey),
			\ }, b:terminalogy_basic)

let b:terminalogy_templates['objects-chain'] = extend({
			\ 'command': printf('for logfile in logs/objects.log{.{\1..1},}; do ./teka -q logs %s $logfile 2>/dev/null; done | awk -F\| ''/\0/'' | cut -d\| -f1,7-', g:weka_ticketKey),
			\ }, b:terminalogy_basic)

let b:terminalogy_templates['objects-yaml'] = extend({
			\ 'command': printf('./teka -q logs %s logs/objects.yaml.log 2>/dev/null | awk -F\| ''/\0/''', g:weka_ticketKey),
			\ }, b:terminalogy_basic)

let b:terminalogy_templates['objects-yq'] = extend({
			\ 'command': printf('./teka -q logs %s logs/objects.yaml.log 2>/dev/null | grep -v ''Entering virtual env'' | yq --yaml-output ''\0''', g:weka_ticketKey),
			\ }, b:terminalogy_basic)

function! s:complete_artifacts(args)
	if !exists('g:weka_ticketFields.artifacts')
		echoerr 'List of artifacts not loaded yet'
		return []
	endif
	return copy(g:weka_ticketFields.artifacts)
endfunction
let b:terminalogy_templates.artifacts = extend({
			\ 'command': printf('./teka -q logs %s \1 2>/dev/null | awk -F\| ''/\0/''', g:weka_ticketKey),
			\ 'complete_1': function('s:complete_artifacts')
			\ }, b:terminalogy_basic)

function! s:readTracesToBuffer() abort
	let l:viewerOutput = shellescape(weka#wekaProjectPathOrGlobal()).'/viewer.output'
	let l:lastLine = str2nr(system('awk "/# FILTER:/ {print NR}" '.l:viewerOutput.'| tail -1'))
	execute 'read !echo {noformat}; awk "'.l:lastLine.'<=NR" '.l:viewerOutput.'; echo {noformat}'
endfunction
command! -buffer WekaPasteTraces call s:readTracesToBuffer()
