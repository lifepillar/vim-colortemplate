" Name:         Default Clone
" Description:  A nearly exact clone of Vim's default colorscheme
" Author:       Bram Moolenaar <Bram@vim.org>
" Maintainer:   Lifepillar <lifepillar@lifepillar.me>
" Website:      https://github.com/vim/vim/blob/master/src/syntax.c
" License:      Vim License (see `:help license`)
" Last Updated: Tue Oct  3 18:23:30 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < 256)
  echohl Error
  echomsg '[Default Clone] There are not enough colors.'
  echohl None
  finish
endif

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'default_clone'

if &background ==# 'dark'
if !has('gui_running') && get(g:, 'default_clone_transp_bg', 0)
hi Normal ctermfg=15 ctermbg=NONE guifg=#ffffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
hi Normal ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#000000 guisp=NONE cterm=NONE gui=NONE
endif
hi ColorColumn ctermfg=NONE ctermbg=1 guifg=NONE guibg=#8b0000 guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=7 ctermbg=242 guifg=#d3d3d3 guibg=#a9a9a9 guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#000000 guisp=NONE cterm=NONE gui=NONE
hi CursorColumn ctermfg=NONE ctermbg=242 guifg=NONE guibg=#666666 guisp=NONE cterm=NONE gui=NONE
hi CursorLine cterm=underline guibg=#666666
hi CursorLineNr ctermfg=11 ctermbg=NONE guifg=#ffff00 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi DiffAdd ctermfg=NONE ctermbg=4 guifg=NONE guibg=#00008b guisp=NONE cterm=NONE gui=NONE
hi DiffChange ctermfg=NONE ctermbg=5 guifg=NONE guibg=#8b008b guisp=NONE cterm=NONE gui=NONE
hi DiffDelete ctermfg=12 ctermbg=6 guifg=#0000ff guibg=#008b8b guisp=NONE cterm=NONE gui=NONE,bold
hi DiffText ctermfg=NONE ctermbg=9 guifg=NONE guibg=#ff0000 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Directory ctermfg=159 ctermbg=NONE guifg=#00ffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link EndOfBuffer NonText
hi ErrorMsg ctermfg=15 ctermbg=1 guifg=#ffffff guibg=#ff0000 guisp=NONE cterm=NONE gui=NONE
hi FoldColumn ctermfg=14 ctermbg=242 guifg=#00ffff guibg=#bebebe guisp=NONE cterm=NONE gui=NONE
hi Folded ctermfg=14 ctermbg=242 guifg=#00ffff guibg=#a9a9a9 guisp=NONE cterm=NONE gui=NONE
hi IncSearch ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi LineNr ctermfg=11 ctermbg=NONE guifg=#ffff00 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi MatchParen ctermfg=NONE ctermbg=6 guifg=NONE guibg=#008b8b guisp=NONE cterm=NONE gui=NONE
hi ModeMsg ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi MoreMsg ctermfg=121 ctermbg=NONE guifg=#2e8b57 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi NonText ctermfg=12 ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi Pmenu ctermbg=13 ctermfg=0 guibg=#ff00ff
hi PmenuSbar ctermfg=NONE ctermbg=248 guifg=NONE guibg=#bebebe guisp=NONE cterm=NONE gui=NONE
hi PmenuSel ctermbg=0 ctermfg=242 guibg=#a9a9a9
hi PmenuThumb ctermfg=NONE ctermbg=15 guifg=NONE guibg=#ffffff guisp=NONE cterm=NONE gui=NONE
hi Question ctermfg=121 ctermbg=NONE guifg=#00ff00 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link QuickFixLine Search
hi Search ctermfg=0 ctermbg=11 guifg=#000000 guibg=#ffff00 guisp=NONE cterm=NONE gui=NONE
hi SignColumn ctermfg=14 ctermbg=242 guifg=#00ffff guibg=#bebebe guisp=NONE cterm=NONE gui=NONE
hi SpecialKey ctermfg=81 ctermbg=NONE guifg=#00ffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpellBad ctermbg=9 guisp=#ff0000 gui=undercurl
hi SpellCap ctermbg=12 guisp=#0000ff gui=undercurl
hi SpellLocal ctermbg=14 guisp=#00ffff gui=undercurl
hi SpellRare ctermbg=13 guisp=#ff00ff gui=undercurl
hi StatusLine ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse,bold gui=NONE,reverse,bold
hi StatusLineNC ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi StatusLineTerm ctermfg=0 ctermbg=121 guifg=#000000 guibg=#90ee90 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi StatusLineTermNC ctermfg=0 ctermbg=121 guifg=#000000 guibg=#90ee90 guisp=NONE cterm=NONE gui=NONE
hi TabLine cterm=underline ctermfg=15 ctermbg=242 gui=underline guibg=#a9a9a9
hi TabLineFill ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi TabLineSel ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Title ctermfg=225 ctermbg=NONE guifg=#ff00ff guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi VertSplit ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi Visual ctermfg=NONE ctermbg=242 guifg=NONE guibg=#a9a9a9 guisp=NONE cterm=NONE gui=NONE
hi VisualNOS ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,underline,bold gui=NONE,underline,bold
hi WarningMsg ctermfg=224 ctermbg=NONE guifg=#ff0000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi WildMenu ctermfg=0 ctermbg=11 guifg=#000000 guibg=#ffff00 guisp=NONE cterm=NONE gui=NONE
hi! link Boolean Constant
hi! link Character Constant
hi Comment ctermfg=14 ctermbg=NONE guifg=#80a0ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Conditional Statement
hi Constant ctermfg=13 ctermbg=NONE guifg=#ffa0a0 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Define PreProc
hi! link Debug Special
hi! link Delimiter Special
hi Error ctermfg=15 ctermbg=9 guifg=#ffffff guibg=#ff0000 guisp=NONE cterm=NONE gui=NONE
hi! link Exception Statement
hi! link Float Constant
hi! link Function Identifier
hi Identifier ctermfg=14 ctermbg=NONE guifg=#40ffff guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE
hi Ignore ctermfg=0 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link Macro PreProc
hi! link Number Constant
hi! link Operator Statement
hi! link PreCondit PreProc
hi PreProc ctermfg=81 ctermbg=NONE guifg=#ff80ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Repeat Statement
hi Special ctermfg=224 ctermbg=NONE guifg=#ffa500 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link SpecialChar Special
hi! link SpecialComment Special
hi Statement ctermfg=11 ctermbg=NONE guifg=#ffff60 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi! link Tag Special
hi Todo ctermfg=0 ctermbg=11 guifg=#0000ff guibg=#ffff00
hi Type ctermfg=121 ctermbg=NONE guifg=#60ff60 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link Typedef Type
hi Underlined ctermfg=81 ctermbg=NONE guifg=#80a0ff guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link lCursor Cursor
hi CursorIM ctermfg=NONE ctermbg=fg guifg=NONE guibg=fg guisp=NONE cterm=NONE gui=NONE
endif
if &background ==# 'light'
if !has('gui_running') && get(g:, 'default_clone_transp_bg', 0)
hi Normal ctermfg=15 ctermbg=NONE guifg=#ffffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
hi Normal ctermfg=0 ctermbg=15 guifg=#000000 guibg=#ffffff guisp=NONE cterm=NONE gui=NONE
endif
hi ColorColumn ctermfg=NONE ctermbg=224 guifg=NONE guibg=#ff4500 guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=7 ctermbg=242 guifg=#d3d3d3 guibg=#a9a9a9 guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#000000 guisp=NONE cterm=NONE gui=NONE
hi CursorColumn ctermfg=NONE ctermbg=7 guifg=NONE guibg=#e5e5e5 guisp=NONE cterm=NONE gui=NONE
hi CursorLine cterm=underline guibg=#e5e5e5
hi CursorLineNr ctermfg=130 ctermbg=NONE guifg=#a52a2a guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi DiffAdd ctermfg=NONE ctermbg=81 guifg=NONE guibg=#add8e6 guisp=NONE cterm=NONE gui=NONE
hi DiffChange ctermfg=NONE ctermbg=225 guifg=NONE guibg=#ffd7ff guisp=NONE cterm=NONE gui=NONE
hi DiffDelete ctermfg=12 ctermbg=159 guifg=#0000ff guibg=#e0ffff guisp=NONE cterm=NONE gui=NONE,bold
hi DiffText ctermfg=NONE ctermbg=9 guifg=NONE guibg=#ff0000 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Directory ctermfg=4 ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link EndOfBuffer NonText
hi ErrorMsg ctermfg=15 ctermbg=1 guifg=#ffffff guibg=#ff0000 guisp=NONE cterm=NONE gui=NONE
hi FoldColumn ctermfg=4 ctermbg=248 guifg=#00008b guibg=#bebebe guisp=NONE cterm=NONE gui=NONE
hi Folded ctermfg=4 ctermbg=248 guifg=#00008b guibg=#d3d3d3 guisp=NONE cterm=NONE gui=NONE
hi IncSearch ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi LineNr ctermfg=130 ctermbg=NONE guifg=#a52a2a guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi MatchParen ctermfg=NONE ctermbg=14 guifg=NONE guibg=#00ffff guisp=NONE cterm=NONE gui=NONE
hi ModeMsg ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi MoreMsg ctermfg=2 ctermbg=NONE guifg=#2e8b57 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi NonText ctermfg=12 ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi Pmenu ctermbg=225 ctermfg=0 guibg=#ffd7ff
hi PmenuSbar ctermfg=NONE ctermbg=248 guifg=NONE guibg=#bebebe guisp=NONE cterm=NONE gui=NONE
hi PmenuSel ctermbg=7 ctermfg=0 guibg=#bebebe
hi PmenuThumb ctermfg=NONE ctermbg=0 guifg=NONE guibg=#000000 guisp=NONE cterm=NONE gui=NONE
hi Question ctermfg=2 ctermbg=NONE guifg=#2e8b57 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link QuickFixLine Search
hi Search ctermfg=NONE ctermbg=11 guifg=NONE guibg=#ffff00 guisp=NONE cterm=NONE gui=NONE
hi SignColumn ctermfg=4 ctermbg=248 guifg=#00008b guibg=#bebebe guisp=NONE cterm=NONE gui=NONE
hi SpecialKey ctermfg=4 ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpellBad ctermbg=224 guisp=#ff0000 gui=undercurl
hi SpellCap ctermbg=81 guisp=#0000ff gui=undercurl
hi SpellLocal ctermbg=14 guisp=#008b8b gui=undercurl
hi SpellRare ctermbg=225 guisp=#ff00ff gui=undercurl
hi StatusLine ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse,bold gui=NONE,reverse,bold
hi StatusLineNC ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi StatusLineTerm ctermfg=15 ctermbg=2 guifg=#ffffff guibg=#006400 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi StatusLineTermNC ctermfg=15 ctermbg=2 guifg=#ffffff guibg=#006400 guisp=NONE cterm=NONE gui=NONE
hi TabLine cterm=underline ctermfg=0 ctermbg=7 gui=underline guibg=#d3d3d3
hi TabLineFill ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi TabLineSel ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Title ctermfg=5 ctermbg=NONE guifg=#ff00ff guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi VertSplit ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi Visual ctermfg=NONE ctermbg=7 guifg=NONE guibg=#d3d3d3 guisp=NONE cterm=NONE gui=NONE
hi VisualNOS ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,underline,bold gui=NONE,underline,bold
hi WarningMsg ctermfg=1 ctermbg=NONE guifg=#ff0000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi WildMenu ctermfg=0 ctermbg=11 guifg=#000000 guibg=#ffff00 guisp=NONE cterm=NONE gui=NONE
hi! link Boolean Constant
hi! link Character Constant
hi Comment ctermfg=4 ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Conditional Statement
hi Constant ctermfg=1 ctermbg=NONE guifg=#8b0000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Define PreProc
hi! link Debug Special
hi! link Delimiter Special
hi Error ctermfg=15 ctermbg=9 guifg=#ffffff guibg=#ff0000 guisp=NONE cterm=NONE gui=NONE
hi! link Exception Statement
hi! link Float Constant
hi! link Function Identifier
hi Identifier ctermfg=6 ctermbg=NONE guifg=#008b8b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Ignore ctermfg=15 ctermbg=NONE guifg=#ffffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link Macro PreProc
hi! link Number Constant
hi! link Operator Statement
hi! link PreCondit PreProc
hi PreProc ctermfg=5 ctermbg=NONE guifg=#a020f0 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Repeat Statement
hi Special ctermfg=5 ctermbg=NONE guifg=#6a5acd guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link SpecialChar Special
hi! link SpecialComment Special
hi Statement ctermfg=130 ctermbg=NONE guifg=#a52a2a guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi! link Tag Special
hi Todo ctermfg=0 ctermbg=11 guifg=#0000ff guibg=#ffff00
hi Type ctermfg=2 ctermbg=NONE guifg=#2e8b57 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link Typedef Type
hi Underlined ctermfg=5 ctermbg=NONE guifg=#6a5acd guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link lCursor Cursor
hi CursorIM ctermfg=NONE ctermbg=fg guifg=NONE guibg=fg guisp=NONE cterm=NONE gui=NONE
endif

" Color: black                rgb(  0,   0,   0)     0        Black
" Color: darkblue             rgb(  0,   0, 139)     4        DarkBlue
" Color: darkgreen            rgb(  0, 100,   0)     2        DarkGreen
" Color: seagreen             rgb( 46, 139,  87)     2        DarkGreen
" Color: darkcyan             rgb(  0, 139, 139)     6        DarkCyan
" Color: darkred              rgb(139,   0,   0)     1        DarkRed
" Color: darkmagenta          rgb(139,   0, 139)     5        DarkMagenta
" Color: purple               rgb(160,  32, 240)     5        DarkMagenta
" Color: slateblue            rgb(106,  90, 205)     5        DarkMagenta
" Color: brown                rgb(165,  42,  42)   130        Brown
" Color: darkyellow           rgb(165,  42,  42)   130        DarkYellow
" Color: grey                 rgb(190, 190, 190)   248        Grey
" Color: grey40               rgb(102, 102, 102)   242        DarkGrey
" Color: greydarkgrey         rgb(190, 190, 190)   242        DarkGrey
" Color: lightgrey            rgb(211, 211, 211)     7        LightGrey
" Color: lightgrey90          rgb(229, 229, 229)     7        LightGrey
" Color: lightgreygrey        rgb(211, 211, 211)   248        Grey
" Color: darkgrey             rgb(169, 169, 169)   242        DarkGrey
" Color: blue                 rgb(  0,   0, 255)    12        Blue
" Color: bluedarkblue         rgb(  0,   0, 255)     4        DarkBlue
" Color: lightblue            rgb(173, 216, 230)    81        LightBlue
" Color: lightbluepreproc     rgb(255, 128, 255)    81        LightBlue
" Color: lightblueunderlined  rgb(128, 160, 255)    81        LightBlue
" Color: green                rgb(  0, 255,   0)    10        Green
" Color: lightgreen           rgb(144, 238, 144)   121        LightGreen
" Color: greenlightgreen      rgb(  0, 255,   0)   121        LightGreen
" Color: lightseagreen        rgb( 46, 139,  87)   121        LightGreen
" Color: lightseagreentype    rgb( 96, 255,  96)   121        LightGreen
" Color: cyan                 rgb(  0, 255, 255)    14        Cyan
" Color: cyancomment          rgb(128, 160, 255)    14        Cyan
" Color: cyanidentifier       rgb( 64, 255, 255)    14        Cyan
" Color: cyanlightblue        rgb(  0, 255, 255)    81        LightBlue
" Color: lightcyan            rgb(224, 255, 255)   159        LightCyan
" Color: cyanlightcyan        rgb(  0, 255, 255)   159        LightCyan
" Color: red                  rgb(255,   0,   0)     9        Red
" Color: reddarkred           rgb(255,   0,   0)     1        DarkRed
" Color: redlightred          rgb(255,   0,   0)   224        LightRed
" Color: lightred             rgb(255,  69,   0)   224        LightRed
" Color: orange               rgb(255, 165,   0)   224        LightRed
" Color: magenta              rgb(255,   0, 255)    13        Magenta
" Color: magentaconstant      rgb(255, 160, 160)    13        Magenta
" Color: magentadarkmagenta   rgb(255,   0, 255)     5        DarkMagenta
" Color: magentalightmagenta  rgb(255,   0, 255)   225        LightMagenta
" Color: lightmagenta         rgb(255, 215, 255)   225        LightMagenta
" Color: yellow               rgb(255, 255,   0)    11        Yellow
" Color: yellowstatement      rgb(255, 255,  96)    11        Yellow
" Color: lightyellow          rgb(255, 255, 224)   229        LightYellow
" Color: white                rgb(255, 255, 255)    15        White
" Background: light
" Normal               black/white       white/none
" ColorColumn          none              lightred
" Conceal              lightgrey         darkgrey
" Cursor               white             black
" CursorColumn         none              lightgrey90
" verbatim
" hi CursorLine cterm=underline guibg=@lightgrey90
" endverbatim
" CursorLineNr         brown             none              g=bold
" DiffAdd              none              lightblue
" DiffChange           none              lightmagenta
" DiffDelete           blue              lightcyan         g=bold
" DiffText             none              red               bold
" Directory            bluedarkblue      none
" EndOfBuffer       -> NonText
" ErrorMsg             white             reddarkred
" FoldColumn           darkblue          grey
" Folded               darkblue          lightgreygrey
" IncSearch            none              none              reverse
" LineNr               brown             none
" MatchParen           none              cyan
" ModeMsg              none              none              bold
" MoreMsg              seagreen          none              g=bold
" NonText              blue              none              g=bold
" verbatim
" hi Pmenu ctermbg=@lightmagenta ctermfg=@black guibg=@lightmagenta
" endverbatim
" PmenuSbar            none              grey
" verbatim
" hi PmenuSel ctermbg=@lightgrey ctermfg=@black guibg=@grey
" endverbatim
" PmenuThumb           none              black
" Question             seagreen          none              g=bold
" QuickFixLine     ->  Search
" Search               none              yellow
" SignColumn           darkblue          grey
" SpecialKey           bluedarkblue      none
" verbatim
" hi SpellBad ctermbg=@lightred guisp=@red gui=undercurl
" hi SpellCap ctermbg=@lightblue guisp=@blue gui=undercurl
" hi SpellLocal ctermbg=@cyan guisp=@darkcyan gui=undercurl
" hi SpellRare ctermbg=@lightmagenta guisp=@magenta gui=undercurl
" endverbatim
" StatusLine           none              none              reverse,bold
" StatusLineNC         none              none              reverse
" StatusLineTerm       white             darkgreen         bold
" StatusLineTermNC     white             darkgreen
" verbatim
" hi TabLine cterm=underline ctermfg=@black ctermbg=@lightgrey gui=underline guibg=@lightgrey
" endverbatim
" TabLineFill          none              none              reverse
" TabLineSel           none              none              bold
" Title                magentadarkmagenta none             g=bold
" VertSplit            none              none              reverse
" Visual               none              lightgrey
" VisualNOS            none              none              underline,bold
" WarningMsg           reddarkred        none
" WildMenu             black             yellow
" Boolean           -> Constant
" Character         -> Constant
" Comment              bluedarkblue      none
" Conditional       -> Statement
" Constant             darkred           none
" Define            -> PreProc
" Debug             -> Special
" Delimiter         -> Special
" Error                white             red
" Exception         -> Statement
" Float             -> Constant
" Function          -> Identifier
" Identifier           darkcyan          none
" Ignore               white             none
" Include           -> PreProc
" Keyword           -> Statement
" Label             -> Statement
" Macro             -> PreProc
" Number            -> Constant
" Operator          -> Statement
" PreCondit         -> PreProc
" PreProc              purple            none
" Repeat            -> Statement
" Special              slateblue         none
" SpecialChar       -> Special
" SpecialComment    -> Special
" Statement            brown             none              g=bold
" StorageClass      -> Type
" String            -> Constant
" Structure         -> Type
" Tag               -> Special
" verbatim
" hi Todo ctermfg=@black ctermbg=@yellow guifg=@blue guibg=@yellow
" endverbatim
" Type                 seagreen          none              g=bold
" Typedef           -> Type
" Underlined           slateblue         none              underline
" lCursor           -> Cursor
" CursorIM             none              fg
" Background: dark
" Normal               white/white       black/none
" ColorColumn          none              darkred
" Conceal              lightgrey         darkgrey
" Cursor               white             black
" CursorColumn         none              grey40
" verbatim
" hi CursorLine cterm=underline guibg=@grey40
" endverbatim
" CursorLineNr         yellow            none              g=bold
" DiffAdd              none              darkblue
" DiffChange           none              darkmagenta
" DiffDelete           blue              darkcyan          g=bold
" DiffText             none              red               bold
" Directory            cyanlightcyan     none
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
" verbatim
" hi Pmenu ctermbg=@magenta ctermfg=@black guibg=@magenta
" endverbatim
" PmenuSbar            none              grey
" verbatim
" hi PmenuSel ctermbg=@black ctermfg=@darkgrey guibg=@darkgrey
" endverbatim
" PmenuThumb           none              white
" Question             greenlightgreen   none              g=bold
" QuickFixLine     ->  Search
" Search               black             yellow
" SignColumn           cyan              greydarkgrey
" SpecialKey           cyanlightblue     none
" verbatim
" hi SpellBad ctermbg=@red guisp=@red gui=undercurl
" hi SpellCap ctermbg=@blue guisp=@blue gui=undercurl
" hi SpellLocal ctermbg=@cyan guisp=@cyan gui=undercurl
" hi SpellRare ctermbg=@magenta guisp=@magenta gui=undercurl
" endverbatim
" StatusLine           none              none              reverse,bold
" StatusLineNC         none              none              reverse
" StatusLineTerm       black             lightgreen        bold
" StatusLineTermNC     black             lightgreen
" verbatim
" hi TabLine cterm=underline ctermfg=@white ctermbg=@darkgrey gui=underline guibg=@darkgrey
" endverbatim
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
" Comment              cyancomment       none
" Conditional       -> Statement
" Constant             magentaconstant   none
" Define            -> PreProc
" Debug             -> Special
" Delimiter         -> Special
" Error                white             red
" Exception         -> Statement
" Float             -> Constant
" Function          -> Identifier
" Identifier           cyanidentifier    none              t=bold
" Ignore               black             none
" Include           -> PreProc
" Keyword           -> Statement
" Label             -> Statement
" Macro             -> PreProc
" Number            -> Constant
" Operator          -> Statement
" PreCondit         -> PreProc
" PreProc              lightbluepreproc  none
" Repeat            -> Statement
" Special              orange            none
" SpecialChar       -> Special
" SpecialComment    -> Special
" Statement            yellowstatement   none              g=bold
" StorageClass      -> Type
" String            -> Constant
" Structure         -> Type
" Tag               -> Special
" verbatim
" hi Todo ctermfg=@black ctermbg=@yellow guifg=@blue guibg=@yellow
" endverbatim
" Type                 lightseagreentype none              g=bold
" Typedef           -> Type
" Underlined           lightblueunderlined none            underline
" lCursor           -> Cursor
" CursorIM             none              fg
