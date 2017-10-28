" Name:        Colorscheme template
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

if exists("b:current_syntax")
  finish
endif

syn case    ignore
syn match   colortemplateComment      "#.*$" contains=colortemplateTodo,@Spell
syn match   colortemplateKey          "^\s*\(\w[^:]*\):"
syn match   colortemplateColorSpec    "^\s*Color\s*:\s*\w\+" contains=colortemplateKey nextgroup=colortemplateColorDef
syn match   colortemplateColorDef     ".\+$" contained contains=colortemplateNumber,colortemplateHexColor,colortemplateFunction,colortemplateConstant,colortemplateCompound,colortemplateComment
syn match   colortemplateNumber       "\d\+" contained
syn match   colortemplateArrow        "->"
syn match   colortemplateHexColor     "#[a-f0-9]\{6\}" contained
syn keyword colortemplateFunction     contained rgb
syn keyword colortemplateTodo         contained TODO FIXME XXX DEBUG NOTE
" Highlight groups
syn match   colortemplateAttrs        "\<\%(te\?r\?m\?\|gu\?i\?\)=\S\+" contains=colortemplateAttr
syn match   colortemplateGuisp        "\<\%(guisp\|sp\?\)="
syn match   colortemplateHiGroup      "\<Conceal\>"
syn keyword colortemplateHiGroup      Boolean Character ColorColumn Comment Conditional Constant Cursor CursorColumn CursorIM
syn keyword colortemplateHiGroup      CursorLine CursorLineNr Define Debug Delimiter DiffAdd DiffChange DiffDelete DiffText Directory
syn keyword colortemplateHiGroup      EndOfBuffer Error ErrorMsg Exception Float FoldColumn Folded Function Identifier Ignore
syn keyword colortemplateHiGroup      IncSearch Include Keyword Label LineNr Macro MatchParen ModeMsg MoreMsg NonText
syn keyword colortemplateHiGroup      Normal Number Operator Pmenu PmenuSbar PmenuSel PmenuThumb PreCondit PreProc Question
syn keyword colortemplateHiGroup      QuickFixLine Repeat Search SignColumn Special SpecialChar SpecialComment SpecialKey SpellBad SpellCap
syn keyword colortemplateHiGroup      SpellLocal SpellRare Statement StatusLine StatusLineNC StatusLineTerm StatusLineTermNC StorageClass String
syn keyword colortemplateHiGroup      Structure TabLine TabLineFill TabLineSel Tag Title Todo Type Typedef Underlined VertSplit
syn keyword colortemplateHiGroup      Visual VisualNOS WarningMsg WildMenu lCursor
syn keyword colortemplateHiGroup      vimAuSyntax vimAugroup vimAutoCmdSfxList vimAutoCmdSpace vimAutoEventList vimBracket vimClusterName vimCmdSep
syn keyword colortemplateHiGroup      vimCollClass vimCollection vimCommentTitle vimCommentTitleLeader vimEcho vimEscapeBrace vimExecute vimExtCmd
syn keyword colortemplateHiGroup      vimFiletype vimFilter vimFuncBlank vimFuncBody vimFunction vimGlobal vimGroupList vimHiBang
syn keyword colortemplateHiGroup      vimHiCtermColor vimHiFontname vimHiGuiFontname vimHiKeyList vimHiLink vimHiTermcap vimIf vimIsCommand
syn keyword colortemplateHiGroup      vimIskList vimMapLhs vimMapMod vimMapModKey vimMapRhs vimMapRhsExtend vimMenuBang vimMenuMap
syn keyword colortemplateHiGroup      vimMenuPriority vimMenuRhs vimNormCmds vimNotation vimOperParen vimPatRegion vimRegion vimSet
syn keyword colortemplateHiGroup      vimSetEqual vimStdPlugin vimSubstPat vimSubstRange vimSubstRep vimSubstRep4 vimSynKeyRegion vimSynLine
syn keyword colortemplateHiGroup      vimSynMatchRegion vimSynMtchCchar vimSynMtchGroup vimSynPatMod vimSynRegion vimSyncLinebreak vimSyncLinecont vimSyncLines
syn keyword colortemplateHiGroup      vimSyncMatch vimSyncRegion vimUserCmd vimUserFunc
syn keyword colortemplateAttr         bold underline undercurl strikethrough reverse inverse italic standout nocombine NONE
syn keyword colortemplateSpecial      fg bg none
" Basic color names
syn keyword colortemplateConstant     contained Black Blue Brown Cyan DarkRed DarkGreen DarkYellow DarkBlue DarkMagenta DarkCyan Green LightGray LightGreySj
syn keyword colortemplateConstant     contained DarkGray DarkGrey Gray Grey LightRed LightGreen LightYellow LightBlue LightMagenta LightCyan Magenta Red Yellow White
" Color names from $VIMRUNTIME/rgb.txt
syn keyword colortemplateConstant     contained AliceBlue AntiqueWhite AntiqueWhite1 AntiqueWhite2 AntiqueWhite3 AntiqueWhite4 BlanchedAlmond BlueViolet
syn keyword colortemplateConstant     contained CadetBlue CadetBlue1 CadetBlue2 CadetBlue3 CadetBlue4 CornflowerBlue DarkBlue DarkCyan
syn keyword colortemplateConstant     contained DarkGoldenrod DarkGoldenrod1 DarkGoldenrod2 DarkGoldenrod3 DarkGoldenrod4 DarkGray DarkGreen DarkGrey
syn keyword colortemplateConstant     contained DarkKhaki DarkMagenta DarkOliveGreen DarkOliveGreen1 DarkOliveGreen2 DarkOliveGreen3 DarkOliveGreen4 DarkOrange
syn keyword colortemplateConstant     contained DarkOrange1 DarkOrange2 DarkOrange3 DarkOrange4 DarkOrchid DarkOrchid1 DarkOrchid2 DarkOrchid3
syn keyword colortemplateConstant     contained DarkOrchid4 DarkRed DarkSalmon DarkSeaGreen DarkSeaGreen1 DarkSeaGreen2 DarkSeaGreen3 DarkSeaGreen4
syn keyword colortemplateConstant     contained DarkSlateBlue DarkSlateGray DarkSlateGray1 DarkSlateGray2 DarkSlateGray3 DarkSlateGray4 DarkSlateGrey DarkTurquoise
syn keyword colortemplateConstant     contained DarkViolet DeepPink DeepPink1 DeepPink2 DeepPink3 DeepPink4 DeepSkyBlue DeepSkyBlue1
syn keyword colortemplateConstant     contained DeepSkyBlue2 DeepSkyBlue3 DeepSkyBlue4 DimGray DimGrey DodgerBlue DodgerBlue1 DodgerBlue2
syn keyword colortemplateConstant     contained DodgerBlue3 DodgerBlue4 FloralWhite ForestGreen GhostWhite GreenYellow HotPink HotPink1
syn keyword colortemplateConstant     contained HotPink2 HotPink3 HotPink4 IndianRed IndianRed1 IndianRed2 IndianRed3 IndianRed4
syn keyword colortemplateConstant     contained LavenderBlush LavenderBlush1 LavenderBlush2 LavenderBlush3 LavenderBlush4 LawnGreen LemonChiffon LemonChiffon1
syn keyword colortemplateConstant     contained LemonChiffon2 LemonChiffon3 LemonChiffon4 LightBlue LightBlue1 LightBlue2 LightBlue3 LightBlue4
syn keyword colortemplateConstant     contained LightCoral LightCyan LightCyan1 LightCyan2 LightCyan3 LightCyan4 LightGoldenrod LightGoldenrod1
syn keyword colortemplateConstant     contained LightGoldenrod2 LightGoldenrod3 LightGoldenrod4 LightGoldenrodYellow LightGray LightGreen LightGrey LightPink
syn keyword colortemplateConstant     contained LightPink1 LightPink2 LightPink3 LightPink4 LightSalmon LightSalmon1 LightSalmon2 LightSalmon3
syn keyword colortemplateConstant     contained LightSalmon4 LightSeaGreen LightSkyBlue LightSkyBlue1 LightSkyBlue2 LightSkyBlue3 LightSkyBlue4 LightSlateBlue
syn keyword colortemplateConstant     contained LightSlateGray LightSlateGrey LightSteelBlue LightSteelBlue1 LightSteelBlue2 LightSteelBlue3 LightSteelBlue4 LightYellow
syn keyword colortemplateConstant     contained LightYellow1 LightYellow2 LightYellow3 LightYellow4 LimeGreen MediumAquamarine MediumBlue MediumOrchid
syn keyword colortemplateConstant     contained MediumOrchid1 MediumOrchid2 MediumOrchid3 MediumOrchid4 MediumPurple MediumPurple1 MediumPurple2 MediumPurple3
syn keyword colortemplateConstant     contained MediumPurple4 MediumSeaGreen MediumSlateBlue MediumSpringGreen MediumTurquoise MediumVioletRed MidnightBlue MintCream
syn keyword colortemplateConstant     contained MistyRose MistyRose1 MistyRose2 MistyRose3 MistyRose4 NavajoWhite NavajoWhite1 NavajoWhite2
syn keyword colortemplateConstant     contained NavajoWhite3 NavajoWhite4 NavyBlue OldLace OliveDrab OliveDrab1 OliveDrab2 OliveDrab3
syn keyword colortemplateConstant     contained OliveDrab4 OrangeRed OrangeRed1 OrangeRed2 OrangeRed3 OrangeRed4 PaleGoldenrod PaleGreen
syn keyword colortemplateConstant     contained PaleGreen1 PaleGreen2 PaleGreen3 PaleGreen4 PaleTurquoise PaleTurquoise1 PaleTurquoise2 PaleTurquoise3
syn keyword colortemplateConstant     contained PaleTurquoise4 PaleVioletRed PaleVioletRed1 PaleVioletRed2 PaleVioletRed3 PaleVioletRed4 PapayaWhip PeachPuff
syn keyword colortemplateConstant     contained PeachPuff1 PeachPuff2 PeachPuff3 PeachPuff4 PowderBlue RebeccaPurple RosyBrown RosyBrown1
syn keyword colortemplateConstant     contained RosyBrown2 RosyBrown3 RosyBrown4 RoyalBlue RoyalBlue1 RoyalBlue2 RoyalBlue3 RoyalBlue4
syn keyword colortemplateConstant     contained SaddleBrown SandyBrown SeaGreen SeaGreen1 SeaGreen2 SeaGreen3 SeaGreen4 SkyBlue
syn keyword colortemplateConstant     contained SkyBlue1 SkyBlue2 SkyBlue3 SkyBlue4 SlateBlue SlateBlue1 SlateBlue2 SlateBlue3
syn keyword colortemplateConstant     contained SlateBlue4 SlateGray SlateGray1 SlateGray2 SlateGray3 SlateGray4 SlateGrey SpringGreen
syn keyword colortemplateConstant     contained SpringGreen1 SpringGreen2 SpringGreen3 SpringGreen4 SteelBlue SteelBlue1 SteelBlue2 SteelBlue3
syn keyword colortemplateConstant     contained SteelBlue4 VioletRed VioletRed1 VioletRed2 VioletRed3 VioletRed4 WebGray WebGreen
syn keyword colortemplateConstant     contained WebGrey WebMaroon WebPurple WhiteSmoke X11Gray X11Green X11Grey X11Maroon
syn keyword colortemplateConstant     contained X11Purple YellowGreen aqua aquamarine aquamarine1 aquamarine2 aquamarine3 aquamarine4
syn keyword colortemplateConstant     contained azure azure1 azure2 azure3 azure4 beige bisque bisque1
syn keyword colortemplateConstant     contained bisque2 bisque3 bisque4 black blue blue1 blue2 blue3
syn keyword colortemplateConstant     contained blue4 brown brown1 brown2 brown3 brown4 burlywood burlywood1
syn keyword colortemplateConstant     contained burlywood2 burlywood3 burlywood4 chartreuse chartreuse1 chartreuse2 chartreuse3 chartreuse4
syn keyword colortemplateConstant     contained chocolate chocolate1 chocolate2 chocolate3 chocolate4 coral coral1 coral2
syn keyword colortemplateConstant     contained coral3 coral4 cornsilk cornsilk1 cornsilk2 cornsilk3 cornsilk4 crimson
syn keyword colortemplateConstant     contained cyan cyan1 cyan2 cyan3 cyan4 firebrick firebrick1 firebrick2
syn keyword colortemplateConstant     contained firebrick3 firebrick4 fuchsia gainsboro gold gold1 gold2 gold3
syn keyword colortemplateConstant     contained gold4 goldenrod goldenrod1 goldenrod2 goldenrod3 goldenrod4 gray gray0
syn keyword colortemplateConstant     contained gray1 gray10 gray100 gray11 gray12 gray13 gray14 gray15
syn keyword colortemplateConstant     contained gray16 gray17 gray18 gray19 gray2 gray20 gray21 gray22
syn keyword colortemplateConstant     contained gray23 gray24 gray25 gray26 gray27 gray28 gray29 gray3
syn keyword colortemplateConstant     contained gray30 gray31 gray32 gray33 gray34 gray35 gray36 gray37
syn keyword colortemplateConstant     contained gray38 gray39 gray4 gray40 gray41 gray42 gray43 gray44
syn keyword colortemplateConstant     contained gray45 gray46 gray47 gray48 gray49 gray5 gray50 gray51
syn keyword colortemplateConstant     contained gray52 gray53 gray54 gray55 gray56 gray57 gray58 gray59
syn keyword colortemplateConstant     contained gray6 gray60 gray61 gray62 gray63 gray64 gray65 gray66
syn keyword colortemplateConstant     contained gray67 gray68 gray69 gray7 gray70 gray71 gray72 gray73
syn keyword colortemplateConstant     contained gray74 gray75 gray76 gray77 gray78 gray79 gray8 gray80
syn keyword colortemplateConstant     contained gray81 gray82 gray83 gray84 gray85 gray86 gray87 gray88
syn keyword colortemplateConstant     contained gray89 gray9 gray90 gray91 gray92 gray93 gray94 gray95
syn keyword colortemplateConstant     contained gray96 gray97 gray98 gray99 green green1 green2 green3
syn keyword colortemplateConstant     contained green4 grey grey0 grey1 grey10 grey100 grey11 grey12
syn keyword colortemplateConstant     contained grey13 grey14 grey15 grey16 grey17 grey18 grey19 grey2
syn keyword colortemplateConstant     contained grey20 grey21 grey22 grey23 grey24 grey25 grey26 grey27
syn keyword colortemplateConstant     contained grey28 grey29 grey3 grey30 grey31 grey32 grey33 grey34
syn keyword colortemplateConstant     contained grey35 grey36 grey37 grey38 grey39 grey4 grey40 grey41
syn keyword colortemplateConstant     contained grey42 grey43 grey44 grey45 grey46 grey47 grey48 grey49
syn keyword colortemplateConstant     contained grey5 grey50 grey51 grey52 grey53 grey54 grey55 grey56
syn keyword colortemplateConstant     contained grey57 grey58 grey59 grey6 grey60 grey61 grey62 grey63
syn keyword colortemplateConstant     contained grey64 grey65 grey66 grey67 grey68 grey69 grey7 grey70
syn keyword colortemplateConstant     contained grey71 grey72 grey73 grey74 grey75 grey76 grey77 grey78
syn keyword colortemplateConstant     contained grey79 grey8 grey80 grey81 grey82 grey83 grey84 grey85
syn keyword colortemplateConstant     contained grey86 grey87 grey88 grey89 grey9 grey90 grey91 grey92
syn keyword colortemplateConstant     contained grey93 grey94 grey95 grey96 grey97 grey98 grey99 honeydew
syn keyword colortemplateConstant     contained honeydew1 honeydew2 honeydew3 honeydew4 indigo ivory ivory1 ivory2
syn keyword colortemplateConstant     contained ivory3 ivory4 khaki khaki1 khaki2 khaki3 khaki4 lavender
syn keyword colortemplateConstant     contained lime linen magenta magenta1 magenta2 magenta3 magenta4 maroon
syn keyword colortemplateConstant     contained maroon1 maroon2 maroon3 maroon4 moccasin navy olive orange
syn keyword colortemplateConstant     contained orange1 orange2 orange3 orange4 orchid orchid1 orchid2 orchid3
syn keyword colortemplateConstant     contained orchid4 peru pink pink1 pink2 pink3 pink4 plum
syn keyword colortemplateConstant     contained plum1 plum2 plum3 plum4 purple purple1 purple2 purple3
syn keyword colortemplateConstant     contained purple4 red red1 red2 red3 red4 salmon salmon1
syn keyword colortemplateConstant     contained salmon2 salmon3 salmon4 seashell seashell1 seashell2 seashell3 seashell4
syn keyword colortemplateConstant     contained sienna sienna1 sienna2 sienna3 sienna4 silver snow snow1
syn keyword colortemplateConstant     contained snow2 snow3 snow4 tan tan1 tan2 tan3 tan4
syn keyword colortemplateConstant     contained teal thistle thistle1 thistle2 thistle3 thistle4 tomato tomato1
syn keyword colortemplateConstant     contained tomato2 tomato3 tomato4 turquoise turquoise1 turquoise2 turquoise3 turquoise4
syn keyword colortemplateConstant     contained violet wheat wheat1 wheat2 wheat3 wheat4 white yellow
syn keyword colortemplateConstant     contained yellow1 yellow2 yellow3 yellow4
syn match   colortemplateCompound     contained "'.\+'" contains=colortemplateCompoundName
syn match   colortemplateCompoundName contained "alice blue\|antique white\|blanched almond\|blue violet\|cadet blue\|cornflower blue"
syn match   colortemplateCompoundName contained "dark \(blue\|cyan\|goldenrod\|gray\|green\|grey\|khaki\|magenta\|olive green\|orange\)"
syn match   colortemplateCompoundName contained "dark \(orchid\|red\|salmon\|sea green\|slate blue\|slate gray\|slate grey\|turquoise\|violet\)"
syn match   colortemplateCompoundName contained "deep \(pink\|sky blue\)"
syn match   colortemplateCompoundName contained "dim \(gray\|grey\)"
syn match   colortemplateCompoundName contained "dodger blue\|floral white\|forest green\|ghost white\|green yellow\|hot pink"
syn match   colortemplateCompoundName contained "indian red\|lavender blush\|lawn green\|lemon chiffon"
syn match   colortemplateCompoundName contained "light \(blue\|coral\|cyan\|goldenrod yellow\|goldenrod\|gray\|green\|grey\|pink\|salmon\)"
syn match   colortemplateCompoundName contained "light \(sea green\|sky blue\|slate blue\|slate gray\|slate grey\|steel blue\|yellow\)"
syn match   colortemplateCompoundName contained "lime green"
syn match   colortemplateCompoundName contained "medium \(aquamarine\|blue\|orchid\|purple\|sea green\|slate blue\|spring green\|turquoise\|violet red\)"
syn match   colortemplateCompoundName contained "midnight blue\|mint cream\|misty rose\|navajo white\|navy blue\|old lace\|olive drab"
syn match   colortemplateCompoundName contained "orange red\|pale goldenrod\|pale green\|pale turquoise\|pale violet red\|papaya whip"
syn match   colortemplateCompoundName contained "peach puff\|powder blue\|rebecca purple\|rosy brown\|royal blue\|saddle brown\|sandy brown"
syn match   colortemplateCompoundName contained "sea green\|sky blue\|slate blue\|slate gray\|slate grey\|spring green\|steel blue\|violet red"
syn match   colortemplateCompoundName contained "web \(gray\|green\|grey\|maroon\|purple\)"
syn match   colortemplateCompoundName contained "white smoke"
syn match   colortemplateCompoundName contained "x11 \(gray\|green\|grey\|maroon\|purple\)"
syn match   colortemplateCompoundName contained "yellow green"

syn include @colortemplatevim syntax/vim.vim
unlet b:current_syntax
syn region colortemplatevim matchgroup=colortemplateKeyword start=/verbatim/ end=/endverbatim/ keepend contains=@colortemplatevim

syn include @colortemplatehelp syntax/help.vim
unlet b:current_syntax
syn region colortemplatehelp matchgroup=colortemplateKeyword start=/documentation/ end=/enddocumentation/ keepend contains=@colortemplatehelp

hi def link colortemplateArrow        Delimiter
hi def link colortemplateAttr         Label
hi def link colortemplateAttrs        String
hi def link colortemplateCompoundName Type
hi def link colortemplateConstant     Type
hi def link colortemplateComment      Comment
hi def link colortemplateFunction     Function
hi def link colortemplateGuisp        String
hi def link colortemplateHexColor     Constant
hi def link colortemplateHiGroup      Identifier
hi def link colortemplateNumber       Number
hi def link colortemplateKey          Special
hi def link colortemplateKeyword      Keyword
hi def link colortemplateSpecial      Boolean
hi def link colortemplateTodo         PreProc

let b:current_syntax = "colortemplate"
