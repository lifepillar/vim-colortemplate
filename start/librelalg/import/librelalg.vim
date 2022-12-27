vim9script

# Helper functions {{{
# string() turns 'A' into a string of length 3, with quotes.
# We do not want that.
def String(value: any): string
  return type(value) == v:t_string ? value : string(value)
enddef

def SchemaAsString(schema: dict<number>): string
  const schemaStr = mapnew(schema, (attr, atype): string => printf("%s: %s", attr, TypeName(atype)))
  return '{' .. join(values(schemaStr), ', ') .. '}'
enddef

def IsRelationInstance(R: any): bool
  return type(R) == v:t_list
enddef

export def In(t: dict<any>, R: any): bool
  const rel = IsRelationInstance(R) ? R : R.instance
  return index(rel, t) != -1
enddef

export def NotIn(t: dict<any>, R: any): bool
  return !(t->In(R))
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
  # TODO: compare performance with copy(t) + remove(dict, key)
  var u = {}
  for attr in attrList
    u[attr] = t[attr]
  endfor
  return u
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
export def Scan(R: any): func(func(dict<any>))
  const rel = IsRelationInstance(R) ? R : R.instance

  return (Emit: func(dict<any>)) => {
    for t in rel
      Emit(t)
    endfor
  }
enddef

export def Foreach(R: any): func(func(dict<any>))
  return Scan(R)
enddef

export def FilteredScan(R: any, Pred: func(dict<any>): bool): func(func(dict<any>))
  var rel = copy(IsRelationInstance(R) ? R : R.instance)

  filter(rel, (_, t) => Pred(t))

  return (Emit: func(dict<any>)) => {
    for t in rel
      Emit(t)
    endfor
  }
enddef

export def LimitScan(R: any, n: number): func(func(dict<any>))
  var rel = copy(IsRelationInstance(R) ? R : R.instance)
  var i = 0

  return (Emit: func(dict<any>)) => {
    for t in rel
      if i < n
        Emit(t)
        i += 1
      else
        break
      endif
    endfor
  }
enddef
# }}}

# Leaf operators (returning a relation) {{{
export def Build(Cont: func(func(dict<any>))): list<dict<any>>
  var rel: list<dict<any>> = []
  Cont((t) => {
      add(rel, t)
  })
  return rel
enddef

export def Query(Cont: func(func(dict<any>))): list<dict<any>>
  return Build(Cont)
enddef

export def Materialize(Cont: func(func(dict<any>))): list<dict<any>>
  return Build(Cont)
enddef

export def Sort(Cont: func(func(dict<any>)), ComparisonFn: func(dict<any>, dict<any>): number): list<dict<any>>
  var rel = Materialize(Cont)
  return sort(rel, ComparisonFn)
enddef

export def SortBy(Cont: func(func(dict<any>)), attrList: list<string>, opts: list<string> = []): list<dict<any>>
  const invert: list<bool> = mapnew(opts, (_, v) => v == 'd')
  const SortAttrPred = (t: dict<any>, u: dict<any>): number => CompareTuples(t, u, attrList, invert)
  return Sort(Cont, SortAttrPred)
enddef

export def SumBy(
    Cont: func(func(dict<any>)),
    groupBy: list<string>,
    attr: string,
    aggrName = 'sum'
): list<dict<any>>
  var aggr: dict<dict<any>> = {}  # Map group => tuple

  Cont((t: dict<any>) => {
    var tp = ProjectTuple(t, groupBy)
    const group = String(values(tp))
    if !aggr->has_key(group)
      aggr[group] = tp->extend({[aggrName]: 0})
    endif
    aggr[group][aggrName] += t[attr]
  })

  return empty(groupBy) && empty(aggr) ? [{[aggrName]: 0}] : values(aggr)
enddef

export def CountBy(
    Cont: func(func(dict<any>)),
    groupBy: list<string>,
    attr: string = null_string,
    aggrName = 'count'
): list<dict<any>>
  var aggrCount: dict<dict<any>> = {}
  var aggrDistinct: dict<dict<bool>> = {}

  Cont((t: dict<any>) => {
    var tp = ProjectTuple(t, groupBy)
    const group = String(values(tp))
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

  return empty(groupBy) && empty(aggrCount) ? [{[aggrName]: 0}] : values(aggrCount)
enddef

export def MaxBy(
    Cont: func(func(dict<any>)),
    groupBy: list<string>,
    attr: string,
    aggrName = 'max'
): list<dict<any>>
  var aggr: dict<dict<any>> = {}  # Map group => tuple

  Cont((t: dict<any>) => {
    var tp = ProjectTuple(t, groupBy)
    const group = String(values(tp))
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
    Cont: func(func(dict<any>)),
    groupBy: list<string>,
    attr: string,
    aggrName = 'min'
): list<dict<any>>
  var aggr: dict<dict<any>> = {}  # Map group => tuple

  Cont((t: dict<any>) => {
    var tp = ProjectTuple(t, groupBy)
    const group = String(values(tp))
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
    Cont: func(func(dict<any>)),
    groupBy: list<string>,
    attr: string,
    aggrName = 'avg'
): list<dict<any>>
  var aggrAvg: dict<dict<any>> = {}
  var aggrCnt: dict<number> = {}

  Cont((t: dict<any>) => {
    var tp = ProjectTuple(t, groupBy)
    const group = String(values(tp))
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
  var seen: dict<bool> = {}

  return (Emit: func(dict<any>)) => {
    def Proj(t: dict<any>)
      var u = ProjectTuple(t, attrList)
      if !seen->has_key(String(u))
        seen[String(u)] = true
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
      tnew[prefix .. attr] = t[attr]
    endfor
    return tnew->extend(u, 'error')
  }
enddef

export def Join(Cont: func(func(dict<any>)), R: any, Pred: func(dict<any>, dict<any>): bool, prefix = ''): func(func(dict<any>))
  const MergeTuples = empty(prefix) ? (t, u) => t->extendnew(u, 'error') : MakeTupleMerger(prefix)
  const rel = IsRelationInstance(R) ? R : R.instance

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

export def EquiJoinPred(lftAttrList: list<string>, rgtAttrList: list<string>): func(dict<any>, dict<any>): bool
  const n = len(lftAttrList)

  if n != len(rgtAttrList)
    throw ErrEquiJoinAttributes(lftAttrList, rgtAttrList)
  endif

  return (t: dict<any>, u: dict<any>): bool => {
    var i = 0
    while i < n
      if t[lftAttrList[i]] != u[rgtAttrList[i]]
        return false
      endif
      i += 1
    endwhile
    return true
  }
enddef

export def EquiJoin(Cont: func(func(dict<any>)), R: any, lftAttrList: list<string>, rgtAttrList: list<string>, prefix = ''): func(func(dict<any>))
  return Join(Cont, R, EquiJoinPred(lftAttrList, rgtAttrList), prefix)
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

export def NatJoin(Cont: func(func(dict<any>)), R: any): func(func(dict<any>))
  const rel = IsRelationInstance(R) ? R : R.instance

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

export def Product(Cont: func(func(dict<any>)), R: any, prefix = ''): func(func(dict<any>))
  return Join(Cont, R, (t, u) => true, prefix)
enddef

export def Intersect(Cont: func(func(dict<any>)), R: any): func(func(dict<any>))
  const rel = IsRelationInstance(R) ? R : R.instance

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

# TODO: check if materializing + sort() + uniq() is more performant
export def Union(Cont: func(func(dict<any>)), R: any): func(func(dict<any>))
  const rel = IsRelationInstance(R) ? R : R.instance

  return (Emit: func(dict<any>)) => {
    for t in rel
      Emit(t)
    endfor

    Cont((t: dict<any>) => {
      if t->NotIn(rel)
        Emit(t)
      endif
    })
  }
enddef

export def Minus(Cont: func(func(dict<any>)), R: any): func(func(dict<any>))
  const rel = IsRelationInstance(R) ? R : R.instance

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

export def SemiJoin(Cont: func(func(dict<any>)), R: any, Pred: func(dict<any>, dict<any>): bool): func(func(dict<any>))
  const rel = IsRelationInstance(R) ? R : R.instance

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

export def AntiJoin(Cont: func(func(dict<any>)), R: any, Pred: func(dict<any>, dict<any>): bool): func(func(dict<any>))
  const rel = IsRelationInstance(R) ? R : R.instance

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
export def LeftNatJoin(
    Cont: func(func(dict<any>)),
    R: any,
    Filler: any  # TODO: extend with a fn depending of t instead?
): func(func(dict<any>))
  const rel    = IsRelationInstance(R)      ? R      : R.instance
  const filler = IsRelationInstance(Filler) ? Filler : Filler.instance

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

export def Extend(Cont: func(func(dict<any>)), Fn: func(dict<any>): dict<any>): func(func(dict<any>))
  return (Emit: func(dict<any>)) => {
    Cont((t: dict<any>) => {
      Emit(Fn(t)->extend(t, 'error'))
    })
  }
enddef

# Inspired by the framing operator described in
# EF Codd, The Relational Model for Database Management: Version 2, 1990
export def Frame(Cont: func(func(dict<any>)), attrList: list<string>, name: string = 'fid'): func(func(dict<any>))
  var fid = 0  # Frame identifier
  var seen: dict<number> = {}

  return (Emit: func(dict<any>)) => {
    def FrameTuple(t: dict<any>)
      const groupby = String(ProjectTuple(t, attrList))
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
    Cont: func(func(dict<any>)),
    groupBy: list<string>,
    AggregateFn: func(func(func(dict<any>))): any,
    aggrName = 'aggrValue'
): func(func(dict<any>))
  var fid: dict<list<dict<any>>> = {}

  Cont((t) => {
    # Materialize into subrelations
    const groupValue = mapnew(groupBy, (_, attr) => t[attr])
    const groupKey = String(groupValue)
    if !fid->has_key(groupKey)
      fid[groupKey] = []
    endif
    fid[groupKey]->add(t)
  })

  return (Emit: func(dict<any>)) => {
    # Apply aggregate function to each subrelation
    for groupKey in keys(fid)
      const subrel = fid[groupKey]
      var t0: dict<any> = {}
      for attr in groupBy
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
export def Divide(Cont: func(func(dict<any>)), S: any): func(func(dict<any>))
  const s = IsRelationInstance(S) ? S : S.instance

  if empty(s)
    # FIXME: this is not defined on the right schema!
    return Cont
  endif

  var r = Materialize(Cont)

  if empty(r)
    return Scan(r)
  endif

  const attrS = keys(s[0])
  const K = filter(keys(r[0]), (i, v) => index(attrS, v) == -1)
  # TODO: optimize (r1 does not need to be materialized)
  const r1 = Scan(r)->Project(K)->Materialize()
  const s1 = Scan(s)->Product(r1)->Minus(r)->Project(K)->Materialize()
  return Scan(r1)->Minus(s1)
enddef

# See: C. Date & H. Darwen, Ch 11, Into the Great Divide,
# Relational Database Writings 1989–1991.
export def ToddDivide(Cont: func(func(dict<any>)), S: any): func(func(dict<any>))
  const s = IsRelationInstance(S) ? S : S.instance

  if empty(s)
    # TODO: Return Scan(s) or throw ErrDivideByZero()?
    throw 'Error: Todd division by empty relation'
  endif

  var r = Materialize(Cont)

  if empty(r)
    return Scan(r)
  endif

  const attrS = keys(s[0])
  const attrR = keys(r[0])
  const X = filter(keys(r[0]), (_, v) => index(attrS, v) == -1)
  const Z = filter(keys(s[0]), (_, v) => index(attrR, v) == -1)
  const t1 = Scan(r)->Project(X)->Materialize()
  const t2 = Scan(s)->Project(Z)->Materialize()
  const t3 = Scan(t1)->Product(t2)->Materialize()
  const t4 = Scan(t1)->Product(s)->Materialize()
  const t5 = Scan(r)->NatJoin(s)->Materialize()
  const t6 = Scan(t4)->Minus(t5)->Materialize()
  const t7 = Scan(t6)->Project(flattennew([X, Z]))->Materialize()
  return Scan(t3)->Minus(t7)
enddef
# }}}

# Aggregate functions {{{
def Aggregate(Cont: func(func(dict<any>)), initValue: any, Fn: func(dict<any>, any): any): any
  var Res: any = initValue
  Cont((t) => {
    Res = Fn(t, Res)
  })
  return Res
enddef

export def Bind(AggrFn: func(func(func(dict<any>)): void, string): any, attr: string): func(func(func(dict<any>))): any
  return (Cont: func(func(dict<any>)): void) => AggrFn(Cont, attr)
enddef

export def Count(Cont: func(func(dict<any>))): number
  var count = 0
  Cont((t) => {
    ++count
  })
  return count
enddef

export def Max(Cont: func(func(dict<any>)), attr: string): any
  var first = true
  var max: any = null
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

export def Min(Cont: func(func(dict<any>)), attr: string): any
  var first = true
  var min: any = null
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

export def Sum(Cont: func(func(dict<any>)), attr: string): any
  return Aggregate(Cont, 0, (t, sum) => sum + t[attr])
enddef

export def Avg(Cont: func(func(dict<any>)), attr: string): any
  var sum: float = 0.0
  var count = 0
  Cont((t: dict<float>) => {
    sum += t[attr]
    ++count
  })
  return count == 0 ? null : sum / count
enddef
# }}}
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

const TypeString = {
  [Int]:         'integer',
  [Str]:         'string',
  [Float]:       'float',
  [Bool]:        'boolean',
  [Func]:        'funcref',
  [v:t_list]:    'list',
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

def ErrReferentialIntegrity(rname: string, fkey: list<string>, sname: string, key: list<string>, t: dict<any>, verbphrase: string): string
  const tStr = join(mapnew(fkey, (_, v) => string(t[v])), ', ')
  return printf("%s %s %s: %s%s = (%s) is not present in %s%s",
                sname, verbphrase, rname, rname, fkey, tStr, sname, key)
enddef

def ErrReferentialIntegrityDeletion(child: string, fkey: list<string>, parent: string, key: list<string>, t_c: dict<any>, t_p: dict<any>, verbphrase: string): string
  const keyVal  = join(mapnew(key,  (_, v) => string(t_p[v])), ', ')
  return printf("%s %s %s: %s%s = (%s) is referenced by %s in %s%s",
                parent, verbphrase, child, parent, key, keyVal, t_c, child, fkey)
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
def AddKey(index: dict<any>, key: list<string>, t: dict<any>): void
  if empty(key)
    index[''] = t
    return
  endif
  AddKey_(index, key, 0, t)
enddef

def AddKey_(index: dict<any>, key: list<string>, i: number, t: dict<any>): void
  const value = t[key[i]]

  if i + 1 == len(key)
    index[value] = t
    return
  endif

  if !index->has_key(String(value))
    index[value] = {}
  endif

  index[value]->AddKey_(key, i + 1, t)
enddef

export const KEY_NOT_FOUND: dict<bool> = {}

# Search for a tuple in R with the same key as t using an index
def SearchKey(index: dict<any>, key: list<string>, t: dict<any>): dict<any>
  if empty(key)
    return empty(index) ? KEY_NOT_FOUND : index['']
  endif
  return SearchKey_(index, key, 0, t)
enddef

def SearchKey_(index: dict<any>, key: list<string>, i: number, t: dict<any>): dict<any>
  const value = t[key[i]]

  if index->has_key(String(value))
    return i + 1 == len(key) ? index[value] : index[value]->SearchKey_(key, i + 1, t)
  endif

  return KEY_NOT_FOUND
enddef

def RemoveKey(index: dict<any>, key: list<string>, t: dict<any>): void
  if empty(key)
    index->remove('')
    return
  endif
  RemoveKey_(index, key, 0, t)
enddef

def RemoveKey_(index: dict<any>, key: list<string>, i: number, t: dict<any>): void
  const value = t[key[i]]

  if i + 1 == len(key)
    index->remove(value)
    return
  endif

  index[value]->RemoveKey_(key, i + 1, t)

  if empty(index[value])
    index->remove(value)
  endif
enddef

export def Lookup(R: dict<any>, key: list<string>, value: list<any>): dict<any>
  if index(R.keys, key) == -1
    throw ErrNotAKey(R.name, key)
  endif
  const index = R.indexes[String(key)]
  return SearchKey(index, key, Zip(key, value))
enddef
# }}}

# Integrity constraints {{{
def SameSize(l1: any, l2: any, errMsg: string): void
  if len(l1) != len(l2)
    throw errMsg
  endif
enddef

# A type constraint checks whether a tuple is compatible with a schema.
#
# R  [TRelSchema]: a relational schema
def TypeCheck(R: dict<any>): void
  const Constraint = (t: dict<any>): void => {
    const schema = R.schema

    if sort(keys(schema)) != sort(keys(t))
      throw ErrIncompatibleTuple(t, schema)
    endif

    for [attr, atype] in items(schema)
      if type(t[attr]) != atype
        throw ErrAttributeType(t, schema, attr)
      endif
    endfor
  }

  R.constraints.I->add(Constraint)
  R.constraints.U->add(Constraint)
enddef

# A key constraint prevents duplicate keys
#
# R   [TRelSchema]: a relational schema
# key [TKey]: a list of attributes that form a key for a certain relation
export def Key(R: dict<any>, key: list<string>): void
  if index(R.keys, key) != -1
    throw ErrKeyAlreadyDefined(R.name, key)
  endif

  const attributes = Attributes(R)

  for keyAttr in key
    if index(attributes, keyAttr) == -1
      throw ErrInvalidAttribute(R.name, keyAttr)
    endif
  endfor

  R.keys->add(key)

  var index = {}

  R.indexes[string(key)] = index

  const K = (t: dict<any>): void => {
    if index->SearchKey(key, t) is KEY_NOT_FOUND
      return
    endif
    throw ErrDuplicateKey(key, t)
  }

  R.constraints.I->add(K)
enddef

def Conforms(attrList: list<string>, R: dict<any>, errMsg: string): void
  const schema = Attributes(R)
  for attr in attrList
    if index(schema, attr) == -1
      throw printf(errMsg, attr)
    endif
  endfor
enddef

def HasKey(R: dict<any>, key: list<string>, errMsg: string): void
  if index(R.keys, key) == -1
    throw errMsg
  endif
enddef

# Define a foreign key from Child[fkey] to Parent[key].
export def ForeignKey(
  Child: dict<any>,
  fkey: list<string>,
  Parent: dict<any>,
  key: list<string>,
  verbphrase = 'has'
): void
  fkey->SameSize(key,     ErrForeignKeySize(Child.name, fkey, Parent.name, key))
  fkey->Conforms(Child, ErrForeignKeySource(Child.name, fkey, Parent.name, key))
  Parent->HasKey(key,   ErrForeignKeyTarget(Child.name, fkey, Parent.name, key))

  const index = Parent.indexes[string(key)]
  const FkCheck = (t: dict<any>): void => {
    if index->SearchKey(fkey, t) is KEY_NOT_FOUND
      throw ErrReferentialIntegrity(Child.name, fkey, Parent.name, key, t, verbphrase)
    endif
  }

  Child.constraints.I->add(FkCheck)
  Child.constraints.U->add(FkCheck)

  const FkPred = EquiJoinPred(fkey, key)

  const DelCheck = (t_p: dict<any>): void => {
    for t_c in Child.instance
      if FkPred(t_c, t_p)
        throw ErrReferentialIntegrityDeletion(Child.name, fkey, Parent.name, key, t_c, t_p, verbphrase)
      endif
    endfor
  }

  Parent.constraints.D->add(DelCheck)
enddef

# Generic constraint
export def Check(
    R: dict<any>,
    Constraint: func(dict<any>): bool,
    msg: string,
    opList: list<string> = ['I', 'U']
): void
  for op in opList
    if index(['I', 'U', 'D'], op) == -1
      throw ErrInvalidConstraintClause(op)
    endif

    R.constraints[op]->add(
      (t: dict<any>): void => {
        if !Constraint(t)
          throw ErrConstraintNotSatisfied(R.name, t, msg)
        endif
      }
    )
  endfor
enddef
# }}}

export def Relation(
  name: string,
  schema: dict<number>,
  keys: list<list<string>>,
  checkType = true
): dict<any>
  if empty(keys)
    throw ErrNoKey(name)
  endif

  var R = {
    name:        name,
    schema:      schema,
    instance:    [],
    keys:        [],
    indexes:     {},
    constraints: {'I': [], 'U': [], 'D': []},
  }

  if checkType
    TypeCheck(R)
  endif

  for key in keys
    Key(R, key)
  endfor

  return R
enddef

export def Attributes(R: dict<any>): list<string>
  return keys(R.schema)
enddef

export def KeyAttributes(R: dict<any>): list<string>
  return flattennew(R.keys)->sort()->uniq()
enddef

export def Descriptors(R: dict<any>): list<string>
  var allAttributes = Attributes(R)
  const keyAttributes = KeyAttributes(R)
  return filter(allAttributes, (_, a) => index(keyAttributes, a) == -1)
enddef

export def Insert(R: dict<any>, t: dict<any>): dict<any>
  for CheckConstraint in R.constraints.I
    CheckConstraint(t)
  endfor

  R.instance->add(t)

  var i = 0
  const n = len(R.keys)
  while i < n
    const key = R.keys[i]
    R.indexes[String(key)]->AddKey(key, t)
    i += 1
  endwhile

  return R
enddef

export def InsertMany(R: dict<any>, tuples: list<dict<any>>): dict<any>
  for t in tuples
    Insert(R, t)
  endfor
  return R
enddef

export def Update(R: dict<any>, t: dict<any>, upsert = false): void
  const key = R.keys[0]
  var keyValue = []
  for a in key
    keyValue->add(t[a])
  endfor
  const oldt = Lookup(R, key, keyValue)

  if oldt is KEY_NOT_FOUND
    if upsert
      Insert(R, t)
    else
      throw ErrKeyNotFound(R.name, key, keyValue)
    endif
    return
  endif

  # Update
  for attr in KeyAttributes(R)
    if t[attr] != oldt[attr]
      throw ErrUpdateKeyAttribute(R.name, attr, t, oldt)
    endif
  endfor

  # This may be tricky for some kinds of constraints, as the old tuple is
  # still in the relation at this point. But for simple checks it should work.
  for CheckConstraint in R.constraints.U
    CheckConstraint(t)
  endfor

  for attr in Descriptors(R)
    oldt[attr] = t[attr]
  endfor
enddef

export def Delete(R: dict<any>, Pred: func(dict<any>): bool = (t) => true): void
  const DeletePred = (i: number, t: dict<any>): bool => {
    if Pred(t)
      for CheckConstraint in R.constraints.D
        CheckConstraint(t)
      endfor
      for key in R.keys
        const index = R.indexes[string(key)]
        index->RemoveKey(key, t)
      endfor
      return false
    endif
    return true
  }

  filter(R.instance, DeletePred)
enddef
# }}}

# Convenience functions {{{
export def Filter(R: any, Pred: func(dict<any>): bool): list<dict<any>>
  var rel = copy(IsRelationInstance(R) ? R : R.instance)
  return filter(rel, (_, t) => Pred(t))
enddef

# Compare two relation instances
export def RelEq(r: list<dict<any>>, s: list<dict<any>>): bool
  return sort(copy(r)) == sort(copy(s))
enddef

export def Empty(R: any): bool
  const rel = IsRelationInstance(R) ? R : R.instance
  return empty(rel)
enddef

# Returns a textual representation of a relation
export def Table(R: any, name = null_string, sep = '─'): string
  var rel: list<dict<any>>
  var relname: string

  if IsRelationInstance(R)
    rel = R
    relname = name
  else
    rel = R.instance
    relname = empty(name) ? R.name : name
  endif

  if empty(rel)
    return printf(" %s\n%s\n", relname, repeat(sep, 2 + strwidth(relname)))
  endif

  const attributes: list<string> = keys(rel[0])
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

