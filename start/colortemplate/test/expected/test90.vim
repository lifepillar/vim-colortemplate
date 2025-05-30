" Name:         Test 90
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test90'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
if has('nvim-0.8')
  hi! link @function Label
  hi! link @text.literal Comment
endif

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  if has('nvim-0.8')
    hi! link @function Label
    hi! link @text.literal Comment
  endif
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
