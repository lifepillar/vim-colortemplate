" Name:         Test 77
" Author:       Me <me@somewhere.org>
" Maintainer:   Me <me@somewhere.org>
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test77'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

if s:t_Co >= 256
  hi Normal ctermfg=7 ctermbg=NONE cterm=NONE
  hi EndOfBuffer ctermfg=0 ctermbg=NONE cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
