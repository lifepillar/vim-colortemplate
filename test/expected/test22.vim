" Name:         Test 22
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test22'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1
let s:italics = (&t_ZH != '' && &t_ZH != '[7m') || has('gui_running')

hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
hi ColorColumn guifg=fg guibg=NONE guisp=#ffffff gui=bold,italic,nocombine,standout,undercurl,underline cterm=bold,inverse,italic,nocombine,standout,underline
if !s:italics
  hi ColorColumn gui=bold,nocombine,standout,undercurl,underline cterm=bold,inverse,nocombine,standout,underline
endif

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  hi ColorColumn ctermfg=fg ctermbg=NONE cterm=bold,inverse,italic,nocombine,standout,underline
  if !s:italics
    hi ColorColumn cterm=bold,inverse,nocombine,standout,underline
  endif
  unlet s:t_Co s:italics
  finish
endif

" vim: et ts=2 sw=2
