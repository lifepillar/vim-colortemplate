" Name:         Test 61
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test61'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

let x256 = '236'
let x16  = 'Black'
let xgui = '#333333'
hi Foobar ctermbg=236

if s:t_Co >= 256
  hi Normal ctermfg=236 ctermbg=236 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
