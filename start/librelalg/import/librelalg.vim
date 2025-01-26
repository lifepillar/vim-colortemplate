vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

# Types {{{
export type Attr            = string
export type Domain          = number # v:t_number, v:t_string, etc.
export type Schema          = dict<Domain> # Map from Attr to Domain
export type AttrSet         = list<Attr> # When the order does not matter
export type AttrList        = list<Attr> # When the order matters
export type Tuple           = dict<any>
export type Relation        = list<Tuple>

export type Constraint      = func(Tuple): bool
export type Consumer        = func(Tuple): void
export type Continuation    = func(Consumer): void
export type UnaryPredicate  = func(Tuple): bool
export type BinaryPredicate = func(Tuple, Tuple): bool
# }}}

# Helper Functions {{{
# string() turns 'A' into a string of length 3, with quotes. Use this if you don't want that.
def String(value: any): string
  return type(value) == v:t_string ? value : string(value)
enddef

def ListStr(items: list<any>): string
  const stringified = mapnew(items, (_, v) => String(v))
  return '[' .. join(stringified, ', ') .. ']'
enddef

def TupleStr(t: Tuple, attrs: AttrList = keys(t)): string
  const stringified = mapnew(attrs, (_, a) => $'{a}: {string(t[a])}')
  return '{' .. join(stringified, ', ') .. '}'
enddef

def SchemaStr(schema: Schema): string
  const stringified = mapnew(schema, (attr, dom) => $'{attr}: {DomainName(dom)}')
  return '{' .. join(values(stringified), ', ') .. '}'
enddef

def All(items: list<any>, P: func(any): bool): bool
  return reduce(items, (res, item) => res && P(item), true)
enddef

def Any(items: list<any>, P: func(any): bool): bool
  return reduce(items, (res, item) => res || P(item), false)
enddef

def IsFunc(X: any): bool
  return type(X) == v:t_func
enddef

def Listify(item: any): list<Attr> # item: Attr | AttrList
  return type(item) == v:t_list ? item : [item]
enddef

def ListifyKeys(keys: any): list<AttrList> # keys: Attr | AttrList | list<Attr | AttrList>
  if type(keys) == v:t_string
    return [[keys]]  # One single-attribute key
  endif

  if empty(keys)
    return []
  endif

  if All(keys, (k) => type(k) == v:t_string)
    return [keys]  # One composite key
  endif

  return mapnew(keys, (_, v) => Listify(v))  # Many keys
enddef

# v1 and v2 must have the same type
def CompareValues(v1: any, v2: any, invert: bool = false): number
  if v1 == v2
    return 0
  endif

  const cmp = (invert ? -1 : 1)

  if type(v1) == v:t_bool # Only true/false (none is not allowed)
    return v1 && !v2 ? cmp : -cmp
  else
    return v1 > v2 ? cmp : -cmp
  endif
enddef

def CompareTuples(t: Tuple, u: Tuple, attrs: AttrSet, invert: list<bool> = []): number
  if empty(invert) # fast path
    for a in attrs
      const cmp = CompareValues(t[a], u[a])

      if cmp == 0
        continue
      endif

      return cmp
    endfor

    return 0
  endif

  const n = len(attrs)
  var   i = 0

  while i < n
    const a   = attrs[i]
    const cmp = CompareValues(t[a], u[a], invert[i])

    if cmp == 0
      i += 1
      continue
    endif

    return cmp
  endwhile

  return 0
enddef

def ProjectTuple(t: Tuple, attrs: AttrSet): Tuple
  var u: Tuple = {}

  for a in attrs
    u[a] = t[a]
  endfor

  return u
enddef

def Values(t: Tuple, attrs: AttrSet): list<any>
  var values = []

  for a in attrs
    values->add(t[a])
  endfor

  return values
enddef

if has("patch-9.1.0547")
  def NumArgs(Fn: func): number
    return get(Fn, "arity").required
  enddef
else
  def NumArgs(Fn: func): number
    return len(split(matchstr(typename(Fn), '([^)]\+)'), ','))
  enddef
endif

# Implement currying with a twist: if the last argument is a function,
# put it at the beginning. This trick allows the following syntaxes to be
# equivalent:
#
#     CurriedFunc(F, 'arg1', 'arg2')
# and
#     CurriedFunc('arg1', 'arg2', F)
#
# besides, of course, allowing partial application.
def Curry(Fn: func, ...values: list<any>): func
  # const n = get(Fn, "arity").required
  const n = NumArgs(Fn)

  return (...args: list<any>) => {
    const totalArgs = values + args

    if len(totalArgs) < n
        return call(Curry, [Fn] + totalArgs)
    else
      if type(totalArgs[-1]) == v:t_func
        return call(Fn, totalArgs[-1 : ] + totalArgs[ : -2])
      else
        return call(Fn, totalArgs)
      endif
    endif
  }
enddef
# }}}

# Data definition and manipulation {{{
# Domains {{{
export const Int     = v:t_number
export const Str     = v:t_string
export const Bool    = v:t_bool
export const Float   = v:t_float
export const Func    = v:t_func
export const List    = v:t_list
export const Obj     = v:t_object

const DomainStr = {
  [Int]:         'integer',
  [Str]:         'string',
  [Float]:       'float',
  [Bool]:        'boolean',
  [Func]:        'funcref',
  [List]:        'list',
  [Obj]:         'object',
  [v:t_dict]:    'dictionary',
  [v:t_none]:    'none',
  [v:t_job]:     'job',
  [v:t_channel]: 'channel',
  [v:t_blob]:    'blob'
}

def DomainName(domain: Domain): string
  return get(DomainStr, domain, 'unknown')
enddef
# }}}

# Error Messages {{{
var E000 = 'At least one key must be specified for relation %s.'
var E001 = 'Expected a tuple on schema %s: got %s instead.'
var E002 = 'Key %s already defined in relation %s.'
var E003 = '%s is not an attribute of relation %s.'
var E004 = 'Duplicate key: %s already exists in relation %s.'
var E100 = 'Update failed: no tuple with key %s exists in relation %s.'
var E101 = 'Cannot replace %s with %s: updating key attributes is not allowed.'
# }}}

# Indexes {{{
export const KEY_NOT_FOUND: Tuple = {}

class Index
  var key:    AttrList          = []
  var _index: dict<list<Tuple>> = {} # Map from key to tuples

  def IsEmpty(): bool
    return empty(this._index)
  enddef

  def Add(t: Tuple)
    var keyValues = string(Values(t, this.key))

    if !this._index->has_key(keyValues)
      this._index[keyValues] = []
    endif

    this._index[keyValues]->add(t)
  enddef

  def Remove(t: Tuple)
    var keyValues = string(Values(t, this.key))

    if this._index->has_key(keyValues)
      var tuples = this._index[keyValues]

      filter(tuples, (_, u) => t isnot u)

      if empty(tuples)
        remove(this._index, keyValues)
      endif
    endif
  enddef

  def Search(keyValue: list<any>): list<Tuple>
    return get(this._index, string(keyValue), [])
  enddef
endclass
# }}}

# Transactions {{{
interface IBaseRel
  var name: string
  var insert_constraints: list<Constraint>
  var delete_constraints: list<Constraint>

  def Instance(): Relation
  def Add(t: Tuple)
  def Remove(t: Tuple)
  def Insert(t: Tuple)
  def Upsert(t: Tuple, insert: bool)
  def Delete(P: UnaryPredicate)
  def Update(P: UnaryPredicate, Set: func(Tuple))
endinterface

class LogEntry
  var rel:   IBaseRel
  var tuple: Tuple

  def string(): string
    return $'LOG({this.rel.name},{TupleStr(this.tuple)})'
  enddef
endclass

var sFailureMessages: list<string>   = [] # Stores error messages when constraints fail
var sTransaction:     number         = 0  # 0 = not in a transaction, 1 = inside transaction
var sNewLog:          list<LogEntry> = [] # Log new tuples to be committed
var sOldLog:          list<LogEntry> = [] # Log deleted tuples to be committed

export def Messages(): list<string>
  return sFailureMessages
enddef

 def Begin()
  if sTransaction != 0
    throw 'Transactions cannot be nested'
  endif

  sFailureMessages = []
  sTransaction     = 1
enddef

def Rollback(throw = true)
  for entry in sNewLog
    entry.rel.Remove(entry.tuple)
  endfor

  for entry in sOldLog
    entry.rel.Add(entry.tuple)
  endfor

  sNewLog      = []
  sOldLog      = []
  sTransaction = 0

  if throw
    throw sFailureMessages[0]
  endif
enddef

 def Commit(throw = true): bool
  if sTransaction != 1
    throw 'Commit() without Begin()'
  endif

  for entry in sNewLog
    for C in entry.rel.insert_constraints
      if !C(entry.tuple)
        Rollback(throw)
        return false
      endif
    endfor
  endfor

  for entry in sOldLog
    for C in entry.rel.delete_constraints
      if !C(entry.tuple)
        Rollback(throw)
        return false
      endif
    endfor
  endfor

  sNewLog      = []
  sOldLog      = []
  sTransaction = 0

  return true
enddef

export def Transaction(Body: func(), throw: bool = true): bool
  Begin()
  Body()
  return Commit(throw)
enddef

def ImplicitTransaction(Body: func())
  var implicit_transaction = (sTransaction == 0)

  if implicit_transaction
    Begin()
  endif

  Body()

  if implicit_transaction
    Commit()
  endif
enddef
# }}}

# Relations {{{
export class Rel implements IBaseRel
  var name:               string
  var schema:             Schema
  var keys:               list<AttrList>
  var attributes:         AttrList
  var key_attributes:     AttrList
  var descriptors:        AttrList
  var instance:           Relation         = []
  var insert_constraints: list<Constraint> = []
  var delete_constraints: list<Constraint> = []
  var update_constraints: list<Constraint> = []

  public var type_check: bool = true

  var _key_indexes: dict<Index> = {}

  def new(this.name, this.schema, relKeys: any, this.type_check = v:none)
    if empty(relKeys)
      throw printf(E000, this.name)
    endif

    var keys_: list<AttrList> = ListifyKeys(relKeys)

    this.attributes     = keys(this.schema)->sort()
    this.key_attributes = flattennew(keys_)->sort()->uniq()
    this.descriptors    = filter(copy(this.attributes), (_, v) => index(this.key_attributes, v) == -1)

    for key in keys_
      this.AddKeyConstraint_(key)
    endfor
  enddef

  def string(): string
    return $'{this.name}={this.Instance()}'
  enddef

  def Instance(): Relation
    return this.instance
  enddef

  def IsEmpty(): bool
    return empty(this.instance)
  enddef

  def Index(key: any): Index
    return this._key_indexes[string(Listify(key))]
  enddef

  def Add(t: Tuple)
    this.TypeCheck_(t)
    this.instance->add(t)

    for idx in values(this._key_indexes)
      idx.Add(t)
    endfor
  enddef

  def Remove(t: Tuple)
    var i = indexof(this.instance, (_, u) => u is t)

    remove(this.instance, i)

    for idx in values(this._key_indexes)
      idx.Remove(t)
    endfor
  enddef

  def Insert(t: Tuple)
    ImplicitTransaction(() => {
      this.Add(t)

      # Check if t was previously deleted during the current transaction
      var k = indexof(sOldLog, (_, entry: LogEntry) => entry.tuple == t)

      if k == -1
        sNewLog->add(LogEntry.new(this, t))
      else # This insertion undoes the deletion
        remove(sOldLog, k)
      endif
    })
  enddef

  def Delete(P: UnaryPredicate = (t) => true)
    ImplicitTransaction(() => {
      for t in this.instance
        if P(t)
          # Check if t was previously inserted during the current transaction
          var k = indexof(sNewLog, (_, entry: LogEntry) => entry.tuple == t)

          if k == -1
            sOldLog->add(LogEntry.new(this, t))
          else # This deletion undoes the insertion
            remove(sNewLog, k)
          endif

          for idx in values(this._key_indexes)
            idx.Remove(t)
          endfor
        endif
      endfor

      filter(this.instance, (_, t) => !P(t))
    })
  enddef

  def InsertMany(tuples: list<Tuple>)
    ImplicitTransaction(() => {
      for t in tuples
        this.Add(t)
        sNewLog->add(LogEntry.new(this, t))
      endfor
    })
  enddef

  def Update(P: UnaryPredicate, Set: func(Tuple))
    ImplicitTransaction(() => {
      for t in this.instance
        var u: Tuple

        if P(t)
          u = deepcopy(t)

          sOldLog->add(LogEntry.new(this, u))
          Set(t)
          sNewLog->add(LogEntry.new(this, t))

          for attr in this.key_attributes
            if t[attr] != u[attr] # FIXME: use `is`? What if a key is an object?
              sFailureMessages->add(printf(E101, TupleStr(u), TupleStr(t)))
              Rollback(true)
            endif
          endfor
        endif
      endfor
    })
  enddef

  def Lookup(key: AttrSet, value: list<any>): Tuple
    if index(this.keys, key) == -1
      throw $'{key} is not a key of {this.name}'
    endif

    var idx = this._key_indexes[String(key)]
    var result = idx.Search(value)

    return empty(result) ? KEY_NOT_FOUND : result[0]
  enddef

  def Upsert(t: Tuple, insert: bool = true)
    var u = this.Lookup(this.keys[0], Values(t, this.keys[0]))

    if u is KEY_NOT_FOUND
      if insert
        this.Insert(t)
        return
      endif

      throw printf(E100, TupleStr(t, this.keys[0]), this.name)
    endif

    for attr in this.key_attributes
      if t[attr] != u[attr] # FIXME: use `is`? What if a key is an object?
        throw printf(E101, TupleStr(u), TupleStr(t))
      endif
    endfor

    ImplicitTransaction(() => {
      sOldLog->add(LogEntry.new(this, deepcopy(u)))

      for attr in this.descriptors
        u[attr] = t[attr]
      endfor

      sNewLog->add(LogEntry.new(this, u))
    })
  enddef

  def AddKeyConstraint_(key: AttrList)
    if index(this.keys, key) != -1
      throw printf(E002, ListStr(key), this.name)
    endif

    for attr in key
      if index(this.attributes, attr) == -1
        throw printf(E003, attr, this.name)
      endif
    endfor

    this.keys->add(key)
    this.CreateUniquenessConstraint_(key)
  enddef

  def CreateUniquenessConstraint_(key: AttrList)
    var keyIndex = Index.new(key)

    var IsUnique: UnaryPredicate = (t) => {
      if len(keyIndex.Search(Values(t, key))) <= 1
        return true
      endif

      return FailedCheck(printf(E004, TupleStr(t, key), this.name))
    }

    this._key_indexes[string(key)] = keyIndex
    Check('Key uniqueness', IsUnique)->OnInsert(this)
  enddef

  def TypeCheck_(t: Tuple)
    if this.type_check
      if sort(keys(t)) != this.attributes
        FailedCheck(printf(E001, SchemaStr(this.schema), TupleStr(t)))
        Rollback()
      endif

      for [attr, domain] in items(this.schema)
        var v = t[attr]

        if type(v) != domain
          FailedCheck(printf(E001, SchemaStr(this.schema), TupleStr(t)))
          Rollback()
        endif
      endfor
    endif
  enddef
endclass
# }}}

# Integrity constraints {{{
export def FailedCheck(message: string): bool
  sFailureMessages->add(message)

  return false
enddef

export def Check(description: string, P: UnaryPredicate): Constraint
  return (t): bool => {
    if P(t)
      return true
    endif

    return FailedCheck($'{description} failed for tuple {TupleStr(t)}.')
  }
enddef

export def OnInsert(C: Constraint, R: Rel): Constraint
  R.insert_constraints->add(C)
  return C
enddef

export def OnDelete(C: Constraint, R: Rel): Constraint
  R.delete_constraints->add(C)
  return C
enddef

export def ForeignKey(Child: Rel, fkey: any): list<any>
  var fkey_: AttrList = Listify(fkey)

  for attr in fkey_
    if index(Child.attributes, attr) == -1
      throw $'Wrong foreign key: {Child.name}{ListStr(fkey_)}. {attr} is not an attribute of {Child.name}'
    endif
  endfor

  return [Child, fkey_]
enddef

export def References(foreign_key: list<any>, Parent: Rel, key: any = null, verbphrase: string = 'references')
  var Child = (<Rel>foreign_key[0])
  var fkey_: AttrList = foreign_key[1]
  var key_:  AttrList = key == null ? fkey_ : Listify(key)

  if len(fkey_) != len(key_)
    throw $'Foreign key size mismatch: {Child.name}{ListStr(fkey_)} -> {Parent.name}{ListStr(key_)}'
  endif

  if index(Parent.keys, key_) == -1
    throw $'Wrong foreign key: {Child.name}{ListStr(fkey_)} -> {Parent.name}{ListStr(key_)}. {ListStr(key_)} is not a key of {Parent.name}'
  endif

  var fkStr = $'{Child.name} {verbphrase} {Parent.name}'

  var FkConstraint: UnaryPredicate = (t) => {
    if Parent.Lookup(key_, Values(t, fkey_)) isnot KEY_NOT_FOUND
      return true
    endif

    return FailedCheck($'{fkStr}: {TupleStr(t, fkey_)} not found in {Parent.name}{ListStr(key_)}')
  }

  Check('Referential integrity', FkConstraint)->OnInsert(Child)

  var FkPred = EquiJoinPred(fkey_, key_)

  var DelConstraint: UnaryPredicate = (t_p) => {
    if Parent.Lookup(key_, Values(t_p, key_)) isnot KEY_NOT_FOUND
      return true
    endif

    for t_c in Child.instance
      if FkPred(t_c, t_p)
        return FailedCheck($'{fkStr}: cannot delete {TupleStr(t_p)} from {Parent.name} because it is referenced by {TupleStr(t_c)} in {Child.name}')
      endif
    endfor

    return true
  }

  Check('Referential integrity', DelConstraint)->OnDelete(Parent)
enddef
# }}}
# }}}

# Rel related helper functions {{{
def IsRel(R: any): bool
  return type(R) == v:t_object
enddef

def Instance(R: any): Relation
  return type(R) == v:t_object ? (<Rel>R).instance : R
enddef

def IsKeyOf(attrs: AttrList, R: Rel): bool
  return index(R.keys, attrs) != -1
enddef
# }}}

# Relational Algebra {{{
# A push-based query engine. Loosely inspired by
# https://arxiv.org/abs/1610.09166:
#
# Shaikhna, Amir and Dashti Mohammad and Koch, Christoph
# Push vs. Pull-Based Loop Fusion in Query Engines, 2016
#
# and references therein.


# Root operators (accepting a relation as input) {{{
export def From(Arg: any): Continuation
  if IsFunc(Arg)
    return Arg
  endif

  const rel: Relation = Instance(Arg)

  return (Emit: Consumer) => {
    for t in rel
      Emit(t)
    endfor
  }
enddef

export def Scan(Arg: any): Continuation
  return From(Arg)
enddef

export def Foreach(Arg: any): Continuation
  return From(Arg)
enddef
# }}}

# Leaf operators (returning a relation) {{{
def Materialize(Cont: Continuation): Relation
  var rel: Relation = []

  Cont((t) => {
    add(rel, t)
  })

  return rel
enddef

export def Query(Arg: any): Relation
  if IsFunc(Arg)
    return Materialize(Arg)
  else
    return Instance(Arg)
  endif
enddef

export def Build(Arg: any): Relation
  return Query(Arg)
enddef

export def Sort(Arg: any, ComparisonFn: func(Tuple, Tuple): number): Relation
  var rel = Query(Arg)
  return sort(rel, ComparisonFn)
enddef

export def SortBy(Arg: any, attrs: any, opts: list<string> = []): Relation
  const invert: list<bool> = mapnew(opts, (_, v) => v == 'd')
  const attrList: AttrList = Listify(attrs)
  const SortAttrPred = (t: Tuple, u: Tuple): number => CompareTuples(t, u, attrList, invert)

  return Sort(Arg, SortAttrPred)
enddef

export def Union(Arg1: any, Arg2: any): Relation
  if IsFunc(Arg1)
    return Materialize(Arg1)->extend(Query(Arg2))->sort()->uniq()
  else
    return Instance(Arg1)->extendnew(Query(Arg2))->sort()->uniq()
  endif
enddef

export def Filter(Arg: any, Pred: func(Tuple): bool): Relation
  var rel = IsFunc(Arg) ? Materialize(Arg) : copy(Instance(Arg))
  return filter(rel, (_, t) => Pred(t))
enddef

export def SumBy(Arg: any, groupBy: any, attr: Attr, aggrName = 'sum'): Relation
  var   aggr: dict<Tuple> = {}
  const groupBy_: AttrSet = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: Tuple) => {
    var tp = ProjectTuple(t, groupBy_)
    const group = string(values(tp))

    if !aggr->has_key(group)
      aggr[group] = tp->extend({[aggrName]: 0})
    endif

    aggr[group][aggrName] += t[attr]
  })

  return empty(groupBy_) && empty(aggr) ? [{[aggrName]: 0}] : values(aggr)
enddef

export def CountBy(Arg: any, groupBy: any, attr: Attr = null_string, aggrName = 'count'): Relation
  var   aggrCount: dict<Tuple> = {}
  var   aggrDistinct: dict<dict<bool>> = {}
  const groupBy_: AttrSet = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: Tuple) => {
    var tp = ProjectTuple(t, groupBy_)
    const group = string(values(tp))

    if !aggrCount->has_key(group)
      aggrCount[group] = tp->extend({[aggrName]: 0})
      aggrDistinct[group] = {}
    endif

    if attr is null_string
      ++aggrCount[group][aggrName]
    elseif !aggrDistinct[group]->has_key(string(t[attr]))
      aggrDistinct[group][string(t[attr])] = true
      ++aggrCount[group][aggrName]
    endif
  })

  return empty(groupBy_) && empty(aggrCount) ? [{[aggrName]: 0}] : values(aggrCount)
enddef

export def MaxBy(Arg: any, groupBy: any, attr: Attr, aggrName = 'max'): Relation
  var   aggr: dict<Tuple> = {}
  const groupBy_: AttrSet = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: Tuple) => {
    var tp = ProjectTuple(t, groupBy_)
    const group = string(values(tp))

    if !aggr->has_key(group)
      aggr[group] = tp->extend({[aggrName]: t[attr]})
    endif

    if aggr[group][aggrName] < t[attr]
      aggr[group][aggrName] = t[attr]
    endif
  })

  return values(aggr)
enddef

export def MinBy(Arg: any, groupBy: any, attr: Attr, aggrName = 'min'): Relation
  var   aggr: dict<Tuple> = {}
  const groupBy_: AttrSet = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: Tuple) => {
    var tp = ProjectTuple(t, groupBy_)
    const group = string(values(tp))

    if !aggr->has_key(group)
      aggr[group] = tp->extend({[aggrName]: t[attr]})
    endif
    if aggr[group][aggrName] > t[attr]
      aggr[group][aggrName] = t[attr]
    endif
  })

  return values(aggr)
enddef

export def AvgBy(Arg: any, groupBy: any, attr: Attr, aggrName = 'avg'): Relation
  var   aggrAvg: dict<Tuple> = {}
  var   aggrCnt: dict<number> = {}
  const groupBy_: AttrSet = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: Tuple) => {
    var tp = ProjectTuple(t, groupBy_)
    const group = string(values(tp))

    if !aggrAvg->has_key(group)
      aggrAvg[group] = tp->extend({[aggrName]: 0.0})
      aggrCnt[group] = 0
    endif

    aggrAvg[group][aggrName] += t[attr]
    ++aggrCnt[group]
  })

  for group in keys(aggrAvg)
    aggrAvg[group][aggrName] /= aggrCnt[group]
  endfor

  return values(aggrAvg)
enddef
# }}}

# Pipeline operators {{{
export def Rename(Arg: any, old: AttrList, new: AttrList): Continuation
  const Cont = From(Arg)

  return (Emit: Consumer) => {
    def RenameAttr(t: Tuple)
      var i = 0
      var tnew = copy(t)

      while i < len(old)
        tnew[new[i]] = tnew[old[i]]
        tnew->remove(old[i])
        ++i
      endwhile

      Emit(tnew)
    enddef

    Cont(RenameAttr)
  }
enddef

export def Select(Arg: any, Pred: UnaryPredicate): Continuation
  const Cont = From(Arg)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      if Pred(t)
        Emit(t)
      endif
    })
  }
enddef

export def Project(Arg: any, attrs: any): Continuation
  const Cont = From(Arg)
  const attrList = Listify(attrs)

  return (Emit: Consumer) => {
    var seen: dict<bool> = {}

    def Proj(t: Tuple)
      var u = ProjectTuple(t, attrList)
      const v = string(values(u))
      if !seen->has_key(v)
        seen[v] = true
        Emit(u)
      endif
    enddef

    Cont((t) => Proj(t))
  }
enddef

def MakeTupleMerger(prefix: string): func(Tuple, Tuple): Tuple
  return (t: Tuple, u: Tuple): Tuple => {
    var tnew: Tuple = {}

    for attr in keys(t)
      const newAttr = u->has_key(attr) ? prefix .. attr : attr
      tnew[newAttr] = t[attr]
    endfor

    return tnew->extend(u, 'error')
  }
enddef

export def Join(Arg1: any, Arg2: any, Pred: BinaryPredicate, prefix = '_'): Continuation
  const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      for u in rel
        if Pred(t, u)
          Emit(MergeTuples(t, u))
        endif
      endfor
    })
  }
enddef

export def EquiJoinPred(lAttrs: AttrList, rAttrs: AttrList = null_list): BinaryPredicate
  const n = len(lAttrs)
  const rgt = rAttrs == null ? lAttrs : rAttrs

  if n != len(rgt)
    throw $'Join on sets of attributes of different length: {ListStr(lAttrs)} vs {ListStr(rgt)}'
  endif

  return (t: Tuple, u: Tuple): bool => {
    var i = 0

    while i < n
      if t[lAttrs[i]] != u[rgt[i]]
        return false
      endif
      ++i
    endwhile

    return true
  }
enddef

# TODO: build index on the fly
export def EquiJoin(
    Arg1: any, Arg2: any, lAttrs: any, rAttrs: any = lAttrs, prefix = '_'
): Continuation
  const lAttrList = Listify(lAttrs)
  const rAttrList = Listify(rAttrs)

  if IsRel(Arg2) && rAttrList->IsKeyOf(Arg2) # Fast path
    const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
    const Cont = From(Arg1)
    const rel: Rel = Arg2

    return (Emit: Consumer) => {
      Cont((t: Tuple) => {
        const u = rel.Lookup(rAttrList, Values(t, lAttrList))

        if u isnot KEY_NOT_FOUND
          Emit(MergeTuples(t, u))
        endif
      })
    }
  endif

  const Pred = EquiJoinPred(lAttrList, rAttrList)

  return Join(Arg1, Arg2, Pred, prefix)
enddef

def NatJoinPred(t: Tuple, u: Tuple): bool
  for a in keys(t)
    if u->has_key(a)
      if t[a] != u[a]
        return false
      endif
    endif
  endfor

  return true
enddef

export def NatJoin(Arg1: any, Arg2: any): Continuation
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      for u in rel
        if NatJoinPred(t, u)
          Emit(t->extendnew(u))
        endif
      endfor
    })
  }
enddef

export def Product(Arg1: any, Arg2: any, prefix = '_'): Continuation
  const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      for u in rel
        Emit(MergeTuples(t, u))
      endfor
    })
  }
enddef

export def Intersect(Arg1: any, Arg2: any): Continuation
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      for u in rel
        if t == u
          Emit(t)
          break
        endif
      endfor
    })
  }
enddef

export def Minus(Arg1: any, Arg2: any): Continuation
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      for u in rel
        if t == u
          return
        endif
      endfor

      Emit(t)
    })
  }
enddef

export def SemiJoin(Arg1: any, Arg2: any, Pred: BinaryPredicate): Continuation
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      for u in rel
        if Pred(t, u)
          Emit(t)
          return
        endif
      endfor
    })
  }
enddef

export def AntiJoin(Arg1: any, Arg2: any, Pred: BinaryPredicate): Continuation
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      for u in rel
        if Pred(t, u)
          return
        endif
      endfor

      Emit(t)
    })
  }
enddef

export def AntiEquiJoin(Arg1: any, Arg2: any, lAttrs: any, rAttrs: any = lAttrs): Continuation
  const lAttrList = Listify(lAttrs)
  const rAttrList = Listify(rAttrs)
  const Cont = From(Arg1)

  if IsRel(Arg2) && rAttrList->IsKeyOf(Arg2) # Fast path
    const rel: Rel = Arg2

    return (Emit: Consumer) => {
      Cont((t: Tuple) => {
        const u = rel.Lookup(rAttrList, Values(t, lAttrList))

        if u is KEY_NOT_FOUND
          Emit(t)
        endif

        return
      })
    }
  endif

  const Pred = EquiJoinPred(lAttrList, rAttrList)

  return AntiJoin(Arg1, Arg2, Pred)
enddef

# See: C. Date & H. Darwen, Outer Join with No Nulls and Fewer Tears, Ch. 20,
# Relational Database Writings 1989–1991
export def LeftNatJoin(Arg1: any, Arg2: any, Filler: any): Continuation
  const rel    = Query(Arg2)
  const Cont   = From(Arg1)
  const filler = Query(Filler)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      var joined: bool = false

      for u in rel
        if NatJoinPred(t, u)
          Emit(t->extendnew(u))
          joined = true
        endif
      endfor

      if !joined
        for v in filler
          Emit(t->extendnew(v))
        endfor
      endif
    })
  }
enddef

export def LeftEquiJoin(
    Arg1: any, Arg2: any, lAttrs: any, rAttrs: any, Filler: any, prefix = '_',
): Continuation
  const lAttrList = Listify(lAttrs)
  const rAttrList = Listify(rAttrs)
  const Cont        = From(Arg1)
  const filler      = Query(Filler)
  const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)

  if IsRel(Arg2) && rAttrList->IsKeyOf(Arg2) # Fast path
    const rel: Rel = Arg2

    return (Emit: Consumer) => {
      Cont((t: Tuple) => {
        const u = rel.Lookup(rAttrList, Values(t, lAttrList))

        if u isnot KEY_NOT_FOUND
          Emit(MergeTuples(t, u))
        else
          for v in filler
            Emit(MergeTuples(t, v))
          endfor
        endif
      })
    }
  endif

  const rel  = Query(Arg2)
  const Pred = EquiJoinPred(lAttrList, rAttrList)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      var joined: bool = false

      for u in rel
        if Pred(t, u)
          Emit(MergeTuples(t, u))
          joined = true
        endif
      endfor

      if !joined
        for v in filler
          Emit(MergeTuples(t, v))
        endfor
      endif
    })
  }
enddef

export def Extend(Arg: any, Fn: func(Tuple): Tuple): Continuation
  const Cont = From(Arg)

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      Emit(Fn(t)->extend(t, 'error'))
    })
  }
enddef

# Inspired by the framing operator described in
# EF Codd, The Relational Model for Database Management: Version 2, 1990
export def Frame(Arg: any, attrs: any, name: string = 'fid'): Continuation
  var fid = 0  # Frame identifier
  var seen: dict<number> = {}
  const attrList: AttrSet = Listify(attrs)
  const Cont = From(Arg)

  return (Emit: Consumer) => {
    def FrameTuple(t: Tuple)
      const groupby = string(ProjectTuple(t, attrList))

      if !seen->has_key(groupby)
        seen[groupby] = fid
        ++fid
      endif

      Emit(extendnew(t, {[name]: seen[groupby]}, 'error'))
    enddef

    Cont((t) => FrameTuple(t))
  }
enddef

export def GroupBy(
    Arg: any, groupBy: any, AggrFn: func(...list<any>): any, aggrName = 'aggrValue'
): Continuation
  var fid: dict<Relation> = PartitionBy(Arg, groupBy)
  const groupBy_: AttrSet = Listify(groupBy)

  return (Emit: Consumer) => {
    # Apply the aggregate function to each subrelation
    for groupKey in keys(fid)
      const subrel = fid[groupKey]
      var t0: Tuple = {}

      for attr in groupBy_
        t0[attr] = subrel[0][attr]
      endfor

      t0[aggrName] = Scan(subrel)->AggrFn()
      Emit(t0)
    endfor
  }
enddef

# Returns all the tuples which, concatenated with a tuple of s, produce
# a tuple of r. Relational division is a derived operator, defined as follows:
#
#     r ÷ s = r₁ - s₁,
#
# where r₁ = π_K(r) and s₁ = π_K((s × r₁) - r), with K the set of attributes
# appearing in r but not in s.
export def CoddDivide(Arg1: any, Arg2: any, divisorAttrs: AttrSet = []): Continuation
  const r = Query(Arg1)

  if empty(r)
    return From(r)
  endif

  const s = Query(Arg2)

  if empty(s)
    const K = IsRel(Arg2)
      ? filter(keys(r[0]), (i, v) => index((<Rel>Arg2).attributes, v) == -1)
      : filter(keys(r[0]), (i, v) => index(divisorAttrs, v) == -1)

    return Project(r, K)
  endif

  const attrS = keys(s[0])
  const K     = filter(keys(r[0]), (i, v) => index(attrS, v) == -1)
  const R1    = Project(r, K)
  const S1    = Product(s, R1)->Minus(r)->Project(K)

  return Minus(R1, S1)
enddef

# This is a generalized form of division proposed by Stephen Todd, which does
# not impose any restrictions on the schemas of the operands. It is defined as
# follows: R(X,Y) ÷ S(Y,Z) = Q(X,Z) where:
#
# Q = {t | there are t1 in R and t2 in S such that t[X]=t1[X] and t[Z]=t2[Z],
#          and π_Y(S_Z) ⊆ π_Y(R_X) },
#
# where S_Z ⊆ S is the set of tuples that agree with t on Z, and R_X ⊆ R is
# the set of tuples that agree with t on X.
#
# Algebraically, Q can be derived as follows:
#
# Q = (π_X(R) ⨯ π_Z(S)) - π_XZ( (π_X(R) ⨯ S) - (R ⨝ S) )
#
# Except for the special case of an empty divisor, Todd's division reduces to
# Codd's division when Z is empty. Differently from Codd's division, when the
# divisor S is empty the result is always empty (note that the definition
# requires the existence of a tuple in S, even when Z is empty).
#
# See also:
# C Date & H Darwen, Into the Great Divide, Ch 11,
# Relational Database Writings 1989–1991.
# C Date, An Introduction to Database Systems
# M Levene and G Loizou, A Guided Tour of Relational Databases and Beyond, Ex. 3.4
export def Divide(Arg1: any, Arg2: any): Continuation
  const r = Query(Arg1)

  if empty(r)
    return From(r)
  endif

  const s = Query(Arg2)

  if empty(s)
    return From(s)
  endif

  const attrR = keys(r[0])
  const attrS = keys(s[0])
  const X = filter(keys(r[0]), (_, v) => index(attrS, v) == -1)
  const Z = filter(keys(s[0]), (_, v) => index(attrR, v) == -1)
  const R_X = Project(r, X)
  const Rhs = Product(R_X, s)->Minus(NatJoin(r, s))->Project(flattennew([X, Z]))

  return Project(s, Z)->Product(R_X)->Minus(Rhs)
enddef
# }}}

# Aggregate functions {{{
def Aggregate(Arg: any, initValue: any, Fn: func(Tuple, any): any): any
  const Cont = From(Arg)

  var Res: any = initValue

  Cont((t) => {
    Res = Fn(t, Res)
  })

  return Res
enddef

def ListAgg_(Arg: any, attr: Attr, How: any, unique: bool): list<any>
  var agg: list<any> = []
  const Cont = From(Arg)

  Cont((t) => {
    agg->add(t[attr])
  })

  if How == null
    return agg
  elseif unique
    return sort(agg, How)->uniq()
  endif

  return sort(agg, How)
enddef

export const ListAgg = Curry(ListAgg_)

def StringAgg_(Arg: any, attr: Attr, sep: string, How: any, unique: bool): string
  return ListAgg_(Arg, attr, How, unique)->join(sep)
enddef

export const StringAgg = Curry(StringAgg_)

export def Count(...ArgList: list<any>): number
  var count = 0
  const Cont = From(ArgList[0])

  Cont((t) => {
    ++count
  })

  return count
enddef

def CountDistinct_(Arg: any, attr: Attr): number
  var count = 0
  var seen: dict<bool> = {}
  const Cont = From(Arg)

  Cont((t) => {
    const v = String(t[attr])

    if !seen->has_key(v)
      ++count
      seen[v] = true
    endif
  })

  return count
enddef

export const CountDistinct = Curry(CountDistinct_)

def Max_(Arg: any, attr: Attr): any
  var first = true
  var max: any = null
  const Cont = From(Arg)

  Cont((t) => {
    const v = t[attr]

    if first
      max = v
      first = false
    elseif CompareValues(v, max) == 1
      max = v
    endif
  })

  return max
enddef

export const Max = Curry(Max_)

def Min_(Arg: any, attr: Attr): any
  var first = true
  var min: any = null
  const Cont = From(Arg)

  Cont((t) => {
    const v = t[attr]

    if first
      min = v
      first = false
    elseif CompareValues(v, min) == -1
      min = v
    endif
  })

  return min
enddef

export const Min = Curry(Min_)

def Sum_(Arg: any, attr: Attr): any
  return Aggregate(Arg, 0, (t, sum) => sum + t[attr])
enddef

export const Sum = Curry(Sum_)

def Avg_(Arg: any, attr: Attr): any
  var sum: float = 0.0
  var count = 0
  const Cont = From(Arg)

  Cont((t: Tuple) => {
    sum += t[attr]
    ++count
  })

  return count == 0 ? null : sum / count
enddef

export const Avg = Curry(Avg_)
# }}}
# }}}

# Convenience functions {{{
export def In(t: Tuple, R: any): bool
  return index(Instance(R), t) != -1
enddef

export def NotIn(t: Tuple, R: any): bool
  return !(t->In(R))
enddef

export def Split(Arg: any, Pred: UnaryPredicate): list<Relation>
  const Cont = From(Arg)
  var ok:  Relation = []
  var tsk: Relation = []

  Cont((t) => {
    if Pred(t)
      ok->add(t)
    else
      tsk->add(t)
    endif
  })

  return [ok, tsk]
enddef

export def PartitionBy(Arg: any, groupBy: any): dict<Relation>
  var   fid: dict<Relation> = {}
  const Cont = From(Arg)

  if type(groupBy) == v:t_string
    Cont((t) => {
      const groupKey = String(t[groupBy])

      if !fid->has_key(groupKey)
        fid[groupKey] = []
      endif

      fid[groupKey]->add(t)
    })
  else
    Cont((t) => {
      const groupValue = mapnew(groupBy, (_, attr) => t[attr])
      const groupKey = string(groupValue)

      if !fid->has_key(groupKey)
        fid[groupKey] = []
      endif

      fid[groupKey]->add(t)
    })
  endif

  return fid
enddef

export def Transform(Arg: any, Fn: func(Tuple): any): list<any>
  const Cont = From(Arg)
  var result = []

  Cont((t) => {
    const value = Fn(t)

    if value == null
      return
    elseif type(value) == v:t_list
      result += value
    else
      result->add(value)
    endif
  })

  return result
enddef

def ExtendByMerging(d1: Tuple, d2: Tuple)
  for k in keys(d2)
    if !d1->has_key(k)
      d1[k] = []
    endif

    d1[k]->add(d2[k])
  endfor
enddef

export def DictTransform(Arg: any, Fn: func(Tuple): Tuple, flatten = false): dict<any>
  const Cont = From(Arg)
  var result: dict<any> = {}

  Cont((t) => {
    ExtendByMerging(result, Fn(t))
  })

  if flatten
    for [k, v] in items(result)
      if len(v) == 1
        result[k] = v[0]
      endif
    endfor
  endif

  return result
enddef

# NOTE: l2 may be longer than l1 (extra elements are simply ignored)
export def Zip(l1: list<any>, l2: list<any>): Tuple
  const n = len(l1)
  var t: Tuple = {}
  var i = 0

  while i < n
    t[String(l1[i])] = l2[i]
    ++i
  endwhile

  return t
enddef

export def RelEq(R: any, S: any): bool
  const rel1: Relation = Instance(R)
  const rel2: Relation = Instance(S)

  return sort(copy(rel1)) == sort(copy(rel2))
enddef

def RecursiveWithoutDuplicates(
    rel: Relation, RecursiveStep: func(Relation): any
    ): Relation
  var result  = rel
  var working = result
  var seen: dict<bool> = {}

  for t in working
    seen[String(t)] = true
  endfor

  while !empty(working)
    var Intermediate = RecursiveStep(working)

    working = []

    From(Intermediate)((t) => {
      var st = String(t)

      if !seen->has_key(st)
        add(working, t)
        add(result, t)
        seen[st] = true
      endif
    })
  endwhile

  return result
enddef

def RecursiveWithDuplicates(
    rel: Relation, RecursiveStep: func(Relation): any
    ): Relation
  var result  = rel
  var working = result

  while !empty(working)
    var Intermediate = RecursiveStep(working)

    if IsFunc(Intermediate)
      working = []
      Intermediate((t) => {
        add(working, t)
        add(result, t)
      })
    else
      working = Instance(Intermediate)
      result->extend(working)
    endif
  endwhile

  return result
enddef

export def Recursive(
    BaseRel: any,
    RecursiveStep: func(Relation): any,
    unionall = false
    ): Relation
  if unionall
    return RecursiveWithDuplicates(Query(BaseRel), RecursiveStep)
  endif

  return RecursiveWithoutDuplicates(Query(BaseRel), RecursiveStep)
enddef

# Returns a textual representation of a relation
export def Table(
    R: any, name = null_string, columns: any = null, gap = 1, sep = '─'
): string
  if strchars(sep) != 1
    throw $'A table separator must be a single character. Got {sep}'
  endif

  var rel: Relation
  var relname: string

  if IsRel(R)
    rel = (<Rel>R).instance
    relname = empty(name) ? (<Rel>R).name : name
  else
    rel = R
    relname = name
  endif

  if empty(rel)
    return printf(" %s\n%s\n", relname, repeat(sep, 2 + strwidth(relname)))
  endif

  const attributes: AttrList = columns == null ? keys(rel[0]) : Listify(columns)
  var width: dict<number> = {}

  for attr in attributes
    width[attr] = gap + strwidth(attr)
  endfor

  # Determine the maximum width for each column
  for t in rel
    for attr in attributes
      const ll = gap + strwidth(String(t[attr]))
      if ll > width[attr]
        width[attr] = ll
      endif
    endfor
  endfor

  var totalWidth = 0

  for attr in attributes
    totalWidth += width[attr]
  endfor

  if totalWidth < 1 + strwidth(relname)
    totalWidth = 1 + strwidth(relname)
  endif

  def Fmt(n: number): string
    return '%' .. string(n) .. 'S'
  enddef

  def FmtHeader(): string
    return join(mapnew(attributes, (_, a) => printf(Fmt(width[a]), a)), '')
  enddef

  def FmtTuple(t: Tuple): string
    return join(mapnew(attributes, (_, a) => printf(Fmt(width[a]), String(t[a]))), '')
  enddef

  # Pretty print
  const separator = repeat(sep, totalWidth + 1)
  var table = empty(relname) ? '' : ' ' .. relname .. "\n"
  table ..= separator .. "\n"
  table ..= printf(Fmt(totalWidth), FmtHeader())
  table ..= printf("\n%s\n", separator)

  for t in rel
    table ..= printf(Fmt(totalWidth), FmtTuple(t)) .. "\n"
  endfor

  return table
enddef
# }}}
