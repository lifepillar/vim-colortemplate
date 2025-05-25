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

const CompareByHiGroupName   = base.CompareByHiGroupName
const CompareEnvironments    = base.CompareEnvironments
const InstantiateBaseGroups  = base.InstantiateBaseGroups
const LinkedGroupToString    = base.LinkedGroupToString
const BaseGroupToString      = base.BaseGroupToString
const BestCtermEnvironment   = base.BestCtermEnvironment
const EmitDefaultDefinitions = base.EmitDefaultDefinitions


def In(v: any, items: list<any>): bool
  return index(items, v) != -1
enddef

export class Generator extends base.Generator
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

    var db              = theme.Db(background)
    var environments    = sort(theme.environments, CompareEnvironments)
    var best_cterm_env  = BestCtermEnvironment(environments)
    var discriminators  = sort(
      db.Discriminator
      ->Transform((t)  => empty(t.DiscrName) ? null_string : t.DiscrName)
    )
    var output: list<string> = []

    output->add('')

    if theme.IsLightAndDark()
      output->add($"if &background == '{background}'")
      this.Indent()
    endif

    # Terminal colors
    if !empty(db.termcolors)
      output->add(printf($'{this.space}g:terminal_ansi_colors = %s',
        mapnew(db.termcolors, (_, name) => db.Color.Lookup(['Name'], [name]).GUI)
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

    # Highligh group definitions
    var [default_linked_groups, linked_group_overrides] = Split(EquiJoin(
      db.LinkedGroup,
      db.Condition,
      {on: 'Condition'}
    ), (t) => t.Environment == 'default' && empty(t.DiscrName)) # && empty(t.DiscrValue) implied

    var [default_base_groups, base_group_overrides] = Split(EquiJoin(
      db.BaseGroup,
      db.Condition,
      {on: 'Condition'}
    ), (t) => t.Environment == 'default' && empty(t.DiscrName)) # && empty(t.DiscrValue) implied

    # Generate default definitions for linked groups
    output += default_linked_groups
      ->Sort(CompareByHiGroupName)
      ->Transform((t) => LinkedGroupToString(t, this.space))

    # Generate default definitions for base groups
    output += EmitDefaultDefinitions(
      db,
      environments,
      best_cterm_env,
      default_base_groups,
      base_group_overrides,
      this.space
    )

    # Deal with the remaining environment-specific definitions
    for environment in environments
      var env_linked = Query(
        linked_group_overrides->Select((t) => t.Environment == environment)
      )

      var env_base: list<dict<any>>

      # Skip definitions incorporated into the default definitions above
      if environment->In(['gui', best_cterm_env, '0'])
        env_base = Query(
          base_group_overrides->Select(
            (t) => t.Environment == environment && !empty(t.DiscrName)
          )
        )
      else
        env_base = Query(
          base_group_overrides->Select((t) => t.Environment == environment)
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

      # Generate environment-specific overrides
      output += env_linked_no_discr
        ->Sort(CompareByHiGroupName)
        ->Transform((t) => LinkedGroupToString(t, this.space))

      output += InstantiateBaseGroups(db, env_base_no_discr, environment)
        ->Sort(CompareByHiGroupName)
        ->Transform((t) => BaseGroupToString(t, this.space))

      # Generate discriminator-specific overrides
      output += this.EmitDiscriminatorBasedDefinitions(
        db,
        environment,
        discriminators,
        env_linked_discr,
        env_base_discr
      )

      # Closing statements
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
      (t) => $'{space}const {t.DiscrName} = {t.Definition}'
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
          output->add($"{this.space}if {discrName} == {condition.DiscrValue}")
        else
          this.Deindent()
          output->add($"{this.space}elseif {discrName} == {condition.DiscrValue}")
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
