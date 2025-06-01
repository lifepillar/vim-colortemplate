vim9script

import 'librelalg.vim'      as ra
import './base.vim'         as base
import '../colorscheme.vim' as colorscheme

const EquiJoin = ra.EquiJoin
const Query    = ra.Query
const Select   = ra.Select

type  Database = colorscheme.Database

const dark_regex  = '\m^\%(7\*\=\|9\*\=\|\d\d\|Brown\|DarkYellow\|\%(Light\|Dark\)\=\%(Gr[ae]y\)\|\%[Light]\%(Blue\|Green\|Cyan\|Red\|Magenta\|Yellow\)\|White\)$'
const light_regex = '\m^\%(\%(0\|1\|2\|3\|4\|5\|6\|8\)\*\=\|Black\|Dark\%(Blue\|Green\|Cyan\|Red\|Magenta\)\)$'

# In Vim < 8.1.0616, `hi Normal ctermbg=...` may change the value of
# 'background'. This function checks the conditions under which that may
# happen. The function's name is a reference to the original issue report,
# which had an example using color 234.
#
# See https://github.com/lifepillar/vim-colortemplate/issues/13.
export def CheckBugBg234(
    db:          Database,
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

export def NotIn(v: any, items: list<any>): bool
  return index(items, v) == -1
enddef

export class Generator extends base.Generator
  var backward_compatible: bool

  def new(this.theme)
    super.Init('viml')
    this.backward_compatible = this.theme.options.vimlcompatibility > 0
  enddef

  def HookEndOfEnvironment(db: Database, environment: string): list<string>
    var output: list<string> = []

    if this.backward_compatible
      output += this.EmitCheckBugBg234(db, environment)
    endif

    if environment->NotIn(['default', 'gui'])
      output += mapnew(
        this.discriminatorNames,
        (_, name) => $'{this.space}unlet s:{name}'
      )
    endif

    return output
  enddef

  def HookEndOfDiscriminatorBlock(
      db: Database,
      environment: string,
      discrName: string,
      discrValue: string
      ): list<string>
    if this.backward_compatible
      return this.EmitCheckBugBg234(db, environment, discrName, discrValue)
    endif

    return []
  enddef

  def EmitCheckBugBg234(
      db:          Database,
      environment: string,
      discrName:   string = '',
      discrValue:  string = ''
      ): list<string>
    # Code needs to be generated only for cterm environments
    var numColors: number

    if environment == 'default'
      numColors = str2nr(this.best_cterm)
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
        this.Add(output, $"if !has('patch-8.0.0616') && !has('gui_running') \" Fix for Vim bug")
      else
        this.Add(output, $"if !has('patch-8.0.0616') \" Fix for Vim bug")
      endif

      this.Indent()
      this.Add(output, $'set background={db.background}')
      this.Deindent()
      this.Add(output, $'endif')
    endif

    return output
  enddef
endclass
