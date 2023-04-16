vim9script
# Name:        Colortemplate
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     Vim license (see `:help license`)

if exists("b:current_syntax")
  finish
endif

syn case    match

syn match   colortemplateDiscrName    "+\s*\h\w*\>"
syn match   colortemplateVariant      "/\s*\d\+\|/gui\>"
syn match   colortemplateSpecial        "\<sp\?="
syn match   colortemplateTermCode     "\<st\%(art\|op\)="
syn match   colortemplateHiGroupDef   "^\h\w*\>" contains=colortemplateHiGroup
syn match   colortemplateHiGroup      contained "\<Conceal\>"
syn keyword colortemplateHiGroup      contained Boolean Character ColorColumn Comment Conditional Constant CurSearch Cursor CursorColumn CursorIM
syn keyword colortemplateHiGroup      contained CursorLine CursorLineFold CursorLineNr CursorLineSign Define Debug Delimiter DiffAdd DiffChange DiffDelete DiffText Directory
syn keyword colortemplateHiGroup      contained EndOfBuffer Error ErrorMsg Exception Float FoldColumn Folded Function Identifier Ignore
syn keyword colortemplateHiGroup      contained IncSearch Include Keyword Label LineNr LineNrAbove LineNrBelow Macro MatchParen MessageWindow ModeMsg MoreMsg NonText
syn keyword colortemplateHiGroup      contained Normal Number Operator Pmenu PmenuKind PmenuKindSel PmenuExtra PmenuExtraSel PmenuSbar PmenuSel PmenuThumb
syn keyword colortemplateHiGroup      contained PopupNotification PopupSelected PreCondit PreProc Question
syn keyword colortemplateHiGroup      contained QuickFixLine Repeat Search SignColumn Special SpecialChar SpecialComment SpecialKey SpellBad SpellCap
syn keyword colortemplateHiGroup      contained SpellLocal SpellRare Statement StatusLine StatusLineNC StatusLineTerm StatusLineTermNC StorageClass String
syn keyword colortemplateHiGroup      contained Structure TabLine TabLineFill TabLineSel Tag Terminal Title Todo Type Typedef Underlined VertSplit
syn keyword colortemplateHiGroup      contained debugPC debugBreakpoint ToolbarLine ToolbarButton
syn keyword colortemplateHiGroup      contained Visual VisualNOS WarningMsg WildMenu lCursor
syn keyword colortemplateHiGroup      contained Menu Scrollbar Tooltip User1 User2 User3 User4 User5 User6 User7 User8 User9
syn keyword colortemplateHiGroup      contained vimAuSyntax vimAugroup vimAutoCmdSfxList vimAutoCmdSpace vimAutoEventList vimBracket vimClusterName vimCmdSep
syn keyword colortemplateHiGroup      contained vimCollClass vimCollection vimCommentTitle vimCommentTitleLeader vimEcho vimEscapeBrace vimExecute vimExtCmd
syn keyword colortemplateHiGroup      contained vimFiletype vimFilter vimFuncBlank vimFuncBody vimFunction vimGlobal vimGroupList vimHiBang
syn keyword colortemplateHiGroup      contained vimHiCtermColor vimHiFontname vimHiGuiFontname vimHiKeyList vimHiLink vimHiTermcap vimIf vimIsCommand
syn keyword colortemplateHiGroup      contained vimIskList vimMapLhs vimMapMod vimMapModKey vimMapRhs vimMapRhsExtend vimMenuBang vimMenuMap
syn keyword colortemplateHiGroup      contained vimMenuPriority vimMenuRhs vimNormCmds vimNotation vimOperParen vimPatRegion vimRegion vimSet
syn keyword colortemplateHiGroup      contained vimSetEqual vimStdPlugin vimSubstPat vimSubstRange vimSubstRep vimSubstRep4 vimSynKeyRegion vimSynLine
syn keyword colortemplateHiGroup      contained vimSynMatchRegion vimSynMtchCchar vimSynMtchGroup vimSynPatMod vimSynRegion vimSyncLinebreak vimSyncLinecont vimSyncLines
syn keyword colortemplateHiGroup      contained vimSyncMatch vimSyncRegion vimUserCmd vimUserFunc
syn keyword colortemplateAttr         bold underline undercurl underdouble underdotted underdashed strikethrough reverse inverse italic standout nocombine NONE
syn keyword colortemplateSpecial      fg bg none omit
syn match   colortemplateComment      ";.*$" contains=colortemplateTodo,@Spell
syn match   colortemplateKey          "\%(Color\|Background\|Variants\|Include\|\%(Full\|Short\)\s\+[Nn]ame\|Author\|Maintainer\|URL\|Description\|License\|Term\s\+[Cc]olors\|Options\|Prefix\):"
syn match   colortemplateColorSpec    "^\s*Color\s*:\s*\w\+" contains=colortemplateKey nextgroup=colortemplateColorDef
syn match   colortemplateColorDef     ".\+$" contained contains=colortemplateNumber,colortemplateHexColor,colortemplateFunction,colortemplateConstant,colortemplateCompound,colortemplateComment
syn match   colortemplateNumber       "\<\d\+\>" contained
syn match   colortemplateArrow        "->"
syn match   colortemplateHexColor     "#[A-Fa-f0-9]\{6\}" contained
syn keyword colortemplateFunction     contained rgb
syn keyword colortemplateTodo         contained TODO FIXME XXX DEBUG NOTE
# Basic color names
syn keyword colortemplateConstant     contained Black Blue Brown Cyan DarkRed DarkGreen DarkYellow DarkBlue DarkMagenta DarkCyan Green LightGray LightGrey
syn keyword colortemplateConstant     contained DarkGray DarkGrey Gray Grey LightRed LightGreen LightYellow LightBlue LightMagenta LightCyan Magenta Red Yellow White
# Color names from $VIMRUNTIME/colors/lists/default.vim
syn keyword colortemplateconstant     contained alice aliceblue almond antique antiquewhite antiquewhite1 antiquewhite2 antiquewhite3
syn keyword colortemplateconstant     contained antiquewhite4 aqua aquamarine aquamarine1 aquamarine2 aquamarine3 aquamarine4 azure
syn keyword colortemplateconstant     contained azure1 azure2 azure3 azure4 beige bisque bisque1 bisque2
syn keyword colortemplateconstant     contained bisque3 bisque4 black blanched blanchedalmond blue blue1 blue2
syn keyword colortemplateconstant     contained blue3 blue4 blueviolet blush brown brown1 brown2 brown3
syn keyword colortemplateconstant     contained brown4 burlywood burlywood1 burlywood2 burlywood3 burlywood4 cadet cadetblue
syn keyword colortemplateconstant     contained cadetblue1 cadetblue2 cadetblue3 cadetblue4 chartreuse chartreuse1 chartreuse2 chartreuse3
syn keyword colortemplateconstant     contained chartreuse4 chiffon chocolate chocolate1 chocolate2 chocolate3 chocolate4 coral
syn keyword colortemplateconstant     contained coral1 coral2 coral3 coral4 cornflower cornflowerblue cornsilk cornsilk1
syn keyword colortemplateconstant     contained cornsilk2 cornsilk3 cornsilk4 cream crimson cyan cyan1 cyan2
syn keyword colortemplateconstant     contained cyan3 cyan4 dark darkblue darkcyan darkgoldenrod darkgoldenrod1 darkgoldenrod2
syn keyword colortemplateconstant     contained darkgoldenrod3 darkgoldenrod4 darkgray darkgreen darkgrey darkkhaki darkmagenta darkolivegreen
syn keyword colortemplateconstant     contained darkolivegreen1 darkolivegreen2 darkolivegreen3 darkolivegreen4 darkorange darkorange1 darkorange2 darkorange3
syn keyword colortemplateconstant     contained darkorange4 darkorchid darkorchid1 darkorchid2 darkorchid3 darkorchid4 darkred darksalmon
syn keyword colortemplateconstant     contained darkseagreen darkseagreen1 darkseagreen2 darkseagreen3 darkseagreen4 darkslateblue darkslategray darkslategray1
syn keyword colortemplateconstant     contained darkslategray2 darkslategray3 darkslategray4 darkslategrey darkturquoise darkviolet darkyellow deep deeppink
syn keyword colortemplateconstant     contained deeppink1 deeppink2 deeppink3 deeppink4 deepskyblue deepskyblue1 deepskyblue2 deepskyblue3
syn keyword colortemplateconstant     contained deepskyblue4 dim dimgray dimgrey dodger dodgerblue dodgerblue1 dodgerblue2
syn keyword colortemplateconstant     contained dodgerblue3 dodgerblue4 drab firebrick firebrick1 firebrick2 firebrick3 firebrick4
syn keyword colortemplateconstant     contained floral floralwhite forest forestgreen fuchsia gainsboro ghost ghostwhite
syn keyword colortemplateconstant     contained gold gold1 gold2 gold3 gold4 goldenrod goldenrod1 goldenrod2
syn keyword colortemplateconstant     contained goldenrod3 goldenrod4 gray gray0 gray1 gray10 gray100 gray11
syn keyword colortemplateconstant     contained gray12 gray13 gray14 gray15 gray16 gray17 gray18 gray19
syn keyword colortemplateconstant     contained gray2 gray20 gray21 gray22 gray23 gray24 gray25 gray26
syn keyword colortemplateconstant     contained gray27 gray28 gray29 gray3 gray30 gray31 gray32 gray33
syn keyword colortemplateconstant     contained gray34 gray35 gray36 gray37 gray38 gray39 gray4 gray40
syn keyword colortemplateconstant     contained gray41 gray42 gray43 gray44 gray45 gray46 gray47 gray48
syn keyword colortemplateconstant     contained gray49 gray5 gray50 gray51 gray52 gray53 gray54 gray55
syn keyword colortemplateconstant     contained gray56 gray57 gray58 gray59 gray6 gray60 gray61 gray62
syn keyword colortemplateconstant     contained gray63 gray64 gray65 gray66 gray67 gray68 gray69 gray7
syn keyword colortemplateconstant     contained gray70 gray71 gray72 gray73 gray74 gray75 gray76 gray77
syn keyword colortemplateconstant     contained gray78 gray79 gray8 gray80 gray81 gray82 gray83 gray84
syn keyword colortemplateconstant     contained gray85 gray86 gray87 gray88 gray89 gray9 gray90 gray91
syn keyword colortemplateconstant     contained gray92 gray93 gray94 gray95 gray96 gray97 gray98 gray99
syn keyword colortemplateconstant     contained green green1 green2 green3 green4 greenyellow grey grey0
syn keyword colortemplateconstant     contained grey1 grey10 grey100 grey11 grey12 grey13 grey14 grey15
syn keyword colortemplateconstant     contained grey16 grey17 grey18 grey19 grey2 grey20 grey21 grey22
syn keyword colortemplateconstant     contained grey23 grey24 grey25 grey26 grey27 grey28 grey29 grey3
syn keyword colortemplateconstant     contained grey30 grey31 grey32 grey33 grey34 grey35 grey36 grey37
syn keyword colortemplateconstant     contained grey38 grey39 grey4 grey40 grey41 grey42 grey43 grey44
syn keyword colortemplateconstant     contained grey45 grey46 grey47 grey48 grey49 grey5 grey50 grey51
syn keyword colortemplateconstant     contained grey52 grey53 grey54 grey55 grey56 grey57 grey58 grey59
syn keyword colortemplateconstant     contained grey6 grey60 grey61 grey62 grey63 grey64 grey65 grey66
syn keyword colortemplateconstant     contained grey67 grey68 grey69 grey7 grey70 grey71 grey72 grey73
syn keyword colortemplateconstant     contained grey74 grey75 grey76 grey77 grey78 grey79 grey8 grey80
syn keyword colortemplateconstant     contained grey81 grey82 grey83 grey84 grey85 grey86 grey87 grey88
syn keyword colortemplateconstant     contained grey89 grey9 grey90 grey91 grey92 grey93 grey94 grey95
syn keyword colortemplateconstant     contained grey96 grey97 grey98 grey99 honeydew honeydew1 honeydew2 honeydew3
syn keyword colortemplateconstant     contained honeydew4 hot hotpink hotpink1 hotpink2 hotpink3 hotpink4 indian
syn keyword colortemplateconstant     contained indianred indianred1 indianred2 indianred3 indianred4 indigo ivory ivory1
syn keyword colortemplateconstant     contained ivory2 ivory3 ivory4 khaki khaki1 khaki2 khaki3 khaki4
syn keyword colortemplateconstant     contained lace lavender lavenderblush lavenderblush1 lavenderblush2 lavenderblush3 lavenderblush4 lawn
syn keyword colortemplateconstant     contained lawngreen lemon lemonchiffon lemonchiffon1 lemonchiffon2 lemonchiffon3 lemonchiffon4 light
syn keyword colortemplateconstant     contained lightblue lightblue1 lightblue2 lightblue3 lightblue4 lightcoral lightcyan lightcyan1
syn keyword colortemplateconstant     contained lightcyan2 lightcyan3 lightcyan4 lightgoldenrod lightgoldenrod1 lightgoldenrod2 lightgoldenrod3 lightgoldenrod4
syn keyword colortemplateconstant     contained lightgoldenrodyellow lightgray lightgreen lightgrey lightpink lightpink1 lightpink2 lightpink3
syn keyword colortemplateconstant     contained lightpink4 lightsalmon lightsalmon1 lightsalmon2 lightsalmon3 lightsalmon4 lightseagreen lightskyblue
syn keyword colortemplateconstant     contained lightskyblue1 lightskyblue2 lightskyblue3 lightskyblue4 lightslateblue lightslategray lightslategrey lightsteelblue
syn keyword colortemplateconstant     contained lightsteelblue1 lightsteelblue2 lightsteelblue3 lightsteelblue4 lightyellow lightyellow1 lightyellow2 lightyellow3
syn keyword colortemplateconstant     contained lightyellow4 lime limegreen linen magenta magenta1 magenta2 magenta3
syn keyword colortemplateconstant     contained magenta4 maroon maroon1 maroon2 maroon3 maroon4 medium mediumaquamarine
syn keyword colortemplateconstant     contained mediumblue mediumorchid mediumorchid1 mediumorchid2 mediumorchid3 mediumorchid4 mediumpurple mediumpurple1
syn keyword colortemplateconstant     contained mediumpurple2 mediumpurple3 mediumpurple4 mediumseagreen mediumslateblue mediumspringgreen mediumturquoise mediumvioletred
syn keyword colortemplateconstant     contained midnight midnightblue mint mintcream misty mistyrose mistyrose1 mistyrose2
syn keyword colortemplateconstant     contained mistyrose3 mistyrose4 moccasin navajo navajowhite navajowhite1 navajowhite2 navajowhite3
syn keyword colortemplateconstant     contained navajowhite4 navy navyblue old oldlace olive olivedrab olivedrab1
syn keyword colortemplateconstant     contained olivedrab2 olivedrab3 olivedrab4 orange orange orange1 orange2 orange3 orange4
syn keyword colortemplateconstant     contained orangered orangered1 orangered2 orangered3 orangered4 orchid orchid1 orchid2
syn keyword colortemplateconstant     contained orchid3 orchid4 pale palegoldenrod palegreen palegreen1 palegreen2 palegreen3
syn keyword colortemplateconstant     contained palegreen4 paleturquoise paleturquoise1 paleturquoise2 paleturquoise3 paleturquoise4 palevioletred palevioletred1
syn keyword colortemplateconstant     contained palevioletred2 palevioletred3 palevioletred4 papaya papayawhip peach peachpuff peachpuff1
syn keyword colortemplateconstant     contained peachpuff2 peachpuff3 peachpuff4 peru pink pink1 pink2 pink3
syn keyword colortemplateconstant     contained pink4 plum plum1 plum2 plum3 plum4 powder powderblue
syn keyword colortemplateconstant     contained puff purple purple1 purple2 purple3 purple4 rebecca rebeccapurple
syn keyword colortemplateconstant     contained red red1 red2 red3 red4 rose rosy rosybrown
syn keyword colortemplateconstant     contained rosybrown1 rosybrown2 rosybrown3 rosybrown4 royal royalblue royalblue1 royalblue2
syn keyword colortemplateconstant     contained royalblue3 royalblue4 saddle saddlebrown salmon salmon1 salmon2 salmon3
syn keyword colortemplateconstant     contained salmon4 sandy sandybrown sea seagreen seagreen1 seagreen2 seagreen3
syn keyword colortemplateconstant     contained seagreen4 seashell seashell1 seashell2 seashell3 seashell4 sienna sienna1
syn keyword colortemplateconstant     contained sienna2 sienna3 sienna4 silver sky skyblue skyblue1 skyblue2
syn keyword colortemplateconstant     contained skyblue3 skyblue4 slate slateblue slateblue1 slateblue2 slateblue3 slateblue4
syn keyword colortemplateconstant     contained slategray slategray1 slategray2 slategray3 slategray4 slategrey smoke snow
syn keyword colortemplateconstant     contained snow1 snow2 snow3 snow4 spring springgreen springgreen1 springgreen2
syn keyword colortemplateconstant     contained springgreen3 springgreen4 steel steelblue steelblue1 steelblue2 steelblue3 steelblue4
syn keyword colortemplateconstant     contained tan tan1 tan2 tan3 tan4 teal thistle thistle1
syn keyword colortemplateconstant     contained thistle2 thistle3 thistle4 tomato tomato1 tomato2 tomato3 tomato4
syn keyword colortemplateconstant     contained turquoise turquoise1 turquoise2 turquoise3 turquoise4 violet violetred violetred1
syn keyword colortemplateconstant     contained violetred2 violetred3 violetred4 web webgray webgreen webgrey webmaroon
syn keyword colortemplateconstant     contained webpurple wheat wheat1 wheat2 wheat3 wheat4 whip white
syn keyword colortemplateconstant     contained whitesmoke x11 x11gray x11green x11grey x11maroon x11purple yellow
syn keyword colortemplateconstant     contained yellow1 yellow2 yellow3 yellow4 yellowgreen

# These are defined for syntax completion. Since they are `contained`, but not
# really contained into anything, this rule is never triggered.
syn keyword colortemplateKeyword      contained auxfile endauxfile helpfile endhelpfile verbatim endverbatim

syn include @colortemplatevim syntax/vim.vim
unlet b:current_syntax
syn region colortemplateVim matchgroup=colortemplateVerb start=/^\s*verbatim\>/ end=/^\s*endverbatim\>/ keepend contains=@colortemplatevim
syn region colortemplateAux   matchgroup=colortemplateVerb start=/^\s*auxfile\s\+.*$/ end=/^\s*endauxfile\>/ keepend contains=@colortemplatevim
syn region colortemplateConst matchgroup=colortemplateConst start=/#const\>/ end=/$/ keepend contains=@colortemplatevim

syn include @colortemplatehelp syntax/help.vim
unlet b:current_syntax
syn region colortemplateHelp matchgroup=colortemplateVerb start=/helpfile/ end=/endhelpfile/ keepend contains=@colortemplatehelp

hi def link colortemplateArrow        Delimiter
hi def link colortemplateAttr         Label
hi def link colortemplateConst        PreProc
hi def link colortemplateConstant     Type
hi def link colortemplateComment      Comment
hi def link colortemplateDiscrName    Identifier
hi def link colortemplateFunction     Function
hi def link colortemplateSpecial      String
hi def link colortemplateHexColor     Constant
hi def link colortemplateHiGroup      Constant
hi def link colortemplateHiGroupDef   Keyword
hi def link colortemplateNumber       Number
hi def link colortemplateKey          Special
hi def link colortemplateKeyword      Keyword
hi def link colortemplateSpecial      Boolean
hi def link colortemplateTermCode     String
hi def link colortemplateTodo         Todo
hi def link colortemplateVariant      PreProc
hi def link colortemplateVerb         Title

b:current_syntax = "colortemplate"

# vim: nowrap et ts=2 sw=2
