" Name:         Test 70
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test70'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if (has('termguicolors') && &termguicolors) || has('gui_running')
  hi Normal guibg=#000000
  hi CursorLine guifg=#ffffff
  unlet s:t_Co
  finish
endif

if s:t_Co >= 8
  hi Normal ctermbg=Black
  hi CursorLine ctermfg=White cterm=underline
  unlet s:t_Co
  finish
endif

if s:t_Co >= 2
  hi Normal term=NONE
  hi CursorLine term=underline
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
