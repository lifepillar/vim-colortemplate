" Name:         Test 73
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test73'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if (has('termguicolors') && &termguicolors) || has('gui_running')
	if 1
		hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
	else
		hi Normal guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE
	endif
	unlet s:t_Co
	finish
endif

" vim: noet
