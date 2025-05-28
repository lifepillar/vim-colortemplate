vim9script

import 'librelalg.vim'      as ra
import './base.vim'         as base
import '../colorscheme.vim' as colorscheme

const EquiJoin             = ra.EquiJoin
const LeftEquiJoin         = ra.LeftEquiJoin
const Query                = ra.Query
const Select               = ra.Select
const Sort                 = ra.Sort
const SortBy               = ra.SortBy
const Transform            = ra.Transform
type  Tuple                = ra.Tuple

const CompareEnvironments  = base.CompareEnvironments
const CompareByHiGroupName = base.CompareByHiGroupName
type  BaseGenerator        = base.Generator

type  Colorscheme          = colorscheme.Colorscheme
type  Database             = colorscheme.Database

def NotIn(item: any, items: list<any>): bool
  return index(items, item) == -1
enddef

def CompareByHiGroupNameEnvironmentDiscrValue(t: Tuple, u: Tuple): number
  var cmp = CompareByHiGroupName(t, u)

  if cmp == 0
    cmp = CompareEnvironments(t.Environment, u.Environment)
  endif

  if cmp == 0
    cmp = t.DiscrValue < u.DiscrValue ? -1 : t.DiscrValue > u.DiscrValue ? 1 : 0
  endif

  return cmp
enddef

def Header(theme: Colorscheme): list<string>
  var header = [
    'Full Name:     ' .. theme.fullname,
    'Short name:    ' .. theme.shortname,
  ]

  if !empty(theme.prefix) && theme.prefix != theme.shortname
    header->add('Prefix:        ' .. theme.prefix)
  endif

  for author in theme.authors
    header->add('Author:        ' .. author)
  endfor

  for maintainer in theme.maintainers
    header->add('Maintainer:    ' .. maintainer)
  endfor

  for url in theme.urls
    header->add('URL:           ' .. url)
  endfor

  for description in theme.description
    header->add('Description:   ' .. description)
  endfor

  if !empty(theme.license)
    header->add('License:       ' .. theme.license)
  endif

  header->add('')

  for option in sort(keys(theme.options))
    var value = theme.options[option]
    var v = option == 'dateformat' ? $'"{value}"' : value

    header->add($"Options:       {option}={v}")
  endfor

  header->add('')
  header->add('Environments: ' .. join(sort(theme.environments, CompareEnvironments), ' '))

  if !empty(theme.rawverbatimtext)
    header->add('')
    header->add('verbatim')
    header += theme.rawverbatimtext
    header->add('endverbatim')
  endif

  return header
enddef

def Footer(): list<string>
  return ['; vim: ft=colortemplate fdm=marker nowrap et sw=2 ts=2']
enddef

def Colors(db: Database): list<string>
  var output = db.Color
    ->Select((t) => t.Name->NotIn(['', 'fg', 'bg', 'none']))
    ->Transform((t) => {
      var base16 = empty(t.Base16) || t.Base16 == 'NONE' ? '' : ' ' .. t.Base16

      return $"Color: {t.Name} {t.GUI} {t.Base256}{base16}"
    })


  if !empty(db.termcolors)
    output->add('')
    output->add('Term Colors: ' .. join(db.termcolors, ' '))
  endif

  return output
enddef

def VerbatimText(db: Database): list<string>
  var output: list<string> = []

  if !empty(db.rawverbatimtext)
    output->add('')
    output->add('verbatim')
    output += db.rawverbatimtext
    output->add('endverbatim')
  endif

  return output
enddef

def Discriminators(db: Database): list<string>
  var output: list<string> = []
  var defs = db.Discriminator->Select((t) => !empty(t.DiscrName))->SortBy('DiscrNum')->Transform(
    (t) => $'#const {t.DiscrName} = {t.RawDefinition}'
  )

  if !empty(defs)
    output->add('')
    output += defs
  endif

  return output
enddef

def HiGroupDefinitions(db: Database): list<string>
  var output: list<string> = []
  # SourceGroup [/environment +discriminator value] -> TargetGroup
  var linked_format = '%s%s%s%s -> %s'
  # HiGroup [/environment +discriminator value] fg bg [s=special style_attributes]
  var base_format = '%s%s%s%s %s %s%s%s'

  output += EquiJoin(
    db.HighlightGroupDef,
    db.Condition->Select((t) => t.Environment != '0'),
    {on: 'Condition', prefix: 'c_'}
  )
  ->LeftEquiJoin(db.LinkedGroup, {
    on: ['HiGroup', 'Condition'],
    filler: [{HiGroup: '', Condition: -1, TargetGroup: ''}],
    prefix: 'l_',
  })
  ->LeftEquiJoin(db.BaseGroup, {
    on: ['HiGroup', 'Condition'],
    filler:  [{HiGroup: '', Condition: -1, Fg: '', Bg: '', Special: '', Style: '', Font: '', Start: '', Stop: ''}],
    prefix: 'b_',
  })
  ->Sort(CompareByHiGroupNameEnvironmentDiscrValue)
  ->Transform((t) => {
    if t.IsLinked
      return printf(linked_format,
        t.HiGroup,
        t.Environment == 'default' ? '' : '/' .. t.Environment,
        empty(t.DiscrName)         ? '' : '+' .. t.DiscrName,
        empty(t.DiscrName)         ? '' : ' ' .. t.DiscrValue,
        empty(t.TargetGroup) ? 'omit' : t.TargetGroup
      )
    else
      return printf(base_format,
        t.HiGroup,
        t.Environment == 'default' ? '' : '/' .. t.Environment,
        empty(t.DiscrName)         ? '' : '+' .. t.DiscrName,
        empty(t.DiscrName)         ? '' : ' ' .. t.DiscrValue,
        empty(t.Fg) ? 'omit' : t.Fg,
        empty(t.Bg) ? 'omit' : t.Bg,
        empty(t.Special) ? ' s=omit' : (t.Special == 'none' ? '' : ' s=' .. t.Special),
        empty(t.Style)   ? ' omit'   : (t.Style   == 'NONE' ? '' : ' '   .. t.Style)
      )
    endif
  })

  return output
enddef

def TermHiGroupDefinitions(db: Database): list<string>
  var linked_format = '%s%s%s%s -> %s'
  var base_format = '%s/0%s%s omit omit%s'
  var output: list<string> = []

  output += EquiJoin(
    db.HighlightGroupDef,
    db.Condition->Select((t) => t.Environment == '0'),
    {on: 'Condition', prefix: 'c_'}
  )
  ->LeftEquiJoin(db.LinkedGroup, {
    on: ['HiGroup', 'Condition'],
    filler: [{HiGroup: '', Condition: -1, TargetGroup: ''}],
    prefix: 'l_',
  })
  ->LeftEquiJoin(db.BaseGroup, {
    on: ['HiGroup', 'Condition'],
    filler:  [{HiGroup: '', Condition: -1, Fg: '', Bg: '', Special: '', Style: '', Font: '', Start: '', Stop: ''}],
    prefix: 'b_',
  })
  ->Sort(CompareByHiGroupNameEnvironmentDiscrValue)
  ->Transform((t) => {
    if t.IsLinked
      return printf(linked_format,
        t.HiGroup,
        t.Environment == 'default' ? '' : '/' .. t.Environment,
        empty(t.DiscrName)         ? '' : '+' .. t.DiscrName,
        empty(t.DiscrName)         ? '' : ' ' .. t.DiscrValue,
        empty(t.TargetGroup) ? 'omit' : t.TargetGroup)
    else
      return printf(base_format,
        t.HiGroup,
        empty(t.DiscrName) ? '' : '+' .. t.DiscrName,
        empty(t.DiscrName) ? '' : ' ' .. t.DiscrValue,
        empty(t.Style) ? ' omit' : (t.Style == 'NONE'  ? '' : ' ' .. t.Style)
      )
    endif
  })

  return output
enddef

export class Generator extends BaseGenerator
  def Generate(theme: Colorscheme): list<string>
    var output: list<string> = []

    output += Header(theme)

    for background in ['dark', 'light']
      if !theme.HasBackground(background)
        continue
      endif

      var db = theme.Db(background)

      output->add('')
      output->add('Background: ' .. background)
      output->add('')
      output += Colors(db)
      output += VerbatimText(db)
      output += Discriminators(db)
      output->add('')
      output += HiGroupDefinitions(db)
      output->add('')
      output += TermHiGroupDefinitions(db)
    endfor

    output->add('')
    output += Footer()

    return output
  enddef
endclass
