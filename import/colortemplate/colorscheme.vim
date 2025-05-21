vim9script

import 'librelalg.vim'  as ra
import 'libversion.vim' as vv

vv.Require('librelalg', ra.version, '0.2.0-alpha1')

#
#                            Colortemplate's Data Model
#
#    ┌───────────┐
#    │           │
#    │Environment│
#    │           │
#    └────┬─┬────┘                       ┌───────────┐
#         │ │         supports           │           │
#           └───────────────────────────●│ Attribute │
#         │                              │           │
#                                        └───────────┘
#         │          ┌───────────┐
#                    │           │
#         │          │ Discrim.  │
#      scopes/       │           │
#   holds within     └─────┬┬────┘
#                                        ┌───────────┐
#         │                ││   varies   │ Highlight │
#                   defines └ ─ ─ ─ ─ ─ ●│           │
#         │                │             │   Group   │
#                          ●             └─────┬─────┘
#         │          ┌───────────┐             │manifests itself
#                    │           │             │through
#         └─ ─ ─ ─ ─●│ Condition │             │      ┌───────────┐
#    ┌───────────┐   │           │             └─────●│ Highlight │
#    │           │   └─────┬─────┘   qualifies/       │   Group   │
#    │   Color   │         └─────────────────────────●│    Def    │
#    │           │                is restricted by    └─────┬─────┘
#    └────┬┬┬────┘                                       ___○___
#         │││                                            ───────
#                                              ┌───────────┘ └──────────┐
#         │││                                  ●                        │
#                                        ┌───────────┐                  │
#         │││                            │  Linked   │                  │
#                                        │           │                  │
#         │││                            │  Group    │                  ●
#                                        └───────────┘            ┌───────────┐
#         ││└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ is foreground of ─ ─ ●│   Base    │
#          └ ─ ─ ─ ─ ─ ─ ─ ─ ─ is background of ─ ─ ─ ─ ─ ─ ─ ─ ─●│           │
#         └─ ─ ─ is special color of ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ●│   Group   │
#                                                                 └───────────┘


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

export const KEY_NOT_FOUND = ra.KEY_NOT_FOUND
# }}}

const ColorKind = {
  '16':  'Base16',
  '256': 'Base256',
  'gui': 'GUI',
  '':    'GUI',
}

# Integrity constraints {{{
def IsValidColorName(t: Tuple): bool
  if t.Name == 'none' ||
     t.Name == 'fg'   ||
     t.Name == 'bg'   ||
     t.Name == 'omit'
    FailedMsg($'"{t.Name}" is a reserved name and cannot be used as a color name')

    return false
  endif

  return true
enddef

def IsValidBase256Value(t: Tuple): bool
  # This works even if the value is a name rather than a number: str2nr()
  # returns 0 if parsing the input fails.
  var n = str2nr(t.Base256)

  if n > 255 || n < 0
    FailedMsg($'Base-256 value must be in [0,255]: {t.Base256} is invalid')

    return false
  endif

  return true
enddef
# }}}

export class Database
  public var background:   string
  public var termcolors:   list<string> = []
  public var verbatimtext: list<string> = []

  var _nextDiscriminatorNum = 0
  var _nextConditionNum = 0

  # Supported environments. «default» is special because it denotes the
  # hypothetical richest environment supporting every attribute.
  var Environment = Rel.new('Environment', {
    Environment: Str,
    NumColors:   Int,
  }, ['Environment']
  ).InsertMany([
    {Environment: 'default', NumColors: 16777216},
    {Environment:     'gui', NumColors: 16777216},
    {Environment:     '256', NumColors:      256},
    {Environment:      '88', NumColors:       88},
    {Environment:      '16', NumColors:       16},
    {Environment:       '8', NumColors:        8},
    {Environment:       '0', NumColors:        0},
  ])

  # Supported attributes for each environment
  var Attribute = Rel.new("Attribute", {
    Environment: Str,
    AttrType:    Str,
    AttrKey:     Str,
  },
  [['Environment', 'AttrKey']]
  ).InsertMany([
    {Environment: 'default', AttrType: 'Fg',      AttrKey: 'guifg'  },
    {Environment: 'default', AttrType: 'Bg',      AttrKey: 'guibg'  },
    {Environment: 'default', AttrType: 'Special', AttrKey: 'guisp'  },
    {Environment: 'default', AttrType: 'Style',   AttrKey: 'gui'    },
    {Environment: 'default', AttrType: 'Font',    AttrKey: 'font'   },
    {Environment: 'default', AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Environment: 'default', AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Environment: 'default', AttrType: 'Special', AttrKey: 'ctermul'},
    {Environment: 'default', AttrType: 'Style',   AttrKey: 'cterm'  },
    {Environment: 'default', AttrType: 'Style',   AttrKey: 'term'   },
    {Environment: 'default', AttrType: 'Start',   AttrKey: 'start'  },
    {Environment: 'default', AttrType: 'Stop',    AttrKey: 'stop'   },
    {Environment: 'gui',     AttrType: 'Fg',      AttrKey: 'guifg'  },
    {Environment: 'gui',     AttrType: 'Bg',      AttrKey: 'guibg'  },
    {Environment: 'gui',     AttrType: 'Special', AttrKey: 'guisp'  },
    {Environment: 'gui',     AttrType: 'Style',   AttrKey: 'gui'    },
    {Environment: 'gui',     AttrType: 'Font',    AttrKey: 'font'   },
    {Environment: '256',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Environment: '256',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Environment: '256',     AttrType: 'Special', AttrKey: 'ctermul'},
    {Environment: '256',     AttrType: 'Style',   AttrKey: 'cterm'  },
    {Environment:  '88',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Environment:  '88',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Environment:  '88',     AttrType: 'Special', AttrKey: 'ctermul'},
    {Environment:  '88',     AttrType: 'Style',   AttrKey: 'cterm'  },
    {Environment:  '16',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Environment:  '16',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Environment:  '16',     AttrType: 'Special', AttrKey: 'ctermul'},
    {Environment:  '16',     AttrType: 'Style',   AttrKey: 'cterm'  },
    {Environment:   '8',     AttrType: 'Fg',      AttrKey: 'ctermfg'},
    {Environment:   '8',     AttrType: 'Bg',      AttrKey: 'ctermbg'},
    {Environment:   '8',     AttrType: 'Special', AttrKey: 'ctermul'},
    {Environment:   '8',     AttrType: 'Style',   AttrKey: 'cterm'  },
    {Environment:   '0',     AttrType: 'Style',   AttrKey: 'term'   },
    {Environment:   '0',     AttrType: 'Start',   AttrKey: 'start'  },
    {Environment:   '0',     AttrType: 'Stop',    AttrKey: 'stop'   },
  ])

  # User-defined color names.
  var Color = Rel.new('Color', {
    Name:       Str,
    GUI:        Str,
    Base256:    Str,
    Base256Hex: Str,
    Base16:     Str,
  }, 'Name'
  ).InsertMany([
    {Name: '',     GUI: '',     Base256: '',     Base256Hex: '', Base16: '',   }, # For when color is omitted
    {Name: 'none', GUI: 'NONE', Base256: 'NONE', Base256Hex: '', Base16: 'NONE'},
    {Name: 'fg',   GUI: 'fg',   Base256: 'fg',   Base256Hex: '', Base16: 'fg', },
    {Name: 'bg',   GUI: 'bg',   Base256: 'bg',   Base256Hex: '', Base16: 'bg', }
  ])

  # Discriminators are variables that can be used to conditionally define
  # highlight group variants. The empty discriminator (discriminator 0) is
  # used when no discriminator exists for a highlight group.
  var Discriminator = Rel.new('Discriminator', {
    DiscrName:  Str,
    Definition: Str,
    DiscrNum:   Int,
  }, [['DiscrName'], ['DiscrNum']]
  ).InsertMany([
    {DiscrName: '', Definition: '', DiscrNum: 0},
  ])

  # A condition determines the context for a highlight group definition to be
  # enabled. That depends on the current environment and, optionally, on the
  # value of a given discriminator variable. Condition 0 is special because it
  # applies to the default definition of each highlight group: so, that means
  # «enabled by default unless overridden».
  var Condition = Rel.new('Condition', {
    Condition:   Int,
    Environment: Str,
    DiscrName:   Str,
    DiscrValue:  Str,
  }, [['Condition'], ['Environment', 'DiscrName', 'DiscrValue']]
  ).InsertMany([
    {Condition: 0, Environment: 'default', DiscrName: '', DiscrValue: ''},
  ])

  var HighlightGroup = Rel.new('Highlight Group', {
    HiGroup:   Str,
    DiscrName: Str,
  }, 'HiGroup')

  var HighlightGroupDef = Rel.new('Highlight Group Definition', {
    HiGroup:   Str,
    Condition: Int,
    IsLinked:  Bool,
  }, [['HiGroup', 'Condition']])

  var LinkedGroup = Rel.new('Linked Group', {
    HiGroup:     Str,
    Condition:   Int,
    TargetGroup: Str,
  }, ['HiGroup', 'Condition'])

  var BaseGroup: Rel = Rel.new('Base Group', {
    HiGroup:   Str,
    Condition: Int,
    Fg:        Str,
    Bg:        Str,
    Special:   Str,
    Style:     Str,
    Font:      Str,
    Start:     Str,
    Stop:      Str,
  }, ['HiGroup', 'Condition'])

  def new(this.background)
    if this.background != 'dark' && this.background != 'light'
      throw $'Invalid background: "{this.background}". Please use "dark" or "light".'
    endif

    this.Color.OnInsertCheck('Valid color',           IsValidColorName)
    this.Color.OnInsertCheck('Valid 256-based color', IsValidBase256Value)

    ForeignKey(this.Attribute, 'Environment')
      ->References(this.Environment, {verb: 'is supported by'})

    ForeignKey(this.Condition, 'Environment')
      ->References(this.Environment, {verb: 'holds within'})

    ForeignKey(this.Condition, 'DiscrName')
      ->References(this.Discriminator, {verb: 'is defined by'})

    ForeignKey(this.HighlightGroup, 'DiscrName')
      ->References(this.Discriminator, {verb: 'is varied by'})

    ForeignKey(this.HighlightGroupDef, 'HiGroup')
      ->References(this.HighlightGroup, {verb: 'refers to'})

    ForeignKey(this.HighlightGroupDef, 'Condition')
      ->References(this.Condition, {verb: 'is restricted by'})

    ForeignKey(this.LinkedGroup, ['HiGroup', 'Condition'])
      ->References(this.HighlightGroupDef, {verb: 'is a'})

    ForeignKey(this.BaseGroup, ['HiGroup', 'Condition'])
      ->References(this.HighlightGroupDef, {verb: 'is a'})

    ForeignKey(this.BaseGroup, 'Fg')
      ->References(this.Color, {verb: 'must adopt as foreground color a valid'})

    ForeignKey(this.BaseGroup, 'Bg')
      ->References(this.Color, {verb: 'must adopt as background color a valid'})

    ForeignKey(this.BaseGroup, 'Special')
      ->References(this.Color, {verb: 'must adopt as special color a valid'})
  enddef

  def InsertDiscriminator(
      discrName: string,
      definition: string,
      )
    ++this._nextDiscriminatorNum

    this.Discriminator.Insert({
      DiscrName:  discrName,
      Definition: definition,
      DiscrNum:   this._nextDiscriminatorNum,
    })
  enddef

  def InsertOrRetrieveCondition_(
      environment: string,
      discrName:   string,
      discrValue:  string,
      ): number
    var u = this.Condition.Lookup(
      ['Environment', 'DiscrName', 'DiscrValue'],
      [ environment,   discrName,   discrValue ],
    )

    if u isnot KEY_NOT_FOUND
      return u.Condition
    endif

    ++this._nextConditionNum

    this.Condition.Insert({
      Condition:   this._nextConditionNum,
      Environment: environment,
      DiscrName:   discrName,
      DiscrValue:  discrValue,
    })

    return this._nextConditionNum
  enddef

  def InsertHighlightGroup_(hiGroupName: string, discrName: string)
    var u = this.HighlightGroup.Lookup(['HiGroup'], [hiGroupName])

    if u is KEY_NOT_FOUND
      this.HighlightGroup.Insert({
        HiGroup:     hiGroupName,
        DiscrName:   discrName,
      })
    elseif !empty(discrName)
      if empty(u.DiscrName)
        this.HighlightGroup.Upsert({
          HiGroup:     hiGroupName,
          DiscrName:   discrName,
        })
      elseif u.DiscrName != discrName
        throw printf(
          "Inconsistent discriminator name '%s': '%s' already uses '%s' (%s background)",
          discrName, hiGroupName, u.DiscrName, this.background
        )
      endif
    endif
  enddef

  def InsertBaseGroup(
    environment: string,
    discrName:   string,
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
    this.InsertHighlightGroup_(hiGroupName, discrName)

    var condition = this.InsertOrRetrieveCondition_(environment, discrName, discrValue)

    this.HighlightGroupDef.Insert({
      HiGroup:     hiGroupName,
      Condition:   condition,
      IsLinked:    false,
    })

    this.BaseGroup.Insert({
      HiGroup:     hiGroupName,
      Condition:   condition,
      Fg:          fgColor,
      Bg:          bgColor,
      Special:     spColor,
      Style:       attributes,
      Font:        font,
      Start:       start,
      Stop:        stop,
    })
  enddef

  def InsertLinkedGroup(
    environment: string,
    discrName:   string,
    discrValue:  string,
    hiGroupName: string,
    targetGroup: string,
  )
    this.InsertHighlightGroup_(hiGroupName, discrName)

    var condition = this.InsertOrRetrieveCondition_(environment, discrName, discrValue)

    this.HighlightGroupDef.Insert({
      HiGroup:     hiGroupName,
      Condition:   condition,
      IsLinked:    true,
    })

    this.LinkedGroup.Insert({
      HiGroup:     hiGroupName,
      Condition:   condition,
      TargetGroup: targetGroup,
    })
  enddef

  def HiGroupDef(
      hiGroupName: string,
      environment: string,
      discrName  = '',
      discrValue = ''
      ): Tuple
    # Return the highlight group definition for the given condition
    var cond = this.Condition.Lookup(
      ['Environment', 'DiscrName', 'DiscrValue'],
      [ environment,   discrName,   discrValue ],
    )

    if cond is KEY_NOT_FOUND
      return KEY_NOT_FOUND
    endif

    var t = this.BaseGroup.Lookup(['HiGroup', 'Condition'], [hiGroupName, cond.Condition])

    if t isnot KEY_NOT_FOUND
      return t
    endif

    return this.LinkedGroup.Lookup(['HiGroup', 'Condition'], [hiGroupName, cond.Condition])
  enddef

  def LinkedGroupDictionaries(environment: string, discrName  = '', discrValue = ''): list<dict<string>>
    # Return the highlight group definitions for the given conditions.
    return EquiJoin(
      this.LinkedGroup,
      this.Condition->Select(
        (t) => t.Environment == environment && t.DiscrName == discrName && t.DiscrValue == discrValue
      ),
      {on: 'Condition'}
    )->Transform((t) => {
      return {HiGroup: t.HiGroup, TargetGroup: t.TargetGroup}
    })
  enddef

  def BaseGroupDictionaries(environment: string, discrName  = '', discrValue = ''): list<dict<string>>
    # Return the highlight group definitions for the given condition as a list
    # of dictionaries, where each dictionary has the correct attributes with
    # the correct values. For instance, a dictionary for a highlight group in
    # 256-color terminals may look as follows:
    #
    #     {ctermfg: '203': ctermbg: '16', ctermul: 'NONE', cterm: 'bold'}
    #
    # Which keys are returned depends on the environment.
    var attributes = this.Attribute
      ->Select((t) => t.Environment == environment)
      ->DictTransform((t) => {
        return {[t.AttrKey]: t.AttrType}
      }, true)

    var colorAttr: string

    if environment == 'gui' || environment == 'default'
      colorAttr = 'GUI'
    elseif str2nr(environment) > 16
      colorAttr = 'Base256'
    else
      colorAttr = 'Base16'
    endif

    var records = EquiJoin(
      this.BaseGroup,
      this.Condition->Select(
        (t) => t.Environment == environment && t.DiscrName == discrName && t.DiscrValue == discrValue
      ),
      {on: 'Condition'}
    )->Transform((t) => {
      var out: dict<string> = {HiGroup: t.HiGroup}

      for [attr_key, attr_type] in items(attributes)
        if attr_type == 'Fg' || attr_type == 'Bg' || attr_type == 'Special'
          out[attr_key] = this.Color.Lookup(['Name'], [t[attr_type]])[colorAttr]
        else
          out[attr_key] = t[attr_type]
        endif
      endfor

      return out
    })

    return records
  enddef

  def GetColor(name: string, kind: string): string
    const t = this.Color.Lookup(['Name'], [name])

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
endclass

export class Colorscheme
  var dark:  Database
  var light: Database

  # Color scheme's metadata
  public var authors:      list<string>       = []
  public var description:  list<string>       = []
  public var fullname:     string             = ''
  public var license:      string             = ''
  public var maintainers:  list<string>       = []
  public var shortname:    string             = ''
  public var urls:         list<string>       = []
  public var version:      string             = ''
  public var environments: list<string>       = []
  public var backgrounds:  dict<bool>         = {dark: false, light: false}
  public var verbatimtext: list<string>       = []
  public var auxfiles:     dict<list<string>> = {}  # path => content
  public var prefix:       string             = ''
  public var options:      dict<any>          = {
    backend:    'vim9',
    creator:     true,
    dateformat: '%Y %b %d',
    palette:     false,
    shiftwidth:  2,
    timestamp:   true,
  }

  def new()
    this.dark = Database.new('dark')
    this.light = Database.new('light')
  enddef

  def IsLightAndDark(): bool
    return this.backgrounds.dark && this.backgrounds.light
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
