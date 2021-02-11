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
call extend(b:terminalogy_templates['objects-yq'], {
			\ 'linesAbove': ['{code:yaml}'],
			\ 'linesBelow': ['{code}'],
			\ })

let b:terminalogy_templates['stress0-file-syscalls'] = extend({
			\ 'command': printf('./teka -q stress0 file-syscalls --system %s --target \1 --name \2 2>/dev/null | sort -k1n | sort -t] -k2 --stable | uniq', g:weka_ticketKey),
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
command! -buffer WekaTerminalogyArtifacts call weka#terminalogy#artifactsFZF()

function! s:readTracesThatStartInLineNumbers(lineNumbers) abort
	let l:lineNumbersCondition = join(map(a:lineNumbers, '"NR == " . v:val'), ' || ')
	let l:viewerOutputPath = shellescape(weka#wekaProjectPathOrGlobal()).'/viewer.output'
	let l:awkProgram = '/{noformat}/ {flag = 0} ' . l:lineNumbersCondition . ' {flag = 1} flag {print} /# ============/ {flag = 0} BEGIN {print "{noformat}"} END {print "{noformat}"}'
	let l:lines = systemlist(printf('awk %s %s', shellescape(l:awkProgram), l:viewerOutputPath))
	call append(line('.'), l:lines)
endfunction

function! s:readTracesToBuffer() abort
	let l:viewerOutputPath = shellescape(weka#wekaProjectPathOrGlobal()).'/viewer.output'
	let l:awkProgram = '/# FILTER:/ {printf "%d %s ", NR, $0} /COUNT:/ {print} FLAG {FLAG = 0; printf "%d %s\n", NR, $0} /{noformat}/ {FLAG = 1}'
	let l:fzfPreview = 'tail +{1} ' . l:viewerOutputPath . ' | awk "/{noformat}/ {exit} // {print} /# ===============/ {exit}"'
	let l:source = printf('awk %s %s', shellescape(l:awkProgram), l:viewerOutputPath)
	let g:source = l:source
	if exists('*fzf#run')
		call fzf#run({
					\ 'source': l:source,
					\ 'options': ['--multi', '--tac', '--no-sort', '--with-nth=2..', '--preview', l:fzfPreview, '--preview-window=up'],
					\ 'sink*': function('s:readTracesToBufferFzfSink'),
					\ })
	else
		call s:readTracesToBufferFzfSink(systemlist(l:source . ' | tail -1'))
	endif
endfunction

function! s:readTracesToBufferFzfSink(choice) abort
	let l:lineNumbers = map(copy(a:choice), 'split(v:val)[0]')
	if empty(l:lineNumbers)
		return
	endif
	call s:readTracesThatStartInLineNumbers(l:lineNumbers)
endfunction

command! -buffer WekaPasteTraces call s:readTracesToBuffer()
