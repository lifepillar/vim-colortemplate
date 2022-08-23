" Name:         Test 64
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test64'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

if 1
elseif ok
else
endif
hi Normal guifg=#000000 guibg=#000000 gui=NONE cterm=NONE
if 4
elseif good
else
endif

if s:t_Co >= 256
  if 2
  elseif ok
  else
  endif
  hi Normal ctermfg=16 ctermbg=16 cterm=NONE
  unlet s:t_Co
  finish
endif

if s:t_Co >= 8
  if 3
  elseif ok
  else
  endif
  hi Normal ctermfg=Black ctermbg=Black cterm=NONE
  if 5
  elseif good
  else
  endif
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
