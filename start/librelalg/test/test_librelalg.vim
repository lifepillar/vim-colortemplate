vim9script

import 'librelalg.vim' as ra
import 'libtinytest.vim' as tt

const AntiJoin             = ra.AntiJoin
const Attributes           = ra.Attributes
const Avg                  = ra.Avg
const AvgBy                = ra.AvgBy
const Bind                 = ra.Bind
const Bool                 = ra.Bool
const Build                = ra.Build
const Check                = ra.Check
const CoddDivide           = ra.CoddDivide
const Count                = ra.Count
const CountBy              = ra.CountBy
const CountDistinct        = ra.CountDistinct
const Delete               = ra.Delete
const Descriptors          = ra.Descriptors
const Divide               = ra.Divide
const Empty                = ra.Empty
const Extend               = ra.Extend
const EquiJoin             = ra.EquiJoin
const EquiJoinPred         = ra.EquiJoinPred
const Filter               = ra.Filter
const FilteredScan         = ra.FilteredScan
const Float                = ra.Float
const ForeignKey           = ra.ForeignKey
const Frame                = ra.Frame
const GroupBy              = ra.GroupBy
const Key                  = ra.Key
const In                   = ra.In
const Insert               = ra.Insert
const InsertMany           = ra.InsertMany
const Int                  = ra.Int
const Intersect            = ra.Intersect
const Join                 = ra.Join
const KeyAttributes        = ra.KeyAttributes
const LeftNatJoin          = ra.LeftNatJoin
const LimitScan            = ra.LimitScan
const Lookup               = ra.Lookup
const Max                  = ra.Max
const MaxBy                = ra.MaxBy
const Min                  = ra.Min
const MinBy                = ra.MinBy
const Minus                = ra.Minus
const NatJoin              = ra.NatJoin
const Noop                 = ra.Noop
const NotIn                = ra.NotIn
const Product              = ra.Product
const Project              = ra.Project
const Query                = ra.Query
const Relation             = ra.Relation
const RelEq                = ra.RelEq
const Rename               = ra.Rename
const Scan                 = ra.Scan
const Select               = ra.Select
const SemiJoin             = ra.SemiJoin
const Sort                 = ra.Sort
const SortBy               = ra.SortBy
const Str                  = ra.Str
const Sum                  = ra.Sum
const SumBy                = ra.SumBy
const Table                = ra.Table
const Update               = ra.Update
const Union                = ra.Union
const Zip                  = ra.Zip

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
var RR: dict<any>
var SS: dict<any>

def Test_RA_CreateEmptyRelation()
  # Every relation must have at least one key
  AssertFails("Relation('R', {A: Int, B: Str}, [])", "No key")

  var R = Relation('R', {A: Int, B: Str}, [['A']])

  assert_true(R->has_key('name'),        "R does not have key 'name'")
  assert_true(R->has_key('schema'),      "R does not have key 'schema'")
  assert_true(R->has_key('instance'),    "R does not have key 'instance'")
  assert_true(R->has_key('keys'),        "R does not have key 'keys'")
  assert_true(R->has_key('indexes'),     "R does not have key 'indexes'")
  assert_true(R->has_key('constraints'), "R does not have key 'constraints'")
  assert_equal('R', R.name)
  assert_equal({A: Int, B: Str}, R.schema)
  assert_equal(v:t_list, type(R.instance))
  assert_true(Empty(R), "R instance is not empty")
  assert_equal([['A']], R.keys)
  assert_equal(1, len(keys(R.indexes)))
  assert_equal("['A']", keys(R.indexes)[0])
  assert_true(!empty(R.constraints.I), "R does not have any insertion constraint")
  assert_true(!empty(R.constraints.U), "R does not have any update constraint")
  assert_true(empty(R.constraints.D),  "R should not have any delete constraint")
  assert_equal(['A', 'B'], sort(Attributes(R)))
  assert_equal(['A'], KeyAttributes(R))
  assert_equal(['B'], Descriptors(R))
enddef

def Test_RA_KeyCannotBeRedefined()
  RR = Relation('RR', {A: Int, B: Str}, [['A']])
  AssertFails('Key(RR, ["A"])', "Key ['A'] already defined in RR")
  Key(RR, ["B"])
  Key(RR, ["A", "B"])  # Superkeys are also allowed
  assert_equal([["A"], ["B"], ["A", "B"]], RR.keys)
enddef

def Test_RA_WrongKey()
  AssertFails("Relation('RR', {A: Int}, [['B']])", "B is not an attribute of RR")
enddef

def Test_RA_Insert()
  RR = Relation('RR', {A: Int, B: Str, C: Bool, D: Float}, [['A', 'C']])
       ->Insert({A: 0, B: 'b0', C: true, D: 1.2})

  assert_equal(1, len(RR.instance))

  RR->Insert({A: 0, B: 'b1', C: false, D: 0.2})

  assert_equal(2, len(RR.instance))
  assert_equal(
    [{A: 0, B: 'b0', C: true, D: 1.2}, {A: 0, B: 'b1', C: false, D: 0.2}],
    RR.instance
  )

  AssertFails("RR->Insert({A: 0, B: 'b2', C: true, D: 3.5})", 'Duplicate key')
  AssertFails("RR->Insert({A: 9})", 'Expected a tuple on schema')
  AssertFails("RR->Insert({A: false, B: 'b3', C: false, D: 7.0})",
              "Attribute A is of type integer, but value 'false' of type boolean")
  AssertFails("RR->Insert({A: 9, B: 9, C: false, D: 'tsk'})",
              "Attribute B is of type string, but value '9' of type integer")
  AssertFails("RR->Insert({A: 9, B: 'b3', C: 3.2, D: 'tsk'})",
              "Attribute C is of type boolean, but value '3.2' of type float")
  AssertFails("RR->Insert({A: 9, B: 'b3', C: false, D: 'tsk'})",
              "Attribute D is of type float, but value 'tsk' of type string")

  assert_equal(
    [{A: 0, B: 'b0', C: true, D: 1.2}, {A: 0, B: 'b1', C: false, D: 0.2}],
    RR.instance
  )
enddef

def Test_RA_Update()
  RR = Relation('RR', {A: Int, B: Str, C: Bool, D: Str}, [['A'], ['B', 'C']])
  const rr = RR.instance
  RR->InsertMany([
    {A: 0, B: 'x', C: true, D: 'd1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
  ])

  RR->Update({A: 0, B: 'x', C: true, D: 'new-d1'})
  RR->Update({A: 1, B: 'x', C: false, D: 'new-d2'})

  const expected = [
    {A: 0, B: 'x', C: true, D: 'new-d1'},
    {A: 1, B: 'x', C: false, D: 'new-d2'},
  ]

  assert_equal(expected, rr)
  AssertFails("RR->Update({A: 0, B: 'x', C: false, D: ''})",
              "Key attribute C in RR cannot be changed")
  AssertFails("RR->Update({A: 2, B: 'y', C: true, D: 'd3'})",
              "Tuple with ['A'] = [2] not found in RR")
enddef

def Test_RA_Upsert()
  RR = Relation('RR', {A: Int, B: Str, C: Bool, D: Str}, [['A'], ['B', 'C']])
  const rr = RR.instance
  RR->InsertMany([
    {A: 0, B: 'x', C: true, D: 'd1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
  ])

  RR->Update({A: 2, B: 'y', C: true, D: 'd3'}, true)
  RR->Update({A: 0, B: 'x', C: true, D: 'new-d1'}, true)

  const expected = [
    {A: 0, B: 'x', C: true, D: 'new-d1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
    {A: 2, B: 'y', C: true, D: 'd3'},
  ]

  assert_equal(expected, rr)

  AssertFails("RR->Update({A: 0, B: 'x', C: false, D: ''})",
              "Key attribute C in RR cannot be changed")
enddef

def Test_RA_Delete()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const empty_indexes = deepcopy(R.indexes)
  const r = R.instance

  R->InsertMany([
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

  R->Delete((t) => t.B == 'X')

  assert_equal(expected1, r)

  R->Delete((t) => t.A == 2 || t.A == 3)

  assert_equal(expected2, r)

  R->Delete()

  assert_equal([], r)
  assert_equal(empty_indexes, R.indexes)
enddef

def Test_RA_DeleteForeignKey()
  RR = Relation('R', {A: Int}, [['A']])
  SS = Relation('S', {X: Str, Y: Int}, [['X']])
  ForeignKey(SS, ['Y'], RR, ['A'])
  RR->Insert({A: 2})
  SS->Insert({X: 'a', Y: 2})

  AssertFails("RR->Delete()",
    "R has S: R['A'] = (2) is referenced by {'X': 'a', 'Y': 2} in S['Y']")

  SS->Delete()
  RR->Delete()

  assert_true(RR->Empty())
enddef

def Test_RA_Index()
  const key = ['A', 'B']
  const keyStr = string(key)
  var R = Relation('R', {A: Int, B: Str}, [key])

  assert_equal(1, len(R.indexes))

  const index = R.indexes[keyStr]

  assert_equal({}, index)

  const t0 = {A: 9, B: 'veni'}
  const t1 = {A: 3, B: 'vici'}
  const t2 = {A: 9, B: 'vidi'}
  R->Insert(t0)
  R->Insert(t1)
  R->Insert(t2)

  assert_equal({'3': { 'vici': t1 },
                '9': { 'veni': t0, 'vidi': t2 }}, index)

  assert_true(index[3]['vici'] is t1)
  assert_true(index[9]['veni'] is t0)
  assert_true(index[9]['vidi'] is t2)

  R->Delete((t) => t.A == 9 && t.B == 'veni')

  assert_equal({'3': { 'vici': t1 },
                '9': { 'vidi': t2 }}, index)

  R->Delete((t) => t.B == 'vici')

  assert_equal({'9': { 'vidi': t2 }}, index)

  R->Delete()

  assert_equal({}, index)
enddef

def Test_RA_ForeignKey()
  RR = Relation('RR', {A: Str}, [['A']])
  SS = Relation('SS', {B: Int, C: Str}, [['B']])

  AssertFails("ForeignKey(SS, ['B', 'C'], RR, ['A'])",
              "Wrong foreign key size: SS['B', 'C'] -> RR['A']")
  AssertFails("ForeignKey(SS, ['C'], RR, ['C'])",
              "Wrong foreign key: SS['C'] -> RR['C']. ['C'] is not a key of RR")
  AssertFails("ForeignKey(SS, ['A'], RR, ['A'])",
              "Wrong foreign key: SS['A'] -> RR['A']. A is not an attribute of SS")

  ForeignKey(SS, ['C'], RR, ['A'], 'constrains')

  RR->InsertMany([
    {A: 'ab'},
    {A: 'tm'}
  ])
  SS->Insert({B: 10, C: 'tm'})
  SS->Insert({B: 20, C: 'tm'})
  SS->Insert({B: 30, C: 'ab'})

  AssertFails("SS->Insert({B: 40, C: 'xy'})",
              "RR constrains SS: SS['C'] = ('xy') is not present in RR['A']")

  SS->Update({B: 20, C: 'ab'})

  AssertFails("SS->Update({B: 30, C: 'wz'})",
              "RR constrains SS: SS['C'] = ('wz') is not present in RR['A']")

  const expected = [
    {B: 10, C: 'tm'},
    {B: 20, C: 'ab'},
    {B: 30, C: 'ab'},
  ]
  assert_equal(expected, SS.instance)
enddef

def Test_RA_GenericConstraint()
  RR = Relation('R', {A: Int, B: Int}, [['A']])

  def Positive(t: dict<any>): bool
    return t.B > 0
  enddef

  Check(RR, Positive, 'B must be positive')

  RR->Insert({A: 1, B: 2})

  AssertFails("RR->Insert({A: 2, B: -1})",
    "{'A': 2, 'B': -1} violates a constraint of R: B must be positive")

  RR->Update({A: 1, B: 3})

  AssertFails("RR->Update({A: 1, B: -2})",
    "{'A': 1, 'B': -2} violates a constraint of R: B must be positive")

  assert_equal([{A: 1, B: 3}], RR.instance)

  RR->Delete()

  assert_true(Empty(RR))
enddef

def Test_RA_In()
  const R = Relation('R', {A: Str, B: Int}, [['A']])
  R->InsertMany([
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
  var R = Relation('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R->InsertMany(instance)

  const result1 = Query(Scan(R))
  const result2 = Query(Scan(R.instance))

  const expected = instance

  assert_equal(expected, result1)
  assert_equal(expected, result2)
  assert_equal(instance, R.instance)
enddef

def Test_RA_FilteredScan()
  var R = Relation('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R->InsertMany(instance)

  const expected = [{A: 2, B: 0.0, C: false, D: 'tuple2'}]
  const result = Query(FilteredScan(R, (t) => !t.C && t.B >= 0))

  assert_equal(expected, result)
  assert_equal(instance, R.instance)
enddef

def Test_RA_LimitScan()
  var R = Relation('R', {A: Int}, [['A']])
          ->InsertMany([{A: 1}, {A: 2}, {A: 3}, {A: 4}])

  assert_equal([{A: 1}], Query(LimitScan(R, 1)))
  assert_equal([{A: 1}, {A: 2}], Query(LimitScan(R, 2)))
  assert_equal([{A: 1}, {A: 2}, {A: 3}], Query(LimitScan(R, 3)))
  assert_equal(R.instance, Query(LimitScan(R, 4)))
  assert_equal(R.instance, Query(LimitScan(R, 5)))
enddef

def Test_RA_Sort()
  var R = Relation('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])
  const r = R.instance

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R->InsertMany(instance)

  const Cmp = (t1, t2) => t1.B == t2.B ? 0 : t1.B > t2.B ? 1 : -1

  const expected = [
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  assert_equal(expected, Scan(r)->Sort(Cmp))
  assert_equal(expected, Scan(r)->SortBy(['B']))
  assert_equal(R.instance, r)
  assert_equal(instance, R.instance)
enddef

def Test_RA_SortByAscDesc()
  var R = Relation('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])
  const r = R.instance

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R->InsertMany(instance)

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

  assert_equal(expected1, Scan(r)->SortBy(['B'], ['i']))
  assert_equal(expected2, Scan(r)->SortBy(['B'], ['d']))
  assert_equal(expected3, Scan(r)->SortBy(['C', 'B'], ['i', 'd']))
  assert_equal(expected4, Scan(r)->SortBy(['C', 'B'], ['i', 'i']))
  assert_equal(expected5, Scan(r)->SortBy(['C', 'B'], ['d', 'i']))
  assert_equal(expected6, Scan(r)->SortBy(['C', 'B'], ['d', 'd']))
  assert_equal(R.instance, r)
  assert_equal(instance, R.instance)
enddef

def Test_RA_Noop()
  var R = Relation('R', {A: Int}, [['A']])

  R->Insert({A: 42})

  assert_equal(Query(Scan(R)), Query(Scan(R)->Noop()->Noop()))
enddef

def Test_RA_Rename()
  var R = Relation('R', {A: Str, B: Float, C: Int}, [['A']])
  const r = R.instance

  const instance = [
    {A: 'a1', B: 4.0, C: 40},
    {A: 'a2', B: 2.0, C: 80},
  ]
  R->InsertMany(instance)

  const expected = [
    {X: 'a1', B: 4.0, W: 40},
    {X: 'a2', B: 2.0, W: 80},
  ]

  assert_equal(instance, Scan(R)->Rename([], [])->Build())
  assert_equal(expected, Scan(R)->Rename(['A', 'C'], ['X', 'W'])->Build())
  assert_equal(instance, r)
enddef

def Test_RA_Select()
  var R = Relation('R', {A: Str, B: Float, C: Int}, [['A']])
  const r = R.instance

  const instance = [
    {A: 'a1', B: 4.0, C: 40},
    {A: 'a2', B: 2.0, C: 80},
    {A: 'a3', B: 9.0, C: 10},
    {A: 'a4', B: 5.0, C: 80},
    {A: 'a5', B: 4.0, C: 20},
  ]
  R->InsertMany(instance)

  const expected1 = [
    {A: 'a1', B: 4.0, C: 40},
  ]
  const expected2 = [
    {A: 'a5', B: 4.0, C: 20},
  ]

  assert_equal(expected1, Query(Scan(r)->Select((t) => t.C == 40)))
  assert_equal(expected2, Query(Scan(r)->Select((t) => t.B <= 4.0 && t.A == 'a5')))
  assert_equal([], Query(Scan(r)->Select((t) => t.B > 9.0)))
  assert_equal(instance, r)
enddef

def Test_RA_Project()
  var R = Relation('R', {A: Str, B: Bool, C: Int}, [['A']])
  const r = R.instance

  const instance = [
    {A: 'a1', B: true,  C: 40},
    {A: 'a2', B: false, C: 80},
    {A: 'a3', B: true,  C: 40},
    {A: 'a4', B: true,  C: 80},
    {A: 'a5', B: false, C: 20},
  ]
  R->InsertMany(instance)

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

  assert_equal([], Query(Scan([])->Project(['X'])))
  assert_equal([], Query(Scan([])->Project([])))
  assert_equal([{}], Query(Scan([{}])->Project([])))
  assert_equal([{}], Query(Scan(r)->Project([])))
  assert_equal(expected1, Scan(r)->Project(['A'])->SortBy(['A']))
  assert_equal(expected2, Scan(r)->Project(['B'])->SortBy(['B']))
  assert_equal(expected3, Scan(r)->Project(['B', 'C'])->SortBy(['B', 'C']))
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
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    ]
  R->InsertMany(instanceR)

  var S = Relation('S', {B: Str, C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0},
  ]
  S->InsertMany(instanceS)


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

  assert_equal(expected1, Scan(R)->Join(S, (rt, st) => rt.B == st.B, 'r_')->SortBy(['r_A']))
  assert_equal(expected2, Scan(S)->Join(R, (st, rt) => rt.B == st.B, 's_')->SortBy(['A']))
  assert_equal(expected3, Scan(R)->Join(S, (rt, st) => rt.A <= st.C, 'r_')->SortBy(['r_A', 'B']))
  assert_equal(expected4, Scan(S)->Join(R, (st, rt) => rt.A <= st.C, 's_')->SortBy(['s_C', 'A']))
  assert_equal(expected5, Scan(S)->Join(S, (s1, s2) => s1.C >= s2.C && s2.C == 0, 's_')->SortBy(['B']))

  assert_equal(expected1, Scan(R)->EquiJoin(S, ['B'], ['B'], 'r_')->SortBy(['r_A']))
  assert_equal(expected2, Scan(S)->EquiJoin(R, ['B'], ['B'], 's_')->SortBy(['A']))

  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_NatJoin()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    ]
  R->InsertMany(instanceR)

  var S = Relation('S', {B: Str, C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0},
  ]
  S->InsertMany(instanceS)

  var T = Relation('T', {D: Int}, [['D']])
  const t = T.instance

  const instanceT = [
    {D: 8},
    {D: 9},
  ]
  T->InsertMany(instanceT)

  var U = Relation('U', {A: Int, B: Str}, [['A', 'B']])
  const u = U.instance

  const instanceU = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  U->InsertMany(instanceU)

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

  assert_equal(expected1, Query(Scan(R)->NatJoin(S)))
  assert_equal(expected1, Query(Scan(S)->NatJoin(R)))
  assert_equal(expected2, Query(Scan(S)->NatJoin(T)))
  assert_equal(r, Query(Scan(R)->NatJoin(R)))
  assert_equal([{A: 1, B: 'one'}], Query(Scan(R)->NatJoin(U)))
  assert_equal([{A: 1, B: 'one'}], Query(Scan(U)->NatJoin(R)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
  assert_equal(instanceT, t)
  assert_equal(instanceU, u)
enddef

def Test_RA_Product()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
    ]
  R->InsertMany(instanceR)

  var S = Relation('S', {C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {C: 10},
    {C: 90},
  ]
  S->InsertMany(instanceS)

  assert_equal([], Query(Scan([])->Product([])))
  assert_equal([], Query(Scan(R)->Product([])))
  assert_equal([], Query(Scan([])->Product(R)))
  assert_equal(r, Query(Scan(R)->Product([{}])))

  const expected = [
    {A: 0, B: 'zero', C: 10},
    {A: 0, B: 'zero', C: 90},
    {A: 1, B: 'one',  C: 10},
    {A: 1, B: 'one',  C: 90},
    {A: 2, B: 'two',  C: 10},
    {A: 2, B: 'two',  C: 90},
  ]

  assert_equal(expected, Scan(R)->Product(S)->SortBy(['A', 'C']))
  assert_equal(expected, Scan(S)->Product(R)->SortBy(['A', 'C']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_Intersect()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.instance

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  S->InsertMany(instanceS)

  assert_equal([{A: 1, B: 'one'}], Query(Scan(R)->Intersect(S)))
  assert_equal([{A: 1, B: 'one'}], Query(Scan(S)->Intersect(R)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_Minus()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.instance

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  S->InsertMany(instanceS)

  const expected1 = [
    {A: 0, B: 'zero'},
    {A: 2, B: 'one'},
  ]
  const expected2 = [
    {A: 0, B: 'many'},
    {A: 2, B: 'two'},
  ]

  assert_equal(expected1, Scan(R)->Minus(S)->SortBy(['A']))
  assert_equal(expected2, Scan(S)->Minus(R)->SortBy(['A']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_Union()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.instance

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 3, B: 'one'},
  ]
  S->InsertMany(instanceS)

  const expected = [
    {A: 0, B: 'many'},
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    {A: 3, B: 'one'},
  ]

  assert_equal(expected, Scan(R)->Union(S)->SortBy(['A', 'B']))
  assert_equal(expected, Scan(S)->Union(R)->SortBy(['A', 'B']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_SemiJoin()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {B: Str, C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0}
  ]
  S->InsertMany(instanceS)

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

  assert_equal(expected1, Scan(R)->SemiJoin(S, (rt, st) => rt.B == st.B)->SortBy(['A']))
  assert_equal(expected2, Query(Scan(S)->SemiJoin(R, (st, rt) => rt.B == st.B)))
  assert_equal(expected3, Scan(R)->SemiJoin(S, (rt, st) => rt.A <= st.C)->SortBy(['A']))
  assert_equal(expected4, Scan(S)->SemiJoin(R, (st, rt) => rt.A <= st.C)->SortBy(['B']))
  assert_equal(expected5, Query(Scan(S)->SemiJoin(S, (s1, s2) => s1.C >= s2.C && s2.C == 0)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_AntiJoin()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const r = R.instance

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {B: Str, C: Int}, [['C']])
  const s = S.instance

  const instanceS = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0},
  ]
  S->InsertMany(instanceS)

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

  assert_equal(expected1, Query(Scan(R)->AntiJoin(S, (rt, st) => rt.B == st.B)))
  assert_equal(expected2, Query(Scan(S)->AntiJoin(R, (st, rt) => rt.B == st.B)))
  assert_equal(expected3, SortBy(Scan(R)->AntiJoin(S, (rt, st) => rt.A <= st.C), ['A']))
  assert_equal(expected4, SortBy(Scan(S)->AntiJoin(R, (st, rt) => rt.A <= st.C), ['B']))
  assert_equal(expected5, Query(Scan(S)->AntiJoin(S, (s1, s2) => s1.C > s2.C)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_LeftNatJoin()
  var Buffer = Relation('Buffer', {
      BufId:   Int,
      BufName:  Str,
    },
    [['BufId'], ['BufName']]
  )

  var Tag = Relation('Tag', {
      BufId:   Int,
      TagName: Str,
      Line:    Int,
      Column:  Int,
    },
    [['BufId', 'TagName']]
  )

  Buffer->InsertMany([
    {BufId: 1, BufName: 'foo'},
    {BufId: 2, BufName: 'bar'},
    {BufId: 3, BufName: 'xyz'},
  ])

  Tag->InsertMany([
    {BufId: 1, TagName: 'abc', Line: 3,  Column: 9},
    {BufId: 1, TagName: 'xyz', Line: 4,  Column: 1},
    {BufId: 1, TagName: 'lll', Line: 4,  Column: 8},
    {BufId: 2, TagName: 'abc', Line: 14, Column: 15},
  ])

  const summary = Query(Scan(Tag)->GroupBy(['BufId'], Count, 'num_tags'))
  const result = Query(Scan(Buffer)->LeftNatJoin(summary, [{'num_tags': 0}]))
  const expected = [
    {BufId: 1, BufName: 'foo', num_tags: 3},
    {BufId: 2, BufName: 'bar', num_tags: 1},
    {BufId: 3, BufName: 'xyz', num_tags: 0},
  ]

  assert_true(RelEq(result, expected))
enddef

def Test_RA_Lookup()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
          ->InsertMany([{A: 1, B: 'x'}, {A: 3, B: 'y'}, {A: 5, B: 'z'}])

  assert_equal({A: 1, B: 'x'}, Lookup(R, ['A'], [1]))
  assert_equal({A: 3, B: 'y'}, Lookup(R, ['A'], [3]))
  assert_equal({A: 5, B: 'z'}, Lookup(R, ['A'], [5]))
enddef

def Test_RA_Extend()
  var R = Relation('R', {A: Int}, [['A']])
          ->InsertMany([{A: 1}, {A: 3}, {A: 5}])
  const expected = [
    {A: 1, B: 2,  C: 'ok'},
    {A: 3, B: 6,  C: 'ok'},
    {A: 5, B: 10, C: 'ok'},
  ]
  const result = Query(
    Scan(R)->Extend((t) => {
      return {B: t.A * 2, C: 'ok'}
    })
  )

  assert_equal(expected, result)
enddef

def Test_RA_Max()
  var R = Relation('R', {A: Int, B: Str, C: Float, D: Bool}, [['A']])
  const r = R.instance

  assert_equal(null, Scan(R)->Max('A'))
  assert_equal(null, Scan(R)->Max('B'))
  assert_equal(null, Scan(R)->Max('C'))
  assert_equal(null, Scan(R)->Max('D'))

  const instance = [
    {A: 0, B: "X", C: 10.0, D:  true},
    {A: 1, B: "Z", C:  2.5, D:  true},
    {A: 2, B: "Y", C: -3.0, D: false},
    {A: 3, B: "X", C:  1.5, D:  true},
    {A: 4, B: "Z", C:  2.5, D:  true},
  ]
  R->InsertMany(instance)

  assert_equal(4,    Scan(R)->Max('A'))
  assert_equal('Z',  Scan(R)->Max('B'))
  assert_equal(10.0, Scan(R)->Max('C'))
  assert_equal(true, Scan(R)->Max('D'))
  assert_equal(instance, r)
enddef

def Test_RA_Min()
  var R = Relation('R', {A: Int, B: Str, C: Float, D: Bool}, [['A']])
  const r = R.instance

  assert_equal(null, Scan(R)->Min('A'))
  assert_equal(null, Scan(R)->Min('B'))
  assert_equal(null, Scan(R)->Min('C'))
  assert_equal(null, Scan(R)->Min('D'))

  const instance = [
    {A: 0, B: "X", C: 10.0, D:  true},
    {A: 1, B: "Z", C:  2.5, D:  true},
    {A: 2, B: "Y", C: -3.0, D: false},
    {A: 3, B: "X", C:  1.5, D:  true},
    {A: 4, B: "Z", C:  2.5, D:  true},
  ]
  R->InsertMany(instance)

  assert_equal(0,     Scan(R)->Min('A'))
  assert_equal('X',   Scan(R)->Min('B'))
  assert_equal(-3.0,  Scan(R)->Min('C'))
  assert_equal(false, Scan(R)->Min('D'))
  assert_equal(instance, r)
enddef

def Test_RA_Sum()
  var R = Relation('R', {A: Int, B: Float}, [['A']])
  const r = R.instance

  assert_equal(0, Scan(R)->Sum('A'))
  assert_equal(0, Scan(R)->Sum('B'))

  const instance = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 2, B: -3.0},
    {A: 3, B:  1.5},
    {A: 4, B:  2.5},
  ]
  R->InsertMany(instance)

  assert_equal(10, Scan(R)->Sum('A'))
  assert_equal(v:t_number, type(Scan(R)->Sum('A')))
  assert_equal(13.5, Scan(R)->Sum('B'))
  assert_equal(v:t_float, type(Scan(R)->Sum('B')))
  assert_equal(instance, r)
enddef

def Test_RA_Avg()
  var R = Relation('R', {A: Int, B: Float}, [['A']])
  const r = R.instance

  assert_equal(null, Scan(R)->Avg('A'))
  assert_equal(null, Scan(R)->Avg('B'))

  const instance = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 2, B: -3.0},
    {A: 3, B:  1.5},
    {A: 4, B:  2.5},
  ]
  R->InsertMany(instance)

  assert_equal(2.0, Scan(R)->Avg('A'))
  assert_equal(v:t_float, type(Scan(R)->Avg('A')))
  assert_equal(2.7, Scan(R)->Avg('B'))
  assert_equal(v:t_float, type(Scan(R)->Avg('B')))
  assert_equal(instance, r)
enddef

def Test_RA_Count()
  const r = [
    {A: 0, B: 10.0},
    {A: 2, B:  2.5},
    {A: 2, B: -3.0},
    {A: 2, B:  1.5},
    {A: 4, B:  2.5},
    {A: 4, B:  2.5},
  ]

  assert_equal(0, Scan([])->Count())
  assert_equal(6, Scan(r)->Count())
enddef

def Test_RA_CountDistinct()
  const r = [
    {A: 0, B: 10.0},
    {A: 2, B:  2.5},
    {A: 2, B: -3.0},
    {A: 2, B:  1.5},
    {A: 4, B:  2.5},
    {A: 4, B:  2.5},
  ]

  assert_equal(0, Scan([])->CountDistinct('A'))
  assert_equal(3, Scan(r)->CountDistinct('A'))
  assert_equal(4, Scan(r)->CountDistinct('B'))
enddef

def Test_RA_SumBy()
  assert_equal([{sum: 0}],   Scan([])->SumBy([], 'A'))
  assert_equal([{summa: 0}], Scan([])->SumBy([], 'B', 'summa'))
  assert_equal([],           Scan([])->SumBy(['A'], 'A'))
  assert_equal([],           Scan([])->SumBy(['B'], 'A', 'summa'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{sum: 8}],   Scan(r)->SumBy([], 'A'))
  assert_equal([{sum: 13.5}], Scan(r)->SumBy([], 'B'))
  assert_equal([
    {A: 0, sum: 10.0},
    {A: 1, sum: -0.5},
    {A: 3, sum:  4.0},
  ], Scan(r)->SumBy(['A'], 'B'))
enddef

def Test_RA_CountBy()
  assert_equal([{count: 0}], Scan([])->CountBy([]))
  assert_equal([{count: 0}], Scan([])->CountBy([], 'A'))
  assert_equal([{cnt: 0}],   Scan([])->CountBy([], 'B', 'cnt'))
  assert_equal([],           Scan([])->CountBy(['A'], 'A'))
  assert_equal([],           Scan([])->CountBy(['B'], 'A', 'cnt'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{count: 5}], Scan(r)->CountBy([]))
  assert_equal([{count: 3}], Scan(r)->CountBy([], 'A'))
  assert_equal([{count: 4}], Scan(r)->CountBy([], 'B'))
  assert_equal([
    {A: 0, cnt: 1},
    {A: 1, cnt: 2},
    {A: 3, cnt: 2},
  ], Scan(r)->CountBy(['A'], null_string, 'cnt'))
  assert_equal([
    {A: 0, cnt: 1},
    {A: 1, cnt: 2},
    {A: 3, cnt: 2},
  ], Scan(r)->CountBy(['A'], 'B', 'cnt'))
enddef

def Test_RA_MaxBy()
  assert_equal([], Scan([])->MaxBy([], 'A'))
  assert_equal([], Scan([])->MaxBy([], 'B'))
  assert_equal([], Scan([])->MaxBy(['A'], 'A'))
  assert_equal([], Scan([])->MaxBy(['B'], 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{max: 3}],    Scan(r)->MaxBy([], 'A'))
  assert_equal([{max: 10.0}], Scan(r)->MaxBy([], 'B'))
  assert_equal([
    {A: 0, maximum: 10.0},
    {A: 1, maximum:  2.5},
    {A: 3, maximum:  2.5},
  ], Scan(r)->MaxBy(['A'], 'B', 'maximum'))
enddef

def Test_RA_MinBy()
  assert_equal([], Scan([])->MinBy([], 'A'))
  assert_equal([], Scan([])->MinBy([], 'B'))
  assert_equal([], Scan([])->MinBy(['A'], 'A'))
  assert_equal([], Scan([])->MinBy(['B'], 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{min: 0}],    Scan(r)->MinBy([], 'A'))
  assert_equal([{min: -3.0}], Scan(r)->MinBy([], 'B'))
  assert_equal([
    {A: 0, minimum: 10.0},
    {A: 1, minimum: -3.0},
    {A: 3, minimum:  1.5},
  ], Scan(r)->MinBy(['A'], 'B', 'minimum'))
enddef

def Test_RA_AvgBy()
  assert_equal([], Scan([])->AvgBy([], 'A'))
  assert_equal([], Scan([])->AvgBy([], 'B'))
  assert_equal([], Scan([])->AvgBy(['A'], 'A'))
  assert_equal([], Scan([])->AvgBy(['B'], 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{avg: 1.6}], Scan(r)->AvgBy([], 'A'))
  assert_equal([{avg: 2.7}], Scan(r)->AvgBy([], 'B'))
  assert_equal([
    {A: 0, average: 10.0},
    {A: 1, average: -0.25},
    {A: 3, average:  2.0},
  ], Scan(r)->AvgBy(['A'], 'B', 'average'))
enddef

def Test_RA_Frame()
  var R = Relation('R', {A: Int, B: Str, C: Str}, [['A']])
    ->InsertMany([
      {A: 10, B: 'a', C: 'x'},
      {A: 20, B: 'b', C: 'y'},
      {A: 30, B: 'a', C: 'x'},
      {A: 40, B: 'a', C: 'x'},
      {A: 50, B: 'b', C: 'x'},
      {A: 60, B: 'b', C: 'y'},
      {A: 70, B: 'a', C: 'y'},
    ])

  var result = Query(
    Scan(R)->Extend((t) => {
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

  result = Query(Scan(R)->Frame(['B', 'C']))
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
enddef

def Test_RA_GroupBy()
  var R = Relation('R', {id: Int, name: Str, balance: Float}, [['id']])
  const r = R.instance

  const instance = [
    {id: 0, name: "A", balance: 10.0},
    {id: 1, name: "A", balance:  2.5},
    {id: 2, name: "B", balance: -3.0},
    {id: 3, name: "A", balance:  1.5},
    {id: 4, name: "B", balance:  2.5},
  ]
  R->InsertMany(instance)

  const result = Scan(r)
               ->GroupBy(['name'], Bind(Sum, 'balance'), 'total')
               ->SortBy(['name'])

  const expected = [
    {name: 'A', total: 14.0},
    {name: 'B', total: -0.5},
  ]

  assert_equal(2, len(result))
  assert_equal(expected, result)
  assert_equal(instance, r)
enddef

def Test_RA_CoddDivide()
  var Subscription = Relation('Subscription',
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
  Subscription->InsertMany(subscription_instance)

  var Session = Relation('Session', {date: Str, course: Str}, [['date', 'course']])
  const result1 = Query(Scan(Subscription)->CoddDivide(Session))
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
  const result2 = Query(Scan(Subscription)->CoddDivide([]))
  const expected2 = subscription_instance
  # The schema can be given explicitly, though (for this special case only)
  const result3 = Query(Scan(Subscription)->CoddDivide([], ['date', 'course']))
  const expected3 = expected1

  assert_equal(expected2, result2)
  assert_equal(expected3, result3)

  const session = Session.instance
  const session_instance = [
    {date: '2019-12-05', course:        'Databases'},
    {date: '2020-12-05', course: 'Computer Science'},
    {date: '2021-12-05', course:          'Algebra'},
  ]
  Session->InsertMany(session_instance)

  # Which students are subscribed to all the courses?
  const result4 = Scan(Subscription)->CoddDivide(Session)->SortBy(['student'])
  const expected4 = [
    {'student': '123'},
    {'student': '283'},
  ]
  assert_equal(expected4, result4)

  # Todd's division must return the same result
  const result5 = Scan(Subscription)->Divide(Session)->SortBy(['student'])
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
  const result = Query(Scan(SP)->Divide(PJ))
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
  const result2 = Query(Scan(PJ)->Divide(SP))
  const expected2 = [
    {'J#': 100, 'S#': 2},
    {'J#': 300, 'S#': 3},
  ]

  assert_true(RelEq(expected2, result2),
    printf("Expected %s, but got %s", expected2, result2))

  const PJEmpty = Relation('PJ', {'P#': Int, 'J#': Int}, [['J#', 'P#']])

  assert_equal([], Query(Scan(SP)->Divide(PJEmpty)))
  assert_equal([], Query(Scan(SP)->Divide([])))
enddef

def Test_RA_EmptyKey()
  RR = Relation('RR', {'A': Int, 'B': Str}, [[]])

  AssertFails("Key(RR, [])", "Key [] already defined in RR")
  AssertFails("RR->Insert({})",
    "Expected a tuple on schema {A: integer, B: string}: got {} instead")

  RR->Insert({A: 1, B: 'x'})

  assert_equal([{A: 1, B: 'x'}], RR.instance)
  AssertFails("RR->Insert({A: 2, B: 'y'})", "Duplicate key")

  RR->Delete()
  RR->Insert({A: 2, B: 'y'})

  assert_equal([{A: 2, B: 'y'}], RR.instance)
enddef

def Test_RA_DivideEdgeCases()
  # For further edge cases, see Test_RA_DeeDum()
  assert_equal([],       Query(Scan([{X: 1}])->Divide([])))
  assert_equal([],       Query(Scan([{X: 1, Y: 2}])->Divide([])))
  assert_equal([],       Query(Scan([])->Divide([{Y: 1}])))
  assert_equal([],       Query(Scan([])->Divide([{Y: 1, Z: 2}])))
  assert_equal([{}],     Query(Scan([{Y: 1}])->Divide([{Y: 1}])))
  assert_equal([{}],     Query(Scan([{Y: 1}, {Y: 2}])->Divide([{Y: 1}])))
  assert_equal([{Z: 2}], Query(Scan([{Y: 1}])->Divide([{Y: 1, Z: 2}])))
  assert_equal([{Z: 2}], Query(Scan([{Y: 1}, {Y: 2}])->Divide([{Y: 1, Z: 2}])))
enddef

def Test_RA_DeeDum()
  RR = Relation('Dee', {}, [[]])
  assert_equal(0, len(RR.instance))
  AssertFails("RR->Insert({A: 0})", "Expected a tuple on schema {}")

  RR->Insert({})

  assert_equal(1, len(RR.instance))
  AssertFails("RR->Insert({})", "Duplicate key")

  var Dum = Relation('Dum', {}, [[]])
  var Dee = RR
  const dum = Dum.instance
  const dee = Dee.instance
  const r   = [{A: 1}, {A: 2}]

  assert_equal([],   Scan(r)->NatJoin(dum)->Build(),           "r ⨝ dum")
  assert_equal(r,    Scan(r)->NatJoin(dee)->Build(),           "r ⨝ dee")
  assert_equal([],   Scan(dum)->NatJoin(r)->Build(),           "dum ⨝ r")
  assert_equal(r,    Scan(dee)->NatJoin(r)->Build(),           "dee ⨝ r")

  assert_equal([],   Scan(dum)->NatJoin(dum)->Build(),         "dum ⨝ dum")
  assert_equal([],   Scan(dum)->NatJoin(dee)->Build(),         "dum ⨝ dee")
  assert_equal([],   Scan(dee)->NatJoin(dum)->Build(),         "dee ⨝ dum")
  assert_equal([{}], Scan(dee)->NatJoin(dee)->Build(),         "dee ⨝ dee")

  assert_equal([],           Scan(dum)->Select((t) => true)->Build(),              "σ[true](dum)")
  assert_equal([],           Scan(dum)->Select((t) => false)->Build(),             "σ[false](dum)")
  assert_equal([{}],         Scan(dee)->Select((t) => true)->Build(),              "σ[true](dee)")
  assert_equal([],           Scan(dee)->Select((t) => false)->Build(),             "σ[false](dee)")

  assert_equal([],           Scan(dum)->Project([])->Build(),                      "π[](dum)")
  assert_equal([{}],         Scan(dee)->Project([])->Build(),                      "π[](dee)")

  assert_equal([],           Scan(dum)->Product(dum)->Build(),                     "dum × dum")
  assert_equal([],           Scan(dum)->Product(dee)->Build(),                     "dum × dee")
  assert_equal([],           Scan(dee)->Product(dum)->Build(),                     "dee × dum")
  assert_equal([{}],         Scan(dee)->Product(dee)->Build(),                     "dee × dee")

  assert_equal([],           Scan(dum)->Intersect(dum)->Build(),                   "dum ∩ dum")
  assert_equal([],           Scan(dum)->Intersect(dee)->Build(),                   "dum ∩ dee")
  assert_equal([],           Scan(dee)->Intersect(dum)->Build(),                   "dee ∩ dum")
  assert_equal([{}],         Scan(dee)->Intersect(dee)->Build(),                   "dee ∩ dee")

  assert_equal([],           Scan(dum)->Minus(dum)->Build(),                       "dum - dum")
  assert_equal([],           Scan(dum)->Minus(dee)->Build(),                       "dum - dee")
  assert_equal([{}],         Scan(dee)->Minus(dum)->Build(),                       "dee - dum")
  assert_equal([],           Scan(dee)->Minus(dee)->Build(),                       "dee - dee")

  assert_equal([],           Scan(dum)->SemiJoin(dum, (t1, t2) => true)->Build(),  "dum ⋉ dum")
  assert_equal([],           Scan(dum)->SemiJoin(dee, (t1, t2) => true)->Build(),  "dum ⋉ dee")
  assert_equal([],           Scan(dee)->SemiJoin(dum, (t1, t2) => true)->Build(),  "dee ⋉ dum")
  assert_equal([{}],         Scan(dee)->SemiJoin(dee, (t1, t2) => true)->Build(),  "dee ⋉ dee")

  assert_equal([],           Scan(dum)->AntiJoin(dum, (t1, t2) => true)->Build(),  "dum ▷ dum")
  assert_equal([],           Scan(dum)->AntiJoin(dee, (t1, t2) => true)->Build(),  "dum ▷ dee")
  assert_equal([{}],         Scan(dee)->AntiJoin(dum, (t1, t2) => true)->Build(),  "dee ▷ dum")
  assert_equal([],           Scan(dee)->AntiJoin(dee, (t1, t2) => true)->Build(),  "dee ▷ dee")

  assert_equal([],           Scan(dum)->GroupBy([], Count, 'agg')->Build(), "dum group by []")
  assert_equal([{'agg': 1}], Scan(dee)->GroupBy([], Count, 'agg')->Build(), "dee group by []")

  assert_equal([],           Scan(dum)->Divide(dum)->Build(),                "dum ÷ dum")
  assert_equal([],           Scan(dum)->Divide(dee)->Build(),                "dum ÷ dee")
  # Differently from Codd's division, Todd's division returns [] whenever the
  # divisor is empty (Codd's division would return [{}] here):
  assert_equal([],           Scan(dee)->Divide(dum)->Build(),                "dee ÷ dum")
  assert_equal([{}],         Scan(dee)->Divide(dee)->Build(),                "dee ÷ dee")
enddef

def Test_RA_Zip()
  assert_equal({A: 7, B: 'v'}, Zip(['A', 'B'], [7, 'v']))
  # If the second list is longer than the first items in excess are ignored:
  assert_equal({X: 9}, Zip(['X'], [9, 8, 7]))
enddef

def Test_RA_Filter()
  var R = Relation('R', {A: Int, B: Int}, [['A']])->InsertMany([
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
  var R = Relation("R", {AAAAAAAAA: Int, B: Str}, [["AAAAAAAAA"]])

  var expectedTable =<< END
 Empty Instance
================
END

  assert_equal(expectedTable, split(Table(R, 'Empty Instance', '='), "\n"))

  R->InsertMany([
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
  var R = Relation("R", {'🙂☀︎': Int, '✔︎✖︎': Str}, [['✔︎✖︎']])

  R->InsertMany([
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

const success = tt.Run('_RA_')
:2echowindow success ? "Success!" : "Some test failed"
