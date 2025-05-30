vim9script

import 'librelalg.vim'      as ra
import './base.vim'         as base
import '../colorscheme.vim' as colorscheme


type  Relation      = ra.Relation
const AntiEquiJoin  = ra.AntiEquiJoin
const EquiJoin      = ra.EquiJoin
const Filter        = ra.Filter
const PartitionBy   = ra.PartitionBy
const Query         = ra.Query
const Select        = ra.Select
const SemiJoin      = ra.SemiJoin
const Sort          = ra.Sort
const SortBy        = ra.SortBy
const Split         = ra.Split
const Transform     = ra.Transform
const Union         = ra.Union

type Colorscheme = colorscheme.Colorscheme
type Database    = colorscheme.Database

const CompareByHiGroupName   = base.CompareByHiGroupName
const CompareEnvironments    = base.CompareEnvironments
const InstantiateBaseGroups  = base.InstantiateBaseGroups
const LinkedGroupToString    = base.LinkedGroupToString
const BaseGroupToString      = base.BaseGroupToString
const BestCtermEnvironment   = base.BestCtermEnvironment
const EmitDefaultDefinitions = base.EmitDefaultDefinitions
const CheckBugBg234          = base.CheckBugBg234


def In(v: any, items: list<any>): bool
  return index(items, v) != -1
enddef

export class Generator extends base.Generator
  def Generate(theme: Colorscheme): list<string>
    var output: list<string> = []

    this.SetLanguage('viml')

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
      output->add(printf($'{this.space}let g:terminal_ansi_colors = %s',
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

    if theme.options.vimlcompatibility > 0
      output += this.GenerateCodeForBugBg234(db, environments, 'default')
    endif

    # Deal with the remaining environment-specific definitions
    var env_linked_classes = linked_group_overrides->PartitionBy('Environment')
    var env_base_classes = base_group_overrides->PartitionBy('Environment')

    for environment in environments
      if environment->In(['gui', best_cterm_env, '0'])
        # Skip definitions incorporated into the default definitions above
        if env_base_classes->has_key(environment)
          env_base_classes[environment] = Query(
            env_base_classes[environment]
            ->Select((t) => !empty(t.DiscrName))  # Exclude definitions with an empty discriminator
            ->Union(env_base_classes[environment]
            ->SemiJoin(
              default_linked_groups,
              (t, u) => t.HiGroup == u.HiGroup
            )   # ...except those that by default were linked
            )
          )
        endif
      else # For the other envs, add default definitions if not overridden
        if !env_base_classes->has_key(environment)
          env_base_classes[environment] = []
        endif

        env_base_classes[environment] += Query(AntiEquiJoin(
          default_base_groups,
          env_base_classes[environment]->Select((t) => empty(t.DiscrName)),
          {on: 'HiGroup'}
        ))
      endif
    endfor

    # Keep track of which environments have no overriding definitions
    var is_empty_env: dict<bool> = {}
    var has_non_empty_terminal_env = false

    for env in environments
      is_empty_env[env] = empty(get(env_linked_classes, env, [])) && empty(get(env_base_classes, env, []))

      if !is_empty_env[env] && env != 'gui'
        has_non_empty_terminal_env = true
      endif
    endfor

    var i = 0

    while i < len(environments)
      var environment = environments[i]

      ++i

      # If there are no environment-specific overrides for the current
      # environment and for the next one, this iteration can be skipped. If
      # this environment is empty, but the next one is not, we still need to
      # generate a `finish` statement to avoid falling through less capable
      # environments.
      if is_empty_env[environment]
        if environment == 'gui'
          if has_non_empty_terminal_env
            output += this.CheckForEmptyTCo()
          endif

          continue
        endif

        # If there is no next environment or the next environment is empty,
        # skip this iteration.
        if i == len(environments) || get(is_empty_env, environments[i], true)
          continue
        endif
      endif

      var env_linked = get(env_linked_classes, environment, [])
      var env_base = get(env_base_classes, environment, [])

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

      if theme.options.vimlcompatibility > 0
        output += this.GenerateCodeForBugBg234(db, environments, environment)
      endif

      # Generate discriminator-specific overrides
      output += this.EmitDiscriminatorBasedDefinitions(
        db,
        environment,
        discriminators,
        env_linked_discr,
        env_base_discr,
        theme.options.vimlcompatibility
      )

      # Closing statements
      if environment == 'gui'
        if has_non_empty_terminal_env
          output += this.CheckForEmptyTCo()
        endif
      else
        for discriminator in discriminators
          output->add($'{this.space}unlet s:{discriminator}')
        endfor

        output->add(this.space .. 'finish')
      endif

      this.Deindent()

      output->add(this.space .. 'endif')
    endwhile

    if theme.IsLightAndDark()
      output->add(this.space .. 'finish')
      this.Deindent()
      output->add('endif')
    endif

    return output
  enddef

  def EmitDiscriminators(db: Database, space: string): list<string>
    return db.Discriminator->Filter((t) => !empty(t.DiscrName))->SortBy('DiscrNum')->Transform(
      (t) => $'{space}let s:{t.DiscrName} = {t.Definition}'
    )
  enddef

  def EmitDiscriminatorBasedDefinitions(
      db:             Database,
      environment:    string,
      discriminators: list<string>,
      linked_groups:  Relation,
      base_groups:    Relation,
      compatibility:  number
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
        var discrValue   = condition.DiscrValue
        var discr_linked = Query(linked_groups->Select((u) => u.Condition == condition.Condition))
        var discr_base   = Query(base_groups->Select((u) => u.Condition == condition.Condition))

        if first
          output->add($"{this.space}if s:{discrName} == {discrValue}")
        else
          this.Deindent()
          output->add($"{this.space}elseif s:{discrName} == {discrValue}")
        endif

        this.Indent()

        output += discr_linked
          ->Sort(CompareByHiGroupName)
          ->Transform((t) => LinkedGroupToString(t, this.space))

        output += InstantiateBaseGroups(db, discr_base, environment)
          ->Sort(CompareByHiGroupName)
          ->Transform((t) => BaseGroupToString(t, this.space))

        if compatibility > 0
          output += this.GenerateCodeForBugBg234(db, [], environment, discrName, discrValue)
        endif

        first = false
      endfor

      this.Deindent()
      output->add(this.space .. 'endif')
    endfor

    return output
  enddef

  def GenerateCodeForBugBg234(
      db:           Database,
      environments: list<string>,
      environment:  string,
      discrName:    string = '',
      discrValue:   string = ''
      ): list<string>
    # Code needs to be generated only for cterm environments
    var numColors: number

    if environment == 'default'
      numColors = str2nr(BestCtermEnvironment(environments))
    else
      numColors = str2nr(environment)
    endif

    if numColors == 0
      return []
    endif

    var output: list<string> = []

    if CheckBugBg234(db, environment, numColors, discrName, discrValue)
      output->add('')

      if environment == 'default'
        output->add($"{this.space}if !has('patch-8.0.0616') && !has('gui_running') \" Fix for Vim bug")
      else
        output->add($"{this.space}if !has('patch-8.0.0616') \" Fix for Vim bug")
      endif

      this.Indent()
      output->add($'{this.space}set background={db.background}')
      this.Deindent()
      output->add($"{this.space}endif")
    endif

    return output
  enddef
endclass
