vim9script
# Description: A tiny testing framework for Vim
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     Vim license (see `:help license`)

if !&magic
  echomsg "Tiny Test requires 'magic' on"
  finish
endif

const  OK = '✔︎'
const TSK = '✘'

# Local state {{{
var mesg = []
var erro = []
var done = 0
var fail = 0

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

# test: the full function invocation (e.g., '<SNR>1_Test_Foobar()')
# name: the test name (e.g., 'Foobar')
def RunTest(test: string, name: string)
  done += 1

  var message = name
  const start_time = reltime()

  try
    execute test
  catch
    add(v:errors, printf('Caught exception in %s: %s @ %s', name, v:exception, v:throwpoint))
  endtry

  message ..=  printf(' (%.01fms)', 1000.0 * reltimefloat(reltime(start_time)))

  if len(v:errors) == 0
    add(mesg, printf('%s %s', OK, message))
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

  add(mesg, printf('%s %s', TSK, message))
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
  return (fail == 0)
enddef
# }}}

# Public interface {{{
# Returns true on success, false on failure
export def Run(pattern: string = ''): bool
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
