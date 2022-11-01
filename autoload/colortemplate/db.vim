vim9script

import '../../import/librelalg.vim' as ra

const AntiJoin             = ra.AntiJoin
const Attributes           = ra.Attributes
const Bool                 = ra.Bool
const Build                = ra.Build
const Count                = ra.Count
const Delete               = ra.Delete
const Descriptors          = ra.Descriptors
const Divide               = ra.Divide
const Float                = ra.Float
const ForeignKey           = ra.ForeignKey
const GroupBy              = ra.GroupBy
const Insert               = ra.Insert
const InsertMany           = ra.InsertMany
const Int                  = ra.Int
const Intersect            = ra.Intersect
const Join                 = ra.Join
const KeyAttributes        = ra.KeyAttributes
const Max                  = ra.Max
const Min                  = ra.Min
const Minus                = ra.Minus
const NatJoin              = ra.NatJoin
const Noop                 = ra.Noop
const Product              = ra.Product
const Project              = ra.Project
const Query                = ra.Query
const Relation             = ra.Relation
const Rename               = ra.Rename
const Scan                 = ra.Scan
const Select               = ra.Select
const SemiJoin             = ra.SemiJoin
const Sort                 = ra.Sort
const SortBy               = ra.SortBy
const Str                  = ra.Str
const Sum                  = ra.Sum
const Update               = ra.Update

# Colortemplate's Relational schema {{{
# Metadata {{{
var Colorscheme = Relation('Colorscheme', {
    pathname:    Str,
    shortname:   Str,
    fullname:    Str,
    description: Str,
    author:      Str,
    maintainer:  Str,
    license:     Str,
    web:         Str,
  },
  [['pathname']]
)

var Environment = Relation('Environment', {
    variant:   Str,
    numColors: Int,
  },
  [['variant'], ['numColors']]
)

Environment->InsertMany([
  {variant: 'gui', numColors: 16777216},
  {variant: '256', numColors:      256},
  {variant:  '88', numColors:       88},
  {variant:  '16', numColors:       16},
  {variant:   '8', numColors:        8},
  {variant:  'bw', numColors:        0},
])


var ColorAttribute = Relation('ColorAttribute', {
    variant:   Str,
    colorAttr: Str,
  },
  [['variant', 'colorAttr']]
)

ColorAttribute->InsertMany([
  {variant: 'gui', colorAttr: 'guifg'  },
  {variant: 'gui', colorAttr: 'guibg'  },
  {variant: 'gui', colorAttr: 'guisp'  },
  {variant: '256', colorAttr: 'ctermfg'},
  {variant: '256', colorAttr: 'ctermbg'},
  {variant: '256', colorAttr: 'ctermul'},
  {variant:  '88', colorAttr: 'ctermfg'},
  {variant:  '88', colorAttr: 'ctermbg'},
  {variant:  '88', colorAttr: 'ctermul'},
  {variant:  '16', colorAttr: 'ctermfg'},
  {variant:  '16', colorAttr: 'ctermbg'},
  {variant:  '16', colorAttr: 'ctermul'},
  {variant:   '8', colorAttr: 'ctermfg'},
  {variant:   '8', colorAttr: 'ctermbg'},
  {variant:   '8', colorAttr: 'ctermul'},
])

const EnvironmentSupportsColorAttributeFk = ForeignKey(
  ColorAttribute, ['variant'],
  Environment,    ['variant']
)
ColorAttribute.constraints->add(EnvironmentSupportsColorAttributeFk)

var StyleAttribute = Relation('StyleAttribute', {
    variant:   Str,
    styleAttr: Str,
  },
  [['variant', 'styleAttr']]
)

StyleAttribute->InsertMany([
  {variant: 'gui', styleAttr: 'gui'  },
  {variant: 'gui', styleAttr: 'font' },
  {variant: '256', styleAttr: 'cterm'},
  {variant:  '88', styleAttr: 'cterm'},
  {variant:  '16', styleAttr: 'cterm'},
  {variant:   '8', styleAttr: 'cterm'},
  {variant:  'bw', styleAttr: 'term' },
  {variant:  'bw', styleAttr: 'start'},
  {variant:  'bw', styleAttr: 'stop' },
])

const EnvironmentSupportsStyleAttributeFk = ForeignKey(
  StyleAttribute, ['variant'],
  Environment,    ['variant']
)
StyleAttribute.constraints->add(EnvironmentSupportsStyleAttributeFk)
# }}}

var Variant = Relation('Variant', {
    variant: Str,
  },
  [['variant']]
)

const EnvironmentManifestsAsVariantFk = ForeignKey(
  Variant,     ['variant'],
  Environment, ['variant']
)
Variant.constraints->add(EnvironmentManifestsAsVariantFk)

var Background = Relation('Background', {
    background: Str,
  },
  [['background']]
)

const ValidBackgroundCk = (t: dict<any>, op: string): void => {
  const v = t['background']
  if v != 'dark' && v != 'light'
    throw printf("%s is not a valid background", v)
  endif
}
Background.constraints->add(ValidBackgroundCk)

var ColorDelta = Relation('ColorDelta', {
    guiValue:     Str,
    base256Value: Str,
    delta:        Float,
  },
  [['guiValue', 'base256Value']]
)

var Color = Relation('Color', {
    background:   Str,
    colorName:    Str,
    guiValue:     Str,
    base256Value: Str,
    base16Value:  Str,
  },
  [['background', 'colorName']]
)

const BackgroundSetsTheScopeOfColorFk = ForeignKey(
  Color,      ['background'],
  Background, ['background'],
)
Color.constraints->add(BackgroundSetsTheScopeOfColorFk)

const ColorDeltaDescribesColorFk = ForeignKey(
  Color,      ['guiValue', 'base256Value'],
  ColorDelta, ['guiValue', 'base256Value'],
)
Color.constraints->add(ColorDeltaDescribesColorFk)

var HighlightGroup = Relation('Highlight Group', {
    background:  Str,
    variant:     Str,
    version:     Int,
    hiGroupName: Str,
    isLinked:    Bool,
  },
  [['hiGroupName', 'variant', 'background', 'version']]
)

const VariantDefinesHighlightGroupFk = ForeignKey(
  HighlightGroup, ['variant'],
  Variant,        ['variant']
)
HighlightGroup.constraints->add(VariantDefinesHighlightGroupFk)

const BackgroundProvidesTheSettingForHighlightGroupFk = ForeignKey(
  HighlightGroup, ['background'],
  Background,     ['background']
)

var LinkedGroup = Relation('Linked Group', {
    background:  Str,
    variant:     Str,
    version:     Int,
    hiGroupName: Str,
    targetGroup: Str,
  },
  [['hiGroupName', 'variant', 'background', 'version']]
)

const HighlightGroupIsLinkedGroupFk = ForeignKey(
  LinkedGroup,    ['hiGroupName', 'variant', 'background', 'version'],
  HighlightGroup, ['hiGroupName', 'variant', 'background', 'version']
)
LinkedGroup.constraints->add(HighlightGroupIsLinkedGroupFk)

var BaseGroup = Relation('Base Group', {
    background:  Str,
    variant:     Str,
    version:     Int,
    hiGroupName: Str,
  },
  [['hiGroupName', 'variant', 'background', 'version']]
)

const HighlightGroupIsBaseGroupFk = ForeignKey(
  BaseGroup,      ['hiGroupName', 'variant', 'background', 'version'],
  HighlightGroup, ['hiGroupName', 'variant', 'background', 'version']
)
BaseGroup.constraints->add(HighlightGroupIsBaseGroupFk)

var Override = Relation('Override', {
    background:    Str,
    variant:       Str,
    version:       Int,
    hiGroupName:   Str,
    parentVersion: Int,
    condition:     Str,
  },
  [['hiGroupName', 'variant', 'background', 'version'],
   ['hiGroupName', 'variant', 'background', 'parentVersion']]
)

const HighlightGroupIsOverriddenByHighlightGroupFk = ForeignKey(
  Override,       ['hiGroupName', 'variant', 'background', 'parentVersion'],
  HighlightGroup, ['hiGroupName', 'variant', 'background', 'version']
)

const HighlightGroupOverridesHighlightGroup = ForeignKey(
  Override,       ['hiGroupName', 'variant', 'background', 'version'],
  HighlightGroup, ['hiGroupName', 'variant', 'background', 'version']
)
Override.constraints->add(HighlightGroupIsOverriddenByHighlightGroupFk)
Override.constraints->add(HighlightGroupOverridesHighlightGroup)

var HiGroupColor = Relation('Highlight Group Color', {
    background:    Str,
    variant:       Str,
    version:       Int,
    hiGroupName:   Str,
    colorAttr:     Str,
    colorName:     Str,
  },
  [['hiGroupName', 'variant', 'background', 'version', 'colorAttr']]
)

const ColorAttributeIsAssignedAValueInHiGroupColorFk = ForeignKey(
  HiGroupColor,   ['variant', 'colorAttr'],
  ColorAttribute, ['variant', 'colorAttr']
)

const BaseGroupHasHiGroupColorFk = ForeignKey(
  HiGroupColor,   ['hiGroupName', 'variant', 'background', 'version'],
  BaseGroup,      ['hiGroupName', 'variant', 'background', 'version']
)

const ColorIsUsedByHiGroupColorFk = ForeignKey(
  HiGroupColor, ['background', 'colorName'],
  Color,        ['background', 'colorName']
)

HiGroupColor.constraints->add(ColorAttributeIsAssignedAValueInHiGroupColorFk)
HiGroupColor.constraints->add(BaseGroupHasHiGroupColorFk)
HiGroupColor.constraints->add(ColorIsUsedByHiGroupColorFk)

var HiGroupStyle = Relation('Highlight Group Style', {
    background:    Str,
    variant:       Str,
    version:       Int,
    hiGroupName:   Str,
    styleAttr:     Str,
    value:         Str,
  },
  [['hiGroupName', 'variant', 'background', 'version', 'styleAttr', 'value']]
)

const StyleAttributeIsAssignedAValueInHiGroupStyleFk = ForeignKey(
  HiGroupStyle,   ['variant', 'styleAttr'],
  StyleAttribute, ['variant', 'styleAttr']
)

const BaseGroupHasHiGroupStyleFk = ForeignKey(
  HiGroupStyle,   ['hiGroupName', 'variant', 'background', 'version'],
  BaseGroup,      ['hiGroupName', 'variant', 'background', 'version']
)
HiGroupStyle.constraints->add(StyleAttributeIsAssignedAValueInHiGroupStyleFk)
HiGroupStyle.constraints->add(BaseGroupHasHiGroupStyleFk)
# }}}

