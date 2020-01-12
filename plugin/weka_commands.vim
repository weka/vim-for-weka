command! -bang -bar WekaBuildErrors call weka#log_parsing#fillQuickfixFromBuildLog(<bang>1)
command! -bang -bar -nargs=? WekaTekaErrors call weka#log_parsing#fillQuickfixFromInfraLogfileErrors(<q-args>, 'teka.log', <bang>1)
command! -bang -bar -nargs=? WekaTestErrors call weka#log_parsing#fillQuickfixFromInfraLogfileErrors(<q-args>, 'testlight.log', <bang>1)
command! -bang -bar -nargs=? WekaFailures call weka#log_parsing#fillQuickfixFromInfraLogfileErrors(<q-args>, 'failures.log', <bang>1)
command! -bar -nargs=? WekaInvestigate call weka#investigate#openInvestigateTui(<q-args>)

command! WekaLoadTicketInfo call weka#jira#fetchIssueAsyncPutIn(g:weka_ticketKey, g:, 'weka_ticketFields')
command! -nargs=? WekaSetTicket if !empty(<q-args>)| let g:weka_ticketKey = <q-args> | endif | WekaLoadTicketInfo

command! WekaTicketDiff execute 'Gdiff ' . g:weka_ticketFields.commit
