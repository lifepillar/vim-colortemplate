vim9script

import 'librelalg.vim' as ra

# Aliases {{{
const Bool       = ra.Bool
const Float      = ra.Float
const ForeignKey = ra.ForeignKey
const Int        = ra.Int
const Rel        = ra.Rel
const Str        = ra.Str
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
  if t.Base256Value > 255 || t.Base256Value < 0
    throw 'Base-256 value must be in [0,255]'
  endif
enddef
# }}}

export class Database
  public this.background:  string

  this.VimHiGroup = Rel.new('Vim Hi Group', {
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
        \   {Variant: 'termgui', NumColors: 16777216},
        \   {Variant:     '256', NumColors:      256},
        \   {Variant:      '88', NumColors:       88},
        \   {Variant:      '16', NumColors:       16},
        \   {Variant:       '8', NumColors:        8},
        \   {Variant:      'bw', NumColors:        0},
        \   {Variant:       '0', NumColors:        0},
        \ ])

  this.VariantAttribute = Rel.new("Variant Attribute", {
        \   Variant:  Str,
        \   AttrType: Str,
        \   AttrKey:  Str,
        \ },
        \ [['Variant', 'AttrKey'], ['Variant', 'AttrType']]).InsertMany([
        \   {Variant: 'gui',     AttrType: 'fg',    AttrKey: 'guifg'  },
        \   {Variant: 'gui',     AttrType: 'bg',    AttrKey: 'guibg'  },
        \   {Variant: 'gui',     AttrType: 'sp',    AttrKey: 'guisp'  },
        \   {Variant: 'gui',     AttrType: 'style', AttrKey: 'gui'    },
        \   {Variant: 'gui',     AttrType: 'font',  AttrKey: 'font'   },
        \   {Variant: 'termgui', AttrType: 'fg',    AttrKey: 'guifg'  },
        \   {Variant: 'termgui', AttrType: 'bg',    AttrKey: 'guibg'  },
        \   {Variant: 'termgui', AttrType: 'sp',    AttrKey: 'guisp'  },
        \   {Variant: 'termgui', AttrType: 'style', AttrKey: 'cterm'  },
        \   {Variant: '256',     AttrType: 'fg',    AttrKey: 'ctermfg'},
        \   {Variant: '256',     AttrType: 'bg',    AttrKey: 'ctermbg'},
        \   {Variant: '256',     AttrType: 'sp',    AttrKey: 'ctermul'},
        \   {Variant: '256',     AttrType: 'style', AttrKey: 'cterm'  },
        \   {Variant:  '88',     AttrType: 'fg',    AttrKey: 'ctermfg'},
        \   {Variant:  '88',     AttrType: 'bg',    AttrKey: 'ctermbg'},
        \   {Variant:  '88',     AttrType: 'sp',    AttrKey: 'ctermul'},
        \   {Variant:  '88',     AttrType: 'style', AttrKey: 'cterm'  },
        \   {Variant:  '16',     AttrType: 'fg',    AttrKey: 'ctermfg'},
        \   {Variant:  '16',     AttrType: 'bg',    AttrKey: 'ctermbg'},
        \   {Variant:  '16',     AttrType: 'sp',    AttrKey: 'ctermul'},
        \   {Variant:  '16',     AttrType: 'style', AttrKey: 'cterm'  },
        \   {Variant:   '8',     AttrType: 'fg',    AttrKey: 'ctermfg'},
        \   {Variant:   '8',     AttrType: 'bg',    AttrKey: 'ctermbg'},
        \   {Variant:   '8',     AttrType: 'sp',    AttrKey: 'ctermul'},
        \   {Variant:   '8',     AttrType: 'style', AttrKey: 'cterm'  },
        \   {Variant:  'bw',     AttrType: 'style', AttrKey: 'term'   },
        \   {Variant:  'bw',     AttrType: 'start', AttrKey: 'start'  },
        \   {Variant:  'bw',     AttrType: 'stop',  AttrKey: 'stop'   },
        \   {Variant:   '0',     AttrType: 'style', AttrKey: 'term'   },
        \   {Variant:   '0',     AttrType: 'start', AttrKey: 'start'  },
        \   {Variant:   '0',     AttrType: 'stop',  AttrKey: 'stop'   },
        \ ])

  this.Color = Rel.new('Color', {
        \   ColorName:    Str,
        \   GUIValue:     Str,
        \   Base256Value: Int,
        \   Base16Value:  Str,
        \   Delta:        Float,
        \ }, [
        \   ['ColorName'],
        \   ['GUIValue', 'Base256Value', 'Base16Value']
        \ ]).InsertMany([
        \   {ColorName: '',     GUIValue: '', Base256Value: -1, Base16Value: '', Delta: 0.0},
        \   {ColorName: 'none', GUIValue: '', Base256Value: -2, Base16Value: '', Delta: 0.0},
        \   {ColorName: 'fg',   GUIValue: '', Base256Value: -3, Base16Value: '', Delta: 0.0},
        \   {ColorName: 'bg',   GUIValue: '', Base256Value: -4, Base16Value: '', Delta: 0.0}
        \ ])

  this.HiGroup = Rel.new('Hi Group', {
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
        \   Attr:        Str,
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

  this.BaseGroupOverride = Rel.new('Base Group', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \   Fg:          Str,
        \   Bg:          Str,
        \   Special:     Str,
        \   Attr:        Str,
        \   Font:        Str,
        \   Start:       Str,
        \   Stop:        Str,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue'])

  def new(this.background)
    this.Color.Check(IsValidColorName)
    this.Color.Check(IsValidBase256Value)

    ForeignKey(this.LinkedGroup,         'must be a',                         this.HiGroup,          ['HiGroupName'])
    ForeignKey(this.BaseGroup,           'must be a',                         this.HiGroup,          ['HiGroupName'])
    ForeignKey(this.BaseGroup,           'must use as foreground a',          this.Color,            ['Fg'], ['ColorName'])
    ForeignKey(this.BaseGroup,           'must use as background a',          this.Color,            ['Bg'], ['ColorName'])
    ForeignKey(this.BaseGroup,           'must use as special color a',       this.Color,            ['Special'], ['ColorName'])
    ForeignKey(this.HiGroupOverride,     'must override an existing',         this.HiGroup,          ['HiGroupName'])
    ForeignKey(this.HiGroupOverride,     'must refer to a valid',             this.Variant,          ['Variant'])
    ForeignKey(this.LinkedGroupOverride, 'must be a',                         this.HiGroupOverride,  ['HiGroupName', 'Variant', 'DiscrValue'])
    ForeignKey(this.BaseGroupOverride,   'must be a',                         this.HiGroupOverride,  ['HiGroupName', 'Variant', 'DiscrValue'])
    ForeignKey(this.BaseGroupOverride,   'must use as foreground a valid',    this.Color,            ['Fg'], ['ColorName'])
    ForeignKey(this.BaseGroupOverride,   'must use as background a valid',    this.Color,            ['Bg'], ['ColorName'])
    ForeignKey(this.BaseGroupOverride,   'must use as special color a valid', this.Color,            ['Special'], ['ColorName'])
  enddef
endclass
