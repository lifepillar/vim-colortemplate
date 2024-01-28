vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

if !&magic
  echomsg "Tiny Test requires 'magic' on"
  finish
endif

const  OK = '✔︎'
const TSK = '✘'

# Local state {{{
var mesg = []
var erro = []
export var done = 0
export var fail = 0

def Init()
  mesg = []
  erro = []
  done = 0
  fail = 0
enddef
# }}}

# Private functions {{{
def FindTests(pattern: string): list<dict<string>>
  const saved_reg = getreg('t')
  const saved_regtype = getregtype('t')

  redir @t
  execute 'silent def /Test_*' .. pattern
  redir END

  const defnames = split(@t, "\n")
  var tests: list<dict<string>> = []

  for t in defnames
    if t =~ '^def <SNR>\d\+\k\+()$'
      const test = substitute(t, '^def ', '\1', '')  # E.g., '<SNR>9_Test_Foo()'
      const name = substitute(test, '^<SNR>\d\+_Test_*\(.\+\)()$', '\1', '')  # E.g., 'Foo'
      tests->add({'test': test, 'name': name})
    endif
  endfor

  setreg('t', saved_reg, saved_regtype)

  return tests
enddef

def Noop()
enddef

export var Setup:    func() = Noop
export var Teardown: func() = Noop

# test: the full function invocation (e.g., '<SNR>1_Test_Foobar()')
# name: the test name (e.g., 'Foobar')
def RunTest(test: string, name: string)
  var message = name
  const start_time = reltime()

  v:errors = []

  Setup()

  try
    execute test
  catch
    add(v:errors, printf('Caught exception in %S: %S @ %S', name, v:exception, v:throwpoint))
  endtry

  done += 1
  Teardown()

  message ..= printf(' (%.01fms)', 1000.0 * reltimefloat(reltime(start_time)))

  if empty(v:errors)
    add(mesg, printf('%S %S', OK, message))
    return
  endif

  fail += 1
  message ..= ' FAILED'
  add(erro, '')
  add(erro, name)

  for err in v:errors
    if err =~# '^Caught exception'
      add(erro, substitute(err, '^Caught exception\zs.*: Vim[^:]*\ze:', '', ''))
    else
      add(erro, substitute(err, '^.*\zeline \d\+', '', ''))
    endif
  endfor

  add(mesg, printf('%S %S', TSK, message))

  v:errors = []
enddef

def FinishTesting(time_spent: float): bool
  add(mesg, '')
  add(mesg, printf('%d test%s run in %.03fs', done, (done == 1 ? '' : 's'), time_spent))
  if fail == 0
    add(mesg, OK .. ' ALL TESTS PASSED!')
  else
    add(mesg, printf('%d test%s failed', fail, (fail == 1 ? '' : 's')))
  endif

  botright new +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile\ wrap
  append(0, strftime('--- %c ---'))
  append(line('$'), mesg)
  append(line('$'), '')
  append(line('$'), erro)

  if get(g:, 'tinytest_highlight', true)
    matchadd('Identifier', OK)
    matchadd('WarningMsg', TSK)
    matchadd('WarningMsg', '\<FAILED\>')
    matchadd('WarningMsg', '^\d\+ tests\? failed')
    matchadd('Keyword',    '^\<line \d\+')
    matchadd('Constant',   '\<Expected\>')
    matchadd('Constant',   '\<but got\>')
    matchadd('ErrorMsg',   'Caught exception')
  endif

  normal G
  nunmenu WinBar
  Setup = Noop
  Teardown = Noop

  return (fail == 0)
enddef

def Min(a: float, b: float): float
  return a <= b ? a : b
enddef

def Max(a: float, b: float): float
  return a >= b ? a : b
enddef
# }}}

# Public interface {{{
var dryrun = false

export def Import(path: string)
  dryrun = true
  execute 'source' path
  dryrun = false
enddef

export def Round(num: float, digits: number): float
  return str2float(printf('%.0' .. digits .. 'f', num))
enddef

export def AssertApprox(
    expected: float, value: float, rtol = 0.001, atol = 0.0
)
  assert_true(
    rtol >= 0.0 && atol >= 0.0, printf(
    "rtol and atol must be non-negative. Got: rtol≅%.5f, atol≅%.5f",
    rtol, atol
    )
  )

  const tmin = Min(expected - rtol * expected, expected - atol)
  const tmax = Max(expected + rtol * expected, expected + atol)

  assert_inrange(tmin, tmax, value)
enddef

export def AssertFails(F: func(): void, expectedError: string)
  try
    F()
    assert_false(1, 'Function should have thrown an error, but succeeded')
  catch
    assert_exception(expectedError)
  endtry
enddef

# Returns true on success, false on failure
export def Run(pattern: string = ''): bool
  if dryrun
    return true
  endif

  Init()

  var tests: list<dict<string>> = FindTests(pattern)

  const start_time = reltime()

  for test in tests
    RunTest(test.test, test.name)
  endfor

  const time_passed = reltimefloat(reltime(start_time))

  return FinishTesting(time_passed)
enddef
# }}}

# vim: nowrap et ts=2 sw=2
