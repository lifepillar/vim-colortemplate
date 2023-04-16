vim9script

import 'librelalg.vim' as ra

# Aliases {{{
const Bool          = ra.Bool
const DictTransform = ra.DictTransform
const EquiJoin      = ra.EquiJoin
const Float         = ra.Float
const ForeignKey    = ra.ForeignKey
const Int           = ra.Int
const LeftEquiJoin  = ra.LeftEquiJoin
const PartitionBy   = ra.PartitionBy
const Query         = ra.Query
const Rel           = ra.Rel
const Select        = ra.Select
const Str           = ra.Str
const Transform     = ra.Transform
# }}}

const ColorKind = {
  '16':  'Base16Value',
  '256': 'Base256Value',
  'gui': 'GUIValue',
  '':    'GUIValue',
}

export const DEFAULT_DISCR_VALUE = '__DfLt__'

# Integrity constraints {{{
def IsValidColorName(t: dict<any>)
  if t.ColorName == 'none' ||
     t.ColorName == 'fg'   ||
     t.ColorName == 'bg'   ||
     t.ColorName == 'omit'
    throw printf("'%s' is a reserved name and cannot be used as a color name", t.ColorName)
  endif
enddef

def IsValidBase256Value(t: dict<any>)
  const n = str2nr(t.Base256Value)
  if n > 255 || n < 0
    throw printf('Base-256 value must be in [0,255]: %s is invalid', t.Base256Value)
  endif
enddef
# }}}

export class Database
  public this.background: string
  public this.termcolors: list<string> = []

  this.Variant: Rel = Rel.new('Variant', {
        \   Variant:   Str,
        \   NumColors: Int,
        \ },
        \ 'Variant').InsertMany([
        \   {Variant:     'gui', NumColors: 16777216},
        \   {Variant:     '256', NumColors:      256},
        \   {Variant:      '88', NumColors:       88},
        \   {Variant:      '16', NumColors:       16},
        \   {Variant:       '8', NumColors:        8},
        \   {Variant:       '0', NumColors:        0},
        \ ])

  this.VariantAttribute = Rel.new("Variant's Attribute", {
        \   Variant:  Str,
        \   AttrType: Str,
        \   AttrKey:  Str,
        \ },
        \ [['Variant', 'AttrKey'], ['Variant', 'AttrType']]).InsertMany([
        \   {Variant: 'gui',     AttrType: 'Fg',      AttrKey: 'guifg'  },
        \   {Variant: 'gui',     AttrType: 'Bg',      AttrKey: 'guibg'  },
        \   {Variant: 'gui',     AttrType: 'Special', AttrKey: 'guisp'  },
        \   {Variant: 'gui',     AttrType: 'Style',   AttrKey: 'gui'    },
        \   {Variant: 'gui',     AttrType: 'Font',    AttrKey: 'font'   },
        \   {Variant: '256',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
        \   {Variant: '256',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
        \   {Variant: '256',     AttrType: 'Special', AttrKey: 'ctermul'},
        \   {Variant: '256',     AttrType: 'Style',   AttrKey: 'cterm'  },
        \   {Variant:  '88',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
        \   {Variant:  '88',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
        \   {Variant:  '88',     AttrType: 'Special', AttrKey: 'ctermul'},
        \   {Variant:  '88',     AttrType: 'Style',   AttrKey: 'cterm'  },
        \   {Variant:  '16',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
        \   {Variant:  '16',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
        \   {Variant:  '16',     AttrType: 'Special', AttrKey: 'ctermul'},
        \   {Variant:  '16',     AttrType: 'Style',   AttrKey: 'cterm'  },
        \   {Variant:   '8',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
        \   {Variant:   '8',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
        \   {Variant:   '8',     AttrType: 'Special', AttrKey: 'ctermul'},
        \   {Variant:   '8',     AttrType: 'Style',   AttrKey: 'cterm'  },
        \   {Variant:   '0',     AttrType: 'Style',   AttrKey: 'term'   },
        \   {Variant:   '0',     AttrType: 'Start',   AttrKey: 'start'  },
        \   {Variant:   '0',     AttrType: 'Stop',    AttrKey: 'stop'   },
        \ ])

  this.Color = Rel.new('Color', {
        \   ColorName:       Str,
        \   GUIValue:        Str,
        \   Base256Value:    Str,
        \   Base256HexValue: Str,
        \   Base16Value:     Str,
        \   Delta:           Float,
        \ }, 'ColorName').InsertMany([
        \   {ColorName: 'omit', GUIValue: '',     Base256Value: '',     Base256HexValue: '', Base16Value: '',     Delta: 0.0},
        \   {ColorName: 'none', GUIValue: 'NONE', Base256Value: 'NONE', Base256HexValue: '', Base16Value: 'NONE', Delta: 0.0},
        \   {ColorName: 'fg',   GUIValue: 'fg',   Base256Value: 'fg',   Base256HexValue: '', Base16Value: 'fg',   Delta: 0.0},
        \   {ColorName: 'bg',   GUIValue: 'bg',   Base256Value: 'bg',   Base256HexValue: '', Base16Value: 'bg',   Delta: 0.0}
        \ ])

  # The tuple with t_Co prevents overriding Colortemplate's definition
  this.Discriminator = Rel.new('Discriminator', {
        \ DiscrName:  Str,
        \ Definition: Str,
        \ },
        \ 'DiscrName').InsertMany([
        \   {DiscrName: '',     Definition: ''},
        \   {DiscrName: 't_Co', Definition: ''},
        \ ])

  this.HiGroup = Rel.new('Highlight Group', {
        \   HiGroupName: Str,
        \   DiscrName:   Str,
        \   IsLinked:    Bool,
        \ },
        \ 'HiGroupName')

  this.LinkedGroup = Rel.new('Linked Group', {
        \   HiGroupName: Str,
        \   TargetGroup: Str,
        \ },
        \ ['HiGroupName'])

  this.BaseGroup = Rel.new('Base Group', {
        \   HiGroupName: Str,
        \   Fg:          Str,
        \   Bg:          Str,
        \   Special:     Str,
        \   Style:       Str,
        \   Font:        Str,
        \   Start:       Str,
        \   Stop:        Str,
        \ },
        \ ['HiGroupName'])

  this.HiGroupOverride = Rel.new('Hi Group Override', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \   IsLinked:    Bool,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue'])

  this.LinkedGroupOverride = Rel.new('Linked Group Override', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \   TargetGroup: Str,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue'])

  this.BaseGroupOverride = Rel.new('Base Group Override', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \   Fg:          Str,
        \   Bg:          Str,
        \   Special:     Str,
        \   Style:       Str,
        \   Font:        Str,
        \   Start:       Str,
        \   Stop:        Str,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue'])

  def new(this.background)
    this.Color.Check(IsValidColorName)
    this.Color.Check(IsValidBase256Value)

    ForeignKey(this.HiGroup,             'must be classified by a',           this.Discriminator,    ['DiscrName'])
    ForeignKey(this.LinkedGroup,         'must be a',                         this.HiGroup,          ['HiGroupName'])
    ForeignKey(this.BaseGroup,           'must be a',                         this.HiGroup,          ['HiGroupName'])
    ForeignKey(this.BaseGroup,           'must use as foreground a valid',    this.Color,            ['Fg'], ['ColorName'])
    ForeignKey(this.BaseGroup,           'must use as background a valid',    this.Color,            ['Bg'], ['ColorName'])
    ForeignKey(this.BaseGroup,           'must use as special color a valid', this.Color,            ['Special'], ['ColorName'])
    ForeignKey(this.HiGroupOverride,     'must override an existing',         this.HiGroup,          ['HiGroupName'])
    ForeignKey(this.HiGroupOverride,     'must refer to a valid',             this.Variant,          ['Variant'])
    ForeignKey(this.LinkedGroupOverride, 'must be a',                         this.HiGroupOverride,  ['HiGroupName', 'Variant', 'DiscrValue'])
    ForeignKey(this.BaseGroupOverride,   'must be a',                         this.HiGroupOverride,  ['HiGroupName', 'Variant', 'DiscrValue'])
    ForeignKey(this.BaseGroupOverride,   'must use as foreground a valid',    this.Color,            ['Fg'], ['ColorName'])
    ForeignKey(this.BaseGroupOverride,   'must use as background a valid',    this.Color,            ['Bg'], ['ColorName'])
    ForeignKey(this.BaseGroupOverride,   'must use as special color a valid', this.Color,            ['Special'], ['ColorName'])
  enddef

  def GetColor(name: string, kind: string): string
    const t = this.Color.Lookup(['ColorName'], [name])

    if empty(t)
      return ''
    endif

    return t[ColorKind[kind]]
  enddef

  def Color16(name: string): string
    return this.GetColor(t, '16')
  enddef

  def Color256(name: string): string
    return this.GetColor(t, '256')
  enddef

  def ColorGui(name: string): string
    return this.GetColor(t, 'gui')
  enddef

  def InsertDefaultLinkedGroup(
    hiGroupName: string,
    targetGroup: string
  )
    this.HiGroup.Insert({
      HiGroupName: hiGroupName,
      DiscrName:   '',
      IsLinked:    true,
    })
    this.LinkedGroup.Insert({
      HiGroupName: hiGroupName,
      TargetGroup: targetGroup,
    })
  enddef

  def InsertLinkedGroupOverride(
    variant:     string,
    discrValue:  string,
    hiGroupName: string,
    targetGroup: string,
  )
    this.HiGroupOverride.Insert({
      HiGroupName: hiGroupName,
      Variant:     variant,
      DiscrValue:  discrValue,
      IsLinked:    true,
    })
    this.LinkedGroupOverride.Insert({
      HiGroupName: hiGroupName,
      Variant:     variant,
      DiscrValue:  discrValue,
      TargetGroup: targetGroup,
    })
  enddef

  def InsertDefaultBaseGroup(
    hiGroupName: string,
    fgColor:     string,
    bgColor:     string,
    spColor:     string,
    attributes:  string,
    font:        string = '',
    start:       string = '',
    stop:        string = ''
  )
    this.HiGroup.Insert({
      HiGroupName: hiGroupName,
      DiscrName:   '',
      IsLinked:    false,
    })
    this.BaseGroup.Insert({
      HiGroupName: hiGroupName,
      Fg:          fgColor,
      Bg:          bgColor,
      Special:     spColor,
      Style:       attributes,
      Font:        font,
      Start:       start,
      Stop:        stop,
    })
  enddef

  def InsertBaseGroupOverride(
    variant:     string,
    discrValue:  string,
    hiGroupName: string,
    fgColor:     string,
    bgColor:     string,
    spColor:     string,
    attributes:  string,
    font:        string = '',
    start:       string = '',
    stop:        string = ''

  )
    this.HiGroupOverride.Insert({
      HiGroupName: hiGroupName,
      Variant:     variant,
      DiscrValue:  discrValue,
      IsLinked:    false,
    })
    this.BaseGroupOverride.Insert({
      HiGroupName: hiGroupName,
      Variant:     variant,
      DiscrValue:  discrValue,
      Fg:          fgColor,
      Bg:          bgColor,
      Special:     spColor,
      Style:       attributes,
      Font:        font,
      Start:       start,
      Stop:        stop,
    })
  enddef

  # Retrieve the relevant metadata for the given variant, including the names
  # of the attributes for the specified variant. An empty string indicates
  # that the variant does not support the corresponding attribute. For
  # example, for the 'gui' variant, this would be:
  #
  #    {
  #      Variant:   'gui',
  #      NumColors: 16777216,
  #      ColorAttr: 'GUIValue',
  #      Colors:    {colname1: #111111, ..., colnameN: #nnnnnn},
  #      Fg:        'guifg',
  #      Bg:        'guibg',
  #      Special:   'guisp',
  #      Style:     'gui',
  #      Font:      'font',
  #      Start:     '',
  #      Stop:      '',
  #    }
  def GetVariantMetadata(variant: string): dict<any>
    const numColors = this.Variant.Lookup(['Variant'], [variant]).NumColors
    const colorAttr = numColors <= 16 ? 'Base16Value' : numColors <= 256 ? 'Base256Value' : 'GUIValue'
    var   metadata  = {
      Variant:   variant,
      NumColors: numColors,
      ColorAttr: colorAttr,
      Colors:    this.Color->DictTransform((t) => ({[t.ColorName]: t[colorAttr]}), true),
    }

    for key in ['Fg', 'Bg', 'Special', 'Style', 'Font', 'Start', 'Stop']
      metadata[key] = get(
        this.VariantAttribute.Lookup(['Variant', 'AttrType'], [variant, key]),
        'AttrKey',
        ''
      )
    endfor

    return metadata
  enddef

  # Return the tuple corresponding to the correct definition for the specified
  # highlight group, variant, and discriminator value.
  #
  # Parameters:
  #
  # hiGroupName  The name of a highlight group (e.g., 'Normal')
  # variant      The name of a variant (e.g., 'gui', '256', '16', etc.)
  # discrValue   [optional] The value of the discriminator associated to the
  #              highlight group.
  #
  # Returns:
  #   a tuple containing the pieces of information that are needed to build
  #   the requested highlight group definition. The caller should always check
  #   whether the result is empty, which may happen if the input values are
  #   invalid or if no overriding definition exists for a given non-default
  #   discriminator value.
  def HiGroupDef(
      hiGroupName: string, variant: string, discrValue: string = DEFAULT_DISCR_VALUE
  ): dict<any>
    if discrValue == DEFAULT_DISCR_VALUE
      return this.GetDefaultDef(hiGroupName, variant)
    endif

    return this.GetOverrideDef(hiGroupName, variant, discrValue)
  enddef

  # Return the tuple corresponding to the default definition for the given
  # variant. This may be the global default definition or a variant-specific
  # override if it exists (e.g., `Comment/256 fgColor bgColor`).
  #
  # Parameters:
  #
  # hiGroupName  The name of a highlight group (e.g., 'Normal')
  # variant      The name of a variant (e.g., 'gui', '256', '16', etc.)
  #
  # Returns:
  #   a tuple containing the pieces of information that are needed to build
  #   the requested highlight group definition.
  def GetDefaultDef(hiGroupName: string, variant: string): dict<any>
    var t = this.GetOverrideDef(hiGroupName, variant, DEFAULT_DISCR_VALUE)

    if empty(t)  # Look for the global default definition
      t = this.BaseGroup.Lookup(['HiGroupName'], [hiGroupName])

      if empty(t)
        t = this.LinkedGroup.Lookup(['HiGroupName'], [hiGroupName])
      endif
    endif

    return t
  enddef

  # Return the tuple corresponding to an overriding definition for the given
  # variant and discriminator value.
  #
  # Parameters:
  #
  # hiGroupName  The name of a highlight group (e.g., 'Normal')
  # variant      The name of a variant (e.g., 'gui', '256', '16', etc.)
  # discrValue   The value of the discriminator associated to the highlight
  #              group.
  #
  # Returns:
  #   a tuple containing the pieces of information that are needed to build
  #   the requested highlight group definition. When an overriding definition
  #   matching the input cannot be found, an empty tuple is returned.
  def GetOverrideDef(
      hiGroupName: string, variant: string, discrValue: string
  ): dict<any>
    const t = this.HiGroupOverride.Lookup(
      ['HiGroupName', 'Variant', 'DiscrValue'],
      [hiGroupName, variant, discrValue]
    )

    if empty(t)
      return t
    endif

    if t.IsLinked
      return this.LinkedGroupOverride.Lookup(
        ['HiGroupName', 'Variant', 'DiscrValue'],
        [hiGroupName, variant, discrValue]
      )
    endif

    return this.BaseGroupOverride.Lookup(
        ['HiGroupName', 'Variant', 'DiscrValue'],
        [hiGroupName, variant, discrValue]
      )
  enddef

  def Discriminators(): list<dict<any>>
    return Query(
      this.Discriminator
      ->Select((t) => !empty(t.DiscrName) && t.DiscrName != 't_Co')
    )
  enddef

  # Return all the default definitions for the given variant. Note that the
  # result is NOT a relation, because it is a list of heterogeneous tuples.
  def DefaultDefinitions(variant: string): list<dict<any>>
    return this.HiGroup->Transform((t) => this.GetDefaultDef(t.HiGroupName, variant))
  enddef

  # Return only variant-specific definitions for the given variant, except
  # those that depend on a discriminator. Note that the result is NOT
  # a relation.
  def VariantSpecificDefinitions(variant: string): list<dict<any>>
      return Query(
        this.HiGroupOverride
        ->Select((t) => t.DiscrValue == DEFAULT_DISCR_VALUE && t.Variant == variant)
        ->LeftEquiJoin(this.LinkedGroupOverride,
          ['HiGroupName', 'Variant', 'DiscrValue'],
          ['HiGroupName', 'Variant', 'DiscrValue'], [{}])
        ->LeftEquiJoin(this.BaseGroupOverride,
          ['HiGroupName', 'Variant', 'DiscrValue'],
          ['HiGroupName', 'Variant', 'DiscrValue'], [{}])
      )
  enddef

  # Return the discriminator-based definitions for the given variant. The
  # returned value is a dictionary of list of heterogeneous tuples, keyed
  # by discriminator's name.
  def OverridingDefsByDiscrName(variant: string): dict<list<dict<any>>>
    return this.HiGroupOverride
      ->Select((t) => t.Variant == variant && t.DiscrValue != DEFAULT_DISCR_VALUE)
      ->EquiJoin(this.HiGroup, ['HiGroupName'], ['HiGroupName'])
      ->LeftEquiJoin(this.LinkedGroupOverride,
        ['HiGroupName', 'Variant', 'DiscrValue'],
        ['HiGroupName', 'Variant', 'DiscrValue'], [{}])
      ->LeftEquiJoin(this.BaseGroupOverride,
        ['HiGroupName', 'Variant', 'DiscrValue'],
        ['HiGroupName', 'Variant', 'DiscrValue'], [{}])
      ->PartitionBy('DiscrName')
  enddef
endclass

export class Colorscheme
  this.dark:  Database
  this.light: Database

  public this.author:       list<string>       = []
  public this.description:  list<string>       = []
  public this.fullname:     string             = ''
  public this.license:      string             = ''
  public this.maintainer:   list<string>       = []
  public this.shortname:    string             = ''
  public this.url:          list<string>       = []
  public this.version:      string             = ''
  public this.variants:     list<string>       = ['gui']
  public this.backgrounds:  dict<bool>         = {'dark': false, 'light': false}
  public this.verbatimtext: list<string>       = []
  public this.auxfiles:     dict<list<string>> = {}  # path => content
  public this.options:      dict<any>          = {backend: 'vim9', creator: true, shiftwidth: 2}
  public this.prefix:       string             = ''

  def new()
    this.dark = Database.new('dark')
    this.light = Database.new('light')
  enddef

  def IsLightAndDark(): bool
    return this.backgrounds['dark'] && this.backgrounds['light']
  enddef

  def HasBackground(background: string): bool
    return this.backgrounds[background]
  enddef

  def Db(background: string): Database
    if background == 'dark'
      return this.dark
    elseif background == 'light'
      return this.light
    endif

    throw 'Invalid background: ' .. background
    return Database.new('')  # Silence a Vim "Missing return statement" error
  enddef
endclass
