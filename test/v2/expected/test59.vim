" Name:         Test 59
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test59'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)
let s:italics = (&t_ZH != '' && &t_ZH != '[7m') || has('gui_running')

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=italic
  if !s:italics
    hi Normal cterm=NONE
  endif
  if 1 " some condition
    hi LineNr ctermfg=255 ctermbg=16 cterm=italic
    if !s:italics
      hi LineNr cterm=NONE
    endif
  endif " end some condition (255)
  unlet s:t_Co s:italics
  finish
endif

" vim: et ts=8 sw=2 sts=2
