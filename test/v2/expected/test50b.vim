" Name:         Test 50b
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test50b'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
let g:terminal_ansi_colors = ['#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000']

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  let g:terminal_ansi_colors = ['#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000','#000000']
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
