vim9script

import './version.vim'     as version
import './colorscheme.vim' as themes
import 'librelalg.vim'     as ra

const VERSION        = version.VERSION
const NO_DISCR_VALUE = themes.DEFAULT_DISCR_VALUE
const Colorscheme    = themes.Colorscheme
const Sort           = ra.Sort
const Transform      = ra.Transform

# Helper functions {{{
def In(v: any, items: list<any>): bool
  return index(items, v) != -1
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

def CompareByDiscrName(t: dict<any>, u: dict<any>): number
  if t.DiscrName == u.DiscrName
    return 0
  else
    return CompareDistinct(t.DiscrName, u.DiscrName)
  endif
enddef

def CompareByDiscrValueAndHiGroupName(t: dict<any>, u: dict<any>): number
  if t.DiscrValue == u.DiscrValue
    return CompareByHiGroupName(t, u)
  elseif t.DiscrValue == NO_DISCR_VALUE
    return 1
  elseif u.DiscrValue == NO_DISCR_VALUE
    return -1
  else
    return CompareDistinct(t.DiscrValue, u.DiscrValue)
  endif
enddef

def LinkedGroupToString(t: dict<any>, indent = 0): string
  if empty(t.TargetGroup)
    return null_string  # Skip definition
  endif

  return printf(
    "%shi! link %s %s", repeat(' ', indent), t.HiGroupName, t.TargetGroup
  )
enddef

def AttributesToString(t: dict<any>, meta: dict<any>, termgui: bool): list<string>
  var attributes = []

  # If the variant supports color attribute `key`, and if the highlight group
  # has a value for it, map the color and add it to the definition
  for key in ['Fg', 'Bg', 'Special']
    if !empty(meta[key]) && !empty(t[key])
      const colorValue: string = meta.Colors[t[key]]
      if !empty(colorValue) && (meta[key] != 'ctermul' || colorValue != 'NONE')
        attributes->add(meta[key] .. '=' .. colorValue)
      endif
    endif
  endfor

  # Do the same for the other (non-color) attributes (no mapping needed)
  if !empty(meta.Style) && !empty(t.Style)
    attributes->add(meta.Style .. '=' .. t.Style)

    if termgui
      attributes->add('cterm=' .. t.Style)
    endif
  endif

  for key in ['Font', 'Start', 'Stop']
    if !empty(meta[key]) && !empty(t[key])
      attributes->add(meta[key] .. '=' .. t[key])
    endif
  endfor

  return attributes
enddef

def BaseGroupToString(t: dict<any>, meta: dict<any>, indent = 0, termgui: bool = false): string
  const space = repeat(' ', indent)
  const attrs = AttributesToString(t, meta, termgui)

  if empty(attrs)
    return null_string  # Skip definition
  endif

  const hiGroupDef = ['hi', t.HiGroupName] + attrs

  return space .. join(hiGroupDef, ' ')
enddef

# Convert a higlight group tuple into a string.
#
# t       A tuple with enough information to generate a highlight group
#         definition (for example, a tuple from Database.BaseGroup).
# meta    Variant metadata from Database.GetVariantMetadata()
def HiGroupToString(t: dict<any>, meta: dict<any>, indent = 0): string
  if t->has_key('TargetGroup') && !empty(t.TargetGroup)
    return LinkedGroupToString(t, indent)
  endif

  return BaseGroupToString(t, meta, indent)
enddef

def AddMeta(
    header: list<string>, text: string, comment: string, value: string
): list<string>
  if !empty(value)
    header->add(printf(text, comment, value))
  endif

  return header
enddef

def AddList(
    header: list<string>, text: string, comment: string, items: list<string>
): list<string>
  if !empty(items)
    header->AddMeta(text, comment, items[0])

    const n = len(items)
    const space = repeat(' ', 15)
    var i = 1
    while i < n
      header->add(printf('%s%s%s', comment, space, items[i]))
      ++i
    endwhile
  endif

  return header
enddef
# }}}

export class Generator
  this.theme:  Colorscheme

  this._backend:      string
  this._shiftwidth:   number
  this._comment:      string = '#'
  this._letKeyword:   string = ''
  this._constKeyword: string = 'const '
  this._varPrefix:    string = ''

  def new(this.theme)
    this._backend    = this.theme.options.backend
    this._shiftwidth = this.theme.options.shiftwidth

    if this._backend == 'legacy'
      this._comment      = '"'
      this._letKeyword   = 'let '
      this._constKeyword = 'let '
      this._varPrefix    = 's:'
    endif
  enddef

  def Generate(): list<string>
    var output: list<string> = []

    output += this.Header()
    output += this.Emit('dark')
    output += this.Emit('light')
    output += this.Footer()

    return output
  enddef

  def Header(): list<string>
    const theme = this.theme
    const license = empty(theme.license) ? 'Vim License (see `:help license`)' : theme.license
    var header: list<string> = this._backend == 'vim9' ? ['vim9script', ''] : []

    header->AddMeta('%s Name:         %s', this._comment, theme.fullname)
    header->AddMeta('%s Version:      %s', this._comment, theme.version)
    header->AddList('%s Description:  %s', this._comment, theme.description)
    header->AddList('%s Authors:      %s', this._comment, theme.author)
    header->AddList('%s Maintainers:  %s', this._comment, theme.maintainer)
    header->AddList('%s URLs:         %s', this._comment, theme.url)
    header->AddMeta('%s License:      %s', this._comment, theme.license)

    if theme.options.timestamp
      header->AddMeta('%s Last Updated: %s', this._comment, strftime("%c"))
    endif

    header->add('')

    if theme.options.creator
      header->AddMeta('%s Generated by Colortemplate v%s', this._comment, VERSION)
      header->add('')
    endif

    if !theme.backgrounds.light
      header->add('set background=dark')->add('')
    elseif !theme.backgrounds.dark
      header->add('set background=light')->add('')
    endif

    header->add('hi clear')
    header->add(printf("%sg:colors_name = '%s'", this._letKeyword, theme.shortname))

    if !empty(theme.verbatimtext)
      header->add('')
      header += theme.verbatimtext
    endif

    return header
  enddef

  def Footer(): list<string>
    const theme = this.theme
    var sourceComments = ['']


    if theme.options.palette
      const commentSymbol = theme.options.backend == 'legacy' ? '" ' : '# '

      for background in ['dark', 'light']
        if theme.HasBackground(background)
          const db = theme.Db(background)
          const palette = db.Color
            ->ra.Select((t) => !empty(t.ColorName) && t.ColorName != 'none' && t.ColorName != 'fg' && t.ColorName != 'bg')
            ->ra.SortBy('ColorName')

          sourceComments->add(printf('%sBackground: %s', commentSymbol, background))
          sourceComments->add(commentSymbol)
          sourceComments += map(split(
            ra.Table(palette, ['ColorName', 'GUIValue', 'Base256Value', 'Base256HexValue', 'Base16Value']),
            "\n"), (_, v) => commentSymbol .. v)
          sourceComments->add('')
        endif
      endfor
    endif

    return sourceComments + [
      printf('%s vim: et ts=8 sw=%s sts=%s',
        this._comment,
        this._shiftwidth,
        this._shiftwidth
      )
    ]
  enddef

  def Emit(background: string, indent = 0): list<string>
    const theme = this.theme

    if !theme.HasBackground(background)
      return []
    endif

    const db           = theme.Db(background)
    const metaGui      = db.GetVariantMetadata('gui')
    const globalLinked = db.LinkedGroup->Sort(CompareByHiGroupName)
    const globalBaseGr = db.BaseGroup  ->Sort(CompareByHiGroupName)

    var nextIndent = indent
    var defs:   list<string> = []
    var output: list<string> = []

    if theme.IsLightAndDark()
      output += this.StartBackground(db.background, indent)
      nextIndent += this._shiftwidth
    endif

    output->add(printf('%s%sg:terminal_ansi_colors = %s',
      repeat(' ', nextIndent), this._letKeyword, string(db.termcolors))
    )
    output->add('')

    if !empty(db.verbatimtext)
      output += mapnew(db.verbatimtext, (_, l) => empty(l) ? l : repeat(' ', nextIndent) .. l)
      output->add('')
    endif

    output += this.GenerateDiscriminators(background, nextIndent)
    output->add('')
    defs = globalLinked->Transform((t) => LinkedGroupToString(t, nextIndent))

    if !empty(defs)
      output += defs->add('')
    endif

    output += globalBaseGr->Transform((t) => BaseGroupToString(t, metaGui, nextIndent, false))

    # Add variant-specific definitions and overrides, in the specified order
    for variant in ['gui', '256', '88', '16', '8', '0']
      if variant->In(theme.variants)
        output += this.GenerateVariant(background, variant, nextIndent, variant == 'gui')
      endif
    endfor

    if theme.IsLightAndDark()
      output += this.EndBackground(indent)
    endif

    return output
  enddef

  def GenerateVariant(background: string, variant: string, indent: number, onlyOverrides = false): list<string>
    const db          = this.theme.Db(background)
    const variantMeta = db.GetVariantMetadata(variant)
    const nextIndent  = indent + this._shiftwidth

    var defaultDefs: list<dict<any>>
    var defs:        list<string>    = []
    var output:      list<string>    = []

    if onlyOverrides
      defaultDefs = db.VariantSpecificDefinitions(variant)->sort(CompareByHiGroupName)
    else
      defaultDefs = db.DefaultDefinitions(variant)
      # Remove default linked groups because they are added globally
      filter(defaultDefs, (_, t) => t->has_key('Fg') || t->has_key('Variant'))
      defaultDefs->sort(CompareByHiGroupName)
    endif

    defs  = defaultDefs->mapnew((_, t) => HiGroupToString(t, variantMeta, nextIndent))
    defs += this.GenerateOverridingDefinitions(background, variantMeta, nextIndent)

    if !empty(defs)
      output->add('')
      output += this.StartVariant(variantMeta, indent)
      output += defs
      output += this.EndVariant(variantMeta, background, indent)
    endif

    return output
  enddef

  def GenerateDiscriminators(background: string, indent: number): list<string>
    const db = this.theme.Db(background)

    return db.Discriminators()->Transform(
      (t) => this.DiscriminatorToString(t, indent)
    )
  enddef

  def DiscriminatorToString(t: dict<any>, indent: number): string
    const space = repeat(' ', indent)
    return printf(
      '%s%s%s%s = %s', space, this._constKeyword, this._varPrefix, t.DiscrName, t.Definition
    )
  enddef

  def GenerateOverridingDefinitions(background: string, variantMeta: dict<any>, indent: number): list<string>
    const db                                = this.theme.Db(background)
    var   overrides:  dict<list<dict<any>>> = db.OverridingDefsByDiscrName(variantMeta.Variant)
    const discrNames: list<string>          = keys(overrides)->sort()
    var   defs:       list<string>          = []
    const space:      string                = repeat(' ', indent)

    for discrName in discrNames
      const hiGroups = overrides[discrName]->sort(CompareByDiscrValueAndHiGroupName)

      if empty(hiGroups)
        continue
      endif

      var discrValue = hiGroups[0].DiscrValue

      defs->add(printf("%sif %s%s == %s", space, this._varPrefix, discrName, discrValue))

      for t in hiGroups
        if t.DiscrValue != discrValue
          discrValue = t.DiscrValue
          defs->add(printf("%selseif %s%s == %s", space, this._varPrefix, discrName, discrValue))
        endif
        const overridingDef = HiGroupToString(t, variantMeta, indent + this._shiftwidth)
        defs->add(overridingDef)
      endfor

      defs->add(space .. 'endif')
    endfor

    return defs
  enddef

  def StartBackground(background: string, indent: number): list<string>
    const space = repeat(' ', indent)
    return ['', printf("%sif &background == '%s'", space, background)]
  enddef

  def EndBackground(indent: number): list<string>
    const space = repeat(' ', indent)
    return [space .. 'endif']
  enddef

  def StartVariant(variantMeta: dict<any>, indent: number): list<string>
    const space  = repeat(' ', indent)

    if variantMeta.Variant == 'gui'
      return [space .. "if has('gui_running')"]
    endif

    return [printf('%sif str2nr(&t_Co) >= %s', space, variantMeta.NumColors)]
  enddef

  def EndVariant(variantMeta: dict<any>, background: string, indent: number): list<string>
    const space  = repeat(' ', indent)

    if variantMeta.Variant == 'gui'
      return [space .. 'endif']
    endif

    const doublespace = space .. repeat(' ', this._shiftwidth)
    var output: list<string> = []

    if this._backend == 'legacy'
      const db = this.theme.Db(background)
      const discriminators = db.Discriminators()

      for t in discriminators
        output->add(doublespace .. 'unlet s:' .. t.DiscrName)
      endfor
    endif

    output += [doublespace .. 'finish', space .. 'endif']

    return output
  enddef
endclass

# vim: foldmethod=marker nowrap et ts=2 sw=2
