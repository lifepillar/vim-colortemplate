vim9script

import 'libpath.vim'     as path
import 'libtinytest.vim' as tt

tt.Import(path.Join(expand('<sfile>:h'), 'tests.vim'))

var setup    = 0
var teardown = 0

tt.Setup = () => {
  ++setup
}

tt.Teardown = () => {
  ++teardown
}

tt.Run('_TT_')

if setup != tt.done || teardown != tt.done
  echoerr $'Wrong setup/teardown counts: done={tt.done}, setup={setup}, teardown={teardown}'
endif
