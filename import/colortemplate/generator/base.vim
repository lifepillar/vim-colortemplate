vim9script

import 'librelalg.vim'      as ra
import '../colorscheme.vim' as colorscheme
import '../version.vim'     as version

const DictTransform = ra.DictTransform
const Extend        = ra.Extend
const EquiJoin      = ra.EquiJoin
const Filter        = ra.Filter
const Query         = ra.Query
const Select        = ra.Select
const Sort          = ra.Sort
const SortBy        = ra.SortBy
const Table         = ra.Table
const Transform     = ra.Transform
type  Relation      = ra.Relation
type  Tuple         = ra.Tuple

type  Colorscheme = colorscheme.Colorscheme
type  Database    = colorscheme.Database
const VERSION     = version.VERSION

export def In(v: any, items: list<any>): bool
  return index(items, v) != -1
enddef

export def CompareDistinct(s1: string, s2: string): number
  return s1 < s2 ? -1 : 1
enddef

export def CompareByHiGroupName(t: dict<any>, u: dict<any>): number
  if t.HiGroup == u.HiGroup
    return 0
  elseif t.HiGroup == 'Normal'
    return -1
  elseif u.HiGroup == 'Normal'
    return 1
  endif

  return CompareDistinct(t.HiGroup, u.HiGroup)
enddef

export def CompareByDiscrName(t: dict<any>, u: dict<any>): number
  if t.DiscrName == u.DiscrName
    return 0
  endif

  return CompareDistinct(t.DiscrName, u.DiscrName)
enddef

export def CompareEnvironments(e1: string, e2: string): number
  if e1 == e2
    return 0
  elseif e1 == 'default'
    return -1
  elseif e2 == 'default'
    return 1
  elseif e1 == 'gui'
    return -1
  elseif e2 == 'gui'
    return 1
  else
    return str2nr(e1) > str2nr(e2) ? -1 : 1
  endif
enddef

def MergeTuple(t: Tuple, other_groups: Relation): Tuple
  # Return colors and style attributes of t except when a corresponding tuple in
  # other_groups exists, in which case prefer the attributes in other_groups.
  #
  # t:            a tuple from Database.BaseGroup.
  # other_groups: a subset of Database.BaseGroup. This should contain at most
  #               one tuple with HiGroup equal to t.HiGroup.
  var fg    = t.Fg
  var bg    = t.Bg
  var sp    = t.Special
  var style = t.Style
  var r     = Query(other_groups->Select((u) => u.HiGroup == t.HiGroup))

  if len(r) > 0
    if !empty(r[0].Fg)
      fg = r[0].Fg
    endif

    if !empty(r[0].Bg)
      bg = r[0].Bg
    endif

    if !empty(r[0].Special)
      sp = r[0].Special
    endif

    if !empty(r[0].Style)
      style = r[0].Style
    endif
  endif

  return {Fg: fg, Bg: bg, Special: sp, Style: style}
enddef

def MergeStyle(t: Tuple, other_groups: Relation): string
  # Return the style attribute from t, except when a corresponding tuple in
  # other_groups exists, in which case prefer the other style.
  #
  # t:            a tuple from Database.BaseGroup.
  # other_groups: a subset of Database.BaseGroup. This should contain at most
  #               one tuple with HiGroup equal to t.HiGroup.
  var style = t.Style
  var r     = Query(other_groups->Select((u) => u.HiGroup == t.HiGroup))

  if len(r) > 0
    if !empty(r[0].Style)
      style = r[0].Style
    endif
  endif

  return style
enddef

export def InstantiateBaseGroups(
    db:          Database,
    groups:      Relation,
    environment: string,
    discrName:   string = '',
    discrValue:  string = ''
    ): list<dict<string>>
  # Return the highlight group definitions for the given condition as a list
  # of dictionaries, where each dictionary has the correct attributes with
  # the correct values. For instance, a dictionary for a highlight group in
  # 256-color terminals may look as follows:
  #
  #     {ctermfg: '203': ctermbg: '16', ctermul: 'NONE', cterm: 'bold'}
  #
  # Which keys are returned depends on the environment.
  var attributes = db.Attribute
    ->Select((t) => t.Environment == environment)
    ->DictTransform((t) => {
      return {[t.AttrKey]: t.AttrType}
    }, true)

  var numColors = db.Environment.Lookup(['Environment'], [environment]).NumColors

  var records = groups->Transform((t) => {
    var out: dict<string> = {HiGroup: t.HiGroup}

    for [attr_key, attr_type] in items(attributes)
      if attr_type == 'Fg' || attr_type == 'Bg' || attr_type == 'Special'
        var colorAttr = attr_key[0] == 'g' ? 'GUI' : (numColors > 16 ? 'Base256' : 'Base16')

        out[attr_key] = db.Color.Lookup(['Name'], [t[attr_type]])[colorAttr]
      else
        out[attr_key] = t[attr_type]
      endif
    endfor

    return out
  })

  return records
enddef

export def LinkedGroupToString(t: Tuple, space: string): string
  if empty(t.TargetGroup)
    return null_string  # Skip definition
  endif

  return $"{space}hi! link {t.HiGroup} {t.TargetGroup}"
enddef

export def BaseGroupToString(t: Tuple, space: string): string
  var attributes: list<string> = []

  for attr in ['guifg', 'guibg', 'guisp', 'gui', 'font', 'ctermfg', 'ctermbg', 'ctermul', 'cterm', 'term', 'start', 'stop']
    var value = get(t, attr, '')

    if !empty(value)
      attributes->add($'{attr}={value}')
    endif
  endfor

  if empty(attributes)
    return null_string  # Skip definition
  endif

  return $"{space}hi {t.HiGroup} {join(attributes, ' ')}"
enddef

export def BestCtermEnvironment(environments: list<string>): string
  for env in ['256', '88', '16', '8']
    if env->In(environments)
      return env
    endif
  endfor
  return ''
enddef

export def EmitDefaultDefinitions(
    db:                  Database,
    environments:        list<string>,
    cterm_env:           string,
    default_base_groups: Relation,
    group_overrides:     Relation,
    space:               string
    ): list<string>
  # We want the default definitions to be as complete as possible, so gui,
  # cterm, and term attributes are merged into a single definition.
  #
  # db:                 a color scheme database
  # environments:       the color scheme's environments (Environments
  #                     metadata)
  # cterm_env:          cterm environment to merge (use '' if no cterm should
  #                     be merged).
  # default_base_group: definitions for the default environment. Note that
  #                     this variable is modified in-place.
  # group_overrides:    environment-specific definitions
  # space:              indentation level
  var output: list<string> = []
  var groups = default_base_groups

  if 'gui'->In(environments)
    # Extend the default highlight group definitions with `gui*`
    # attributes, whose values are taken from the 'gui' environment if
    # a corresponding specific definition was provided, otherwise the
    # default values are used.
    var gui_base_groups = Query(
      group_overrides
      ->Select((t) => t.Environment == 'gui' && empty(t.DiscrName))
    )

    groups = Query(groups->Extend((t) => {
      var t0 = MergeTuple(t, gui_base_groups)
      var u  = {
        guifg: db.Color.Lookup(['Name'], [t0.Fg]).GUI,
        guibg: db.Color.Lookup(['Name'], [t0.Bg]).GUI,
        guisp: db.Color.Lookup(['Name'], [t0.Special]).GUI,
        gui:   t0.Style,
        cterm: t0.Style} # For capable terminals when termguicolors is set

      # See https://github.com/lifepillar/vim-colortemplate/issues/15
      if u.guifg == 'NONE' && u.guibg == 'NONE'
        u['ctermfg'] = 'NONE'
        u['ctermbg'] = 'NONE'
      endif

      return u
    }))
  endif

  if !empty(cterm_env)
    var cterm_attr = str2nr(cterm_env) > 16 ? 'Base256' : 'Base16'
    var cterm_base_groups = Query(
      group_overrides
      ->Select((t) => t.Environment == cterm_env && empty(t.DiscrName))
    )

    # Extend the default highlight group definitions with `cterm*`
    # attributes, whose values are taken from the best cterm environment if
    # a corresponding specific definition was provided, otherwise the
    # default values are used.
    groups = Query(groups->Extend((t) => {
      var t0 = MergeTuple(t, cterm_base_groups)

      return {
        ctermfg: db.Color.Lookup(['Name'], [t0.Fg])[cterm_attr],
        ctermbg: db.Color.Lookup(['Name'], [t0.Bg])[cterm_attr],
        ctermul: db.Color.Lookup(['Name'], [t0.Special])[cterm_attr],
        cterm: t0.Style}
    }, {force: true}))
  endif

  # Add `term` attribute if required
  if '0'->In(environments)
    var bw_base_groups = Query(group_overrides
      ->Select((t) => t.Environment == '0' && empty(t.DiscrName))
    )

    # Extend the default highlight group definitions with a `term`
    # attribute, whose value is taken from a '0' environment if
    # a corresponding definition was provided, otherwise the default style
    # is used.
    groups = Query(groups->Extend((t) => {
      var style = MergeStyle(t, bw_base_groups)

      return {term: style}
    }))
  endif

  output += groups
    ->Sort(CompareByHiGroupName)
    ->Transform((t) => BaseGroupToString(t, space))

  return output
enddef

const dark_regex  = '\m^\%(7\*\=\|9\*\=\|\d\d\|Brown\|DarkYellow\|\%(Light\|Dark\)\=\%(Gr[ae]y\)\|\%[Light]\%(Blue\|Green\|Cyan\|Red\|Magenta\|Yellow\)\|White\)$'
const light_regex = '\m^\%(\%(0\|1\|2\|3\|4\|5\|6\|8\)\*\=\|Black\|Dark\%(Blue\|Green\|Cyan\|Red\|Magenta\)\)$'

# In Vim < 8.1.0616, `hi Normal ctermbg=...` may change the value of
# 'background'. This function checks the conditions under which that may
# happen The function's name is a reference to the original issue report,
# which had an example using color 234.
#
# See https://github.com/lifepillar/vim-colortemplate/issues/13.
export def CheckBugBg234(
    db: Database,
    environment: string,
    numColors:   number,
    discrName:   string = '',
    discrValue:  string = ''
    ): bool
  var definition = Query(EquiJoin(
    db.BaseGroup->Select((t) => t.HiGroup == 'Normal'),
    db.Condition->Select(
      (t) => t.Environment == environment && t.DiscrName == discrName && t.DiscrValue == discrValue
    ),
    {on: 'Condition'}
  ))

  if empty(definition)
    return false
  endif

  var bg = Query(db.Color->EquiJoin(definition, {onleft: 'Name', onright: 'Bg'}))[0]

  if db.background == 'dark'
    return (
      numColors > 16       &&
      bg.Base256 != 'NONE' &&
      (str2nr(bg.Base256) >= 10 || str2nr(bg.Base256) == 7 || str2nr(bg.Base256) == 9)
    ) || bg.Base16 =~? dark_regex
  else # light background
    return numColors > 0 && numColors <= 16 && bg.Base16 =~# light_regex
  endif
enddef

export interface IGenerator
  def Generate(theme: Colorscheme): list<string>
endinterface

export abstract class Generator implements IGenerator
  var language:       string       = 'vim9'
  var comment_symbol: string       = '# '
  var let_keyword:    string       = ''
  var const_keyword:  string       = 'const '
  var var_prefix:     string       = ''
  var header:         list<string> = ['vim9script', '']
  var footer:         list<string> = ['']
  var indent:         number       = 0
  var shiftwidth:     number       = 2
  var space:          string       = ''

  abstract def Generate(theme: Colorscheme): list<string>

  def Indent()
    this.indent += this.shiftwidth
    this.space = repeat(' ', this.indent)
  enddef

  def Deindent()
    this.indent -= this.shiftwidth
    this.space = repeat(' ', this.indent)
  enddef

  def SetLanguage(language: string)
    if language == 'vim9'
      this.language       = 'vim9'
      this.comment_symbol = '# '
      this.let_keyword    = ''
      this.const_keyword  = 'const '
      this.var_prefix     = ''
      this.header         = ['vim9script', '']
      this.footer         = []
    elseif language == 'viml'
      this.language       = 'viml'
      this.comment_symbol = '" '
      this.let_keyword    = 'let '
      this.const_keyword  = 'let '
      this.var_prefix     = 's:'
      this.header         = []
      this.footer         = []
    endif
  enddef

  def AddMeta(template: string, value: string)
    if !empty(value)
      this.header->add(this.comment_symbol .. printf(template, value))
    endif
  enddef

  def AddMultivaluedMeta(template: string, items: list<string>)
    if !empty(items)
      this.AddMeta(template, items[0])

      var n = len(items)
      var space = repeat(' ', 14)
      var i = 1

      while i < n
        this.header->add(this.comment_symbol .. printf('%s%s', space, items[i]))
        ++i
      endwhile
    endif
  enddef

  def BuildDefaultHeader(theme: Colorscheme)
    this.header = this.language == 'vim9' ? ['vim9script', ''] : []

    var sa = len(theme.authors) > 1     ? 's:' : ': '
    var sm = len(theme.maintainers) > 1 ? 's:' : ': '
    var su = len(theme.urls) > 1        ? 's:' : ': '

    this.AddMeta('Name:         %s', theme.fullname)
    this.AddMeta('Version:      %s', theme.version)
    this.AddMultivaluedMeta('Description:  %s', theme.description)
    this.AddMultivaluedMeta($'Author{sa}      %s', theme.authors)
    this.AddMultivaluedMeta($'Maintainer{sm}  %s', theme.maintainers)
    this.AddMultivaluedMeta($'URL{su}         %s', theme.urls)
    this.AddMeta('License:      %s', theme.license)

    if theme.options.timestamp
      this.AddMeta('Last Change:  %s', strftime(theme.options.dateformat))
    endif

    this.header->add('')

    if theme.options.creator
      this.AddMeta('Generated by Colortemplate v%s', VERSION)
      this.header->add('')
    endif

    if !theme.backgrounds.light
      this.header->add('set background=dark')->add('')
    elseif !theme.backgrounds.dark
      this.header->add('set background=light')->add('')
    endif

    this.header->add('hi clear')
    this.header->add($"{this.let_keyword}g:colors_name = '{theme.shortname}'")

    if !empty(theme.verbatimtext)
      this.header->add('')
      this.header += theme.verbatimtext
    endif
  enddef

  def BuildDefaultFooter(theme: Colorscheme)
    this.footer = []

    if theme.options.palette # Write the color palette as a comment
      for background in ['dark', 'light']
        if theme.HasBackground(background)
          var db = theme.Db(background)
          var palette = db.Color
            ->Select((t) => !empty(t.Name) && t.Name != 'none' && t.Name != 'fg' && t.Name != 'bg')
            ->SortBy('Name')

          this.footer->add(this.comment_symbol .. 'Background: ' .. background)
          this.footer->add(this.comment_symbol)
          this.footer += map(split(Table(palette, {
            columns: [
              'Name',
              'GUI',
              'Base256',
              'Base256Hex',
              'Base16'
            ]
          }), "\n"), (_, v) => this.comment_symbol .. v)
          this.footer->add('')
        endif
      endfor
    endif

    this.footer->add('')
    this.footer->add(this.comment_symbol .. $'vim: et ts=8 sw={theme.options.shiftwidth} sts={theme.options.shiftwidth}')
  enddef

  def CheckBugBg234(db: Database, environment: string, discrName: string = '', discrValue = ''): list<string>
    output: list<string> = []

    if CheckBugBg234(db, environment, discrName, discrValue)
      output->add($"{this.space}if !has('patch-8.0.0616') {this.comment_symbol} Fix for Vim bug")
      this.Indent()
      output->add($'{this.space}set background={this.background}')
      this.Deindent()
      output->add($'{this.space}endif')
    endif

    return output
  enddef

  def CheckForEmptyTCo(): list<string>
    var output: list<string> = ['', this.space .. 'if empty(&t_Co)']

    this.Indent()
    output->add(this.space .. 'finish')
    this.Deindent()
    output->add(this.space .. 'endif')

    return output
  enddef
endclass
