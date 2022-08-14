vim9script
# Description: A tiny testing framework
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     Vim license (see `:help license`)

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
def FindTests(pattern: string): list<string>
  const saved_reg = getreg('t')
  const saved_regtype = getregtype('t')

  redir @t
  execute 'silent def /^Test' .. pattern
  redir END

  const defnames = split(@t, "\n")
  var testnames: list<string> = []
  for t in defnames
    if t =~ '^def Test\k\+()$'
      const name = substitute(t, '^def \(Test\k\+\)()$', '\1', '')
      testnames->add(name)
    endif
  endfor

  setreg('t', saved_reg, saved_regtype)

  return testnames
enddef

# test: test name (without 'g:' prefix and without parentheses)
def RunTest(test: string)
  done += 1

  var message = test
  const start_time = reltime()

  try
    execute 'g:' .. test .. '()'
  catch
    add(v:errors, printf('Caught exception in %s: %s @ %s', test, v:exception, v:throwpoint))
  endtry

  message ..=  printf(' (%.01fms)', 1000.0 * reltimefloat(reltime(start_time)))

  if len(v:errors) == 0
    add(mesg, '✔︎ ' .. message)
    return
  endif

  fail += 1
  message ..= ' FAILED'
  add(erro, '')
  add(erro, test)

  for err in v:errors
    if err =~# '^Caught exception'
      add(erro, substitute(err, '^Caught exception\zs.*: Vim[^:]*\ze:', '', ''))
    else
      add(erro, substitute(err, '^.*\zeline \d\+', '', ''))
    endif
  endfor

  add(mesg, '✘ ' .. message)
  v:errors = []
enddef

def FinishTesting(time_spent: float): bool
  add(mesg, '')
  add(mesg, printf('%d test%s run in %.03fs', done, (done == 1 ? '' : 's'), time_spent))
  if fail == 0
    add(mesg, '✔︎ ALL TESTS PASSED!')
  else
    add(mesg, printf('%d test%s failed', fail, (fail == 1 ? '' : 's')))
  endif

  botright new +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile\ wrap
  append(line('$'), mesg)
  append(line('$'), '')
  append(line('$'), erro)
  matchadd('Identifier', '✔︎')
  matchadd('WarningMsg', '✘')
  matchadd('WarningMsg', '\<FAILED\>')
  matchadd('WarningMsg', '^\d\+ tests\? failed')
  matchadd('Keyword',    '^\<line \d\+')
  matchadd('Constant',   '\<Expected\>')
  matchadd('Constant',   '\<but got\>')
  matchadd('ErrorMsg',   'Caught exception')
  norm G
  nunmenu WinBar
  return (fail == 0)
enddef
# }}}
# Public interface {{{
# Returns true on success, false on failure
export def RunBabyRun(what: string): bool
  Init()

  var tests: list<string>

  if what =~ '^Test' # Assume single test
    tests = [what]
  else               # Assume pattern
    tests = FindTests(what)
  endif

  const start_time = reltime()

  for test in tests
    RunTest(test)
  endfor

  const time_passed = reltimefloat(reltime(start_time))

  return FinishTesting(time_passed)
enddef
# }}}

# vim: nowrap et ts=2 sw=2
