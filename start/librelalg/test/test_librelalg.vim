vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

import 'librelalg.vim' as ra
import 'libtinytest.vim' as tt

# Aliases {{{
const AntiJoin             = ra.AntiJoin
const Avg                  = ra.Avg
const AvgBy                = ra.AvgBy
const Bool                 = ra.Bool
const Build                = ra.Build
const CoddDivide           = ra.CoddDivide
const Count                = ra.Count
const CountBy              = ra.CountBy
const CountDistinct        = ra.CountDistinct
const Divide               = ra.Divide
const Extend               = ra.Extend
const EquiJoin             = ra.EquiJoin
const EquiJoinPred         = ra.EquiJoinPred
const Filter               = ra.Filter
const Float                = ra.Float
const ForeignKey           = ra.ForeignKey
const Frame                = ra.Frame
const From                 = ra.From
const GroupBy              = ra.GroupBy
const In                   = ra.In
const Int                  = ra.Int
const Intersect            = ra.Intersect
const Join                 = ra.Join
const LeftNatJoin          = ra.LeftNatJoin
const ListAgg              = ra.ListAgg
const Max                  = ra.Max
const MaxBy                = ra.MaxBy
const Min                  = ra.Min
const MinBy                = ra.MinBy
const Minus                = ra.Minus
const NatJoin              = ra.NatJoin
const NotIn                = ra.NotIn
const Product              = ra.Product
const Project              = ra.Project
const Query                = ra.Query
const Rel                  = ra.Rel
const RelEq                = ra.RelEq
const Rename               = ra.Rename
const Select               = ra.Select
const SemiJoin             = ra.SemiJoin
const Sort                 = ra.Sort
const SortBy               = ra.SortBy
const Str                  = ra.Str
const StringAgg            = ra.StringAgg
const Sum                  = ra.Sum
const SumBy                = ra.SumBy
const Table                = ra.Table
const Union                = ra.Union
const Zip                  = ra.Zip
# }}}

# assert_fails() logs exceptions in messages. This function is quiet.
def AssertFails(what: string, expectedError: string): void
  try
    execute what
    assert_false(1, 'Command should have failed, but succeeded')
  catch
    assert_exception(expectedError)
  endtry
enddef

# These are defined at the script level for using with AssertFails().
# See also: https://github.com/vim/vim/issues/6868
var RR: Rel
var SS: Rel

# Data definition {{{
def Test_RA_CreateEmptyRel()
  const M = Rel.new('M', {}, [[]])

  assert_equal('M', M.name)
  assert_equal({}, M.schema)
  assert_equal([], M.instance)
  assert_equal([], M.attributes)
  assert_equal([], M.keyAttributes)
  assert_equal([], M.descriptors)
  assert_equal(1, len(M.keys))
  assert_equal([], M.keys[0])

  const R1 = Rel.new('R', {A: Int, C: Float, B: Str}, [['A']])
  const R2 = Rel.new('R', {A: Int, C: Float, B: Str}, ['A'])
  const R3 = Rel.new('R', {A: Int, C: Float, B: Str}, 'A')

  for R in [R1, R2, R3]
    assert_equal('R', R.name)
    assert_equal({A: Int, B: Str, C: Float}, R.schema)
    assert_equal([], R.instance)
    assert_equal(['A', 'B', 'C'], R.attributes)
    assert_equal(['A'], R.keyAttributes)
    assert_equal(['B', 'C'], R.descriptors)
    assert_equal(1, len(R.keys))
    assert_equal(['A'], R.keys[0])
  endfor

  const S = Rel.new('S',
    {Z: Str, Y: Int, W: Float, X: Str},
    [['X', 'Y'], ['Z', 'Y']]
  )
  assert_equal('S', S.name)
  assert_equal({X: Str, Y: Int, W: Float, Z: Str}, S.schema)
  assert_equal([], S.instance)
  assert_equal(['W', 'X', 'Y', 'Z'], S.attributes)
  assert_equal(['X', 'Y', 'Z'], S.keyAttributes)
  assert_equal(['W'], S.descriptors)
  assert_equal(2, len(S.keys))
  assert_equal(['X', 'Y'], S.keys[0])
  assert_equal(['Z', 'Y'], S.keys[1])

  const T = Rel.new('T',
    {Z: Str, Y: Int, W: Float, X: Str},
    [['X', 'Y'], 'Z', ['Y']]
  )
  assert_equal('T', T.name)
  assert_equal({X: Str, Y: Int, W: Float, Z: Str}, T.schema)
  assert_equal([], T.instance)
  assert_equal(['W', 'X', 'Y', 'Z'], T.attributes)
  assert_equal(['X', 'Y', 'Z'], T.keyAttributes)
  assert_equal(['W'], T.descriptors)
  assert_equal(3, len(T.keys))
  assert_equal(['X', 'Y'], T.keys[0])
  assert_equal(['Z'], T.keys[1])
  assert_equal(['Y'], T.keys[2])

  const U = Rel.new('U',
    {A: Int, B: Int},
    ['B', 'A']  # One composite key
  )
  assert_equal('U', U.name)
  assert_equal({A: Int, B: Int}, U.schema)
  assert_equal([], U.instance)
  assert_equal(['A', 'B'], U.attributes)
  assert_equal(['A', 'B'], U.keyAttributes)
  assert_equal([], U.descriptors)
  assert_equal(1, len(U.keys))
  assert_equal(['B', 'A'], U.keys[0])

  const V = Rel.new('V',
    {A: Int, B: Int},
    [['B'], 'A']  # Two single-attribute keys
  )
  assert_equal('V', V.name)
  assert_equal({A: Int, B: Int}, V.schema)
  assert_equal([], V.instance)
  assert_equal(['A', 'B'], V.attributes)
  assert_equal(['A', 'B'], V.keyAttributes)
  assert_equal([], V.descriptors)
  assert_equal(2, len(V.keys))
  assert_equal(['B'], V.keys[0])
  assert_equal(['A'], V.keys[1])
enddef

def Test_RA_DuplicateKey()
  RR = Rel.new('RR', {A: Int, B: Str}, ['A'])
  AssertFails('RR.Key(["A"])', "Key ['A'] already defined in RR")
  AssertFails('RR.Key("A")',   "Key ['A'] already defined in RR")
  RR.Key('B')
  RR.Key(['A', 'B'])  # Superkeys are also allowed
  assert_equal([['A'], ['B'], ['A', 'B']], RR.keys)
enddef

def Test_RA_WrongKey()
  AssertFails("Rel.new('RR', {A: Int}, [['B']])", "B is not an attribute of RR")
  AssertFails("Rel.new('RR', {A: Int}, ['B'])",   "B is not an attribute of RR")
enddef
# }}}

# Data manipulation {{{
def Test_RA_Insert()
  RR = Rel.new('RR', {A: Int, B: Str, C: Bool, D: Float}, [['A', 'C']])
  RR.Insert({A: 0, B: 'b0', C: true, D: 1.2})

  assert_equal(1, len(RR.instance))

  const result = RR.Insert({A: 0, B: 'b1', C: false, D: 0.2})

  assert_equal(2, len(RR.instance))
  assert_equal(
    [{A: 0, B: 'b0', C: true, D: 1.2}, {A: 0, B: 'b1', C: false, D: 0.2}],
    RR.instance
  )
  assert_equal(v:t_object, type(result))
  assert_true(result is RR, 'The result is not the relation object')

  AssertFails("RR.Insert({A: 0, B: 'b2', C: true, D: 3.5})",
              'Duplicate key')

  AssertFails("RR.Insert({A: 9})",
              'Expected a tuple on schema')

  AssertFails("RR.Insert({A: false, B: 'b3', C: false, D: 7.0})",
              "Attribute A is of type integer, but value 'false' of type boolean")

  AssertFails("RR.Insert({A: 9, B: 9, C: false, D: 'tsk'})",
              "Attribute B is of type string, but value '9' of type integer")

  AssertFails("RR.Insert({A: 9, B: 'b3', C: 3.2, D: 'tsk'})",
              "Attribute C is of type boolean, but value '3.2' of type float")

  AssertFails("RR.Insert({A: 9, B: 'b3', C: false, D: 'tsk'})",
              "Attribute D is of type float, but value 'tsk' of type string")

  assert_equal(
    [{A: 0, B: 'b0', C: true, D: 1.2}, {A: 0, B: 'b1', C: false, D: 0.2}],
    RR.instance
  )
enddef

def Test_RA_InsertMany()
  RR = Rel.new('RR', {A: Int, B: Str, C: Bool, D: Float}, [['A', 'C']])
  const instance = [
    {A: 0, B: 'b0', C: true, D: 1.2},
    {A: 1, B: 'b1', C: true, D: 3.4},
  ]
  RR.InsertMany(instance)

  assert_equal(instance, RR.instance)

  # InsertMany() should work in a transactional way: if a tuple cannot be
  # inserted then the relation should not be modified at all.
  const statement =<< trim END
    RR.InsertMany([
      {A: 2, B: 'b2', C: false, D: 1.0},
      {A: 1, B: 'b3', C: true,  D: 3.4},
    ])
  END

  AssertFails(join(statement),
    "Duplicate key value: ['A', 'C'] = (1, true) already exists")

  assert_equal(instance, RR.instance)
enddef

def Test_RA_Update()
  RR = Rel.new('RR', {A: Int, B: Str, C: Bool, D: Str}, [['A'], ['B', 'C']])
  const rr = RR.instance
  RR.InsertMany([
    {A: 0, B: 'x', C: true, D: 'd1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
  ])

  RR.Update({A: 0, B: 'x', C: true, D: 'new-d1'})
  RR.Update({A: 1, B: 'x', C: false, D: 'new-d2'})

  const expected = [
    {A: 0, B: 'x', C: true, D: 'new-d1'},
    {A: 1, B: 'x', C: false, D: 'new-d2'},
  ]

  assert_equal(expected, rr)
  AssertFails("RR.Update({A: 0, B: 'x', C: false, D: ''})",
              "Key attribute C in RR cannot be changed")
  AssertFails("RR.Update({A: 2, B: 'y', C: true, D: 'd3'})",
              "Tuple with ['A'] = [2] not found in RR")
enddef

def Test_RA_Upsert()
  RR = Rel.new('RR', {A: Int, B: Str, C: Bool, D: Str}, [['A'], ['B', 'C']])
  const rr = RR.instance
  RR.InsertMany([
    {A: 0, B: 'x', C: true, D: 'd1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
  ])

  RR.Update({A: 2, B: 'y', C: true, D: 'd3'}, true)
  RR.Update({A: 0, B: 'x', C: true, D: 'new-d1'}, true)

  const expected = [
    {A: 0, B: 'x', C: true, D: 'new-d1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
    {A: 2, B: 'y', C: true, D: 'd3'},
  ]

  assert_equal(expected, rr)

  AssertFails("RR.Update({A: 0, B: 'x', C: false, D: ''})",
              "Key attribute C in RR cannot be changed")
enddef

def Test_RA_Delete()
  var R = Rel.new('R', {A: Int, B: Str}, ['A'])

  R.InsertMany([
    {A: 0, B: 'X'},
    {A: 1, B: 'Y'},
    {A: 2, B: 'Z'},
    {A: 3, B: 'Y'},
    {A: 4, B: 'Z'},
  ])

  const expected1 = [
    {A: 1, B: 'Y'},
    {A: 2, B: 'Z'},
    {A: 3, B: 'Y'},
    {A: 4, B: 'Z'},
  ]
  const expected2 = [
    {A: 1, B: 'Y'},
    {A: 4, B: 'Z'},
  ]

  R.Delete((t) => t.B == 'X')

  assert_equal(expected1, R.instance)

  R.Delete((t) => t.A == 2 || t.A == 3)

  assert_equal(expected2, R.instance)

  R.Delete()

  assert_equal([], R.instance)
enddef

def Test_RA_ReferentialIntegrity()
  RR = Rel.new('R', {A: Int}, ['A'])
  SS = Rel.new('S', {X: Str, Y: Int}, ['X'])
  ForeignKey(SS, 'references', RR, ['Y'], ['A'])
  RR.Insert({A: 2})
  SS.Insert({X: 'a', Y: 2})

  AssertFails("RR.Delete()",
    "S references R: R['A'] = (2) is referenced by {'X': 'a', 'Y': 2}")

  SS.Delete()
  RR.Delete()

  assert_true(RR.IsEmpty())
enddef
# }}}

# Integrity constraints {{{
def Test_RA_ForeignKey()
  RR = Rel.new('RR', {A: Str}, 'A')
  SS = Rel.new('SS', {B: Int, C: Str}, 'B')

  AssertFails("ForeignKey(SS, 'ref', RR, ['B', 'C'], ['A'])",
              "Wrong foreign key size: SS['B', 'C'] -> RR['A']")
  AssertFails("ForeignKey(SS, 'ref', RR, ['C'])",
              "Wrong foreign key: SS['C'] -> RR['C']. ['C'] is not a key of RR")
  AssertFails("ForeignKey(SS, 'ref', RR, ['A'], ['A'])",
              "Wrong foreign key: SS['A'] -> RR['A']. A is not an attribute of SS")

  ForeignKey(SS, 'references', RR, 'C', 'A')

  RR.InsertMany([{A: 'ab'}, {A: 'tm'}])
  SS.Insert({B: 10, C: 'tm'})
  SS.Insert({B: 20, C: 'tm'})
  SS.Insert({B: 30, C: 'ab'})

  AssertFails("SS.Insert({B: 40, C: 'xy'})",
              "SS references RR: SS['C'] = ('xy') is not present in RR['A']")

  SS.Update({B: 20, C: 'ab'})

  AssertFails("SS.Update({B: 30, C: 'wz'})",
              "SS references RR: SS['C'] = ('wz') is not present in RR['A']")

  const expected = [
    {B: 10, C: 'tm'},
    {B: 20, C: 'ab'},
    {B: 30, C: 'ab'},
  ]
  assert_equal(expected, SS.instance)
enddef

def Test_RA_ForeignKeySameAttrs()
  RR = Rel.new('R', {A: Str}, 'A')
  SS = Rel.new('S', {B: Int, A: Str}, 'B')

  ForeignKey(SS, 'flocks with', RR, 'A')

  RR.InsertMany([{A: 'ab'}, {A: 'tm'}])
  SS.Insert({B: 10, A: 'tm'})
  SS.Insert({B: 20, A: 'tm'})
  SS.Insert({B: 30, A: 'ab'})

  AssertFails("SS.Insert({B: 40, A: 'xy'})",
              "S flocks with R: S['A'] = ('xy') is not present in R['A']")
enddef

def Test_RA_GenericConstraint()
  RR = Rel.new('R', {A: Int, B: Int}, 'A')

  RR.Check((t) => {
    if t.B <= 0
      throw printf('B must be positive: got %s', t.B)
    endif
  })

  var t0 = {A: 1, B: 2}
  RR.Insert(t0)

  assert_equal([t0], RR.instance)

  AssertFails("RR.Insert({A: 2, B: -3})", "B must be positive: got -3")

  assert_equal([t0], RR.instance)

  RR.Update({A: 1, B: 3})

  AssertFails("RR.Update({A: 1, B: -2})", "B must be positive: got -2")

  assert_equal([t0], RR.instance)

  RR.Delete()

  assert_true(RR.IsEmpty())
enddef
# }}}

# Indexes {{{
def Test_RA_Index()
  const key = ['A', 'B']
  const keyStr = string(key)
  var R = Rel.new('R', {A: Int, B: Str}, key)

  assert_equal([['A', 'B']], R.keys)

  const I = R.Index(key)

  assert_equal(v:t_object, type(I))
  assert_equal('object<KeyIndex>', typename(I))

  assert_true(I.IsEmpty(), 'Index must be initially empty')

  const t0 = {A: 9, B: 'veni'}
  const t1 = {A: 3, B: 'vici'}
  const t2 = {A: 9, B: 'vidi'}
  R.InsertMany([t0, t1, t2])
  const index = I.GetRawIndex()

  assert_equal({'3': { 'vici': t1 },
                '9': { 'veni': t0, 'vidi': t2 }}, index)

  assert_true(index[3]['vici'] is t1)
  assert_true(index[9]['veni'] is t0)
  assert_true(index[9]['vidi'] is t2)

  R.Delete((t) => t.A == 9 && t.B == 'veni')

  assert_equal({'3': { 'vici': t1 },
                '9': { 'vidi': t2 }}, index)

  R.Delete((t) => t.B == 'vici')

  assert_equal({'9': { 'vidi': t2 }}, index)

  R.Delete()

  assert_equal({}, index)
enddef
# }}}
#
def Test_RA_In()
  const R = Rel.new('R', {A: Str, B: Int}, [['A']])
  R.InsertMany([
    {A: 'a', B: 1},
    {A: 'b', B: 1},
    {A: 'c', B: 2},
  ])

  const t1 = {A: 'a', B: 1}
  const t2 = {A: 'a', B: 2}
  assert_true(t1->In(R), "t1 is not in R")
  assert_true(!t2->In(R), "t2 is in R")
  assert_true(!t1->NotIn(R), "not (not t1 is not in R)")
  assert_true(t2->NotIn(R), "not (t2 is not in R)")
enddef

def Test_RA_Scan()
  var R = Rel.new('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R.InsertMany(instance)

  const result1 = Query(From(R))
  const result2 = Query(From(R.instance))

  const expected = instance

  assert_equal(expected, result1)
  assert_equal(expected, result2)
  assert_equal(instance, R.instance)
enddef

def Test_RA_FilteredScan()
  var R = Rel.new('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R.InsertMany(instance)

  const expected = [{A: 2, B: 0.0, C: false, D: 'tuple2'}]
  const result = Query(R->Select((t) => !t.C && t.B >= 0))

  assert_equal(expected, result)
  assert_equal(instance, R.instance)
enddef

def Test_RA_Sort()
  var R = Rel.new('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])
  const r = R.instance

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R.InsertMany(instance)

  const Cmp = (t1, t2) => t1.B == t2.B ? 0 : t1.B > t2.B ? 1 : -1

  const expected = [
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  assert_equal(expected, From(r)->Sort(Cmp))
  assert_equal(expected, From(r)->SortBy('B'))
  assert_equal(R.instance, r)
  assert_equal(instance, R.instance)
enddef

def Test_RA_SortByAscDesc()
  var R = Rel.new('R', {A: Int, B: Float, C: Bool, D: Str}, 'A')
  const r = R.instance

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R.InsertMany(instance)

  const expected1 = [
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  const expected2 = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]

  const expected3 = [
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  const expected4 = [
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  const expected5 = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
  ]

  const expected6 = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]

  assert_equal(expected1, From(r)->SortBy(['B'], ['i']))
  assert_equal(expected2, From(r)->SortBy('B', ['d']))
  assert_equal(expected3, From(r)->SortBy(['C', 'B'], ['i', 'd']))
  assert_equal(expected4, From(r)->SortBy(['C', 'B'], ['i', 'i']))
  assert_equal(expected5, From(r)->SortBy(['C', 'B'], ['d', 'i']))
  assert_equal(expected6, From(r)->SortBy(['C', 'B'], ['d', 'd']))
  assert_equal(R.instance, r)
  assert_equal(instance, R.instance)
enddef

def Test_RA_Rename()
  var R = Rel.new('R', {A: Str, B: Float, C: Int}, 'A')
  const r = R.instance

  const instance = [
    {A: 'a1', B: 4.0, C: 40},
    {A: 'a2', B: 2.0, C: 80},
  ]
  R.InsertMany(instance)

  const expected = [
    {X: 'a1', B: 4.0, W: 40},
    {X: 'a2', B: 2.0, W: 80},
  ]

  assert_equal(instance, From(R)->Rename([], [])->Build())
  assert_equal(expected, From(R)->Rename(['A', 'C'], ['X', 'W'])->Build())
  assert_equal(instance, r)
enddef

def Test_RA_Select()
  var R = Rel.new('R', {A: Str, B: Float, C: Int}, [['A']])
  const r = R.instance

  const instance = [
    {A: 'a1', B: 4.0, C: 40},
    {A: 'a2', B: 2.0, C: 80},
    {A: 'a3', B: 9.0, C: 10},
    {A: 'a4', B: 5.0, C: 80},
    {A: 'a5', B: 4.0, C: 20},
  ]
  R.InsertMany(instance)

  const expected1 = [
    {A: 'a1', B: 4.0, C: 40},
  ]
  const expected2 = [
    {A: 'a5', B: 4.0, C: 20},
  ]

  assert_equal(expected1, Query(From(r)->Select((t) => t.C == 40)))
  assert_equal(expected2, Query(From(r)->Select((t) => t.B <= 4.0 && t.A == 'a5')))
  assert_equal([], Query(From(r)->Select((t) => t.B > 9.0)))
  assert_equal(instance, r)
enddef

def Test_RA_Project()
  var R = Rel.new('R', {A: Str, B: Bool, C: Int}, 'A')
  const r = R.instance

  const instance = [
    {A: 'a1', B: true,  C: 40},
    {A: 'a2', B: false, C: 80},
    {A: 'a3', B: true,  C: 40},
    {A: 'a4', B: true,  C: 80},
    {A: 'a5', B: false, C: 20},
  ]
  R.InsertMany(instance)

  const expected1 = [
    {A: 'a1'},
    {A: 'a2'},
    {A: 'a3'},
    {A: 'a4'},
    {A: 'a5'},
  ]
  const expected2 = [
    {B: false},
    {B: true}
  ]
  const expected3 = [
    {B: false, C: 20},
    {B: false, C: 80},
    {B: true,  C: 40},
    {B: true,  C: 80},
  ]

  assert_equal([], Query(From([])->Project('X')))
  assert_equal([], Query(From([])->Project([])))
  assert_equal([{}], Query(From([{}])->Project([])))
  assert_equal([{}], Query(From(r)->Project([])))
  assert_equal(expected1, From(r)->Project('A')->SortBy('A'))
  assert_equal(expected2, From(r)->Project('B')->SortBy('B'))
  assert_equal(expected3, From(r)->Project(['B', 'C'])->SortBy(['B', 'C']))
  assert_equal(instance, r)
enddef

def Test_RA_EquiJoinPred()
  var Pred = EquiJoinPred(['X'], ['Y'])

  assert_true(Pred({X: 1, W: 2}, {Y: 1, Z: 3}), "Equi-join predicate 1 failed")
  assert_false(Pred({X: 2, W: 2}, {Y: 1, Z: 3}), "Equi-join predicate 2 succeeded")

  Pred = EquiJoinPred(['X', 'Y'], ['W', 'Z'])

  assert_true(Pred({X: 1, Y: 2}, {W: 1, Z: 2}), "Equi-join predicate 3 failed")
  assert_false(Pred({X: 3, Y: 4}, {W: 3, Z: 5}), "Equi-join predicate 4 succeeded")
enddef

def Test_RA_Join()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0},
  ]
  S.InsertMany(instanceS)


  const expected1 = [
    {r_A: 1, r_B: 'one', B: 'one', C: 1},
    {r_A: 2, r_B: 'one', B: 'one', C: 1},
  ]
  const expected2 = [
    {A: 1, B: 'one', s_B: 'one', s_C: 1},
    {A: 2, B: 'one', s_B: 'one', s_C: 1},
  ]
  const expected3 = [
    {r_A: 0, r_B: 'zero',  B: 'one',   C: 1},
    {r_A: 0, r_B: 'zero',  B: 'three', C: 0},
    {r_A: 1, r_B: 'one',   B: 'one',   C: 1},
  ]
  const expected4 = [
    {A: 0, B: 'zero',  s_B: 'three', s_C: 0},
    {A: 0, B: 'zero',  s_B: 'one',   s_C: 1},
    {A: 1, B: 'one',   s_B: 'one',   s_C: 1},
  ]
  const expected5 = [
    {s_B: 'one',   s_C: 1, B: 'three', C: 0},
    {s_B: 'three', s_C: 0, B: 'three', C: 0},
  ]

  assert_equal(expected1, From(R)->Join(S, (rt, st) => rt.B == st.B, 'r_')->SortBy('r_A'))
  assert_equal(expected2, From(S)->Join(R, (st, rt) => rt.B == st.B, 's_')->SortBy('A'))
  assert_equal(expected3, From(R)->Join(S, (rt, st) => rt.A <= st.C, 'r_')->SortBy(['r_A', 'B']))
  assert_equal(expected4, From(S)->Join(R, (st, rt) => rt.A <= st.C, 's_')->SortBy(['s_C', 'A']))
  assert_equal(expected5, From(S)->Join(S, (s1, s2) => s1.C >= s2.C && s2.C == 0, 's_')->SortBy('B'))

  assert_equal(expected1, From(R)->EquiJoin(S, ['B'], ['B'], 'r_')->SortBy('r_A'))
  assert_equal(expected2, From(S)->EquiJoin(R, 'B', 'B', 's_')->SortBy('A'))

  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_NatJoin()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0},
  ]
  S.InsertMany(instanceS)

  var T = Rel.new('T', {D: Int}, [['D']])
  const t = T.instance

  const instanceT = [
    {D: 8},
    {D: 9},
  ]
  T.InsertMany(instanceT)

  var U = Rel.new('U', {A: Int, B: Str}, [['A', 'B']])
  const u = U.instance

  const instanceU = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  U.InsertMany(instanceU)

  const expected1 = [
    {A: 1, B: 'one', C: 1},
    {A: 2, B: 'one', C: 1},
  ]
  const expected2 = [
    {B: 'one',   C: 1, D: 8},
    {B: 'one',   C: 1, D: 9},
    {B: 'three', C: 0, D: 8},
    {B: 'three', C: 0, D: 9},
  ]

  assert_equal(expected1, Query(From(R)->NatJoin(S)))
  assert_equal(expected1, Query(From(S)->NatJoin(R)))
  assert_equal(expected2, Query(From(S)->NatJoin(T)))
  assert_equal(r, Query(From(R)->NatJoin(R)))
  assert_equal([{A: 1, B: 'one'}], Query(From(R)->NatJoin(U)))
  assert_equal([{A: 1, B: 'one'}], Query(From(U)->NatJoin(R)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
  assert_equal(instanceT, t)
  assert_equal(instanceU, u)
enddef

def Test_RA_Product()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
    ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {C: 10},
    {C: 90},
  ]
  S.InsertMany(instanceS)

  assert_equal([], Query(From([])->Product([])))
  assert_equal([], Query(From(R)->Product([])))
  assert_equal([], Query(From([])->Product(R)))
  assert_equal(r, Query(From(R)->Product([{}])))

  const expected = [
    {A: 0, B: 'zero', C: 10},
    {A: 0, B: 'zero', C: 90},
    {A: 1, B: 'one',  C: 10},
    {A: 1, B: 'one',  C: 90},
    {A: 2, B: 'two',  C: 10},
    {A: 2, B: 'two',  C: 90},
  ]

  assert_equal(expected, From(R)->Product(S)->SortBy(['A', 'C']))
  assert_equal(expected, From(S)->Product(R)->SortBy(['A', 'C']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_Intersect()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.instance

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  S.InsertMany(instanceS)

  assert_equal([{A: 1, B: 'one'}], Query(From(R)->Intersect(S)))
  assert_equal([{A: 1, B: 'one'}], Query(From(S)->Intersect(R)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_Minus()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.instance

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  S.InsertMany(instanceS)

  const expected1 = [
    {A: 0, B: 'zero'},
    {A: 2, B: 'one'},
  ]
  const expected2 = [
    {A: 0, B: 'many'},
    {A: 2, B: 'two'},
  ]

  assert_equal(expected1, From(R)->Minus(S)->SortBy('A'))
  assert_equal(expected2, From(S)->Minus(R)->SortBy('A'))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_Union()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.instance

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 3, B: 'one'},
  ]
  S.InsertMany(instanceS)

  const expected = [
    {A: 0, B: 'many'},
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    {A: 3, B: 'one'},
  ]

  assert_equal(expected, From(R)->Union(S)->SortBy(['A', 'B']))
  assert_equal(expected, Union(S, R)->SortBy(['A', 'B']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
  assert_equal(expected, R->Union(Select(S, (t) => true)->SortBy(['A', 'B'])))
enddef

def Test_RA_SemiJoin()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0}
  ]
  S.InsertMany(instanceS)

  const expected1 = [
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  const expected2 = [
    {B: 'one', C: 1},
  ]
  const expected3 = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
  ]
  const expected4 = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0},
  ]
  const expected5 = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0},
  ]

  assert_equal(expected1, From(R)->SemiJoin(S, (rt, st) => rt.B == st.B)->SortBy('A'))
  assert_equal(expected2, Query(From(S)->SemiJoin(R, (st, rt) => rt.B == st.B)))
  assert_equal(expected3, From(R)->SemiJoin(S, (rt, st) => rt.A <= st.C)->SortBy('A'))
  assert_equal(expected4, From(S)->SemiJoin(R, (st, rt) => rt.A <= st.C)->SortBy('B'))
  assert_equal(expected5, Query(From(S)->SemiJoin(S, (s1, s2) => s1.C >= s2.C && s2.C == 0)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_AntiJoin()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0},
  ]
  S.InsertMany(instanceS)

  const expected1 = [
    {A: 0, B: 'zero'},
  ]
  const expected2 = [
    {B: 'three', C: 0},
  ]
  const expected3 = [
    {A: 2, B: 'one'},
  ]
  const expected4 = []
  const expected5 = [
    {B: 'three', C: 0},
  ]

  assert_equal(expected1, Query(From(R)->AntiJoin(S, (rt, st) => rt.B == st.B)))
  assert_equal(expected2, Query(From(S)->AntiJoin(R, (st, rt) => rt.B == st.B)))
  assert_equal(expected3, SortBy(From(R)->AntiJoin(S, (rt, st) => rt.A <= st.C), 'A'))
  assert_equal(expected4, SortBy(From(S)->AntiJoin(R, (st, rt) => rt.A <= st.C), 'B'))
  assert_equal(expected5, Query(From(S)->AntiJoin(S, (s1, s2) => s1.C > s2.C)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_LeftNatJoin()
  var Buffer = Rel.new('Buffer', {
      BufId:   Int,
      BufName:  Str,
    },
    [['BufId'], ['BufName']]
  )

  var Tag = Rel.new('Tag', {
      BufId:   Int,
      TagName: Str,
      Line:    Int,
      Column:  Int,
    },
    [['BufId', 'TagName']]
  )

  Buffer.InsertMany([
    {BufId: 1, BufName: 'foo'},
    {BufId: 2, BufName: 'bar'},
    {BufId: 3, BufName: 'xyz'},
  ])

  Tag.InsertMany([
    {BufId: 1, TagName: 'abc', Line: 3,  Column: 9},
    {BufId: 1, TagName: 'xyz', Line: 4,  Column: 1},
    {BufId: 1, TagName: 'lll', Line: 4,  Column: 8},
    {BufId: 2, TagName: 'abc', Line: 14, Column: 15},
  ])

  const summary = Query(From(Tag)->GroupBy(['BufId'], Count, 'num_tags'))
  const result = Query(From(Buffer)->LeftNatJoin(summary, [{'num_tags': 0}]))
  const expected = [
    {BufId: 1, BufName: 'foo', num_tags: 3},
    {BufId: 2, BufName: 'bar', num_tags: 1},
    {BufId: 3, BufName: 'xyz', num_tags: 0},
  ]

  assert_true(RelEq(result, expected))
enddef

def Test_RA_Lookup()
  var R = Rel.new('R', {A: Int, B: Str}, 'A')
  R.InsertMany([{A: 1, B: 'x'}, {A: 3, B: 'y'}, {A: 5, B: 'z'}])

  assert_equal({A: 1, B: 'x'}, R.Lookup(['A'], [1]))
  assert_equal({A: 3, B: 'y'}, R.Lookup(['A'], [3]))
  assert_equal({A: 5, B: 'z'}, R.Lookup(['A'], [5]))
enddef

def Test_RA_Extend()
  var R = Rel.new('R', {A: Int}, [['A']]).InsertMany([{A: 1}, {A: 3}, {A: 5}])
  const expected = [
    {A: 1, B: 2,  C: 'ok'},
    {A: 3, B: 6,  C: 'ok'},
    {A: 5, B: 10, C: 'ok'},
  ]
  const result = Query(
    From(R)->Extend((t) => {
      return {B: t.A * 2, C: 'ok'}
    })
  )

  assert_equal(expected, result)
enddef

def Test_RA_Max()
  var R = Rel.new('R', {A: Int, B: Str, C: Float, D: Bool}, [['A']])
  const r = R.instance

  assert_equal(null, From(R)->Max('A'))
  assert_equal(null, From(R)->Max('B'))
  assert_equal(null, From(R)->Max('C'))
  assert_equal(null, From(R)->Max('D'))

  const instance = [
    {A: 0, B: "X", C: 10.0, D:  true},
    {A: 1, B: "Z", C:  2.5, D:  true},
    {A: 2, B: "Y", C: -3.0, D: false},
    {A: 3, B: "X", C:  1.5, D:  true},
    {A: 4, B: "Z", C:  2.5, D:  true},
  ]
  R.InsertMany(instance)

  assert_equal(4,    From(R)->Max('A'))
  assert_equal('Z',  From(R)->Max('B'))
  assert_equal(10.0, From(R)->Max('C'))
  assert_equal(true, From(R)->Max('D'))
  assert_equal(instance, r)
enddef

def Test_RA_Min()
  var R = Rel.new('R', {A: Int, B: Str, C: Float, D: Bool}, [['A']])
  const r = R.instance

  assert_equal(null, From(R)->Min('A'))
  assert_equal(null, From(R)->Min('B'))
  assert_equal(null, From(R)->Min('C'))
  assert_equal(null, From(R)->Min('D'))

  const instance = [
    {A: 0, B: "X", C: 10.0, D:  true},
    {A: 1, B: "Z", C:  2.5, D:  true},
    {A: 2, B: "Y", C: -3.0, D: false},
    {A: 3, B: "X", C:  1.5, D:  true},
    {A: 4, B: "Z", C:  2.5, D:  true},
  ]
  R.InsertMany(instance)

  assert_equal(0,     From(R)->Min('A'))
  assert_equal('X',   From(R)->Min('B'))
  assert_equal(-3.0,  From(R)->Min('C'))
  assert_equal(false, From(R)->Min('D'))
  assert_equal(instance, r)
enddef

def Test_RA_Sum()
  var R = Rel.new('R', {A: Int, B: Float}, [['A']])
  const r = R.instance

  assert_equal(0, From(R)->Sum('A'))
  assert_equal(0, From(R)->Sum('B'))

  const instance = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 2, B: -3.0},
    {A: 3, B:  1.5},
    {A: 4, B:  2.5},
  ]
  R.InsertMany(instance)

  assert_equal(10, From(R)->Sum('A'))
  assert_equal(v:t_number, type(From(R)->Sum('A')))
  assert_equal(13.5, From(R)->Sum('B'))
  assert_equal(v:t_float, type(From(R)->Sum('B')))
  assert_equal(instance, r)
enddef

def Test_RA_Avg()
  var R = Rel.new('R', {A: Int, B: Float}, [['A']])
  const r = R.instance

  assert_equal(null, From(R)->Avg('A'))
  assert_equal(null, From(R)->Avg('B'))

  const instance = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 2, B: -3.0},
    {A: 3, B:  1.5},
    {A: 4, B:  2.5},
  ]
  R.InsertMany(instance)

  assert_equal(2.0, From(R)->Avg('A'))
  assert_equal(v:t_float, type(From(R)->Avg('A')))
  assert_equal(2.7, From(R)->Avg('B'))
  assert_equal(v:t_float, type(From(R)->Avg('B')))
  assert_equal(instance, r)
enddef

def Test_RA_Count()
  const r = [
    {id: 0, A: 0, B: 10.0},
    {id: 1, A: 2, B:  2.5},
    {id: 2, A: 2, B: -3.0},
    {id: 3, A: 2, B:  1.5},
    {id: 4, A: 4, B:  2.5},
    {id: 5, A: 4, B:  2.5},
  ]

  assert_equal(0, From([])->Count())
  assert_equal(6, From(r)->Count())
enddef

def Test_RA_CountDistinct()
  const r = [
    {id: 0, A: 0, B: 10.0},
    {id: 1, A: 2, B:  2.5},
    {id: 2, A: 2, B: -3.0},
    {id: 3, A: 2, B:  1.5},
    {id: 4, A: 4, B:  2.5},
    {id: 5, A: 4, B:  2.5},
  ]

  assert_equal(0, From([])->CountDistinct('A'))
  assert_equal(3, From(r)->CountDistinct('A'))
  assert_equal(4, From(r)->CountDistinct('B'))
enddef

def Test_RA_ListAgg()
  const r = [
    {id: 0, A: 0, B: 10.0},
    {id: 1, A: 2, B:  2.5},
    {id: 2, A: 2, B: -3.0},
    {id: 3, A: 2, B:  1.5},
    {id: 4, A: 4, B:  2.5},
    {id: 5, A: 4, B:  2.5},
  ]
  const expected = [
    {A: 0, aggrValue: [10.0]},
    {A: 2, aggrValue: [2.5, -3.0, 1.5]},
    {A: 4, aggrValue: [2.5, 2.5]},
  ]

  assert_equal([], From([])->ListAgg('A'))
  assert_equal([0, 2, 2, 2, 4, 4], From(r)->ListAgg('A'))
  assert_equal([10.0, 2.5, -3.0, 1.5, 2.5, 2.5], From(r)->ListAgg('B'))
  assert_equal(expected, From(r)->GroupBy(['A'], ListAgg('B'))->SortBy('A'))
enddef

def Test_RA_StringAgg()
  const r = [
    {id: 0, A: 0, B: 'a'},
    {id: 1, A: 2, B: 'c'},
    {id: 2, A: 2, B: 'f'},
    {id: 3, A: 2, B: 'p'},
    {id: 4, A: 4, B: 'b'},
    {id: 5, A: 4, B: 'm'},
  ]

  assert_equal('', From([])->StringAgg('A', '', ''))
  assert_equal('0.2.2.2.4.4', r->StringAgg('A', '.', ''))
  assert_equal('a, b, c, f, m, p', r->StringAgg('B', ', ', ''))

  const result = From(r)
                 ->GroupBy('A',
                     StringAgg('B',
                               ',',
                               (x, y) => x == y ? 0 : x > y ? -1 : 1)
                     )
                 ->SortBy('A')

  const expected = [
    {A: 0, aggrValue: 'a'},
    {A: 2, aggrValue: 'p,f,c'},
    {A: 4, aggrValue: 'm,b'},
  ]

  assert_equal(expected, result)
enddef

def Test_RA_SumBy()
  assert_equal([{sum: 0}],   From([])->SumBy([], 'A'))
  assert_equal([{summa: 0}], From([])->SumBy([], 'B', 'summa'))
  assert_equal([],           From([])->SumBy(['A'], 'A'))
  assert_equal([],           From([])->SumBy('B', 'A', 'summa'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{sum: 8}],   From(r)->SumBy([], 'A'))
  assert_equal(13.5, From(r)->SumBy([], 'B')[0].sum)
  assert_equal([
    {A: 0, sum: 10.0},
    {A: 1, sum: -0.5},
    {A: 3, sum:  4.0},
  ], From(r)->SumBy(['A'], 'B'))
enddef

def Test_RA_CountBy()
  assert_equal([{count: 0}], From([])->CountBy([]))
  assert_equal([{count: 0}], From([])->CountBy([], 'A'))
  assert_equal([{cnt: 0}],   From([])->CountBy([], 'B', 'cnt'))
  assert_equal([],           From([])->CountBy(['A'], 'A'))
  assert_equal([],           From([])->CountBy(['B'], 'A', 'cnt'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{count: 5}], From(r)->CountBy([]))
  assert_equal([{count: 3}], From(r)->CountBy([], 'A'))
  assert_equal([{count: 4}], From(r)->CountBy([], 'B'))
  assert_equal([
    {A: 0, cnt: 1},
    {A: 1, cnt: 2},
    {A: 3, cnt: 2},
  ], From(r)->CountBy(['A'], null_string, 'cnt'))
  assert_equal([
    {A: 0, cnt: 1},
    {A: 1, cnt: 2},
    {A: 3, cnt: 2},
  ], From(r)->CountBy('A', 'B', 'cnt'))
enddef

def Test_RA_MaxBy()
  assert_equal([], From([])->MaxBy([], 'A'))
  assert_equal([], From([])->MaxBy([], 'B'))
  assert_equal([], From([])->MaxBy(['A'], 'A'))
  assert_equal([], From([])->MaxBy('B', 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{max: 3}],    From(r)->MaxBy([], 'A'))
  assert_equal([{max: 10.0}], From(r)->MaxBy([], 'B'))
  assert_equal([
    {A: 0, maximum: 10.0},
    {A: 1, maximum:  2.5},
    {A: 3, maximum:  2.5},
  ], From(r)->MaxBy(['A'], 'B', 'maximum'))
enddef

def Test_RA_MinBy()
  assert_equal([], From([])->MinBy([], 'A'))
  assert_equal([], From([])->MinBy([], 'B'))
  assert_equal([], From([])->MinBy(['A'], 'A'))
  assert_equal([], From([])->MinBy('B', 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{min: 0}],    From(r)->MinBy([], 'A'))
  assert_equal([{min: -3.0}], From(r)->MinBy([], 'B'))
  assert_equal([
    {A: 0, minimum: 10.0},
    {A: 1, minimum: -3.0},
    {A: 3, minimum:  1.5},
  ], From(r)->MinBy(['A'], 'B', 'minimum'))
enddef

def Test_RA_AvgBy()
  assert_equal([], From([])->AvgBy([], 'A'))
  assert_equal([], From([])->AvgBy([], 'B'))
  assert_equal([], From([])->AvgBy(['A'], 'A'))
  assert_equal([], From([])->AvgBy('B', 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{avg: 1.6}], From(r)->AvgBy([], 'A'))
  assert_equal([{avg: 2.7}], From(r)->AvgBy([], 'B'))
  assert_equal([
    {A: 0, average: 10.0},
    {A: 1, average: -0.25},
    {A: 3, average:  2.0},
  ], From(r)->AvgBy(['A'], 'B', 'average'))
enddef

def Test_RA_Frame()
  var R = Rel.new('R', {A: Int, B: Str, C: Str}, [['A']])
  R.InsertMany([
    {A: 10, B: 'a', C: 'x'},
    {A: 20, B: 'b', C: 'y'},
    {A: 30, B: 'a', C: 'x'},
    {A: 40, B: 'a', C: 'x'},
    {A: 50, B: 'b', C: 'x'},
    {A: 60, B: 'b', C: 'y'},
    {A: 70, B: 'a', C: 'y'},
  ])

  var result = Query(
    From(R)->Extend((t) => {
      return {'fid': t.A / 30}
    })
  )
  var expected = [
    {A: 10, B: 'a', C: 'x', fid: 0},
    {A: 20, B: 'b', C: 'y', fid: 0},
    {A: 30, B: 'a', C: 'x', fid: 1},
    {A: 40, B: 'a', C: 'x', fid: 1},
    {A: 50, B: 'b', C: 'x', fid: 1},
    {A: 60, B: 'b', C: 'y', fid: 2},
    {A: 70, B: 'a', C: 'y', fid: 2},
  ]
  assert_equal(expected, result)

  result = Query(From(R)->Frame(['B', 'C']))
  expected = [
    {A: 10, B: 'a', C: 'x', fid: 0},
    {A: 20, B: 'b', C: 'y', fid: 1},
    {A: 30, B: 'a', C: 'x', fid: 0},
    {A: 40, B: 'a', C: 'x', fid: 0},
    {A: 50, B: 'b', C: 'x', fid: 2},
    {A: 60, B: 'b', C: 'y', fid: 1},
    {A: 70, B: 'a', C: 'y', fid: 3},
  ]
  assert_equal(expected, result)

  result = Query(R->Frame('B'))
  expected = [
    {A: 10, B: 'a', C: 'x', fid: 0},
    {A: 20, B: 'b', C: 'y', fid: 1},
    {A: 30, B: 'a', C: 'x', fid: 0},
    {A: 40, B: 'a', C: 'x', fid: 0},
    {A: 50, B: 'b', C: 'x', fid: 1},
    {A: 60, B: 'b', C: 'y', fid: 1},
    {A: 70, B: 'a', C: 'y', fid: 0},
  ]
  assert_equal(expected, result)
enddef

def Test_RA_GroupBy()
  var R = Rel.new('R', {id: Int, name: Str, balance: Float, class: Str}, 'id')
  const r = R.instance

  const instance = [
    {id: 0, name: "A", balance: 10.0, class: "X"},
    {id: 1, name: "A", balance:  3.5, class: "X"},
    {id: 2, name: "B", balance: -3.0, class: "X"},
    {id: 3, name: "A", balance:  1.5, class: "Y"},
    {id: 4, name: "B", balance:  2.5, class: "X"},
  ]
  R.InsertMany(instance)

  var result = From(r)
               ->GroupBy(['name'], Sum('balance'), 'total')
               ->SortBy('name')

  var expected = [
    {name: 'A', total: 15.0},
    {name: 'B', total: -0.5},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name', Max('balance'), 'max')->SortBy('name')

  expected = [
    {name: 'A', max: 10.0},
    {name: 'B', max: 2.5},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name', Min('balance'), 'min')->SortBy('name')

  expected = [
    {name: 'A', min: 1.5},
    {name: 'B', min: -3.0},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name', Avg('balance'), 'avg')->SortBy('name')

  expected = [
    {name: 'A', avg: 5.0},
    {name: 'B', avg: -0.25},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name', Count, 'count')->SortBy('name')

  expected = [
    {name: 'A', count: 3},
    {name: 'B', count: 2},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name', CountDistinct('class'), 'num_class')->SortBy('name')

  expected = [
    {name: 'A', num_class: 2},
    {name: 'B', num_class: 1},
  ]

  assert_equal(expected, result)

  assert_equal(instance, r)
enddef

def Test_RA_CoddDivide()
  var Subscription = Rel.new('Subscription',
     {student: Str, date: Str, course: Str},
     [['student', 'course']]
  )
  const subscription = Subscription.instance
  const subscription_instance = [
    {student: '123', date: '2019-12-05', course:        'Databases'},
    {student: '283', date: '2019-12-05', course:        'Databases'},
    {student: '123', date: '2020-12-05', course: 'Computer Science'},
    {student: '123', date: '2021-12-05', course:          'Algebra'},
    {student: '283', date: '2021-12-05', course:          'Algebra'},
    {student: '375', date: '2015-01-06', course:        'Databases'},
    {student: '283', date: '2020-12-05', course: 'Computer Science'},
    {student: '303', date: '2020-12-05', course: 'Computer Science'},
  ]
  Subscription.InsertMany(subscription_instance)

  var Session = Rel.new('Session', {date: Str, course: Str}, [['date', 'course']])
  const result1 = Query(From(Subscription)->CoddDivide(Session))
  const expected1 = [
    {student: '123'},
    {student: '283'},
    {student: '375'},
    {student: '303'},
  ]

  assert_equal(expected1, result1)

  # If the divisor is an empty *derived* relation, the divisor carries no
  # information about its schema. Short of explicitly providing a schema,
  # the choice is arbitrary: we assume that the schema is empty.
  const result2 = Query(From(Subscription)->CoddDivide([]))
  const expected2 = subscription_instance
  # The schema can be given explicitly, though (for this special case only)
  const result3 = Query(From(Subscription)->CoddDivide([], ['date', 'course']))
  const expected3 = expected1

  assert_equal(expected2, result2)
  assert_equal(expected3, result3)

  const session = Session.instance
  const session_instance = [
    {date: '2019-12-05', course:        'Databases'},
    {date: '2020-12-05', course: 'Computer Science'},
    {date: '2021-12-05', course:          'Algebra'},
  ]
  Session.InsertMany(session_instance)

  # Which students are subscribed to all the courses?
  const result4 = From(Subscription)->CoddDivide(Session)->SortBy('student')
  const expected4 = [
    {'student': '123'},
    {'student': '283'},
  ]
  assert_equal(expected4, result4)

  # Todd's division must return the same result
  const result5 = From(Subscription)->Divide(Session)->SortBy('student')
  const expected5 = [
    {'student': '123'},
    {'student': '283'},
  ]
  assert_equal(expected5, result5)

  assert_equal(subscription_instance, subscription)
  assert_equal(session_instance, session)
enddef

def Test_RA_Divide()
  const SP = [  # Supplier S# supplies part P#
    {'S#': 1, 'P#': 10},
    {'S#': 1, 'P#': 20},
    {'S#': 1, 'P#': 30},
    {'S#': 2, 'P#': 10},
    {'S#': 2, 'P#': 20},
    {'S#': 3, 'P#': 20},
    {'S#': 3, 'P#': 40},
  ]
  const PJ = [  # Part P# is used in project J#
    {'P#': 10, 'J#': 100},
    {'P#': 20, 'J#': 100},
    {'P#': 20, 'J#': 200},
    {'P#': 30, 'J#': 200},
    {'P#': 20, 'J#': 300},
    {'P#': 40, 'J#': 300},
  ]
  # Find the pairs {S,J} such that
  # supplier S supplies all the parts used in project J:
  const result = Query(From(SP)->Divide(PJ))
  const expected = [
    {'S#': 1, 'J#': 100},
    {'S#': 1, 'J#': 200},
    {'S#': 2, 'J#': 100},
    {'S#': 3, 'J#': 300},
  ]
  assert_true(RelEq(expected, result),
    printf("Expected %s, but got %s", expected, result))

  # Find the pairs {J,S} such that
  # project J uses all the parts supplied by supplier S
  const result2 = Query(From(PJ)->Divide(SP))
  const expected2 = [
    {'J#': 100, 'S#': 2},
    {'J#': 300, 'S#': 3},
  ]

  assert_true(RelEq(expected2, result2),
    printf("Expected %s, but got %s", expected2, result2))

  const PJEmpty = Rel.new('PJ', {'P#': Int, 'J#': Int}, [['J#', 'P#']])

  assert_equal([], Query(From(SP)->Divide(PJEmpty)))
  assert_equal([], Query(From(SP)->Divide([])))
enddef

def Test_RA_EmptyKey()
  RR = Rel.new('RR', {'A': Int, 'B': Str}, [[]])

  AssertFails("RR.Key([])", "Key [] already defined in RR")
  AssertFails("RR.Insert({})",
    "Expected a tuple on schema {A: integer, B: string}: got {} instead")

  RR.Insert({A: 1, B: 'x'})

  assert_equal([{A: 1, B: 'x'}], RR.instance)
  AssertFails("RR.Insert({A: 2, B: 'y'})", "Duplicate key")

  RR.Delete()
  RR.Insert({A: 2, B: 'y'})

  assert_equal([{A: 2, B: 'y'}], RR.instance)
enddef

def Test_RA_DivideEdgeCases()
  # For further edge cases, see Test_RA_DeeDum()
  assert_equal([],       Query(From([{X: 1}])->Divide([])))
  assert_equal([],       Query(From([{X: 1, Y: 2}])->Divide([])))
  assert_equal([],       Query(From([])->Divide([{Y: 1}])))
  assert_equal([],       Query(From([])->Divide([{Y: 1, Z: 2}])))
  assert_equal([{}],     Query(From([{Y: 1}])->Divide([{Y: 1}])))
  assert_equal([{}],     Query(From([{Y: 1}, {Y: 2}])->Divide([{Y: 1}])))
  assert_equal([{Z: 2}], Query(From([{Y: 1}])->Divide([{Y: 1, Z: 2}])))
  assert_equal([{Z: 2}], Query(From([{Y: 1}, {Y: 2}])->Divide([{Y: 1, Z: 2}])))
enddef

def Test_RA_DeeDum()
  RR = Rel.new('Dee', {}, [[]])
  assert_equal(0, len(RR.instance))
  AssertFails("RR.Insert({A: 0})", "Expected a tuple on schema {}")

  RR.Insert({})

  assert_equal(1, len(RR.instance))
  AssertFails("RR.Insert({})", "Duplicate key")

  var Dum = Rel.new('Dum', {}, [[]])
  var Dee = RR
  const dum = Dum.instance
  const dee = Dee.instance
  const r   = [{A: 1}, {A: 2}]

  assert_equal([],   From(r)->NatJoin(dum)->Build(),           "r ⨝ dum")
  assert_equal(r,    From(r)->NatJoin(dee)->Build(),           "r ⨝ dee")
  assert_equal([],   From(dum)->NatJoin(r)->Build(),           "dum ⨝ r")
  assert_equal(r,    From(dee)->NatJoin(r)->Build(),           "dee ⨝ r")

  assert_equal([],   From(dum)->NatJoin(dum)->Build(),         "dum ⨝ dum")
  assert_equal([],   From(dum)->NatJoin(dee)->Build(),         "dum ⨝ dee")
  assert_equal([],   From(dee)->NatJoin(dum)->Build(),         "dee ⨝ dum")
  assert_equal([{}], From(dee)->NatJoin(dee)->Build(),         "dee ⨝ dee")

  assert_equal([],           From(dum)->Select((t) => true)->Build(),              "σ[true](dum)")
  assert_equal([],           From(dum)->Select((t) => false)->Build(),             "σ[false](dum)")
  assert_equal([{}],         From(dee)->Select((t) => true)->Build(),              "σ[true](dee)")
  assert_equal([],           From(dee)->Select((t) => false)->Build(),             "σ[false](dee)")

  assert_equal([],           From(dum)->Project([])->Build(),                      "π[](dum)")
  assert_equal([{}],         From(dee)->Project([])->Build(),                      "π[](dee)")

  assert_equal([],           From(dum)->Product(dum)->Build(),                     "dum × dum")
  assert_equal([],           From(dum)->Product(dee)->Build(),                     "dum × dee")
  assert_equal([],           From(dee)->Product(dum)->Build(),                     "dee × dum")
  assert_equal([{}],         From(dee)->Product(dee)->Build(),                     "dee × dee")

  assert_equal([],           From(dum)->Intersect(dum)->Build(),                   "dum ∩ dum")
  assert_equal([],           From(dum)->Intersect(dee)->Build(),                   "dum ∩ dee")
  assert_equal([],           From(dee)->Intersect(dum)->Build(),                   "dee ∩ dum")
  assert_equal([{}],         From(dee)->Intersect(dee)->Build(),                   "dee ∩ dee")

  assert_equal([],           From(dum)->Minus(dum)->Build(),                       "dum - dum")
  assert_equal([],           From(dum)->Minus(dee)->Build(),                       "dum - dee")
  assert_equal([{}],         From(dee)->Minus(dum)->Build(),                       "dee - dum")
  assert_equal([],           From(dee)->Minus(dee)->Build(),                       "dee - dee")

  assert_equal([],           From(dum)->SemiJoin(dum, (t1, t2) => true)->Build(),  "dum ⋉ dum")
  assert_equal([],           From(dum)->SemiJoin(dee, (t1, t2) => true)->Build(),  "dum ⋉ dee")
  assert_equal([],           From(dee)->SemiJoin(dum, (t1, t2) => true)->Build(),  "dee ⋉ dum")
  assert_equal([{}],         From(dee)->SemiJoin(dee, (t1, t2) => true)->Build(),  "dee ⋉ dee")

  assert_equal([],           From(dum)->AntiJoin(dum, (t1, t2) => true)->Build(),  "dum ▷ dum")
  assert_equal([],           From(dum)->AntiJoin(dee, (t1, t2) => true)->Build(),  "dum ▷ dee")
  assert_equal([{}],         From(dee)->AntiJoin(dum, (t1, t2) => true)->Build(),  "dee ▷ dum")
  assert_equal([],           From(dee)->AntiJoin(dee, (t1, t2) => true)->Build(),  "dee ▷ dee")

  assert_equal([],           From(dum)->GroupBy([], Count, 'agg')->Build(), "dum group by []")
  assert_equal([{'agg': 1}], From(dee)->GroupBy([], Count, 'agg')->Build(), "dee group by []")

  assert_equal([],           From(dum)->CoddDivide(dum)->Build(),           "dum ÷ dum")
  assert_equal([],           From(dum)->CoddDivide(dee)->Build(),           "dum ÷ dee")
  assert_equal([{}],         From(dee)->CoddDivide(dum)->Build(),           "dee ÷ dum")
  assert_equal([{}],         From(dee)->CoddDivide(dee)->Build(),           "dee ÷ dee")

  assert_equal([],           From(dum)->Divide(dum)->Build(),               "dum ÷ dum")
  assert_equal([],           From(dum)->Divide(dee)->Build(),               "dum ÷ dee")
  # Todd's division returns [] whenever the divisor is empty
  assert_equal([],           From(dee)->Divide(dum)->Build(),               "dee ÷ dum")
  assert_equal([{}],         From(dee)->Divide(dee)->Build(),               "dee ÷ dee")
enddef

def Test_RA_Zip()
  assert_equal({A: 7, B: 'v'}, Zip(['A', 'B'], [7, 'v']))
  # If the second list is longer than the first items in excess are ignored:
  assert_equal({X: 9}, Zip(['X'], [9, 8, 7]))
enddef

def Test_RA_Filter()
  var R = Rel.new('R', {A: Int, B: Int}, [['A']]).InsertMany([
    {A: 0, B: 10},
    {A: 2, B: 30},
    {A: 1, B: 20},
    {A: 3, B: 40},
  ])

  const expected = [{A: 2, B: 30}, {A: 3, B: 40}]
  assert_equal(expected, R->Filter((t) => t.B > 20))

  const expected2 = [{A: 2, B: 30}]
  assert_equal(expected2, Filter(expected, (t) => t.A == 2))
enddef

def Test_RA_Table()
  var R = Rel.new("R", {AAAAAAAAA: Int, B: Str}, [["AAAAAAAAA"]])

  var expectedTable =<< END
 Empty Instance
================
END

  assert_equal(expectedTable, split(Table(R, 'Empty Instance', '='), "\n"))

  R.InsertMany([
    {AAAAAAAAA: 1, B: 'XYWZ'},
    {AAAAAAAAA: 2, B: 'ABC'},
  ])

  expectedTable =<< END
 R
────────────────
    B AAAAAAAAA
────────────────
 XYWZ         1
  ABC         2
END

  assert_equal(expectedTable, split(Table(R), "\n"))

  expectedTable =<< END
 Very Long Table Name
──────────────────────
          B AAAAAAAAA
──────────────────────
       XYWZ         1
        ABC         2
END

  assert_equal(expectedTable, split(Table(R, 'Very Long Table Name'), "\n"))
enddef


def Test_RA_PrettyPrintUnicode()
  var R = Rel.new("R", {'🙂☀︎': Int, '✔︎✖︎': Str}, [['✔︎✖︎']])

  R.InsertMany([
    {'🙂☀︎': 9, '✔︎✖︎': '⌘'},
    {'🙂☀︎': 99, '✔︎✖︎': '►◀︎└┴┴┴┘'},
  ])

  const expectedTable =<< END
 R
─────────────
      ✔︎✖︎ 🙂☀︎
─────────────
       ⌘   9
 ►◀︎└┴┴┴┘  99
END

  assert_equal(expectedTable, split(Table(R), "\n"))
enddef

tt.Run('_RA_')
