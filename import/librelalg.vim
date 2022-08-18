vim9script

# Error messages {{{
def ErrEquiJoinAttributes(attrList: list<string>, otherList: list<string>): string
  return printf("Join on lists of attributes of different length: %s vs %s", attrList, otherList)
enddef

def ErrIncompatibleTuple(t: dict<any>, schema: dict<number>): string
  const schemaStr = SchemaAsString(schema)
  return printf("Expected a tuple on schema %s: got %s instead", schemaStr, t)
enddef

def ErrAttributeType(t: dict<any>, schema: dict<number>, attr: string): string
  const value = t[attr]
  const wrongType = TypeName(type(value))
  const rightType = TypeName(schema[attr])
  return printf("Attribute %s is of type %s, but value '%s' of type %s was provided",
                attr, rightType, value, wrongType)
enddef

def ErrDuplicateKey(key: list<string>, t: dict<any>): string
  const tStr = join(mapnew(key, (_, v) => string(t[v])), ', ')
  return printf('Duplicate key value: %s = (%s) already exists', key, tStr)
enddef

def ErrForeignKeyTarget(relname: string, key: list<string>): string
  return printf("Wrong foreign key: %s is not a key of relation %s", key, relname)
enddef

def ErrForeignKeySource(relname: string, key: list<string>, attrList: list<string>): string
  return printf("Wrong foreign key: %s -> %s(%s)", attrList, relname, key)
enddef

def ErrForeignKey(relname: string, key: list<string>, t: dict<any>, attrList: list<string>): string
  const tStr = join(mapnew(attrList, (_, v) => string(t[v])), ', ')
  return printf('Foreign key error: %s = (%s) is not present in %s', key, tStr, relname)
enddef

# }}}

# Helper functions {{{
# string() turns 'A' into a string of length 3, with quotes.
# We may not want that.
def String(value: any): string
  return type(value) == v:t_string ? value : string(value)
enddef

# v1 and v2 must have the same type
def CompareValues(v1: any, v2: any): number
  if v1 == v2
    return 0
  endif
  if type(v1) == v:t_bool # Only true/false (none is not allowed)
    return v1 && !v2 ? 1 : -1
  else
    return v1 > v2 ? 1 : -1
  endif
enddef

def CompareTuples(t: dict<any>, u: dict<any>, listAttr: list<string>): number
  for a in listAttr
    const cmp = CompareValues(t[a], u[a])
    if cmp == 0
      continue
    endif
    return cmp
  endfor
  return 0
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

# type Attr         string
# type Tuple        dict<any>
# type Rel          list<Tuple>
# type Consumer     func(Tuple): void
# type Continuation func(Consumer): void

# Operators requiring a materialized relation as input {{{
export def Scan(rel: list<dict<any>>): func(func(dict<any>))
  return (Emit: func(dict<any>)) => {
    for t in rel
      Emit(t)
    endfor
  }
enddef

export def Foreach(rel: list<dict<any>>): func(func(dict<any>))
  return Scan(rel)
enddef

export def SortPred(rel: list<dict<any>>, ComparisonFn: func(dict<any>, dict<any>): number): list<dict<any>>
  return sort(copy(rel), ComparisonFn)
enddef

export def SortedPredScan(rel: list<dict<any>>, ComparisonFn: func(dict<any>, dict<any>): number): func(func(dict<any>))
  return SortPred(rel, ComparisonFn)->Scan()
enddef

export def Sort(rel: list<dict<any>>, listAttr: list<string>): list<dict<any>>
  const SortAttrPred = (t: dict<any>, u: dict<any>): number => CompareTuples(t, u, listAttr)
  return SortPred(rel, SortAttrPred)
enddef

export def SortedScan(rel: list<dict<any>>, listAttr: list<string>): func(func(dict<any>))
  return Sort(rel, listAttr)->Scan()
enddef

export def GroupBy(rel: list<dict<any>>, attrList: list<string>, AggregateFn: func(func(func(dict<any>))): any, aggrName = 'AggregateValue'): func(func(dict<any>))
  return (Emit: func(dict<any>)) => {
    var fid: dict<list<dict<any>>> = {}

    # Split into subrelations
    for t in rel
      const groupValue = mapnew(attrList, (_, attr) => t[attr])
      const groupKey = String(groupValue)
      if !fid->has_key(groupKey)
        fid[groupKey] = []
      endif
      fid[groupKey]->add(t)
    endfor

    # Apply aggregate function to each subrelation
    for groupKey in keys(fid)
      const subrel = fid[groupKey]
      var t0: dict<any> = {}
      for attr in attrList
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
export def Divide(r: list<dict<any>>, s: list<dict<any>>): func(func(dict<any>))
  if empty(r) || empty(s)
    return Scan(r)
  endif
  const attrS = keys(s[0])
  const K = filter(keys(r[0]), (i, v) => index(attrS, v) == -1)
  const r1 = Scan(r)->Project(K)->Materialize()
  const s1 = Scan(s)->Product(r1)->Minus(r)->Project(K)->Materialize()
  return Scan(r1)->Minus(s1)
enddef
# }}}

# Operators materializing their input {{{
export def Materialize(Cont: func(func(dict<any>))): list<dict<any>>
  var rel: list<dict<any>> = []
  Cont((t) => {
      add(rel, t)
  })
  return rel
enddef

export def Query(Cont: func(func(dict<any>))): list<dict<any>>
  return Materialize(Cont)
enddef
# }}}

# Pipeline operators {{{
export def Noop(Cont: func(func(dict<any>))): func(func(dict<any>))
  return (Emit: func(dict<any>)) => {
    Cont(Emit)
  }
enddef

export def Rename(Cont: func(func(dict<any>)), old: list<string>, new: list<string>): func(func(dict<any>))
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

export def Select(Cont: func(func(dict<any>)), Pred: func(dict<any>): bool): func(func(dict<any>))
  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      if Pred(t)
        Emit(t)
      endif
    })
  }
enddef

export def Project(Cont: func(func(dict<any>)), attrList: list<string>): func(func(dict<any>))
  return (Emit: func(dict<any>)) => {
    var seen: dict<bool> = {}
    def Proj(t: dict<any>)
      var u = {}
      for attr in attrList
        u[attr] = t[attr]
      endfor
      if !seen->has_key(String(u))
        seen[String(u)] = true
        Emit(u)
      endif
    enddef
    Cont((t) => Proj(t))
  }
enddef

export def Join(Cont: func(func(dict<any>)), rel: list<dict<any>>, Pred: func(dict<any>, dict<any>): bool, prefix = ''): func(func(dict<any>))
  var MergeTuples: func(dict<any>, dict<any>): dict<any>
  if empty(prefix)
    MergeTuples = (t: dict<any>, u: dict<any>): dict<any> => t->extendnew(u, 'error')
  else
    MergeTuples = (t: dict<any>, u: dict<any>): dict<any> => {
      var unew: dict<any> = {}
      for attr in keys(u)
        unew[prefix .. attr] = u[attr]
      endfor
      return unew->extend(t, 'error')
    }
  endif

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

def NatJoinCheck(t: dict<any>, u: dict<any>): bool
  for a in keys(t)
    if u->has_key(a)
      if t[a] != u[a]
        return false
      endif
    endif
  endfor
  return true
enddef

export def NatJoin(Cont: func(func(dict<any>)), rel: list<dict<any>>): func(func(dict<any>))
  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      for u in rel
        if NatJoinCheck(t, u)
          Emit(t->extendnew(u))
        endif
      endfor
    })
  }
enddef

export def Product(Cont: func(func(dict<any>)), rel: list<dict<any>>, prefix = ''): func(func(dict<any>))
  return Join(Cont, rel, (t, u) => true, prefix)
enddef

export def Intersect(Cont: func(func(dict<any>)), rel: list<dict<any>>): func(func(dict<any>))
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

export def Minus(Cont: func(func(dict<any>)), rel: list<dict<any>>): func(func(dict<any>))
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

export def SemiJoin(Cont: func(func(dict<any>)), rel: list<dict<any>>, Pred: func(dict<any>, dict<any>): bool): func(func(dict<any>))
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

export def AntiJoin(Cont: func(func(dict<any>)), rel: list<dict<any>>, Pred: func(dict<any>, dict<any>): bool): func(func(dict<any>))
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
# }}}

# Aggregate functions {{{
def Aggregate(Cont: func(func(dict<any>)), Init: func(): any, Fn: func(dict<any>, any): any): any
  var Res: any = Init()
  Cont((t) => {
    Res = Fn(t, Res)
  })
  return Res
enddef

export def Max(Cont: func(func(dict<any>)), attr: string): any
  def Fn(t: dict<any>, v: any): any
    return type(v) == v:t_none ? t[attr] : CompareValues(t[attr], v) == 1 ? t[attr] : v
  enddef
  return Aggregate(Cont, () => v:none, Fn)
enddef

export def Min(Cont: func(func(dict<any>)), attr: string): any
  def Fn(t: dict<any>, v: any): any
    return type(v) == v:t_none ? t[attr] : CompareValues(t[attr], v) == -1 ? t[attr] : v
  enddef
  return Aggregate(Cont, () => v:none, Fn)
enddef

export def Count(Cont: func(func(dict<any>))): any
  def Fn(t: dict<any>, v: any): any
    return v + 1
  enddef
  return Aggregate(Cont, () => 0, Fn)
enddef

export def Sum(Cont: func(func(dict<any>)), attr: string): any
  def Fn(t: dict<any>, v: any): any
    return type(v) == v:t_none ? t[attr] : t[attr] + v
  enddef
  return Aggregate(Cont, () => v:none, Fn)
enddef
# }}}
# }}}

# Data manipulation {{{
# type TType        number
# type TTupleSchema dict<TType>
# type TRelSchema   dict<any>
# type TKey         list<TAttr>
# type TConstraint  func(Tuple): void
# type TIndex       dict<any>

# Data types supported in relations
export const Int     = v:t_number
export const Str     = v:t_string
export const Bool    = v:t_bool
export const Float   = v:t_float

const TypeString = {
  [Int]:         'integer',
  [Str]:         'string',
  [Float]:       'float',
  [Bool]:        'boolean',
  [v:t_func]:    'funcref',
  [v:t_list]:    'list',
  [v:t_dict]:    'dictionary',
  [v:t_none]:    'none',
  [v:t_job]:     'job',
  [v:t_channel]: 'channel',
  [v:t_blob]:    'blob'
}

# Indexes {{{
def MakeIndex(key: list<string>): dict<any>
  return {key: copy(key), data: {}}
enddef

def AddKey(index: dict<any>, t: dict<any>, rowNumber: number): void
  const key = index.key

  if len(key) == 0
    index.row = rowNumber
    return
  endif

  const value = t[key[0]]

  if !index.data->has_key(String(value))
    index.data[value] = MakeIndex(key[1 : ])
  endif

  index.data[value]->AddKey(t, rowNumber)
enddef

# Search for a tuple in R with the same key as t using an index
def SearchKey(index: dict<any>, t: dict<any>, alias = index.key): number
  const key = index.key

  if empty(key)
    return index->has_key('row') ? index.row : -1
  endif

  const value = t[alias[0]]

  if !index.data->has_key(String(value))
    return -1
  endif

  return index.data[value]->SearchKey(t, alias[1 : ])
enddef
# }}}

def SchemaToString(schema: dict<number>): string
  const schemaStr = mapnew(schema, (attr, atype): string => printf("%s: %s", attr, TypeString[atype]))
  return '{' .. join(values(schemaStr), ', ') .. '}'
enddef

def TypeName(atype: number): string
  return get(TypeString, atype, 'unknown')
enddef

def SchemaAsString(schema: dict<number>): string
  const schemaStr = mapnew(schema, (attr, atype): string => printf("%s: %s", attr, TypeName(atype)))
  return '{' .. join(values(schemaStr), ', ') .. '}'
enddef

# A type constraint checks whether a tuple is compatible with a schema.
#
# schema [TTupleSchema]: a tuple schema
#
# Return type: TConstraint
def TypeConstraint(schema: dict<number>): func(dict<any>): void
  return (t: dict<any>): void => {
    if sort(keys(schema)) != sort(keys(t))
      throw ErrIncompatibleTuple(t, schema)
    endif

    for [attr, atype] in items(schema)
      if type(t[attr]) != atype
        throw ErrAttributeType(t, schema, attr)
      endif
    endfor
  }
enddef

# A key constraint prevents duplicate keys
#
# key [TKey]: a list of attributes that form a key for a certain relation
# R   [TRelSchema]: a relational schema
export def KeyConstraint(key: list<string>, index: dict<any>): func(dict<any>): void
  const keyStr = string(key)

  return (t: dict<any>): void => {
    if index->SearchKey(t) != -1
      throw ErrDuplicateKey(key, t)
    endif
  }
enddef

export def ForeignKeyConstraint(R: dict<any>, key: list<string>, attrList = key): func
  if len(key) != len(attrList)
    throw ErrForeignKeySource(R.name, key, attrList)
  endif

  if index(R.keys, key) == -1
    throw ErrForeignKeyTarget(R.name, key)
  endif

  const keyStr = string(key)

  return (t: dict<any>): void => {
    if R.indexes[keyStr]->SearchKey(t, attrList) == -1
      throw ErrForeignKey(R.name, key, t, attrList)
    endif
  }
enddef


export def Relation(name: string, schema: dict<number>, keys: list<list<string>>, constraints: list<func> = [], checkType = true): dict<any>
  final indexes: any = {}
  final integrity_constraints: list<func> = []

  if checkType
    integrity_constraints->add(TypeConstraint(schema))
  endif

  for key in keys
    const skey = string(key)
    indexes[skey] = MakeIndex(key)
    integrity_constraints->add(KeyConstraint(key, indexes[skey]))
  endfor

  for OtherConstraint in constraints
    integrity_constraints->add(OtherConstraint)
  endfor

  return {
    name:        name,
    schema:      schema,
    instance:    [],
    keys:        keys,
    indexes:     indexes,
    constraints: integrity_constraints
  }
enddef

export def Insert(R: dict<any>, t: dict<any>): number
  # Check constraints
  for CheckConstraint in R.constraints
    CheckConstraint(t)
  endfor

  # Insert
  R.instance->add(t)
  const rowNumber = len(R.instance) - 1

  # Update indexes
  for key in R.keys
    const index = R.indexes[string(key)]
    index->AddKey(t, rowNumber)
  endfor

  return rowNumber
enddef

export def InsertMany(R: dict<any>, tuples: list<dict<any>>): number
  for t in tuples
    Insert(R, t)
  endfor
  return len(tuples)
enddef

export def Delete(R: dict<any>, Pred: func(dict<any>): bool): void
  R.instance->filter((_, v) => !Pred(v))
  # FIXME: update/rebuild the indexes!
enddef
# }}}

# Convenience functions {{{
# Compare two relation instances
export def RelEq(r: list<dict<any>>, s: list<dict<any>>): bool
  return sort(copy(r)) == sort(copy(s))
enddef

# Returns a textual representation of a relation instance
export def Table(rel: list<dict<any>>, name = 'Relation'): string
  if empty(rel)
    return printf("%s\n%s\n", name, repeat('-', len(name)))
  endif

  const attributes = keys(rel[0])
  var width: list<number> = []
  var totalWidth = 0

  # Determine the maximum width for each column
  for attr in attributes
    width->add(len(attr))
    for t in rel
      const value = t[attr]
      if type(value) != v:t_none
        if width[-1] < len(String(value))
          width[-1] = len(String(value))
        endif
      endif
    endfor
    totalWidth += width[-1]
  endfor

  # Pretty print
  var table = printf("%s\n%s\n", name, repeat('-', totalWidth))
  table ..= join(mapnew(attributes, (i, a) => printf('%' .. width[i] .. 's', a)))
  table ..= "\n"

  for t in rel
    table ..= join(mapnew(values(t), (i, v) => printf('%' .. width[i] .. 's', String(v))))
    table ..= "\n"
  endfor

  return table
enddef
# }}}

