vim9script

export class HiGroupGenerator
  this.palette: dict<dict<string>> = {
        \  'NONE': { 'gui': 'NONE', '256': 'NONE', '16': 'NONE'},
        \  'fg':   { 'gui': 'fg',   '256': 'fg',   '16': 'fg'},
        \  'bg':   { 'gui': 'bg',   '256': 'bg',   '16': 'bg'},
        \ }
  this.numColors: number
  this.cterm: string

  def new()
    this.numColors = str2nr(&t_Co) ?? 0
    this.cterm = this.numColors >= 256 ? '256' : '16'
  enddef

  def Color(name: string, gui: string, b256: string, b16: string = '')
    this.palette[name] = {'gui': gui, '256': b256, '16': b16}
  enddef

  def Hi(
      name:       string,
      guifg:      string,
      guibg:      string,
      guisp:      string = '',
      guistyle:   string = 'NONE',
      ctermfg:    string = guifg,
      ctermbg:    string = guibg,
      ctermul:    string = guisp,
      ctermstyle: string = guistyle,
      termstyle:  string = guistyle
      )
    const guifg_    = empty(guifg)      ? '' : 'guifg='   .. this.palette[guifg].gui
    const guibg_    = empty(guibg)      ? '' : 'guibg='   .. this.palette[guibg].gui
    const guisp_    = empty(guisp)      ? '' : 'guisp='   .. this.palette[guisp].gui
    const gui_      = empty(guistyle)   ? '' : 'gui='     .. guistyle
    const ctermfg_  = empty(ctermfg)    ? '' : 'ctermfg=' .. this.palette[ctermfg][this.cterm]
    const ctermbg_  = empty(ctermbg)    ? '' : 'ctermbg=' .. this.palette[ctermbg][this.cterm]
    const ctermul_  = empty(ctermul)    ? '' : 'ctermul=' .. this.palette[ctermul][this.cterm]
    const cterm_    = empty(ctermstyle) ? '' : 'cterm='   .. ctermstyle
    const term_     = empty(termstyle)  ? '' : "term="    .. termstyle
    execute 'hi' name guifg_ guibg_ gui_ ctermfg_ ctermbg_ ctermul_ cterm_ term_
  enddef

  def Link(source: string, target: string)
    execute 'hi! link' source target
  enddef

  def Term(name: string, termstyle = 'NONE')
    execute "hi" name 'term=' .. termstyle
  enddef
endclass
