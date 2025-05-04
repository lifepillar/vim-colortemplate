" Name:         Test 91
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test91'

let s:t_Co = has('gui_running') ? -1 : get(g:, 'test91_t_Co', get(g:, 't_Co', exists('&t_Co') ? +&t_Co : 0))

hi! link @function Label
hi! link @text.literal Comment

let g:terminal_color_0 = '#000000'
let g:terminal_color_1 = '#000000'
let g:terminal_color_2 = '#000000'
let g:terminal_color_3 = '#000000'
let g:terminal_color_4 = '#000000'
let g:terminal_color_5 = '#000000'
let g:terminal_color_6 = '#000000'
let g:terminal_color_7 = '#000000'
let g:terminal_color_8 = '#ffffff'
let g:terminal_color_9 = '#ffffff'
let g:terminal_color_10 = '#ffffff'
let g:terminal_color_11 = '#ffffff'
let g:terminal_color_12 = '#ffffff'
let g:terminal_color_13 = '#ffffff'
let g:terminal_color_14 = '#ffffff'
let g:terminal_color_15 = '#ffffff'

hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
