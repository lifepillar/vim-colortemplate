" Name:         Test 65
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test65'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

hi Normal guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi LineNr guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE

" vim: et ts=2 sw=2
