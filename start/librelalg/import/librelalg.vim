vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

# Helper functions {{{
# string() turns 'A' into a string of length 3, with quotes. We do not want that.
def String(value: any): string
  return type(value) == v:t_string ? value : string(value)
enddef

def SchemaAsString(schema: dict<number>): string
  const schemaStr = mapnew(schema, (attr, atype): string => printf("%s: %s", attr, TypeName(atype)))
  return '{' .. join(values(schemaStr), ', ') .. '}'
enddef

def All(items: list<any>, Pred: func(any): bool): bool
  return reduce(items, (res, item) => res && Pred(item), true)
enddef

def Any(items: list<any>, Pred: func(any): bool): bool
  return reduce(items, (res, item) => res || Pred(item), false)
enddef

def IsFunc(X: any): bool
  return type(X) == v:t_func
enddef

def Listify(item: any): list<string>
  return type(item) == v:t_list ? item : [item]
enddef

def ListifyKeys(keys: any): list<list<string>>
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

def CompareTuples(t: dict<any>, u: dict<any>, attrList: list<string>, invert: list<bool> = []): number
  if empty(invert)
    for a in attrList
      const cmp = CompareValues(t[a], u[a])
      if cmp == 0
        continue
      endif
      return cmp
    endfor
    return 0
  endif

  const n = len(attrList)
  var i = 0
  while i < n
    const a = attrList[i]
    const cmp = CompareValues(t[a], u[a], invert[i])
    if cmp == 0
      i += 1
      continue
    endif
    return cmp
  endwhile
  return 0
enddef

def ProjectTuple(t: dict<any>, attrList: list<string>): dict<any>
  var u = {}
  for attr in attrList
    u[attr] = t[attr]
  endfor
  return u
enddef

def Values(t: dict<any>, attrList: list<string>): list<any>
  var values = []
  for a in attrList
    values->add(t[a])
  endfor
  return values
enddef


def NumArgs(Fn: func): number   # Number of arguments of a function
  return len(split(matchstr(typename(Fn), '([^)]\+)'), ','))
enddef

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
# type TType        number
# type TTupleSchema dict<TType>
# type TRelSchema   dict<any>
# type TKey         list<TAttr>
# type TConstraint  func(Tuple, string): void
# type TIndex       dict<any>

# Data types  {{{
export const Int     = v:t_number
export const Str     = v:t_string
export const Bool    = v:t_bool
export const Float   = v:t_float
export const Func    = v:t_func
export const List    = v:t_list

const TypeString = {
  [Int]:         'integer',
  [Str]:         'string',
  [Float]:       'float',
  [Bool]:        'boolean',
  [Func]:        'funcref',
  [List]:        'list',
  [v:t_dict]:    'dictionary',
  [v:t_none]:    'none',
  [v:t_job]:     'job',
  [v:t_channel]: 'channel',
  [v:t_blob]:    'blob'
}

def TypeName(atype: number): string
  return get(TypeString, atype, 'unknown')
enddef
# }}}

# Error messages {{{


def ErrAttributeType(t: dict<any>, schema: dict<number>, attr: string): string
  const value = t[attr]
  const wrongType = TypeName(type(value))
  const rightType = TypeName(schema[attr])
  return printf("Attribute %s is of type %s, but value '%s' of type %s was provided",
                attr, rightType, value, wrongType)
enddef

def ErrConstraintNotSatisfied(relname: string, t: dict<any>, msg: string): string
  return printf("%s violates a constraint of %s: %s", t, relname, msg)
enddef

def ErrKeyAlreadyDefined(name: string, key: list<string>): string
  return printf('Key %s already defined in %s', key, name)
enddef

def ErrDuplicateKey(key: list<string>, t: dict<any>): string
  const tStr = join(mapnew(key, (_, v) => string(t[v])), ', ')
  return printf('Duplicate key value: %s = (%s) already exists', key, tStr)
enddef

def ErrEquiJoinAttributes(attrList: list<string>, otherList: list<string>): string
  return printf("Join on lists of attributes of different length: %s vs %s", attrList, otherList)
enddef

def ErrReferentialIntegrity(
    child:      string,
    verbphrase: string,
    parent:     string,
    fkey:       list<string>,
    key:        list<string>,
    t:          dict<any>
): string
    const tStr = join(mapnew(fkey, (_, v) => string(t[v])), ', ')
    return printf("%s %s %s: %s%s = (%s) is not present in %s%s",
                  child, verbphrase, parent, child, fkey, tStr, parent, key)
enddef

def ErrReferentialIntegrityDeletion(
    child:      string,
    verbphrase: string,
    parent:     string,
    fkey:       list<string>,
    key:        list<string>,
    t_c:        dict<any>,
    t_p:        dict<any>
): string
  const keyVal  = join(mapnew(key,  (_, v) => string(t_p[v])), ', ')
  return printf("%s %s %s: %s%s = (%s) is referenced by %s",
                child, verbphrase, parent, parent, key, keyVal, t_c)
enddef

def ErrForeignKeySize(child: string, fkey: list<string>, parent: string, key: list<string>): string
  return printf("Wrong foreign key size: %s%s -> %s%s", child, fkey, parent, key)
enddef

def ErrForeignKeySource(child: string, fkey: list<string>, parent: string, key: list<string>): string
  return printf("Wrong foreign key: %s%s -> %s%s. %s is not an attribute of %s",
                child, fkey, parent, key, '%s', child)
enddef

def ErrForeignKeyTarget(child: string, fkey: list<string>, parent: string, key: list<string>): string
  return printf("Wrong foreign key: %s%s -> %s%s. %s is not a key of %s",
                child, fkey, parent, key, key, parent)
enddef

def ErrIncompatibleTuple(t: dict<any>, schema: dict<number>): string
  const schemaStr = SchemaAsString(schema)
  return printf("Expected a tuple on schema %s: got %s instead", schemaStr, t)
enddef

def ErrKeyNotFound(relname: string, key: list<string>, keyValue: list<any>): string
  return printf("Tuple with %s = %s not found in %s", key, keyValue, relname)
enddef

def ErrNoKey(relname: string): string
  return printf("No key specified for relation %s", relname)
enddef

def ErrInvalidAttribute(relname: string, attr: string): string
  return printf("%s is not an attribute of %s", attr, relname)
enddef

def ErrNotAKey(relname: string, key: list<string>): string
  return printf("%s is not a key of %s", key, relname)
enddef

def ErrUpdateKeyAttribute(relname: string, attr: string, t: dict<any>, oldt: dict<any>): string
  return printf("Key attribute %s in %s cannot be changed (trying to update %s with %s)", attr, relname, oldt, t)
enddef

def ErrInvalidConstraintClause(op: string): string
  return printf("Expected one of 'I' (insert), 'U' (update), 'D' (deletion), but got %s", op)
enddef
# }}}

# Indexes {{{
export const KEY_NOT_FOUND: dict<bool> = {}

class UniqueIndex
  this.key: list<string> = []
  this._index: dict<dict<any>> = {}

  def GetRawIndex(): dict<dict<any>>
    return this._index
  enddef

  def IsEmpty(): bool
    return empty(this._index)
  enddef

  def Add(t: dict<any>)
    const keyValues = string(Values(t, this.key))
    this._index[keyValues] = t
  enddef

  def Remove(keyValue: list<any>)
    this._index->remove(string(keyValue))
  enddef

  def Search(keyValue: list<any>): dict<any>
    return get(this._index, string(keyValue), KEY_NOT_FOUND)
  enddef
endclass
# }}}

# Relations {{{
export class Rel
  this.name:          string
  this.schema:        dict<number>
  this.instance:      list<dict<any>> = []
  this.keys:          list<list<string>>
  this.attributes:    list<string>
  this.keyAttributes: list<string>
  this.descriptors:   list<string>
  this._attrtype:     list<number> = []
  this._indexes:      dict<UniqueIndex> = {}
  this._constraints:  dict<list<func(dict<any>): void>> = {'I': [], 'U': [], 'D': []}

  def new(this.name, this.schema, keys: any, checkType = true)
    if checkType
      this.TypeCheck_()
    endif

    if empty(keys)
      throw ErrNoKey(this.name)
    endif

    const keys_: list<list<string>> = ListifyKeys(keys)

    this.attributes = keys(this.schema)->sort()
    this.keyAttributes = flattennew(keys_)->sort()->uniq()
    this.descriptors = filter(copy(this.attributes), (_, v) => index(this.keyAttributes, v) == -1)

    for attr in this.attributes
      this._attrtype->add(this.schema[attr])
    endfor

    for key in keys_
      this.Key(key)
    endfor
  enddef

  def Key(key: any)
    const key_: list<string> = Listify(key)

    if index(this.keys, key_) != -1
      throw ErrKeyAlreadyDefined(this.name, key_)
    endif

    for attr in key_
      if index(this.attributes, attr) == -1
        throw ErrInvalidAttribute(this.name, attr)
      endif
    endfor

    this.keys->add(key_)

    var index = UniqueIndex.new(key_)

    this._indexes[string(key_)] = index

    const KeyConstraint = (t: dict<any>): void => {
      if index.Search(Values(t, key_)) isnot KEY_NOT_FOUND
        throw ErrDuplicateKey(key_, t)
      endif
    }

    this._constraints.I->add(KeyConstraint)
  enddef

  def IsEmpty(): bool
    return empty(this.instance)
  enddef

  def Index(key: any): UniqueIndex
    return this._indexes[string(Listify(key))]
  enddef

  def Insert(t: dict<any>): any
    for CheckConstraint in this._constraints.I
      CheckConstraint(t)
    endfor

    this.instance->add(t)

    for idx in values(this._indexes)
      idx.Add(t)
    endfor

    return this
  enddef

  def InsertMany(tuples: list<dict<any>>, atomic: bool = false): any
    if atomic
      var inserted: list<dict<any>> = []

      for t in tuples
        try
          this.Insert(t)
          inserted->add(t)
        catch
          this.RollbackInsertion_(inserted)
          throw v:exception
        endtry
      endfor
    else
      for t in tuples
        this.Insert(t)
      endfor
    endif

    return this
  enddef

  def RollbackInsertion_(tuples: list<dict<any>>)
    const DeletePred = (i: number, t: dict<any>): bool => {
      if t->In(tuples)
        for index in values(this._indexes)
          const keyValue = Values(t, index.key)
          index.Remove(keyValue)
        endfor

        return false
      endif

      return true
    }

    filter(this.instance, DeletePred)
  enddef

  def Update(t: dict<any>, upsert = false): any
    const key = this.keys[0]
    const keyValue = Values(t, key)
    const oldt = this.Lookup(key, keyValue)

    if oldt is KEY_NOT_FOUND
      if upsert
        this.Insert(t)
      else
        throw ErrKeyNotFound(this.name, key, keyValue)
      endif
      return this
    endif

    for attr in this.keyAttributes
      if t[attr] != oldt[attr]
        throw ErrUpdateKeyAttribute(this.name, attr, t, oldt)
      endif
    endfor

    # This may be tricky for some kind of constraints, as the old tuple is
    # still in the relation at this point. But for simple checks it should work.
    for CheckConstraint in this._constraints.U
      CheckConstraint(t)
    endfor

    for attr in this.descriptors
      oldt[attr] = t[attr]
    endfor

    return this
  enddef

  def Delete(
      Pred: func(dict<any>): bool = (t) => true,
      atomic: bool = false
  ): any
    const DeletePred = (i: number, t: dict<any>): bool => {
      if Pred(t)
        for CheckConstraint in this._constraints.D
          CheckConstraint(t)
        endfor

        for index in values(this._indexes)
          const keyValue = Values(t, index.key)
          index.Remove(keyValue)
        endfor

        return false
      endif

      return true
    }

    if atomic
      this.instance = filter(copy(this.instance), DeletePred)
    else
      filter(this.instance, DeletePred)
    endif

    return this
  enddef

  def Lookup(key: list<string>, value: list<any>): dict<any>
    if index(this.keys, key) == -1
      throw ErrNotAKey(this.name, key)
    endif
    const index = this._indexes[String(key)]
    return index.Search(value)
  enddef

  def Check(Constraint: func(dict<any>), opList: list<string> = ['I', 'U'])
    for op in opList
      if index(['I', 'U', 'D'], op) == -1
        throw ErrInvalidConstraintClause(op)
      endif

      this._constraints[op]->add(Constraint)
    endfor
  enddef


  def TypeCheck_()
    const TypeConstraint = (t: dict<any>): void => {
      const schema = this.schema

      if sort(keys(t)) != this.attributes
        throw ErrIncompatibleTuple(t, schema)
      endif

      for [attr, atype] in items(schema)
        if type(t[attr]) != atype
          throw ErrAttributeType(t, schema, attr)
        endif
      endfor
    }

    this.Check(TypeConstraint, ['I', 'U'])
  enddef
endclass
# }}}

# Rel related helper functions {{{
def AsRel(R: Rel): Rel
  return R
enddef

def IsRel(R: any): bool
  return type(R) == v:t_object
enddef

def Instance(R: any): list<dict<any>>
  return type(R) == v:t_object ? AsRel(R).instance : R
enddef

def IsKeyOf(attrs: list<string>, R: Rel): bool
  return index(R.keys, attrs) != -1
enddef
# }}}

# Integrity constraints {{{
def SameSize(l1: any, l2: any, errMsg: string): void
  if len(l1) != len(l2)
    throw errMsg
  endif
enddef

def Conforms(attrList: list<string>, R: Rel, errMsg: string): void
  const schema = R.attributes
  for attr in attrList
    if index(schema, attr) == -1
      throw printf(errMsg, attr)
    endif
  endfor
enddef

def HasKey(R: Rel, key: list<string>, errMsg: string): void
  if index(R.keys, key) == -1
    throw errMsg
  endif
enddef

export def ForeignKey(
  Child:      Rel,
  verbphrase: string,
  Parent:     Rel,
  fkey:       any,
  key:        any = null
): void
  const fkey_: list<string> = Listify(fkey)
  const key_:  list<string> = key == null ? fkey_ : Listify(key)

  fkey_->SameSize(key_,  ErrForeignKeySize(Child.name, fkey_, Parent.name, key_))
  fkey_->Conforms(Child, ErrForeignKeySource(Child.name, fkey_, Parent.name, key_))
  Parent->HasKey(key_,   ErrForeignKeyTarget(Child.name, fkey_, Parent.name, key_))

  const FkConstraint = (t: dict<any>): void => {
    if Parent.Lookup(key_, Values(t, fkey_)) is KEY_NOT_FOUND
      throw ErrReferentialIntegrity(Child.name, verbphrase, Parent.name, fkey_, key_, t)
    endif
  }

  Child.Check(FkConstraint, ['I', 'U'])

  const FkPred = EquiJoinPred(fkey_, key_)

  const DelConstraint = (t_p: dict<any>): void => {
    for t_c in Child.instance
      if FkPred(t_c, t_p)
        throw ErrReferentialIntegrityDeletion(Child.name, verbphrase, Parent.name, fkey_, key_, t_c, t_p)
      endif
    endfor
  }

  Parent.Check(DelConstraint, ['D'])
enddef
# }}}
# }}}

# Relational Algebra {{{
# A push-based query engine. Loosely inspired by
# https://arxiv.org/abs/1610.09166:
#
# Shaikhna, Amir and Dashti Mohammad and Koch, Christoph
# Push vs. Pull-Based Loop Fusion in Query Engines, 2016
#
# and references therein.

# type Attr         string
# type Tuple        dict<any>
# type Rel          list<Tuple>
# type Consumer     func(Tuple): void
# type Continuation func(Consumer): void

# Root operators (requiring a relation as input) {{{
export def From(Arg: any): func(func(dict<any>))
  if IsFunc(Arg)
    return Arg
  endif

  const rel: list<dict<any>> = Instance(Arg)

  return (Emit: func(dict<any>)) => {
    for t in rel
      Emit(t)
    endfor
  }
enddef

export def Scan(Arg: any): func(func(dict<any>))
  return From(Arg)
enddef

export def Foreach(Arg: any): func(func(dict<any>))
  return From(Arg)
enddef
# }}}

# Leaf operators (returning a relation) {{{
def Materialize(Cont: func(func(dict<any>))): list<dict<any>>
  var rel: list<dict<any>> = []
  Cont((t) => {
    add(rel, t)
  })
  return rel
enddef

export def Query(Arg: any): list<dict<any>>
  return IsFunc(Arg) ? Materialize(Arg) : Instance(Arg)
enddef

export def Build(Arg: any): list<dict<any>>
  return Query(Arg)
enddef

export def Sort(Arg: any, ComparisonFn: func(dict<any>, dict<any>): number): list<dict<any>>
  var rel = Query(Arg)
  return sort(rel, ComparisonFn)
enddef

export def SortBy(Arg: any, attrs: any, opts: list<string> = []): list<dict<any>>
  const invert: list<bool> = mapnew(opts, (_, v) => v == 'd')
  const attrList: list<string> = Listify(attrs)
  const SortAttrPred = (t: dict<any>, u: dict<any>): number => CompareTuples(t, u, attrList, invert)
  return Sort(Arg, SortAttrPred)
enddef

export def Union(Arg1: any, Arg2: any): list<dict<any>>
  if IsFunc(Arg1)
    return Materialize(Arg1)->extend(Query(Arg2))->sort()->uniq()
  else
    return Instance(Arg1)->extendnew(Query(Arg2))->sort()->uniq()
  endif
enddef

export def Filter(Arg: any, Pred: func(dict<any>): bool): list<dict<any>>
  var rel = IsFunc(Arg) ? Materialize(Arg) : copy(Instance(Arg))
  return filter(rel, (_, t) => Pred(t))
enddef

export def SumBy(
    Arg: any,
    groupBy: any,
    attr: string,
    aggrName = 'sum'
): list<dict<any>>
  var   aggr: dict<dict<any>> = {}
  const groupBy_: list<string> = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: dict<any>) => {
    var tp = ProjectTuple(t, groupBy_)
    const group = string(values(tp))
    if !aggr->has_key(group)
      aggr[group] = tp->extend({[aggrName]: 0})
    endif
    aggr[group][aggrName] += t[attr]
  })

  return empty(groupBy_) && empty(aggr) ? [{[aggrName]: 0}] : values(aggr)
enddef

export def CountBy(
    Arg: any,
    groupBy: any,
    attr: string = null_string,
    aggrName = 'count'
): list<dict<any>>
  var   aggrCount: dict<dict<any>> = {}
  var   aggrDistinct: dict<dict<bool>> = {}
  const groupBy_: list<string> = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: dict<any>) => {
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

export def MaxBy(
    Arg: any,
    groupBy: any,
    attr: string,
    aggrName = 'max'
): list<dict<any>>
  var   aggr: dict<dict<any>> = {}  # Map group => tuple
  const groupBy_: list<string> = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: dict<any>) => {
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

export def MinBy(
    Arg: any,
    groupBy: any,
    attr: string,
    aggrName = 'min'
): list<dict<any>>
  var   aggr: dict<dict<any>> = {}  # Map group => tuple
  const groupBy_: list<string> = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: dict<any>) => {
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

export def AvgBy(
    Arg: any,
    groupBy: any,
    attr: string,
    aggrName = 'avg'
): list<dict<any>>
  var   aggrAvg: dict<dict<any>> = {}
  var   aggrCnt: dict<number> = {}
  const groupBy_: list<string> = Listify(groupBy)
  const Cont = IsFunc(Arg) ? Arg : From(Arg)

  Cont((t: dict<any>) => {
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
export def Rename(Arg: any, old: list<string>, new: list<string>): func(func(dict<any>))
  const Cont = From(Arg)

  return (Emit: func(dict<any>)) => {
    def RenameAttr(t: dict<any>)
      var i = 0
      var tnew = copy(t)
      while i < len(old)
        tnew[new[i]] = tnew[old[i]]
        tnew->remove(old[i])
        i += 1
      endwhile
      Emit(tnew)
    enddef

    Cont(RenameAttr)
  }
enddef

export def Select(Arg: any, Pred: func(dict<any>): bool): func(func(dict<any>))
  const Cont = From(Arg)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      if Pred(t)
        Emit(t)
      endif
    })
  }
enddef

export def Project(Arg: any, attrs: any): func(func(dict<any>))
  const Cont = From(Arg)
  const attrList = Listify(attrs)

  return (Emit: func(dict<any>)) => {
    var seen: dict<bool> = {}

    def Proj(t: dict<any>)
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

def MakeTupleMerger(prefix: string): func(dict<any>, dict<any>): dict<any>
  return (t: dict<any>, u: dict<any>): dict<any> => {
    var tnew: dict<any> = {}
    for attr in keys(t)
      const newAttr = u->has_key(attr) ? prefix .. attr : attr
      tnew[newAttr] = t[attr]
    endfor
    return tnew->extend(u, 'error')
  }
enddef

export def Join(
    Arg1: any, Arg2: any, Pred: func(dict<any>, dict<any>): bool, prefix = '_'
): func(func(dict<any>))
  const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      for u in rel
        if Pred(t, u)
          Emit(MergeTuples(t, u))
        endif
      endfor
    })
  }
enddef

export def EquiJoinPred(
    lftAttrList: list<string>, rgtAttrList: list<string> = null_list
): func(dict<any>, dict<any>): bool
  const n = len(lftAttrList)
  const rgt = rgtAttrList == null ? lftAttrList : rgtAttrList

  if n != len(rgt)
    throw ErrEquiJoinAttributes(lftAttrList, rgt)
  endif

  return (t: dict<any>, u: dict<any>): bool => {
    var i = 0
    while i < n
      if t[lftAttrList[i]] != u[rgt[i]]
        return false
      endif
      i += 1
    endwhile
    return true
  }
enddef

export def EquiJoin(
    Arg1: any, Arg2: any, lftAttrs: any, rgtAttrs: any, prefix = '_'
): func(func(dict<any>))
  const lftAttrList = Listify(lftAttrs)
  const rgtAttrList = Listify(rgtAttrs)

  if IsRel(Arg2) && rgtAttrList->IsKeyOf(Arg2) # Fast path
    const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
    const Cont = From(Arg1)
    const rel: Rel = Arg2

    return (Emit: func(dict<any>)) => {
      Cont((t: dict<any>) => {
        const u = rel.Lookup(rgtAttrList, Values(t, lftAttrList))
        if u isnot KEY_NOT_FOUND
          Emit(MergeTuples(t, u))
        endif
      })
    }
  endif

  const Pred = EquiJoinPred(lftAttrList, rgtAttrList)

  return Join(Arg1, Arg2, Pred, prefix)
enddef

def NatJoinPred(t: dict<any>, u: dict<any>): bool
  for a in keys(t)
    if u->has_key(a)
      if t[a] != u[a]
        return false
      endif
    endif
  endfor
  return true
enddef

export def NatJoin(Arg1: any, Arg2: any): func(func(dict<any>))
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      for u in rel
        if NatJoinPred(t, u)
          Emit(t->extendnew(u))
        endif
      endfor
    })
  }
enddef

export def Product(Arg1: any, Arg2: any, prefix = '_'): func(func(dict<any>))
  const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      for u in rel
        Emit(MergeTuples(t, u))
      endfor
    })
  }
enddef

export def Intersect(Arg1: any, Arg2: any): func(func(dict<any>))
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      for u in rel
        if t == u
          Emit(t)
          break
        endif
      endfor
    })
  }
enddef

export def Minus(Arg1: any, Arg2: any): func(func(dict<any>))
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      for u in rel
        if t == u
          return
        endif
      endfor
      Emit(t)
    })
  }
enddef

export def SemiJoin(Arg1: any, Arg2: any, Pred: func(dict<any>, dict<any>): bool): func(func(dict<any>))
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      for u in rel
        if Pred(t, u)
          Emit(t)
          return
        endif
      endfor
    })
  }
enddef

export def AntiJoin(Arg1: any, Arg2: any, Pred: func(dict<any>, dict<any>): bool): func(func(dict<any>))
  const rel  = Query(Arg2)
  const Cont = From(Arg1)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      for u in rel
        if Pred(t, u)
          return
        endif
      endfor
      Emit(t)
    })
  }
enddef

# See: C. Date & H. Darwen, Outer Join with No Nulls and Fewer Tears, Ch. 20,
# Relational Database Writings 1989–1991
export def LeftNatJoin(Arg1: any, Arg2: any, Filler: any): func(func(dict<any>))
  const rel    = Query(Arg2)
  const Cont   = From(Arg1)
  const filler = Query(Filler)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
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
  Arg1:     any,
  Arg2:     any,
  lftAttrs: any,
  rgtAttrs: any,
  Filler:   any,
  prefix = '_',
): func(func(dict<any>))
  const lftAttrList = Listify(lftAttrs)
  const rgtAttrList = Listify(rgtAttrs)
  const Cont        = From(Arg1)
  const filler      = Query(Filler)
  const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)

  if IsRel(Arg2) && rgtAttrList->IsKeyOf(Arg2) # Fast path
    const rel: Rel = Arg2

    return (Emit: func(dict<any>)) => {
      Cont((t: dict<any>) => {
        const u = rel.Lookup(rgtAttrList, Values(t, lftAttrList))
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
  const Pred = EquiJoinPred(lftAttrList, rgtAttrList)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
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

export def Extend(Arg: any, Fn: func(dict<any>): dict<any>): func(func(dict<any>))
  const Cont = From(Arg)

  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      Emit(Fn(t)->extend(t, 'error'))
    })
  }
enddef

# Inspired by the framing operator described in
# EF Codd, The Relational Model for Database Management: Version 2, 1990
export def Frame(
    Arg: any,
    attrs: any,
    name: string = 'fid'
): func(func(dict<any>))
  var fid = 0  # Frame identifier
  var seen: dict<number> = {}
  const attrList: list<string> = Listify(attrs)
  const Cont = From(Arg)

  return (Emit: func(dict<any>)) => {
    def FrameTuple(t: dict<any>)
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
    Arg: any,
    groupBy: any,
    AggregateFn: func(...any): any,
    aggrName = 'aggrValue'
): func(func(dict<any>))
  var   fid:      dict<list<dict<any>>> = PartitionBy(Arg, groupBy)
  const groupBy_: list<string>          = Listify(groupBy)

  return (Emit: func(dict<any>)) => {
    # Apply aggregate function to each subrelation
    for groupKey in keys(fid)
      const subrel = fid[groupKey]
      var t0: dict<any> = {}
      for attr in groupBy_
        t0[attr] = subrel[0][attr]
      endfor
      t0[aggrName] = Scan(subrel)->AggregateFn()
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
export def CoddDivide(Arg1: any, Arg2: any, divisorAttrList: list<string> = []): func(func(dict<any>))
  const r = Query(Arg1)

  if empty(r)
    return From(r)
  endif

  const s = Query(Arg2)

  if empty(s)
    const K = IsRel(Arg2)
      ? filter(keys(r[0]), (i, v) => index(AsRel(Arg2).attributes, v) == -1)
      : filter(keys(r[0]), (i, v) => index(divisorAttrList, v) == -1)
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
export def Divide(Arg1: any, Arg2: any): func(func(dict<any>))
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
def Aggregate(Arg: any, initValue: any, Fn: func(dict<any>, any): any): any
  const Cont = From(Arg)

  var Res: any = initValue
  Cont((t) => {
    Res = Fn(t, Res)
  })
  return Res
enddef

def ListAgg_(Arg: any, attr: string, How: any): list<any>
  var agg: list<any> = []
  const Cont = From(Arg)

  Cont((t) => {
    agg->add(t[attr])
  })

  return How == null ? agg : sort(agg, How)
enddef

export const ListAgg = Curry(ListAgg_)

def StringAgg_(Arg: any, attr: string, sep: string, How: any): string
  return ListAgg_(Arg, attr, How)->join(sep)
enddef

export const StringAgg = Curry(StringAgg_)

export def Count(Arg: any): number
  var count = 0
  const Cont = From(Arg)

  Cont((t) => {
    ++count
  })

  return count
enddef

def CountDistinct_(Arg: any, attr: string): number
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

def Max_(Arg: any, attr: string): any
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

def Min_(Arg: any, attr: string): any
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

def Sum_(Arg: any, attr: string): any
  return Aggregate(Arg, 0, (t, sum) => sum + t[attr])
enddef

export const Sum = Curry(Sum_)

def Avg_(Arg: any, attr: string): any
  var sum: float = 0.0
  var count = 0
  const Cont = From(Arg)

  Cont((t: dict<any>) => {
    sum += t[attr]
    ++count
  })
  return count == 0 ? null : sum / count
enddef

export const Avg = Curry(Avg_)
# }}}
# }}}

# Convenience functions {{{
# Compare two relation instances
export def In(t: dict<any>, R: any): bool
  return index(Instance(R), t) != -1
enddef

export def NotIn(t: dict<any>, R: any): bool
  return !(t->In(R))
enddef

export def Split(Arg: any, Pred: func(dict<any>): bool): list<list<dict<any>>>
  const Cont = From(Arg)
  var ok:  list<dict<any>> = []
  var tsk: list<dict<any>> = []

  Cont((t) => {
    if Pred(t)
      ok->add(t)
    else
      tsk->add(t)
    endif
  })

  return [ok, tsk]
enddef

export def PartitionBy(
    Arg: any,
    groupBy: any
): dict<list<dict<any>>>
  var   fid: dict<list<dict<any>>> = {}
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

export def Transform(Arg: any, F: func(dict<any>): any): list<any>
  const rel = Query(Arg)
  var result = []

  for t in rel
    const value = F(t)
    if type(value) == v:t_list
      result += value
    else
      result->add(value)
    endif
  endfor

  return result
enddef

def ExtendByMerging(d1: dict<any>, d2: dict<any>)
  for k in keys(d2)
    if !d1->has_key(k)
      d1[k] = []
    endif
    d1[k]->add(d2[k])
  endfor
enddef

export def DictTransform(
    Arg: any, F: func(dict<any>): dict<any>, flatten = false
): dict<any>
  const rel = Query(Arg)
  var result: dict<any> = {}

  for t in rel
    ExtendByMerging(result, F(t))
  endfor

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
export def Zip(l1: list<any>, l2: list<any>): dict<any>
  const n = len(l1)
  var zipdict: dict<any> = {}
  var i = 0
  while i < n
    zipdict[String(l1[i])] = l2[i]
    ++i
  endwhile
  return zipdict
enddef

export def RelEq(R: any, S: any): bool
  const rel1: list<dict<any>> = Instance(R)
  const rel2: list<dict<any>> = Instance(S)
  return sort(copy(rel1)) == sort(copy(rel2))
enddef

# Returns a textual representation of a relation
export def Table(R: any, columns: any = null, name = null_string, sep = '─'): string
  if strchars(sep) != 1
    throw printf("A table separator must be a single character. Got %s", sep)
  endif

  var rel: list<dict<any>>
  var relname: string

  if IsRel(R)
    rel = AsRel(R).instance
    relname = empty(name) ? AsRel(R).name : name
  else
    rel = R
    relname = name
  endif

  if empty(rel)
    return printf(" %s\n%s\n", relname, repeat(sep, 2 + strwidth(relname)))
  endif

  const attributes: list<string> = columns == null ? keys(rel[0]) : Listify(columns)
  var width: dict<number> = {}

  for attr in attributes
    width[attr] = 1 + strwidth(attr)
  endfor

  # Determine the maximum width for each column
  for t in rel
    for attr in attributes
      const ll = 1 + strwidth(String(t[attr]))
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

  def FmtTuple(t: dict<any>): string
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
