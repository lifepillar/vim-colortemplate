" Name:         Test 73
" Author:       y

set background=dark

hi clear
let g:colors_name = 'test73'

let s:foo = get(g:, 'foo', 0)

hi Normal guifg=#000000 guibg=#ffffff guisp=NONE gui=NONE cterm=NONE
if s:foo == 1
  hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE cterm=NONE
endif

" vim: et ts=8 sw=2 sts=2
