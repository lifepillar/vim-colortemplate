" Name:         Test 88
" Author:       y
" Maintainer:   w

set background=dark

hi clear
let g:colors_name = 'test88'


hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 ctermul=NONE cterm=NONE

if !has('patch-8.0.0616') && !has('gui_running') " Fix for Vim bug
  set background=dark
endif

if empty(&t_Co)
  finish
endif

if str2nr(&t_Co) >= 256
  finish
endif

if str2nr(&t_Co) >= 16
  hi Normal ctermfg=White ctermbg=Black ctermul=NONE cterm=NONE
  finish
endif

if str2nr(&t_Co) >= 8
  hi Normal ctermfg=White ctermbg=Brown ctermul=NONE cterm=NONE

  if !has('patch-8.0.0616') " Fix for Vim bug
    set background=dark
  endif
  finish
endif

" vim: et ts=8 sw=2 sts=2
