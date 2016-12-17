command! -bang -bar WekaBuildErrors call weka#log_parsing#fillQuickfixFromBuildLog(<bang>1)
command! -bang -bar -nargs=? WekaTestErrors call weka#log_parsing#fillQuickfixFromTestlightErrors(<q-args>, <bang>1)
