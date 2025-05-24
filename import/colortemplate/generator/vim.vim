vim9script

import 'librelalg.vim'      as ra
import './base.vim'         as base
import '../colorscheme.vim' as colorscheme


type  Relation      = ra.Relation
const DictTransform = ra.DictTransform
const Extend        = ra.Extend
const EquiJoin      = ra.EquiJoin
const Filter        = ra.Filter
const NatJoin       = ra.NatJoin
const PartitionBy   = ra.PartitionBy
const Project       = ra.Project
const Query         = ra.Query
const Select        = ra.Select
const Sort          = ra.Sort
const SortBy        = ra.SortBy
const Split         = ra.Split
const Transform     = ra.Transform

type Colorscheme = colorscheme.Colorscheme
type Database    = colorscheme.Database

const CompareByHiGroupName = base.CompareByHiGroupName
const CompareEnvironments  = base.CompareEnvironments


def In(v: any, items: list<any>): bool
  return index(items, v) != -1
enddef

def InstantiateBaseGroups(
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

def LinkedGroupToString(t: dict<any>, space: string): string
  if empty(t.TargetGroup)
    return null_string  # Skip definition
  endif

  return $"{space}hi! link {t.HiGroup} {t.TargetGroup}"
enddef

def BaseGroupToString(t: dict<any>, space: string): string
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

export class Generator extends base.Generator
  var indent = 0
  var shiftwidth = 2
  var space = ''

  def Indent()
    this.indent += this.shiftwidth
    this.space = repeat(' ', this.indent)
  enddef

  def Deindent()
    this.indent -= this.shiftwidth
    this.space = repeat(' ', this.indent)
  enddef

  def Generate(theme: Colorscheme): list<string>
    var output: list<string> = []

    this.shiftwidth = theme.options.shiftwidth
    this.indent = 0
    this.space = ''
    this.BuildDefaultHeader(theme)
    this.BuildDefaultFooter(theme)

    output += this.header
    output += this.Emit(theme, 'dark')
    output += this.Emit(theme, 'light')
    output += this.footer

    return output
  enddef

  def Emit(theme: Colorscheme, background: string): list<string>
    if !theme.HasBackground(background)
      return []
    endif

    var db = theme.Db(background)
    var output: list<string> = []

    output->add('')

    if theme.IsLightAndDark()
      output->add($"if &background == '{background}'")
      this.Indent()
    endif

    # Terminal colors
    if !empty(db.termcolors)
      output->add(printf($'%s{this.let_keyword}g:terminal_ansi_colors = %s',
        this.space, mapnew(db.termcolors, (_, name) => db.Color.Lookup(['Name'], [name]).GUI)
      ))
      output->add('')
    endif

    # Background-specific verbatim text
    if !empty(db.verbatimtext)
      output += mapnew(
        db.verbatimtext, (_, l) => empty(l) ? l : this.space .. l
      )
      output->add('')
    endif

    # Definitions of discriminator variables
    output += this.EmitDiscriminators(db, this.space)
    output->add('')

    var [default_linked_group, linked_group_override] = Split(EquiJoin(
      db.LinkedGroup,
      db.Condition,
      {on: 'Condition'}
    ), (t) => t.Environment == 'default' && empty(t.DiscrName)) # && empty(t.DiscrValue) implied

    var [default_base_group, base_group_override] = Split(EquiJoin(
      db.BaseGroup,
      db.Condition,
      {on: 'Condition'}
    ), (t) => t.Environment == 'default' && empty(t.DiscrName)) # && empty(t.DiscrValue) implied

    # We want the default definitions to be as complete as possible, so we
    # determine which attributes to use for them.

    if 'gui'->In(theme.environments)
      # Extend the default highlight group definitions with `gui*`
      # attributes, whose values are taken from the 'gui' environment if
      # a corresponding specific definition was provided, otherwise the
      # default values are used.
      var gui_base_group = Query(
        base_group_override
        ->Select((t) => t.Environment == 'gui' && empty(t.DiscrName))
      )

      default_base_group = Query(default_base_group->Extend((t) => {
        var fg    = t.Fg
        var bg    = t.Bg
        var sp    = t.Special
        var style = t.Style
        var r     = Query(gui_base_group->Select((u) => u.HiGroup == t.HiGroup))

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

        var u = {
          guifg: db.Color.Lookup(['Name'], [fg]).GUI,
          guibg: db.Color.Lookup(['Name'], [bg]).GUI,
          guisp: db.Color.Lookup(['Name'], [sp]).GUI,
          gui:   style,
          cterm: style} # For capable terminals when termguicolors is set

        # See https://github.com/lifepillar/vim-colortemplate/issues/15
        if u.guifg == 'NONE' && u.guibg == 'NONE'
          u['ctermfg'] = 'NONE'
          u['ctermbg'] = 'NONE'
        endif

        return u
      }))
    endif

    # Find the best cterm environment for which definitions must be generated
    var best_cterm = ''
    var cterm_attr = ''

    for env in ['256', '88', '16', '8']
      if env->In(theme.environments)
        best_cterm = env

        if str2nr(env) > 16
          cterm_attr = 'Base256'
        else
          cterm_attr = 'Base16'
        endif

        break
      endif
    endfor

    if !empty(best_cterm)
      var cterm_base_group = Query(
        base_group_override
        ->Select((t) => t.Environment == best_cterm && empty(t.DiscrName))
      )

      # Extend the default highlight group definitions with `cterm*`
      # attributes, whose values are taken from the best cterm environment if
      # a corresponding specific definition was provided, otherwise the
      # default values are used.
      default_base_group = Query(default_base_group->Extend((t) => {
        var fg    = t.Fg
        var bg    = t.Bg
        var sp    = t.Special
        var style = t.Style
        var r     = Query(cterm_base_group->Select((u) => u.HiGroup == t.HiGroup))

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

        return {
          ctermfg: db.Color.Lookup(['Name'], [fg])[cterm_attr],
          ctermbg: db.Color.Lookup(['Name'], [bg])[cterm_attr],
          ctermul: db.Color.Lookup(['Name'], [sp])[cterm_attr],
          cterm: style}
      }, {force: true}))
    endif

    # Add `term` attribute if required
    if '0'->In(theme.environments)
      var bw_base_group = Query(base_group_override
        ->Select((t) => t.Environment == '0' && empty(t.DiscrName))
      )

      # Extend the default highlight group definitions with a `term`
      # attribute, whose value is taken from a '0' environment if
      # a corresponding definition was provided, otherwise the default style
      # is used.
      default_base_group = Query(default_base_group->Extend((t) => {
        var r = Query(bw_base_group->Select((u) => u.HiGroup == t.HiGroup))
        var style = t.Style

        if len(r) > 0
          if !empty(r[0].Style)
            style = r[0].Style
          endif
        endif

        return {term: style}
      }))
    endif

    # Generate default definitions
    output += default_linked_group
      ->Sort(CompareByHiGroupName)
      ->Transform((t) => LinkedGroupToString(t, this.space))

    output += default_base_group
      ->Sort(CompareByHiGroupName)
      ->Transform((t) => BaseGroupToString(t, this.space))

    var discriminators = sort(
      db.Discriminator
      ->Transform((t) => empty(t.DiscrName) ? null_string : t.DiscrName)
    )

    # Default discriminator-specific overrides
    output += this.EmitDiscriminatorBasedDefinitions(
      db,
      'default',
      discriminators,
      linked_group_override,
      base_group_override
    )

    # Now we have to deal with the remaining environment-specific and
    # discriminator-specific definitions
    for environment in sort(theme.environments, CompareEnvironments)
      var env_linked = Query(
        linked_group_override->Select((t) => t.Environment == environment)
      )

      var env_base: list<dict<any>>

      # Skip definitions incorporated into the default definitions above
      if environment->In(['gui', best_cterm, '0'])
        env_base = Query(
          base_group_override->Select(
            (t) => t.Environment == environment && !empty(t.DiscrName)
          )
        )
      else
        env_base = Query(
          base_group_override->Select((t) => t.Environment == environment)
        )
      endif

      if empty(env_linked) && empty(env_base)
        continue
      endif

      var startif = environment == 'gui'
        ? this.space .. "if has('gui_running') || (has('termguicolors') && &termguicolors)"
        : this.space .. $"if str2nr(&t_Co) >= {environment}"

      this.Indent()
      output->add('')
      output->add(startif)

      var [env_linked_no_discr, env_linked_discr] = Split(
        env_linked, (t) => empty(t.DiscrName)
      )

      var [env_base_no_discr, env_base_discr] = Split(
        env_base, (t) => empty(t.DiscrName)
      )

      # Output environment-specific overrides
      output += env_linked_no_discr
        ->Sort(CompareByHiGroupName)
        ->Transform((t) => LinkedGroupToString(t, this.space))

      output += InstantiateBaseGroups(db, env_base_no_discr, environment)
        ->Sort(CompareByHiGroupName)
        ->Transform((t) => BaseGroupToString(t, this.space))

      # Discriminator-specific overrides
      output += this.EmitDiscriminatorBasedDefinitions(
        db,
        environment,
        discriminators,
        env_linked_discr,
        env_base_discr
      )

      if environment != 'gui'
        output->add(this.space .. 'finish')
      endif

      this.Deindent()

      output->add(this.space .. 'endif')
    endfor

    if theme.IsLightAndDark()
      output->add(this.space .. 'finish')
      this.Deindent()
      output->add('endif')
    endif

    return output
  enddef

  def EmitDiscriminators(db: Database, space: string): list<string>
    return db.Discriminator->Filter((t) => !empty(t.DiscrName))->SortBy('DiscrNum')->Transform(
      (t) => $'{space}{this.const_keyword}{this.var_prefix}{t.DiscrName} = {t.Definition}'
    )
  enddef

  def EmitDiscriminatorBasedDefinitions(
      db:             Database,
      environment:    string,
      discriminators: list<string>,
      linked_groups:  Relation,
      base_groups:    Relation
      ): list<string>
    var output: list<string> = []

    for discrName in sort(discriminators)
      var conditions = db.Condition
        ->Select((t) => t.Environment == environment && t.DiscrName == discrName)
        ->SortBy('DiscrValue')

      if empty(conditions)
        continue
      endif

      var first = true

      for condition in conditions
        var discr_linked = Query(linked_groups->Select((u) => u.Condition == condition.Condition))
        var discr_base = Query(base_groups->Select((u) => u.Condition == condition.Condition))

        if first
          output->add($"{this.space}if {this.var_prefix}{discrName} == {condition.DiscrValue}")
        else
          this.Deindent()
          output->add($"{this.space}elseif {this.var_prefix}{discrName} == {condition.DiscrValue}")
        endif

        this.Indent()

        output += discr_linked
          ->Sort(CompareByHiGroupName)
          ->Transform((t) => LinkedGroupToString(t, this.space))

        output += InstantiateBaseGroups(db, discr_base, environment)
          ->Sort(CompareByHiGroupName)
          ->Transform((t) => BaseGroupToString(t, this.space))

        first = false
      endfor

      this.Deindent()
      output->add(this.space .. 'endif')
    endfor

      return output
  enddef
endclass
