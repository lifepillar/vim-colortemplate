vim9script

import 'librelalg.vim' as ra

# Aliases {{{
const Bool          = ra.Bool
const DictTransform = ra.DictTransform
const Float         = ra.Float
const ForeignKey    = ra.ForeignKey
const Int           = ra.Int
const Rel           = ra.Rel
const Str           = ra.Str
# }}}

export const DEFAULT_DISCR_VALUE = '__DfLt__'

export class Metadata
  public this.author:      list<string> = []
  public this.description: list<string> = []
  public this.fullname:    string       = ''
  public this.license:     string       = ''
  public this.maintainer:  list<string> = []
  public this.pathname:    string       = ''
  public this.shortname:   string       = ''
  public this.url:         list<string> = []
  public this.version:     string       = ''
  public this.variants:    list<string> = []
  public this.backgrounds: dict<bool>   = {'dark': false, 'light': false}
  public this.termcolors:  list<string> = []

  def IsLightAndDark(): bool
    return this.backgrounds['dark'] && this.backgrounds['light']
  enddef

  def HasBackground(background: string): bool
    return this.backgrounds[background]
  enddef
endclass

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
  public this.background:  string

  this.VimHiGroup = Rel.new('Vim Highlight Group', {
        \ HiGroupName: Str,
        \ },
        \ 'HiGroupName').InsertMany([
        \ {HiGroupName: 'ColorColumn',       },
        \ {HiGroupName: 'Comment',           },
        \ {HiGroupName: 'Conceal',           },
        \ {HiGroupName: 'Constant',          },
        \ {HiGroupName: 'Cursor',            },
        \ {HiGroupName: 'CursorColumn',      },
        \ {HiGroupName: 'CursorLine',        },
        \ {HiGroupName: 'CursorLineFold',    },
        \ {HiGroupName: 'CursorLineNr',      },
        \ {HiGroupName: 'CursorLineSign',    },
        \ {HiGroupName: 'DiffAdd',           },
        \ {HiGroupName: 'DiffChange',        },
        \ {HiGroupName: 'DiffDelete',        },
        \ {HiGroupName: 'DiffText',          },
        \ {HiGroupName: 'Directory',         },
        \ {HiGroupName: 'EndOfBuffer',       },
        \ {HiGroupName: 'Error',             },
        \ {HiGroupName: 'ErrorMsg',          },
        \ {HiGroupName: 'FoldColumn',        },
        \ {HiGroupName: 'Folded',            },
        \ {HiGroupName: 'Identifier',        },
        \ {HiGroupName: 'Ignore',            },
        \ {HiGroupName: 'IncSearch',         },
        \ {HiGroupName: 'LineNr',            },
        \ {HiGroupName: 'LineNrAbove',       },
        \ {HiGroupName: 'LineNrBelow',       },
        \ {HiGroupName: 'MatchParen',        },
        \ {HiGroupName: 'MessageWindow',     },
        \ {HiGroupName: 'ModeMsg',           },
        \ {HiGroupName: 'MoreMsg',           },
        \ {HiGroupName: 'NonText',           },
        \ {HiGroupName: 'Normal',            },
        \ {HiGroupName: 'Pmenu',             },
        \ {HiGroupName: 'PmenuKind',         },
        \ {HiGroupName: 'PmenuKindSel',      },
        \ {HiGroupName: 'PmenuExtra',        },
        \ {HiGroupName: 'PmenuExtraSel',     },
        \ {HiGroupName: 'PmenuSbar',         },
        \ {HiGroupName: 'PmenuSel',          },
        \ {HiGroupName: 'PmenuThumb',        },
        \ {HiGroupName: 'PopupNotification', },
        \ {HiGroupName: 'PopupSelected',     },
        \ {HiGroupName: 'PreProc',           },
        \ {HiGroupName: 'Question',          },
        \ {HiGroupName: 'QuickFixLine',      },
        \ {HiGroupName: 'Search',            },
        \ {HiGroupName: 'SignColumn',        },
        \ {HiGroupName: 'Special',           },
        \ {HiGroupName: 'SpecialKey',        },
        \ {HiGroupName: 'SpellBad',          },
        \ {HiGroupName: 'SpellCap',          },
        \ {HiGroupName: 'SpellLocal',        },
        \ {HiGroupName: 'SpellRare',         },
        \ {HiGroupName: 'Statement',         },
        \ {HiGroupName: 'StatusLine',        },
        \ {HiGroupName: 'StatusLineNC',      },
        \ {HiGroupName: 'StatusLineTerm',    },
        \ {HiGroupName: 'StatusLineTermNC',  },
        \ {HiGroupName: 'TabLine',           },
        \ {HiGroupName: 'TabLineFill',       },
        \ {HiGroupName: 'TabLineSel',        },
        \ {HiGroupName: 'Title',             },
        \ {HiGroupName: 'Todo',              },
        \ {HiGroupName: 'ToolbarButton',     },
        \ {HiGroupName: 'ToolbarLine',       },
        \ {HiGroupName: 'Type',              },
        \ {HiGroupName: 'Underlined',        },
        \ {HiGroupName: 'VertSplit',         },
        \ {HiGroupName: 'Visual',            },
        \ {HiGroupName: 'VisualNOS',         },
        \ {HiGroupName: 'WarningMsg',        },
        \ {HiGroupName: 'WildMenu',          },
        \ ])

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
        \   ColorName:    Str,
        \   GUIValue:     Str,
        \   Base256Value: Str,
        \   Base16Value:  Str,
        \   Delta:        Float,
        \ }, [
        \   ['ColorName'],
        \   ['GUIValue', 'Base256Value', 'Base16Value']
        \ ]).InsertMany([
        \   {ColorName: '',     GUIValue: '',     Base256Value: '',     Base16Value: '',     Delta: 0.0},
        \   {ColorName: 'none', GUIValue: 'NONE', Base256Value: 'NONE', Base16Value: 'NONE', Delta: 0.0},
        \   {ColorName: 'fg',   GUIValue: 'fg',   Base256Value: 'fg',   Base16Value: 'fg',   Delta: 0.0},
        \   {ColorName: 'bg',   GUIValue: 'bg',   Base256Value: 'bg',   Base16Value: 'bg',   Delta: 0.0}
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

  def GetVariantMetadata(variant: string): dict<any>
    # Retrieve the relevant metadata for the given variant, including the
    # names of the attributes for the current variant. An empty string
    # indicates that the variant does not support the corresponding attribute.
    # For example, for the 'gui' variant, this would be:
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

  def HiGroupDef(
      hiGroupName: string, variant: string, discrValue: string = DEFAULT_DISCR_VALUE
  ): dict<any>
    # Return the tuple corresponding to the correct definition for the
    # specified highlight group, variant, and discriminator value. To
    # distinguish a linked group from a base group, you may check whether the
    # returned tuple `has_key('TargetGroup')`.
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
    #   the requested highlight group definition. The caller should always
    #   check whether the result is empty, which may happen if the input
    #   values are invalid or if no overriding definition exists for a given
    #   non-default discriminator value.
    if discrValue == DEFAULT_DISCR_VALUE
      return this.GetDefaultDef(hiGroupName, variant)
    endif

    return this.GetOverrideDef(hiGroupName, variant, discrValue)
  enddef

  def GetDefaultDef(hiGroupName: string, variant: string): dict<any>
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
    var t = this.GetOverrideDef(hiGroupName, variant, DEFAULT_DISCR_VALUE)

    if empty(t)  # Look for the global default definition
      t = this.BaseGroup.Lookup(['HiGroupName'], [hiGroupName])

      if empty(t)
        t = this.LinkedGroup.Lookup(['HiGroupName'], [hiGroupName])
      endif
    endif

    return t
  enddef

  def GetOverrideDef(
      hiGroupName: string, variant: string, discrValue: string
  ): dict<any>
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
    #   the requested highlight group definition. When an overriding
    #   definition matching the input cannot be found, an empty tuple is
    #   returned.
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
endclass
