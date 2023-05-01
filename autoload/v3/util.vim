vim9script

import 'libcolor.vim'  as libcolor
import 'libparser.vim' as libparser
import './parser.vim'  as parser

const Approximate = libcolor.Approximate
const Hex2Rgb     = libcolor.Hex2Rgb
const Neighbours  = libcolor.Neighbours
const ColorParser = parser.ColorParser
const Context     = libparser.Context

# Get info about the Color definition under the cursor.
#
# n: the desired number of terminal approximations for the given color.
export def GetColorInfo(n: number)
  var ctx = Context.new(getline('.'))
  const result = ColorParser(ctx)

  if !result.success
    return
  endif

  const colorName  = result.value[2]
  const guiValue   = result.value[3]
  const bestApprox = Approximate(guiValue)
  const best256    = bestApprox.xterm
  const [r, g, b]  = Hex2Rgb(guiValue)
  const approx     = n == 1 ? [bestApprox] : Neighbours(guiValue, n)

  echon printf('%s: %s/rgb(%d,%d,%d) ', colorName, guiValue, r, g, b)

  if has('gui_running') || (has('termguicolors') && &termguicolors)
    try
      execute printf(
        "hi! ColortemplateInfoFg ctermfg=%d guifg=%s ctermbg=NONE guibg=NONE", best256, guiValue
      )
      execute printf(
        "hi! ColortemplateInfoBg ctermbg=%d guibg=%s ctermfg=NONE guifg=NONE", best256, guiValue
      )
    catch /^Vim\%((\a\+)\)\=:E254/ # Cannot allocate color
      hi clear ColortemplateInfoFg
      hi clear ColortemplateInfoBg
    endtry

    echohl ColortemplateInfoFg | echon 'xxx' | echohl None
    echon ' '
    echohl ColortemplateInfoBg | echon '   ' | echohl None
  endif

  echon ' Best xterm approx:'

  for item in approx
    echon printf(' %d', item.xterm)
    execute printf(
      "hi! ColortemplateInfoBg%d ctermbg=%d guibg=%s ctermfg=NONE guifg=NONE",
      item.xterm, item.xterm, item.hex
    )
    execute 'echohl ColortemplateInfoBg' .. item.xterm | echon '   ' | echohl None
    echon printf('@%.2f', item.delta)
  endfor
enddef

