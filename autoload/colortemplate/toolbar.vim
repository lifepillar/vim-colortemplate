fun! colortemplate#toolbar#show()
  if getbufvar('%', '&ft') ==# 'colortemplate' && expand('%:t') !~# '\m^_'
    nunmenu WinBar
    nnoremenu <silent> 1.10 WinBar.Build :update<cr>:call colortemplate#build_dir('')<cr>
    nnoremenu <silent> 1.20 WinBar.Build! :update<cr>:call colortemplate#build_dir('!')<cr>
    nnoremenu <silent> 1.30 WinBar.Enable :call colortemplate#enable_colorscheme()<cr>
    nnoremenu <silent> 1.40 WinBar.Disable :call colortemplate#disable_colorscheme()<cr>
    nnoremenu <silent> 1.50 WinBar.Validate :call colortemplate#validate()<cr>
    nnoremenu <silent> 1.60 WinBar.Stats :update<cr>:call colortemplate#stats()<cr>
    nnoremenu <silent> 1.70 WinBar.View\ Source :call colortemplate#view_source()<cr>
    let l:wd = escape(fnamemodify(get(b:, 'colortemplate_wd', getcwd()), ':p:h:t'), './\ ')
    execute 'nnoremenu 1.70 WinBar.@'.l:wd ':call colortemplate#setwd()<cr>'
    nnoremenu 1.99 WinBar.✕ :nunmenu WinBar<cr>
  endif
  return ''
endf

