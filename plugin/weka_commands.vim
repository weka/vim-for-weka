command! -bang -bar WekaBuildErrors call weka#log_parsing#fillQuickfixFromBuildLog(<bang>1)
command! -bang -bar -nargs=? WekaTekaErrors call weka#log_parsing#fillQuickfixFromInfraLogfileErrors(<q-args>, 'teka.log', <bang>1)
command! -bang -bar -nargs=? WekaTestErrors call weka#log_parsing#fillQuickfixFromInfraLogfileErrors(<q-args>, 'testlight.log', <bang>1)
command! -bar -nargs=? WekaInvestigate call weka#investigate#openInvestigateTui(<q-args>)
