" Name:         Test 94
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test94'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)
let s:italics = (&t_ZH != '' && &t_ZH != '[7m') || has('gui_running')

hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
hi Comment guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
hi Bold guifg=#ffffff guibg=#000000 gui=bold cterm=bold
hi Italic guifg=#ffffff guibg=#000000 gui=italic cterm=italic
if !s:italics
  hi Italic gui=NONE cterm=NONE
endif

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  hi Comment ctermfg=255 ctermbg=16 cterm=NONE
  hi Bold ctermfg=255 ctermbg=16 cterm=bold
  hi Italic ctermfg=255 ctermbg=16 cterm=italic
  if !s:italics
    hi Italic cterm=NONE
  endif
  unlet s:t_Co s:italics
  finish
endif

" vim: et ts=8 sw=2 sts=2
