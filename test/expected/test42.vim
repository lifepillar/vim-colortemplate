" Name:         Test 42
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test42'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

hi Normal guifg='ghost white' guibg=BlanchedAlmond gui=NONE cterm=NONE

if s:t_Co >= 256
  hi Normal ctermfg=231 ctermbg=223 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
