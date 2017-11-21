" Name:         Blue
" Description:  Templatized version of blue colorscheme from Vim
" Author:       Steven Vertigan <steven@vertigan.wattle.id.au>
" Maintainer:   To be determined
" License:      Vim License (see `:help license`)
" Last Updated: Tue Nov 21 19:58:30 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < 16)
  echoerr '[Blue] There are not enough colors.'
  finish
endif

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'blue'

" Revision #5: Switch main text from white to yellow for easier contrast,
" fixed some problems with terminal backgrounds.

if !has('gui_running') && get(g:, 'blue_transp_bg', 0)
  hi Normal ctermfg=yellow ctermbg=NONE guifg=yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
  hi Normal ctermfg=yellow ctermbg=darkBlue guifg=yellow guibg=darkBlue guisp=NONE cterm=NONE gui=NONE
endif
hi Cursor ctermfg=black ctermbg=white guifg=black guibg=white guisp=NONE cterm=NONE gui=NONE
hi DiffAdd ctermfg=black ctermbg=blue guifg=black guibg=slateblue guisp=NONE cterm=NONE gui=NONE
hi DiffChange ctermfg=black ctermbg=darkGreen guifg=black guibg=darkGreen guisp=NONE cterm=NONE gui=NONE
hi DiffDelete ctermfg=black ctermbg=cyan guifg=black guibg=coral guisp=NONE cterm=NONE gui=NONE
hi DiffText ctermfg=black ctermbg=lightGreen guifg=black guibg=olivedrab guisp=NONE cterm=NONE gui=NONE
hi ErrorMsg ctermfg=lightRed ctermbg=darkBlue guifg=orange guibg=darkBlue guisp=NONE cterm=NONE gui=NONE
hi FoldColumn ctermfg=black ctermbg=gray guifg=black guibg=gray30 guisp=NONE cterm=NONE gui=NONE
hi Folded ctermfg=black ctermbg=yellow guifg=black guibg=orange guisp=NONE cterm=NONE gui=NONE
hi IncSearch ctermfg=black ctermbg=darkYellow guifg=black guibg=yellow guisp=NONE cterm=NONE gui=NONE
hi LineNr ctermfg=cyan ctermbg=NONE guifg=cyan guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi ModeMsg ctermfg=yellow ctermbg=NONE guifg=yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi MoreMsg ctermfg=yellow ctermbg=NONE guifg=yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NonText ctermfg=lightMagenta ctermbg=NONE guifg=magenta guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Search ctermfg=black ctermbg=darkYellow guifg=black guibg=orange guisp=NONE cterm=NONE gui=NONE
hi StatusLine ctermfg=cyan ctermbg=blue guifg=cyan guibg=blue guisp=NONE cterm=NONE gui=NONE,bold
hi StatusLineNC ctermfg=black ctermbg=blue guifg=black guibg=blue guisp=NONE cterm=NONE gui=NONE
hi Title guifg=white gui=bold cterm=bold
hi VertSplit ctermfg=blue ctermbg=blue guifg=blue guibg=blue guisp=NONE cterm=NONE gui=NONE
hi Visual ctermfg=black ctermbg=darkCyan guifg=black guibg=darkCyan guisp=NONE cterm=NONE,reverse gui=NONE
hi WarningMsg ctermfg=cyan ctermbg=darkBlue guifg=cyan guibg=darkBlue guisp=NONE cterm=NONE gui=NONE,bold
hi Comment ctermfg=gray ctermbg=darkBlue guifg=gray guibg=darkBlue guisp=NONE cterm=NONE gui=NONE
hi Constant ctermfg=cyan ctermbg=NONE guifg=cyan guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=red ctermbg=darkBlue guifg=red guibg=darkBlue guisp=NONE cterm=NONE gui=NONE,underline
hi Identifier ctermfg=red ctermbg=NONE guifg=gray guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Label ctermfg=yellow ctermbg=NONE guifg=yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Operator ctermfg=lightRed ctermbg=darkBlue guifg=orange guibg=darkBlue guisp=NONE cterm=NONE gui=NONE,bold
hi PreProc ctermfg=green ctermbg=NONE guifg=green guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Special ctermfg=lightMagenta ctermbg=darkBlue guifg=magenta guibg=darkBlue guisp=NONE cterm=NONE gui=NONE
hi Statement ctermfg=white ctermbg=darkBlue guifg=white guibg=darkBlue guisp=NONE cterm=NONE gui=NONE
hi Todo ctermfg=black ctermbg=darkYellow guifg=black guibg=orange guisp=NONE cterm=NONE gui=NONE
hi Type ctermfg=lightRed ctermbg=darkBlue guifg=orange guibg=darkBlue guisp=NONE cterm=NONE gui=NONE
hi Underlined ctermfg=cyan ctermbg=NONE guifg=cyan guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi cIf0 ctermfg=gray ctermbg=NONE guifg=gray guibg=NONE guisp=NONE cterm=NONE gui=NONE
finish

" Background: dark
" Color: black                black                  ~        black
" Color: blue                 blue                   ~        blue
" Color: coral                coral                  ~        cyan
" Color: cyan                 cyan                   ~        cyan
" Color: darkgreen            darkGreen              ~        darkGreen
" Color: darkblue             darkBlue               ~        darkBlue
" Color: darkcyan             darkCyan               ~        darkCyan
" Color: gray                 gray                   ~        gray
" Color: gray_red             gray                   ~        red
" Color: gray30               gray30                 ~        gray
" Color: green                green                  ~        green
" Color: magenta              magenta                ~        lightMagenta
" Color: olivedrab            olivedrab              ~        lightGreen
" Color: orange               orange                 ~        lightRed
" Color: orange_darkyellow    orange                 ~        darkYellow
" Color: orange_yellow        orange                 ~        yellow
" Color: red                  red                    ~        red
" Color: slateblue            slateblue              ~        blue
" Color: white                white                  ~        white
" Color: yellow               yellow                 ~        yellow
" Color: yellow_darkyellow    yellow                 ~        darkYellow
"     Normal yellow none
"     Normal yellow darkblue
" Cursor               black             white
" DiffAdd              black             slateblue
" DiffChange           black             darkgreen
" DiffDelete           black             coral
" DiffText             black             olivedrab
" ErrorMsg             orange            darkblue
" FoldColumn           black             gray30
" Folded               black             orange_yellow
" IncSearch            black             yellow_darkyellow
" LineNr               cyan              none
" ModeMsg              yellow            none
" MoreMsg              yellow            none
" NonText              magenta           none
" Search               black             orange_darkyellow
" StatusLine           cyan              blue              g=bold
" StatusLineNC         black             blue
" VertSplit            blue              blue
" Visual               black             darkcyan          t=reverse
" WarningMsg           cyan              darkblue          g=bold
" Comment              gray              darkblue
" Constant             cyan              none
" Error                red               darkblue          g=underline
" Identifier           gray_red          none
" Label                yellow            none
" Operator             orange            darkblue          g=bold
" PreProc              green             none
" Special              magenta           darkblue
" Statement            white             darkblue
" Todo                 black             orange_darkyellow
" Type                 orange            darkblue
" Underlined           cyan              none              underline
" cIf0                 gray              none
