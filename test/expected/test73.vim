" Name:         Test 73
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test73'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

if 1
	hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
else
	hi Normal guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE
endif

" vim: noet ts=8 sw=8 sts=8
