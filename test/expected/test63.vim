" Name:         Test 63
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'test63'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

call foo()

if s:t_Co >= 256
  call bar()
  hi Normal ctermfg=16 ctermbg=16 cterm=NONE
  call foobar()
  unlet s:t_Co
  finish
endif

