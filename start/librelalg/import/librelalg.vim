vim9script

export var version = '0.3.0-alpha0'

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

# Types Aliases {{{
export type Attr            = string
export type Domain          = number       # v:t_number, v:t_string, etc.
export type Schema          = dict<Domain> # Map from Attr to Domain
export type AttrSet         = list<Attr>   # When the order does not matter
export type AttrList        = list<Attr>   # When the order matters
export type Tuple           = dict<any>
export type Relation        = list<Tuple>

export type Consumer        = func(Tuple): void
export type Continuation    = func(Consumer): void
export type UnaryPredicate  = func(Tuple): bool
export type BinaryPredicate = func(Tuple, Tuple): bool
# }}}

# Helper Functions {{{
def IsIn(v: any, items: list<any>): bool
  return indexof(items, (_, u) => u == v) != -1
enddef
def IsNotIn(v: any, items: list<any>): bool
  return indexof(items, (_, u) => u == v) == -1
enddef

# string() turns 'A' into a string of length 3, with quotes.
# Use this if you don't want that.
def String(value: any): string
  return type(value) == v:t_string ? value : string(value)
enddef

def ListStr(items: list<any>): string
  var stringified = mapnew(items, (_, v) => String(v))
  return '[' .. join(stringified, ', ') .. ']'
enddef

def TupleStr(t: Tuple, attrs: AttrList = keys(t)): string
  var stringified = mapnew(attrs,
    (_, a) => $'{a}: {string(t[a])}'
  )
  return '{' .. join(stringified, ', ') .. '}'
enddef

def SchemaStr(schema: Schema): string
  var stringified = mapnew(schema,
    (attr, dom) => $'{attr}: {DomainName(dom)}'
  )
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

def Listify(item: any): list<Attr>
  # item: Attr | AttrList
  return type(item) == v:t_list ? item : [item]
enddef

def ListifyKeys(keys: any): list<AttrList>
  # keys: Attr | AttrList | list<Attr | AttrList>
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
const E000 = 'At least one key must be specified for relation %s.'
const E001 = 'Expected a tuple on schema %s: got %s instead.'
const E002 = 'Key %s already defined in relation %s.'
const E003 = '%s is not an attribute of relation %s.'
const E004 = 'Duplicate key: %s already exists in %s.'
const E005 = 'Wrong foreign key: %s%s. %s is not an attribute of %s.'
const E006 = 'Foreign key size mismatch: %s%s -> %s%s.'
const E007 = 'Wrong foreign key: %s%s -> %s%s. %s is not a key of %s.'
const E008 = '%s: %s not found in %s%s.'
const E009 = '%s: cannot delete %s from %s because it is referenced by %s in %s.'
const E010 = '%s is not a key of %s.'
const E011 = '%s failed for %s.'
const E100 = 'Update failed: no tuple with key %s exists in relation %s.'
const E101 = 'Cannot replace %s with %s: updating key attributes is not allowed.'
const E200 = 'Join on sets of attributes of different length: %s vs %s.'
const E300 = 'A table separator must be a single character. Got %s.'
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

# Interfaces {{{
export interface IRel
  var name:       string
  var attributes: list<Attr>
  var keys:       list<AttrList>

  def Instance(): Relation
  def IsEmpty(): bool
  def Lookup(key: AttrList, value: list<any>): Tuple
endinterface

interface ICheckable extends IRel
  def OnInsertCheck(name: string, C: UnaryPredicate)
  def OnDeleteCheck(name: string, C: UnaryPredicate)
endinterface

interface ITransactable
  def IsConsistent_(): bool
  def Commit_()
  def Rollback_()
endinterface
# }}}

# Transactions {{{
class TransactionManager
  var _running: number              = 0
  var _pending: list<ITransactable> = []
  var _messages: list<string>       = []

  def Add(rel: ITransactable)
    if rel->IsNotIn(this._pending)
      this._pending->add(rel)
    endif
  enddef

  def LogMessage(msg: string, prepend = false)
    if prepend
      this._messages->insert(msg)
    else
      this._messages->add(msg)
    endif
  enddef

  def CheckConstraints(): bool
    for rel in this._pending
      if !rel.IsConsistent_()
        return false
      endif
    endfor

    return true
  enddef

  def Begin()
    this._running += 1
  enddef

  def Commit()
    if this._running == 0 # Not in a transaction (rolled back)
      return
    endif

    this._running -= 1

    if this._running > 0 # Nested transaction
      return
    endif

    if this.CheckConstraints()
      for rel in this._pending
        rel.Commit_()
      endfor

      this._pending  = []
      this._messages = []
    else
      this.Rollback()
    endif
  enddef

  def Rollback()
    for rel in this._pending
      rel.Rollback_()
    endfor

    var errors = join(this._messages)

    this._pending  = []
    this._messages = []
    this._running  = 0

    throw errors
  enddef
endclass

var globalTransactionManager = TransactionManager.new()

export def Transaction(Body: func())
  globalTransactionManager.Begin()
  Body()
  globalTransactionManager.Commit()
enddef

export def FailedMsg(message: string, prepend = false)
  globalTransactionManager.LogMessage(message, prepend)
enddef
# }}}

# Integrity constraints {{{
class Constraint
  var name:  string
  var Check: UnaryPredicate

  def string(): string
    return this.name
  enddef
endclass

export def ForeignKey(Child: ICheckable, fkey: any): list<any>
  var fkey_: AttrList = Listify(fkey)

  for attr in fkey_
    if attr->IsNotIn(Child.attributes)
      throw printf(E005, Child.name, ListStr(fkey_), attr, Child.name)
    endif
  endfor

  return [Child, fkey_]
enddef

export def References(foreign_key: list<any>, Parent: ICheckable, args: dict<any> = {})
  var Child = (<ICheckable>foreign_key[0])
  var fkey: AttrList = foreign_key[1]
  var key:  AttrList = args->has_key('key') ? Listify(args.key) : Parent.keys[0]

  if len(fkey) != len(key)
    throw printf(E006,
      Child.name,
      ListStr(fkey),
      Parent.name,
      ListStr(key)
    )
  endif

  if key->IsNotIn(Parent.keys)
    throw printf(E007,
      Child.name,
      ListStr(fkey),
      Parent.name,
      ListStr(key),
      ListStr(key),
      Parent.name
    )
  endif

  var fkStr = $'{Child.name} {args->get("verb", "references")} {Parent.name}'

  var FkConstraint: UnaryPredicate = (t) => {
    if Parent.Lookup(key, Values(t, fkey)) isnot KEY_NOT_FOUND
      return true
    endif

    FailedMsg(printf(E008,
      fkStr,
      TupleStr(t, fkey),
      Parent.name,
      ListStr(key))
    )
    return false
  }

  Child.OnInsertCheck('Referential integrity', FkConstraint)

  var FkPred = EquiJoinPred(fkey, key)

  var DelConstraint: UnaryPredicate = (t_p) => {
    if Parent.Lookup(key, Values(t_p, key)) isnot KEY_NOT_FOUND
      return true
    endif

    for t_c in Child.Instance()
      if FkPred(t_c, t_p)
        FailedMsg(printf(E009,
          fkStr,
          TupleStr(t_p),
          Parent.name, TupleStr(t_c),
          Child.name
        ))
        return false
      endif
    endfor

    return true
  }

  Parent.OnDeleteCheck('Referential integrity', DelConstraint)
enddef
# }}}

# Relations {{{
export class Rel implements IRel, ICheckable, ITransactable
  var name:               string
  var schema:             Schema
  var keys:               list<AttrList>
  var attributes:         AttrList
  var key_attributes:     AttrList
  var descriptors:        AttrList
  var insert_constraints: list<Constraint> = []
  var delete_constraints: list<Constraint> = []

  public var typecheck:   bool             = true

  var _instance:          Relation         = []
  var _key_indexes:       dict<Index>      = {}
  # Differential sets. See: Grefen and Apers, 1993
  # Integrity control in relational database systems - An overview
  var _inserted_tuples:   list<Tuple>      = []
  var _deleted_tuples:    list<Tuple>      = []

  def new(
      this.name,
      this.schema,
      relKeys: any,
      opts: dict<any> = {},
      )
    if empty(relKeys)
      throw printf(E000, this.name)
    endif

    var keys_: list<AttrList> = ListifyKeys(relKeys)

    this.typecheck      = get(opts, 'typecheck', true)
    this.attributes     = keys(this.schema)->sort()
    this.key_attributes = flattennew(keys_)->sort()->uniq()
    this.descriptors    = filter(
      copy(this.attributes),
      (_, v) => v->IsNotIn(this.key_attributes)
    )

    for key in keys_
      this.AddKeyConstraint_(key)
    endfor
  enddef

  def string(): string
    return $'{this.name}={this.Instance()}'
  enddef

  def Instance(): Relation
    return this._instance
  enddef

  def IsEmpty(): bool
    return empty(this._instance)
  enddef

  def Index(key: any): Index
    return this._key_indexes[string(Listify(key))]
  enddef

  def OnInsertCheck(name: string, C: UnaryPredicate)
    this.insert_constraints->add(Constraint.new(name, C))
  enddef

  def OnDeleteCheck(name: string, C: UnaryPredicate)
    this.delete_constraints->add(Constraint.new(name, C))
  enddef

  def Add_(t: Tuple)
    this.TypeCheck_(t)
    this._instance->add(t)

    for idx in values(this._key_indexes)
      idx.Add(t)
    endfor
  enddef

  def Remove_(t: Tuple)
    var i = indexof(this._instance, (_, u) => u is t)

    remove(this._instance, i)

    for idx in values(this._key_indexes)
      idx.Remove(t)
    endfor
  enddef

  def Insert(t: Tuple): Rel
    globalTransactionManager.Add(this)

    Transaction(() => {
      this.Add_(t)

      # Check if t was previously deleted during the current transaction
      var k = indexof(this._deleted_tuples, (_, u: Tuple) => u == t)

      if k == -1
        this._inserted_tuples->add(t)
      else # This insertion undoes the deletion
        remove(this._deleted_tuples, k)
      endif
    })

    return this
  enddef

  def Delete(P: UnaryPredicate = (t) => true): Relation
    var deleted: list<Tuple> = []

    globalTransactionManager.Add(this)

    Transaction(() => {
      for t in this._instance
        if P(t)
          deleted->add(t)

          for idx in values(this._key_indexes)
            idx.Remove(t)
          endfor

          # Check if t was previously inserted during the current transaction
          var k = indexof(this._inserted_tuples, (_, u: Tuple) => u == t)

          if k == -1
            this._deleted_tuples->add(t)
          else # This deletion undoes the insertion
            remove(this._inserted_tuples, k)
          endif
        endif
      endfor

      filter(this._instance, (_, t) => !P(t))
    })

    return deleted
  enddef

  def InsertMany(tuples: list<Tuple>): Rel
    Transaction(() => {
      for t in tuples
        this.Insert(t)
      endfor
    })

    return this
  enddef

  def Update(P: UnaryPredicate, Set: func(Tuple))
    globalTransactionManager.Add(this)

    Transaction(() => {
      var deleted = this.Delete(P)

      for t in deleted
        var new_t = deepcopy(t)

        Set(new_t)
        this.Insert(new_t)
      endfor
    })
  enddef

  def Lookup(key: AttrList, value: list<any>): Tuple
    var idx: Index

    try
      idx = this._key_indexes[String(key)]
    catch /^Vim\%((\a\+)\)\=:E716:/
      throw printf(E010, key, this.name)
    endtry

    var result = idx.Search(value)

    return empty(result) ? KEY_NOT_FOUND : result[0]
  enddef

  def Upsert(t: Tuple, opts: dict<any> = {})
    # Lookup by primary key (conventionally, the first defined key)
    var u = this.Lookup(this.keys[0], Values(t, this.keys[0]))

    if u is KEY_NOT_FOUND
      if get(opts, 'insert', true)
        this.Insert(t)
        return
      endif

      throw printf(E100, TupleStr(t, this.keys[0]), this.name)
    endif

    if u == t
      return
    endif

    Transaction(() => {
      this.Delete((v) => v == u)
      this.Insert(t)
    })
  enddef

  def TypeCheck_(t: Tuple)
    if this.typecheck
      if sort(keys(t)) != this.attributes
        FailedMsg(printf(E001, SchemaStr(this.schema), TupleStr(t)))
        globalTransactionManager.Rollback()
      endif

      for [attr, domain] in items(this.schema)
        var v = t[attr]

        if type(v) != domain
          FailedMsg(printf(E001, SchemaStr(this.schema), TupleStr(t)))
          globalTransactionManager.Rollback()
        endif
      endfor
    endif
  enddef

  def AddKeyConstraint_(key: AttrList)
    if key->IsIn(this.keys)
      throw printf(E002, ListStr(key), this.name)
    endif

    for attr in key
      if attr->IsNotIn(this.attributes)
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

      FailedMsg(printf(E004, TupleStr(t, key), this.name))

      return false
    }

    this._key_indexes[string(key)] = keyIndex
    this.OnInsertCheck('Uniqueness', IsUnique)
  enddef

  def IsConsistent_(): bool
    for constraint in this.insert_constraints
      for t in this._inserted_tuples
        if !constraint.Check(t)
          FailedMsg(printf(E011, constraint, TupleStr(t)), true)
          return false
        endif
      endfor
    endfor

    for constraint in this.delete_constraints
      for t in this._deleted_tuples
        if !constraint.Check(t)
          FailedMsg(printf(E011, constraint, TupleStr(t)), true)
          return false
        endif
      endfor
    endfor

    return true
  enddef

  def Commit_()
    this._inserted_tuples = []
    this._deleted_tuples  = []
  enddef

  def Rollback_()
    for t in this._inserted_tuples
      this.Remove_(t)
    endfor

    for t in this._deleted_tuples
      this.Add_(t)
    endfor

    this._inserted_tuples = []
    this._deleted_tuples  = []
  enddef
endclass
# }}}
# }}}

# IRel related helper functions {{{
def IsRel(R: any): bool
  return type(R) == v:t_object
enddef

def Instance(R: any): Relation
  return type(R) == v:t_object ? (<IRel>R).Instance() : R
enddef

def IsKeyOf(attrs: AttrList, R: IRel): bool
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
export def Rename(Arg: any, renamed: dict<string>): Continuation
  var Cont = From(Arg)

  return (Emit: Consumer) => {
    def RenameAttr(t: Tuple)
      var i = 0
      var tnew = copy(t)

      for old_attr in keys(renamed)
        tnew[renamed[old_attr]] = tnew[old_attr]
        tnew->remove(old_attr)
      endfor

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
    var unew: Tuple = {}

    for attr in keys(u)
      if t->has_key(attr)
        unew[prefix .. attr] = u[attr]
      else
        unew[attr] = u[attr]
      endif
    endfor

    return unew->extend(t, 'error')
  }
enddef

export def Join(
    Arg1: any, Arg2: any, Pred: BinaryPredicate, opts: dict<any> = {}
    ): Continuation
  var prefix = get(opts, 'prefix', '_')
  var MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
  var rel  = Query(Arg2)
  var Cont = From(Arg1)

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
    throw printf(E200, ListStr(lAttrs), ListStr(rgt))
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
export def EquiJoin(Arg1: any, Arg2: any, opts: dict<any> = {}): Continuation
  var lAttrList = Listify(get(opts, 'onleft',  get(opts, 'on', [])))
  var rAttrList = Listify(get(opts, 'onright', get(opts, 'on', [])))
  var prefix    = get(opts, 'prefix', '_')

  if IsRel(Arg2) && rAttrList->IsKeyOf(Arg2) # Fast path
    var MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
    var Cont = From(Arg1)
    var rel: IRel = Arg2

    return (Emit: Consumer) => {
      Cont((t: Tuple) => {
        var u = rel.Lookup(rAttrList, Values(t, lAttrList))

        if u isnot KEY_NOT_FOUND
          Emit(MergeTuples(t, u))
        endif
      })
    }
  endif

  var Pred = EquiJoinPred(lAttrList, rAttrList)

  return Join(Arg1, Arg2, Pred, {prefix: prefix})
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

export def Product(Arg1: any, Arg2: any, opts: dict<any> = {}): Continuation
  var prefix      = get(opts, 'prefix', '_')
  var MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
  var rel         = Query(Arg2)
  var Cont        = From(Arg1)

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
  var rel  = Query(Arg2)
  var Cont = From(Arg1)

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

# export def AntiEquiJoin(Arg1: any, Arg2: any, lAttrs: any, rAttrs: any = lAttrs): Continuation
export def AntiEquiJoin(Arg1: any, Arg2: any, opts: dict<any> = {}): Continuation
  var lAttrList = Listify(get(opts, 'onleft',  get(opts, 'on', [])))
  var rAttrList = Listify(get(opts, 'onright', get(opts, 'on', [])))
  var Cont      = From(Arg1)

  if IsRel(Arg2) && rAttrList->IsKeyOf(Arg2) # Fast path
    var rel: IRel = Arg2

    return (Emit: Consumer) => {
      Cont((t: Tuple) => {
        var u = rel.Lookup(rAttrList, Values(t, lAttrList))

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
export def LeftNatJoin(Arg1: any, Arg2: any, opts: dict<any> = {}): Continuation
  var rel    = Query(Arg2)
  var Cont   = From(Arg1)
  var filler = Query(get(opts, 'filler', []))

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

export def LeftEquiJoin(Arg1: any, Arg2: any, opts: dict<any> = {}): Continuation
  var lAttrList   = Listify(get(opts, 'onleft',  get(opts, 'on', [])))
  var rAttrList   = Listify(get(opts, 'onright', get(opts, 'on', [])))
  var filler      = Query(get(opts, 'filler', []))
  var prefix      = get(opts, 'prefix', '_')
  var Cont        = From(Arg1)
  var MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)

  if IsRel(Arg2) && rAttrList->IsKeyOf(Arg2) # Fast path
    var rel: IRel = Arg2

    return (Emit: Consumer) => {
      Cont((t: Tuple) => {
        var u = rel.Lookup(rAttrList, Values(t, lAttrList))

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

  var rel  = Query(Arg2)
  var Pred = EquiJoinPred(lAttrList, rAttrList)

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

export def Extend(Arg: any, Fn: func(Tuple): Tuple, opts: dict<any> = {}): Continuation
  var Cont = From(Arg)
  var match = get(opts, 'force', false) ? 'keep' : 'error'

  return (Emit: Consumer) => {
    Cont((t: Tuple) => {
      Emit(Fn(t)->extend(t, match))
    })
  }
enddef

# Inspired by the framing operator described in
# EF Codd, The Relational Model for Database Management: Version 2, 1990
export def Frame(Arg: any, attrs: any, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', 'fid')
  var inplace = get(opts, 'inplace', false)
  var fid = 0  # Frame identifier
  var seen: dict<number> = {}
  var attrList: AttrSet = Listify(attrs)
  var Cont = From(Arg)

  return (Emit: Consumer) => {
    def FrameTuple(t: Tuple)
      var groupby = string(ProjectTuple(t, attrList))

      if !seen->has_key(groupby)
        seen[groupby] = fid
        ++fid
      endif

      if inplace
        t[name] = seen[groupby]
        Emit(t)
      else
        Emit(extendnew(t, {[name]: seen[groupby]}, 'error'))
      endif
    enddef

    Cont((t) => FrameTuple(t))
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
      ? filter(keys(r[0]), (i, v) => index((<IRel>Arg2).attributes, v) == -1)
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
export def Aggregate(Arg: any, Fn: func(any): any): Continuation
  if type(Arg) == v:t_dict # Input from GroupBy()
    var attrs = Arg.attributes
    var groups: list<Relation> = values(Arg.groups)

    return (Emit: Consumer) => {
      for group in groups
        var Cont = From(Fn(group))

        Cont((t) => {
          for attr in attrs
            t[attr] = group[0][attr]
          endfor

          Emit(t)
        })
      endfor
    }
  endif

  return From(Fn(Arg))
enddef

export def Count(Arg: any, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', 'count')
  return Aggregate(Arg, (R): Relation => [{[name]: len(Query(R))}])
enddef

export def CountDistinct(Arg: any, attr: Attr, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', 'count')

  return Aggregate(Arg, (R): Relation => {
    var count = 0
    var seen: dict<bool> = {}
    var Cont = From(R)

    Cont((t) => {
      var v = String(t[attr])

      if !seen->has_key(v)
        ++count
        seen[v] = true
      endif
    })

    return [{[name]: count}]
  })
enddef

export def Max(Arg: any, attr: Attr, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', 'max')

  return Aggregate(Arg, (R): Relation => {
    var first = true
    var max: any = null
    var Cont = From(R)

    Cont((t) => {
      var v = t[attr]

      if first
        max = v
        first = false
      elseif CompareValues(v, max) == 1
        max = v
      endif
    })

    return [{[name]: max}]
  })
enddef

export def Min(Arg: any, attr: Attr, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', 'min')

  return Aggregate(Arg, (R): Relation => {
    var first = true
    var min: any = null
    var Cont = From(R)

    Cont((t) => {
      var v = t[attr]

      if first
        min = v
        first = false
      elseif CompareValues(v, min) == -1
        min = v
      endif
    })

    return [{[name]: min}]
  })
enddef

export def Sum(Arg: any, attr: Attr, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', 'sum')

  return Aggregate(Arg, (R): Relation => {
    var sum = 0.0
    var Cont = From(R)

    Cont((t) => {
      sum += t[attr]
    })

    return [{[name]: sum}]
  })
enddef

export def Avg(Arg: any, attr: Attr, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', 'avg')

  return Aggregate(Arg, (R): Relation => {
    var sum: float = 0.0
    var count = 0
    var Cont = From(R)

    Cont((t) => {
      sum += t[attr]
      ++count
    })

    return [{[name]: count == 0 ? null : sum / count}]
  })
enddef

export def ListAggregate(Arg: any, attr: Attr, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', attr)

  return Aggregate(Arg, (R): Relation => {
    var agg: list<any> = []
    var Cont = From(R)

    Cont((t) => {
      agg->add(t[attr])
    })

    var How = get(opts, 'how', null)

    if How == null
      return [{[name]: agg}]
    elseif get(opts, 'unique', false)
      return [{[name]: sort(agg, How)->uniq()}]
    endif

    return [{[name]: sort(agg, How)}]
  })
enddef

export def StringAggregate(Arg: any, attr: Attr, opts: dict<any> = {}): Continuation
  var name = get(opts, 'name', attr)

  var sep = get(opts, 'sep', '')
  var Cont = ListAggregate(Arg, attr, opts)

  return (Emit: Consumer) => {
    Cont((t) => {
      t[name] = t[name]->join(sep)
      Emit(t)
    })
  }
enddef
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
  var Cont = From(Arg)
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

def FlatPartitionBy(Arg: any, groupBy: any): dict<Relation>
  var fid: dict<Relation> = {}
  var Cont = From(Arg)

  if type(groupBy) == v:t_string
    Cont((t) => {
      var groupKey = String(t[groupBy])

      if !fid->has_key(groupKey)
        fid[groupKey] = []
      endif

      fid[groupKey]->add(t)
    })
  else
    Cont((t) => {
      var groupValue = mapnew(groupBy, (_, attr) => t[attr])
      var groupKey = string(groupValue)

      if !fid->has_key(groupKey)
        fid[groupKey] = []
      endif

      fid[groupKey]->add(t)
    })
  endif

  return fid
enddef

export def GroupBy(Arg: any, groupBy: any): dict<any> # TODO: use Vim's tuple
  return {attributes: Listify(groupBy), groups: FlatPartitionBy(Arg, groupBy)}
enddef

export def PartitionBy(Arg: any, groupBy: any, opts: dict<any> = {}): dict<any>
  if get(opts, 'flat', false)
    return FlatPartitionBy(Arg, groupBy)
  endif

  var fid: dict<any> = {}
  var Cont = From(Arg)
  var groupBy_ = Listify(groupBy)
  var n = len(groupBy_)

  Cont((t) => {
    var i = 0
    var dict = fid
    var key: string

    while i < n - 1
      key = String(t[groupBy_[i]])

      if !dict->has_key(key)
        dict[key] = {}
      endif

      dict = dict[key]
      ++i
    endwhile

    key = String(t[groupBy_[-1]])

      if !dict->has_key(key)
        dict[key] = []
      endif

    dict[key]->add(t)
  })

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
# export def Table(R: any, name = null_string, columns: any = null, gap = 1, sep = '─'): string
export def Table(R: any, opts: dict<any> = {}): string
  var name    = get(opts, 'name', null_string)
  var columns = get(opts, 'columns', null_list)
  var gap     = get(opts, 'gap', 1)
  var sep     = get(opts, 'sep', '─')

  if strchars(sep) != 1
    throw printf(E300, sep)
  endif

  var rel: Relation
  var relname: string

  if IsRel(R)
    rel = (<IRel>R).Instance()
    relname = empty(name) ? (<IRel>R).name : name
  else
    rel = Query(R)
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
