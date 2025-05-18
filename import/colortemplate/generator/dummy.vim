vim9script

import '../../libcolortemplate.vim' as lib

export class Generator implements lib.Generator
  def Generate(theme: lib.Colorscheme): list<string>
    return ['vim9script', '# DUMMY']
  enddef
endclass

