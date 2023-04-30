vim9script

import 'libcolor.vim'      as libcolor
import 'librelalg.vim'     as ra
import './colorscheme.vim' as themes

const Colorscheme          = themes.Colorscheme
const NO_DISCR             = themes.DEFAULT_DISCR_VALUE
const ContrastRatio        = libcolor.ContrastRatio
const BrightnessDifference = libcolor.BrightnessDifference
const ColorDifference      = libcolor.ColorDifference
const Hex2Rgb              = libcolor.Hex2Rgb
const AntiEquiJoin         = ra.AntiEquiJoin
const EquiJoin             = ra.EquiJoin
const Extend               = ra.Extend
const GroupBy              = ra.GroupBy
const Product              = ra.Product
const Project              = ra.Project
const Query                = ra.Query
const Rel                  = ra.Rel
const Select               = ra.Select
const SortBy               = ra.SortBy
const StringAgg            = ra.StringAgg
const Table                = ra.Table
const Transform            = ra.Transform
const Union                = ra.Union

def NotIn(item: any, items: list<any>): bool
  return index(items, item) == -1
enddef

# Print details about the color palette for the specified background
def SimilarityTable(theme: Colorscheme, background: string): list<string>
  const db     = theme.Db(background)
  const colors = db.Color
    ->Select((t) => index(['', 'none', 'fg', 'bg'], t.ColorName) == -1)
    ->Extend((t) => {
      const rgbGui = Hex2Rgb(t.GUIValue)
      const rgbTerm = Hex2Rgb(t.Base256HexValue)
      return {
            \ 'GUI RGB': rgbGui,
            \ 'Term RGB': rgbTerm,
            \ 'Delta': ColorDifference(t.GUIValue, t.Base256HexValue)
            \ }
    })
    ->SortBy('Delta')

  var output = [printf('{{{ Color Similarity Table (%s)', background)]
  output += split(Table(colors, ['ColorName', 'GUIValue', 'GUI RGB', 'Base256Value', 'Term RGB', 'Delta']), '\n')
  output->add('}}} Color Similarity Table')

  return output
enddef

# Info about fg/bg pairs with low contrast
def CriticalPairs(theme: Colorscheme, background: string, gui: bool): list<string>
  const db        = theme.Db(background)
  const variant   = gui ? 'gui'      : '256'
  const colorAttr = gui ? 'GUIValue' : 'Base256HexValue'
  const report    = gui ? 'gui'      : 'terminal'

  const variantDefault = Query(db.BaseGroupOverride
    ->Select((t) => t.Variant == variant && t.DiscrValue == NO_DISCR)
  )

  const defaultDefs = Query(db.BaseGroup
    ->AntiEquiJoin(variantDefault, 'HiGroupName')
    ->Extend((t): dict<any> => {
      return { Variant: '', DiscrValue: '' }
    })
  )

  const pairs = Query(defaultDefs
    ->Union(db.BaseGroupOverride->Select((t) => t.Variant == variant))
    ->Select((t) => t.Fg->NotIn(['', 'none', 'fg', 'bg']) && t.Bg->NotIn(['', 'none', 'fg', 'bg']))
    ->GroupBy(['Fg', 'Bg', 'Variant'], StringAgg('HiGroupName', ', ', '', false), 'HighlightGroup')
    ->EquiJoin(db.Color, 'Fg', 'ColorName')
    ->EquiJoin(db.Color, 'Bg', 'ColorName', 'fg_')
    ->Extend((t): dict<any> => {
      return { ContrastRatio:  ContrastRatio(t['fg_' .. colorAttr], t[colorAttr]) }
    })
    ->Select((t) => t.ContrastRatio < 3.0)
    ->Extend((t): dict<any> => {
      return {
            \ BrightnessDiff: BrightnessDifference(t['fg_' .. colorAttr], t[colorAttr]),
            \ ColorDiff: ColorDifference(t['fg_' .. colorAttr], t[colorAttr]),
            \ Definition: empty(t.Variant) ? 'default' : 'override',
            \ }
    })
    ->SortBy('ContrastRatio')
  )

  var output: list<string> = []

  output->add(printf('{{{ Critical Pairs (%s %s)', background, report))
  output->add('Pairs of foreground/background colors not conforming to ISO-9241-3')
  output->add('')
  output += split(Table(
    pairs,
    ['Fg', 'Bg', 'ContrastRatio', 'BrightnessDiff', 'ColorDiff', 'HighlightGroup', 'Definition'],
    printf('%s (%s)', gui ? 'GUI' : 'Terminal', background)
  ), '\n')
  output->add('}}} Critical Pairs')

  return output
enddef

def Matrix(colors: list<dict<any>>, F: func(any, any): float, attr: string): list<list<float>>
  var pairs = colors->Transform((t) => [mapnew(colors, (_, u) => F(t[attr], u[attr]))])
  return pairs
enddef

def BuildMatrix(theme: Colorscheme, background: string, F: func(any, any): float, attr: string): list<string>
  const db     = theme.Db(background)
  const colors = Query(db.Color->Select((t) => t.ColorName->NotIn(['', 'none', 'fg', 'bg'])))
  const names  = mapnew(colors, (_, t) => t.ColorName)
  const M      = Matrix(colors, F, attr)

  var output: list<string> = []

  output->add("\t" .. join(names, "\t"))

  for i in range(len(M))
    const label = colors[i].ColorName
    output->add(printf(
      "%s\t%s\t%s",
      label, join(mapnew(M[i], (j, v) => j == i ? '' : printf("%5.02f", v)), "\t"), label
    ))
  endfor

  output->add("\t" .. join(names, "\t"))

  return output
enddef

def ContrastRatioMatrix(theme: Colorscheme, background: string, gui: bool): list<string>
  var output = [
    printf('{{{ Contrast Ratio Matrix (%s %s)', background, gui ? 'gui' : 'terminal'),
    'Pairs of colors with contrast ≥4.5 can be safely used as a fg/bg combo',
    '█ Not W3C conforming   █ Not ISO-9241-3 conforming',
  ]
  + BuildMatrix(theme, background, ContrastRatio, gui ? 'GUIValue' : 'Base256HexValue')
  + ['}}} Contrast Ratio Matrix']

  return output
enddef

def ColorDifferenceMatrix(theme: Colorscheme, background: string, gui: bool): list<string>
  var output = [
    printf('{{{ Color Difference Matrix (%s %s)', background, gui ? 'gui' : 'terminal'),
    'Pairs of colors whose color difference is ≥500 can be safely used as a fg/bg combo',
  ]
  + BuildMatrix(theme, background, ColorDifference, gui ? 'GUIValue' : 'Base256HexValue')
  + ['}}} Color Difference Matrix']

  return output
enddef

def BrightnessDifferenceMatrix(theme: Colorscheme, background: string, gui: bool): list<string>
  var output = [
    printf('{{{ Brightness Difference Matrix (%s %s)', background, gui ? 'gui' : 'terminal'),
    'Pairs of colors whose brightness difference is ≥125 can be safely used as a fg/bg combo',
  ]
  + BuildMatrix(theme, background, BrightnessDifference, gui ? 'GUIValue' : 'Base256HexValue')
  + ['}}} Brightness Difference Matrix']

  return output
enddef

def ColorInfo(theme: Colorscheme, background: string): list<string>
  if !theme.HasBackground(background)
    return []
  endif

  const db     = theme.Db(background)
  const colors = db.Color.instance
  const width  = 2 + max(mapnew(colors, (_, t) => len(t.ColorName))) # Find maximum length of color names

  execute printf('setlocal tabstop=%d shiftwidth=%d', width, width)

  var output: list<string> = []

  if theme.IsLightAndDark()
    output->add(printf('{{{ %s background', background))
  endif

  output += SimilarityTable(theme, background)

  for report in ['GUI', 'Terminal']
    const isGUI = report == 'GUI'
    output += ['', printf('{{{ %s Colors (%s)', report, background)]
    output += CriticalPairs(theme, background, isGUI)
    output += ContrastRatioMatrix(theme, background, isGUI)
    output += ColorDifferenceMatrix(theme, background, isGUI)
    output += BrightnessDifferenceMatrix(theme, background, isGUI)
    output += [printf('}}} %s Colors (%s)', report, background)]
  endfor

  if theme.IsLightAndDark()
    output->add('}}}')
  endif

  return output
enddef

export def ColorStats(theme: Colorscheme)
  silent botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted foldmethod=marker noet norl noswf nowrap
  set ft=colortemplate-info
  append(0, ['Color statistics for ' .. theme.fullname, '']
    + ColorInfo(theme, 'dark')
    + ['']
    + ColorInfo(theme, 'light')
  )
enddef

# vim: foldmethod=manual nowrap et ts=2 sw=2
