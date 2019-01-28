function! weka#jira#fetchIssueCommand(job, data) abort
	let l:project = matchstr(a:job, '\v^\w*\ze-\d+$')
	let l:codeLines = [
				\ 'import json;',
				\ 'from wepy.devops.jira import JiraProject;',
				\ printf('issue = JiraProject.PROJECTS[%s]().get_issue_by_id(%s);', string(l:project), string(a:job)),
				\ 'print(json.dumps({',
				\ ]
	for [l:name, l:expr] in items(a:data)
		call add(l:codeLines, printf('    %s: %s,', string(l:name), l:expr))
	endfor
	call extend(l:codeLines, [
				\ '}));'
				\ ])
	return weka#tekaCommand('-q explore -c '.shellescape(join(l:codeLines)))
endfunction

function! weka#jira#fetchIssueAsync(job, Callback) abort
	let l:command = './teka -q explore -c "exec(sys.stdin.read())"'
	let l:code = readfile(weka#vfwScriptPath('jira-issue-data-script.py'))
	call insert(l:code, 'JIRA_TICKET_KEY = ' . string(a:job))
	let l:gatheredData = []

	function! OnExit(...) closure
		try
			let l:asJson = json_decode(join(l:gatheredData, ''))
		catch //
			return
		endtry
		call a:Callback(l:asJson)
	endfunction

	if exists('*jobstart') " Neovim
		let l:vimjob = jobstart(l:command, {
					\ 'cwd': weka#wekaProjectPath(),
					\ 'on_stdout': {job_id, data, event -> add(l:gatheredData, join(data, "\n"))},
					\ 'on_exit': funcref('OnExit'),
					\ })
		call chansend(l:vimjob, l:code)
		call chanclose(l:vimjob, 'stdin')
	elseif exists('*job_start') "Vim
		let l:vimjob = job_start(l:command, {
					\ 'cwd': weka#wekaProjectPath(),
					\ 'in_mode': 'nl', 'out_mode': 'nl',
					\ 'out_cb': {channel, msg -> add(l:gatheredData, msg)},
					\ 'exit_cb': funcref('OnExit'),
					\ })
		call string(ch_sendraw(l:vimjob, join(l:code, "\n")))
		call string(ch_close_in(l:vimjob))
	endif
endfunction

function! s:setItemInDict(dict, key, value) abort
	let a:dict[a:key] = a:value
endfunction

function! weka#jira#fetchIssueAsyncPutIn(job, dict, key) abort
	if !has('lambda')
		return
	endif
	call weka#jira#fetchIssueAsync(a:job, function('s:setItemInDict', [a:dict, a:key]))
endfunction
