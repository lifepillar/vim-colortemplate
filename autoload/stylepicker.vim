vim9script

# Requirements Check {{{
if !has('popupwin') || !has('textprop') || v:version < 901
  echomsg 'Stylepicker requires Vim 9.1 compiled with popupwin and textprop.'
  finish
endif
# }}}
# Imports {{{
import 'libcolor.vim'       as libcolor
import 'libpath.vim'        as path
import 'libreactive.vim'    as react
import 'libversion.vim'     as vv
import 'libstylepicker.vim' as libui

if !vv.Require('libreactive', react.version, '0.0.1-beta', {throw: false})
  finish
endif

type ReactiveView = libui.ReactiveView
type StaticView   = libui.StaticView
type TextLine     = libui.TextLine
type TextProperty = libui.TextProperty
type VStack       = libui.VStack
type View         = libui.View
type ViewContent  = libui.ViewContent
# }}}
# Constants {{{
const kNumColorsPerLine = 10

const kUltimateFallbackColor = {
  'bg': {'dark': '#000000', 'light': '#ffffff'},
  'fg': {'dark': '#ffffff', 'light': '#000000'},
  'sp': {'dark': '#ffffff', 'light': '#000000'},
  'ul': {'dark': '#ffffff', 'light': '#000000'},
}

const kFgBgSp = {
  'fg': 'bg',
  'bg': 'sp',
  'sp': 'fg',
}

const kSpBgFg = {
  'sp': 'bg',
  'bg': 'fg',
  'fg': 'sp',
}

const kDefaultQuotes = [
  'Absentem edit cum ebrio qui litigat.',
  'Accipere quam facere praestat iniuriam',
  'Amicum cum vides obliviscere miserias.',
  'Diligite iustitiam qui iudicatis terram.',
  'Etiam capillus unus habet umbram suam.',
  'Impunitas semper ad deteriora invitat.',
  'Mala tempora currunt sed peiora parantur',
  'Nec quod fuimusve sumusve, cras erimus',
  'Nec sine te, nec tecum vivere possum',
  'Quis custodiet ipsos custodes?',
  'Quod non vetat lex, hoc vetat fieri pudor.',
  'Vim vi repellere licet',
  'Vana gloria spica ingens est sine grano.',
]

const kAddToFavoritesKey    = "A"
const kBotKey               = ">"
const kCancelKey            = "X"
const kChooseKey            = "\<enter>"
const kClearKey             = "Z"
const kCloseKey             = "x"
const kCollapsedPaneKey     = "_"
const kDecrementKey         = "\<left>"
const kDoubleClickKey       = "\<2-leftmouse>"
const kDownKey              = "\<down>"
const kFgBgSpKey            = "\<tab>"
const kGrayPaneKey          = "G"
const kHelpPaneKey          = "?"
const kHsbPaneKey           = "H"
const kIncrementKey         = "\<right>"
const kLeftClickKey         = "\<leftmouse>"
const kLeftDragKey          = "\<leftdrag>"
const kLeftReleaseKey       = "\<leftrelease>"
const kPasteKey             = "P"
const kRemoveKey            = "D"
const kRgbPaneKey           = "R"
const kSetColorKey          = "E"
const kSetHiGroupKey        = "N"
const kSpBgFgKey            = "\<s-tab>"
const kToggleBoldKey        = "B"
const kToggleItalicKey      = "I"
const kToggleReverseKey     = "V"
const kToggleStandoutKey    = "S"
const kToggleStrikeThruKey  = "K"
const kToggleTrackingKey    = "T"
const kToggleUndercurlKey   = "~"
const kToggleUnderdashedKey = "-"
const kToggleUnderdottedKey = "."
const kToggleUnderdoubleKey = "="
const kToggleUnderlineKey   = "U"
const kTopKey               = "<"
const kUpKey                = "\<up>"
const kYankKey              = "Y"

const kPrettyKey = {
  "\<left>":    "←",
  "\<right>":   "→",
  "\<up>":      "↑",
  "\<down>":    "↓",
  "\<tab>":     "↳",
  "\<s-tab>":   "⇧-↳",
  "\<enter>":   "↲",
  "\<s-enter>": "⇧-↲",
}

const kASCIIKey = {
  "\<left>":    "Left",
  "\<right>":   "Right",
  "\<up>":      "Up",
  "\<down>":    "Down",
  "\<tab>":     "Tab",
  "\<s-tab>":   "S-Tab",
  "\<enter>":   "Enter",
  "\<s-enter>": "S-Enter",
}
# }}}
# Reactive User Settings {{{
const kDefaultUserSettings: dict<any> = {
  allowkeymapping:    true,
  ascii:              false,
  asciiborderchars:   ['-', '|', '-', '|', ':', ':', ':', ':'],
  asciidigitchars:    ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
  asciidragsymbol:    '=',
  asciileftsymbol:    '<',
  asciirightsymbol:   '>',
  asciimarker:        '>> ',
  asciislidersymbols: [" ", ".", ":", "!", "|", "/", "-", "=", "#"],
  asciistar:          '*',
  borderchars:        ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
  debug:              0,
  digitchars:         ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'],
  dragsymbol:         '𝌆',
  favoritepath:       '',
  keyaliases:         {},
  highlight:          '',
  leftsymbol:         '◀︎',
  marker:             '❯❯ ',
  minwidth:           15,
  quotes:             kDefaultQuotes,
  numrecent:          20,
  recentpath:         '',
  rightsymbol:        '▶︎',
  slidersymbols:      [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", '█'],
  star:               '★',
  stepdelay:          1.0,
  zindex:             50,
}->extend(get(g:, 'stylepicker_options', {}), 'force')

var settings: dict<react.Property> = {}

for opt in keys(kDefaultUserSettings)
  settings[opt] = react.Property.new(kDefaultUserSettings[opt])
endfor

# Derived settings
var sDigits             = react.ComputedProperty.new(() => settings.ascii.Get() ? settings.asciidigitchars.Get()    : settings.digitchars.Get())
var sDragSymbol         = react.ComputedProperty.new(() => settings.ascii.Get() ? settings.asciidragsymbol.Get()    : settings.dragsymbol.Get())
var sLeftSymbol         = react.ComputedProperty.new(() => settings.ascii.Get() ? settings.asciileftsymbol.Get()    : settings.leftsymbol.Get())
var sMarker             = react.ComputedProperty.new(() => settings.ascii.Get() ? settings.asciimarker.Get()        : settings.marker.Get())
var sRightSymbol        = react.ComputedProperty.new(() => settings.ascii.Get() ? settings.asciirightsymbol.Get()   : settings.rightsymbol.Get())
var sSliderSymbols      = react.ComputedProperty.new(() => settings.ascii.Get() ? settings.asciislidersymbols.Get() : settings.slidersymbols.Get())
var sStar               = react.ComputedProperty.new(() => settings.ascii.Get() ? settings.asciistar.Get()          : settings.star.Get())
var sGutterDisplayWidth = react.ComputedProperty.new(() => strdisplaywidth(sMarker.Get()))
var sGutter             = react.ComputedProperty.new(() => repeat(' ', sGutterDisplayWidth.Get()))
var sGutterWidth        = react.ComputedProperty.new(() => strcharlen(sGutter.Get()))
var sPopupWidth         = react.ComputedProperty.new(() => max([39 + strdisplaywidth(sMarker.Get()), 42]))
var sReversedKeyAliases = react.ComputedProperty.new(() => {
  var keyMap: dict<string> = {}
  foreach(settings.keyaliases.Get(), (k, v) => {
    keyMap[v] = k
  })
  return keyMap
})

export def Set(option: string, value: any)
  if !settings->has_key(option)
    Error($"'{option}' is not a valid option.")
    return
  endif

  if type(settings[option].Get()) == v:t_bool
    settings[option].Set(<bool>value)
  else
    settings[option].Set(value)
  endif
enddef

export def Settings(values: dict<any> = {}): dict<react.Property>
  react.Transaction(() => {
    for option in keys(values)
      Set(option, values[option])
    endfor
  })
  return settings
enddef

def Getter(name: string): func(): any
  return settings[name].Get
enddef

class Config
  static var AllowKeyMapping    = Getter('allowkeymapping')
  static var Ascii              = Getter('ascii')
  static var BorderChars        = Getter('borderchars')
  static var ColorMode          = () => has('gui_running') || (has('termguicolors') && &termguicolors) ? 'gui' : 'cterm'
  static var Debug              = Getter('debug')
  static var Digits             = sDigits.Get
  static var DragSymbol         = sDragSymbol.Get
  static var FavoritePath       = Getter('favoritepath')
  static var Gutter             = sGutter.Get
  static var GutterWidth        = sGutterWidth.Get
  static var Highlight          = Getter('highlight')
  static var KeyAliases         = Getter('keyaliases')
  static var LeftSymbol         = sLeftSymbol.Get
  static var Marker             = sMarker.Get
  static var MinWidth           = Getter('minwidth')
  static var NumRecent          = Getter('numrecent')
  static var PopupWidth         = sPopupWidth.Get
  static var RandomQuotation    = () => settings.quotes.Get()[rand() % len(settings.quotes.Get())]
  static var RecentPath         = Getter('recentpath')
  static var ReversedKeyAliases = sReversedKeyAliases.Get
  static var RightSymbol        = sRightSymbol.Get
  static var SliderSymbols      = sSliderSymbols.Get
  static var Star               = sStar.Get
  static var StepDelay          = Getter('stepdelay')
  static var StyleMode          = () => has('gui_running') ? 'gui' : 'cterm'
  static var ZIndex             = Getter('zindex')
endclass
# }}}
# Internal State {{{
# Reference to the name of the current color scheme for autocommands
var sColorscheme:    react.Property = react.Property.new(exists('g:colors_name') ? g:colors_name : '')
var sHiGroup:        react.Property                          # Reference to the current highlight group for autocommands
var sX:              number         = 0                      # Horizontal position of the style picker
var sY:              number         = 0                      # Vertical position of the style picker
var sLastClickedRow: number         = 0                      # Window row where the mouse is currently left pressed
var sRedrawCount:    number         = 0                      # Number of times the popup has been redrawn
var sRecent:         react.Property = react.Property.new([]) # Cached recent colors to persist across close/reopen
var sFavorite:       react.Property = react.Property.new([]) # Cached favorite colors to persist across close/reopen
# }}}
# Helper Functions {{{
def In(v: any, items: list<any>): bool
  return index(items, v) != -1
enddef

def NotIn(v: any, items: list<any>): bool
  return index(items, v) == -1
enddef

def Min(a: number, b: number): number
  if a < b
    return a
  endif
  return b
enddef

def Int(cond: bool): number
  return cond ? 1 : 0
enddef

def KeySymbol(defaultKeyCode: string): string
  var userKeyCode = get(Config.ReversedKeyAliases(), defaultKeyCode, defaultKeyCode)

  if Config.Ascii()
    return get(kASCIIKey, userKeyCode, userKeyCode)
  endif

  return get(kPrettyKey, userKeyCode, userKeyCode)
enddef

def Center(text: string, width: number): string
  var lPad = repeat(' ', (width + 1 - strwidth(text)) / 2)
  var rPad = repeat(' ', (width - strwidth(text)) / 2)

  return $'{lPad}{text}{rPad}'
enddef

def Msg(text: string, hiGroup = 'Normal', log = true)
  execute 'echohl' hiGroup

  if log
    echomsg $'[StylePicker] {text}'
  else
    echo $'[StylePicker] {text}'
  endif

  echohl None
enddef

def Error(text: string)
  Msg(text, 'Error')
enddef

def Notification(winid: number, text: string, opts: dict<any> = {})
  var duration = opts->get('duration', 2500)
  var width    = opts->get('width',    strcharlen(text))
  var border   = opts->get('border',   Config.BorderChars())
  var where    = popup_getpos(winid)
  var line     = where.core_line + ((where.core_height - 3) / 2) + 1
  var col      = where.core_col + ((where.core_width - width) / 2) - 2

  popup_notification(Center(text, width), {
    pos:         'topleft',
    line:        line,
    col:         col,
    highlight:   'Normal',
    time:        duration,
    moved:       'any',
    mousemoved:  'any',
    minwidth:    width,
    maxwidth:    width,
    borderchars: border,
  })
enddef

def WarningPopup(
    text: string, duration = 2000, border = sBorder, width = Config.PopupWidth()
    )
  popup_notification(Center(text, width), {
    pos:         'topleft',
    highlight:   'Normal',
    time:        duration,
    moved:       'any',
    mousemoved:  'any',
    borderchars: border,
  })
enddef

def ComputeScore(hexCol1: string, hexCol2: string): number
  #   #
  #  # Assign an integer score from zero to five to a pair of colors according
  # #  to how many criteria the pair satifies.
  ##   Thresholds follow W3C guidelines.
  var cr = libcolor.ContrastRatio(hexCol1, hexCol2)
  var cd = libcolor.ColorDifference(hexCol1, hexCol2)
  var bd = libcolor.BrightnessDifference(hexCol1, hexCol2)

  return Int(cr >= 3.0) + Int(cr >= 4.5) + Int(cr >= 7.0) + Int(cd >= 500) + Int(bd >= 125)
enddef

def HiGroupUnderCursor(): string
  #   #
  #  # Return the name of the highlight group under the cursor.
  # #  Return 'Normal' if the highlight group cannot be determined.
  ##
  var hiGrp: string = synIDattr(synIDtrans(synID(line('.'), col('.'), true)), 'name')

  if empty(hiGrp)
    return 'Normal'
  endif

  return hiGrp
enddef

def CtermAttr(attr: string, mode: string): string
  #   #
  #  # Vim does not have "ctermsp", but "ctermul". Since internally, this
  # #  script always uses "sp", the attribute's name must be converted for
  ##   cterm attributes.
  if attr == 'sp' && mode == 'cterm'
    return 'ul'
  endif

  return attr
enddef

def HiGroupColorValue(hiGroup: string, fgBgSp: string, mode: string): string
  #   #
  #  # When mode is 'gui', return either a hex value or 'NONE'.
  # #  When mode is 'cterm', return either a numeric string or 'NONE'.
  ##
  var attr = CtermAttr(fgBgSp, mode)
  var value = synIDattr(synIDtrans(hlID(hiGroup)), $'{attr}#', mode)

  if empty(value)
    return 'NONE'
  endif

  if mode == 'gui'
    if value[0] != '#' # In terminals, `value` may be a color name
      value = libcolor.RgbName2Hex(value, '')
    endif

    return value
  endif

  if value !~ '\m^\d\+$' # Try converting color name to number
    var num = libcolor.CtermColorNumber(value, 16)

    if num >= 0
      value = string(num)
    else
      value = 'NONE'
    endif
  endif

  return value
enddef

#
def GetHiGroupColor(
    hiGroup: string, fgBgSp: string, colorMode: string = Config.ColorMode()
    ): string
  #   # Try hard to determine a sensible hex value for the requested
  #  # color attribute. Always prefer the GUI definition if it exists,
  # # regardless of current mode (GUI vs terminal), otherwise infer
  ## a hex value in other ways. Always returns a hex color value.
  var value = HiGroupColorValue(hiGroup, fgBgSp, 'gui') # Try to get a GUI color

  if value != 'NONE' # Fast path
    return value
  endif

  # Try to infer a hex color value from the cterm definition
  if colorMode == 'cterm'
    var ctermValue = HiGroupColorValue(
      hiGroup, CtermAttr(fgBgSp, 'cterm'), 'cterm'
    )

    if ctermValue != 'NONE'
      var hex = libcolor.ColorNumber2Hex(str2nr(ctermValue))

      # Enable fast path for future calls
      execute 'hi' hiGroup $'gui{fgBgSp}={hex}'

      return hex
    endif
  endif

  # Fallback strategy
  if fgBgSp == 'sp'
    return GetHiGroupColor(hiGroup, 'fg')
  elseif hiGroup == 'Normal'
    return kUltimateFallbackColor[fgBgSp][&bg]
  endif

  return GetHiGroupColor('Normal', fgBgSp)
enddef

def AltColor(hiGrp: string, fgBgSp: string): string
  #   #
  #  # Return the color 'opposite' to the current color attribute.
  # #  That is the background color if the input color attribute is
  ##   foreground; otherwise, it is the foreground color.
  if fgBgSp == 'bg'
    return GetHiGroupColor(hiGrp, 'fg')
  else
    return GetHiGroupColor(hiGrp, 'bg')
  endif
enddef

def LoadPalette(loadPath: string): list<string>
  var palette: list<string>

  try
    palette = readfile(path.Expand(loadPath))
  catch /.*/
    Error($'Could not load colors from file: {v:exception}')
    palette = []
  endtry

  # Keep only lines matching hex colors
  filter(palette, (_, v) => v =~ '\m^\s*#[A-Fa-f0-9]\{6}\>')

  return palette
enddef

def SavePalette(palette: list<string>, savePath: string)
  try
    if writefile(palette, path.Expand(savePath), 's') < 0
      throw $'failed to write {savePath}'
    endif
  catch /.*/
    Error($'Could not save colors to file: {v:exception}')
  endtry
enddef

def ChooseIndex(max: number): number
  Msg($'Which color (0-{max})? ')

  var key = getcharstr()
  echo "\r"

  if key =~ '\m^\d\+$'
    var n = str2nr(key)

    if n <= max
      return n
    endif
  endif

  return -1
enddef

def ChooseGuiColor(): string
  #   #
  #  # Prompt the user to enter a hex value for a color.
  # #  Return an empty string if the input is invalid.
  ##
  var newCol = input('[StylePicker] New color: #', '')
  echo "\r"

  if newCol =~ '\m^[0-9a-fa-f]\{1,6}$'
    if len(newCol) <= 3
      newCol = repeat(newCol, 6 /  len(newCol))
    endif

    if len(newCol) == 6
      return $'#{newCol}'
    endif
  endif

  return ''
enddef

def ChooseTermColor(): string
  #   #
  #  # Prompt the user to enter a numeric value for a terminal color and
  # # return the value as a hex color string.
  ## Return an empty string if the input is invalid.
  var newCol = input('[StylePicker] New terminal color [16-255]: ', '')
  echo "\r"
  var numCol = str2nr(newCol)

  if 16 <= numCol && numCol <= 255
    return libcolor.Xterm2Hex(numCol)
  endif

  return ''
enddef

def ChooseHiGroup(): string
  #   #
  #  # Prompt the user to enter a the name of a highlight group.
  # # Return an empty string if the input is invalid.
  ##
  var hiGroup = input('[StylePicker] Highlight group: ', '', 'highlight')
  echo "\r"

  if hlexists(hiGroup)
    return hiGroup
  endif

  return ''
enddef
# }}}
# Reactive State {{{
enum ColorState
  New,        # The color was just set (e.g., highlight group changed)
  Edited,     # The color has been modified via UI, but it is unsaved
  Saved       # The color has been saved to recent color palette
endenum

class ColorProperty extends react.Property
  #   # A color property is backed by a Vim's highlight group,
  #  # hence, it needs special management.
  # # A color property stores the hexadecimal value of the color.
  ##
  var colorState: react.Property = react.Property.new(ColorState.New)
  var _hiGroup:   string
  var _fgBgSp:    string
  var _guiAttr:   string # 'guifg', 'guibg', or 'guisp'
  var _ctermAttr: string # 'ctermfg', 'ctermbg', or 'ctermul'

  def new(hiGroup: react.Property, fgBgSp: react.Property, args: dict<any> = {})
    super.Init(args)

    # Reinitialize this property's value every time the highlight group changes
    react.CreateEffect(() => {
      this._hiGroup   = hiGroup.Get()
      this._fgBgSp    = fgBgSp.Get()
      this._guiAttr   = $'gui{this._fgBgSp}'
      this._ctermAttr = 'cterm' .. CtermAttr(this._fgBgSp, 'cterm')

      this.colorState.Set(ColorState.New)
      this.Set_(GetHiGroupColor(this._hiGroup, this._fgBgSp)) # `super` does not compile in a lambda in some Vim versions
    })
  enddef

  def Set(newValue: string, args: dict<any> = {})
    if !args->get('force', false) && newValue == this.value
      return
    endif

    var attrs: dict<any> = {name: this._hiGroup, [this._guiAttr]: newValue}
    var newValue_ = newValue

    if newValue_ == 'NONE'
      attrs[this._ctermAttr] = 'NONE'
      newValue_ = kUltimateFallbackColor[this._fgBgSp][&bg]
    else
      attrs[this._ctermAttr] = string(libcolor.Approximate(newValue).xterm)
    endif

    hlset([attrs])

    react.Transaction(() => {
      if this.colorState.value == ColorState.New
        this.colorState.Set(ColorState.Edited)
      endif

      this.Set_(newValue_)
    })
  enddef

  def Set_(newValue: string)
    super.Set(newValue)

    var mode    = Config.ColorMode()
    var fgColor = HiGroupColorValue(this._hiGroup, 'fg', mode)
    var bgColor = HiGroupColorValue(this._hiGroup, 'bg', mode)
    var spColor = HiGroupColorValue(this._hiGroup, 'sp', mode)

    hlset([{
      name: 'stylePickerCurrent',
      [$'{mode}fg']: fgColor,
      [$'{mode}bg']: bgColor,
      [$'{mode}sp']: spColor,
    }])
  enddef
endclass

class StyleProperty extends react.Property
  #   #
  #  # A style property is backed by a Vim's highlight group,
  # # hence it needs special management.
  ##
  static const styles: dict<bool> = {
    bold:          false,
    italic:        false,
    reverse:       false,
    standout:      false,
    strikethrough: false,
    underline:     false,
    undercurl:     false,
    underdashed:   false,
    underdotted:   false,
    underdouble:   false,
  }
  var _hiGroup: string

  def new(hiGroup: react.Property, args: dict<any> = {})
    super.Init(args)

    # Reinitialize this property's value every time the highlight group changes
    react.CreateEffect(() => {
      this._hiGroup = hiGroup.Get()
      var hl        = hlget(this._hiGroup, true)[0]
      var mode      = Config.StyleMode()
      var style     = get(hl, mode, {}) # Only attributes that are set
      var value     = extendnew(StyleProperty.styles, style, 'force') # All attributes

      if value.undercurl || value.underdashed || value.underdotted || value.underdouble
        value.underline = true
      endif

      hlset([{name: 'stylePickerCurrent', [mode]: style}])
      this.Set_(value) # `super` cannot appear inside a lambda
    })
  enddef

  def Set(value: dict<bool>, args: dict<any> = {})
    var style = filter(value, (_, v) => v)
    var mode  = Config.StyleMode()

    hlset([{name: this._hiGroup,        [mode]: style}])
    hlset([{name: 'stylePickerCurrent', [mode]: style}])
    super.Set(extendnew(StyleProperty.styles, value, 'force'), args)
  enddef

  def ToggleAttribute(attr: string)
    var style = this.value

    if attr[0 : 4] == 'under'
      var wasOn = style[attr]

      style.underline   = false
      style.undercurl   = false
      style.underdashed = false
      style.underdotted = false
      style.underdouble = false

      if !wasOn
        style[attr]     = true
        style.underline = true
      endif
    else
      style[attr] = !style[attr]
    endif

    this.Set(style)
  enddef

  def Set_(newStyle: dict<bool>)
    super.Set(newStyle)
  enddef
endclass

class State
  #   #
  #  # The reactive state of this script.
  # #
  ##
  var hiGroup:  react.Property # The name of the current highlight group
  var fgBgSp:   react.Property # The current color attribute ('fg', 'bg', or 'sp')
  var recent:   react.Property # List of recent colors
  var favorite: react.Property # List of favorite colors
  var color:    ColorProperty  # The hex value of the current color
  var style:    StyleProperty  # The current style attributes (bold, italic, etc.)

  var step     = react.Property.new(1)           # Current increment/decrement step
  var pane     = react.Property.new(kRgbPaneKey) # Current pane (rgb, hsb, grayscale, help)
  var rgb      = react.Property.new([0, 0, 0])
  var red      = react.Property.new(0)
  var green    = react.Property.new(0)
  var blue     = react.Property.new(0)
  var gray     = react.Property.new(0)
  # HSB values must be cached, because RGB -> HSB and HSB -> RGB are not
  # inverse to each other. For instance, HSB(1,1,1) -> RGB(3,3,3), but when
  # converting back, RGB(3,3,3) -> HSB(0,0,1). We don't want the sliders to
  # jump around randomly.
  var cachedHsb   = react.Property.new([-1, -1, -1])
  var cachedHex   = '#000000'
  var hsb         = react.Property.new([-1, -1, -1])
  var hue         = react.Property.new(-1)
  var saturation  = react.Property.new(-1)
  var brightness  = react.Property.new(-1)
  var colorscheme = react.Property.new(exists('g:colors_name') ? g:colors_name : '')

  public var winid    = 0  # StylePicker window ID

  var _timeSinceLastDigitPressed: list<number> = reltime() # Time since last digit key was pressed

  def new(hiGroup: string, fgBgSp: string)
    this.hiGroup = react.Property.new(hiGroup)
    this.fgBgSp  = react.Property.new(fgBgSp)
    this.color   = ColorProperty.new(this.hiGroup, this.fgBgSp)
    this.style   = StyleProperty.new(this.hiGroup)

    react.CreateEffect(() => {
      if !empty(Config.RecentPath()) && path.IsReadable(path.Expand(Config.RecentPath()))
        sRecent.Set(LoadPalette(Config.RecentPath()))
      endif
    })

    react.CreateEffect(() => {
      if !empty(Config.FavoritePath()) && path.IsReadable(path.Expand(Config.FavoritePath()))
        sFavorite.Set(LoadPalette(Config.FavoritePath()))
      endif
    })

    this.recent   = sRecent
    this.favorite = sFavorite
    sHiGroup      = this.hiGroup     # Allows setting the highlight group from an autocommand
    sColorscheme  = this.colorscheme # Ditto

    react.CreateEffect(() => { # Recompute value when this.color or this.cachedHsb changes
      var color = this.color.Get()
      var pane  = this.pane.Get()

      if pane == kHsbPaneKey
        var [h, s, b] = this.cachedHsb.Get()

        if color == this.cachedHex
          this.hsb.Set([h, s, b])
        else
          this.hsb.Set(libcolor.Hex2Hsv(color))
        endif

        this.hue.Set(this.hsb.value[0])
        this.saturation.Set(this.hsb.value[1])
        this.brightness.Set(this.hsb.value[2])
      else
        this.rgb.Set(libcolor.Hex2Rgb(color))
        this.red.Set(this.rgb.value[0])
        this.green.Set(this.rgb.value[1])
        this.blue.Set(this.rgb.value[2])

        if pane == kGrayPaneKey
          this.gray.Set(libcolor.Rgb2Gray(this.red.value, this.green.value, this.blue.value))
        endif
      endif
    })

    react.CreateEffect(() => { # Save to recent palette when a color is modified
      if this.color.colorState.Get() == ColorState.Edited
        this.SaveToRecent()
      endif
    })

    this.recent.Register(react.CreateEffect(() => { # Save recent palette to file if provided
      if !empty(Config.RecentPath())
        SavePalette(this.recent.Get(), Config.RecentPath())
      endif
    }, {execute: false})) # No need to save something we've just loaded

    this.favorite.Register(react.CreateEffect(() => { # Save favorite palette to file if provided
      if !empty(Config.FavoritePath())
        SavePalette(this.favorite.Get(), Config.FavoritePath())
      endif
    }, {execute: false}))
  enddef

  def SetStep(digit: number)
    var newStep = digit
    var elapsed = this._timeSinceLastDigitPressed->reltime()

    this._timeSinceLastDigitPressed = reltime()

    if elapsed->reltimefloat() <= Config.StepDelay()
      newStep = 10 * this.step.Get() + newStep

      if newStep > 99
        newStep = digit
      endif
    endif

    if newStep < 1
      newStep = 1
    endif

    this.step.Set(newStep)
  enddef

  def SetRgb(r: number, g: number, b: number)
    this.color.Set(libcolor.Rgb2Hex(r, g, b))
  enddef

  def SetRed(red: number)
    var [_, g, b] = this.rgb.Get()
    this.SetRgb(red, g, b)
  enddef

  def SetGreen(green: number)
    var [r, _, b] = this.rgb.Get()
    this.SetRgb(r, green, b)
  enddef

  def SetBlue(blue: number)
    var [r, g, _] = this.rgb.Get()
    this.SetRgb(r, g, blue)
  enddef

  def SetHSB(h: number, s: number, b: number)
    react.Transaction(() => {
      this.cachedHsb.Set([h, s, b])
      this.cachedHex = libcolor.Hsv2Hex(h, s, b)
      this.color.Set(this.cachedHex)
    })
  enddef

  def SetHue(hue: number)
    var hsb = this.hsb.Get()
    this.SetHSB(hue, hsb[1], hsb[2])
  enddef

  def SetSaturation(saturation: number)
    var hsb = this.hsb.Get()
    this.SetHSB(hsb[0], saturation, hsb[2])
  enddef

  def SetBrightness(brightness: number)
    var hsb = this.hsb.Get()
    this.SetHSB(hsb[0], hsb[1], brightness)
  enddef

  def SetGrayLevel(gray: number)
    this.color.Set(libcolor.Gray2Hex(gray))
  enddef

  def SaveToRecent()
    react.Transaction(() => {
      var recentColors: list<string> = this.recent.value
      var color = this.color.Get()

      if color->NotIn(recentColors)
        recentColors->add(color)

        while len(recentColors) > Config.NumRecent()
          remove(recentColors, 0)
        endwhile

        this.recent.Set(recentColors, {force: true})
      endif

      this.color.colorState.Set(ColorState.Saved)
    })
  enddef

  def AddToFavorite(color: string)
    var favorite = this.favorite.value

    if color->NotIn(favorite)
      favorite->add(color)
      this.favorite.Set(favorite, {force: true})
    endif
  enddef

  def Yank(color: string)
    setreg(v:register, color)
    feedkeys("\<esc>") # Clear partial command (is there a better way?)
    Notification(this.winid, $'{color} yanked into register @{v:register}')
  enddef

  def PasteColor()
    var what = getreg(v:register)

    feedkeys("\<esc>") # Clear partial command

    if what =~ '#\?[0-9a-fA-F]\{6}'
      this.SaveToRecent()
      this.color.Set(what)
    else
      Notification(this.winid, $'@{v:register} does not contain a valid color')
    endif
  enddef

  def ChooseHiGroup()
    var hiGroup = ChooseHiGroup()

    if !empty(hiGroup)
      UntrackCursorAutoCmd()
      this.hiGroup.Set(hiGroup)
    endif
  enddef
endclass
# }}}
# Text with Properties {{{
const kPropTypeOn               = '_on__' # Property for 'enabled' stuff
const kPropTypeOff              = '_off_' # Property for 'disabled' stuff
const kPropTypeLabel            = '_labl' # Mark line as a label
const kPropTypeCurrentHighlight = '_curh' # To highlight text with the currently selected highglight group
const kPropTypeHeader           = '_titl' # Highlight for title section
const kPropTypeGuiHighlight     = '_gcol' # Highlight for the current GUI color
const kPropTypeCtermHighlight   = '_tcol' # Highlight for the current cterm color
const kPropTypeGray000          = '_g000' # Grayscale blocks
const kPropTypeGray025          = '_g025' # Grayscale blocks
const kPropTypeGray050          = '_g050' # Grayscale blocks
const kPropTypeGray075          = '_g075' # Grayscale blocks
const kPropTypeGray100          = '_g100' # Grayscale blocks

def InitTextPropertyTypes(bufnr: number)
  var propTypes = {
    [kPropTypeOn              ]: {bufnr: bufnr, highlight: 'stylePickerOn'                   },
    [kPropTypeOff             ]: {bufnr: bufnr, highlight: 'stylePickerOff'                  },
    [kPropTypeLabel           ]: {bufnr: bufnr, highlight: 'Label',                          },
    [kPropTypeCurrentHighlight]: {bufnr: bufnr, highlight: 'stylePickerCurrent'              },
    [kPropTypeHeader          ]: {bufnr: bufnr, highlight: 'Title',               priority: 1}, # Higher than label
    [kPropTypeGuiHighlight    ]: {bufnr: bufnr, highlight: 'stylePickerGuiColor'             },
    [kPropTypeCtermHighlight  ]: {bufnr: bufnr, highlight: 'stylePickerTermColor'            },
    [kPropTypeGray000         ]: {bufnr: bufnr, highlight: 'stylePickerGray000'              },
    [kPropTypeGray025         ]: {bufnr: bufnr, highlight: 'stylePickerGray025'              },
    [kPropTypeGray050         ]: {bufnr: bufnr, highlight: 'stylePickerGray050'              },
    [kPropTypeGray075         ]: {bufnr: bufnr, highlight: 'stylePickerGray075'              },
    [kPropTypeGray100         ]: {bufnr: bufnr, highlight: 'stylePickerGray100'              },
  }

  for [propType, propValue] in items(propTypes)
    prop_type_delete(propType, {bufnr: bufnr})
    prop_type_add(propType, propValue)
  endfor
enddef

def BlankLine(width = 0): TextLine
  return TextLine.new(repeat(' ', width))
enddef

def WithStyle(line: TextLine, propType: string, from = 0, to = strcharlen(line.Text()), id = 1): TextLine
  line.Add(TextProperty.new(propType, from, to, id))
  return line
enddef

def WithTitle(line: TextLine, from = 0, to = strcharlen(line.Text())): TextLine
  return WithStyle(line, kPropTypeHeader, from, to)
enddef

def WithState(line: TextLine, enabled: bool, from = 0, to = strcharlen(line.Text())): TextLine
  return WithStyle(line, enabled ? kPropTypeOn : kPropTypeOff, from, to)
enddef

def WithGuiHighlight(line: TextLine, from = 0, to = strcharlen(line.Text())): TextLine
  return WithStyle(line, kPropTypeGuiHighlight, from, to)
enddef

def WithCtermHighlight(line: TextLine, from = 0, to = strcharlen(line.Text())): TextLine
  return WithStyle(line, kPropTypeCtermHighlight, from, to)
enddef

def WithCurrentHighlight(line: TextLine, from = 0, to = strcharlen(line.Text())): TextLine
  return WithStyle(line, kPropTypeCurrentHighlight, from, to)
enddef

def Labeled(line: TextLine, from = 0, to = strcharlen(line.Text())): TextLine
  return WithStyle(line, kPropTypeLabel, from, to)
enddef
# }}}
# Autocommands {{{
def ColorschemeChangedAutoCmd()
  augroup StylePicker
    autocmd ColorScheme * sColorscheme.Set(exists('g:colors_name') ? g:colors_name : '')
  augroup END
enddef

def TrackCursorAutoCmd()
  augroup StylePicker
    autocmd CursorMoved * sHiGroup.Set(HiGroupUnderCursor())
  augroup END
enddef

def UntrackCursorAutoCmd()
  if exists('#StylePicker')
    autocmd! StylePicker CursorMoved *
      endif
enddef

def ToggleTrackCursor()
  if exists('#StylePicker#CursorMoved')
    UntrackCursorAutoCmd()
  else
    TrackCursorAutoCmd()
  endif
enddef

def DisableAllAutocommands()
  if exists('#StylePicker')
    autocmd! StylePicker
    augroup! StylePicker
  endif
enddef
# }}}
# BlankView {{{
def BlankView(height = 1, width = 0): View
  return StaticView.new(repeat([BlankLine(width)], height))
enddef
# }}}
# CollapsedView {{{
def CollapsedView(): View
  return ReactiveView.new(() => {
    var dragSym = Config.DragSymbol()
    var pad     = repeat(' ', Config.MinWidth() - strdisplaywidth('StylePicker') - strdisplaywidth(dragSym))
    var text    = 'StylePicker' .. pad .. dragSym
    var width   = strcharlen(text)

    return [TextLine.new(text)->WithTitle(0, 11)->WithState(false, width - strcharlen(dragSym), width)]
  })
enddef
# }}}
# HeaderView {{{
def HeaderView(rstate: State, pane: string): View
  const attrs      = 'BIUVSK' # Bold, Italic, Underline, reVerse, Standout, striKethrough
  const attrsWidth = strcharlen(attrs)
  const styles     = ['bold', 'italic', 'underline', 'reverse', 'standout', 'strikethrough']

  var headerView = ReactiveView.new(() => {
    if rstate.pane.Get() == pane
      var hiGroup      = rstate.hiGroup.Get()
      var style        = rstate.style.Get()
      var dragSym      = Config.DragSymbol()
      var text         = $'{attrs} [{rstate.fgBgSp.Get()}] {hiGroup}'
      text           ..= repeat(' ', Config.PopupWidth() - strdisplaywidth(text) - strdisplaywidth(dragSym))
      var startDrag    = strcharlen(text)

      return [TextLine.new(text .. dragSym)
        ->WithState(style.bold,          0, 1)
        ->WithState(style.italic,        1, 2)
        ->WithState(style.underline,     2, 3)
        ->WithState(style.reverse,       3, 4)
        ->WithState(style.standout,      4, 5)
        ->WithState(style.strikethrough, 5, 6)
        ->WithTitle(7, 12 + strcharlen(hiGroup))
        ->WithState(false, startDrag, startDrag + strcharlen(dragSym)),
        BlankLine(),
      ]
    endif

    return []
  })

  headerView.OnMouseEvent(kLeftClickKey, (_, col) => {
    var pos = col - 3

    if pos >= 0 && pos < len(styles)
      rstate.style.ToggleAttribute(styles[pos])
    elseif pos >= 7 && pos <= 10
      rstate.fgBgSp.Set(kFgBgSp[rstate.fgBgSp.Get()])
    elseif pos >= 12 && pos <= 11 + strcharlen(rstate.hiGroup.Get())
      rstate.ChooseHiGroup()
    endif
  })

  headerView.OnMouseEvent(kDoubleClickKey, (_, _) => {
    rstate.pane.Set(kCollapsedPaneKey)
  })

  return headerView
enddef
# }}}
# FooterView {{{
def FooterView(rstate: State): View
  const nextPane = {
    [kRgbPaneKey]:  kHsbPaneKey,
    [kHsbPaneKey]:  kGrayPaneKey,
    [kGrayPaneKey]: kHelpPaneKey,
    [kHelpPaneKey]: kRgbPaneKey,
  }
  const prevPane = {
    [kRgbPaneKey]:  kHelpPaneKey,
    [kHsbPaneKey]:  kRgbPaneKey,
    [kGrayPaneKey]: kHsbPaneKey,
    [kHelpPaneKey]: kGrayPaneKey,
  }
  var offsets: dict<list<number>>
  var tpanes = ' Rgb Hsb Gray ?Help '
  var tlen = strcharlen(tpanes)

  var footerView = ReactiveView.new(() => {
    var pane = rstate.pane.Get()

    if pane == kCollapsedPaneKey
      return []
    endif

    var ll     = Config.LeftSymbol()
    var rr     = Config.RightSymbol()
    var text   = Center($'{ll}{tpanes}{rr}', Config.PopupWidth())
    var lpos   = stridx(text, ll) # In bytes, but works because before ll there are only spaces
    var offset = lpos + strcharlen(ll) # Start of tpanes (in characters)

    offsets = {
      leftArrow:      [lpos,          offset],
      rightArrow:     [offset + tlen, offset + tlen + strcharlen(rr)],
      [kRgbPaneKey]:  [offset +  1,   offset +  4], # Rgb
      [kHsbPaneKey]:  [offset +  5,   offset +  8], # Hsb
      [kGrayPaneKey]: [offset +  9,   offset + 13], # Gray
      [kHelpPaneKey]: [offset + 14,   offset + 19]} # ?Help

    var footer = TextLine.new(text)
      ->Labeled(offset + 1,  offset + 2)  # R[gb]
      ->Labeled(offset + 5,  offset + 6)  # H[sb]
      ->Labeled(offset + 9,  offset + 10) # G[ray]
      ->Labeled(offset + 14, offset + 15) # H[elp
      ->WithTitle(offsets[pane][0], offsets[pane][1])

    return [BlankLine(), footer]
  })

  footerView.OnMouseEvent(kLeftClickKey, (_, col) => {
    var pos = col - 3

    if pos >= offsets.leftArrow[0] - 1 && pos <= offsets.leftArrow[1]
      rstate.pane.Set(prevPane[rstate.pane.Get()])
    elseif pos >= offsets.rightArrow[0] - 1 && pos <= offsets.rightArrow[1]
      rstate.pane.Set(nextPane[rstate.pane.Get()])
    elseif pos >= offsets[kRgbPaneKey][0] && pos < offsets[kRgbPaneKey][1]
      rstate.pane.Set(kRgbPaneKey)
    elseif pos >= offsets[kHsbPaneKey][0] && pos < offsets[kHsbPaneKey][1]
      rstate.pane.Set(kHsbPaneKey)
    elseif pos >= offsets[kGrayPaneKey][0] && pos < offsets[kGrayPaneKey][1]
      rstate.pane.Set(kGrayPaneKey)
    elseif pos >= offsets[kHelpPaneKey][0] && pos < offsets[kHelpPaneKey][1]
      rstate.pane.Set(kHelpPaneKey)
    endif
  })

  return footerView
enddef
# }}}
# SectionTitleView {{{
def SectionTitleView(title: string, opts: dict<any> = {}): View
  #   #
  #  # A static line with a Label highlight.
  # #
  ##
  return ReactiveView.new(() => {
    var text = opts->get('center', false) ? Center(title, Config.PopupWidth()) : title
    return [TextLine.new(text)->Labeled()]
  })
enddef
# }}}
# GrayscaleSectionView {{{
def GrayscaleSectionView(): View
  #   #
  #  #
  # # A static line with grayscale markers.
  ##
  return ReactiveView.new(() => {
    var gutterWidth = Config.GutterWidth()
    var width       = Config.PopupWidth()

    return [
      TextLine.new('Grayscale')->Labeled(),
      BlankLine(width)
      ->WithStyle(kPropTypeGray000, gutterWidth +  5, gutterWidth + 7)
      ->WithStyle(kPropTypeGray025, gutterWidth + 13, gutterWidth + 15)
      ->WithStyle(kPropTypeGray050, gutterWidth + 21, gutterWidth + 23)
      ->WithStyle(kPropTypeGray075, gutterWidth + 29, gutterWidth + 31)
      ->WithStyle(kPropTypeGray100, gutterWidth + 37, gutterWidth + 39),
    ]
  })
enddef
# }}}
# StepView {{{
def StepView(rstate: State, pane: string): View
  return ReactiveView.new(() => {
    if rstate.pane.Get() == pane
      return [
        TextLine.new(printf('Step  %02d', rstate.step.Get()))->Labeled(0, 4),
        BlankLine(),
      ]
    endif

    return []
  })
enddef
# }}}
# SliderView {{{
def SliderView(
    rstate:      State,
    name:        string,         # The name of the slider (appears next to the slider)
    sliderValue: react.Property, # Observed value
    SetValue:    func(number),   # Used for updating when the slider's value changes
    max:         number = 255,   # Maximum value of the slider
    min:         number = 0,     # Minimum value of the slider
    ): View
  var range           = max + 1.0 - min
  var gutter          = react.Property.new(Config.Gutter())

  var sliderView = ReactiveView.new(() => {
    var width       = Config.PopupWidth() - Config.GutterWidth() - 6
    var gutterWidth = strcharlen(gutter.Get())
    var symbols     = Config.SliderSymbols()
    var value       = sliderValue.Get()
    var valuewidth  = value * width / range
    var whole       = float2nr(valuewidth)
    var frac        = valuewidth - whole
    var bar         = repeat(symbols[-1], whole)
    var part_char   = symbols[1 + float2nr(floor(frac * 8))]
    var text        = printf("%s%s %3d %s%s", gutter.Get(), name, value, bar, part_char)

    return [TextLine.new(text)->Labeled(gutterWidth, gutterWidth + 1)]
  })
  .Focusable(true)

  react.CreateEffect(() => {
    if sliderView.focused.Get()
      gutter.Set(Config.Marker())
    else
      gutter.Set(Config.Gutter())
    endif
  })

  sliderView.OnKeyPress(kIncrementKey, () => {
    var newValue = sliderValue.Get() + rstate.step.Get()

    if newValue > max
      newValue = max
    endif

    SetValue(newValue)
  })

  sliderView.OnKeyPress(kDecrementKey, () => {
    var newValue = sliderValue.Get() - rstate.step.Get()

    if newValue < min
      newValue = min
    endif

    SetValue(newValue)
  })

  sliderView.OnMouseEvent(kLeftClickKey, (_, col) => {
    var gutterWidth = Config.GutterWidth()
    var width       = Config.PopupWidth() - gutterWidth - 6
    var pos         = col - gutterWidth - 9

    if pos < 0 || pos >= width
      return
    endif

    sLastClickedRow = getmousepos().winrow

    var value = max * pos / (width - 1)

    SetValue(value)
  })

  sliderView.OnMouseEvent(kLeftDragKey, (lnum, col) => {
    var gutterWidth = Config.GutterWidth()
    var width       = Config.PopupWidth() - gutterWidth - 6
    var pos         = col - gutterWidth - 9

    if pos < 0 || pos >= width
      return
    endif

    if getmousepos().winrow != sLastClickedRow
      return
    endif

    var value = max * pos / (width - 1)

    SetValue(value)
  })

  return sliderView
enddef
# }}}
# SliderGroupView {{{
def SliderGroupView(rstate: State, ...sliders: list<View>): View
  var sliderGroupView = VStack.new(sliders)

  sliderGroupView.OnKeyPress('0', () => rstate.SetStep(0))
  sliderGroupView.OnKeyPress('1', () => rstate.SetStep(1))
  sliderGroupView.OnKeyPress('2', () => rstate.SetStep(2))
  sliderGroupView.OnKeyPress('3', () => rstate.SetStep(3))
  sliderGroupView.OnKeyPress('4', () => rstate.SetStep(4))
  sliderGroupView.OnKeyPress('5', () => rstate.SetStep(5))
  sliderGroupView.OnKeyPress('6', () => rstate.SetStep(6))
  sliderGroupView.OnKeyPress('7', () => rstate.SetStep(7))
  sliderGroupView.OnKeyPress('8', () => rstate.SetStep(8))
  sliderGroupView.OnKeyPress('9', () => rstate.SetStep(9))

  return sliderGroupView
enddef
# }}}
# RgbSliderView {{{
def RgbSliderView(rstate: State): View
  return SliderGroupView(rstate,
    SliderView(rstate, 'R', rstate.red,   rstate.SetRed),
    SliderView(rstate, 'G', rstate.green, rstate.SetGreen),
    SliderView(rstate, 'B', rstate.blue,  rstate.SetBlue),
  )
enddef
# }}}
# HsbSliderView {{{
def HsbSliderView(rstate: State): View
  return SliderGroupView(rstate,
    SliderView(rstate, 'H', rstate.hue,        rstate.SetHue,        359),
    SliderView(rstate, 'S', rstate.saturation, rstate.SetSaturation, 100),
    SliderView(rstate, 'B', rstate.brightness, rstate.SetBrightness, 100),
  )
enddef
# }}}
# GrayscaleSliderView {{{
def GrayscaleSliderView(rstate: State): View
  return SliderGroupView(rstate,
    GrayscaleSectionView(),
    SliderView(rstate, 'G', rstate.gray, rstate.SetGrayLevel),
  )
enddef
# }}}
# ColorInfoView {{{
def ColorInfoView(rstate: State, pane: string): View
  var colorInfoView = ReactiveView.new(() => {
    if rstate.pane.Get() == pane
      var hiGroup = rstate.hiGroup.Get()
      var fgBgSp  = rstate.fgBgSp.Get()
      var color   = rstate.color.Get()

      var altColor    = AltColor(hiGroup, fgBgSp)
      var approxCol   = libcolor.Approximate(color)
      var approxAlt   = libcolor.Approximate(altColor)
      var contrast    = libcolor.ContrastColor(color)
      var contrastAlt = libcolor.Approximate(contrast)
      var guiScore    = ComputeScore(color, altColor)
      var termScore   = ComputeScore(approxCol.hex, approxAlt.hex)
      var delta       = printf("%.1f", approxCol.delta)[ : 2]
      var guiGuess    = (color != HiGroupColorValue(hiGroup, fgBgSp, 'gui') ? '!' : ' ')
      var ctermGuess  = (string(approxCol.xterm) != HiGroupColorValue(hiGroup, fgBgSp, 'cterm') ? '!' : ' ')
      var deltaSym    = Config.Ascii() ? ' ' : 'Δ'

      var info = printf(
        $' {guiGuess}   {ctermGuess}  %s %-5S %3d/%s %-5S {deltaSym}{delta}',
        color[1 : ],
        repeat(Config.Star(), guiScore),
        approxCol.xterm,
        approxCol.hex[1 : ],
        repeat(Config.Star(), termScore)
      )

      rstate.colorscheme.Get()
      execute $'hi stylePickerGuiColor guifg={contrast} guibg={color} ctermfg={contrastAlt.xterm} ctermbg={approxCol.xterm}'
      execute $'hi stylePickerTermColor guifg={contrast} guibg={approxCol.hex} ctermfg={contrastAlt.xterm} ctermbg={approxCol.xterm}'

      return [
        TextLine.new(info)->WithGuiHighlight(0, 3)->WithCtermHighlight(4, 7),
        BlankLine(),
      ]
    endif

    return []
  })

  colorInfoView.OnMouseEvent(kLeftClickKey, (_, col) => {
    var pos = col - 3

    if (pos >= 0 && pos <= 2) || (pos >= 8 && pos <= 13) # Yank GUI color
      rstate.Yank(rstate.color.Get())
    endif

    if (pos >= 4 && pos <= 6) || (pos >= 21 && pos <= 30) # Yank cterm color
      var approx = libcolor.Approximate(rstate.color.Get())
      rstate.Yank(approx.hex)
    endif
  })

  return colorInfoView
enddef
# }}}
# QuotationView {{{
def QuotationView(): View
  return ReactiveView.new(() => {
    return [TextLine.new(Center(Config.RandomQuotation(), Config.PopupWidth()))->WithCurrentHighlight()]
  })
enddef
# }}}
# ColorSliceView {{{
def ColorSliceView(
    identifier: string,
    bufnr:      number,
    pane:       string,
    rstate:     State,
    colorSet:   react.Property,
    from:       number,
    to:         number,
    hasHeader:  bool = true,
    ):         View
  #   #
  #  # A view of a segment of a color palette as a strip of colored cells:
  # #
  ##    0   1   2   3   4   5   6   7   8   9
  ##   ███ ███ ███ ███ ███ ███ ███ ███ ███ ███

  var gutter = react.Property.new(Config.Gutter())

  var sliceView = ReactiveView.new(() => {
    if rstate.pane.Get() == pane
      var width  = Config.PopupWidth() - Config.GutterWidth()
      var digits = Config.Digits()

      var palette: list<string> = colorSet.Get()

      if from >= len(palette)
        return []
      endif

      var content: list<TextLine> = []
      var to_                     = Min(to, len(palette))

      if hasHeader
        content->add(TextLine.new(
          Config.Gutter() .. ' ' .. join(digits[0 : (to_ - from - 1)], '   ')
        )->Labeled())
      endif

      var colorsLine = TextLine.new(gutter.Get() .. repeat(' ', width))
      var k = 0
      var gutterWidth = strcharlen(gutter.Get())

      while k < to_ - from
        var hexCol   = palette[from + k]
        var approx   = libcolor.Approximate(hexCol)
        var textProp = $'stylePicker{identifier}_{from + k}'
        var column   = gutterWidth + 4 * k

        colorsLine->WithStyle(textProp, column, column + 3)

        rstate.colorscheme.Get()
        hlset([{name: textProp, guibg: hexCol, ctermbg: string(approx.xterm)}])
        prop_type_delete(textProp, {bufnr: bufnr})
        prop_type_add(textProp, {bufnr: bufnr, highlight: textProp})

        ++k
      endwhile

      content->add(colorsLine)
      return content
    endif

    return []
  })
  .Focusable(true)

  react.CreateEffect(() => {
    if sliceView.focused.Get()
      gutter.Set(Config.Marker())
    else
      gutter.Set(Config.Gutter())
    endif
  })

  sliceView.OnKeyPress(kYankKey, () => {
    var palette = colorSet.Get()
    var n = Min(to, len(palette)) - from
    var k = ChooseIndex(n - 1)

    if 0 <= k && k <= n
      rstate.Yank(palette[from + k])
    endif
  })

  sliceView.OnKeyPress(kChooseKey, () => {
    var palette = colorSet.Get()
    var n = Min(to, len(palette)) - from
    var k = ChooseIndex(n - 1)

    if 0 <= k && k <= n
      react.Transaction(() => {
        rstate.SaveToRecent()
        rstate.color.Set(palette[from + k])
      })
    endif
  })

  sliceView.OnKeyPress(kRemoveKey, () => {
    var palette = colorSet.Get()
    var n = Min(to, len(palette)) - from
    var k = ChooseIndex(n - 1)

    if 0 <= k && k <= n
      palette->remove(from + k)
      react.Transaction(() => {
        colorSet.Set(palette, {force: true})

        if empty(palette)
          sliceView.FocusPrevious()
        endif
      })
    endif
  })

  sliceView.OnMouseEvent(kLeftClickKey, (_, col) => {
    var pos = col - Config.GutterWidth() - 3

    if pos < 0 || pos % 4 == 3 # Space between color swaths
      return
    endif

    var index = pos / 4 + from
    var palette = colorSet.Get()

    if index < len(palette)
      var color = palette[index]

      react.Transaction(() => {
        rstate.SaveToRecent()
        rstate.color.Set(color)
      })
    endif
  })

  return sliceView
enddef
# }}}
# ColorPaletteView {{{
class ColorPaletteView extends VStack
  var identifier:       string
  var palette:          react.Property
  var rstate:           State
  var bufnr:            number
  var pane:             string
  var minHeight:        number # Minimum height in lines, excluding top blank line and title
  var hideIfEmpty:      bool   # Collapse view if there are no colors to display
  var numColorsPerLine: number # Number of colors of a slice

  def new(this.identifier, title: string, this.palette, this.rstate, args: dict<any>)
    this.bufnr            = args['bufnr']
    this.pane             = args['pane']
    this.minHeight        = args->get('minHeight', 0)
    this.hideIfEmpty      = args->get('hide', true)
    this.numColorsPerLine = args->get('numColorsPerLine', kNumColorsPerLine)

    this.AddView(BlankView())
    this.AddView(SectionTitleView(title))
  enddef

  def Body(): ViewContent
    if this.rstate.pane.Get() == this.pane
      # Dynamically add slices to accommodate all the colors
      var numColors = len(this.palette.Get())
      var numSlices = this.NumChildren() - 2  # First two children are always blank line and title
      var numSlots  = numSlices * this.numColorsPerLine

      while numSlots < numColors
        this.AddView(ColorSliceView(
          this.identifier,
          this.bufnr,
          this.pane,
          this.rstate,
          this.palette,
          numSlots,
          numSlots + this.numColorsPerLine,
        ))
        numSlots += this.numColorsPerLine
      endwhile

      var body   = super.Body()
      var height = len(body) - 2 # Do not count blank line and title

      if this.hideIfEmpty && height == 0
        return []
      endif

      if height < this.minHeight
        body += repeat(BlankView().Body(), this.minHeight - height)
      endif

      return body
    endif

    return []
  enddef
endclass
# }}}
# StylePickerView {{{
def StylePickerView(pane: string, rstate: State, MakeSlidersView: func(State): View): View
  var bufnr = winbufnr(rstate.winid)

  var stylePickerView = VStack.new([
    HeaderView(rstate, pane),
    MakeSlidersView(rstate),
    StepView(rstate, pane),
    ColorInfoView(rstate, pane),
    QuotationView(),
    ColorPaletteView.new(
      'Recent',
      'Recent Colors',
      rstate.recent,
      rstate,
      {bufnr: bufnr, pane: pane, minHeight: 2, hide: false}
    ),
    ColorPaletteView.new(
      'Fav',
      'Favorite Colors',
      rstate.favorite,
      rstate,
      {bufnr: bufnr, pane: pane}
    ),
    FooterView(rstate),
  ])
  stylePickerView.OnKeyPress(kUpKey,                stylePickerView.FocusPrevious)
  stylePickerView.OnKeyPress(kDownKey,              stylePickerView.FocusNext)
  stylePickerView.OnKeyPress(kTopKey,               stylePickerView.FocusFirst)
  stylePickerView.OnKeyPress(kBotKey,               stylePickerView.FocusLast)
  stylePickerView.OnKeyPress(kFgBgSpKey,            () => rstate.fgBgSp.Set(kFgBgSp[rstate.fgBgSp.Get()]))
  stylePickerView.OnKeyPress(kSpBgFgKey,            () => rstate.fgBgSp.Set(kSpBgFg[rstate.fgBgSp.Get()]))
  stylePickerView.OnKeyPress(kToggleBoldKey,        () => rstate.style.ToggleAttribute('bold'))
  stylePickerView.OnKeyPress(kToggleItalicKey,      () => rstate.style.ToggleAttribute('italic'))
  stylePickerView.OnKeyPress(kToggleReverseKey,     () => rstate.style.ToggleAttribute('reverse'))
  stylePickerView.OnKeyPress(kToggleStandoutKey,    () => rstate.style.ToggleAttribute('standout'))
  stylePickerView.OnKeyPress(kToggleStrikeThruKey,  () => rstate.style.ToggleAttribute('strikethrough'))
  stylePickerView.OnKeyPress(kToggleUndercurlKey,   () => rstate.style.ToggleAttribute('undercurl'))
  stylePickerView.OnKeyPress(kToggleUnderdashedKey, () => rstate.style.ToggleAttribute('underdashed'))
  stylePickerView.OnKeyPress(kToggleUnderdottedKey, () => rstate.style.ToggleAttribute('underdotted'))
  stylePickerView.OnKeyPress(kToggleUnderdoubleKey, () => rstate.style.ToggleAttribute('underdouble'))
  stylePickerView.OnKeyPress(kToggleUnderlineKey,   () => rstate.style.ToggleAttribute('underline'))

  stylePickerView.OnKeyPress(kYankKey, () => {
    rstate.Yank(rstate.color.Get())
  })

  stylePickerView.OnKeyPress(kPasteKey, () => {
    rstate.PasteColor()
  })

  stylePickerView.OnKeyPress(kAddToFavoritesKey, () => {
    rstate.AddToFavorite(rstate.color.Get())
  })

  stylePickerView.OnKeyPress(kSetColorKey, () => {
    var color = Config.ColorMode() == 'gui' ? ChooseGuiColor() : ChooseTermColor()

    if !empty(color)
      rstate.color.Set(color)
    endif
  })

  stylePickerView.OnKeyPress(kSetHiGroupKey, () => {
    rstate.ChooseHiGroup()
  })

  stylePickerView.OnKeyPress(kClearKey, () => {
    rstate.color.Set('NONE')
    Notification(rstate.winid, 'Color cleared')
  })

  stylePickerView.OnMouseEvent(kLeftReleaseKey, (_, _) => {
    sLastClickedRow = 0
  })

  return stylePickerView
enddef
# }}}
# HelpView {{{
def HelpView(rstate: State): View
  var helpView = ReactiveView.new(() => {
    var s = {
      [00]: KeySymbol(kUpKey),
      [01]: KeySymbol(kDownKey),
      [02]: KeySymbol(kTopKey),
      [03]: KeySymbol(kBotKey),
      [04]: KeySymbol(kFgBgSpKey),
      [05]: KeySymbol(kSpBgFgKey),
      [06]: KeySymbol(kToggleTrackingKey),
      [07]: KeySymbol(kRgbPaneKey),
      [08]: KeySymbol(kHsbPaneKey),
      [09]: KeySymbol(kGrayPaneKey),
      [10]: KeySymbol(kCloseKey),
      [11]: KeySymbol(kCancelKey),
      [12]: KeySymbol(kHelpPaneKey),
      [13]: KeySymbol(kCollapsedPaneKey),
      [14]: KeySymbol(kToggleBoldKey),
      [15]: KeySymbol(kToggleItalicKey),
      [16]: KeySymbol(kToggleReverseKey),
      [17]: KeySymbol(kToggleStandoutKey),
      [18]: KeySymbol(kToggleStrikeThruKey),
      [19]: KeySymbol(kToggleUnderlineKey),
      [20]: KeySymbol(kToggleUndercurlKey),
      [21]: KeySymbol(kToggleUnderdashedKey),
      [22]: KeySymbol(kToggleUnderdottedKey),
      [23]: KeySymbol(kToggleUnderdoubleKey),
      [24]: KeySymbol(kIncrementKey),
      [25]: KeySymbol(kDecrementKey),
      [26]: KeySymbol(kYankKey),
      [27]: KeySymbol(kPasteKey),
      [28]: KeySymbol(kSetColorKey),
      [29]: KeySymbol(kSetHiGroupKey),
      [30]: KeySymbol(kClearKey),
      [31]: KeySymbol(kAddToFavoritesKey),
      [32]: KeySymbol(kYankKey),
      [33]: KeySymbol(kRemoveKey),
      [34]: KeySymbol(kChooseKey)}

    var maxSymbolWidth = max(mapnew(s, (_, v) => strdisplaywidth(v)))

    # Pad with spaces, so all symbol strings have the same width
    map(s, (_, v) => v .. repeat(' ', maxSymbolWidth - strdisplaywidth(v)))

    return [
      TextLine.new('Keyboard Controls')->WithTitle(),
      BlankLine(),
      TextLine.new('Popup')->Labeled(),
      TextLine.new($'{s[00]} Move up           {s[07]} RGB Pane'),
      TextLine.new($'{s[01]} Move down         {s[08]} HSB Pane'),
      TextLine.new($'{s[02]} Go to top         {s[09]} Grayscale Pane'),
      TextLine.new($'{s[03]} Go to bottom      {s[10]} Close'),
      TextLine.new($'{s[04]} fg->bg->sp        {s[11]} Close and reset'),
      TextLine.new($'{s[05]} sp->bg->fg        {s[12]} Help pane'),
      TextLine.new($'{s[06]} Toggle tracking   {s[13]} Toggle Collapse'),
      BlankLine(),
      TextLine.new('Attributes')->Labeled(),
      TextLine.new($'{s[14]} Toggle boldface   {s[19]} Toggle underline'),
      TextLine.new($'{s[15]} Toggle italics    {s[20]} Toggle undercurl'),
      TextLine.new($'{s[16]} Toggle reverse    {s[21]} Toggle underdashed'),
      TextLine.new($'{s[17]} Toggle standout   {s[22]} Toggle underdotted'),
      TextLine.new($'{s[18]} Toggle strikethru {s[23]} Toggle underdouble'),
      BlankLine(),
      TextLine.new('Color')->Labeled(),
      TextLine.new($'{s[24]} Increment value   {s[28]} Set value'),
      TextLine.new($'{s[25]} Decrement value   {s[29]} Set hi group'),
      TextLine.new($'{s[26]} Yank color        {s[30]} Clear color'),
      TextLine.new($'{s[27]} Paste color       {s[31]} Add to favorites'),
      BlankLine(),
      TextLine.new('Recent & Favorites')->Labeled(),
      TextLine.new($'{s[32]} Yank color        {s[34]} Pick color'),
      TextLine.new($'{s[33]} Delete color'),
    ]
  })
  var helpVStack = VStack.new([helpView, FooterView(rstate)])

  return helpVStack
enddef
# }}}
# Highlight {{{
def InitHighlight()
  #   #
  #  # Initialize the highlight groups used by the style picker.
  # #
  ##
  var mode         = Config.ColorMode()
  var style        = Config.StyleMode()
  var warnColor    = HiGroupColorValue('WarningMsg', 'fg', mode)
  var labelColor   = HiGroupColorValue('Label',      'fg', mode)
  var commentColor = HiGroupColorValue('Comment',    'fg', mode)
  var fgColor      = HiGroupColorValue('Normal',     'fg', mode)
  var bgColor      = HiGroupColorValue('Normal',     'bg', mode)

  execute $'highlight stylePickerOn        {mode}fg={labelColor}   {style}=bold term=bold'
  execute $'highlight stylePickerOff       {mode}fg={commentColor} {style}=NONE term=NONE'
  execute $'highlight stylePickerWarning   {mode}fg={warnColor}    {style}=bold term=bold'
  # Used as normal highlight group (default fg and bg colors) in the stylepicker:
  execute $'highlight stylePickerHighlight {mode}fg={fgColor} {mode}bg={bgColor}'
  # Used to store the highlight group currently in use:
  execute $'highlight stylePickerCurrent   {mode}fg={fgColor} {mode}bg={bgColor}'

  highlight stylePickerGray000 guibg=#000000 ctermbg=16
  highlight stylePickerGray025 guibg=#404040 ctermbg=238
  highlight stylePickerGray050 guibg=#7f7f7f ctermbg=244
  highlight stylePickerGray075 guibg=#bfbfbf ctermbg=250
  highlight stylePickerGray100 guibg=#ffffff ctermbg=231
  highlight clear stylePickerGuiColor
  highlight clear stylePickerTermColor
enddef
# }}}
# UI {{{
class UI
  var rstate: State
  var rootView: react.ComputedProperty
  var _reopenPane = kRgbPaneKey

  def new(this.rstate)
    this.rootView = react.ComputedProperty.new(() => StaticView.new([]))
  enddef

  def Init(winid: number, initialPane: string)
    InitTextPropertyTypes(winbufnr(winid))
    this.rstate.winid = winid

    # Inherit global tabstop: this matters if the marker contains a tab
    setbufvar(winbufnr(winid), '&tabstop', &tabstop)

    var rgbView       = StylePickerView(kRgbPaneKey,  this.rstate, RgbSliderView)
    var hsbView       = StylePickerView(kHsbPaneKey,  this.rstate, HsbSliderView)
    var grayscaleView = StylePickerView(kGrayPaneKey, this.rstate, GrayscaleSliderView)
    var helpView      = HelpView(this.rstate)
    var collapsedView = CollapsedView()

    this.rstate.pane.Set(initialPane)

    this.rootView = react.ComputedProperty.new(() => {
      var pane = this.rstate.pane.Get()

      this.rstate.color.colorState.Set(ColorState.New)

      if pane == kRgbPaneKey
        return rgbView
      elseif pane == kHsbPaneKey
        return hsbView
      elseif pane == kGrayPaneKey
        return grayscaleView
      elseif pane == kCollapsedPaneKey
        return collapsedView
      else
        return helpView
      endif
    }, {force: true})

    react.CreateEffect(() => { # Reset the focus when the root view changes
      this.rootView.Get().FocusFirst()
    })
  enddef

  def HandleEvent(winid: number, rawKeyCode: string): bool
    if rawKeyCode->In(values(Config.KeyAliases())) # Key code is remapped
      return false
    endif

    var keyCode = get(Config.KeyAliases(), rawKeyCode, rawKeyCode)

    if this.rstate.pane.Get() == kCollapsedPaneKey
      if !keyCode->In([kCollapsedPaneKey, kDoubleClickKey])
        return false
      endif

      this.rstate.pane.Set(this._reopenPane)
      return true
    endif

    if keyCode == kCancelKey
      Cancel(winid)
      return true
    endif

    if keyCode == kCloseKey
      popup_close(winid)
      return true
    endif

    if keyCode->In([kHelpPaneKey, kRgbPaneKey, kHsbPaneKey, kCollapsedPaneKey, kGrayPaneKey])
      if keyCode == kCollapsedPaneKey
        this._reopenPane = this.rstate.pane.Get()
      endif

      this.rstate.pane.Set(keyCode)

      return true
    endif

    if keyCode == kToggleTrackingKey
      ToggleTrackCursor()
      return true
    endif

    if keyCode->In([kLeftClickKey, kLeftDragKey, kDoubleClickKey, kLeftReleaseKey])
      var mousepos = getmousepos()

      if mousepos.winid != winid
        return false
      endif

      var lnum = mousepos.line
      var col  = mousepos.wincol

      if lnum <= 1 && (col > Config.PopupWidth() - strcharlen(Config.DragSymbol()))
        return false # Leave some room for dragging the popup
      endif

      return this.rootView.Get().RespondToMouseEvent(keyCode, mousepos.line, mousepos.wincol)
    endif

    return this.rootView.Get().SubViewWithFocus().RespondToKeyEvent(keyCode)
  enddef
endclass
# }}}
# Style Picker Popup {{{
def Cancel(winid: number)
  popup_close(winid)

  if exists('g:colors_name') && !empty('g:colors_name')
    execute 'colorscheme' g:colors_name
  endif
enddef

def ClosedCallback(winid: number, result: any = '')
  DisableAllAutocommands()
  sX = popup_getoptions(winid).col
  sY = popup_getoptions(winid).line
  sRedrawCount = 0
enddef

def StylePickerPopup(hiGroup: string, xPos: number, yPos: number): number
  var initHighlightEffect = react.CreateEffect(() => {
    InitHighlight()
  })
  sColorscheme.Register(initHighlightEffect)

  var _hiGroup = empty(hiGroup) ? HiGroupUnderCursor() : hiGroup
  var  rstate  = State.new(_hiGroup, 'fg')
  var  ui      = UI.new(rstate)

  var winid    = popup_create('', {
    border:      [1, 1, 1, 1],
    borderchars: Config.BorderChars(),
    callback:    ClosedCallback,
    close:       'button',
    col:         xPos,
    cursorline:  false,
    drag:        true,
    dragall:     true,
    filter:      ui.HandleEvent,
    filtermode:  'n',
    hidden:      true,
    highlight:   empty(Config.Highlight()) ? 'stylePickerHighlight' : Config.Highlight(),
    line:        yPos,
    mapping:     Config.AllowKeyMapping(),
    minwidth:    Config.MinWidth(),
    padding:     [0, 1, 0, 1],
    pos:         'topleft',
    resize:      false,
    scrollbar:   true,
    tabpage:     0,
    title:       '',
    wrap:        false,
    zindex:      Config.ZIndex(),
  })
  ui.Init(winid, kRgbPaneKey)

  if empty(hiGroup)
    TrackCursorAutoCmd()
  endif

  ColorschemeChangedAutoCmd()

  def Redraw()
    ++sRedrawCount

    if Config.Debug() == 0
      popup_settext(winid, ui.rootView.Get().Body())
      return
    endif

    var text      = $'{sRedrawCount} winid={winid} bufnr={winbufnr(winid)} gutter={Config.GutterWidth()}'
    var debugText = [BlankLine().value, TextLine.new(text).value]

    popup_settext(winid, ui.rootView.Get().Body() + debugText)
  enddef

  react.CreateEffect(() => Redraw(), {weight: 100})

  popup_show(winid)

  return winid
enddef
# }}}
# Public Interface {{{
export def Open(hiGroup = '')
  StylePickerPopup(hiGroup, sX, sY)
enddef
# }}}
