vim9script

import '../../import/librelalg.vim' as ra

const AntiJoin       = ra.AntiJoin
const Attributes     = ra.Attributes
const Bool           = ra.Bool
const Build          = ra.Build
const Count          = ra.Count
const Delete         = ra.Delete
const Descriptors    = ra.Descriptors
const Divide         = ra.Divide
const Float          = ra.Float
const GroupBy        = ra.GroupBy
const Insert         = ra.Insert
const InsertMany     = ra.InsertMany
const Int            = ra.Int
const Intersect      = ra.Intersect
const Join           = ra.Join
const KeyAttributes  = ra.KeyAttributes
const Max            = ra.Max
const Min            = ra.Min
const Minus          = ra.Minus
const NatJoin        = ra.NatJoin
const Noop           = ra.Noop
const Product        = ra.Product
const Project        = ra.Project
const Query          = ra.Query
const RelEq          = ra.RelEq
const Relation       = ra.Relation
const Rename         = ra.Rename
const Scan           = ra.Scan
const Select         = ra.Select
const SemiJoin       = ra.SemiJoin
const Sort           = ra.Sort
const SortBy         = ra.SortBy
const Str            = ra.Str
const Sum            = ra.Sum
const Update         = ra.Update

# This is defined at the script level to allow for the use of assert_fails().
# See also: https://github.com/vim/vim/issues/6868
var RR: dict<any> # TRelSchema

def ErrMsg(context: string, expected: any, result: any): string
  return printf("%s: Expected %s, but got %s", context, result, expected)
enddef

def g:Test_CT_CreateEmptyRelation()
  # Every relation must have at least one key
  assert_fails("Relation('R', {A: Int, B: Str}, [])", "No key")

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
  assert_true(empty(R.instance),         "R instance is not empty")
  assert_equal([['A']], R.keys)
  assert_equal(1, len(keys(R.indexes)))
  assert_equal("['A']", keys(R.indexes)[0])
  assert_true(!empty(R.constraints),     "R does not have any associated constraint")
  assert_equal(['A', 'B'], sort(Attributes(R)))
  assert_equal(['A'], KeyAttributes(R))
  assert_equal(['B'], Descriptors(R))
enddef


def g:Test_CT_Insert()
  RR = Relation('RR', {A: Int, B: Str, C: Bool, D: Float}, [['A', 'C']])

  RR->Insert({A: 0, B: 'b0', C: true, D: 1.2})

  assert_equal(1, len(RR.instance))

  RR->Insert({A: 0, B: 'b1', C: false, D: 0.2})

  assert_equal(2, len(RR.instance))
  assert_equal(
    [{A: 0, B: 'b0', C: true, D: 1.2}, {A: 0, B: 'b1', C: false, D: 0.2}],
    RR.instance
  )

  assert_fails("RR->Insert({A: 0, B: 'b2', C: true, D: 3.5})", 'Duplicate key')
  assert_fails("RR->Insert({A: 9})", 'Expected a tuple on schema')
  assert_fails("RR->Insert({A: false, B: 'b3', C: false, D: 7.0})",
               "Attribute A is of type integer, but value 'false' of type boolean")
  assert_fails("RR->Insert({A: 9, B: 9, C: false, D: 'tsk'})",
               "Attribute B is of type string, but value '9' of type integer")
  assert_fails("RR->Insert({A: 9, B: 'b3', C: 3.2, D: 'tsk'})",
               "Attribute C is of type boolean, but value '3.2' of type float")
  assert_fails("RR->Insert({A: 9, B: 'b3', C: false, D: 'tsk'})",
               "Attribute D is of type float, but value 'tsk' of type string")

  assert_equal(
    [{A: 0, B: 'b0', C: true, D: 1.2}, {A: 0, B: 'b1', C: false, D: 0.2}],
    RR.instance
  )
enddef

def g:Test_CT_Update()
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
    {A: 1, B: 'x', C: false, D: 'new-d2'}
  ]

  assert_true(RelEq(expected, rr))
  assert_fails("RR->Update({A: 0, B: 'x', C: false, D: ''})",
    "Key attribute C in RR cannot be changed")
  assert_fails("RR->Update({A: 2, B: 'y', C: true, D: 'd3'})",
    "Tuple with ['A'] = [2] not found in RR")
enddef

def g:Test_CT_Upsert()
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
    {A: 2, B: 'y', C: true, D: 'd3'}
  ]

  assert_true(RelEq(expected, rr))
  assert_fails("RR->Update({A: 0, B: 'x', C: false, D: ''})",
    "Key attribute C in RR cannot be changed")
enddef

def g:Test_CT_Delete()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const empty_indexes = deepcopy(R.indexes)
  var r = R.instance

  R->InsertMany([
    {A: 0, B: 'X'},
    {A: 1, B: 'Y'},
    {A: 2, B: 'Z'},
    {A: 3, B: 'Y'},
    {A: 4, B: 'Z'}
  ])

  const expected1 = [
    {A: 1, B: 'Y'},
    {A: 2, B: 'Z'},
    {A: 3, B: 'Y'},
    {A: 4, B: 'Z'}
  ]
  const expected2 = [
    {A: 1, B: 'Y'},
    {A: 4, B: 'Z'}
  ]

  R->Delete((t) => t.B == 'X')

  assert_equal(expected1, r)

  R->Delete((t) => t.A == 2 || t.A == 3)

  assert_equal(expected2, r)

  R->Delete((t) => true)

  assert_equal([], r)
  assert_equal(empty_indexes, R.indexes)
enddef

def g:Test_CT_Index()
  const key = ['A', 'B']
  const keyStr = string(key)
  var R = Relation('R', {A: Int, B: Str}, [key])

  assert_equal(1, len(R.indexes))

  const index = R.indexes[keyStr]

  assert_true(index->has_key('key'), "Index does not have 'key' field")
  assert_true(index->has_key('data'), "Index does not have 'data' field")
  assert_equal(key, index.key)
  assert_equal({}, index.data)

  const t0 = {A: 9, B: 'veni'}
  const t1 = {A: 3, B: 'vici'}
  const t2 = {A: 9, B: 'vidi'}
  R->Insert(t0)
  R->Insert(t1)
  R->Insert(t2)

  assert_equal(
      { 'key':  ['A', 'B'],
        'data': { '3': {
                    'key': ['B'],
                    'data': {
                      'vici': { 'key': [], 'data': {}, 'row': t1 }
                    },
                  },
                  '9': {
                    'key': ['B'],
                    'data': {
                      'veni': { 'key': [], 'data': {}, 'row': t0 },
                      'vidi': { 'key': [], 'data': {}, 'row': t2 }
                    }
                  }
                }
      },
      index)
  assert_true(index.data[3].data['vici'].row is t1)
  assert_true(index.data[9].data['veni'].row is t0)
  assert_true(index.data[9].data['vidi'].row is t2)
enddef

def g:Test_CT_Scan()
  const expected = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  var R = Relation('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])
  R->InsertMany(expected)

  const result1 = Query(Scan(R))
  const result2 = Query(Scan(R.instance))

  assert_true(RelEq(expected, result1), ErrMsg("Scan", expected, result1))
  assert_true(RelEq(expected, result2), ErrMsg("Scan", expected, result2))

enddef

def g:Test_CT_Sort()
  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  const expected = [
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]
  var R = Relation('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])
  R->InsertMany(instance)

  const r = R.instance

  const Cmp = (t1, t2) => t1.B == t2.B ? 0 : t1.B > t2.B ? 1 : -1

  assert_equal(expected, Scan(r)->Sort(Cmp))
  assert_equal(expected, Scan(r)->SortBy(['B']))
  assert_equal(R.instance, r)
  assert_equal(instance, R.instance)
enddef

def g:Test_CT_Noop()
  var R = Relation('R', {A: Int}, [['A']])
  R->Insert({A: 42})

  const r = R.instance

  assert_equal(Query(Scan(r)), Query(Scan(r)->Noop()->Noop()))
enddef

def g:Test_CT_Rename()
  var R = Relation('R', {A: Str, B: Float, C: Int}, [['A']])
  const instance = [
    {A: 'a1', B: 4.0, C: 40},
    {A: 'a2', B: 2.0, C: 80}
  ]
  R->InsertMany(instance)

  const r = R.instance

  const expected = [
    {X: 'a1', B: 4.0, W: 40},
    {X: 'a2', B: 2.0, W: 80}
  ]

  assert_equal(instance, Query(Scan(r)->Rename([], [])))
  assert_equal(expected, Query(Scan(r)->Rename(['A', 'C'], ['X', 'W'])))
  assert_equal(instance, r)
enddef

def g:Test_CT_Select()
  var R = Relation('R', {A: Str, B: Float, C: Int}, [['A']])
  const instance = [
    {A: 'a1', B: 4.0, C: 40},
    {A: 'a2', B: 2.0, C: 80},
    {A: 'a3', B: 9.0, C: 10},
    {A: 'a4', B: 5.0, C: 80},
    {A: 'a5', B: 4.0, C: 20},
  ]
  R->InsertMany(instance)

  const r = R.instance

  const expected1 = [
    {A: 'a1', B: 4.0, C: 40}
  ]
  const expected2 = [
    {A: 'a5', B: 4.0, C: 20}
  ]

  assert_equal(expected1, Query(Scan(r)->Select((t) => t.C == 40)))
  assert_equal(expected2, Query(Scan(r)->Select((t) => t.B <= 4.0 && t.A == 'a5')))
  assert_equal([], Query(Scan(r)->Select((t) => t.B > 9.0)))
  assert_equal(instance, r)
enddef

def g:Test_CT_Project()
  var R = Relation('R', {A: Str, B: Bool, C: Int}, [['A']])
  const instance = [
    {A: 'a1', B: true,  C: 40},
    {A: 'a2', B: false, C: 80},
    {A: 'a3', B: true,  C: 40},
    {A: 'a4', B: true,  C: 80},
    {A: 'a5', B: false, C: 20},
  ]
  R->InsertMany(instance)

  const r = R.instance

  const expected1 = [
    {A: 'a1'},
    {A: 'a2'},
    {A: 'a3'},
    {A: 'a4'},
    {A: 'a5'}
  ]
  const expected2 = [
    {B: false},
    {B: true}
  ]
  const expected3 = [
    {B: false, C: 20}
    {B: false, C: 80},
    {B: true,  C: 40},
    {B: true,  C: 80},
  ]

  assert_equal(expected1, Scan(r)->Project(['A'])->SortBy(['A']))
  assert_equal(expected2, Scan(r)->Project(['B'])->SortBy(['B']))
  assert_equal(expected3, Scan(r)->Project(['B', 'C'])->SortBy(['B', 'C']))
  assert_equal(instance, r)
enddef

def g:Test_CT_Join()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'}
    ]
  R->InsertMany(instanceR)

  var S = Relation('S', {B: Str, C: Int}, [['C']])
  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0}
  ]
  S->InsertMany(instanceS)

  const r = R.instance
  const s = S.instance

  const expected1 = [
    {A: 1, B: 'one', s_B: 'one', s_C: 1},
    {A: 2, B: 'one', s_B: 'one', s_C: 1}
  ]
  const expected2 = [
    {r_A: 1, r_B: 'one', B: 'one', C: 1},
    {r_A: 2, r_B: 'one', B: 'one', C: 1}
  ]
  const expected3 = [
    {A: 0, B: 'zero',  s_B: 'one',   s_C: 1},
    {A: 0, B: 'zero',  s_B: 'three', s_C: 0},
    {A: 1, B: 'one',   s_B: 'one',   s_C: 1},
  ]
  const expected4 = [
    {r_A: 0, r_B: 'zero',  B: 'three', C: 0},
    {r_A: 0, r_B: 'zero',  B: 'one',   C: 1},
    {r_A: 1, r_B: 'one',   B: 'one',   C: 1},
  ]
  const expected5 = [
    {B: 'one',   C: 1, s_B: 'three', s_C: 0},
    {B: 'three', C: 0, s_B: 'three', s_C: 0},
  ]

  assert_equal(expected1, Scan(r)->Join(s, (rt, st) => rt.B == st.B, 's_')->SortBy(['A']))
  assert_equal(expected2, Scan(s)->Join(r, (st, rt) => rt.B == st.B, 'r_')->SortBy(['r_A']))
  assert_equal(expected3, Scan(r)->Join(s, (rt, st) => rt.A <= st.C, 's_')->SortBy(['A', 's_B']))
  assert_equal(expected4, Scan(s)->Join(r, (st, rt) => rt.A <= st.C, 'r_')->SortBy(['C', 'r_A']))
  assert_equal(expected5, Scan(s)->Join(s, (s1, s2) => s1.C >= s2.C && s2.C == 0, 's_')->SortBy(['B']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def g:Test_CT_NatJoin()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'}
    ]
  R->InsertMany(instanceR)

  var S = Relation('S', {B: Str, C: Int}, [['C']])
  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0}
  ]
  S->InsertMany(instanceS)

  var T = Relation('T', {D: Int}, [['D']])
  const instanceT = [
    {D: 8},
    {D: 9}
  ]
  T->InsertMany(instanceT)

  var U = Relation('U', {A: Int, B: Str}, [['A', 'B']])
  const instanceU = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'}
  ]
  U->InsertMany(instanceU)

  const r = R.instance
  const s = S.instance
  const t = T.instance
  const u = U.instance

  const expected1 = [
    {A: 1, B: 'one', C: 1},
    {A: 2, B: 'one', C: 1}
  ]
  const expected2 = [
    {B: 'one',   C: 1, D: 8},
    {B: 'one',   C: 1, D: 9},
    {B: 'three', C: 0, D: 8}
    {B: 'three', C: 0, D: 9}
  ]
  assert_equal(expected1, Query(Scan(r)->NatJoin(s)))
  assert_equal(expected1, Query(Scan(s)->NatJoin(r)))
  assert_equal(expected2, Query(Scan(s)->NatJoin(t)))
  assert_equal(r, Query(Scan(r)->NatJoin(r)))
  assert_equal([{A: 1, B: 'one'}], Query(Scan(r)->NatJoin(u)))
  assert_equal([{A: 1, B: 'one'}], Query(Scan(u)->NatJoin(r)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
  assert_equal(instanceT, t)
  assert_equal(instanceU, u)
enddef

def g:Test_CT_Product()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'}
    ]
  R->InsertMany(instanceR)

  var S = Relation('S', {C: Int}, [['C']])
  const instanceS = [
    {C: 10},
    {C: 90}
  ]
  S->InsertMany(instanceS)

  const r = R.instance
  const s = S.instance

  const expected = [
    {A: 0, B: 'zero', C: 10},
    {A: 0, B: 'zero', C: 90},
    {A: 1, B: 'one',  C: 10},
    {A: 1, B: 'one',  C: 90},
    {A: 2, B: 'two',  C: 10}
    {A: 2, B: 'two',  C: 90}
  ]

  assert_equal(expected, Scan(r)->Product(s)->SortBy(['A', 'C']))
  assert_equal(expected, Scan(s)->Product(r)->SortBy(['A', 'C']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def g:Test_CT_Intersect()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'}
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {A: Int, B: Str}, [['A', 'B']])
  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'}
  ]
  S->InsertMany(instanceS)

  const r = R.instance
  const s = S.instance

  assert_equal([{A: 1, B: 'one'}], Query(Scan(r)->Intersect(s)))
  assert_equal([{A: 1, B: 'one'}], Query(Scan(s)->Intersect(r)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def g:Test_CT_Minus()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'}
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {A: Int, B: Str}, [['A', 'B']])
  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'}
  ]
  S->InsertMany(instanceS)

  const r = R.instance
  const s = S.instance

  const expected1 = [
    {A: 0, B: 'zero'},
    {A: 2, B: 'one'}
  ]
  const expected2 = [
    {A: 0, B: 'many'},
    {A: 2, B: 'two'}
  ]

  assert_equal(expected1, Scan(r)->Minus(s)->SortBy(['A']))
  assert_equal(expected2, Scan(s)->Minus(r)->SortBy(['A']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def g:Test_CT_SemiJoin()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'}
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {B: Str, C: Int}, [['C']])
  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0}
  ]
  S->InsertMany(instanceS)

  const r = R.instance
  const s = S.instance

  const expected1 = [
    {A: 1, B: 'one'},
    {A: 2, B: 'one'}
  ]
  const expected2 = [
    {B: 'one', C: 1}
  ]
  const expected3 = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'}
  ]
  const expected4 = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0},
  ]
  const expected5 = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0}
  ]

  assert_equal(expected1, Scan(r)->SemiJoin(s, (rt, st) => rt.B == st.B)->SortBy(['A']))
  assert_equal(expected2, Query(Scan(s)->SemiJoin(r, (st, rt) => rt.B == st.B)))
  assert_equal(expected3, Scan(r)->SemiJoin(s, (rt, st) => rt.A <= st.C)->SortBy(['A']))
  assert_equal(expected4, Scan(s)->SemiJoin(r, (st, rt) => rt.A <= st.C)->SortBy(['B']))
  assert_equal(expected5, Query(Scan(s)->SemiJoin(s, (s1, s2) => s1.C >= s2.C && s2.C == 0)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def g:Test_CT_AntiJoin()
  var R = Relation('R', {A: Int, B: Str}, [['A']])
  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'}
  ]
  R->InsertMany(instanceR)

  var S = Relation('S', {B: Str, C: Int}, [['C']])
  const instanceS = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0}
  ]
  S->InsertMany(instanceS)

  const r = R.instance
  const s = S.instance

  const expected1 = [
    {A: 0, B: 'zero'}
  ]
  const expected2 = [
    {B: 'three', C: 0}
  ]
  const expected3 = [
    {A: 2, B: 'one'}
  ]
  const expected4 = []
  const expected5 = [
    {B: 'three', C: 0}
  ]

  assert_equal(expected1, Query(Scan(r)->AntiJoin(s, (rt, st) => rt.B == st.B)))
  assert_equal(expected2, Query(Scan(s)->AntiJoin(r, (st, rt) => rt.B == st.B)))
  assert_equal(expected3, SortBy(Scan(r)->AntiJoin(s, (rt, st) => rt.A <= st.C), ['A']))
  assert_equal(expected4, SortBy(Scan(s)->AntiJoin(r, (st, rt) => rt.A <= st.C), ['B']))
  assert_equal(expected5, Query(Scan(s)->AntiJoin(s, (s1, s2) => s1.C > s2.C)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def g:Test_CT_Max()
  var R = Relation('R', {A: Int, B: Str, C: Float, D: Bool}, [['A']])
  const r = R.instance

  assert_equal(v:none, Scan(r)->Max('A'))
  assert_equal(v:none, Scan(r)->Max('B'))
  assert_equal(v:none, Scan(r)->Max('C'))
  assert_equal(v:none, Scan(r)->Max('D'))

  const instance = [
    {A: 0, B: "X", C: 10.0, D: true},
    {A: 1, B: "Z", C:  2.5, D: true},
    {A: 2, B: "Y", C: -3.0, D: false},
    {A: 3, B: "X", C:  1.5, D: true},
    {A: 4, B: "Z", C:  2.5, D: true}
  ]
  R->InsertMany(instance)

  assert_equal(4, Scan(r)->Max('A'))
  assert_equal('Z', Scan(r)->Max('B'))
  assert_equal(10.0, Scan(r)->Max('C'))
  assert_equal(true, Scan(r)->Max('D'))
  assert_equal(instance, r)
enddef

def g:Test_CT_Min()
  var R = Relation('R', {A: Int, B: Str, C: Float, D: Bool}, [['A']])
  const r = R.instance

  assert_equal(v:none, Scan(r)->Min('A'))
  assert_equal(v:none, Scan(r)->Min('B'))
  assert_equal(v:none, Scan(r)->Min('C'))
  assert_equal(v:none, Scan(r)->Min('D'))

  const instance = [
    {A: 0, B: "X", C: 10.0, D: true},
    {A: 1, B: "Z", C:  2.5, D: true},
    {A: 2, B: "Y", C: -3.0, D: false},
    {A: 3, B: "X", C:  1.5, D: true},
    {A: 4, B: "Z", C:  2.5, D: true}
  ]
  R->InsertMany(instance)

  assert_equal(0, Scan(r)->Min('A'))
  assert_equal('X', Scan(r)->Min('B'))
  assert_equal(-3.0, Scan(r)->Min('C'))
  assert_equal(false, Scan(r)->Min('D'))
  assert_equal(instance, r)
enddef

def g:Test_CT_Sum()
  var R = Relation('R', {A: Int, B: Float}, [['A']])
  const r = R.instance

  assert_equal(v:none, Scan(r)->Sum('A'))
  assert_equal(v:none, Scan(r)->Sum('B'))

  const instance = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 2, B: -3.0},
    {A: 3, B:  1.5},
    {A: 4, B:  2.5}
  ]
  R->InsertMany(instance)

  assert_equal(10, Scan(r)->Sum('A'))
  assert_equal(13.5, Scan(r)->Sum('B'))
  assert_equal(instance, r)
enddef

def g:Test_CT_Count()
  var R = Relation('R', {A: Int, B: Float}, [['A']])
  const r = R.instance

  assert_equal(0, Scan(r)->Count())

  const instance = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 2, B: -3.0},
    {A: 3, B:  1.5},
    {A: 4, B:  2.5}
  ]
  R->InsertMany(instance)

  assert_equal(5, Scan(r)->Count())
  assert_equal(instance, r)
enddef

def g:Test_CT_GroupBy()
  var R = Relation('R', {id: Int, name: Str, balance: Float}, [['id']])
  const r = R.instance
  const instance = [
    {id: 0, name: "A", balance: 10.0},
    {id: 1, name: "A", balance:  2.5},
    {id: 2, name: "B", balance: -3.0},
    {id: 3, name: "A", balance:  1.5},
    {id: 4, name: "B", balance:  2.5}
  ]
  const numInserted = R->InsertMany(instance)
  const expected = [
    {name: 'A', total: 14.0},
    {name: 'B', total: -0.5}
  ]
  const result = Scan(r)->GroupBy(['name'], (Cont) => Sum(Cont, 'balance'), 'total')->SortBy(['name'])

  assert_equal(5, numInserted)
  assert_equal(2, len(result))
  assert_equal(expected, result)
  assert_equal(instance, r)
enddef

def g:Test_CT_Divide()
  var Subscription = Relation('Subscription',
     {student: Str, date: Str, course: Str},
     [['student', 'course']]
  )
  const subscription = Subscription.instance
  const subscription_instance = [
    {student: '123', date: '2019-12-05', course: 'Databases'},
    {student: '283', date: '2019-12-05', course: 'Databases'},
    {student: '123', date: '2020-12-05', course: 'Computer Science'},
    {student: '123', date: '2021-12-05', course: 'Algebra'},
    {student: '283', date: '2021-12-05', course: 'Algebra'},
    {student: '375', date: '2015-01-06', course: 'Databases'},
    {student: '283', date: '2020-12-05', course: 'Computer Science'},
    {student: '303', date: '2020-12-05', course: 'Computer Science'},
  ]
  Subscription->InsertMany(subscription_instance)

  var Session = Relation('Session', {date: Str, course: Str}, [['date', 'course']])
  const session = Session.instance
  const session_instance = [
    {date: '2019-12-05', course: 'Databases'},
    {date: '2020-12-05', course: 'Computer Science'},
    {date: '2021-12-05', course: 'Algebra'},
  ]
  Session->InsertMany(session_instance)

  # Which students are subscribed to all the courses?
  const expected = [
    {'student': '123'},
    {'student': '283'},
  ]
  const result = Scan(subscription)->Divide(session)->SortBy(['student'])

  assert_equal(expected, result)
  assert_equal(subscription_instance, subscription)
  assert_equal(session_instance, session)
enddef

def g:Test_CT_DeeDum()
  RR = Relation('Dee', {}, [[]])
  assert_equal(0, len(RR.instance))
  assert_fails("RR->Insert({A: 0})", "Expected a tuple on schema {}")

  RR->Insert({})

  assert_equal(1, len(RR.instance))
  assert_fails("RR->Insert({})", "Duplicate key")

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
  assert_equal([{}],         Scan(dee)->Divide(dum)->Build(),                "dee ÷ dum")
  assert_equal([{}],         Scan(dee)->Divide(dee)->Build(),                "dee ÷ dee")
enddef


