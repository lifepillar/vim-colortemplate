" Name:         Test 65
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test65'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

hi Normal guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi LineNr guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE

" vim: et ts=8 sw=2 sts=2
