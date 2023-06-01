" Name:         Test 82
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test82'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

hi Normal guifg=#a34c9e guibg=#ffffff gui=NONE cterm=NONE

" vim: et sw=2 sts=2
