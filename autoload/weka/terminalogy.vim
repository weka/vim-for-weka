function! weka#terminalogy#artifactsFZF() abort
	call fzf#run({
				\ 'source': g:weka_ticketFields.artifacts,
				\ 'options': ['--tac', '--tiebreak=index'],
				\ 'sink*': function('s:runArtifacts'),
				\ })
endfunction

function! s:runArtifacts(artifacts) abort
	execute join(map(['Terminalogy', 'artifacts'] + a:artifacts, 'fnameescape(v:val)'))
endfunction
