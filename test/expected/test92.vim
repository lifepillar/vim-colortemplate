" Name:         Test 92
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test92'

let s:t_Co = has('gui_running') ? -1 : get(g:, 'test92_t_Co', get(g:, 't_Co', exists('&t_Co') ? +&t_Co : 0))
let s:italics = get(g:, 'test92_italics', 1)

hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
hi Comment guifg=#ffffff guibg=#000000 gui=italic cterm=italic
if !s:italics
  hi Comment gui=NONE cterm=NONE
endif

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  hi Comment ctermfg=255 ctermbg=16 cterm=italic
  if !s:italics
    hi Comment cterm=NONE
  endif
  unlet s:t_Co s:italics
  finish
endif

" vim: et ts=8 sw=2 sts=2
