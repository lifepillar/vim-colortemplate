fun! colortemplate#toolbar#show()
  if expand('%:t') !~# '\m^_'
    nnoremenu 1.10 WinBar.Build :Colortemplate<cr>
    nnoremenu 1.20 WinBar.Build! :Colortemplate!<cr>
    nnoremenu 1.30 WinBar.View :silent call colortemplate#enable_colorscheme()<cr>
    nnoremenu 1.40 WinBar.Hide :silent call colortemplate#disable_colorscheme()<cr>
    nnoremenu 1.50 WinBar.Validate :call colortemplate#validate()<cr>
    nnoremenu 1.60 WinBar.Stats :silent call colortemplate#stats()<cr>
    let l:wd = escape(expand('%:p:h:t'), '\/ ')
    execute 'nnoremenu 1.70 WinBar.@'.l:wd ':call colortemplate#setwd()<cr>'
    nnoremenu 1.99 WinBar.✕ :nunmenu WinBar<cr>
  endif
endf

