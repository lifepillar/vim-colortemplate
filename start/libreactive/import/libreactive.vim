vim9script

# Settings {{{
export var debug_level = get(g:, 'libreactive_debug_level',     0)
export var queue_size  = get(g:, 'libreactive_queue_size',  10000)
# }}}

# Helper functions {{{
def NotIn(v: any, items: list<any>): bool
  return indexof(items, (_, u) => u is v) == -1
enddef

def RemoveFrom(v: any, items: list<any>)
  var i = indexof(items, (_, e) => e is v)

  if i > -1
    items->remove(i)
  endif
enddef
# }}}

# Effects {{{
interface IProperty
  def Get(): any
  def Set(value: any, force: bool)
  def Clear()
  def RemoveEffect(effect: any)
endinterface

class Effect
  var Fn: func()
  public var dependentProperties: list<IProperty> = []

  var _n = 0
  static var _count = 0

  def new(this.Fn)
    this._n = _count
    _count += 1
  enddef

  def Execute()
    var prevActive = sActiveEffect

    sActiveEffect = this
    this.ClearDependencies()

    Begin()

    try
      this.Fn()
    finally
      Commit()
      sActiveEffect = prevActive
    endtry
  enddef

  def ClearDependencies()
    for property in this.dependentProperties
      property.RemoveEffect(this)
    endfor

    this.dependentProperties = []
  enddef

  def string(): string
    return $'E{this._n}:' .. substitute(string(this.Fn), 'function(''\(.\+\)'')', '\1', '')
  enddef
endclass

class EffectsQueue
  var _q: list<Effect> = []
  var _start: number = 0

  static var max_size = queue_size

  def empty(): bool
    return this._start == len(this._q)
  enddef

  def Items(): list<Effect>
    return this._q[this._start : ]
  enddef

  def Push(effect: Effect)
    this._q->add(effect)

    if len(this._q) > EffectsQueue.max_size
      throw $'[Reactive] Potentially recursive effects detected (effects max size = {EffectsQueue.max_size}).'
    endif
  enddef

  def Pop(): Effect
    ++this._start
    return this._q[this._start - 1]
  enddef

  def Reset()
    this._q = []
    this._start = 0
  enddef
endclass
# }}}

# Global state {{{
var sActiveEffect: Effect = null_object
var sTransaction = 0 # 0 = not in a transaction, >=1 = inside transaction, >1 = in nested transaction
var sQueue = EffectsQueue.new()
# }}}

# Transactions {{{
export def Begin()
  sTransaction += 1
enddef

export def Commit()
  if sTransaction > 1
    --sTransaction
    return
  endif

  try
    while !sQueue.empty()
      sQueue.Pop().Execute()
    endwhile
  finally
    sTransaction = 0
    sQueue.Reset()
  endtry
enddef

export def Transaction(Body: func())
  Begin()
  Body()
  Commit()
enddef

export def Reset()
  sQueue.Reset()
enddef
# }}}

# Properties {{{
export class Property implements IProperty
  var value: any = null
  var _effects: list<Effect> = []

  var _n = 0
  static var count = 0

  def new(this.value = v:none, pool: list<IProperty> = null_list)
    this.Init(pool)
  enddef

  def Init(pool: list<IProperty>)
    if pool != null
      pool->add(this)
    endif

    this._n = count
    count += 1
  enddef

  def Get(): any
    if sActiveEffect != null && sActiveEffect->NotIn(this._effects)
      this._effects->add(sActiveEffect)
      sActiveEffect.dependentProperties->add(this)
    endif

    return this.value
  enddef

  def Set(value: any, force = false)
    if !force && (value == this.value)
      return
    endif

    this.value = value

    Begin()

    for effect in this._effects
      if effect->NotIn(sQueue.Items())
        sQueue.Push(effect)
      endif
    endfor

    Commit()
  enddef

  def RemoveEffect(effect: Effect)
    effect->RemoveFrom(this._effects)
  enddef

  def Clear()
    this._effects = []
  enddef

  def Effects(): list<string>
    return mapnew(this._effects, (_, eff: Effect): string => eff.string())
  enddef

  def string(): string
    return printf('P%d = %s', this._n, this.value) .. ' {' .. printf('%s', join(this.Effects(), ', ')) .. '}'
  enddef
endclass
# }}}

# Functions {{{
export def CreateEffect(Fn: func())
  var runningEffect = Effect.new(Fn)

  if sActiveEffect != null && debug_level > 0
    echomsg '[libreactive] Nested effects detected. '
      .. $'Active effect: {sActiveEffect.string()}. Inner effect: {runningEffect.string()}'
  endif

  runningEffect.Execute() # Necessary to bind to dependent signals
enddef

export def CreateMemo(Fn: func(): any, pool: list<IProperty> = null_list): func(): any
  var memo = Property.new(v:none, pool)
  CreateEffect(() => memo.Set(Fn()))
  return memo.Get
enddef
# }}}
