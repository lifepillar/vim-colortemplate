" Name:        Colortemplate
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

if exists("b:current_syntax")
  finish
endif

syn case    match
" Highlight groups
syn match   colortemplateAttrs        "\<\%(te\?r\?m\?\|gu\?i\?\)=\S\+" contains=colortemplateAttr,colortemplateSpecial
syn match   colortemplateGuisp        "\<\%(guisp\|sp\?\)="
syn match   colortemplateTermCode     "\<st\%(art\|op\)="
syn match   colortemplateHiGroup      "\<Conceal\>"
syn match   colortemplateHiGroup      "\<Include\>"
syn match   colortemplateHiGroup      "\<Terminal\>"
syn keyword colortemplateHiGroup      Boolean Character ColorColumn Comment Conditional Constant Cursor CursorColumn CursorIM
syn keyword colortemplateHiGroup      CursorLine CursorLineNr Define Debug Delimiter DiffAdd DiffChange DiffDelete DiffText Directory
syn keyword colortemplateHiGroup      EndOfBuffer Error ErrorMsg Exception Float FoldColumn Folded Function Identifier Ignore
syn keyword colortemplateHiGroup      IncSearch Keyword Label LineNr LineNrAbove LineNrBelow Macro MatchParen ModeMsg MoreMsg NonText
syn keyword colortemplateHiGroup      Normal Number Operator Pmenu PmenuSbar PmenuSel PmenuThumb PopupSelected PreCondit PreProc Question
syn keyword colortemplateHiGroup      QuickFixLine Repeat Search SignColumn Special SpecialChar SpecialComment SpecialKey SpellBad SpellCap
syn keyword colortemplateHiGroup      SpellLocal SpellRare Statement StatusLine StatusLineNC StatusLineTerm StatusLineTermNC StorageClass String
syn keyword colortemplateHiGroup      Structure TabLine TabLineFill TabLineSel Tag Title Todo Type Typedef Underlined VertSplit
syn keyword colortemplateHiGroup      debugPC debugBreakpoint ToolbarLine ToolbarButton
syn keyword colortemplateHiGroup      Visual VisualNOS WarningMsg WildMenu lCursor
syn keyword colortemplateHiGroup      Menu Scrollbar Tooltip User1 User2 User3 User4 User5 User6 User7 User8 User9
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
syn keyword colortemplateSpecial      fg bg none omit
syn match   colortemplateComment      "[;#].*$" contains=colortemplateTodo,@Spell
syn match   colortemplateKey          "^\s*\(\w[^:]*\):"
syn match   colortemplateColorSpec    "^\s*Color\s*:\s*\w\+" contains=colortemplateKey nextgroup=colortemplateColorDef
syn match   colortemplateColorDef     ".\+$" contained contains=colortemplateNumber,colortemplateHexColor,colortemplateFunction,colortemplateConstant,colortemplateCompound,colortemplateComment
syn match   colortemplateNumber       "\<\d\+\>" contained
syn match   colortemplateArrow        "->"
syn match   colortemplateHexColor     "#[A-Fa-f0-9]\{6\}" contained
syn keyword colortemplateFunction     contained rgb
syn keyword colortemplateTodo         contained TODO FIXME XXX DEBUG NOTE
" Basic color names
syn keyword colortemplateConstant     contained Black Blue Brown Cyan DarkRed DarkGreen DarkYellow DarkBlue DarkMagenta DarkCyan Green LightGray LightGrey
syn keyword colortemplateConstant     contained DarkGray DarkGrey Gray Grey LightRed LightGreen LightYellow LightBlue LightMagenta LightCyan Magenta Red Yellow White
" Color names from $VIMRUNTIME/rgb.txt
syn keyword colortemplateConstant     contained alice AliceBlue almond antique AntiqueWhite AntiqueWhite1 AntiqueWhite2 AntiqueWhite3
syn keyword colortemplateConstant     contained AntiqueWhite4 aqua aquamarine aquamarine1 aquamarine2 aquamarine3 aquamarine4 azure
syn keyword colortemplateConstant     contained azure1 azure2 azure3 azure4 beige bisque bisque1 bisque2
syn keyword colortemplateConstant     contained bisque3 bisque4 black blanched BlanchedAlmond blue blue1 blue2
syn keyword colortemplateConstant     contained blue3 blue4 BlueViolet blush brown brown1 brown2 brown3
syn keyword colortemplateConstant     contained brown4 burlywood burlywood1 burlywood2 burlywood3 burlywood4 cadet CadetBlue
syn keyword colortemplateConstant     contained CadetBlue1 CadetBlue2 CadetBlue3 CadetBlue4 chartreuse chartreuse1 chartreuse2 chartreuse3
syn keyword colortemplateConstant     contained chartreuse4 chiffon chocolate chocolate1 chocolate2 chocolate3 chocolate4 coral
syn keyword colortemplateConstant     contained coral1 coral2 coral3 coral4 cornflower CornflowerBlue cornsilk cornsilk1
syn keyword colortemplateConstant     contained cornsilk2 cornsilk3 cornsilk4 cream crimson cyan cyan1 cyan2
syn keyword colortemplateConstant     contained cyan3 cyan4 dark DarkBlue DarkCyan DarkGoldenrod DarkGoldenrod1 DarkGoldenrod2
syn keyword colortemplateConstant     contained DarkGoldenrod3 DarkGoldenrod4 DarkGray DarkGreen DarkGrey DarkKhaki DarkMagenta DarkOliveGreen
syn keyword colortemplateConstant     contained DarkOliveGreen1 DarkOliveGreen2 DarkOliveGreen3 DarkOliveGreen4 DarkOrange DarkOrange1 DarkOrange2 DarkOrange3
syn keyword colortemplateConstant     contained DarkOrange4 DarkOrchid DarkOrchid1 DarkOrchid2 DarkOrchid3 DarkOrchid4 DarkRed DarkSalmon
syn keyword colortemplateConstant     contained DarkSeaGreen DarkSeaGreen1 DarkSeaGreen2 DarkSeaGreen3 DarkSeaGreen4 DarkSlateBlue DarkSlateGray DarkSlateGray1
syn keyword colortemplateConstant     contained DarkSlateGray2 DarkSlateGray3 DarkSlateGray4 DarkSlateGrey DarkTurquoise DarkViolet deep DeepPink
syn keyword colortemplateConstant     contained DeepPink1 DeepPink2 DeepPink3 DeepPink4 DeepSkyBlue DeepSkyBlue1 DeepSkyBlue2 DeepSkyBlue3
syn keyword colortemplateConstant     contained DeepSkyBlue4 dim DimGray DimGrey dodger DodgerBlue DodgerBlue1 DodgerBlue2
syn keyword colortemplateConstant     contained DodgerBlue3 DodgerBlue4 drab firebrick firebrick1 firebrick2 firebrick3 firebrick4
syn keyword colortemplateConstant     contained floral FloralWhite forest ForestGreen fuchsia gainsboro ghost GhostWhite
syn keyword colortemplateConstant     contained gold gold1 gold2 gold3 gold4 goldenrod goldenrod1 goldenrod2
syn keyword colortemplateConstant     contained goldenrod3 goldenrod4 gray gray0 gray1 gray10 gray100 gray11
syn keyword colortemplateConstant     contained gray12 gray13 gray14 gray15 gray16 gray17 gray18 gray19
syn keyword colortemplateConstant     contained gray2 gray20 gray21 gray22 gray23 gray24 gray25 gray26
syn keyword colortemplateConstant     contained gray27 gray28 gray29 gray3 gray30 gray31 gray32 gray33
syn keyword colortemplateConstant     contained gray34 gray35 gray36 gray37 gray38 gray39 gray4 gray40
syn keyword colortemplateConstant     contained gray41 gray42 gray43 gray44 gray45 gray46 gray47 gray48
syn keyword colortemplateConstant     contained gray49 gray5 gray50 gray51 gray52 gray53 gray54 gray55
syn keyword colortemplateConstant     contained gray56 gray57 gray58 gray59 gray6 gray60 gray61 gray62
syn keyword colortemplateConstant     contained gray63 gray64 gray65 gray66 gray67 gray68 gray69 gray7
syn keyword colortemplateConstant     contained gray70 gray71 gray72 gray73 gray74 gray75 gray76 gray77
syn keyword colortemplateConstant     contained gray78 gray79 gray8 gray80 gray81 gray82 gray83 gray84
syn keyword colortemplateConstant     contained gray85 gray86 gray87 gray88 gray89 gray9 gray90 gray91
syn keyword colortemplateConstant     contained gray92 gray93 gray94 gray95 gray96 gray97 gray98 gray99
syn keyword colortemplateConstant     contained green green1 green2 green3 green4 GreenYellow grey grey0
syn keyword colortemplateConstant     contained grey1 grey10 grey100 grey11 grey12 grey13 grey14 grey15
syn keyword colortemplateConstant     contained grey16 grey17 grey18 grey19 grey2 grey20 grey21 grey22
syn keyword colortemplateConstant     contained grey23 grey24 grey25 grey26 grey27 grey28 grey29 grey3
syn keyword colortemplateConstant     contained grey30 grey31 grey32 grey33 grey34 grey35 grey36 grey37
syn keyword colortemplateConstant     contained grey38 grey39 grey4 grey40 grey41 grey42 grey43 grey44
syn keyword colortemplateConstant     contained grey45 grey46 grey47 grey48 grey49 grey5 grey50 grey51
syn keyword colortemplateConstant     contained grey52 grey53 grey54 grey55 grey56 grey57 grey58 grey59
syn keyword colortemplateConstant     contained grey6 grey60 grey61 grey62 grey63 grey64 grey65 grey66
syn keyword colortemplateConstant     contained grey67 grey68 grey69 grey7 grey70 grey71 grey72 grey73
syn keyword colortemplateConstant     contained grey74 grey75 grey76 grey77 grey78 grey79 grey8 grey80
syn keyword colortemplateConstant     contained grey81 grey82 grey83 grey84 grey85 grey86 grey87 grey88
syn keyword colortemplateConstant     contained grey89 grey9 grey90 grey91 grey92 grey93 grey94 grey95
syn keyword colortemplateConstant     contained grey96 grey97 grey98 grey99 honeydew honeydew1 honeydew2 honeydew3
syn keyword colortemplateConstant     contained honeydew4 hot HotPink HotPink1 HotPink2 HotPink3 HotPink4 indian
syn keyword colortemplateConstant     contained IndianRed IndianRed1 IndianRed2 IndianRed3 IndianRed4 indigo ivory ivory1
syn keyword colortemplateConstant     contained ivory2 ivory3 ivory4 khaki khaki1 khaki2 khaki3 khaki4
syn keyword colortemplateConstant     contained lace lavender LavenderBlush LavenderBlush1 LavenderBlush2 LavenderBlush3 LavenderBlush4 lawn
syn keyword colortemplateConstant     contained LawnGreen lemon LemonChiffon LemonChiffon1 LemonChiffon2 LemonChiffon3 LemonChiffon4 light
syn keyword colortemplateConstant     contained LightBlue LightBlue1 LightBlue2 LightBlue3 LightBlue4 LightCoral LightCyan LightCyan1
syn keyword colortemplateConstant     contained LightCyan2 LightCyan3 LightCyan4 LightGoldenrod LightGoldenrod1 LightGoldenrod2 LightGoldenrod3 LightGoldenrod4
syn keyword colortemplateConstant     contained LightGoldenrodYellow LightGray LightGreen LightGrey LightPink LightPink1 LightPink2 LightPink3
syn keyword colortemplateConstant     contained LightPink4 LightSalmon LightSalmon1 LightSalmon2 LightSalmon3 LightSalmon4 LightSeaGreen LightSkyBlue
syn keyword colortemplateConstant     contained LightSkyBlue1 LightSkyBlue2 LightSkyBlue3 LightSkyBlue4 LightSlateBlue LightSlateGray LightSlateGrey LightSteelBlue
syn keyword colortemplateConstant     contained LightSteelBlue1 LightSteelBlue2 LightSteelBlue3 LightSteelBlue4 LightYellow LightYellow1 LightYellow2 LightYellow3
syn keyword colortemplateConstant     contained LightYellow4 lime LimeGreen linen magenta magenta1 magenta2 magenta3
syn keyword colortemplateConstant     contained magenta4 maroon maroon1 maroon2 maroon3 maroon4 medium MediumAquamarine
syn keyword colortemplateConstant     contained MediumBlue MediumOrchid MediumOrchid1 MediumOrchid2 MediumOrchid3 MediumOrchid4 MediumPurple MediumPurple1
syn keyword colortemplateConstant     contained MediumPurple2 MediumPurple3 MediumPurple4 MediumSeaGreen MediumSlateBlue MediumSpringGreen MediumTurquoise MediumVioletRed
syn keyword colortemplateConstant     contained midnight MidnightBlue mint MintCream misty MistyRose MistyRose1 MistyRose2
syn keyword colortemplateConstant     contained MistyRose3 MistyRose4 moccasin navajo NavajoWhite NavajoWhite1 NavajoWhite2 NavajoWhite3
syn keyword colortemplateConstant     contained NavajoWhite4 navy NavyBlue old OldLace olive OliveDrab OliveDrab1
syn keyword colortemplateConstant     contained OliveDrab2 OliveDrab3 OliveDrab4 Orange orange orange1 orange2 orange3 orange4
syn keyword colortemplateConstant     contained OrangeRed OrangeRed1 OrangeRed2 OrangeRed3 OrangeRed4 orchid orchid1 orchid2
syn keyword colortemplateConstant     contained orchid3 orchid4 pale PaleGoldenrod PaleGreen PaleGreen1 PaleGreen2 PaleGreen3
syn keyword colortemplateConstant     contained PaleGreen4 PaleTurquoise PaleTurquoise1 PaleTurquoise2 PaleTurquoise3 PaleTurquoise4 PaleVioletRed PaleVioletRed1
syn keyword colortemplateConstant     contained PaleVioletRed2 PaleVioletRed3 PaleVioletRed4 papaya PapayaWhip peach PeachPuff PeachPuff1
syn keyword colortemplateConstant     contained PeachPuff2 PeachPuff3 PeachPuff4 peru pink pink1 pink2 pink3
syn keyword colortemplateConstant     contained pink4 plum plum1 plum2 plum3 plum4 powder PowderBlue
syn keyword colortemplateConstant     contained puff purple purple1 purple2 purple3 purple4 rebecca RebeccaPurple
syn keyword colortemplateConstant     contained red red1 red2 red3 red4 rose rosy RosyBrown
syn keyword colortemplateConstant     contained RosyBrown1 RosyBrown2 RosyBrown3 RosyBrown4 royal RoyalBlue RoyalBlue1 RoyalBlue2
syn keyword colortemplateConstant     contained RoyalBlue3 RoyalBlue4 saddle SaddleBrown salmon salmon1 salmon2 salmon3
syn keyword colortemplateConstant     contained salmon4 sandy SandyBrown sea SeaGreen SeaGreen1 SeaGreen2 SeaGreen3
syn keyword colortemplateConstant     contained SeaGreen4 seashell seashell1 seashell2 seashell3 seashell4 sienna sienna1
syn keyword colortemplateConstant     contained sienna2 sienna3 sienna4 silver sky SkyBlue SkyBlue1 SkyBlue2
syn keyword colortemplateConstant     contained SkyBlue3 SkyBlue4 slate SlateBlue SlateBlue1 SlateBlue2 SlateBlue3 SlateBlue4
syn keyword colortemplateConstant     contained SlateGray SlateGray1 SlateGray2 SlateGray3 SlateGray4 SlateGrey smoke snow
syn keyword colortemplateConstant     contained snow1 snow2 snow3 snow4 spring SpringGreen SpringGreen1 SpringGreen2
syn keyword colortemplateConstant     contained SpringGreen3 SpringGreen4 steel SteelBlue SteelBlue1 SteelBlue2 SteelBlue3 SteelBlue4
syn keyword colortemplateConstant     contained tan tan1 tan2 tan3 tan4 teal thistle thistle1
syn keyword colortemplateConstant     contained thistle2 thistle3 thistle4 tomato tomato1 tomato2 tomato3 tomato4
syn keyword colortemplateConstant     contained turquoise turquoise1 turquoise2 turquoise3 turquoise4 violet VioletRed VioletRed1
syn keyword colortemplateConstant     contained VioletRed2 VioletRed3 VioletRed4 web WebGray WebGreen WebGrey WebMaroon
syn keyword colortemplateConstant     contained WebPurple wheat wheat1 wheat2 wheat3 wheat4 whip white
syn keyword colortemplateConstant     contained WhiteSmoke x11 X11Gray X11Green X11Grey X11Maroon X11Purple yellow
syn keyword colortemplateConstant     contained yellow1 yellow2 yellow3 yellow4 YellowGreen

" These are defined for syntax completion. Since they are `contained`, but not
" really contained into anything, this rule is never triggered.
syn keyword colortemplateKeyword      contained auxfile endauxfile documentation enddocumentation reset endreset verbatim endverbatim

syn include @colortemplatevim syntax/vim.vim
unlet b:current_syntax
syn region colortemplateVim matchgroup=colortemplateVerb start=/^\s*verbatim\>/ end=/^\s*endverbatim\>/ keepend contains=@colortemplatevim
syn region colortemplateReset matchgroup=colortemplateVerb start=/^\s*reset\>/ end=/^\s*endreset\>/ keepend contains=@colortemplatevim
syn region colortemplateAux   matchgroup=colortemplateVerb start=/^\s*auxfile\s\+.*$/ end=/^\s*endauxfile\>/ keepend contains=@colortemplatevim
syn region colortemplateCommand matchgroup=colortemplateCommand start=/^\s*#\%(if\|else\%[if]\|endif\|\%[un]let\|call\)\>/ end=/$/ keepend contains=@colortemplatevim

syn include @colortemplatehelp syntax/help.vim
unlet b:current_syntax
syn region colortemplateHelp matchgroup=colortemplateVerb start=/documentation/ end=/enddocumentation/ keepend contains=@colortemplatehelp

hi def link colortemplateArrow        Delimiter
hi def link colortemplateAttr         Label
hi def link colortemplateAttrs        String
hi def link colortemplateCommand      PreProc
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
hi def link colortemplateTermCode     String
hi def link colortemplateTodo         Todo
hi def link colortemplateVerb         Title

let b:current_syntax = "colortemplate"

" vim: nowrap et ts=2 sw=2
