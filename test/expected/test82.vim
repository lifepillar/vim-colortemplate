" Name:         Test 82
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test82'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

hi Normal guifg=#a34c9e guibg=#ffffff gui=NONE cterm=NONE

" vim: et ts=2 sw=2
