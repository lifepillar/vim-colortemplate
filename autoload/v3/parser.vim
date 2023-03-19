vim9script

import 'libparser.vim' as parser
import './colorscheme.vim'

# Aliases {{{
const Database       = colorscheme.Database
const Metadata       = colorscheme.Metadata

const Apply          = parser.Apply
const Bol            = parser.Bol
const Context        = parser.Context
const Eof            = parser.Eof
const Lab            = parser.Lab
const LookAhead      = parser.LookAhead
const Many           = parser.Many
const Map            = parser.Map
const OneOf          = parser.OneOf
const OneOrMore      = parser.OneOrMore
const Opt            = parser.Opt
const Result         = parser.Result
const Seq            = parser.Seq
const Skip           = parser.Skip
const SpaceOrComment = parser.Regex('\%([ \n\t\r]*\%(;[^\n\r]*\)\=\)*')
const Regex          = parser.Regex
const R              = parser.RegexToken(SpaceOrComment)
const T              = parser.TextToken(SpaceOrComment)
# }}}

# Semantic actions {{{
def SetActiveBackground(v: list<string>, ctx: Context)
  const bg = v[2]
  if bg != 'dark' && bg != 'light'
    throw printf(
      "Invalid background: %s. Valid values are 'dark' and 'light'.", bg
    )
  endif

  const state = ctx.state
  var meta: Metadata = state.meta
  state.background = v[2]
  meta.backgrounds[state.background] = true
enddef

def SetOption(v: list<string>, ctx: Context)
  const key: string  = v[0]
  const val: string  = v[2]
  var meta: Metadata = ctx.state.meta

  meta.options[key] = val
enddef

def SetSupportedVariants(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  if !empty(meta.variants)
    throw printf(
      "Supported variants already defined ('%s')", meta.variants
    )
  endif
  meta.variants = ['gui'] + v
  meta.variants->sort()->uniq()
enddef

def SetFullName(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  if !empty(meta.fullname)
    throw printf(
      'Full name already defined (%s)', meta.fullname
    )
  endif
  meta.fullname = v[3]
enddef

def SetShortName(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  if !empty(meta.shortname)
    throw printf(
      'Short name already defined (%s)', meta.shortname
    )
  endif
  meta.shortname = v[3]
enddef

def SetLicense(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  if !empty(meta.license)
    throw printf(
      "License already defined ('%s')", meta.license
    )
  endif
  meta.license = v[2]
enddef

def SetAuthor(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  meta.author->add(v[2])
enddef

def SetMaintainer(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  meta.maintainer->add(v[2])
enddef

def SetDescription(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  meta.description->add(v[2])
enddef

def SetVersion(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  if !empty(meta.version)
    throw printf(
      "Version already defined ('%s')", meta.version
    )
  endif
  meta.version = v[2]
enddef

def SetURL(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  meta.url->add(v[2])
enddef

def SetTermColors(v: list<string>, ctx: Context)
  const state           = ctx.state
  var   meta: Metadata  = state.meta
  const dbase: Database = state.Db()

  for colorName in v
    const t = dbase.Color.Lookup(['ColorName'], [colorName])
    if empty(t)
      throw printf(
        "Invalid color name: %s", colorName
      )
    endif
    meta.termcolors->add(t.GUIValue)
  endfor
enddef

def DefineColor(v: list<string>, ctx: Context)
  const colorName: string   = v[2]
  const vGUI:      string   = v[3]
  const v256:      string   = v[4]  # FIXME: convert ~
  const v16:       string   = v[5]
  const delta:     float    = 0.0  # FIXME
  const dbase:     Database = ctx.state.Db()
  const meta:      Metadata = ctx.state.meta

  if empty(meta.variants)
    throw "Missing Variants directive: please define the supported variants first"
  endif

  dbase.Color.Insert({
    ColorName:    colorName,
    GUIValue:     vGUI,
    Base256Value: v256,
    Base16Value:  v16,
    Delta:        delta,
  })
enddef

def DefineDiscriminator(v: list<string>, ctx: Context)
  const discrName:  string   = v[2]
  const definition: string   = v[4]
  const dbase:      Database = ctx.state.Db()

  dbase.Discriminator.Insert({
    DiscrName:  discrName,
    Definition: definition,
  })
enddef

def SetHiGroupName(v: list<string>, ctx: Context)
  const state   = ctx.state
  const hiGroup = v[0]

  state.Reset()
  state.hiGroupName = hiGroup
enddef

def SetVariants(v: list<any>, ctx: Context)
  const state                  = ctx.state
  const meta: Metadata         = state.meta
  const variants: list<string> = flattennew(v)

  state.variants = variants
  state.isDefault = false
enddef

def SetDiscrName(v: list<string>, ctx: Context)
  const discrName       = v[1]
  const state           = ctx.state
  const dbase: Database = state.Db()
  const t               = dbase.HiGroup.Lookup(['HiGroupName'], [state.hiGroupName])

  if empty(t)
    throw printf(
      "Missing default definition for highlight group: %s",
      state.hiGroupName
    )
  endif

  if empty(t.DiscrName)  # First override: set the discriminator's name
    dbase.HiGroup.Update({
      HiGroupName: t.HiGroupName,
      DiscrName:   discrName,
      IsLinked:    t.IsLinked,
    })
  elseif t.DiscrName != discrName
    throw printf(
      "Inconsistent discriminator: '%s' ('%s' already uses '%s')",
      discrName, state.hiGroupName, t.DiscrName
    )
  endif

  state.discrName = discrName
  state.isDefault = false
enddef

def SetDiscrValue(discrValue: string, ctx: Context)
  ctx.state.discrValue = discrValue
enddef

def DefineLinkedGroup(v: list<string>, ctx: Context)
  const state           = ctx.state
  const dbase: Database = state.Db()
  const hiGroupName     = state.hiGroupName
  const targetGroup     = v[1]

  if state.isDefault
    dbase.InsertDefaultLinkedGroup(hiGroupName, targetGroup)
  else
    for variant in state.variants
      dbase.InsertLinkedGroupOverride(variant, state.discrValue, hiGroupName, targetGroup)
    endfor
  endif
enddef

def CheckColorName(colorName: string, ctx: Context): string
  if !empty(colorName)
    const state = ctx.state
    const db: Database = state.Db()

    if empty(db.Color.Lookup(['ColorName'], [colorName]))
      throw printf("Undefined color name: %s", colorName)
    endif
  endif

  return colorName
enddef

def DefineBaseGroup(v: list<any>, ctx: Context)
  const state           = ctx.state
  const dbase: Database = state.Db()
  const hiGroupName     = state.hiGroupName
  const fgColor         = v[0]
  const bgColor         = v[1]
  const spColor         = empty(v[2]) ? 'none' : v[2]
  const attributes      = empty(v[3]) ? 'NONE' : join(sort(v[3]), ',')

  if state.isDefault
    dbase.InsertDefaultBaseGroup(
      hiGroupName,
      fgColor, bgColor, spColor, attributes, '', '', ''
    )
  else
    for variant in state.variants
      dbase.InsertBaseGroupOverride(
        variant, state.discrValue, hiGroupName,
        fgColor, bgColor, spColor, attributes, '', '', ''
      )
    endfor
  endif
enddef
# }}}

# Parser {{{
def RefInclude(name: string): func(list<string>, Context)
  return (v: list<string>, ctx: Context) => {
    eval(name)(v, ctx)
  }
enddef

const K_AUTHOR      = T('Author')
const K_BACKGROUND  = T('Background')
const K_COLOR       = T('Color')
const K_COLORS      = R('[Cc]olors')
const K_COLORT      = T('Colortemplate')
const K_CONST       = T('const')
const K_DESCRIPTION = T('Description')
const K_FULL        = T('Full')
const K_INCLUDE     = T('Include')
const K_LICENSE     = T('License')
const K_MAINTAINER  = T('Maintainer')
const K_NAME        = R('[Nn]ame')
const K_OPTS        = R('[Oo]ptions')
const K_OPTN        = R('\%(creator\|useTabs\|shiftwidth\)\>')
const K_OPTV        = R('\%(true\|false\)\>\|\d\+')
const K_SHORT       = T('Short')
const K_SPECIAL     = R('s\|sp\>')
const K_TERM        = R('Term\%[inal\]')
const K_URL         = R('URL')
const K_VARIANT     = R('\(gui\|256\|88\|16\|8\|0\)\>')
const K_VARIANTS    = T('Variants')
const K_VERSION     = T('Version')

const BAR           = T('/')
const COLON         = T(':')
const COMMA         = T(',')
const EQ            = T('=')
const HASH          = T('#')
const PLUS          = T('+')
const RARROW        = T('->')
const SEMICOLON     = T(';')
const TILDE         = T('~')
const TRUE          = T('true')
const FALSE         = T('false')

const IDENTIFIER    = R('\<\h\w*\>')
const HIGROUPNAME   = IDENTIFIER
const DISCRNAME     = IDENTIFIER
const COLORNAME     = IDENTIFIER
const FGCOLOR       = COLORNAME
const BGCOLOR       = COLORNAME
const ATTRIBUTE     = R(printf('\%(%s\)\>',
                      join(['bold',
                        'italic',
                        'underline',
                        'undercurl',
                        'reverse',
                        'inverse',
                        'standout',
                        'strikethrough',
                        'underdashed',
                        'underdouble',
                        'underdotted',
                        'nocombine'
                      ], '\|')))
const COL16         = R('\%(\d\+\)\|\w\+') # FIXME: match only colors from g:colortemplate#colorspace#ansi_colors
const NUM256        = R('\d\{1,3}\>')
const NUMBER        = R('-\=\d\+\%(\.\d*\)\=')
const BACKGROUND    = R('dark\>\|light\>')
const HEXCOL        = R('#[A-Fa-f0-9]\{6}')
const STRING        = R('"[^"]*"')
const TEXTLINE      = R('[^\r\n]\+')
const THEMENAME     = R('\w\+')

const L_ATTRIBUTE   = Lab(ATTRIBUTE,            "Expected an attribute")
const L_BACKGROUND  = Lab(BACKGROUND,           "Expected a valid background ('light' or 'dark')")
const L_BGCOLOR     = Lab(BGCOLOR,              "Expected the name of the background color")
const L_COL256      = Lab(OneOf(TILDE, NUM256), "Expected a 256-color value or tilde")
const L_COLON       = Lab(COLON,                "Expected a colon")
const L_COLORNAME   = Lab(COLORNAME,            "Expected a color name")
const L_COLORS      = Lab(K_COLORS,             "Expected the keyword 'Colors'")
const L_CONST       = Lab(K_CONST,              "Expected the keyword 'const'")
const L_DISCRNAME   = Lab(DISCRNAME,            "Expected an identifier")
const L_EQ          = Lab(EQ,                   "Expected an equal sign")
const L_HEXCOL      = Lab(HEXCOL,               "Expected a hex color value")
const L_HIGROUPNAME = Lab(HIGROUPNAME,          "Expected the name of a highlight group")
const L_IDENTIFIER  = Lab(IDENTIFIER,           "Expected an identifier")
const L_NAME        = Lab(K_NAME,               "Expected the keyword 'Name'")
const L_OPTN        = Lab(K_OPTN,               "Expected a valid option")
const L_OPTS        = Lab(K_OPTS,               "Expected the keyword 'Options'")
const L_OPTV        = Lab(K_OPTV,               "Expected a valid option value")
const L_PATH        = Lab(TEXTLINE,             "Expected a relative path")
const L_SPCOLOR     = Lab(COLORNAME,            "Expected the name of the special color")
const L_TEXTLINE    = Lab(TEXTLINE,             "Expected the value of the directive (which cannot be empty)")
const L_THEMENAME   = Lab(THEMENAME,            "Expected a valid color scheme's name")
const L_VARIANT     = Lab(K_VARIANT,            "Expected a variant (gui, 256, 88, 16, 8, or 0)")

const Attributes    = Seq(
                        ATTRIBUTE,
                        Many(Seq(Skip(COMMA), L_ATTRIBUTE))
                      )                                             ->Map((v, _) => flattennew(v))
const SpecialColor  = Seq(K_SPECIAL, EQ, L_SPCOLOR)                 ->Map((v, _) => v[2])
const BaseGroup     = Seq(
                        FGCOLOR                                     ->Map(CheckColorName),
                        L_BGCOLOR                                   ->Map(CheckColorName),
                        Opt(SpecialColor)                           ->Map(CheckColorName),
                        Opt(Attributes)
                      )                                             ->Apply(DefineBaseGroup)
const LinkedGroup   = Seq(RARROW, L_HIGROUPNAME)                    ->Apply(DefineLinkedGroup)
const HiGroupDef    = OneOf(LinkedGroup, BaseGroup)
const DiscrValue    = OneOf(NUMBER, STRING, TRUE, FALSE)            ->Apply(SetDiscrValue)
const DiscrRest     = OneOrMore(Seq(
                        DiscrValue,
                        HiGroupDef
                      ))
const DiscrDef      = Seq(
                        Seq(PLUS, L_DISCRNAME)                     ->Apply(SetDiscrName),
                        DiscrRest
                      )
const HiGroupVar    = Seq(
                        OneOrMore(Seq(Skip(BAR), L_VARIANT))       ->Apply(SetVariants),
                        OneOf(DiscrDef, HiGroupDef)
                      )
const HiGroupVers   = OneOf(HiGroupVar, DiscrDef)
const HiGroupRest   = OneOf(
                        Seq(
                          HiGroupDef,
                          Many(HiGroupVers)
                        ),
                        OneOrMore(HiGroupVers)
                      )
const HiGroupName   = Seq(Bol, HIGROUPNAME)                        ->Apply(SetHiGroupName)
const HiGroupDecl   = Seq(HiGroupName, HiGroupRest)

const TermColorList = Seq(
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME,
                        L_COLORNAME
                      )                                             ->Apply(SetTermColors)

const OptionsList   = OneOrMore(
                        Seq(L_OPTN, L_EQ, L_OPTV)                   ->Apply(SetOption)
                      )

const VariantList   = Lab(
                        OneOrMore(K_VARIANT),
                        "Expected one of: gui, 256, 88, 16, 8, 0"
                      )                                             ->Apply(SetSupportedVariants)

const Options       = Seq(K_COLORT, L_OPTS, L_COLON, OptionsList)   ->Apply(SetVersion)
const Version       = Seq(K_VERSION,        L_COLON, L_TEXTLINE)    ->Apply(SetVersion)
const Variants      = Seq(K_VARIANTS,       L_COLON, VariantList)
const URL           = Seq(K_URL,            L_COLON, L_TEXTLINE)    ->Apply(SetURL)
const TermColors    = Seq(K_TERM, L_COLORS, L_COLON, TermColorList)
const Shortname     = Seq(K_SHORT, L_NAME,  L_COLON, L_THEMENAME)   ->Apply(SetShortName)
const Maintainer    = Seq(K_MAINTAINER,     L_COLON, L_TEXTLINE)    ->Apply(SetMaintainer)
const License       = Seq(K_LICENSE,        L_COLON, L_TEXTLINE)    ->Apply(SetLicense)
const Fullname      = Seq(K_FULL,  L_NAME,  L_COLON, L_TEXTLINE)    ->Apply(SetFullName)
const Description   = Seq(K_DESCRIPTION,    L_COLON, L_TEXTLINE)    ->Apply(SetDescription)
const Author        = Seq(K_AUTHOR,         L_COLON, L_TEXTLINE)    ->Apply(SetAuthor)
const Background    = Seq(K_BACKGROUND,     L_COLON, L_BACKGROUND)  ->Apply(SetActiveBackground)
const Include       = Seq(K_INCLUDE,        L_COLON, L_PATH)        ->Apply(RefInclude('ParseInclude'))
const ColorDef      = Seq(
                        K_COLOR,
                        L_COLON,
                        L_COLORNAME,
                        L_HEXCOL,
                        L_COL256,
                        Opt(COL16)
                      )                                            ->Apply(DefineColor)

# FIXME: better lookahead (a colon may appear in a comment)
const Directive     = Seq(LookAhead(Regex('[^\n\r]*:')),
                        Lab(OneOf(
                          ColorDef,
                          Include,
                          Background,
                          Author,
                          Description,
                          Fullname,
                          License,
                          Maintainer,
                          Shortname,
                          TermColors,
                          URL,
                          Variants,
                          Version
                        ), 'Expected a metadata directive: spurious colon?')
                      )

const Statement     = Seq(
                        HASH,
                        L_CONST,
                        L_IDENTIFIER,
                        L_EQ,
                        L_TEXTLINE
                      )                                            ->Apply(DefineDiscriminator)

const Declaration   = OneOf(Statement, Directive, HiGroupDecl)
const Template      = Seq(
                        Skip(SpaceOrComment),
                        Many(Declaration),
                        Lab(Eof, "Unexpected token")
                      )
# }}}

# Main {{{
const DEFAULT_DISCR_VALUE = colorscheme.DEFAULT_DISCR_VALUE

def GetDatabase(state: dict<any>): func(): Database
  return (): Database => {
    if empty(state.background)
      throw 'Please set the background first'
    endif
    return state[state.background]
  }
enddef

class ColortemplateContext extends Context
  def new(this.text)
    this.state.meta                   = Metadata.new()
    this.state.dark                   = Database.new('dark')
    this.state.light                  = Database.new('light')
    this.state.background             = ''
    this.state.Db                     = GetDatabase(this.state)
    this.state.hiGroupName            = ''
    this.state.isDefault              = true
    this.state.variants               = []
    this.state.discrName              = ''
    this.state.discrValue             = DEFAULT_DISCR_VALUE
    this.state.Reset                  = () => {
      const state          = this.state
      const meta: Metadata = state.meta
      state.variants       = meta.variants
      state.discrName      = ''
      state.discrValue     = DEFAULT_DISCR_VALUE
      state.isDefault      = true
    }
  enddef
endclass

export def Parse(
    text:    string,
    Parser:  func(Context): Result = Template,
    context: Context               = ColortemplateContext.new(text)
    ): dict<any>
  var   ctx    = context
  const result = Parser(ctx)

  const meta:  Metadata = ctx.state.meta
  const dark:  Database = ctx.state.dark
  const light: Database = ctx.state.light

  return {result: result, meta: meta, dark: dark, light: light}
enddef

def ParseInclude(v: list<string>, ctx: Context)
  const path   = v[2]
  const text   = join(readfile(path), "\n")
  var   newCtx = ColortemplateContext.new(text)

  newCtx.state = deepcopy(ctx.state)

  const result = Parse(text, Template, newCtx)
  const parseResult: Result = result.result

  if !parseResult.success
    throw printf("in %s, byte %d: %s",
      path, parseResult.errpos, parseResult.label
    )
  endif

  ctx.state = newCtx.state
enddef
# }}}

# Colortemplate grammar {{{
# Template                  ::= (VerbatimBlock | Declaration | Comment)*
# VerbatimBlock             ::= OneLiner | ResetBlock | HelpBlock
# OneLiner                  ::= ('#if' | '#else[if]' | '#endif' | '#let' | '#unlet[!]' | '#call[!]') '[^\r\n]*'
# ResetBlock                ::= 'reset' '.*' 'endreset'
# HelpBlock                 ::= 'help' '.*' 'endhelp'
# Declaration               ::= [Directive | HiGroupDef]
# Comment                   ::= ';' '[^\r\n]*'

# Directive                 ::= ColorDef | Key ':' DirectiveValue
# Key                       ::= 'Include' | 'Full name' | 'Short name' | 'Author' | 'Background' | ...
# DirectiveValue            ::= '[^\r\n]+'

# ColorDef                  ::= 'Color' ':' ColorName GUIValue Base256Value [Base16Value]
# ColorName                 ::= '[A-Za-z][A-Za-z0-9_]*'
# GUIValue                  ::= HexValue | RGBValue
# HexValue                  ::= '#[A-Fa-f0-9]{6}'
# RGBValue                  ::= 'rgb' '(' Num256 ',' Num256 ',' Num256 ')'
# Base256Value              ::= '~' | Num256
# Num256                    ::= '0' | '1' | ... | '255'
# Base16Value               ::= '0' | '1' | ... | '15' | 'Black' | 'DarkRed' | ...

# HiGroupDecl               ::= ^HiGroupName (HiGroupDef HiGroupVersion* | HiGroupVersion+)
# HiGroupVersion            ::= HiGroupVariant | HiGroupDiscr
# HiGroupVariant            ::= ('/' Variant)+ (HiGroupDiscr | HiGroupDef)
# HiGroupDiscr              ::= ('+' | '-') DiscrName (DiscrValue HiGroupDef)+
# DiscrName                 ::= '[A-z_0-9]+'
# DiscrValue                ::= '[0-9]+ | ''' .+ ''' | true | false
# Variant                   ::= 'gui' | '256' | '88' | '16' | '8' | '0' | 'bw'
# HiGroupDef                ::= '->' HiGroupName | BaseGroup
# BaseGroup                 ::= FgColor BgColor Attributes?
# HiGroupName               ::= '[A-z][A-z0-9]*'
# FgColor                   ::= ColorName
# BgColor                   ::= ColorName
# Attributes                ::= Attribute (',' Attribute)* | SpecialColor
# Attribute                 ::= 'bold | 'italic' | ...
# SpecialColor              ::= 's' '=' ColorName
# }}}

