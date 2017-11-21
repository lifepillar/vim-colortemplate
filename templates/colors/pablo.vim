" Name:         Pablo
" Description:  Modernized version of Pablo (Vim colorscheme)
" Author:       Ron Aaron <ron@ronware.org>
" Maintainer:   Ron Aaron <ron@ronware.org>
" License:      Vim License (see `:help license`)
" Last Updated: Tue Nov 21 20:11:30 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < (get(g:, 'pablo_use16', 0) ? 16 : 256))
  echoerr '[Pablo] There are not enough colors.'
  finish
endif

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'pablo'

" 256-color variant
if !get(g:, 'pablo_use16', 0)
  " Color similarity table (dark background)
  "     pablo_brightred: GUI=#ff0000/rgb(255,  0,  0)  Term=196 #ff0000/rgb(255,  0,  0)  [delta=0.000000]
  "  pablo_brightyellow: GUI=#ffff00/rgb(255,255,  0)  Term=226 #ffff00/rgb(255,255,  0)  [delta=0.000000]
  "   pablo_brightgreen: GUI=#00ff00/rgb(  0,255,  0)  Term= 46 #00ff00/rgb(  0,255,  0)  [delta=0.000000]
  "            lightred: GUI=#ffd7d7/rgb(255,215,215)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=0.000000]
  "         pablo_black: GUI=#000000/rgb(  0,  0,  0)  Term= 16 #000000/rgb(  0,  0,  0)  [delta=0.000000]
  "   pablo_brightblack: GUI=#808080/rgb(128,128,128)  Term=244 #808080/rgb(128,128,128)  [delta=0.000000]
  "            white231: GUI=#ffffff/rgb(255,255,255)  Term=231 #ffffff/rgb(255,255,255)  [delta=0.000000]
  "   pablo_brightwhite: GUI=#ffffff/rgb(255,255,255)  Term=231 #ffffff/rgb(255,255,255)  [delta=0.000000]
  "        lightmagenta: GUI=#ffd7ff/rgb(255,215,255)  Term=225 #ffd7ff/rgb(255,215,255)  [delta=0.000000]
  "    pablo_brightcyan: GUI=#00ffff/rgb(  0,255,255)  Term= 51 #00ffff/rgb(  0,255,255)  [delta=0.000000]
  "    pablo_brightblue: GUI=#0000ff/rgb(  0,  0,255)  Term= 21 #0000ff/rgb(  0,  0,255)  [delta=0.000000]
  "          pablo_blue: GUI=#000080/rgb(  0,  0,128)  Term= 18 #000087/rgb(  0,  0,135)  [delta=0.997742]
  "              grey40: GUI=#666666/rgb(102,102,102)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=2.286696]
  "          pablo_cyan: GUI=#00c0c0/rgb(  0,192,192)  Term= 37 #00afaf/rgb(  0,175,175)  [delta=4.687734]
  "        pablo_yellow: GUI=#c0c000/rgb(192,192,  0)  Term=142 #afaf00/rgb(175,175,  0)  [delta=4.729465]
  "         pablo_green: GUI=#00c000/rgb(  0,192,  0)  Term= 34 #00af00/rgb(  0,175,  0)  [delta=4.752495]
  "          lightgreen: GUI=#90ee90/rgb(144,238,144)  Term=121 #87ffaf/rgb(135,255,175)  [delta=5.506701]
  "                grey: GUI=#bebebe/rgb(190,190,190)  Term=248 #a8a8a8/rgb(168,168,168)  [delta=6.064496]
  "              grey50: GUI=#7f7f7f/rgb(127,127,127)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=7.555364]
  "       cyanlightcyan: GUI=#00ffff/rgb(  0,255,255)  Term=159 #afffff/rgb(175,255,255)  [delta=9.538112]
  "           lightcyan: GUI=#e0ffff/rgb(224,255,255)  Term=159 #afffff/rgb(175,255,255)  [delta=9.677722]
  "           lightblue: GUI=#add8e6/rgb(173,216,230)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=10.163918]
  "   lightseagreentype: GUI=#60ff60/rgb( 96,255, 96)  Term=121 #87ffaf/rgb(135,255,175)  [delta=10.311495]
  "         lightyellow: GUI=#ffffe0/rgb(255,255,224)  Term=229 #ffffaf/rgb(255,255,175)  [delta=10.880707]
  "       lightgreygrey: GUI=#d3d3d3/rgb(211,211,211)  Term=248 #a8a8a8/rgb(168,168,168)  [delta=11.246825]
  "     greenlightgreen: GUI=#00ff00/rgb(  0,255,  0)  Term=121 #87ffaf/rgb(135,255,175)  [delta=14.742261]
  "       cyanlightblue: GUI=#00ffff/rgb(  0,255,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=19.943026]
  "            darkgrey: GUI=#a9a9a9/rgb(169,169,169)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=21.550199]
  "               brown: GUI=#a52a2a/rgb(165, 42, 42)  Term=130 #af5f00/rgb(175, 95,  0)  [delta=23.756716]
  "        greydarkgrey: GUI=#bebebe/rgb(190,190,190)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=27.078524]
  " lightblueunderlined: GUI=#80a0ff/rgb(128,160,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=30.383451]
  "       lightseagreen: GUI=#2e8b57/rgb( 46,139, 87)  Term=121 #87ffaf/rgb(135,255,175)  [delta=30.704694]
  " magentalightmagenta: GUI=#ff00ff/rgb(255,  0,255)  Term=225 #ffd7ff/rgb(255,215,255)  [delta=30.845801]
  "              orange: GUI=#ffa500/rgb(255,165,  0)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=31.310244]
  "         redlightred: GUI=#ff0000/rgb(255,  0,  0)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=37.517050]
  "    lightbluepreproc: GUI=#ff80ff/rgb(255,128,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=49.869151]
  "           slateblue: GUI=#6a5acd/rgb(106, 90,205)  Term=  5                           [delta=nan]
  "            darkblue: GUI=#00008b/rgb(  0,  0,139)  Term=  4                           [delta=nan]
  "              yellow: GUI=#ffff00/rgb(255,255,  0)  Term= 11                           [delta=nan]
  "  magentadarkmagenta: GUI=#ff00ff/rgb(255,  0,255)  Term=  5                           [delta=nan]
  "     magentaconstant: GUI=#ffa0a0/rgb(255,160,160)  Term= 13                           [delta=nan]
  "               black: GUI=#000000/rgb(  0,  0,  0)  Term=  0                           [delta=nan]
  "                blue: GUI=#0000ff/rgb(  0,  0,255)  Term= 12                           [delta=nan]
  "     yellowstatement: GUI=#ffff60/rgb(255,255, 96)  Term= 11                           [delta=nan]
  "           lightgrey: GUI=#d3d3d3/rgb(211,211,211)  Term=  7                           [delta=nan]
  "         cyancomment: GUI=#80a0ff/rgb(128,160,255)  Term= 14                           [delta=nan]
  "             darkred: GUI=#8b0000/rgb(139,  0,  0)  Term=  1                           [delta=nan]
  "             magenta: GUI=#ff00ff/rgb(255,  0,255)  Term= 13                           [delta=nan]
  "      magentadarkred: GUI=#ff00ff/rgb(255,  0,255)  Term=  1                           [delta=nan]
  "      cyanidentifier: GUI=#40ffff/rgb( 64,255,255)  Term= 14                           [delta=nan]
  "            seagreen: GUI=#2e8b57/rgb( 46,139, 87)  Term=  2                           [delta=nan]
  "           darkgreen: GUI=#006400/rgb(  0,100,  0)  Term=  2                           [delta=nan]
  "              purple: GUI=#a020f0/rgb(160, 32,240)  Term=  5                           [delta=nan]
  "         lightgrey90: GUI=#e5e5e5/rgb(229,229,229)  Term=  7                           [delta=nan]
  "        bluedarkblue: GUI=#0000ff/rgb(  0,  0,255)  Term=  4                           [delta=nan]
  "         darkmagenta: GUI=#8b008b/rgb(139,  0,139)  Term=  5                           [delta=nan]
  "               green: GUI=#00ff00/rgb(  0,255,  0)  Term= 10                           [delta=nan]
  "            darkcyan: GUI=#008b8b/rgb(  0,139,139)  Term=  6                           [delta=nan]
  "          reddarkred: GUI=#ff0000/rgb(255,  0,  0)  Term=  1                           [delta=nan]
  "                 red: GUI=#ff0000/rgb(255,  0,  0)  Term=  9                           [delta=nan]
  "                cyan: GUI=#00ffff/rgb(  0,255,255)  Term= 14                           [delta=nan]
  "               white: GUI=#ffffff/rgb(255,255,255)  Term= 15                           [delta=nan]
  if !has('gui_running') && get(g:, 'pablo_transp_bg', 0)
    hi Normal ctermfg=231 ctermbg=NONE guifg=#ffffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Terminal ctermfg=15 ctermbg=NONE guifg=White guibg=NONE guisp=NONE cterm=NONE gui=NONE
  else
    hi Normal ctermfg=231 ctermbg=16 guifg=#ffffff guibg=#000000 guisp=NONE cterm=NONE gui=NONE
    hi Terminal ctermfg=15 ctermbg=0 guifg=White guibg=Black guisp=NONE cterm=NONE gui=NONE
  endif
  hi Comment ctermfg=244 ctermbg=NONE guifg=#808080 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Constant ctermfg=51 ctermbg=NONE guifg=#00ffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Identifier ctermfg=37 ctermbg=NONE guifg=#00c0c0 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE
  hi Statement ctermfg=142 ctermbg=NONE guifg=#c0c000 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi PreProc ctermfg=46 ctermbg=NONE guifg=#00ff00 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Type ctermfg=34 ctermbg=NONE guifg=#00c000 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi Special ctermfg=21 ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Error ctermfg=NONE ctermbg=196 guifg=NONE guibg=#ff0000 guisp=NONE cterm=NONE gui=NONE
  hi Todo ctermfg=18 ctermbg=142 guifg=#000080 guibg=#c0c000 guisp=NONE cterm=NONE gui=NONE
  hi Directory ctermfg=34 ctermbg=NONE guifg=#00c000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StatusLine ctermfg=226 ctermbg=21 guifg=#ffff00 guibg=#0000ff guisp=NONE cterm=NONE gui=NONE
  hi Search ctermfg=0 ctermbg=142 guifg=Black guibg=#c0c000 guisp=NONE cterm=NONE gui=NONE

  " Highlight groups with default colors
  hi ColorColumn ctermfg=NONE ctermbg=1 guifg=NONE guibg=DarkRed guisp=NONE cterm=NONE gui=NONE
  hi Conceal ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
  hi Cursor ctermfg=0 ctermbg=fg guifg=Black guibg=fg guisp=NONE cterm=NONE gui=NONE
  hi CursorColumn ctermfg=NONE ctermbg=242 guifg=NONE guibg=Grey40 guisp=NONE cterm=NONE gui=NONE
  hi CursorLine ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=Grey40 gui=NONE guisp=NONE
  hi CursorLineNr ctermfg=11 ctermbg=NONE guifg=Yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi DiffAdd ctermfg=NONE ctermbg=4 guifg=NONE guibg=DarkBlue guisp=NONE cterm=NONE gui=NONE
  hi DiffChange ctermfg=NONE ctermbg=5 guifg=NONE guibg=DarkMagenta guisp=NONE cterm=NONE gui=NONE
  hi DiffDelete ctermfg=12 ctermbg=6 guifg=Blue guibg=DarkCyan guisp=NONE cterm=NONE gui=NONE,bold
  hi DiffText ctermfg=NONE ctermbg=9 guifg=NONE guibg=Red guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi! link EndOfBuffer NonText
  hi ErrorMsg ctermfg=15 ctermbg=1 guifg=White guibg=Red guisp=NONE cterm=NONE gui=NONE
  hi FoldColumn ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey guisp=NONE cterm=NONE gui=NONE
  hi Folded ctermfg=14 ctermbg=242 guifg=Cyan guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
  hi IncSearch ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi LineNr ctermfg=11 ctermbg=NONE guifg=Yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi MatchParen ctermfg=NONE ctermbg=6 guifg=NONE guibg=DarkCyan guisp=NONE cterm=NONE gui=NONE
  hi ModeMsg ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi MoreMsg ctermfg=121 ctermbg=NONE guifg=SeaGreen guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi NonText ctermfg=12 ctermbg=NONE guifg=Blue guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi Pmenu ctermfg=0 ctermbg=13 cterm=NONE guifg=NONE guibg=Magenta gui=NONE guisp=NONE
  hi PmenuSbar ctermfg=NONE ctermbg=248 guifg=NONE guibg=Grey guisp=NONE cterm=NONE gui=NONE
  hi PmenuSel ctermfg=242 ctermbg=0 cterm=NONE guifg=NONE guibg=DarkGrey gui=NONE guisp=NONE
  hi PmenuThumb ctermfg=NONE ctermbg=231 guifg=NONE guibg=White guisp=NONE cterm=NONE gui=NONE
  hi Question ctermfg=121 ctermbg=NONE guifg=Green guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi! link QuickFixLine Search
  hi SignColumn ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey guisp=NONE cterm=NONE gui=NONE
  hi SpecialKey ctermfg=81 ctermbg=NONE guifg=Cyan guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SpellBad ctermfg=NONE ctermbg=9 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Red
  hi SpellCap ctermfg=NONE ctermbg=12 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Blue
  hi SpellLocal ctermfg=NONE ctermbg=14 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Cyan
  hi SpellRare ctermfg=NONE ctermbg=13 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Magenta
  hi StatusLineNC ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi StatusLineTerm ctermfg=0 ctermbg=121 cterm=NONE,bold guifg=bg guibg=LightGreen gui=NONE,bold guisp=NONE
  hi StatusLineTermNC ctermfg=0 ctermbg=121 cterm=NONE guifg=bg guibg=LightGreen gui=NONE guisp=NONE
  hi TabLine ctermfg=231 ctermbg=242 cterm=NONE,underline guifg=NONE guibg=DarkGrey gui=NONE,underline guisp=NONE
  hi TabLineFill ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi TabLineSel ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Title ctermfg=225 ctermbg=NONE guifg=Magenta guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi VertSplit ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi Visual ctermfg=NONE ctermbg=242 guifg=NONE guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
  hi VisualNOS ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
  hi WarningMsg ctermfg=224 ctermbg=NONE guifg=Red guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi WildMenu ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow guisp=NONE cterm=NONE gui=NONE
  hi! link Boolean Constant
  hi! link Character Constant
  hi! link Conditional Statement
  hi! link Define PreProc
  hi! link Debug Special
  hi! link Delimiter Special
  hi! link Exception Statement
  hi! link Float Number
  hi! link Function Identifier
  hi Ignore ctermfg=0 ctermbg=NONE guifg=Black guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Include PreProc
  hi! link Keyword Statement
  hi! link Label Statement
  hi! link Macro PreProc
  hi! link Number Constant
  hi! link Operator Statement
  hi! link PreCondit PreProc
  hi! link Repeat Statement
  hi! link SpecialChar Special
  hi! link SpecialComment Special
  hi! link StorageClass Type
  hi! link String Constant
  hi! link Structure Type
  hi! link Tag Special
  hi! link Typedef Type
  hi Underlined ctermfg=81 ctermbg=NONE guifg=#80a0ff guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi! link lCursor Cursor
  hi ToolbarLine ctermfg=NONE ctermbg=242 guifg=NONE guibg=Grey50 guisp=NONE cterm=NONE gui=NONE
  hi ToolbarButton ctermfg=0 ctermbg=7 guifg=Black guibg=LightGrey guisp=NONE cterm=NONE,bold gui=NONE,bold
  finish
endif

" 16-color variant
if !has('gui_running') && get(g:, 'pablo_transp_bg', 0)
  hi Normal ctermfg=15 ctermbg=NONE guifg=#ffffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Terminal ctermfg=White ctermbg=NONE guifg=White guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
  hi Normal ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi Terminal ctermfg=White ctermbg=Black guifg=White guibg=Black guisp=NONE cterm=NONE gui=NONE
endif
hi Comment ctermfg=8 ctermbg=NONE guifg=#808080 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Constant ctermfg=14 ctermbg=NONE guifg=#00ffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Identifier ctermfg=6 ctermbg=NONE guifg=#00c0c0 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE
hi Statement ctermfg=3 ctermbg=NONE guifg=#c0c000 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi PreProc ctermfg=10 ctermbg=NONE guifg=#00ff00 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Type ctermfg=2 ctermbg=NONE guifg=#00c000 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi Special ctermfg=12 ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=NONE ctermbg=9 guifg=NONE guibg=#ff0000 guisp=NONE cterm=NONE gui=NONE
hi Todo ctermfg=4 ctermbg=3 guifg=#000080 guibg=#c0c000 guisp=NONE cterm=NONE gui=NONE
hi Directory ctermfg=2 ctermbg=NONE guifg=#00c000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StatusLine ctermfg=11 ctermbg=12 guifg=#ffff00 guibg=#0000ff guisp=NONE cterm=NONE gui=NONE
hi Search ctermfg=Black ctermbg=3 guifg=Black guibg=#c0c000 guisp=NONE cterm=NONE gui=NONE

" Highlight groups with default colors
hi ColorColumn ctermfg=NONE ctermbg=DarkRed guifg=NONE guibg=DarkRed guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=LightGrey ctermbg=DarkGrey guifg=LightGrey guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=Black ctermbg=fg guifg=Black guibg=fg guisp=NONE cterm=NONE gui=NONE
hi CursorColumn ctermfg=NONE ctermbg=DarkGrey guifg=NONE guibg=Grey40 guisp=NONE cterm=NONE gui=NONE
hi CursorLine ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=Grey40 gui=NONE guisp=NONE
hi CursorLineNr ctermfg=Yellow ctermbg=NONE guifg=Yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi DiffAdd ctermfg=NONE ctermbg=DarkBlue guifg=NONE guibg=DarkBlue guisp=NONE cterm=NONE gui=NONE
hi DiffChange ctermfg=NONE ctermbg=DarkMagenta guifg=NONE guibg=DarkMagenta guisp=NONE cterm=NONE gui=NONE
hi DiffDelete ctermfg=Blue ctermbg=DarkCyan guifg=Blue guibg=DarkCyan guisp=NONE cterm=NONE gui=NONE,bold
hi DiffText ctermfg=NONE ctermbg=Red guifg=NONE guibg=Red guisp=NONE cterm=NONE,bold gui=NONE,bold
hi! link EndOfBuffer NonText
hi ErrorMsg ctermfg=White ctermbg=DarkRed guifg=White guibg=Red guisp=NONE cterm=NONE gui=NONE
hi FoldColumn ctermfg=Cyan ctermbg=DarkGrey guifg=Cyan guibg=Grey guisp=NONE cterm=NONE gui=NONE
hi Folded ctermfg=Cyan ctermbg=DarkGrey guifg=Cyan guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
hi IncSearch ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi LineNr ctermfg=Yellow ctermbg=NONE guifg=Yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi MatchParen ctermfg=NONE ctermbg=DarkCyan guifg=NONE guibg=DarkCyan guisp=NONE cterm=NONE gui=NONE
hi ModeMsg ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi MoreMsg ctermfg=LightGreen ctermbg=NONE guifg=SeaGreen guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi NonText ctermfg=Blue ctermbg=NONE guifg=Blue guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi Pmenu ctermfg=Black ctermbg=Magenta cterm=NONE guifg=NONE guibg=Magenta gui=NONE guisp=NONE
hi PmenuSbar ctermfg=NONE ctermbg=Grey guifg=NONE guibg=Grey guisp=NONE cterm=NONE gui=NONE
hi PmenuSel ctermfg=DarkGrey ctermbg=Black cterm=NONE guifg=NONE guibg=DarkGrey gui=NONE guisp=NONE
hi PmenuThumb ctermfg=NONE ctermbg=White guifg=NONE guibg=White guisp=NONE cterm=NONE gui=NONE
hi Question ctermfg=LightGreen ctermbg=NONE guifg=Green guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link QuickFixLine Search
hi SignColumn ctermfg=Cyan ctermbg=DarkGrey guifg=Cyan guibg=Grey guisp=NONE cterm=NONE gui=NONE
hi SpecialKey ctermfg=LightBlue ctermbg=NONE guifg=Cyan guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpellBad ctermfg=NONE ctermbg=Red cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Red
hi SpellCap ctermfg=NONE ctermbg=Blue cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Blue
hi SpellLocal ctermfg=NONE ctermbg=Cyan cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Cyan
hi SpellRare ctermfg=NONE ctermbg=Magenta cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Magenta
hi StatusLineNC ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi StatusLineTerm ctermfg=Black ctermbg=LightGreen cterm=NONE,bold guifg=bg guibg=LightGreen gui=NONE,bold guisp=NONE
hi StatusLineTermNC ctermfg=Black ctermbg=LightGreen cterm=NONE guifg=bg guibg=LightGreen gui=NONE guisp=NONE
hi TabLine ctermfg=White ctermbg=DarkGrey cterm=NONE,underline guifg=NONE guibg=DarkGrey gui=NONE,underline guisp=NONE
hi TabLineFill ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi TabLineSel ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Title ctermfg=LightMagenta ctermbg=NONE guifg=Magenta guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi VertSplit ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi Visual ctermfg=NONE ctermbg=DarkGrey guifg=NONE guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
hi VisualNOS ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
hi WarningMsg ctermfg=LightRed ctermbg=NONE guifg=Red guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi WildMenu ctermfg=Black ctermbg=Yellow guifg=Black guibg=Yellow guisp=NONE cterm=NONE gui=NONE
hi! link Boolean Constant
hi! link Character Constant
hi! link Conditional Statement
hi! link Define PreProc
hi! link Debug Special
hi! link Delimiter Special
hi! link Exception Statement
hi! link Float Number
hi! link Function Identifier
hi Ignore ctermfg=Black ctermbg=NONE guifg=Black guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link Macro PreProc
hi! link Number Constant
hi! link Operator Statement
hi! link PreCondit PreProc
hi! link Repeat Statement
hi! link SpecialChar Special
hi! link SpecialComment Special
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi! link Tag Special
hi! link Typedef Type
hi Underlined ctermfg=LightBlue ctermbg=NONE guifg=#80a0ff guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link lCursor Cursor
hi ToolbarLine ctermfg=NONE ctermbg=DarkGrey guifg=NONE guibg=Grey50 guisp=NONE cterm=NONE gui=NONE
hi ToolbarButton ctermfg=Black ctermbg=LightGrey guifg=Black guibg=LightGrey guisp=NONE cterm=NONE,bold gui=NONE,bold
finish

" Background: dark
" Color: pablo_black                #000000              ~          0
" Color: pablo_green                #00c000              ~          2
" Color: pablo_yellow               #c0c000              ~          3
" Color: pablo_blue                 #000080              ~          4
" Color: pablo_cyan                 #00c0c0              ~          6
" Color: pablo_brightblack          #808080              ~          8
" Color: pablo_brightred            #ff0000              ~          9
" Color: pablo_brightgreen          #00ff00              ~          10
" Color: pablo_brightyellow         #ffff00              ~          11
" Color: pablo_brightblue           #0000ff              ~          12
" Color: pablo_brightcyan           #00ffff              ~          14
" Color: pablo_brightwhite          #ffffff              ~          15
" Color: black                Black                  0        Black
" Color: blue                 Blue                  12        Blue
" Color: bluedarkblue         Blue                   4        DarkBlue
" Color: brown                Brown                130        Brown
" Color: cyan                 Cyan                  14        Cyan
" Color: cyancomment          #80a0ff               14        Cyan
" Color: cyanidentifier       #40ffff               14        Cyan
" Color: cyanlightblue        Cyan                  81        LightBlue
" Color: cyanlightcyan        Cyan                 159        LightCyan
" Color: darkblue             DarkBlue               4        DarkBlue
" Color: darkcyan             DarkCyan               6        DarkCyan
" Color: darkgreen            DarkGreen              2        DarkGreen
" Color: darkgrey             DarkGrey             242        DarkGrey
" Color: darkmagenta          DarkMagenta            5        DarkMagenta
" Color: darkred              DarkRed                1        DarkRed
" Color: green                Green                 10        Green
" Color: greenlightgreen      Green                121        LightGreen
" Color: grey                 Grey                 248        Grey
" Color: grey40               Grey40               242        DarkGrey
" Color: grey50               Grey50               242        DarkGrey
" Color: greydarkgrey         Grey                 242        DarkGrey
" Color: lightblue            LightBlue             81        LightBlue
" Color: lightbluepreproc     #ff80ff               81        LightBlue
" Color: lightblueunderlined  #80a0ff               81        LightBlue
" Color: lightcyan            LightCyan            159        LightCyan
" Color: lightgreen           LightGreen           121        LightGreen
" Color: lightgrey            LightGrey              7        LightGrey
" Color: lightgrey90          Grey90                 7        LightGrey
" Color: lightgreygrey        LightGrey            248        Grey
" Color: lightmagenta         LightMagenta         225        LightMagenta
" Color: lightred             LightRed             224        LightRed
" Color: lightseagreen        SeaGreen             121        LightGreen
" Color: lightseagreentype    #60ff60              121        LightGreen
" Color: lightyellow          LightYellow          229        LightYellow
" Color: magenta              Magenta               13        Magenta
" Color: magentaconstant      #ffa0a0               13        Magenta
" Color: magentadarkmagenta   Magenta                5        DarkMagenta
" Color: magentadarkred       Magenta                1        DarkRed
" Color: magentalightmagenta  Magenta              225        LightMagenta
" Color: orange               Orange               224        LightRed
" Color: purple               Purple                 5        DarkMagenta
" Color: red                  Red                    9        Red
" Color: reddarkred           Red                    1        DarkRed
" Color: redlightred          Red                  224        LightRed
" Color: seagreen             SeaGreen               2        DarkGreen
" Color: slateblue            SlateBlue              5        DarkMagenta
" Color: white                White                 15        White
" Color: white231             White                231        White
" Color: yellow               Yellow                11        Yellow
" Color: yellowstatement      #ffff60               11        Yellow
" Normal               pablo_brightwhite       none
" Terminal             white                   none
" Normal               pablo_brightwhite pablo_black
" Terminal             white                   black
" Comment              pablo_brightblack       none
" Constant             pablo_brightcyan        none
" Identifier           pablo_cyan              none                 t=bold
" Statement            pablo_yellow            none                 bold
" PreProc              pablo_brightgreen       none
" Type                 pablo_green             none                 g=bold
" Special              pablo_brightblue        none
" Error                none                    pablo_brightred
" Todo                 pablo_blue              pablo_yellow
" Directory            pablo_green             none
" StatusLine           pablo_brightyellow      pablo_brightblue
" Search               black                   pablo_yellow
" ColorColumn          none              darkred
" Conceal              lightgrey         darkgrey
" Cursor               black             fg
" CursorColumn         none              grey40
" CursorLineNr         yellow            none              g=bold
" DiffAdd              none              darkblue
" DiffChange           none              darkmagenta
" DiffDelete           blue              darkcyan          g=bold
" DiffText             none              red               bold
" EndOfBuffer       -> NonText
" ErrorMsg             white             reddarkred
" FoldColumn           cyan              greydarkgrey
" Folded               cyan              darkgrey
" IncSearch            none              none              reverse
" LineNr               yellow            none
" MatchParen           none              darkcyan
" ModeMsg              none              none              bold
" MoreMsg              lightseagreen     none              g=bold
" NonText              blue              none              g=bold
" PmenuSbar            none              grey
" PmenuThumb           none              white231
" Question             greenlightgreen   none              g=bold
" QuickFixLine     ->  Search
" SignColumn           cyan              greydarkgrey
" SpecialKey           cyanlightblue     none
" StatusLineNC         none              none              reverse
" TabLineFill          none              none              reverse
" TabLineSel           none              none              bold
" Title                magentalightmagenta none            g=bold
" VertSplit            none              none              reverse
" Visual               none              darkgrey
" VisualNOS            none              none              underline,bold
" WarningMsg           redlightred       none
" WildMenu             black             yellow
" Boolean           -> Constant
" Character         -> Constant
" Conditional       -> Statement
" Define            -> PreProc
" Debug             -> Special
" Delimiter         -> Special
" Exception         -> Statement
" Float             -> Number
" Function          -> Identifier
" Ignore               black             none
" Include           -> PreProc
" Keyword           -> Statement
" Label             -> Statement
" Macro             -> PreProc
" Number            -> Constant
" Operator          -> Statement
" PreCondit         -> PreProc
" Repeat            -> Statement
" SpecialChar       -> Special
" SpecialComment    -> Special
" StorageClass      -> Type
" String            -> Constant
" Structure         -> Type
" Tag               -> Special
" Typedef           -> Type
" Underlined           lightblueunderlined none            underline
" lCursor           -> Cursor
" ToolbarLine          none              grey50
" ToolbarButton        black             lightgrey         bold
