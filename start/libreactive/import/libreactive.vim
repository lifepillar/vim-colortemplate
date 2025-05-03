vim9script

export var version = '0.0.1-beta'

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
interface IEffect
endinterface

interface IProperty
  var effects: list<IEffect>
  def Get(): any
  def Set(value: any, args: dict<any>)
  def ClearEffects()
endinterface

class Effect implements IEffect
  var Fn: func()
  public var weight: number
  public var dependentProperties: list<IProperty> = []

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
      this->RemoveFrom(property.effects)
    endfor

    this.dependentProperties = []
  enddef

  def string(): string
    return substitute(string(this.Fn), 'function(''\(.\+\)'')', '\1', '')
  enddef

  def Observe(property: IProperty)
    property.effects->add(this)
    this.dependentProperties->add(property)
  enddef
endclass

class EffectsQueue
  var _queue: list<Effect> = []
  var _start: number       = 0

  static var max_size = queue_size

  def empty(): bool
    return this._start == len(this._queue)
  enddef

  def Items(): list<Effect>
    return this._queue[this._start : ]
  enddef

  def Push(effect: Effect)
    var k = len(this._queue) - 1

    while k >= this._start && effect.weight < this._queue[k].weight
      --k
    endwhile

    this._queue->insert(effect, k + 1)

    if len(this._queue) > EffectsQueue.max_size
      throw $'[Reactive] Potentially recursive effects detected (effects max size = {EffectsQueue.max_size}).'
    endif
  enddef

  def Pop(): Effect
    ++this._start
    return this._queue[this._start - 1]
  enddef

  def Reset()
    this._queue = []
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
def Bind(property: IProperty)
  if sActiveEffect != null && sActiveEffect->NotIn(property.effects)
    sActiveEffect.Observe(property)
  endif
enddef

def PushEffects(effects: list<Effect>)
  Begin()

  for effect in effects
    if effect->NotIn(sQueue.Items())
      sQueue.Push(effect)
    endif
  endfor

  Commit()
enddef

export class Property implements IProperty
  public var value: any = null
  var effects: list<Effect> = []

  def new(this.value = v:none, args: dict<any> = {})
    this.Init(args)
  enddef

  def Init(args: dict<any>)
    var pool = get(args, 'pool', null_list)

    if pool != null
      pool->add(this)
    endif
  enddef

  def Get(): any
    Bind(this)
    return this.value
  enddef

  def Set(value: any, args: dict<any> = {})
    if !args->get('force', false) && (value == this.value)
      return
    endif

    this.value = value

    PushEffects(this.effects)
  enddef

  def Register(effect: Effect)
    effect.Observe(this)
  enddef

  def ClearEffects()
    this.effects = []
  enddef

  def string(): string
    return type(this.value) == v:t_string ? this.value : string(this.value)
  enddef
endclass

export class ComputedProperty extends Property
  def new(Fn: func(): any, args: dict<any> = {})
    super.Init(args)
    CreateEffect(() => this.Set_(Fn(), args), args)
  enddef

  def Set(value: any, args: dict<any> = {})
    throw 'The value of a computed property cannot be set.'
  enddef

  def Set_(value: any, args: dict<any>)
    super.Set(value, args)
  enddef
endclass
# }}}

# CreateEffect {{{
export def CreateEffect(Fn: func(), args = {}): Effect
  var runningEffect = Effect.new(Fn, args->get('weight', 0))

  if sActiveEffect != null && debug_level > 0
    echomsg '[libreactive] Nested effects detected. '
      .. $'Active effect: {sActiveEffect.string()}. Inner effect: {runningEffect.string()}'
  endif

  if args->get('execute', true)
    runningEffect.Execute() # Necessary to bind to dependent signals
  endif

  return runningEffect
enddef
# }}}
