" Name:         Test 86
" Author:       y
" Maintainer:   w

hi clear
let g:colors_name = 'test86'

if &background == 'dark'
  let g:terminal_ansi_colors = ['#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff']

  hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE

  finish
endif

if &background == 'light'
  let g:terminal_ansi_colors = ['#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff']

  hi Normal guifg=#000000 guibg=#ffffff guisp=NONE gui=NONE ctermfg=16 ctermbg=255 cterm=NONE

endif

" vim: et ts=8 sw=2 sts=2
