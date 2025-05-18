vim9script

export interface Generator
  def Generate(theme: lib.Colorscheme): list<string>
endinterface

