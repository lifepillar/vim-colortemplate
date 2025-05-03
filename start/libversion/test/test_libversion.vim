vim9script

import 'libtinytest.vim' as tt
import 'libversion.vim'  as vv

type Version = vv.Version
const Require = vv.Require


def Test_Version_Version()
  assert_true(match(vv.version, '^\d\+\.\d\+\.\d\+') != -1)
enddef

def Test_Version_Parse()
  for [version, major, minor, patch, prelease, build] in [
      ['0.0.0',                          0,  0,  0,       [               ], [                          ]],
      ['1.2.3',                          1,  2,  3,       [               ], [                          ]],
      ['22.11.333',                      22, 11, 333,     [               ], [                          ]],
      ['1.0.0-alpha',                    1,  0,  0,       ['alpha'        ], [                          ]],
      ['2.1.1-beta',                     2,  1,  1,       ['beta'         ], [                          ]],
      ['2.1.1-rc2',                      2,  1,  1,       ['rc2'          ], [                          ]],
      ['3.6.9-alpha.1',                  3,  6,  9,       ['alpha', 1     ], [                          ]],
      ['9.8.76-alpha.beta',              9,  8,  76,      ['alpha', 'beta'], [                          ]],
      ['1.0.0-rc.1.bis',                 1,  0,  0,       ['rc', 1, 'bis' ], [                          ]],
      ['1.0.0-alpha+001',                1,  0,  0,       ['alpha'        ], ['001'                     ]],
      ['4.5.7+20130313144700',           4,  5,  7,       [               ], ['20130313144700'          ]],
      ['1.0.0+21AF26D3----117B344092BD', 1,  0,  0,       [               ], ['21AF26D3----117B344092BD']],
      ['9.8.76-beta+exp.sha.5114f85',    9,  8,  76,      ['beta'         ], ['exp', 'sha', '5114f85'   ]],
      ['1.2.3-a.b.111+build-3454.34',    1,  2,  3,       ['a', 'b', 111  ], ['build-3454', '34'        ]],
  ]
    var v = Version.Parse(version)

    assert_equal(major, v.major)
    assert_equal(minor, v.minor)
    assert_equal(patch, v.patch)
    assert_equal(prelease, v.prerelease)
    assert_equal(version, v.string())
  endfor
enddef

def Test_Version_Equality()
  var testCase = [
      '1.0.0',
      '1.0.0-rc.1',
      '1.0.0-beta.11',
      '1.0.0-beta.2',
      '1.0.0-beta',
      '1.0.0-alpha.beta',
      '1.0.0-alpha.1',
      '1.0.0-alpha',
      '3.0.0',
      '2.0.0',
      '3.2.0',
      '3.1.0',
      '3.2.1',
      '2.1.0',
      '2.1.1',
      '2.1.1-alpha',
      '2.1.1-beta',
      '2.1.1-rc2',
      '2.1.1-rc1',
      '2.1.1-rc.2',
      '2.1.1-rc.1',
  ]

  for case in testCase
    var v1 = Version.Parse(case)
    var v2 = Version.Parse(case)

    assert_true(v1.Equal(case))
    assert_true(v1.Equal((v2)))
    assert_true(v1.GreaterThanOrEqual(v2))
  endfor

  for i in range(len(testCase))
    var v1 = Version.Parse(testCase[i])
    var v2 = Version.Parse(testCase[(i + 1) % len(testCase)])

    assert_false(v1.Equal(v2), $'Not equal #{i}: {string(v1)} vs {string(v2)}')
  endfor
enddef

def Test_Version_Comparison()
  var i = 0

  for [x, y] in [
      ['1.0.0',            '1.0.0-rc.1'],
      ['1.0.0-rc.1',       '1.0.0-beta.11'],
      ['1.0.0-beta.11',    '1.0.0-beta.2'],
      ['1.0.0-beta.2',     '1.0.0-beta'],
      ['1.0.0-beta',       '1.0.0-alpha.beta'],
      ['1.0.0-alpha.beta', '1.0.0-alpha.1'],
      ['2.0.0',            '1.0.0'],
      ['2.1.0',            '2.0.0'],
      ['2.1.1',            '2.1.0'],
      ['2.1.1',            '2.1.1-alpha'],
      ['2.1.1-beta',       '2.1.1-alpha'],
      ['2.1.1-rc2',        '2.1.1-rc1'],
      ['2.1.1-rc.2',       '2.1.1-rc.1'],
  ]
    var v1 = Version.Parse(x)
    var v2 = Version.Parse(y)
    ++i
    assert_true(v1.GreaterThanOrEqual(v2), $'v1 >= v2 {i}: {string(v1)} >= {string(v2)}')
    assert_true(v1.GreaterThanOrEqual(y), $'v1 >= y {i}: {string(v1)} >= {y}')
    assert_true(v2.LessThanOrEqual(v1), $'v2 <= v1 {i}: {string(v2)} <= {string(v1)}')
    assert_true(v2.LessThanOrEqual(x), $'v2 <= x {i}: {string(v2)} <= {x}')
    assert_true(v1.GreaterThan(v2), $'v1 > v2 {i}: {string(v1)} > {string(v2)}')
    assert_true(v1.GreaterThan(y), $'v1 > y {i}: {string(v1)} > {y}')
    assert_true(v2.LessThan(v1), $'v2 < v1 {i}: {string(v2)} < {string(v1)}')
    assert_true(v2.LessThan(x), $'v2 < x {i}: {string(v2)} < {x}')
    assert_false(v2.GreaterThanOrEqual(v1), $'Not v2 >= v1 {i}: {string(v2)} >= {string(v1)}')
    assert_false(v2.GreaterThanOrEqual(x), $'Not v2 >= x {i}: {string(v2)} >= {x}')
    assert_false(v1.LessThanOrEqual(v2), $'Not v1 <= v2 {i}: {string(v1)} <= {string(v2)}')
    assert_false(v1.LessThanOrEqual(y), $'Not v1 <= y {i}: {string(v1)} <= {y}')
    assert_false(v2.GreaterThan(v1), $'Not v2 > v1 {i}: {string(v2)} > {string(v1)}')
    assert_false(v2.GreaterThan(y), $'Not v2 > y {i}: {string(v2)} > {y}')
    assert_false(v1.LessThan(v2), $'Not v1 < v2 {i}: {string(v1)} < {string(v2)}')
    assert_false(v1.LessThan(y), $'Not v1 < y {i}: {string(v1)} < {y}')
  endfor
enddef

def Test_Version_Require()
  var v = '1.0.0'
  assert_true(Require('X', v, '0.0.9'))
  assert_true(Require('X', v, '0.0.9', {max: '1.0.0'}))
  assert_true(Require('X', v, '1.0.0-alpha.1', {max: '1.0.0'}))

  tt.AssertFails(() => {
    Require('X', v, '1.0.1')
  }, $'X v{v} is too old')

  silent assert_false(Require('X', v, '1.0.1', {throw: false}))

  tt.AssertFails(() => {
    Require('X', v, '1.0.0-rc1', {max: '1.0.0-rc2'})
  }, $'X v{v} is not supported yet')

  silent assert_false(Require('X', v, '1.0.0-rc1', {max: '1.0.0-rc2', throw: false}))
enddef


tt.Run('_Version_')
