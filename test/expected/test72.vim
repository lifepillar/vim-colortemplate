" Name:         Test 72
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

hi clear
let g:colors_name = 'test72'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

if (has('termguicolors') && &termguicolors) || has('gui_running')
  let g:terminal_ansi_colors = ['#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff']
endif
if &background ==# 'dark'
  hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
else
  " Light background
  hi Normal guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE
endif

" vim: et ts=2 sw=2
