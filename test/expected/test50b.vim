" Name:         Test 50b
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test50b'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if (has('termguicolors') && &termguicolors) || has('gui_running')
  hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
  let g:terminal_ansi_colors = ['#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000']
  unlet s:t_Co
  finish
endif

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  if !has('patch-8.0.0616') " Fix for Vim bug
    set background=dark
  endif
  let g:terminal_ansi_colors = ['#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000']
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
