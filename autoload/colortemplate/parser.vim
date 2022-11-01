vim9script

import 'libparser.vim' as parser

const Apply      = parser.Apply
const Eof        = parser.Eof
const Fail       = parser.Fail
const Label      = parser.Label
const Lexeme     = parser.Lexeme
const Many       = parser.Many
const Map        = parser.Map
const OneOf      = parser.OneOf
const Optional   = parser.Optional
const Regex      = parser.Regex
const Sequence   = parser.Sequence
const Skip       = parser.Skip
const Text       = parser.Text

# Colortemplate semi-formal grammar {{{
# Template                  ::= (VerbatimBlock | Declaration | Comment)*
# VerbatimBlock             ::= OneLiner | ResetBlock | HelpBlock
# OneLiner                  ::= ('#if' | '#else[if]' | '#endif' | '#let' | '#unlet[!]' | '#call[!]') '[^\r\n]*'
# ResetBlock                ::= 'reset' '.*' 'endreset'
# HelpBlock                 ::= 'help' '.*' 'endhelp'
# Declaration               ::= [Directive | HiGroupDef]
# Comment                   ::= ';' '[^\r\n]*'

# Directive                 ::= 'Color' ':' ColorDef | Key ':' DirectiveValue
# Key                       ::= 'Include' | 'Full name' | 'Short name' | 'Author' | 'Background' | ...
# DirectiveValue            ::= '[^\r\n]+'

# ColorDef                  ::= ColorName GUIValue Base256Value [Base16Value]
# ColorName                 ::= '[A-Za-z][A-Za-z0-9_]*'
# GUIValue                  ::= HexValue | RGBValue
# HexValue                  ::= '#[A-Fa-f0-9]{6}'
# RGBValue                  ::= 'rgb' '(' Num256 ',' Num256 ',' Num256 ')'
# Base256Value              ::= '~' | Num256
# Num256                    ::= '0' | '1' | ... | '255'
# Base16Value               ::= '0' | '1' | ... | '15' | 'Black' | 'DarkRed' | ...

# HiGroupDef                ::= HiGroupName HiGroupDefRest
# HiGroupDefRest            ::= '->' HiGroupName | BaseGroup
# BaseGroup                 ::= FgColor BgColor (Attributes)*
# HiGroupName               ::= '[A-z][A-z0-9]*'
# FgColor                   ::= ColorName
# BgColor                   ::= ColorName
# Attributes                ::= [('term' | 't' | 'gui' | 'g') '='] AttrValueList | ('guisp' | 's') '=' ColorName
# AttrValueList             ::= AttrValue TrailingAttrValue*
# AttrValue                 ::= 'bold' | 'italic' | 'reverse' | 'inverse' | 'underline' | ...
# TrailingAttrValue         ::= ',' AttrValue
# }}}

# Semantic actions {{{
var currentState = {
  background: v:none,
  variants: []
}

def SetFullName(v: list<string>): void
  const name = v[3]
  echo 'FULLNAME = "' .. name .. '"'
enddef

def SetShortName(v: list<string>): void
  const name = v[3]
  echo 'SHORT NAME = "' .. name .. '"'
enddef

def SetAuthor(v: list<string>): void
  const name = v[2]
  echo printf("Setting author's name to '%s'", name)
enddef

def SetDescription(v: list<string>): void
  const description = v[2]
  echo printf("Setting description to '%s'", description)
enddef

def SetWebsite(v: list<string>): void
  const website = v[2]
  echo printf("Setting website to '%s'", website)
enddef

def SetActiveBackground(v: list<string>): void
  const background = v[2]
  echo printf("Setting background to '%s'", background)
  currentState.background = background
enddef

def SetActiveVariants(v: list<any>): void
  const variants = v[2]
  echo printf("Setting variants to '%s'", variants)
  currentState.variants = variants
enddef

def DefineColor(v: list<any>): void
  const color = v[2]
  echo printf("Defining color %s for background %s", color, currentState.background)
enddef

def DefineLinkedGroup(source: string, target: string): void
  echo printf("Defining linked hi group %s -> %s for background %s and variants %s",
    source, target, currentState.background, currentState.variants)
enddef

def DefineBaseGroup(name: string, v: any): void
 echo printf("Defining base group %s for background %s and variants %s",
   name, currentState.background, currentState.variants)
 const fgcol      = v[0]
 const bgcol      = v[1]
 const attributes = v[2]
 for attrGroup in attributes
   if len(attrGroup) == 1 # E.g., [['italic', 'bold']]
     echo printf("Both term/gui = %s", attrGroup[0])
   else # E.g., ['gui', ['italic', 'bold']] or ['guisp', 'colorname']
     const kind = attrGroup[0]
     if match(kind, 'guisp\|s') == -1
       echo printf("Only %s = %s", attrGroup[0], attrGroup[1])
     else
       echo printf("guisp color = %s", attrGroup[1])
     endif
   endif
 endfor
 echo printf(" Name=%s fg=%s bg=%s attrs=%s", name, fgcol, bgcol, attributes)
enddef

def DefineHighlightGroup(v: any): void
  const name = v[0]
  if v[1][0] == '->'
    DefineLinkedGroup(name, v[1][1])
  else
    DefineBaseGroup(name, v[1])
  endif
enddef
# }}}

# Parser {{{
const Space = Regex('\%(\r\|\n\|\s\)*', 'whitespace')
const Token = Lexeme(Space)

def TextToken(token: string): func(dict<any>): dict<any>
  return Token(Text(token))
enddef

def RegexToken(pattern: string, expected: string): func(dict<any>): dict<any>
  return Token(Regex(pattern, expected))
enddef

# FIXME: Include, Terminal Colors

const ATTRVALUE          = RegexToken('\%(bold\|italic\|reverse\|inverse\|underline\|undercurl\|strikethrough\|standout\|\|nocombine\)\>', 'attribute value')
const BACKGROUND         = RegexToken('dark\|light\|any\>', "one of 'dark', 'light', or 'any'")
const BASE16VALUE        = RegexToken('\%(\d\+\)\|\w\+\|omit\>', 'xterm color name or color value between 0 and 15') # FIXME: match only colors from g:colortemplate#colorspace#ansi_colors
const COLON              = TextToken(':')
const COLORNAME          = RegexToken('[A-z][A-z0-9_]*\>', "a color's name")
const COLORSNAME         = RegexToken('\w\+', "the color scheme's short name")
const COMMA              = Skip(TextToken(','))
const EQUALSIGN          = Skip(TextToken('='))
const HEXCOLOR           = RegexToken('#[A-Fa-f0-9]\{6}\>', 'hex color value')
const HIGROUPNAME        = RegexToken('[A-z][A-z0-9]*\>',  "the name of a highlight group")
const K_AUTHOR           = TextToken('Author')
const K_BACKGROUND       = TextToken('Background')
const K_COLOR            = TextToken('Color')
const K_COLORS           = RegexToken('[Cc]olors', "'Colors' keyword")
const K_DESCRIPTION      = TextToken('Description')
const K_FULL             = TextToken('Full')
const K_GUI              = RegexToken('g\%[ui]\>', "'gui' keyword")
const K_GUISP            = RegexToken('guisp\|s', "'guisp' keyword")
const K_LICENSE          = TextToken('License')
const K_NAME             = RegexToken('[Nn]ame', "'name' keyword")
const K_SHORT            = TextToken('Short')
const K_TERM             = RegexToken('t\%[erm]', "'term' keyword")
const K_TERMINAL         = RegexToken('Term\%[inal\]', "'Terminal' keyword")
const K_VARIANT          = TextToken('Variant')
const K_WEBSITE          = TextToken('Website')
const NUM256             = RegexToken('\d\{1,3}\>', 'color value between 0 and 255')
const RIGHTARROW         = TextToken('->')
const SEMICOLON          = TextToken(';')
const TEXT               = RegexToken('[^\r\n]\+', "some text")
const TILDE              = TextToken('~')

const Color              = Sequence(COLORNAME, HEXCOLOR, OneOf(TILDE, NUM256), BASE16VALUE)
const ColorDef           = Sequence(K_COLOR, COLON, Color)
                          ->Apply(DefineColor)

const TrailingAttrValue  = Sequence(COMMA, ATTRVALUE)
const AttrValueList      = Sequence(ATTRVALUE, Many(TrailingAttrValue))->Map((v) => flattennew(v))
const Attribute          = OneOf(
                            Sequence(K_GUISP, EQUALSIGN, COLORNAME),
                            Sequence(Optional(Sequence(OneOf(K_GUI, K_TERM), EQUALSIGN)->Map((v) => v[0])), AttrValueList)
                          )

const BaseGroup          = Sequence(COLORNAME, COLORNAME, Many(Attribute))
const LinkedGroup        = Sequence(RIGHTARROW, HIGROUPNAME)
const HighlightGroupRest = OneOf(BaseGroup, LinkedGroup)
const HighlightGroup     = Sequence(HIGROUPNAME, HighlightGroupRest)
                          ->Apply(DefineHighlightGroup)

const VariantDef         = Many(OneOf(NUM256, K_GUI))
const Variant            = Sequence(K_VARIANT, COLON, VariantDef)
                           ->Apply(SetActiveVariants)

const Background         = Sequence(K_BACKGROUND, COLON, BACKGROUND)
                           ->Apply(SetActiveBackground)

const Fullname           = Sequence(K_FULL, K_NAME, COLON, TEXT)
                          ->Apply(SetFullName)

const Shortname          = Sequence(K_SHORT, K_NAME, COLON, COLORSNAME)
                          ->Apply(SetShortName)

const Author             = Sequence(K_AUTHOR, COLON, TEXT)
                           ->Apply(SetAuthor)

const Description        = Sequence(K_DESCRIPTION, COLON, TEXT)
                          ->Apply(SetDescription)

const Website           = Sequence(K_WEBSITE, COLON, TEXT)
                          ->Apply(SetWebsite)

const Comment           = Skip(Sequence(SEMICOLON, Optional(TEXT)))

const Directive          = OneOf(ColorDef, Background, Variant, Fullname, Shortname, Author, Description, Website)
const Declaration        = Label(OneOf(Directive, HighlightGroup, Comment), "a directive or a highlight group definition")
const Template           = Sequence(Many(Declaration), OneOf(Eof, Label(Fail, 'unexpected token')))
# }}}

export def Parse(Parser: func(dict<any>): dict<any>, text: string): any
  var   ctx    = {text: text, index: 0}
  const result = Parser(ctx)

  if result.success
    return result.value
  endif

  return printf("Parse error (%d:%d): expected %s", 1 + ctx.linenr, ctx.index - ctx.linebegin + 1, result.expected)
enddef

