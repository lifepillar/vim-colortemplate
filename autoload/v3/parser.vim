vim9script

import 'libcolor.vim'      as libcol
import 'libparser.vim'     as parser
import 'libpath.vim'       as path
import './colorscheme.vim' as themes

# Aliases {{{
const Approximate         = libcol.Approximate
const RgbName2Hex         = libcol.RgbName2Hex
const Rgb2Hex             = libcol.Rgb2Hex
const Xterm2Hex           = libcol.Xterm2Hex
const ColorDifferenceHex  = libcol.ColorDifferenceHex
const Apply               = parser.Apply
const Bol                 = parser.Bol
const Context             = parser.Context
const Eof                 = parser.Eof
const Lab                 = parser.Lab
const LookAhead           = parser.LookAhead
const Many                = parser.Many
const Map                 = parser.Map
const OneOf               = parser.OneOf
const OneOrMore           = parser.OneOrMore
const Opt                 = parser.Opt
const Result              = parser.Result
const Seq                 = parser.Seq
const Skip                = parser.Skip
const SpaceOrComment      = parser.Regex('\%([ \n\t\r]*\%(;[^\n\r]*\)\=\)*')
const Regex               = parser.Regex
const R                   = parser.RegexToken(SpaceOrComment)
const T                   = parser.TextToken(SpaceOrComment)
const Colorscheme         = themes.Colorscheme
const Database            = themes.Database
const DEFAULT_DISCR_VALUE = themes.DEFAULT_DISCR_VALUE
# }}}

# Semantic actions {{{
def ResetState(state: dict<any>)
  const theme: Colorscheme = state.theme
  state.variants           = theme.variants
  state.discrName          = ''
  state.discrValue         = DEFAULT_DISCR_VALUE
  state.isDefault          = true
enddef

def SetActiveDatabases(v: list<string>, ctx: Context)
  const bg                 = v[2]
  const state              = ctx.state
  var   theme: Colorscheme = state.theme

  ResetState(state)

  if bg == 'dark'
    state.active_db         = [theme.dark]
    theme.backgrounds.dark  = true
  elseif bg == 'light'
    state.active_db         = [theme.light]
    theme.backgrounds.light = true
  elseif bg == 'any'
    state.active_db         = [theme.dark, theme.light]
    theme.backgrounds.dark  = true
    theme.backgrounds.light = true
  else
    throw printf(
      "Invalid background: %s. Valid values are 'dark', 'light' and 'any'.", bg
    )
  endif
enddef

def ActiveDatabases(state: dict<any>): list<Database>
  if empty(state.active_db)
    throw "Missing 'Background' directive: please set the background first"
  endif

  return state.active_db
enddef

def SetOption(v: list<string>, ctx: Context)
  const key: string      = v[0]
  const val: string      = v[2]
  var theme: Colorscheme = ctx.state.theme

  if theme.options->has_key(key)
    if val == 'true'
      theme.options[key] = true
    elseif val == 'false'
      theme.options[key] = false
    elseif val =~ '^\d\+$'
      theme.options[key] = str2nr(val)
    else
      theme.options[key] = val
    endif
  else
    throw printf("Invalid option name: '%s'. Valid options: %s", key, keys(theme.options))
  endif
enddef

def CheckEmpty(name: string, value: any)
  if !empty(value)
    throw printf('%s already defined (%s)', name, value)
  endif
enddef

def SetSupportedVariants(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  theme.variants = ['gui'] + v
  theme.variants->sort()->uniq()
enddef

def SetFullName(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  CheckEmpty('Full name', theme.fullname)
  theme.fullname = v[3]
enddef

def SetShortName(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  CheckEmpty('Short name', theme.shortname)
  theme.shortname = v[3]
enddef

def SetLicense(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  CheckEmpty('License', theme.license)
  theme.license = v[2]
enddef

def SetAuthor(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  theme.author->add(v[2])
enddef

def SetMaintainer(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  theme.maintainer->add(v[2])
enddef

def SetDescription(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  theme.description->add(v[2])
enddef

def SetVersion(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  CheckEmpty('Version', theme.version)
  theme.version = v[2]
enddef

def SetOptionsPrefix(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  CheckEmpty('Options prefix', theme.prefix)
  theme.prefix = v[2]
enddef

def SetURL(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  theme.url->add(v[2])
enddef

def SetTermColors(v: list<string>, ctx: Context)
  for db in ActiveDatabases(ctx.state)
    for colorName in v
      const t = db.Color.Lookup(['ColorName'], [colorName])

      if empty(t)
        throw printf(
          "Invalid color name: %s (%s background)", colorName, db.background
        )
      endif

      db.termcolors->add(t.GUIValue)
    endfor
  endfor
enddef

def ToHexColor(v: list<string>, ctx: Context): string
  const r = str2nr(v[2])
  const g = str2nr(v[4])
  const b = str2nr(v[6])

  if r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255
    throw printf('Invalid RGB values: (%d, %d, %d)', r, g, b)
  endif

  return Rgb2Hex(r, g, b)
enddef

def DefineColor(v: list<string>, ctx: Context)
  const colorName: string = v[2]
  const vGui:      string = v[3]
  const vGuiHex:   string = vGui[0] == '#' ? vGui : RgbName2Hex(vGui)
  const v16:       string = v[5]
  var   v256:      string
  var   v256Hex:   string
  var   delta:     float

  if v[4] == '~'
    const approxColor: dict<any> = Approximate(vGuiHex)
    v256    = string(approxColor.xterm)
    v256Hex = approxColor.hex
    delta   = approxColor.delta
  else
    v256 = v[4]
    v256Hex = Xterm2Hex(str2nr(v256))
    delta = ColorDifferenceHex(vGuiHex, v256Hex)
  endif

  for db in ActiveDatabases(ctx.state)
    db.Color.Insert({
      ColorName:       colorName,
      GUIValue:        vGui,
      Base256Value:    v256,
      Base256HexValue: v256Hex,
      Base16Value:     v16,
      Delta:           delta,
    })
  endfor
enddef

def DefineDiscriminator(v: list<string>, ctx: Context)
  const discrName:  string = v[1]
  const definition: string = v[3]

  for db in ActiveDatabases(ctx.state)
    db.Discriminator.Insert({
      DiscrName:  discrName,
      Definition: definition,
    })
  endfor
enddef

def SetHiGroupName(v: list<string>, ctx: Context)
  const state   = ctx.state
  const hiGroup = v[0]
  ResetState(state)
  state.hiGroupName = hiGroup
enddef

def SetVariants(v: list<any>, ctx: Context)
  const state                  = ctx.state
  const variants: list<string> = flattennew(v)
  state.variants = variants
  state.isDefault = false
enddef

def SetDiscrName(v: list<string>, ctx: Context)
  const discrName = v[1]
  const state     = ctx.state
  state.discrName = discrName
  state.isDefault = false

  for db in ActiveDatabases(state)
    const t = db.HiGroup.Lookup(['HiGroupName'], [state.hiGroupName])

    if empty(t)
      throw printf(
        "Missing default definition for highlight group '%s' (%s background)",
        state.hiGroupName, db.background
      )
    endif

    if empty(t.DiscrName)  # First override: set the discriminator's name
      db.HiGroup.Update({
        HiGroupName: t.HiGroupName,
        DiscrName:   discrName,
        IsLinked:    t.IsLinked,
      })
    elseif t.DiscrName != discrName
      throw printf(
        "Inconsistent discriminator name '%s': '%s' already uses '%s' (%s background)",
        discrName, state.hiGroupName, t.DiscrName, db.background
      )
    endif
  endfor
enddef

def SetDiscrValue(discrValue: string, ctx: Context)
  ctx.state.discrValue = discrValue
enddef

def DefineLinkedGroup(v: list<string>, ctx: Context)
  const state           = ctx.state
  const hiGroupName     = state.hiGroupName
  const targetGroup     = v[1]

  for db in ActiveDatabases(state)
    if state.isDefault
      db.InsertDefaultLinkedGroup(hiGroupName, targetGroup)
    else
      for variant in state.variants
        db.InsertLinkedGroupOverride(variant, state.discrValue, hiGroupName, targetGroup)
      endfor
    endif
  endfor
enddef

def CheckColorName(colorName: string, ctx: Context): string
  if !empty(colorName)
    for db in ActiveDatabases(ctx.state)
      if empty(db.Color.Lookup(['ColorName'], [colorName]))
        throw printf(
          "Undefined color name: '%s' (%s background)",
          colorName, db.background
        )
      endif
    endfor
  endif

  return colorName
enddef

def DefineBaseGroup(v: list<any>, ctx: Context)
  const state       = ctx.state
  const hiGroupName = state.hiGroupName
  const fgColor     = v[0]
  const bgColor     = v[1]
  const spColor     = empty(v[2]) ? 'none' : v[2]
  const attributes  = empty(v[3]) ? 'NONE' : join(sort(v[3]), ',')

  for db in ActiveDatabases(state)
    if state.isDefault
      db.InsertDefaultBaseGroup(
        hiGroupName,
        fgColor, bgColor, spColor, attributes, '', '', ''
      )
    else
      for variant in state.variants
        db.InsertBaseGroupOverride(
          variant, state.discrValue, hiGroupName,
          fgColor, bgColor, spColor, attributes, '', '', ''
        )
      endfor
    endif
  endfor
enddef

def FindReplacement(placeholder: string, ctx: Context): string
  if placeholder == '@date'
    return strftime("%Y %b %d")
  elseif placeholder == '@vimversion'
    return string(v:version / 100)
  endif

  const state = ctx.state
  const theme: Colorscheme = state.theme

  if placeholder == '@shortname'
    return theme.shortname
  elseif placeholder == '@fullname'
    return theme.fullname
  elseif placeholder == '@version'
    return theme.version
  elseif placeholder == '@license'
    return theme.license
  elseif placeholder == '@prefix'
    return empty(theme.prefix) ? theme.shortname : theme.prefix
  endif

  const directive = matchlist(placeholder, '^@\(author\|maintainer\|url\|description\)\(\d\+\)\=$')

  if !empty(directive)
    const key = directive[1]
    const num = empty(directive[2]) ? 0 : str2nr(directive[2]) - 1

    if num < 0
      return ''
    endif

    if key == 'author'
      return theme.author[num]
    elseif key == 'maintainer'
      return theme.maintainer[num]
    elseif key == 'url'
      return theme.url[num]
    elseif key == 'description'
      return theme.description[num]
    endif
  endif

  # The following replacements make sense only if the background is unambiguous
  if len(state.active_db) != 1
    return ''
  endif

  const db: Database = state.active_db[0]

  if placeholder == '@background'
    return db.background
  endif

  const colorPlaceholder = matchlist(placeholder, '^@\(16\|256\|gui\)\?\(\w\+\)$')

  if empty(colorPlaceholder)
    return ''
  endif

  const kind = colorPlaceholder[1]
  const name = colorPlaceholder[2]

  return db.GetColor(name, kind)
enddef

def CollectPlaceholders(text: string): dict<bool>
  var placeholders: dict<bool> = {}
  var i = 0

  while true
    const [atString, _, endpos] = matchstrpos(text, '@\%(prefix\|shortname\|\w\+\>\)', i)
    if empty(atString)
      break
    endif
    placeholders[atString] = true
    i = endpos
  endwhile

  return placeholders
enddef

def Interpolate(text: string, ctx: Context): list<string>
  var placeholders = CollectPlaceholders(text)
  var newtext      = text

  for placeholder in keys(placeholders)
    const replacement = FindReplacement(placeholder, ctx)
    if !empty(replacement)
      newtext = substitute(newtext, placeholder, replacement, 'g')
    endif
  endfor

  return split(newtext, "\n")
enddef

def GetVerbatim(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  theme.verbatimtext = theme.verbatimtext + Interpolate(v[1], ctx)
enddef

def GetAuxFile(v: list<string>, ctx: Context)
  const auxPath: string = Interpolate(v[1], ctx)[0]
  var theme: Colorscheme = ctx.state.theme

  if !theme.auxfiles->has_key(auxPath)
    theme.auxfiles[auxPath] = []
  endif

  theme.auxfiles[auxPath] += Interpolate(v[2], ctx)
enddef

def GetHelpFile(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme

  if empty(theme.shortname)
    throw 'Please define the short name of the color scheme first'
  endif

  const auxPath = path.Join('doc', theme.shortname .. '.txt')

  GetAuxFile([v[0], auxPath, v[1]], ctx)
enddef
# }}}

# Parser {{{
def RefInclude(name: string): func(list<string>, Context)
  return (v: list<string>, ctx: Context) => {
    eval(name)(v, ctx)
  }
enddef

const K_AUTHOR      = T('Author')
const K_AUXFILE     = T('auxfile')
const K_BACKGROUND  = T('Background')
const K_COLOR       = T('Color')
const K_COLORS      = R('[Cc]olors')
const K_CONST       = T('#const')
const K_DESCRIPTION = T('Description')
const K_ENDAUXFILE  = T('endauxfile')
const K_ENDHELPFILE = T('endhelpfile')
const K_ENDVERBATIM = T('endverbatim')
const K_FULL        = T('Full')
const K_HELPFILE    = T('helpfile')
const K_INCLUDE     = T('Include')
const K_LICENSE     = T('License')
const K_MAINTAINER  = T('Maintainer')
const K_NAME        = R('[Nn]ame')
const K_OPTIONS     = T('Options')
const K_OPTN        = R('\%(backend\|creator\|tabs\|shiftwidth\)\>')
const K_OPTV        = R('\%(true\|false\)\>\|\d\+\|\w\+')
const K_PREFIX      = T('Prefix')
const K_RGB         = R('rgb\>')
const K_SHORT       = T('Short')
const K_SPECIAL     = R('s\|sp\>')
const K_TERM        = R('Term\%[inal\]')
const K_URL         = R('URL')
const K_VARIANT     = R('\(gui\|256\|88\|16\|8\|0\)\>')
const K_VARIANTS    = T('Variants')
const K_VERBATIM    = Regex('verbatim')
const K_VERSION     = T('Version')

const BAR           = T('/')
const COLON         = T(':')
const COMMA         = T(',')
const EQ            = T('=')
const LPAREN        = T('(')
const RPAREN        = T(')')
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
const BACKGROUND    = R('dark\>\|light\|any\>')
const HEXCOL        = R('#[A-Fa-f0-9]\{6}')
const GUICOL        = OneOf(HEXCOL, IDENTIFIER)
const STRING        = R('"[^"]*"')
const TEXTLINE      = R('[^\r\n]\+')
const THEMENAME     = R('\w\+')
const VERBTEXT      = R('\_.\{-}\ze\%(end\%(verbatim\|help\|auxfile\)\)')

const L_ATTRIBUTE   = Lab(ATTRIBUTE,            "Expected an attribute")
const L_BACKGROUND  = Lab(BACKGROUND,           "Expected a valid background ('light' or 'dark')")
const L_BGCOLOR     = Lab(BGCOLOR,              "Expected the name of the background color")
const L_COL256      = Lab(OneOf(TILDE, NUM256), "Expected a 256-color value or tilde")
const L_COLON       = Lab(COLON,                "Expected a colon")
const L_COLORNAME   = Lab(COLORNAME,            "Expected a color name")
const L_COLORS      = Lab(K_COLORS,             "Expected keyword 'Colors'")
const L_COMMA       = Lab(COMMA,                "Expected a comma")
const L_DISCRNAME   = Lab(DISCRNAME,            "Expected an identifier")
const L_ENDAUXFILE  = Lab(K_ENDAUXFILE,         "Expected keyword 'endauxfile'")
const L_ENDHELPFILE = Lab(K_ENDHELPFILE,        "Expected keyword 'endhelpfile'")
const L_ENDVERBATIM = Lab(K_ENDVERBATIM,        "Expected keyword 'endverbatim'")
const L_EQ          = Lab(EQ,                   "Expected an equal sign")
const L_HIGROUPNAME = Lab(HIGROUPNAME,          "Expected the name of a highlight group")
const L_IDENTIFIER  = Lab(IDENTIFIER,           "Expected an identifier")
const L_LPAREN      = Lab(LPAREN,               "Expected open parenthesis")
const L_NAME        = Lab(K_NAME,               "Expected 'Name'")
const L_NUM256      = Lab(NUM256,               "Expected a number")
const L_OPTV        = Lab(K_OPTV,               "Expected a valid option value")
const L_PATH        = Lab(TEXTLINE,             "Expected a relative path")
const L_RPAREN      = Lab(RPAREN,               "Expected closed parenthesis")
const L_SPCOLOR     = Lab(COLORNAME,            "Expected the name of the special color")
const L_TEXTLINE    = Lab(TEXTLINE,             "Expected the value of the directive (which cannot be empty)")
const L_THEMENAME   = Lab(THEMENAME,            "Expected a valid color scheme's name")
const L_VARIANT     = Lab(K_VARIANT,            "Expected a variant (gui, 256, 88, 16, 8, or 0)")
const L_VERBTEXT    = Lab(VERBTEXT,             "Expected end of verbatim block")

const AuxFile       = OneOf(
                        Seq(
                          K_AUXFILE,
                          L_PATH,
                          L_VERBTEXT,
                          L_ENDAUXFILE
                        )                                           ->Apply(GetAuxFile),
                        Seq(
                          K_HELPFILE,
                          L_VERBTEXT,
                          L_ENDHELPFILE
                        )                                           ->Apply(GetHelpFile)
                      )

const VerbatimBlock = Seq(
                        K_VERBATIM,
                        L_VERBTEXT,
                        L_ENDVERBATIM
                      )                                             ->Apply(GetVerbatim)

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

const OptionsList   = Lab(
                        OneOrMore(
                          Seq(K_OPTN, L_EQ, L_OPTV)                 ->Apply(SetOption)
                        ),
                        'Expected a Colortemplate option'
                      )

const VariantList   = Lab(
                        OneOrMore(K_VARIANT),
                        "Expected one of: gui, 256, 88, 16, 8, 0"
                      )                                             ->Apply(SetSupportedVariants)

const Prefix        = Seq(K_PREFIX,         L_COLON, L_IDENTIFIER)  ->Apply(SetOptionsPrefix)
const Options       = Seq(K_OPTIONS,        L_COLON, OptionsList)
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
const Background    = Seq(K_BACKGROUND,     L_COLON, L_BACKGROUND)  ->Apply(SetActiveDatabases)
const Include       = Seq(K_INCLUDE,        L_COLON, L_PATH)        ->Apply(RefInclude('ParseInclude'))
const RgbColor      = Seq(
                        K_RGB,
                        L_LPAREN,
                        L_NUM256,
                        L_COMMA,
                        L_NUM256,
                        L_COMMA,
                        L_NUM256,
                        L_RPAREN)                                   ->Map(ToHexColor)
const GuiColor      = Lab(
                        OneOf(RgbColor, GUICOL),
                        "Expected a valid GUI color definition"
                      )
const ColorDef      = Seq(
                        K_COLOR,
                        L_COLON,
                        L_COLORNAME,
                        GuiColor,
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
                          Version,
                          Options,
                          Prefix
                        ), 'Expected a valid metadata directive')
                      )

const Statement     = Seq(
                        K_CONST,
                        L_IDENTIFIER,
                        L_EQ,
                        L_TEXTLINE
                      )                                            ->Apply(DefineDiscriminator)

const Declaration   = OneOf(Statement, VerbatimBlock, AuxFile, Directive, HiGroupDecl)
const Template      = Seq(
                        Skip(SpaceOrComment),
                        Many(Declaration),
                        Lab(Eof, "Unexpected token")
                      )
# }}}

# Main {{{
class ColortemplateContext extends Context
  def new(this.text, basedir = '')
    this.state.basedir     = basedir
    this.state.theme       = Colorscheme.new()
    this.state.active_db   = []
    this.state.hiGroupName = ''
    this.state.isDefault   = true
    this.state.variants    = ['gui']
    this.state.discrName   = ''
    this.state.discrValue  = DEFAULT_DISCR_VALUE
  enddef
endclass

export def Parse(
    text: string,
    basedir = '',
    Parser: func(Context): Result = Template,
    context: Context = ColortemplateContext.new(text, basedir)
): list<any>
  var   ctx                = context
  const result: Result     = Parser(ctx)
  const theme: Colorscheme = ctx.state.theme

  return [result, theme]
enddef

def ParseInclude(v: list<string>, ctx: Context)
  if !path.IsRelative(v[2])
    throw printf(
      "Include path must be a relative path. Got '%s'", v[2]
    )
  endif

  const state       = ctx.state
  const oldBasedir  = state.basedir
  const includePath = path.Expand(v[2], state.basedir)
  const text        = join(readfile(includePath), "\n")
  var   newCtx      = ColortemplateContext.new(text)

  newCtx.state = deepcopy(state)
  newCtx.state.basedir = path.Parent(includePath)

  const [result: Result, theme: Colorscheme] = Parse(text, null_string, Template, newCtx)

  if !result.success
    throw printf("in %s, byte %d: %s", includePath, result.errpos, result.label)
  endif

  ctx.state = newCtx.state
  ctx.state.basedir = oldBasedir
enddef
# }}}

# Colortemplate's grammar {{{
# Template        ::= Declaration*
# Declaration     ::= Statement | VerbatimBlock | Auxfile |  Directive | HiGroupDecl
# Statement       ::= '#const' IDENT = TEXTLINE
# VerbatimBlock   ::= 'verbatim' TEXT 'endverbatim'
# Auxfile         ::= 'auxfile' PATH TEXT 'endauxfile' | 'helpfile' TEXT 'endhelpfile'

# Directive       ::= ColorDef | Include    | Background | Author     | Description |
#                              | Fullname   | License    | Maintainer | Shortname   |
#                              | Termcolors | URL        | Variants   | Version     |
#                              | Options    | Prefix

# Author          ::= 'Author'        ':' TEXTLINE
# Background      ::= 'Background'    ':' ('dark' | 'light')
# Description     ::= 'Description'   ':' TEXTLINE
# Fullname        ::= 'Full' 'name'   ':' TEXTLINE
# Include         ::= 'Include'       ':' PATH
# License         ::= 'License'       ':' TEXTLINE
# Maintainer      ::= 'Maintainer'    ':' TEXTLINE
# Options         ::= 'Options'       ':' (OPTNAME '=' OPTVALUE)+
# Prefix          ::= 'Prefix'        ':' IDENT
# Shortname       ::= 'Short' 'name'  ':' IDENT
# TermColors      ::= 'Term' 'colors' ':' IDENT{16}
# URL             ::= 'URL'           ':' TEXTLINE
# Variants        ::= 'Variants'      ':' VARIANT+
# Version         ::= 'Version'       ':' TEXTLINE

# ColorDef        ::= 'Color' ':' IDENT GUICol Col256 [Col16]
# GUICol          ::= '#[A-Fa-f0-9]{6}' | IDENT
# Col256          ::= '~' | Num256
# Num256          ::= '0' | '1' | ... | '255'
# Col16           ::= '0' | '1' | ... | '15' | IDENT

# HiGroupDecl     ::= ^HiGroupName HiGroupRest
# HiGroupRest     ::= HiGroupDef HiGroupVersion* | HiGroupVersion+
# HiGroupVersion  ::= HiGroupVariant | DiscrDef
# HiGroupVariant  ::= ('/' VARIANT)+ (DiscrDef | HiGroupDef)
# DiscrDef        ::= '+' IDENT DiscrRest
# DiscrRest       ::= (DiscrValue HiGroupDef)+
# DiscrValue      ::= NUMBER | STRING | TRUE | FALSE
# HiGroupDef      ::= LinkedGroup | BaseGroup
# LinkedGroup     ::= '->' IDENT
# BaseGroup       ::= IDENT IDENT SpecialColor? Attributes?
# SpecialColor    ::= 's' '=' IDENT
# Attributes      ::= ATTRIBUTE (',' ATTRIBUTE)*
# }}}

