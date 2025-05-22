vim9script

import './base.vim'         as base
import '../colorscheme.vim' as colorscheme

export class Generator extends base.Generator
  def Generate(theme: colorscheme.Colorscheme): list<string>
    return ['vim9script', '# DUMMY']
  enddef
endclass

