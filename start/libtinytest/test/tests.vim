vim9script

import 'libtinytest.vim' as tt

const AssertFails = tt.AssertFails
const Round       = tt.Round

def Test_TT_Version()
  assert_true(match(tt.version, '^\d\+\.\d\+\.\d\+') != -1)
enddef

def Test_TT_Round()
  assert_equal(4.55, Round(4.54898, 2))
  assert_equal(1.0,  Round(0.9987, 0))
enddef

def Test_TT_AssertApprox()
  const testCases = [
    [1.0,    1.00001, v:none, v:none],
    [1.0,    1.0001,  0.0,    0.0001],
    [1.0,    1.0001,  0.0001, 0.0],
    [1.0,    2.0,     0.0,    1.0],
    [10.0,   11.0,    0.1,    v:none],
    [10.0,   11.0,    0.05,   1.0],
    [10.0,   11.0,    0.0,    1.0],
    [0.6879, 0.68785, 0.0,    0.00005],
    [0.6879, 0.68785, 0.0,    0.00005],
  ]

  for t in testCases
    tt.AssertApprox(t[0], t[1], t[2], t[3])
  endfor
enddef

def Test_TT_AssertFails()
  AssertFails(() => {
    throw 'error'
  }, 'err')
enddef

def Test_TT_AssertFailsNestedLambda()
  def F(G: func())
    const H = () => {
      G()
    }
    H()
  enddef

  AssertFails(() => {
    F(() => {
      throw 'error'
    })
  }, 'error', 'Assertion of failure failed')

enddef

def Test_TT_AssertBenchmark()
  def F()
    sleep 1m
  enddef

  tt.AssertBenchmark(F, 'Sleep for 1ms', {
    repeat: 3,
    severity: {
      '!': 0.0,
      '✓': 1.0,
      '✗': 1.3,
    },
  })
enddef

tt.Run('_TT_', {
  oksymbol: 'OK!',
})
