vim9script

import 'librelalg.vim'  as ra
import 'libversion.vim' as vv

vv.Require('librelalg', ra.version, '0.1.0-alpha')

# Aliases {{{
type Attr           = ra.Attr
type Tuple          = ra.Tuple
type Rel            = ra.Rel
type Relation       = ra.Relation

const Bool          = ra.Bool
const DictTransform = ra.DictTransform
const EquiJoin      = ra.EquiJoin
const FailedMsg     = ra.FailedMsg
const Float         = ra.Float
const ForeignKey    = ra.ForeignKey
const Int           = ra.Int
const LeftEquiJoin  = ra.LeftEquiJoin
const PartitionBy   = ra.PartitionBy
const Query         = ra.Query
const References    = ra.References
const Select        = ra.Select
const SortBy        = ra.SortBy
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
def IsValidColorName(t: Tuple): bool
  if t.ColorName == 'none' ||
     t.ColorName == 'fg'   ||
     t.ColorName == 'bg'   ||
     t.ColorName == 'omit'
    FailedMsg($"'{t.ColorName}' is a reserved name and cannot be used as a color name")

    return false
  endif

  return true
enddef

def IsValidBase256Value(t: Tuple): bool
  # This works even if the value is a name rather than a number: str2nr() returns 0
  var n = str2nr(t.Base256Value)

  if n > 255 || n < 0
    FailedMsg($'Base-256 value must be in [0,255]: {t.Base256Value} is invalid')

    return false
  endif

  return true
enddef
# }}}

export class Database
  public var background:   string
  public var termcolors:   list<string> = []
  public var verbatimtext: list<string> = []

  var Variant = Rel.new('Variant', {
    Variant:   Str,
    NumColors: Int,
  }, 'Variant'
  ).InsertMany([
    {Variant:     'gui', NumColors: 16777216},
    {Variant:     '256', NumColors:      256},
    {Variant:      '88', NumColors:       88},
    {Variant:      '16', NumColors:       16},
    {Variant:       '8', NumColors:        8},
    {Variant:       '0', NumColors:        0},
  ])

  var VariantAttribute = Rel.new("Variant's Attribute", {
    Variant:  Str,
    AttrType: Str,
    AttrKey:  Str,
  },
  [['Variant', 'AttrKey'], ['Variant', 'AttrType']]
  ).InsertMany([
    {Variant: 'gui',     AttrType: 'Fg',      AttrKey: 'guifg'  },
    {Variant: 'gui',     AttrType: 'Bg',      AttrKey: 'guibg'  },
    {Variant: 'gui',     AttrType: 'Special', AttrKey: 'guisp'  },
    {Variant: 'gui',     AttrType: 'Style',   AttrKey: 'gui'    },
    {Variant: 'gui',     AttrType: 'Font',    AttrKey: 'font'   },
    {Variant: '256',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Variant: '256',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Variant: '256',     AttrType: 'Special', AttrKey: 'ctermul'},
    {Variant: '256',     AttrType: 'Style',   AttrKey: 'cterm'  },
    {Variant:  '88',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Variant:  '88',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Variant:  '88',     AttrType: 'Special', AttrKey: 'ctermul'},
    {Variant:  '88',     AttrType: 'Style',   AttrKey: 'cterm'  },
    {Variant:  '16',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Variant:  '16',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Variant:  '16',     AttrType: 'Special', AttrKey: 'ctermul'},
    {Variant:  '16',     AttrType: 'Style',   AttrKey: 'cterm'  },
    {Variant:   '8',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Variant:   '8',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Variant:   '8',     AttrType: 'Special', AttrKey: 'ctermul'},
    {Variant:   '8',     AttrType: 'Style',   AttrKey: 'cterm'  },
    {Variant:   '0',     AttrType: 'Style',   AttrKey: 'term'   },
    {Variant:   '0',     AttrType: 'Start',   AttrKey: 'start'  },
    {Variant:   '0',     AttrType: 'Stop',    AttrKey: 'stop'   },
  ])

  var Color = Rel.new('Color', {
    ColorName:       Str,
    GUIValue:        Str,
    Base256Value:    Str,
    Base256HexValue: Str,
    Base16Value:     Str,
  }, 'ColorName'
  ).InsertMany([
    {ColorName: '',     GUIValue: '',     Base256Value: '',     Base256HexValue: '', Base16Value: '',   },
    {ColorName: 'none', GUIValue: 'NONE', Base256Value: 'NONE', Base256HexValue: '', Base16Value: 'NONE'},
    {ColorName: 'fg',   GUIValue: 'fg',   Base256Value: 'fg',   Base256HexValue: '', Base16Value: 'fg', },
    {ColorName: 'bg',   GUIValue: 'bg',   Base256Value: 'bg',   Base256HexValue: '', Base16Value: 'bg', }
  ])

  var Discriminator = Rel.new('Discriminator', {
    DiscrName:  Str,
    Definition: Str,
    DiscrNum:   Int,
  }, [['DiscrName'], ['DiscrNum']]
  ).InsertMany([
    {DiscrName: '', Definition: '', DiscrNum: 0},
  ])

  var HiGroup = Rel.new('Highlight Group', {
    HiGroupName: Str,
    DiscrName:   Str,
    IsLinked:    Bool,
  }, 'HiGroupName')

  var LinkedGroup = Rel.new('Linked Group', {
    HiGroupName: Str,
    TargetGroup: Str,
  }, ['HiGroupName'])

  var BaseGroup: Rel = Rel.new('Base Group', {
    HiGroupName: Str,
    Fg:          Str,
    Bg:          Str,
    Special:     Str,
    Style:       Str,
    Font:        Str,
    Start:       Str,
    Stop:        Str,
  }, ['HiGroupName'])

  var HiGroupOverride: Rel = Rel.new('Hi Group Override', {
    HiGroupName: Str,
    Variant:     Str,
    DiscrValue:  Str,
    IsLinked:    Bool,
  }, ['HiGroupName', 'Variant', 'DiscrValue'])

  var LinkedGroupOverride: Rel = Rel.new('Linked Group Override', {
    HiGroupName: Str,
    Variant:     Str,
    DiscrValue:  Str,
    TargetGroup: Str,
  }, ['HiGroupName', 'Variant', 'DiscrValue'])

  var BaseGroupOverride: Rel = Rel.new('Base Group Override', {
    HiGroupName: Str,
    Variant:     Str,
    DiscrValue:  Str,
    Fg:          Str,
    Bg:          Str,
    Special:     Str,
    Style:       Str,
    Font:        Str,
    Start:       Str,
    Stop:        Str,
  }, ['HiGroupName', 'Variant', 'DiscrValue'])

  def new(this.background)
    this.Color.OnInsertCheck('Valid color', IsValidColorName)
    this.Color.OnInsertCheck('Valid 256-based color', IsValidBase256Value)

    ForeignKey(this.HiGroup,             'DiscrName'                             )-> References(this.Discriminator,   {verb: 'is classified by'})
    ForeignKey(this.LinkedGroup,         'HiGroupName'                           )-> References(this.HiGroup,         {verb: 'is a'})
    ForeignKey(this.BaseGroup,           'HiGroupName'                           )-> References(this.HiGroup,         {verb: 'is a'})
    ForeignKey(this.BaseGroup,           'Fg'                                    )-> References(this.Color,           {verb: 'uses as foreground a'})
    ForeignKey(this.BaseGroup,           'Bg'                                    )-> References(this.Color,           {verb: 'must use as background a valid'})
    ForeignKey(this.BaseGroup,           'Special'                               )-> References(this.Color,           {verb: 'must use as special color a valid'})
    ForeignKey(this.HiGroupOverride,     'HiGroupName'                           )-> References(this.HiGroup,         {verb: 'must override an existing'})
    ForeignKey(this.HiGroupOverride,     'Variant'                               )-> References(this.Variant,         {verb: 'must refer to a valid'})
    ForeignKey(this.LinkedGroupOverride, ['HiGroupName', 'Variant', 'DiscrValue'])-> References(this.HiGroupOverride, {verb: 'must be a'})
    ForeignKey(this.BaseGroupOverride,   ['HiGroupName', 'Variant', 'DiscrValue'])-> References(this.HiGroupOverride, {verb: 'must be a'})
    ForeignKey(this.BaseGroupOverride,   'Fg'                                    )-> References(this.Color,           {verb: 'must use as foreground a valid'})
    ForeignKey(this.BaseGroupOverride,   'Bg'                                    )-> References(this.Color,           {verb: 'must use as background a valid'})
    ForeignKey(this.BaseGroupOverride,   'Special'                               )-> References(this.Color,           {verb: 'must use as special color a valid'})
  enddef

  def GetColor(name: string, kind: string): string
    const t = this.Color.Lookup(['ColorName'], [name])

    if empty(t)
      return ''
    endif

    return t[ColorKind[kind]]
  enddef

  def Color16(name: string): string
    return this.GetColor(name, '16')
  enddef

  def Color256(name: string): string
    return this.GetColor(name, '256')
  enddef

  def ColorGui(name: string): string
    return this.GetColor(name, 'gui')
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
  # example, for the '256' variant, this would be:
  #
  #    {
  #      Variant:    '256',
  #      NumColors:  256,
  #      ColorAttr:  'Base256Value',
  #      Colors:     {colname1: '50', ..., colnameN: '253'},
  #      Fg:         'ctermfg',
  #      Bg:         'ctermbg',
  #      Special:    'ctermul',
  #      Style:      'cterm',
  #      Font:       '',
  #      Start:      '',
  #      Stop:       '',
  #      GuiColors:  {
  #                     Colors:  {colname1: #111111, ..., colnameN: #nnnnnn},
  #                     Fg:      'guifg',
  #                     Bg:      'guibg',
  #                     Special: 'guisp',
  #                  }
  #    }
  def GetVariantMetadata(variant: string): dict<any>
    const numColors = this.Variant.Lookup(['Variant'], [variant]).NumColors
    const colorAttr = numColors <= 16 ? 'Base16Value' : numColors <= 256 ? 'Base256Value' : 'GUIValue'
    var   metadata  = {
      Variant:   variant,
      NumColors: numColors,
      ColorAttr: colorAttr,
      Colors:    this.Color->DictTransform((t) => ({[t.ColorName]: t[colorAttr]}), true),
      GuiColors: {
        Colors: this.Color->DictTransform((t) => ({[t.ColorName]: t['GUIValue']}), true),
        Fg:      'guifg',
        Bg:      'guibg',
        Special: 'guisp',
      }
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
  ): Tuple
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
  def GetDefaultDef(hiGroupName: string, variant: string): Tuple
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
  ): Tuple
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

  # Return the discriminators in the order they have been defined.
  def Discriminators(): list<dict<any>>
    return this.Discriminator
      ->Select((t) => !empty(t.DiscrName))
      ->SortBy('DiscrNum')
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
  var dark:  Database
  var light: Database

  public var author:       list<string>       = []
  public var description:  list<string>       = []
  public var fullname:     string             = ''
  public var license:      string             = ''
  public var maintainer:   list<string>       = []
  public var shortname:    string             = ''
  public var url:          list<string>       = []
  public var version:      string             = ''
  public var variants:     list<string>       = ['gui']
  public var backgrounds:  dict<bool>         = {'dark': false, 'light': false}
  public var verbatimtext: list<string>       = []
  public var auxfiles:     dict<list<string>> = {}  # path => content
  public var prefix:       string             = ''
  public var options:      dict<any>          = {
    backend:    'vim9',
    creator:    true,
    dateformat: '%Y %b %d',
    palette:    false,
    shiftwidth: 2,
    timestamp:  true,
  }

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

    throw $'Invalid background: {background}'
  enddef
endclass
