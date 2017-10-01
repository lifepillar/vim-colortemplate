" Name:         Pablo
" Author:       Ron Aaron <ron@ronware.org>
" Maintainer:   Ron Aaron <ron@ronware.org>
" License:      Vim License (see `:help license`)
" Last Updated: Sun Oct  1 12:49:58 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < 256)
  echohl Error
  echomsg 'Pablo: There are not enough colors.'
  echohl None
  finish
endif

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'pablo'

if !has('gui_running') && get(g:, 'pablo_transp_bg', 0)
hi Normal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
hi Normal ctermfg=255 ctermbg=0 guifg=#ffffff guibg=#000000 guisp=NONE cterm=NONE gui=NONE
endif
hi Directory ctermfg=34 ctermbg=NONE guifg=#00c000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Search ctermfg=NONE ctermbg=184 guifg=NONE guibg=#c0c000 guisp=NONE cterm=NONE gui=NONE
hi StatusLine ctermfg=226 ctermbg=21 guifg=#ffff00 guibg=#0000ff guisp=NONE cterm=NONE gui=NONE
hi Comment ctermfg=244 ctermbg=NONE guifg=#808080 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Constant ctermfg=51 ctermbg=NONE guifg=#00ffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=NONE ctermbg=196 guifg=NONE guibg=#ff0000 guisp=NONE cterm=NONE gui=NONE
hi Identifier ctermfg=51 ctermbg=NONE guifg=#00c0c0 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE
hi PreProc ctermfg=46 ctermbg=NONE guifg=#00ff00 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Special ctermfg=21 ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Statement ctermfg=184 ctermbg=NONE guifg=#c0c000 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Todo ctermfg=19 ctermbg=184 guifg=#000080 guibg=#c0c000 guisp=NONE cterm=NONE gui=NONE
hi Type ctermfg=34 ctermbg=NONE guifg=#00c000 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold

" Color: black                #000000                0        0
" Color: green                #00c000               34        2
" Color: yellow               #c0c000              184        3
" Color: blue                 #000080               19        4
" Color: cyan                 #00c0c0               51        6
" Color: brightblack          #808080              244        8
" Color: brightred            #ff0000              196        9
" Color: brightgreen          #00ff00               46        10
" Color: brightyellow         #ffff00              226        11
" Color: brightblue           #0000ff               21        12
" Color: brightcyan           #00ffff               51        14
" Color: brightwhite          #ffffff              255        15
" Background: dark
" Normal               brightwhite/none  black/none
" Directory            green             none
" Search               none              yellow
" StatusLine           brightyellow      brightblue
" Comment              brightblack       none
" Constant             brightcyan        none
" Error                none              brightred
" Identifier           cyan              none                 t=bold
" PreProc              brightgreen       none
" Special              brightblue        none
" Statement            yellow            none                 bold
" Todo                 blue              yellow
" Type                 green             none                 g=bold
