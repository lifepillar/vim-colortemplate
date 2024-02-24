vim9script

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
    this._n = Effect._count
    Effect._count += 1
  enddef

  def Execute()
    var prevActive = gActiveEffect
    gActiveEffect = this
    this.ClearDependencies()
    Begin()
    try
      this.Fn()
    finally
      Commit()
      gActiveEffect = prevActive
    endtry
  enddef

  def ClearDependencies()
    for property in this.dependentProperties
      property.RemoveEffect(this)
    endfor
    this.dependentProperties = []
  enddef

  def String(): string
    return $'E{this._n}:' .. substitute(string(this.Fn), 'function(''\(.\+\)'')', '\1', '')
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
export const DEFAULT_POOL = '__DEFAULT__'

var gActiveEffect: Effect = null_object
var gTransaction = 0 # 0 = not in a transaction, >=1 = inside transaction, >1 = in nested transaction
var gCreatingEffect = false
var gQueue = EffectsQueue.new()
var gPropertyRegistry: dict<list<IProperty>> = {}

export def Clear(poolName: string, hard = false)
  const pools = empty(poolName) ? keys(gPropertyRegistry) : [poolName]

  for pool in pools
    if gPropertyRegistry->has_key(pool)
      for property in gPropertyRegistry[pool]
        property.Clear()
      endfor

      if hard
        gPropertyRegistry[pool] = []
      endif
    endif
  endfor
enddef
# }}}

# Transactions {{{
export def Begin()
  gTransaction += 1
enddef

export def Commit()
  if gTransaction > 1
    --gTransaction
    return
  endif

  try
    while !gQueue.Empty()
      gQueue.Pop().Execute()
    endwhile
  finally
    gTransaction = 0
    gQueue.Reset()
  endtry
enddef

export def Transaction(Body: func())
  Begin()
  Body()
  Commit()
enddef
# }}}

# Properties {{{
export class Property implements IProperty
  var _value: any = null
  var _effects: list<Effect> = []

  def new(this._value = v:none, pool = DEFAULT_POOL)
    this.Register(pool)
  enddef

  def Register(pool: string)
    if !gPropertyRegistry->has_key(pool)
      gPropertyRegistry[pool] = []
    endif
    gPropertyRegistry[pool]->add(this)
  enddef

  def Get(): any
    if gActiveEffect != null && gActiveEffect->NotIn(this._effects)
      this._effects->add(gActiveEffect)
      gActiveEffect.dependentProperties->add(this)
    endif

    return this._value
  enddef

  def Set(value: any, force = false)
    if !force && (value == this._value)
      return
    endif

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
    gCreatingEffect = false
    throw 'Nested CreateEffect() calls detected'
  endif

  var runningEffect = Effect.new(Fn)

  gCreatingEffect = true
  try
    runningEffect.Execute() # Necessary to bind to dependent signals
  finally
    gCreatingEffect = false
  endtry
enddef

export def CreateMemo(p: Property, Fn: func(): any)
  CreateEffect(() => p.Set(Fn()))
enddef
# }}}
