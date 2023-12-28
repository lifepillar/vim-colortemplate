vim9script

import 'librelalg.vim'     as ra
import 'libcolor.vim'      as libcolor
import './colorscheme.vim' as themes

const Extend            = ra.Extend
const Max               = ra.Max
const Select            = ra.Select
const Sort              = ra.Sort
const SortBy            = ra.SortBy
const Transform         = ra.Transform
const ANSI_HEX          = libcolor.ANSI_HEX
const Approximate       = libcolor.Approximate
const CtermColorNumber  = libcolor.CtermColorNumber
const RgbName2Hex       = libcolor.RgbName2Hex
const Xterm2Hex         = libcolor.Xterm2Hex
const NO_DISCR          = themes.DEFAULT_DISCR_VALUE
type  Colorscheme       = themes.Colorscheme

const ADJECTIVES = [
  'bald',
  'bold',
  'busy',
  'calm',
  'cool',
  'cute',
  'dead',
  'drab',
  'dull',
  'dumb',
  'easy',
  'evil',
  'fair',
  'fine',
  'free',
  'glad',
  'glum',
  'good',
  'hurt',
  'kind',
  'lazy',
  'long',
  'nice',
  'open',
  'pale',
  'poor',
  'real',
  'rich',
  'sore',
  'sour',
  'tame',
  'ugly',
  'vast',
  'warm',
  'weak',
  'wild',
  'zany',
]

const ANIMALS = [
  'Akita',
  'Bison',
  'Bongo',
  'Booby',
  'Camel',
  'Coati',
  'Coral',
  'Crane',
  'Dhole',
  'Dingo',
  'Eagle',
  'Fossa',
  'Gecko',
  'Goose',
  'Guppy',
  'Heron',
  'Horse',
  'Human',
  'Hyena',
  'Indri',
  'Koala',
  'Lemur',
  'Liger',
  'Llama',
  'Macaw',
  'Molly',
  'Moose',
  'Mouse',
  'Okapi',
  'Otter',
  'Prawn',
  'Quail',
  'Quoll',
  'Robin',
  'Saola',
  'Sheep',
  'Skunk',
  'Sloth',
  'Snail',
  'Snake',
  'Squid',
  'Stoat',
  'Tapir',
  'Tetra',
  'Tiger',
  'Xerus',
  'Zebra',
  'Zorse',
]

def FancyNames(): list<string>
  var fancyNames: list<string> = []

  for adjective in ADJECTIVES
    for animal in ANIMALS
      fancyNames->add(adjective .. animal)
    endfor
  endfor

  return fancyNames
enddef

def NotIn(item: any, items: list<any>): bool
  return index(items, item) == -1
enddef

def CompareDistinct(s1: string, s2: string): number
  return s1 < s2 ? -1 : 1
enddef

def CompareByHiGroupName(t: dict<any>, u: dict<any>): number
  if t.HiGroupName == u.HiGroupName
    return 0
  elseif t.HiGroupName == 'Normal'
    return -1
  elseif u.HiGroupName == 'Normal'
    return 1
  else
    return CompareDistinct(t.HiGroupName, u.HiGroupName)
  endif
enddef

def Fatal(t: string)
  echohl Error
  echomsg '[Colortemplate]' t .. '.'
  echohl None
  call interrupt()
enddef

def Shuffle(x: list<string>): list<string>
  for i in reverse(range(len(x) - 1))
    const j = rand() % (i + 1)
    const t = x[i]
    x[i] = x[j]
    x[j] = t
  endfor

  return x
enddef

class NameGenerator
  this._colmap:     dict<string> = {} # Color name => Hex value
  this._invmap:     dict<string> = {} # Hex value => Color name
  this._n                        = 0
  this._fancyNames: list<string>

  def new()
    this._fancyNames = Shuffle(FancyNames())
  enddef

  def GetName(hex: string): string
    if !this._invmap->has_key(hex)
      const name = this.NextColorName_()
      this._colmap[name] = hex
      this._invmap[hex]  = name
    endif

    return this._invmap[hex]
  enddef

  def NextColorName_(): string
    this._n += 1

    if get(g:, 'colortemplate_fancy_import', true)
      if this._n <= len(this._fancyNames)
        return this._fancyNames[this._n - 1]
      endif

      Fatal('Too many colors. Try setting g:colortemplate_fancy_import to false')
    endif

    return 'Color' .. repeat('0', float2nr(4 - log10(this._n + 1))) .. this._n
  enddef
endclass

# Return the list of the names of the currently defined highlight groups.
#
# Note: sometimes, a highlight group definition is split on two lines, e.g.:
#
# StatusLineTerm xxx term=bold,reverse cterm=bold ctermfg=0 ...
#                   links to StatusLine
#
# The second line would result in an empty name: that's why filter() is used.
def HiGroupNames(): list<string>
  const names = split(execute('hi'), '\n')
  return filter(mapnew(names, (_, v) => matchstr(v, "^\\S\\+")), (_, w) => !empty(w))
enddef

# Return the list of the synIDs of the currently defined highlight groups.
def GetAllIDs(): list<number>
  return mapnew(HiGroupNames(), (_, v) => hlID(matchstr(v, "^\\S\\+")))
enddef

# Return a hex color value or an empty string
def GuiValueFromCterm(nr: number): string
  var guiValue: string = ''

  if nr < 16
    guiValue = ANSI_HEX[nr]
  elseif nr < 256
    guiValue = Xterm2Hex(nr)
  endif

  return guiValue
enddef

# Return a color number (as a string), or an empty string
def GetCtermColor(synid: number, kind: string): string
  var cterm = synIDattr(synid, kind == 'sp' ? 'ul' : kind, 'cterm')

  if cterm =~ '\m^\d\+$'
    return cterm
  endif

  const t_Co = str2nr(&t_Co) == 8 ? 8 : 16

  try
    const nr = CtermColorNumber(cterm, t_Co)
    return string(nr)
  catch
  endtry

  return ''
enddef

def GetColorValues(synid: number, kind: string): dict<string>
  var   gui   = synIDattr(synid, kind, 'gui')
  var   cterm = GetCtermColor(synid, kind)
  const fail  = {GUIValue: '', Base256Value: '', Base256HexValue: '', Base16Value: ''}

  if empty(gui) && empty(cterm)
    return fail
  endif

  if empty(gui) # Try to approximate using cterm value
    gui = GuiValueFromCterm(str2nr(cterm))
    if empty(gui)
      return fail
    endif
  endif

  if gui[0] != '#'
    try
      gui = RgbName2Hex(gui)
    catch
      return fail
    endtry
  endif

  var base256:    string
  var base256Hex: string
  var base16:     string

  if empty(cterm) || str2nr(cterm) < 16
    const approx = Approximate(gui)
    base256 = string(approx.xterm)
    base256Hex = approx.hex
    base16 = cterm
  else
    base256 = cterm
    base256Hex = Xterm2Hex(str2nr(cterm))
    base16 = ''
  endif

  return {GUIValue: gui, Base256Value: base256, Base256HexValue: base256Hex, Base16Value: base16}
enddef

const ATTRIBUTES = [
  'bold',
  'italic',
  'nocombine',
  'reverse',
  'standout',
  'strike',
  'underline',
  'undercurl',
  'underdouble',
  'underdotted',
  'underdashed'
]

def GetAttributes(synid: number, mode: string): string
  var attributes: list<string> = []

  for attr in ATTRIBUTES
    if synIDattr(synid, attr, mode) == '1'
      attributes->add(attr)
    endif
  endfor

  return join(attributes, ',')
enddef

class Importer
  this.theme: Colorscheme
  this.background: string
  this._nameGenerator: NameGenerator
  this._hiGroupWidth: number = 0 # Maximum length of a highlight group's name
  this._colorWidth: number = 0 # Maximum length of a color name

  def new()
    this.theme                              = Colorscheme.new()
    this.background                         = &background
    this.theme.backgrounds[this.background] = true
    this.theme.fullname                     = get(g:, 'colors_name', '')
    this.theme.shortname                    = get(g:, 'colors_name', '')
    this.theme.author->add('Colortemplate')
    this.theme.variants                     = ['gui', '256', '0']
    this._nameGenerator                     = NameGenerator.new()
  enddef

  def AddColor_(id: number, kind: string): string
    var t = GetColorValues(id, kind)

    if !empty(t.GUIValue)
      const colorName = this._nameGenerator.GetName(t.GUIValue)
      var db = this.theme.Db(this.background)

      if empty(db.Color.Lookup(['ColorName'], [colorName]))
        db.Color.Insert({ColorName: colorName}->extend(t))
      endif

      return colorName
    endif

    return 'none'
  enddef

  # Collect information about the currently active highlight groups
  def Collect_()
    var db = this.theme.Db(this.background)

    const synIDs = GetAllIDs()

    for id in synIDs
      const trid = synIDtrans(id)

      if id == trid # Base group
        const hiGroupName = synIDattr(id, 'name')
        const fgColorName = this.AddColor_(id, 'fg')
        const bgColorName = this.AddColor_(id, 'bg')
        const spColorName = this.AddColor_(id, 'sp')

        const guiAttributes   = GetAttributes(id, 'gui')
        const ctermAttributes = GetAttributes(id, 'cterm')
        const termAttributes  = GetAttributes(id, 'term')

        db.InsertDefaultBaseGroup(
          hiGroupName,
          fgColorName,
          bgColorName,
          spColorName,
          guiAttributes
        )

        if ctermAttributes != guiAttributes
          db.InsertBaseGroupOverride(
            '256',
            NO_DISCR,
            hiGroupName,
            fgColorName,
            bgColorName,
            spColorName,
            ctermAttributes
          )
        endif

        if termAttributes != guiAttributes
          db.InsertBaseGroupOverride(
            '0',
            NO_DISCR,
            hiGroupName,
            '',
            '',
            '',
            termAttributes
          )
        endif
      else
        const hiGroupName = synIDattr(id, 'name')
        const targetGroup = synIDattr(trid, 'name')

        db.InsertDefaultLinkedGroup(
          hiGroupName,
          targetGroup
        )
      endif
    endfor

    # Retrieve terminal ANSI colors
    if (exists('g:terminal_ansi_colors'))
      for hex in g:terminal_ansi_colors
        const colorName = this._nameGenerator.GetName(hex)

        db.termcolors->add(colorName)

        if empty(db.Color.Lookup(['ColorName'], [colorName]))
          const approx = Approximate(hex)
          const t = {
            GUIValue: hex,
            Base256Value: string(approx.xterm),
            Base256HexValue: approx.hex,
            Base16Value: ''
          }
          db.Color.Insert({ColorName: colorName}->extend(t))
        endif
      endfor
    endif

    this._hiGroupWidth = this.LongestHiGroupName_() + 5
    this._colorWidth   = this.LongestColorName_() + 2
  enddef

  def LongestHiGroupName_(): number
    const db = this.theme.Db(this.background)
    const n = db.HiGroup
      ->Extend((t) => {
        return {Length: len(t.HiGroupName)}
      })
      ->Max('Length')

    return n
  enddef

  def LongestColorName_(): number
    const db = this.theme.Db(this.background)
    const n = db.Color
      ->Extend((t) => {
        return {Length: len(t.ColorName)}
      })
      ->Max('Length')

    return n
  enddef

  def GenerateTemplate(): list<string>
    this.Collect_()

    var output: list<string> = []

    output += this.Header_()
    output->add('')
    output += this.Colors_()
    output->add('')
    output += this.DefaultHiGroups_()
    output->add('')
    output += this.OverrideHiGroup_()
    output->add('')
    output += this.TermVariant_()
    output->add('')
    output += this.Footer_()

    return output
  enddef

  def Header_(): list<string>
    const theme = this.theme
    var header = [
      'Full Name:   ' .. theme.fullname,
      'Short name:  ' .. theme.shortname,
      'Author:      ' .. theme.author[0],
      '',
      'Variants:    256 0',
      'Background:  ' .. this.background,
    ]

    return header
  enddef

  def Colors_(): list<string>
    const db = this.theme.Db(this.background)

    var output = db.Color
      ->Select((t) => t.ColorName->NotIn(['', 'fg', 'bg', 'none']))
      ->Transform(
      (t) => printf('Color: %s %s %s', t.ColorName, t.GUIValue, t.Base256Value)
    )
    output += [
      '',
      'Term Colors: ' .. join(db.termcolors, ' '),
    ]

    return output
  enddef

  def DefaultHiGroups_(): list<string>
    const db = this.theme.Db(this.background)
    var output: list<string> = []
    var format = printf('%%-%ds -> %%s', this._hiGroupWidth)

    output += db.LinkedGroup
      ->SortBy('HiGroupName')
      ->Transform(
      (t) => printf(format, t.HiGroupName, t.TargetGroup)
    )

    output->add('')

    format = printf('%%-%ds %%-%ds %%-%ds %%-%ds %%s',
      this._hiGroupWidth, this._colorWidth, this._colorWidth, this._colorWidth + 2
    )
    output += db.BaseGroup
      ->Sort(CompareByHiGroupName)
      ->Transform(
        (t) => printf(format,
        t.HiGroupName,
        t.Fg,
        t.Bg,
        empty(t.Special) || t.Special == 'none' ? '' : 's=' .. t.Special,
        t.Style)
      )

    return output
  enddef

  def OverrideHiGroup_(): list<string>
    const db = this.theme.Db(this.background)
    var output: list<string> = []
    const format = printf('%%-%ds /256 %%-%ds %%-%ds %%-%ds %%s',
      this._hiGroupWidth - 5, this._colorWidth, this._colorWidth, this._colorWidth + 2
    )

    output += db.BaseGroupOverride
      ->Select((t) => t.Variant == '256')
      ->Sort(CompareByHiGroupName)
      ->Transform(
        (t) => printf(format,
        t.HiGroupName,
        t.Fg,
        t.Bg,
        empty(t.Special) || t.Special == 'none' ? '' : 's=' .. t.Special,
        t.Style)
      )

    return output
  enddef

  def TermVariant_(): list<string>
    const db = this.theme.Db(this.background)
    var output: list<string> = []
    const format = printf('%%-%ds /0 %%-%ds %%-%ds %%-%ds %%s',
      this._hiGroupWidth - 3, this._colorWidth, this._colorWidth, this._colorWidth + 2
    )

    output += db.BaseGroupOverride
      ->Select((t) => t.Variant == '0')
      ->Sort(CompareByHiGroupName)
      ->Transform((t) => printf(format, t.HiGroupName, 'omit', 'omit', '', t.Style))

    return output
  enddef

  def Footer_(): list<string>
    return [
      '',
      '; vim: nowrap et sw=2',
    ]
  enddef
endclass

export def Import()
  var importer = Importer.new()
  new
  setlocal ft=colortemplate
  const template = importer.GenerateTemplate()
  append(0, template)
enddef
