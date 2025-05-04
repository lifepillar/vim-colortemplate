" Name:         Test 70
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test70'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

hi Normal guibg=#000000
hi CursorLine guifg=#ffffff

if s:t_Co >= 8
  hi Normal ctermbg=Black
  hi CursorLine ctermfg=White cterm=underline
  unlet s:t_Co
  finish
endif

if s:t_Co >= 0
  hi Normal term=NONE
  hi CursorLine term=underline
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
