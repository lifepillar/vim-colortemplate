vim9script
# Source me to run the tests!

import 'libpath.vim'     as path
import 'libtinytest.vim' as tt

const TESTDIR = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const COLDIR  = path.Join(TESTDIR, 'colors')
const DOCDIR  = path.Join(TESTDIR, 'doc')
const OUTDIR  = path.Join(TESTDIR, 'out')
const LOGFILE = TESTDIR .. '/test.log'

# Test files
tt.Import(path.Join(expand('<sfile>:h'), 'test_colorscheme.vim'))
tt.Import(path.Join(expand('<sfile>:h'), 'test_parser_v3.vim'))
tt.Import(path.Join(expand('<sfile>:h'), 'test_generator_viml.vim'))
tt.Import(path.Join(expand('<sfile>:h'), 'test_generator_vim9.vim'))
tt.Import(path.Join(expand('<sfile>:h'), 'test_generator_template.vim'))

# Runner!
var results = tt.Run(get(g:, 'test', ''))
var success = (indexof(results, (_, r) => !r.Ok()) == -1)

# Cleanup
if success
  delete(DOCDIR, "rf")
  delete(OUTDIR, "d")
  delete(COLDIR, "d")
endif

if get(g:, 'autotest', 0)
  if success
    delete(LOGFILE)
    qall!
  else
    execute "write" LOGFILE
    cquit
  endif
endif

# vim: nowrap et ts=2 sw=2
