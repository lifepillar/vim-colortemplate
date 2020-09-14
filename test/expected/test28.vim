" Name:         Test 28
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'test28'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if (has('termguicolors') && &termguicolors) || has('gui_running')
  hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
  let z = 'Test 28'
  let z = 'test28'
  let z = 'y'
  let z = 'y'
  let g:foo = [
        \ White
        \ 231
        \ #ffffff]
  " xxxx yyyy
  hi Foobar ctermfg=255 ctermbg=231 guibg=#000000 guifg=#ffffff guisp=#ffffff
  unlet s:t_Co
  finish
endif

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=231 cterm=NONE
  if !has('patch-8.0.0616') " Fix for Vim bug
    set background=dark
  endif
  let z = 'Test 28'
  let z = 'test28'
  let z = 'y'
  let z = 'y'
  let g:foo = [
        \ White
        \ 231
        \ #ffffff]
  " xxxx yyyy
  hi Foobar ctermfg=255 ctermbg=231 guibg=#000000 guifg=#ffffff guisp=#ffffff
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
