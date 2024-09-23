" Name:         Test 82
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test84'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)
let s:italics = has('gui_running') || (&t_ZH != '' && &t_ZH != '[7m' && !has('win32'))

hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
hi StatusLine guifg=#000000 guibg=#ffffff gui=bold,italic cterm=italic
if !s:italics
  hi StatusLine gui=bold cterm=NONE
endif

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  hi StatusLine ctermfg=16 ctermbg=255 cterm=italic
  if !s:italics
    hi StatusLine cterm=NONE
  endif
  unlet s:t_Co s:italics
  finish
endif

" vim: et ts=8 sw=2 sts=2
