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

# Main {{{
const DEFAULT_DISCR_VALUE = colorscheme.DEFAULT_DISCR_VALUE

def GetDatabase(ctx: Context): func(): Database
  const state = ctx.state

  return (): Database => {
    if empty(state.background)
      throw 'Please set the background first'
    endif
    return state[state.background]
  }
enddef

export def Parse(text: string, Parser: func(Context): Result = Template): dict<any>
  var ctx                          = Context.new(text)
  ctx.state.meta                   = Metadata.new()
  ctx.state.dark                   = Database.new('dark')
  ctx.state.light                  = Database.new('light')
  ctx.state.background             = ''
  ctx.state.Db                     = GetDatabase(ctx)
  ctx.state.hiGroupName            = ''
  ctx.state.isDefault              = true
  ctx.state.variants               = []
  ctx.state.discrName              = ''
  ctx.state.discrValue             = DEFAULT_DISCR_VALUE
  ctx.state.Reset                  = () => {
    const state          = ctx.state
    const meta: Metadata = state.meta
    state.variants       = meta.variants
    state.discrName      = ''
    state.discrValue     = DEFAULT_DISCR_VALUE
    state.isDefault      = true
  }

  const result = Parser(ctx)

  if !result.success
    echo strcharpart(text, 0, 1 + result.errpos) .. '<==='

    if !empty(result.label)
      echo result.label
    endif
  endif

  const meta:  Metadata = ctx.state.meta
  const dark:  Database = ctx.state.dark
  const light: Database = ctx.state.light

  return {result: result, meta: meta, dark: dark, light: light}
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
# Variant                   ::= 'gui' | 'termgui' | '256' | '88' | '16' | '8' | '0' | 'bw'
# HiGroupDef                ::= '->' HiGroupName | BaseGroup
# BaseGroup                 ::= FgColor BgColor Attributes?
# HiGroupName               ::= '[A-z][A-z0-9]*'
# FgColor                   ::= ColorName
# BgColor                   ::= ColorName
# Attributes                ::= Attribute (',' Attribute)* | SpecialColor
# Attribute                 ::= 'bold | 'italic' | ...
# SpecialColor              ::= 's' '=' ColorName
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

def SetSupportedVariants(v: list<string>, ctx: Context)
  var meta: Metadata = ctx.state.meta
  if !empty(meta.variants)
    throw printf(
      "Supported variants already defined ('%s')", meta.variants
    )
  endif
  meta.variants = v
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
  const v256:      number   = str2nr(v[4])  # FIXME: convert ~
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

  for variant in meta.variants
    const t = dbase.Variant.Lookup(['Variant'], [variant])

    if t.NumColors == 0
      continue
    endif

    const value = t.NumColors <= 16 ? v16 : t.NumColors <= 256 ? string(v256) : vGUI

    dbase.ColorVariant.Insert({
      ColorName:  colorName,
      Variant:    variant,
      ColorValue: value,
    })
  endfor
enddef

def SetHiGroupName(v: list<string>, ctx: Context)
  const state          = ctx.state
  const meta: Metadata = state.meta
  const hiGroup = v[0]
  state.Reset()
  state.hiGroupName = hiGroup

  const dbase: Database = state.Db()
  try
    dbase.HiGroup.Insert({
      HiGroupName: hiGroup,
      DiscrName: '',
    })
  catch /Duplicate/
  endtry
enddef

def SetVariants(v: list<any>, ctx: Context)
  const state                  = ctx.state
  const meta: Metadata         = state.meta
  const variants: list<string> = flattennew(v)

  for variant in variants
    if index(meta.variants, variant) == -1
      throw printf(
        "'%s' is not among the supported variants: %s", variant, meta.variants
      )
    endif
  endfor
  state.variants = variants
  state.isDefault = false
enddef

def SetDiscrName(v: list<string>, ctx: Context)
  const state           = ctx.state
  const dbase: Database = state.Db()
  const discrName       = v[1]
  const hiGroup         = state.hiGroupName
  const t               = dbase.HiGroup.Lookup(['HiGroupName'], [hiGroup])

  if empty(t)  # This should never happen
    throw printf(
      "Highlight group '%s' not in database: please report this bug", hiGroup
    )
  endif

  if empty(t.DiscrName)
    dbase.HiGroup.Update({HiGroupName: hiGroup, DiscrName: discrName})
  elseif t.DiscrName != discrName
    throw printf(
      "Inconsistent discriminator: '%s' ('%s' already uses '%s')", discrName, hiGroup, t.DiscrName
    )
  endif
  state.discrName = discrName
  state.isDefault = false
enddef

def SetDiscrValue(discrValue: string, ctx: Context)
  ctx.state.discrValue = discrValue
enddef

def DefineLinkedGroup(v: list<string>, ctx: Context)
  if ctx.state.isDefault
    DefineDefaultLinkedGroup(v, ctx)
  else
    DefineNonDefaultLinkedGroup(v, ctx)
  endif
enddef

def DefineDefaultLinkedGroup(v: list<string>, ctx: Context)
  const state           = ctx.state
  const dbase: Database = state.Db()
  const targetGroup     = v[1]
  const hiGroup         = state.hiGroupName
  const discriminator   = state.discrValue

  for variant in state.variants
    const t = dbase.HiGroupVersion.Lookup(
      ['HiGroupName', 'Variant', 'DiscrValue'],
      [hiGroup, variant, discriminator]
    )

    if empty(t)
      InsertLinkedGroup(dbase, hiGroup, variant, discriminator, targetGroup, true)
    elseif t.IsDefault
      throw printf(
        "A default definition already exists for '%s'", hiGroup
      )
    endif
  endfor
enddef

def DefineNonDefaultLinkedGroup(v: list<string>, ctx: Context)
  const state           = ctx.state
  const dbase: Database = state.Db()
  const targetGroup     = v[1]
  const hiGroup         = state.hiGroupName
  const discriminator   = state.discrValue

  for variant in state.variants
    const t = dbase.HiGroupVersion.Lookup(
      ['HiGroupName', 'Variant', 'DiscrValue'],
      [hiGroup, variant, discriminator]
    )

    if !empty(t)
      if t.IsDefault
        DeleteHiGroupVersion(dbase, hiGroup, variant, discriminator)
      else
        const discrPhrase = empty(discriminator) ? '' : printf(" and discriminator '%s'", discriminator)
        throw printf(
          "An override for variant '%s'%s already exists for '%s'", variant, discrPhrase, hiGroup
        )
      endif
    endif

    InsertLinkedGroup(dbase, hiGroup, variant, discriminator, targetGroup, false)
  endfor
enddef

def InsertLinkedGroup(
    dbase:         Database,
    hiGroup:       string,
    variant:       string,
    discriminator: string,
    targetGroup:   string,
    default:       bool
)
  dbase.HiGroupVersion.Insert({
    HiGroupName: hiGroup,
    Variant:     variant,
    DiscrValue:  discriminator,
    IsLinked:    true,
    IsDefault:   default,
  })
  dbase.LinkedGroup.Insert({
    HiGroupName: hiGroup,
    Variant:     variant,
    DiscrValue:  discriminator,
    TargetGroup: targetGroup,
  })
enddef

def DefineBaseGroup(v: list<any>, ctx: Context)
  if ctx.state.isDefault
    DefineDefaultBaseGroup(v, ctx)
  else
    DefineNonDefaultBaseGroup(v, ctx)
  endif
enddef

def DefineDefaultBaseGroup(v: list<any>, ctx: Context)
  const state           = ctx.state
  const dbase: Database = state.Db()
  const hiGroup         = state.hiGroupName
  const discriminator   = state.discrValue

  for variant in state.variants
    const t = dbase.HiGroupVersion.Lookup(
      ['HiGroupName', 'Variant', 'DiscrValue'],
      [hiGroup, variant, discriminator]
    )

    if empty(t)
      InsertBaseGroup(dbase, hiGroup, variant, discriminator, v[0], v[1], v[2], v[3], true)
    elseif t.IsDefault
      throw printf(
        "A default definition already exists for '%s'", hiGroup
      )
    endif
  endfor
enddef

def DefineNonDefaultBaseGroup(v: list<any>, ctx: Context)
  const state           = ctx.state
  const dbase: Database = state.Db()
  const hiGroup         = state.hiGroupName
  const discriminator   = state.discrValue

  for variant in state.variants
    const t = dbase.HiGroupVersion.Lookup(
      ['HiGroupName', 'Variant', 'DiscrValue'],
      [hiGroup, variant, discriminator]
    )

    if !empty(t)
      if t.IsDefault
        DeleteHiGroupVersion(dbase, hiGroup, variant, discriminator)
      else
        const discrPhrase = empty(discriminator) ? '' : printf(" and discriminator '%s'", discriminator)
        throw printf(
          "An override of '%s' for variant '%s'%s already exists", hiGroup, variant, discrPhrase
        )
      endif
    endif
    InsertBaseGroup(dbase, hiGroup, variant, discriminator, v[0], v[1], v[2], v[3], false)
  endfor
enddef

def InsertBaseGroup(
    dbase:         Database,
    hiGroup:       string,
    variant:       string,
    discriminator: string,
    fg:            string,
    bg:            string,
    sp:            string,
    attrs:         any,
    default:       bool
)
  const colorMap: dict<string> = {'fg': fg, 'bg': bg, 'sp': sp}
  const style                  = empty(attrs) ? 'NONE' : join(sort(attrs), ',')

  dbase.HiGroupVersion.Insert({
    HiGroupName: hiGroup,
    Variant:     variant,
    DiscrValue:  discriminator,
    IsLinked:    false,
    IsDefault:   default,
  })

  dbase.BaseGroup.Insert({
    HiGroupName: hiGroup,
    Variant:     variant,
    DiscrValue:  discriminator,
  })

  for colorType in keys(colorMap)
    const colorName = colorMap[colorType]

    if !empty(colorName) && colorName != 'omit'
      const t = dbase.VariantAttribute.Lookup(['Variant', 'AttrType'], [variant, colorType])

      if !empty(t)
        dbase.ColorAttribute.Insert({
          HiGroupName: hiGroup,
          Variant:     variant,
          DiscrValue:  discriminator,
          ColorKey:    t.AttrKey,
          ColorName:   colorName,
        })
      endif
    endif
  endfor

  const t = dbase.VariantAttribute.Lookup(['Variant', 'AttrType'], [variant, 'style'])

  if !empty(t)
    dbase.Attribute.Insert({
      HiGroupName: hiGroup,
      Variant:     variant,
      DiscrValue:  discriminator,
      AttrKey:     t.AttrKey,
      AttrValue:   style,
    })
  endif
enddef

def DeleteHiGroupVersion(
    dbase: Database,
    hiGroup: string,
    variant: string,
    discriminator: string
)
  const Pred = (t) => t.HiGroupName == hiGroup && t.Variant == variant && t.DiscrValue == discriminator
  dbase.ColorAttribute.Delete(Pred)
  dbase.Attribute.Delete(Pred)
  dbase.BaseGroup.Delete(Pred)
  dbase.LinkedGroup.Delete(Pred)
  dbase.HiGroupVersion.Delete(Pred)
enddef
# }}}

# Parser {{{
# FIXME: Include

const K_AUTHOR      = T('Author')
const K_BACKGROUND  = T('Background')
const K_COLOR       = T('Color')
const K_COLORS      = R('[Cc]olors')
const K_DESCRIPTION = T('Description')
const K_FULL        = T('Full')
const K_INCLUDE     = T('Include')
const K_LICENSE     = T('License')
const K_MAINTAINER  = T('Maintainer')
const K_NAME        = R('[Nn]ame')
const K_SHORT       = T('Short')
const K_SPECIAL     = R('s\|sp\>')
const K_TERM        = R('Term\%[inal\]')
const K_URL         = R('URL\|Website')
const K_VARIANT     = R('\(gui\|termgui\|256\|88\|16\|8\|bw\|0\)\>')
const K_VARIANTS    = T('Variants')
const K_VERSION     = T('Version')

const BAR           = T('/')
const COLON         = T(':')
const COMMA         = T(',')
const EQ            = T('=')
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
const COL16         = R('\%(\d\+\)\|\w\+\|omit') # FIXME: match only colors from g:colortemplate#colorspace#ansi_colors
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
const L_DISCRNAME   = Lab(DISCRNAME,            "Expected an identifier")
const L_EQ          = Lab(EQ,                   "Expected an equal sign")
const L_HEXCOL      = Lab(HEXCOL,               "Expected a hex color value")
const L_HIGROUPNAME = Lab(HIGROUPNAME,          "Expected the name of a highlight group")
const L_NAME        = Lab(K_NAME,               "Expected the keyword 'Name'")
const L_PATH        = Lab(TEXTLINE,             "Expected a relative path")
const L_SPCOLOR     = Lab(COLORNAME,            "Expected the name of the special color")
const L_TEXTLINE    = Lab(TEXTLINE,             "Expected the value of the directive (which cannot be empty)")
const L_THEMENAME   = Lab(THEMENAME,            "Expected a valid color scheme's name")
const L_VARIANT     = Lab(K_VARIANT,            "Expected a variant (gui, 256, 16, etc.)")

const Attributes    = Seq(
                        ATTRIBUTE,
                        Many(Seq(Skip(COMMA), L_ATTRIBUTE))
                      )                                             ->Map((v, _) => flattennew(v))
const SpecialColor  = Seq(K_SPECIAL, EQ, L_SPCOLOR)                 ->Map((v, _) => v[2])
const BaseGroup     = Seq(
                        FGCOLOR,
                        L_BGCOLOR,
                        Opt(SpecialColor),
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

const VariantList   = Lab(
                        OneOrMore(K_VARIANT),
                        "Expected one of: gui, 256, 88, 16, 8, bw, 0"
                      )                                             ->Apply(SetSupportedVariants)

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
const Include       = Seq(K_INCLUDE,        L_COLON, L_PATH)        #->Apply(ParseInclude)
const ColorDef      = Seq(
                        K_COLOR,
                        L_COLON,
                        L_COLORNAME,
                        L_HEXCOL,
                        L_COL256,
                        Opt(COL16)
                      )                                            ->Apply(DefineColor)

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

const Declaration   = OneOf(Directive, HiGroupDecl)

const Template      = Seq(
                        Skip(SpaceOrComment),
                        Many(Declaration),
                        Lab(Eof, "Unexpected token")
                      )
# }}}
