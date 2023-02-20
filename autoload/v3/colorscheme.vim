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

export class Metadata
  public this.author:      list<string> = []
  public this.description: list<string> = []
  public this.fullname:    string       = ''
  public this.license:     string       = ''
  public this.maintainer:  list<string> = []
  public this.pathname:    string       = ''
  public this.shortname:   string       = ''
  public this.url:         string       = ''
  public this.version:     string       = ''
  public this.website:     string       = ''
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
        \ ])

  this.HighlightGroup = Rel.new('Highlight Group', {
        \   HiGroupName: Str,
        \   DiscrName:   Str,
        \ },
        \ 'HiGroupName').InsertMany([
        \ {HiGroupName: 'ColorColumn',       DiscrName: ''},
        \ {HiGroupName: 'Comment',           DiscrName: ''},
        \ {HiGroupName: 'Conceal',           DiscrName: ''},
        \ {HiGroupName: 'Constant',          DiscrName: ''},
        \ {HiGroupName: 'Cursor',            DiscrName: ''},
        \ {HiGroupName: 'CursorColumn',      DiscrName: ''},
        \ {HiGroupName: 'CursorLine',        DiscrName: ''},
        \ {HiGroupName: 'CursorLineFold',    DiscrName: ''},
        \ {HiGroupName: 'CursorLineNr',      DiscrName: ''},
        \ {HiGroupName: 'CursorLineSign',    DiscrName: ''},
        \ {HiGroupName: 'DiffAdd',           DiscrName: ''},
        \ {HiGroupName: 'DiffChange',        DiscrName: ''},
        \ {HiGroupName: 'DiffDelete',        DiscrName: ''},
        \ {HiGroupName: 'DiffText',          DiscrName: ''},
        \ {HiGroupName: 'Directory',         DiscrName: ''},
        \ {HiGroupName: 'EndOfBuffer',       DiscrName: ''},
        \ {HiGroupName: 'Error',             DiscrName: ''},
        \ {HiGroupName: 'ErrorMsg',          DiscrName: ''},
        \ {HiGroupName: 'FoldColumn',        DiscrName: ''},
        \ {HiGroupName: 'Folded',            DiscrName: ''},
        \ {HiGroupName: 'Identifier',        DiscrName: ''},
        \ {HiGroupName: 'Ignore',            DiscrName: ''},
        \ {HiGroupName: 'IncSearch',         DiscrName: ''},
        \ {HiGroupName: 'LineNr',            DiscrName: ''},
        \ {HiGroupName: 'LineNrAbove',       DiscrName: ''},
        \ {HiGroupName: 'LineNrBelow',       DiscrName: ''},
        \ {HiGroupName: 'MatchParen',        DiscrName: ''},
        \ {HiGroupName: 'MessageWindow',     DiscrName: ''},
        \ {HiGroupName: 'ModeMsg',           DiscrName: ''},
        \ {HiGroupName: 'MoreMsg',           DiscrName: ''},
        \ {HiGroupName: 'NonText',           DiscrName: ''},
        \ {HiGroupName: 'Normal',            DiscrName: ''},
        \ {HiGroupName: 'Pmenu',             DiscrName: ''},
        \ {HiGroupName: 'PmenuSbar',         DiscrName: ''},
        \ {HiGroupName: 'PmenuSel',          DiscrName: ''},
        \ {HiGroupName: 'PmenuThumb',        DiscrName: ''},
        \ {HiGroupName: 'PopupNotification', DiscrName: ''},
        \ {HiGroupName: 'PopupSelected',     DiscrName: ''},
        \ {HiGroupName: 'PreProc',           DiscrName: ''},
        \ {HiGroupName: 'Question',          DiscrName: ''},
        \ {HiGroupName: 'QuickFixLine',      DiscrName: ''},
        \ {HiGroupName: 'Search',            DiscrName: ''},
        \ {HiGroupName: 'SignColumn',        DiscrName: ''},
        \ {HiGroupName: 'Special',           DiscrName: ''},
        \ {HiGroupName: 'SpecialKey',        DiscrName: ''},
        \ {HiGroupName: 'SpellBad',          DiscrName: ''},
        \ {HiGroupName: 'SpellCap',          DiscrName: ''},
        \ {HiGroupName: 'SpellLocal',        DiscrName: ''},
        \ {HiGroupName: 'SpellRare',         DiscrName: ''},
        \ {HiGroupName: 'Statement',         DiscrName: ''},
        \ {HiGroupName: 'StatusLine',        DiscrName: ''},
        \ {HiGroupName: 'StatusLineNC',      DiscrName: ''},
        \ {HiGroupName: 'StatusLineTerm',    DiscrName: ''},
        \ {HiGroupName: 'StatusLineTermNC',  DiscrName: ''},
        \ {HiGroupName: 'TabLine',           DiscrName: ''},
        \ {HiGroupName: 'TabLineFill',       DiscrName: ''},
        \ {HiGroupName: 'TabLineSel',        DiscrName: ''},
        \ {HiGroupName: 'Title',             DiscrName: ''},
        \ {HiGroupName: 'Todo',              DiscrName: ''},
        \ {HiGroupName: 'ToolbarButton',     DiscrName: ''},
        \ {HiGroupName: 'ToolbarLine',       DiscrName: ''},
        \ {HiGroupName: 'Type',              DiscrName: ''},
        \ {HiGroupName: 'Underlined',        DiscrName: ''},
        \ {HiGroupName: 'VertSplit',         DiscrName: ''},
        \ {HiGroupName: 'Visual',            DiscrName: ''},
        \ {HiGroupName: 'VisualNOS',         DiscrName: ''},
        \ {HiGroupName: 'WarningMsg',        DiscrName: ''},
        \ {HiGroupName: 'WildMenu',          DiscrName: ''},
        \ ])

  this.HiGroupVersion = Rel.new('Highlight Group Version', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \   IsLinked:    Bool,
        \   IsDefault:   Bool,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue'])

  this.LinkedGroup = Rel.new('Linked Group', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \   TargetGroup: Str,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue'])

  this.BaseGroup = Rel.new('Base Group', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue'])

  this.Attribute = Rel.new('Attribute', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \   AttrKey:     Str,
        \   AttrValue:   Str,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue', 'AttrKey'])

  this.ColorAttribute = Rel.new('Color Attribute', {
        \   HiGroupName: Str,
        \   Variant:     Str,
        \   DiscrValue:  Str,
        \   AttrKey:     Str,
        \   ColorName:   Str,
        \ },
        \ ['HiGroupName', 'Variant', 'DiscrValue', 'AttrKey'])

  def new(this.background)
    this.Color.Check(IsValidColorName)
    this.Color.Check(IsValidBase256Value)

    ForeignKey(this.HiGroupVersion, 'must be a version of a', this.HighlightGroup,   ['HiGroupName'])
    ForeignKey(this.HiGroupVersion, 'must apply to a',        this.Variant,          ['Variant'])
    ForeignKey(this.LinkedGroup,    'must be a',              this.HiGroupVersion,   ['HiGroupName', 'Variant', 'DiscrValue'])
    ForeignKey(this.BaseGroup,      'must be a',              this.HiGroupVersion,   ['HiGroupName', 'Variant', 'DiscrValue'])
    ForeignKey(this.Attribute,      'must describe a',        this.BaseGroup,        ['HiGroupName', 'Variant', 'DiscrValue'])
    ForeignKey(this.Attribute,      'must use a',             this.VariantAttribute, ['Variant', 'AttrKey'])
    ForeignKey(this.ColorAttribute, 'must describe a',        this.BaseGroup,        ['HiGroupName', 'Variant', 'DiscrValue'])
    ForeignKey(this.ColorAttribute, 'must use a',             this.VariantAttribute, ['Variant', 'AttrKey'])
    ForeignKey(this.ColorAttribute, 'must use a',             this.Color,            ['ColorName'])
  enddef
endclass
