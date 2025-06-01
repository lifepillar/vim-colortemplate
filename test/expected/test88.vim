" Name:         Test 88
" Author:       y
" Maintainer:   w

set background=dark

hi clear
let g:colors_name = 'test88'

let s:t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE

if !has('patch-8.0.0616') && !has('gui_running') " Fix for Vim bug
  set background=dark
endif

if s:t_Co >= 256
  finish
endif

if s:t_Co >= 16
  hi Normal ctermfg=White ctermbg=Black cterm=NONE
  finish
endif

if s:t_Co >= 8
  hi Normal ctermfg=White ctermbg=Brown cterm=NONE

  if !has('patch-8.0.0616') " Fix for Vim bug
    set background=dark
  endif
  finish
endif

" vim: et ts=8 sw=2 sts=2
