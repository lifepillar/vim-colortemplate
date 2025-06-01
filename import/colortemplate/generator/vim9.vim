vim9script

import './base.vim' as base

export class Generator extends base.Generator
  def new(this.theme)
    super.Init('vim9')
  enddef
endclass
