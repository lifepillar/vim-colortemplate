vim9script

import 'libcolor.vim'       as libcolor
import 'libparser.vim'      as parser
import 'libpath.vim'        as path
import 'libversion.vim'     as vv
import '../colorscheme.vim' as colorscheme

try
  vv.Require('libcolor',  libcolor.version, '0.0.1-alpha')
  vv.Require('libparser', parser.version,   '0.0.1-alpha')
  vv.Require('libpath',   path.version,     '0.0.1-alpha')
catch /.*/
  echohl Error
  echomsg v:exception
  echohl NONE
endtry

# Aliases {{{
const ANSI_COLORS         = libcolor.ANSI_COLORS
const Approximate         = libcolor.Approximate
const RgbName2Hex         = libcolor.RgbName2Hex
const Rgb2Hex             = libcolor.Rgb2Hex
const ColorNumber2Hex     = libcolor.ColorNumber2Hex
const ColorDifference     = libcolor.ColorDifference

export type  ParserResult = parser.Result
type  Context             = parser.Context
const Apply               = parser.Apply
const Bol                 = parser.Bol
const Eof                 = parser.Eof
const Lab                 = parser.Lab
const LookAhead           = parser.LookAhead
const Many                = parser.Many
const Map                 = parser.Map
const OneOf               = parser.OneOf
const OneOrMore           = parser.OneOrMore
const Opt                 = parser.Opt
const Seq                 = parser.Seq
const Skip                = parser.Skip
const SpaceOrComment      = parser.Regex('\%([ \n\t\r]*\%(;[^\n\r]*\)\=\)*')
const Regex               = parser.Regex
const R                   = parser.RegexToken(SpaceOrComment)
const T                   = parser.TextToken(SpaceOrComment)

type  Colorscheme         = colorscheme.Colorscheme
type  Database            = colorscheme.Database
const KEY_NOT_FOUND       = colorscheme.KEY_NOT_FOUND
# }}}

# Semantic actions {{{
def ResetState(state: dict<any>)
  var theme: Colorscheme = state.theme
  state.environments     = ['default']
  state.discrName        = ''
  state.discrValue       = ''
enddef

def SetActiveDatabases(v: list<string>, ctx: Context)
  var bg                 = v[2]
  var state              = ctx.state
  var theme: Colorscheme = state.theme

  ResetState(state)

  state.background = bg

  if bg == 'any'
    theme.backgrounds.dark  = true
    theme.backgrounds.light = true
  else
    theme.backgrounds[bg] = true
  endif
enddef

def ActiveDatabases(ctx: Context): list<Database>
  var state: dict<any> = ctx.state

  if empty(state.background)
    throw "Missing 'Background' directive: please set the background first"
  endif

  var theme: Colorscheme = state.theme

  if state.background == 'any'
    return [theme.dark, theme.light]
  endif

  return [theme.Db(state.background)]
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
    elseif val =~ '^"'
      theme.options[key] = matchstr(val, '^"\zs[^"]*\ze"')
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

def SetSupportedEnvironments(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  theme.InsertDefaultAttributes(v)
  theme.environments = v
  theme.environments->sort()->uniq()
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
  theme.authors->add(v[2])
enddef

def SetMaintainer(v: list<string>, ctx: Context)
  var theme: Colorscheme = ctx.state.theme
  theme.maintainers->add(v[2])
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
  theme.urls->add(v[2])
enddef

def SetTermColors(v: list<string>, ctx: Context)
  for db in ActiveDatabases(ctx)
    for colorName in v
      var t = db.Color.Lookup(['Name'], [colorName])

      if t is KEY_NOT_FOUND
        throw printf(
          "Invalid color name: %s (%s background)", colorName, db.background
        )
      endif

      db.termcolors->add(colorName)
    endfor
  endfor
enddef

def ToHexColor(v: list<string>, ctx: Context): string
  var r = str2nr(v[2])
  var g = str2nr(v[4])
  var b = str2nr(v[6])

  if r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255
    throw printf('Invalid RGB values: (%d, %d, %d)', r, g, b)
  endif

  return Rgb2Hex(r, g, b)
enddef

# Remove leading and trailing quotes
def Strip(name: string): string
  return substitute(name, '^"\(.\+\)"$', '\1', '')
enddef

def DefineColor(v: list<string>, ctx: Context)
  var colorName: string = v[2]
  var vGui:      string = tolower(v[3])
  var vGuiHex:   string = vGui
  var v16:       string = v[5]
  var v256:      string
  var v256Hex:   string

  # GUI value
  if vGui[0] != '#' # A color name: infer hex value
    vGui = Strip(vGui)

    vGuiHex = RgbName2Hex(vGui)

    if vGui =~ '\s' # Names containing spaces must be quoted
      vGui = $"'{vGui}'"
    endif
  endif

  # Base-256 value
  if v[4] == '~'
    var approxColor: dict<any> = Approximate(vGuiHex)
    v256    = string(approxColor.xterm)
    v256Hex = approxColor.hex
  else
    v256    = v[4]
    v256Hex = ColorNumber2Hex(str2nr(v256))
  endif

  # Base-16 value
  if empty(v16)
    v16 = str2nr(v256) < 16 ? v256 : 'NONE'
  endif

  # Insert color!
  for db in ActiveDatabases(ctx)
    db.Color.Insert({
      Name:       colorName,
      GUI:        vGui,
      Base256:    v256,
      Base256Hex: v256Hex,
      Base16:     v16,
    })
  endfor
enddef

def DefineDiscriminator(v: list<string>, ctx: Context)
  var discrName:  string = v[1]
  var rawDef:     string = v[3]
  var definition: string = join(Interpolate(rawDef, ctx))

  for db in ActiveDatabases(ctx)
    db.InsertDiscriminator(discrName, rawDef, definition)
  endfor
enddef

def SetHiGroupName(v: list<string>, ctx: Context)
  var state   = ctx.state
  var hiGroup = v[0]
  ResetState(state)
  state.hiGroupName = hiGroup
enddef

def SetEnvironments(v: list<any>, ctx: Context)
  var state                      = ctx.state
  var environments: list<string> = flattennew(v)

  state.environments = environments
  state.discrName    = ''
  state.discrValue   = ''
enddef

def SetDiscrName(v: list<string>, ctx: Context)
  var discrName   = v[1]
  ctx.state.discrName = discrName
enddef

def SetDiscrValue(discrValue: string, ctx: Context)
  ctx.state.discrValue = discrValue
enddef

def DefineLinkedGroup(v: list<string>, ctx: Context)
  const state           = ctx.state
  const hiGroupName     = state.hiGroupName
  const targetGroup     = v[1] == 'omit' ? '' : v[1]

  for db in ActiveDatabases(ctx)
    for environment in state.environments
      db.InsertLinkedGroup(environment, state.discrName, state.discrValue, hiGroupName, targetGroup)
    endfor
  endfor
enddef

def CheckColorName(colorName: string, ctx: Context): string
  if !empty(colorName) && colorName != 'omit'
    for db in ActiveDatabases(ctx)
      if empty(db.Color.Lookup(['Name'], [colorName]))
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
  const fgColor     = v[0] == 'omit' ? '' : v[0]
  const bgColor     = v[1] == 'omit' ? '' : v[1]
  const spColor     = empty(v[2]) ? 'none' : v[2] == 'omit' ? '' : v[2]
  const attributes  = empty(v[3]) ? 'NONE' : index(v[3], 'omit') != -1 ? '' : join(sort(v[3]), ',')

  for db in ActiveDatabases(ctx)
    for environment in state.environments
      db.InsertBaseGroup(
        environment,
        state.discrName,
        state.discrValue,
        hiGroupName,
        fgColor,
        bgColor,
        spColor,
        attributes
      )
    endfor
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

    try
      if key == 'author'
        return theme.authors[num]
      elseif key == 'maintainer'
        return theme.maintainers[num]
      elseif key == 'url'
        return theme.urls[num]
      elseif key == 'description'
        return theme.description[num]
      endif
    catch /E684/ # List index out of range
      throw printf("Cannot interpolate value '%s': index out of range", placeholder)
    endtry
  endif

  # The following replacements make sense only if the background is unambiguous
  if empty(state.background) || state.background == 'any'
    return ''
  endif

  const db: Database = theme.Db(state.background)

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

  for placeholder in sort(keys(placeholders), (x, y) => len(y) - len(x))
    const replacement = FindReplacement(placeholder, ctx)
    if !empty(replacement)
      newtext = substitute(newtext, placeholder, replacement, 'g')
    endif
  endfor

  return split(newtext, "\n")
enddef

def GetVerbatim(v: list<string>, ctx: Context)
  var state: dict<any> = ctx.state
  var theme: Colorscheme = state.theme
  var rawText = split(v[1], "\n")
  var text = Interpolate(v[1], ctx)

  if state.background == '' || state.background == 'any'
    theme.rawverbatimtext = theme.rawverbatimtext + rawText
    theme.verbatimtext = theme.verbatimtext + text
  else
    var db: Database = theme.Db(state.background)
    db.rawverbatimtext = db.rawverbatimtext + rawText
    db.verbatimtext = db.verbatimtext + text
  endif
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

const K_AUTHOR        = T('Author')
const K_AUXFILE       = T('auxfile')
const K_BACKGROUND    = T('Background')
const K_COLOR         = T('Color')
const K_COLORS        = R('[Cc]olors')
const K_CONST         = T('#const')
const K_DESCRIPTION   = T('Description')
const K_ENDAUXFILE    = T('endauxfile')
const K_ENDHELPFILE   = T('endhelpfile')
const K_ENDVERBATIM   = T('endverbatim')
const K_FULL          = T('Full')
const K_HELPFILE      = T('helpfile')
const K_INCLUDE       = T('Include')
const K_LICENSE       = T('License')
const K_MAINTAINER    = T('Maintainer')
const K_NAME          = R('[Nn]ame')
const K_OPTIONS       = T('Options')
const K_OPTN          = R('\%(backend\|creator\|dateformat\|palette\|shiftwidth\|timestamp\|vimlcompatibility\)\>')
const K_OPTV          = R('\%(true\|false\)\>\|\d\+\|\w\+\|"[^"]*"')
const K_PREFIX        = T('Prefix')
const K_RGB           = R('rgb\>')
const K_SHORT         = T('Short')
const K_SPECIAL       = R('s\|sp\>')
const K_TERM          = R('Term\%[inal\]')
const K_URL           = T('URL')
const K_ENVIRONMENT   = R('\(gui\|256\|88\|16\|8\|0\)\>')
const K_ENVIRONMENTS  = R('\(Environments\|Variants\)\>')
const K_VERBATIM      = Regex('verbatim')
const K_VERSION       = T('Version')

const BAR             = T('/')
const COLON           = T(':')
const COMMA           = T(',')
const EQ              = T('=')
const LPAREN          = T('(')
const RPAREN          = T(')')
const PLUS            = T('+')
const RARROW          = T('->')
const SEMICOLON       = T(';')
const TILDE           = T('~')
const TRUE            = T('true')
const FALSE           = T('false')

const IDENTIFIER      = R('\<\h\w*\>')
const HIGROUPNAME     = IDENTIFIER
const DISCRNAME       = IDENTIFIER
const COLORNAME       = IDENTIFIER
const FGCOLOR         = COLORNAME
const BGCOLOR         = COLORNAME
const ATTRIBUTE       = R(printf('\C\%(%s\)\>',
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
                          'nocombine',
                          'omit'
                        ], '\|')))
const COL16           = R('\%(\d\+\)\|' .. join(ANSI_COLORS, '\|'))
const NUM256          = R('\d\{1,3}\>')
const NUMBER          = R('-\=\d\+\%(\.\d*\)\=')
const STRING          = R('"[^"]*"')
const BACKGROUND      = R('dark\>\|light\|any\>')
const HEXCOL          = R('#[A-Fa-f0-9]\{6}')
const GUICOL          = OneOf(HEXCOL, STRING)
const TEXTLINE        = R('[^\r\n]\+')
const THEMENAME       = R('[0-9A-Z-a-z_-]\+')
const VERBTEXT        = R('\_.\{-}\ze\%(end\%(verbatim\|help\|auxfile\)\)')

const L_ATTRIBUTE     = Lab(ATTRIBUTE,            "Expected an attribute")
const L_BACKGROUND    = Lab(BACKGROUND,           "Expected a valid background ('light', 'dark', or 'any')")
const L_BGCOLOR       = Lab(BGCOLOR,              "Expected the name of the background color")
const L_COL256        = Lab(OneOf(TILDE, NUM256), "Expected a 256-color value or tilde")
const L_COLON         = Lab(COLON,                "Expected a colon")
const L_COLORNAME     = Lab(COLORNAME,            "Expected a color name")
const L_COLORS        = Lab(K_COLORS,             "Expected keyword 'Colors'")
const L_COMMA         = Lab(COMMA,                "Expected a comma")
const L_DISCRNAME     = Lab(DISCRNAME,            "Expected a discriminator name")
const L_ENDAUXFILE    = Lab(K_ENDAUXFILE,         "Expected keyword 'endauxfile'")
const L_ENDHELPFILE   = Lab(K_ENDHELPFILE,        "Expected keyword 'endhelpfile'")
const L_ENDVERBATIM   = Lab(K_ENDVERBATIM,        "Expected keyword 'endverbatim'")
const L_EQ            = Lab(EQ,                   "Expected an equal sign")
const L_HIGROUPNAME   = Lab(HIGROUPNAME,          "Expected the name of a highlight group")
const L_IDENTIFIER    = Lab(IDENTIFIER,           "Expected an identifier")
const L_LPAREN        = Lab(LPAREN,               "Expected open parenthesis")
const L_NAME          = Lab(K_NAME,               "Expected 'Name'")
const L_NUM256        = Lab(NUM256,               "Expected a number")
const L_OPTV          = Lab(K_OPTV,               "Expected a valid option value")
const L_PATH          = Lab(TEXTLINE,             "Expected a relative path")
const L_RPAREN        = Lab(RPAREN,               "Expected closed parenthesis")
const L_SPCOLOR       = Lab(COLORNAME,            "Expected the name of the special color")
const L_TEXTLINE      = Lab(TEXTLINE,             "Expected the value of the directive (which cannot be empty)")
const L_THEMENAME     = Lab(THEMENAME,            "Expected a valid color scheme's name")
const L_ENVIRONMENT   = Lab(K_ENVIRONMENT,        "Expected an environment value (gui, 256, 88, 16, 8, or 0)")
const L_VERBTEXT      = Lab(VERBTEXT,             "Expected end of verbatim block")

const AuxFile         = OneOf(
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

const VerbatimBlock   = Seq(
                          K_VERBATIM,
                          L_VERBTEXT,
                          L_ENDVERBATIM
                        )                                             ->Apply(GetVerbatim)

const Attributes      = Seq(
                          ATTRIBUTE,
                          Many(Seq(Skip(COMMA), L_ATTRIBUTE))
                        )                                             ->Map((v, _) => flattennew(v))
const SpecialColor    = Seq(K_SPECIAL, EQ, L_SPCOLOR)                 ->Map((v, _) => v[2])
const BaseGroup       = Seq(
                          FGCOLOR                                     ->Map(CheckColorName),
                          L_BGCOLOR                                   ->Map(CheckColorName),
                          Opt(SpecialColor)                           ->Map(CheckColorName),
                          Opt(Attributes)
                        )                                             ->Apply(DefineBaseGroup)
const LinkedGroup     = Seq(RARROW, L_HIGROUPNAME)                    ->Apply(DefineLinkedGroup)
const HiGroupDef      = OneOf(LinkedGroup, BaseGroup)
const DiscrValue      = OneOf(NUMBER, STRING, TRUE, FALSE)            ->Apply(SetDiscrValue)
const DiscrRest       = OneOrMore(Seq(
                          DiscrValue,
                          HiGroupDef
                        ))
const DiscrDef        = Seq(
                          Seq(PLUS, L_DISCRNAME)                      ->Apply(SetDiscrName),
                          DiscrRest
                        )
const HiGroupVariant  = Seq(
                          OneOrMore(Seq(Skip(BAR), L_ENVIRONMENT))    ->Apply(SetEnvironments),
                          OneOf(OneOrMore(DiscrDef),
                            Seq(HiGroupDef, Many(DiscrDef))
                          )
                        )
const HiGroupRest     = OneOf(
                          OneOrMore(HiGroupVariant),
                          Seq(
                            HiGroupDef,
                            Many(HiGroupVariant)
                          ),
                        )
const HiGroupName     = Seq(Bol, HIGROUPNAME)                         ->Apply(SetHiGroupName)
const HiGroupDecl     = Seq(HiGroupName, HiGroupRest)

const TermColorList   = Seq(
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

const OptionsList     = Lab(
                          OneOrMore(
                            Seq(K_OPTN, L_EQ, L_OPTV)                 ->Apply(SetOption)
                          ),
                          'Expected a Colortemplate option'
                        )

const EnvironmentList = Lab(
                          OneOrMore(K_ENVIRONMENT),
                          "Expected one of: gui, 256, 88, 16, 8, 0"
                        )                                             ->Apply(SetSupportedEnvironments)

const Prefix          = Seq(K_PREFIX,         L_COLON, L_IDENTIFIER)  ->Apply(SetOptionsPrefix)
const Options         = Seq(K_OPTIONS,        L_COLON, OptionsList)
const Version         = Seq(K_VERSION,        L_COLON, L_TEXTLINE)    ->Apply(SetVersion)
const Environments    = Seq(K_ENVIRONMENTS,   L_COLON, EnvironmentList)
const URL             = Seq(K_URL,            L_COLON, L_TEXTLINE)    ->Apply(SetURL)
const TermColors      = Seq(K_TERM, L_COLORS, L_COLON, TermColorList)
const Shortname       = Seq(K_SHORT, L_NAME,  L_COLON, L_THEMENAME)   ->Apply(SetShortName)
const Maintainer      = Seq(K_MAINTAINER,     L_COLON, L_TEXTLINE)    ->Apply(SetMaintainer)
const License         = Seq(K_LICENSE,        L_COLON, L_TEXTLINE)    ->Apply(SetLicense)
const Fullname        = Seq(K_FULL,  L_NAME,  L_COLON, L_TEXTLINE)    ->Apply(SetFullName)
const Description     = Seq(K_DESCRIPTION,    L_COLON, L_TEXTLINE)    ->Apply(SetDescription)
const Author          = Seq(K_AUTHOR,         L_COLON, L_TEXTLINE)    ->Apply(SetAuthor)
const Background      = Seq(K_BACKGROUND,     L_COLON, L_BACKGROUND)  ->Apply(SetActiveDatabases)
const Include         = Seq(K_INCLUDE,        L_COLON, L_PATH)        ->Apply(RefInclude('ParseInclude'))
const RgbColor        = Seq(
                          K_RGB,
                          L_LPAREN,
                          L_NUM256,
                          L_COMMA,
                          L_NUM256,
                          L_COMMA,
                          L_NUM256,
                          L_RPAREN)                                   ->Map(ToHexColor)
const GuiColor        = Lab(
                         OneOf(RgbColor, GUICOL),
                         "Expected a valid GUI color definition"
                       )

export const ColorParser = Seq(
                        K_COLOR,
                        L_COLON,
                        L_COLORNAME,
                        GuiColor,
                        L_COL256,
                        Opt(COL16)
                      )

const ColorDef       = ColorParser                                 ->Apply(DefineColor)

const Directive       = Seq(LookAhead(Regex('\%(\w\|\s\)\+\_s*:')),
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
                            Environments,
                            Version,
                            Options,
                            Prefix
                          ), 'Expected a valid metadata directive')
                        )

const Statement       = Seq(
                          K_CONST,
                          L_IDENTIFIER,
                          L_EQ,
                          L_TEXTLINE
                        )                                             ->Apply(DefineDiscriminator)

const Declaration     = OneOf(Statement, VerbatimBlock, AuxFile, Directive, HiGroupDecl)

export const Template = Seq(
                        Skip(SpaceOrComment),
                        Many(Declaration),
                        Lab(Eof, "Unexpected token")
                      )
# }}}

# Main {{{
class ColortemplateContext extends Context
  def new(this.text, basedir = '')
    this.state.basedir      = basedir
    this.state.theme        = Colorscheme.new()
    this.state.background   = ''          # Currently active background (dark, light, any)
    this.state.hiGroupName  = ''          # Currently parsed highlight group
    this.state.environments = ['default'] # Currently active environments
    this.state.discrName    = ''          # Currently active discriminator name
    this.state.discrValue   = ''          # Currently active discriminator value
  enddef
endclass

export def Parse(
    text:    string,
    basedir: string                      = '',
    Parser:  func(Context): ParserResult = Template,
    context: Context                     = ColortemplateContext.new(text, basedir)
    ): list<any>
  var ctx:    Context      = context
  var result: ParserResult = Parser(ctx)
  var theme:  Colorscheme  = ctx.state.theme

  return [result, theme]
enddef

def ParseInclude(v: list<string>, ctx: Context)
  if !path.IsRelative(v[2])
    throw printf(
      "Include path must be a relative path. Got '%s'", v[2]
    )
  endif

  var state       = ctx.state
  var oldBasedir  = state.basedir
  var includePath = path.Expand(v[2], state.basedir)
  var text        = join(readfile(includePath), "\n")
  var newCtx      = ColortemplateContext.new(text)

  newCtx.state = deepcopy(state)
  newCtx.state.basedir = path.Parent(includePath)

  const result: ParserResult = Template(newCtx)

  if !result.success
    throw printf('%s in included file "%s", byte %d)',
      result.label, includePath, result.errpos
    )
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

# Directive       ::= ColorDef | Include    | Background | Author       | Description |
#                              | Fullname   | License    | Maintainer   | Shortname   |
#                              | Termcolors | URL        | Environments | Version     |
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
# Shortname       ::= 'Short' 'name'  ':' THEMENAME
# TermColors      ::= 'Term' 'colors' ':' IDENT{16}
# URL             ::= 'URL'           ':' TEXTLINE
# Environments    ::= 'Environments'  ':' ENVIRONMENT+
# Version         ::= 'Version'       ':' TEXTLINE

# ColorDef        ::= 'Color' ':' IDENT GUICol Col256 [Col16]
# GUICol          ::= '#[A-Fa-f0-9]{6}' | IDENT | Rgb
# Rgb             ::= 'rgb' '(' Num256 ',' Num256 ',' Num256 ')'
# Col256          ::= '~' | Num256
# Num256          ::= '0' | '1' | ... | '255'
# Col16           ::= '0' | '1' | ... | '15' | IDENT

# HiGroupDecl     ::= ^HiGroupName HiGroupRest
# HiGroupRest     ::= HiGroupVariant+ | HiGroupDef HiGroupVariant*
# HiGroupVariant  ::= ('/' ENVIRONMENT)+ (DiscrDef+ | HiGroupDef DiscrDef*)
# DiscrDef        ::= '+' IDENT DiscrRest
# DiscrRest       ::= (DiscrValue HiGroupDef)+
# DiscrValue      ::= NUMBER | STRING | TRUE | FALSE
# HiGroupDef      ::= LinkedGroup | BaseGroup
# LinkedGroup     ::= '->' IDENT
# BaseGroup       ::= IDENT IDENT SpecialColor? Attributes?
# SpecialColor    ::= 's' '=' IDENT
# Attributes      ::= ATTRIBUTE (',' ATTRIBUTE)*
# }}}

