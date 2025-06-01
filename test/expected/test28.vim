" Name:         Test 28
" Author:       aa
" Maintainer:   mm

hi clear
let g:colors_name = 'test28'

" Full name is Test 28
" Short name is test28
" Author and maintainer: aa and mm

if &background == 'dark'
  let fullname = 'Test 28'
  let shortname = 'test28'
  let author = 'aa'
  let maintainer = 'mm'
  let background = 'dark'
  let g:foo = [
      \ 'White',
      \ '231',
      \ '#ffffff']
  " xxxx yyyy
  hi Foobar ctermfg=255 ctermbg=Black guibg=#000000 guifg=#ffffff guisp=#ffffff

  hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=231 cterm=NONE

  finish
endif

if &background == 'light'
  let fullname = 'Test 28'
  let shortname = 'test28'
  let author = 'aa'
  let maintainer = 'mm'
  let background = 'light'
  let g:foo = [
      \ 'Gray',
      \ '236',
      \ '#fafafa']
  " xxxx yyyy
  hi Foobar ctermfg=231 ctermbg=DarkGray guibg=#333333 guifg=#fafafa guisp=#fafafa

  hi Normal guifg=#fafafa guibg=#333333 guisp=NONE gui=NONE ctermfg=231 ctermbg=236 cterm=NONE

endif

" vim: et ts=8 sw=2 sts=2
