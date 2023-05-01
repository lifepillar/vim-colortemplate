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

var cachedHiGroup: dict<any> = { 'synid': -1 }

# Returns a Dictionary with information about the highlight group at the
# specified position.
#
# See: http://vim.wikia.com/wiki/VimTip99 and hilinks.vim script.
def GetHighlightInfoAt(line: number, col: number): dict<any>
  const synid0 = synID(line, col, false)

  if empty(synid0) || synid0 == 0 # Apparently, sometimes synID() fails to return a value
    return {}
  endif

  const trans  = synIDattr(synID(line, col, false), 'name')
  const synid1 = synID(line, col, true)
  const higrp  = synIDattr(synid1, 'name')
  const synid  = synIDtrans(synid1)
  const logrp  = synIDattr(synid, 'name')

  if synid == cachedHiGroup.synid
    return cachedHiGroup
  endif

  const fgterm = synIDattr(synid, 'fg',  'cterm')
  const fggui  = synIDattr(synid, 'fg#', 'gui')
  const bgterm = synIDattr(synid, 'bg',  'cterm')
  const bggui  = synIDattr(synid, 'bg#', 'gui')
  const spterm = synIDattr(synid, 'ul',  'cterm') # TODO: Not implemented? Should be 'sp'?
  const spgui  = synIDattr(synid, 'sp#', 'gui')

  cachedHiGroup = {
    synid:     synid,
    tname:     trans,
    name:      higrp,
    transname: logrp,
    fgterm:    empty(fgterm) ? 'NONE' : fgterm,
    fggui:     empty(fggui)  ? 'NONE' : fggui,
    bgterm:    empty(bgterm) ? 'NONE' : bgterm,
    bggui:     empty(bggui)  ? 'NONE' : bggui,
    spterm:    empty(spterm) ? 'NONE' : spterm,
    spgui:     empty(spgui)  ? 'NONE' : spgui,
  }

  try # The following may raise an error, e.g., if CtrlP is opened while this is active
    execute(printf('hi! ColortemplateInfoFg ctermbg=%s guibg=%s',
      cachedHiGroup.fgterm, cachedHiGroup.fggui
    ))
    execute(printf('hi! ColortemplateInfoBg ctermbg=%s guibg=%s',
      cachedHiGroup.bgterm, cachedHiGroup.bggui
    ))
    execute(printf('hi! ColortemplateInfoSp ctermbg=%s guibg=%s',
      cachedHiGroup.spterm, cachedHiGroup.spgui
    ))
  catch /^Vim\%((\a\+)\)\=:E254/ # Cannot allocate color
    hi clear ColortemplateInfoFg
    hi clear ColortemplateInfoBg
  endtry

  const synstack = synstack(line, col)
  # Sometimes, Vim spits E896: Argument of map() must be a List, Dictionary or
  # Blob even if synstack is a List...
  if !empty(synstack)
    cachedHiGroup['synstack'] = mapnew(reverse(copy(synstack)), (_, v) => synIDattr(v, 'name'))
  else
    cachedHiGroup['synstack'] = []
  endif

  return cachedHiGroup
enddef

# Displays some information about the highlight group under the cursor in the
# command line.
export def GetHighlightInfo()
  const info = GetHighlightInfoAt(line('.'), col('.'))

  if empty(info)
    return
  endif

  echo join(info.synstack, ' ⊂ ')
  execute "echohl" info.transname | echon ' xxx ' | echohl None

  if info.name != info.tname
    echon printf('T: %s → %s', info['tname'], info['name'])
  elseif info.name != info.transname
    echon printf('%s → %s ', info['name'], info['transname'])
  else
    echon printf('%s ',  info['name'])
  endif

  echohl ColortemplateInfoFg | echon '  ' | echohl None
  echon printf(' fg=%s/%s ', info.fggui, info.fgterm)

  if info.bggui != 'NONE' || info.bgterm != 'NONE'
    echohl ColortemplateInfoBg | echon '  ' | echohl None
    echon printf(" bg=%s/%s ", info.bggui, info.bgterm)
  endif

  if info.spgui != 'NONE' || info.spterm != 'NONE'
    echohl ColortemplateInfoSp | echon "  " | echohl None
    echon printf(" sp=%s/%s ", info.spgui, info.spterm)
  endif
enddef

export def ToggleHighlightInfo()
  if get(g:, 'colortemplate_higroup_balloon', 1)
    # if s:balloon_id && popup_getpos(s:balloon_id) != {}
    #   call popup_close(s:balloon_id)
    # endif
    # set ballooneval! balloonevalterm!
  endif

  if get(g:, 'colortemplate_higroup_command_line', true)
    if exists("#colortemplate_syn_info")
      autocmd! colortemplate_syn_info
      augroup! colortemplate_syn_info
      echo "\r"
    else
      cachedHiGroup = { 'synid': -1 }

      augroup colortemplate_syn_info
        autocmd CursorMoved * call GetHighlightInfo()
      augroup END
    endif
  endif
enddef
