" Name:         Gruvbox Dark
" Description:  Retro groove color scheme
" Author:       morhetz <morhetz@gmail.com>
" Maintainer:   Lifepillar <lifepillar@lifepillar.me>
" Website:      https://github.com/morhetz/gruvbox/
" License:      Vim License  (see `:help license`)

if !exists('&t_Co')
" FIXME: Do something?
endif

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'gruvbox_dark'

if !has('gui_running') && get(g:, 'gruvbox_dark_transp_bg', 0)
hi Normal ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
hi Normal ctermfg=223 ctermbg=235 guifg=#ebdbb2 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
endif
hi ColorColumn ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link CursorColumn CursorLine
hi CursorLine ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi CursorLineNr ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi DiffAdd ctermfg=142 ctermbg=bg guifg=#b8bb26 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffChange ctermfg=108 ctermbg=bg guifg=#8ec07c guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffDelete ctermfg=167 ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffText ctermfg=214 ctermbg=bg guifg=#fabd2f guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Directory ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi EndOfBuffer ctermfg=235 ctermbg=NONE guifg=#282828 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=167 ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
hi ErrorMsg ctermfg=235 ctermbg=167 guifg=#282828 guibg=#fb4934 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi FoldColumn ctermfg=245 ctermbg=237 guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi Folded ctermfg=245 ctermbg=237 guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE,italic gui=NONE,italic
hi IncSearch ctermfg=208 ctermbg=bg guifg=#fe8019 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi LineNr ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi MatchParen ctermfg=NONE ctermbg=241 guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi ModeMsg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi MoreMsg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi NonText ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Pmenu ctermfg=223 ctermbg=239 guifg=#ebdbb2 guibg=#504945 guisp=NONE cterm=NONE gui=NONE
hi PmenuSbar ctermfg=NONE ctermbg=239 guifg=NONE guibg=#504945 guisp=NONE cterm=NONE gui=NONE
hi PmenuSel ctermfg=239 ctermbg=109 guifg=#504945 guibg=#83a598 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi PmenuThumb ctermfg=NONE ctermbg=243 guifg=NONE guibg=#7c6f64 guisp=NONE cterm=NONE gui=NONE
hi Question ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi! link QuickFixLine Search
hi Search ctermfg=214 ctermbg=bg guifg=#fabd2f guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi SignColumn ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi SpecialKey ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpellBad ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#83a598 cterm=NONE,underline gui=NONE,undercurl
hi SpellCap ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
hi SpellLocal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#8ec07c cterm=NONE,underline gui=NONE,undercurl
hi SpellRare ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,undercurl
hi StatusLine ctermfg=239 ctermbg=223 guifg=#504945 guibg=#ebdbb2 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi StatusLineNC ctermfg=237 ctermbg=246 guifg=#3c3836 guibg=#a89984 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link TabLine TabLineFill
hi TabLineFill ctermfg=243 ctermbg=237 guifg=#7c6f64 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi TabLineSel ctermfg=142 ctermbg=237 guifg=#b8bb26 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi Title ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi VertSplit ctermfg=241 ctermbg=235 guifg=#665c54 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
hi Visual ctermfg=NONE ctermbg=241 guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE gui=NONE
hi! link VisualNOS Visual
hi WarningMsg ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi WildMenu ctermfg=109 ctermbg=239 guifg=#83a598 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Boolean ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Character ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Comment ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi Constant ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Debug ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Delimiter ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Float ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Function ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Identifier ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Ignore ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Include ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Keyword ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Label ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Number ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Operator Normal
hi PreProc ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Special ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi SpecialChar ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpecialComment ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Statement ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StorageClass ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi String ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Structure ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Todo ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
hi Type ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Underlined ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link lCursor Cursor
hi CursorIM ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi vimCommentTitle ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi vimContinue ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimMapModKey ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link vimMapMod vimMapModKey
hi vimBracket ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimNotation ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link gitcommitComment Comment

" Color: dark0             rgb(40,  40,  40)     235         Black
" Color: dark1             rgb(60,  56,  54)     237       DarkRed
" Color: dark2             rgb(80,  73,  69)     239     DarkGreen
" Color: dark3             rgb(102, 92,  84)     241    DarkYellow
" Color: dark4             rgb(124, 111, 100)    243      DarkBlue
" Color: orange            rgb(254, 128, 25)     208   DarkMagenta
" Color: light3            rgb(189, 174, 147)    248      DarkCyan
" Color: light4            rgb(168, 153, 132)    246     LightGrey
" Color: grey              rgb(146, 131, 116)    245      DarkGrey
" Color: red               rgb(251, 73,  52)     167      LightRed
" Color: green             rgb(184, 187, 38)     142    LightGreen
" Color: yellow            rgb(250, 189, 47)     214   LightYellow
" Color: blue              rgb(131, 165, 152)    109     LightBlue
" Color: purple            rgb(211, 134, 155)    175  LightMagenta
" Color: aqua              rgb(142, 192, 124)    108     LightCyan
" Color: light1            rgb(235, 219, 178)    223         White
" Normal light1 dark0/none
" ColorColumn none dark1
" Conceal blue none
" Cursor none none inverse
" CursorColumn -> CursorLine
" CursorLine none dark1
" CursorLineNr yellow dark1
" DiffAdd green bg inverse
" DiffChange aqua bg inverse
" DiffDelete red bg inverse
" DiffText yellow bg inverse
" Directory green none bold
" EndOfBuffer dark0 none
" Error red bg bold,reverse
" ErrorMsg dark0 red bold
" FoldColumn grey dark1
" Folded grey dark1 italic
" IncSearch orange bg inverse
" LineNr dark4 none
" MatchParen none dark3 bold
" ModeMsg yellow none bold
" MoreMsg yellow none bold
" NonText dark2 none
" Pmenu light1 dark2
" PmenuSbar none dark2
" PmenuSel dark2 blue bold
" PmenuThumb none dark4
" Question orange none bold
" QuickFixLine -> Search
" Search yellow bg inverse
" SignColumn none dark1
" SpecialKey dark2 none
" SpellBad none none t=underline g=undercurl s=blue
" SpellCap none none t=underline g=undercurl s=red
" SpellLocal none none t=underline g=undercurl s=aqua
" SpellRare none none t=underline g=undercurl s=magenta
" StatusLine dark2 light1 inverse
" StatusLineNC dark1 light4 inverse
" StatusLineTerm -> StatusLine
" StatusLineTermNC -> StatusLineNC
" TabLine -> TabLineFill
" TabLineFill dark4 dark1
" TabLineSel green dark1
" Title green none bold
" VertSplit dark3 dark0
" Visual none dark3
" VisualNOS -> Visual
" WarningMsg red none bold
" WildMenu blue dark2 bold
" Boolean purple none
" Character purple none
" Comment grey none italic
" Constant purple none
" Debug red none
" Delimiter orange none
" Float purple none
" Function green none bold
" Identifier blue none
" Ignore fg none
" Include aqua none
" Keyword red none
" Label red none
" Number purple none
" Operator -> Normal
" PreProc aqua none
" Special orange none italic
" SpecialChar red none
" SpecialComment red none
" Statement red none
" StorageClass orange none
" String green none
" Structure aqua none
" Todo fg bg bold,italic
" Type yellow none
" Underlined blue none underline
" lCursor -> Cursor
" CursorIM none none inverse
" vimCommentTitle light4 none bold
" vimContinue light3 none
" vimMapModKey orange none
" vimMapMod -> vimMapModKey
" vimBracket orange none
" vimNotation orange none
" gitcommitComment -> Comment
