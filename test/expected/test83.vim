" Name:         Test 83
" Description:  Color scheme with custom reset block
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

" Manually inserted reset block
hi clear               " Manual
if exists('syntax_on') " Manual
  syntax reset         " Manual
endif                  " Manual

let g:colors_name     = 'test83'

let s:name            = 'Test 83'
let s:author          = 'y'
let s:maintainer      = 'w'
let s:license         = 'Vim License (see `:help license`)'
let s:description     = 'Color scheme with custom reset block'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

" Verbatim block 1
hi Normal guifg=#a34c9e guibg=#ffffff gui=NONE cterm=NONE
" Verbatim block 2

" vim: et ts=2 sw=2
