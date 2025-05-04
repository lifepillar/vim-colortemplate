" Name:         Test 89
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test89'

let s:t_Co = has('gui_running') ? -1 : get(g:, 'test89_t_Co', get(g:, 't_Co', exists('&t_Co') ? +&t_Co : 0))

hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  if !has('patch-8.0.0616') " Fix for Vim bug
    set background=dark
  endif
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
