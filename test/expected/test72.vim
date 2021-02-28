" Name:         Test 72
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

hi clear
let g:colors_name = 'test72'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if (has('termguicolors') && &termguicolors) || has('gui_running')
  let g:terminal_ansi_colors = ['#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff', '#000000', '#ffffff']
  if &background ==# 'dark'
    hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
    unlet s:t_Co
    finish
  endif
  " Light background
  hi Normal guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
