vim9script

import 'libcolor.vim'                             as libcolor
import 'libparser.vim'                            as libparser
import '../../import/colortemplate/parser/v3.vim' as parser

const Approximate  = libcolor.Approximate
const Hex2Rgb      = libcolor.Hex2Rgb
const Neighbours   = libcolor.Neighbours
const ColorsWithin = libcolor.ColorsWithin
const ColorParser  = parser.ColorParser
type  Context      = libparser.Context

var sBalloonID        = 0
var sLastBalloonText  = ''

hi clear ColortemplateInfoFg
hi clear ColortemplateInfoBg
hi clear ColortemplateInfoSp

prop_type_delete('ct_hifg')
prop_type_delete('ct_hibg')
prop_type_delete('ct_hisp')
prop_type_add('ct_hifg', {highlight: 'ColortemplateInfoFg'})
prop_type_add('ct_hibg', {highlight: 'ColortemplateInfoBg'})
prop_type_add('ct_hisp', {highlight: 'ColortemplateInfoSp'})

# Get info about the Color definition under the cursor.
#
# n: the desired number of terminal approximations for the given color.
export def GetColorInfo(n: number)
  var ctx    = Context.new(getline('.'))
  var result = ColorParser(ctx)

  if !result.success
    return
  endif

  var colorName  = result.value[2]
  var guiValue   = result.value[3]
  var bestApprox = Approximate(guiValue)
  var best256    = bestApprox.xterm
  var [r, g, b]  = Hex2Rgb(guiValue)
  var approx     = n == 1 ? [bestApprox] : Neighbours(guiValue, n)

  echon $'{colorName}: {guiValue}/rgb({r},{g},{b}) '

  if has('gui_running') || (has('termguicolors') && &termguicolors)
    try
      execute (
        $'hi! ColortemplateInfoFg ctermfg={best256} guifg={guiValue} ctermbg=NONE guibg=NONE'
      )
      execute (
        $'hi! ColortemplateInfoBg ctermbg={best256} guibg={guiValue} ctermfg=NONE guifg=NONE'
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
    echon $' {item.xterm}'
    execute (
      $'hi! ColortemplateInfoBg{item.xterm} ctermbg={item.xterm} guibg={item.hex} ctermfg=NONE guifg=NONE'
    )
    execute 'echohl ColortemplateInfoBg' .. item.xterm | echon '   ' | echohl None
    echon printf('@%.2f', item.delta)
  endfor
enddef

var cachedHiGroup: dict<any> = {synid: -1}

# Returns a Dictionary with information about the highlight group at the
# specified position.
#
# See: http://vim.wikia.com/wiki/VimTip99 and hilinks.vim script.
def GetHighlightInfoAt(line: number, col: number): dict<any>
  var synid0 = synID(line, col, false)

  if empty(synid0) || synid0 == 0 # Apparently, sometimes synID() fails to return a value
    return {}
  endif

  var synid1 = synID(line, col, true)
  var synid  = synIDtrans(synid1)

  if synid == cachedHiGroup.synid
    return cachedHiGroup
  endif

  var trans  = synIDattr(synID(line, col, false), 'name')
  var higrp  = synIDattr(synid1, 'name')
  var logrp  = synIDattr(synid, 'name')

  var fggui  = synIDattr(synid, 'fg#', 'gui')
  var bggui  = synIDattr(synid, 'bg#', 'gui')
  var spgui  = synIDattr(synid, 'sp#', 'gui')
  var fgterm = synIDattr(synid, 'fg',  'cterm')
  var bgterm = synIDattr(synid, 'bg',  'cterm')
  var spterm = synIDattr(synid, 'ul',  'cterm')

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
    execute(
      $'hi! ColortemplateInfoFg ctermbg={cachedHiGroup.fgterm} guibg={cachedHiGroup.fggui}'
    )
    execute(
      $'hi! ColortemplateInfoBg ctermbg={cachedHiGroup.bgterm} guibg={cachedHiGroup.bggui}'
    )
    execute($'hi! ColortemplateInfoSp ctermbg={cachedHiGroup.spterm} guibg={cachedHiGroup.spgui}'
    )
  catch /^Vim\%((\a\+)\)\=:E254/ # Cannot allocate color
    hi clear ColortemplateInfoFg
    hi clear ColortemplateInfoBg
  endtry

  var synstack = synstack(line, col)

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
  var info = GetHighlightInfoAt(line('.'), col('.'))

  if empty(info)
    return
  endif

  echo join(info.synstack, ' ⊂ ')
  execute "echohl" info.transname | echon ' xxx ' | echohl None

  if info.name != info.tname
    echon $'T: {info.tname} → {info.name}'
  elseif info.name != info.transname
    echon $'{info.name} → {info.transname} '
  else
    echon $'{info.name} '
  endif

  echohl ColortemplateInfoFg | echon '  ' | echohl None
  echon $' fg={info.fggui}/{info.fgterm} '

  if info.bggui != 'NONE' || info.bgterm != 'NONE'
    echohl ColortemplateInfoBg | echon '  ' | echohl None
    echon $' bg={info.bggui}/{info.bgterm} '
  endif

  if info.spgui != 'NONE' || info.spterm != 'NONE'
    echohl ColortemplateInfoSp | echon "  " | echohl None
    echon $' sp={info.spgui}/{info.spterm} '
  endif
enddef

export def BalloonExpr(): string # See :help popup_beval_example
  var beval_text = v:beval_text

  if sBalloonID > 0 && popup_getpos(sBalloonID) != null_dict # Previous popup window still shows
    if beval_text == sLastBalloonText # Still the same text, keep the existing popup
      return null_string
    endif

    popup_close(sBalloonID)
  endif

  var info = GetHighlightInfoAt(v:beval_lnum, v:beval_col)

  if !empty(info)
    var name  = info.name
    var tname = info.tname
    var trans = info.transname
    var text0 = (name == tname) ? name : $'T:{tname} → {name}'

    if name != trans
      text0 ..= $' → {trans}'
    endif

    var text1 = printf('     Fg %7s %4s     ', info.fggui, info.fgterm)
    var prop1 = [{col: 2, length: 2, type: 'ct_hifg'}]
    var beval = [{text: text0, props: []}, {text: text1, props: prop1}]

    if info.bggui != 'NONE' || info.bgterm != 'NONE'
      beval->add({
        text: printf('     Bg %7s %4s     ', info.bggui, info.bgterm),
        props: [{col: 2, length: 2, type: 'ct_hibg'}],
      })
    endif

    if info.spgui != 'NONE' || info.spterm != 'NONE'
      beval->add({
        text: printf('     Sp %7s %4s     ', info.spgui, info.spterm),
        props: [{col: 2, length: 2, type: 'ct_hisp'}]
      })
    endif

    beval->add({text: join(info.synstack, " ⊂ "), props: []})

    sBalloonID = popup_beval(beval, {padding: [0, 1, 0, 1]})
    sLastBalloonText = beval_text
  endif

  return null_string
enddef

export def ToggleHighlightInfo()
  if get(g:, 'colortemplate_higroup_popup', true)
    if sBalloonID > 0 && popup_getpos(sBalloonID) != null_dict
      popup_close(sBalloonID)
    endif

    if has('balloon_eval')
      set ballooneval!
    endif

    if has('balloon_eval_term')
      set balloonevalterm!
    endif
  endif

  if get(g:, 'colortemplate_higroup_command_line', true)
    if exists("#colortemplate_syn_info")
      autocmd! colortemplate_syn_info
      augroup! colortemplate_syn_info
      echo "\r"
    else
      cachedHiGroup = {synid: -1}

      augroup colortemplate_syn_info
        autocmd CursorMoved * call GetHighlightInfo()
      augroup END
    endif
  endif
enddef

export def ApproximateColor(n: number)
  var ctx = Context.new(getline('.'))
  var result = ColorParser(ctx)

  if !result.success
    return
  endif

  var guiValue = result.value[3]
  var approx   = Neighbours(guiValue, n)[-1]

  setline('.', substitute(getline('.'), '\~', string(approx.xterm), ''))
enddef

export def NearbyColors(n: float)
  var ctx = Context.new(getline('.'))
  var result = ColorParser(ctx)

  if !result.success
    return
  endif

  const guiValue = result.value[3]

  echo ColorsWithin(guiValue, n)
enddef
