" Name:         Test 58
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test58'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

if 1 " some condition
  hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
elseif '#000000' == '#ffffff' " interpolation works here
  hi Normal guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE
else " A comment
  hi Normal guifg=#000000 guibg=#000000 gui=NONE cterm=NONE
endif " end some condition (255)

" vim: et ts=2 sw=2
