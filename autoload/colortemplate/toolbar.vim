fun! colortemplate#toolbar#show()
  if get(g:, 'colortemplate_toolbar', 1) && (has('patch-8.0.1123') && has('menu')) " has window-toolbar
    if getbufvar('%', '&ft') ==# 'colortemplate' && expand('%:t') !~# '\m^_'
      nunmenu WinBar
      nnoremenu <silent> 1.10 WinBar.Build! :Colortemplate!<cr>
      nnoremenu <silent> 1.20 WinBar.BuildAll! :ColortemplateAll!<cr>
      nnoremenu <silent> 1.30 WinBar.Show :call colortemplate#enable_colorscheme()<cr>
      nnoremenu <silent> 1.40 WinBar.Hide :call colortemplate#disable_colorscheme()<cr>
      nnoremenu <silent> 1.50 WinBar.Check :ColortemplateValidate<cr>
      nnoremenu <silent> 1.60 WinBar.Stats :ColortemplateStats<cr>
      nnoremenu <silent> 1.70 WinBar.Source :call colortemplate#view_source()<cr>
      nnoremenu <silent> 1.75 WinBar.HiTest :call colortemplate#highlighttest()<cr>
      " nnoremenu <silent> 1.80 WinBar.Colortest :call colortemplate#colortest()<cr>
      nnoremenu          1.90 WinBar.OutDir :ColortemplateOutdir<cr>
      nnoremenu 1.99 WinBar.✕ :nunmenu WinBar<cr>
    endif
  endif
  return ''
endf

fun! colortemplate#toolbar#hide()
  if getbufvar('%', '&ft') ==# 'colortemplate'
    nunmenu WinBar
  endif
endf

