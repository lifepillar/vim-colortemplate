vim9script

# A minimal reactive library. Loosely inspired by this tutorial:
# https://dev.to/ryansolid/building-a-reactive-library-from-scratch-1i0p

# Helper functions {{{
def NotIn(v: any, items: list<any>): bool
  return indexof(items, (_, u) => u is v) == -1
enddef

def RemoveFrom(v: any, items: list<any>)
  const i = indexof(items, (_, e) => e is v)
  if i == -1
    return
  endif
  items->remove(i)
enddef
# }}}

# Effects {{{
interface IProperty
  def Get(): any
  def Set(value: any)
  def Clear()
  def RemoveEffect(effect: any)
endinterface

class Effect
  var Fn: func()
  public var dependentProperties: list<IProperty> = []

  def Execute()
    var prevActive = gActiveEffect
    gActiveEffect = this
    this.ClearDependencies()
    Begin()
    this.Fn()
    Commit()
    gActiveEffect = prevActive
  enddef

  def ClearDependencies()
    for property in this.dependentProperties
      property.RemoveEffect(this)
    endfor
    this.dependentProperties = []
  enddef

  def String(): string
    return substitute(printf('%s', this.Fn), 'function(''\(.\+\)'')', '\1', '')
  enddef
endclass

class EffectsQueue
  var _q: list<Effect> = []
  var _start: number = 0

  static var max_size = get(g:, 'libreactive_queue_size', 10000)

  def Items(): list<Effect>
    return this._q[this._start : ]
  enddef

  def Empty(): bool
    return this._start == len(this._q)
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
const DEFAULT_POOL = '__DEFAULT__'
var gActiveEffect: Effect = null_object
var gTransaction = 0 # 0 = not in a transaction, >=1 = inside transaction, >1 = in nested transaction
var gCreatingEffect = false
var gQueue = EffectsQueue.new()
var gPropertyRegistry: dict<list<IProperty>> = {DEFAULT_POOL: []}

export def Reinit()
  gActiveEffect   = null_object
  gTransaction    = 0
  gCreatingEffect = false
  gQueue.Reset()
enddef

export def Clear(poolName = DEFAULT_POOL, hard = false)
  const pools = empty(poolName) ? keys(gPropertyRegistry) : [poolName]

  for pool in pools
    for property in gPropertyRegistry[pool]
      property.Clear()
    endfor

    if hard
      gPropertyRegistry[pool] = []
    endif
  endfor
enddef
# }}}

# Transactions {{{
# By default, when a signal is updated, its effects are triggered
# synchronously. It is possible, however, to perform several changes to one or
# more signals within a transaction, in which case notifications are sent only
# when the transaction commits. The gTransaction counter signals whether
# a (nested) transaction is running. The queue is where the effects to be
# executed are pushed. The queue is emptied when the transaction commits (see
# Commit()).

def Begin()
  gTransaction += 1
enddef

def Commit()
  if gTransaction == 1
    while !gQueue.Empty()
      gQueue.Pop().Execute()
    endwhile
    gQueue.Reset()
  endif
  gTransaction -= 1
enddef

# Clients use this function to perform changes to signals in an atomic way.
# Notifications are postponed until commit time. Also, each effect is notified
# exactly once, even if several changes to the signal (or signals) it observes
# have happened inside the transaction.
export def Transaction(Body: func())
  Begin()
  Body()
  Commit()
enddef
# }}}

# Properties {{{
export class Property implements IProperty
  var _value: any = null
  var _pool = DEFAULT_POOL
  var _effects: list<Effect> = []

  def new(this._value = v:none, this._pool = v:none)
    if !gPropertyRegistry->has_key(this._pool)
      gPropertyRegistry[this._pool] = []
    endif
    gPropertyRegistry[this._pool]->add(this)
  enddef

  def Get(): any
    if gActiveEffect != null && gActiveEffect->NotIn(this._effects)
      this._effects->add(gActiveEffect)
      gActiveEffect.dependentProperties->add(this)
    endif

    return this._value
  enddef

  def Set(value: any)
    this._value = value

    Begin()
    for effect in this._effects
      if effect->NotIn(gQueue.Items())
        gQueue.Push(effect)
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
    return mapnew(this._effects, (_, eff: Effect): string => eff.String())
  enddef
endclass
# }}}

# Functions {{{
export def CreateEffect(Fn: func())
  if gCreatingEffect
    throw 'Nested CreateEffect() calls detected'
  endif
  var runningEffect = Effect.new(Fn)
  gCreatingEffect = true
  runningEffect.Execute() # Necessary to bind to dependent signals
  gCreatingEffect = false
enddef

export def CreateMemo(Fn: func(): any): func(): any
  var signal = Property.new()
  CreateEffect(() => signal.Set(Fn()))
  return signal.Get
enddef
# }}}
