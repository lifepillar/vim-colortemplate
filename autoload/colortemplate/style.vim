" Popup state {{{
" Current style
let s:higroup   = 'Normal'
let s:color     = #{ fg: '#000000', bg: '#000000', sp: '#000000' }
let s:bold      = 0
let s:italic    = 0
let s:inverse   = 0
let s:standout  = 0
let s:underline = 0
let s:undercurl = 0
let s:strike    = 0

" Popup configuration
const s:mode = (has('gui_running') || (has('termguicolors') && &termguicolors) ? 'gui': 'cterm')
const s:mark = get(g:, 'colortemplate_marker', '=> ')
const s:width = 39 + len(s:mark) " Popup width
let s:popup_x = 0                " Horizontal position of the popup (0=center)
let s:popup_y = 0                " Vertical position of the popup (0=center)
let s:popup_id = -1              " Popup buffer ID
let s:active_line = 1            " Where the marker is located in the popup
let s:pane = 'rgb'               " Current pane ('rgb', 'gray', 'hsl')
let s:coltype = 'fg'             " Currently displayed color ('fg', 'bg', 'sp')
let s:recent  = []               " List of recent colors
let s:favorites = []             " List of favorite colors
" }}}
" Helper functions {{{
" Builds a level bar (for simplicity called a "slider") with a specified
" value.
"
" name: The label for the level bar
" value: the value of the level bar (0–255)
" width: the maximum width of the bar
"
" NOTE: to be rendered correctly, ambiwidth must be set to 'single'.
fun! s:slider(name, value, width = 32)
  let l:whole = a:value * a:width / 256
  let l:frac = a:value * a:width / 256.0 - l:whole
  let l:bar = repeat('█', l:whole)
  let l:part_width = float2nr(floor(l:frac * 8))
  let l:part_char = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉"][l:part_width]
  let l:bar = printf("%s %3d %s", a:name, a:value, l:bar.l:part_char)
  return l:bar
endf

fun! s:is_active_line(linenr)
  return a:linenr == s:active_line
endf

fun! s:set_higroup(name)
  let s:higroup     = empty(a:name) ? 'Normal' : a:name
  let l:id          = hlID(a:name)
  let s:color.fg    = colortemplate#syn#higroup2hex(a:name, 'fg')
  let s:color.bg    = colortemplate#syn#higroup2hex(a:name, 'bg')
  let s:color.sp    = colortemplate#syn#higroup2hex(a:name, 'sp')
  let s:bold        = synIDattr(l:id, 'bold') ==# '1' ? 1 : 0
  let s:italic      = synIDattr(l:id, 'italic') ==# '1' ? 1 : 0
  let s:inverse     = synIDattr(l:id, 'reverse') ==# '1' ? 1 : 0
  let s:standout    = synIDattr(l:id, 'standout') ==# '1' ? 1 : 0
  let s:underline   = synIDattr(l:id, 'underline') ==# '1' ? 1 : 0
  let s:undercurl   = synIDattr(l:id, 'undercurl') ==# '1' ? 1 : 0
  let s:strike      = synIDattr(l:id, 'strike') ==# '1' ? 1 : 0
endf

fun! s:set_higroup_under_cursor()
  call s:set_higroup(synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name'))
endf

fun! s:choose_gui_color()
  let l:col = input('New color: #', '')
  if !has('patch-8.1.1456')
    redraw! " see https://github.com/vim/vim/issues/4473
  endif
  if l:col =~# '\m^[0-9a-fa-f]\{1,6}$'
    if len(l:col) <= 3
      let l:col = repeat(l:col, 6 /  len(l:col))
    endif
    if len(l:col) == 6
      let s:color[s:coltype] = '#'.l:col
      call s:apply_color()
      call s:redraw()
    endif
  endif
endf

fun! s:choose_term_color()
  let l:col = input('New terminal color [16-255]: ', '')
  if !has('patch-8.1.1456')
    redraw! " see https://github.com/vim/vim/issues/4473
  endif
  if l:col =~# '\m^[0-9]\{1,3}$' && str2nr(l:col) > 15 && str2nr(l:col) < 256
    let s:color[s:coltype] = colortemplate#colorspace#xterm256_hexvalue(str2nr(l:col))
    call s:apply_color()
    call s:redraw()
  endif
endf

fun! s:save_popup_position(id)
  let s:popup_x = popup_getoptions(a:id)['col']
  let s:popup_y = popup_getoptions(a:id)['line']
endf
" }}}
" Text properties {{{
fun! s:set_highlight()
  " FIXME: distinguish between GUI and terminal colors.
  let s:lgc = colortemplate#syn#higroup2hex('Label', 'fg')
  let s:ltc = synIDattr(synIDtrans(hlID('Label')), 'fg', 'cterm')
  hi! clear ColortemplateGUIColor
  hi! clear ColortemplateTermColor
  execute printf("hi! ColortemplateBold guifg=%s ctermfg=%s cterm=bold gui=bold", s:lgc, s:ltc)
  execute printf("hi! ColortemplateItalic guifg=%s ctermfg=%s cterm=italic gui=italic", s:lgc, s:ltc)
  execute printf("hi! ColortemplateUnderline guifg=%s ctermfg=%s cterm=underline gui=underline", s:lgc, s:ltc)
  execute printf("hi! ColortemplateUndercurl guifg=%s ctermfg=%s cterm=undercurl gui=undercurl", s:lgc, s:ltc)
  execute printf("hi! ColortemplateStandout guifg=%s ctermfg=%s cterm=standout gui=standout", s:lgc, s:ltc)
  execute printf("hi! ColortemplateInverse guifg=%s ctermfg=%s cterm=inverse gui=inverse", s:lgc, s:ltc)
  execute printf("hi! ColortemplateStrike guifg=%s ctermfg=%s cterm=strikethrough gui=strikethrough", s:lgc, s:ltc)
  " FIXME: decorative highlights, to be eliminated:
  hi! ColortemplateC1 guibg=#a62317 ctermbg=124
  hi! ColortemplateC2 guibg=#ff966e ctermbg=209
  hi! ColortemplateC3 guibg=#d5b088 ctermbg=180
  hi! ColortemplateC4 guibg=#0c594e ctermbg=23
  hi! ColortemplateC5 guibg=#ffd393 ctermbg=222
endf

fun! s:add_prop_types()
  """""""""""""""""""" Generic properties
  " Title of the pane
  call prop_type_add('title', #{bufnr: winbufnr(s:popup_id), highlight: 'Title'})
  " Mark line as an item that can be selected
  call prop_type_add('item',  #{bufnr: winbufnr(s:popup_id), highlight: 'Ignore'})
  " Mark line as a label
  call prop_type_add('label', #{bufnr: winbufnr(s:popup_id), highlight: 'Label'})
  " To highlight text with the currently selected highglight group
  call prop_type_add('curr',  #{bufnr: winbufnr(s:popup_id), highlight: s:higroup})
  " Highglight for the current GUI color
  call prop_type_add('gcol',  #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateGUIColor'})
  " Highlight for the current cterm color
  call prop_type_add('tcol',  #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateTermColor'})
  " Highlight for attributes
  call prop_type_add('bold',  #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateBold'})
  call prop_type_add('it',    #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateItalic'})
  call prop_type_add('ul',    #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateUnderline'})
  call prop_type_add('uc',    #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateUndercurl'})
  call prop_type_add('st',    #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStandout'})
  call prop_type_add('inv',   #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateInverse'})
  call prop_type_add('strik', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStrike'})
  """"""""""""""""""" Pane-specific properties
  " Mark line as an RGB slider
  call prop_type_add('rgb',   #{bufnr: winbufnr(s:popup_id), highlight: 'Ignore'})
  call prop_type_add('red',   #{bufnr: winbufnr(s:popup_id), highlight: 'Ignore'})
  call prop_type_add('green', #{bufnr: winbufnr(s:popup_id), highlight: 'Ignore'})
  call prop_type_add('blue',  #{bufnr: winbufnr(s:popup_id), highlight: 'Ignore'})

  " FIXME: decorative types, to be eliminated
  call prop_type_add('C1', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateC1'})
  call prop_type_add('C2', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateC2'})
  call prop_type_add('C3', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateC3'})
  call prop_type_add('C4', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateC4'})
  call prop_type_add('C5', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateC5'})
endf

fun! s:noprop(t)
  return #{ text: a:t, props: [] }
endfunc

fun! s:propitem(t, linenr)
  return #{
        \ text: (s:is_active_line(a:linenr) ? s:mark : repeat(' ', len(s:mark))).a:t,
        \ props: [#{type: 'item', col: 1, length: 0}]
        \ }
endf

fun! s:proplevel(t, linenr, pane, name)
  return #{
        \ text: (s:is_active_line(a:linenr) ? s:mark : repeat(' ', len(s:mark))).a:t,
        \ props: [#{type: 'item',  col: 1, length: 0},
        \         #{type: a:pane,  col: 1, length: 0},
        \         #{type: a:name,  col: 1, length: 0}]
        \ }
endf

" Returns the next line after linenr, which has an 'item' property.
" It wraps at the last item.
fun! s:find_next_item(linenr)
  let l:next = prop_find(#{bufnr: winbufnr(s:popup_id), type: 'item', lnum: a:linenr, col: 1, skipstart: 1}, 'f')
  if empty(l:next)
    let l:next = prop_find(#{bufnr: winbufnr(s:popup_id), type: 'item', lnum: 1, col: 1}, 'f')
    if empty(l:next) " This should never happen
      echohl Error
      echomsg '[Colortemplate] Cannot find the next item. Please report this bug.'
      echohl None
      return a:linenr
    endif
  endif
  return l:next.lnum
endf

" Returns the previous line before linenr, which has an 'item' property.
" It wraps at the first item.
fun! s:find_prev_item(linenr)
  let l:prev = prop_find(#{bufnr: winbufnr(s:popup_id), type: 'item', lnum: a:linenr - 1, col: 1,}, 'b')
  if empty(l:prev)
    let l:prev = prop_find(#{bufnr: winbufnr(s:popup_id), type: 'item', lnum: line('$', s:popup_id), col: 1}, 'b')
    if empty(l:prev) " This should never happen
      echohl Error
      echomsg '[Colortemplate] Cannot find the previous item. Please report this bug.'
      echohl None
      return a:linenr
    endif
  endif
  return l:prev.lnum
endf

fun! s:proptitle(t)
  return #{ text: a:t, props: [#{type: 'title', col: 1, length: s:width}] }
endf

fun! s:proplabel(t)
  return #{ text: a:t, props: [#{type: 'label', col: 1, length: s:width}] }
endf

fun! s:propcurrent(t)
  call prop_type_change('curr', #{bufnr: winbufnr(s:popup_id), highlight: s:higroup})
  return #{ text: a:t, props: [#{type: 'curr', col: 1, length: s:width}] }
endf

fun! s:has_property(list, prop)
  return index(a:list, a:prop) != - 1
endf
" }}}
" RGB Pane {{{
fun! s:rgb_increase_level(props)
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:color[s:coltype])
  if s:has_property(a:props, 'red') && l:r < 255
    let l:r += 1
  elseif s:has_property(a:props, 'green') && l:g < 255
    let l:g += 1
  elseif s:has_property(a:props, 'blue') && l:b < 255
    let l:b += 1
  endif
  let s:color[s:coltype] = colortemplate#colorspace#rgb2hex(l:r, l:g, l:b)
endf

fun! s:rgb_decrease_level(props)
 let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:color[s:coltype])
  if s:has_property(a:props, 'red') && l:r > 0
    let l:r -= 1
  elseif s:has_property(a:props, 'green') && l:g > 0
    let l:g -= 1
  elseif s:has_property(a:props, 'blue') && l:b > 0
    let l:b -= 1
  endif
  let s:color[s:coltype] = colortemplate#colorspace#rgb2hex(l:r, l:g, l:b)
endf

fun! s:redraw_rgb()
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:color[s:coltype])
  let l:t = (s:coltype ==# 'fg' ? 'Fg' : (s:coltype ==# 'bg' ? 'Bg' : 'Sp'))
  let l:tc = colortemplate#colorspace#approx(s:color[s:coltype])
  call popup_settext(s:popup_id, [
        \ s:proptitle(printf('%s%s%s', s:higroup, repeat(' ', s:width - len(s:higroup) - 4), 'RHG?')), s:noprop(''),
        \ s:proplevel(s:slider('R', l:r), 3, 'rgb', 'red'),
        \ s:proplevel(s:slider('G', l:g), 4, 'rgb', 'green'),
        \ s:proplevel(s:slider('B', l:b), 5, 'rgb', 'blue'),
        \ s:noprop(''),
        \ s:noprop(printf('%s %s     %3d      BIUSV~-    ', l:t, s:color[s:coltype], l:tc['index'])),
        \ s:noprop(''),
        \ s:propcurrent('The quick brown fox jumped over the lazy dog'),
        \ s:noprop(''),
        \ s:proplabel('Recent'),
        \ s:propitem('0    1    2    NOT IMPLEMENTED YET      ', 12),
        \ s:noprop(''),
        \ s:proplabel('Favorites'),
        \ s:propitem('0    1         NOT IMPLEMENTED YET      ', 15),
        \ ])
  call prop_add(7,  1, #{bufnr: winbufnr(s:popup_id), length: 2, type: 'label'})
  call prop_add(1, 39, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'label'})
  if s:mode ==# 'gui'
    execute printf('hi! ColortemplateGUIColor guibg=%s ctermbg=%d', s:color[s:coltype], l:tc['index'])
    call prop_add(7, 12, #{bufnr: winbufnr(s:popup_id), length: 3, type: 'gcol'})
  endif
  execute printf('hi! ColortemplateTermColor guibg=%s ctermbg=%d', colortemplate#colorspace#xterm256_hexvalue(l:tc['index']), l:tc['index'])
  call prop_add(7, 20, #{bufnr: winbufnr(s:popup_id), length: 3, type: 'tcol'})
  " TODO: refactor attributes
  if s:bold
    call prop_add(7, 25, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'bold'})
  endif
  if s:italic
    call prop_add(7, 26, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'it'})
  endif
  if s:underline
    call prop_add(7, 27, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'ul'})
  endif
  if s:standout
    call prop_add(7, 28, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'st'})
  endif
  if s:inverse
    call prop_add(7, 29, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'inv'})
  endif
  if s:undercurl
    call prop_add(7, 30, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'uc'})
  endif
  if s:strike
    call prop_add(7, 31, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'strik'})
  endif
  " FIXME: temporary properties, just for decoration
  call prop_add(12, 6, #{bufnr: winbufnr(s:popup_id), length: 2, type: 'C1'})
  call prop_add(12, 11, #{bufnr: winbufnr(s:popup_id), length: 2, type: 'C2'})
  call prop_add(12, 16, #{bufnr: winbufnr(s:popup_id), length: 2, type: 'C3'})
  call prop_add(15, 6, #{bufnr: winbufnr(s:popup_id), length: 2, type: 'C4'})
  call prop_add(15, 11, #{bufnr: winbufnr(s:popup_id), length: 2, type: 'C5'})
endf
" }}}
" HSL Pane {{{
fun! s:redraw_hsl()
  call popup_settext(s:popup_id, [
        \ s:proptitle(printf('%s%s%s', s:higroup, repeat(' ', s:width - len(s:higroup) - 4), 'RHG?')),
        \ s:noprop(''),
        \ s:proplabel('Not implemented yet.'),
        \ s:proplabel('Please switch back to R.'),
        \ ])
  call prop_add(1, 40, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'label'})
endf
" }}}
" Grayscale Pane {{{
fun! s:redraw_gray()
  call popup_settext(s:popup_id, [
        \ s:proptitle(printf('%s%s%s', s:higroup, repeat(' ', s:width - len(s:higroup) - 4), 'RHG?')),
        \ s:noprop(''),
        \ s:proplabel('Not implemented yet.'),
        \ s:proplabel('Please switch back to R.'),
        \ ])
  call prop_add(1, 41, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'label'})
endf
" }}}
" Help pane {{{
fun! s:redraw_help()
  call popup_settext(s:popup_id, [
        \ s:proptitle(printf('Keyboard Controls%s%s', repeat(' ', s:width - 21), 'RHG?')),
        \ s:noprop(''),
        \ s:proplabel('Popup'),
        \ s:noprop('[x] Close             [R] RGB'),
        \ s:noprop('[X] Cancel            [H] HSL'),
        \ s:noprop('[Tab] fg->bg->sp      [G] Grayscale'),
        \ s:noprop('[S-Tab] sp->bg->fg    [?] Help pane'),
        \ s:noprop(''),
        \ s:proplabel('Attributes'),
        \ s:noprop('[B] Toggle boldface   [V] Toggle reverse'),
        \ s:noprop('[I] Toggle italics    [S] Toggle standout'),
        \ s:noprop('[U] Toggle underline  [~] Toggle undercurl'),
        \ s:noprop('[-] Toggle strikethrough'),
        \ s:noprop(''),
        \ s:proplabel('Color'),
        \ s:noprop('[→] Increase value    [E] New value'),
        \ s:noprop('[←] Decrease value    [N] New hi group'),
        \ s:noprop('[y] Yank color'),
        \ ])
  call prop_add(1, 42, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'label'})
endf
" }}}
" Popup actions {{{
fun! s:commit()
  call popup_close(s:popup_id)
endf

fun! s:cancel()
  call popup_close(s:popup_id)
  if exists('g:colors_name') && !empty('g:colors_name')
    execute 'colorscheme' g:colors_name
  endif
endf

fun! s:yank()
  let @"=s:color[s:coltype]
endf

fun! s:mouse_clicked()
  echo string(s:popup_id) . ' ' . string(getmousepos())
endf

fun! s:select_next_item()
  let s:active_line = s:find_next_item(s:active_line)
  call s:redraw()
endf

fun! s:select_prev_item()
  let s:active_line = s:find_prev_item(s:active_line)
  call s:redraw()
endf

fun! s:update_higroup()
  call s:set_higroup_under_cursor()
  " TODO: save current color to recent colors if modified
  call s:redraw()
endf

fun! s:fgbgsp_next()
  let s:coltype = (s:coltype == 'fg' ? 'bg' : (s:coltype == 'bg' ? 'sp' : 'fg'))
  call s:redraw()
endf

fun! s:fgbgsp_prev()
  let s:coltype = (s:coltype == 'bg' ? 'fg' : (s:coltype == 'fg' ? 'sp' : 'bg'))
  call s:redraw()
endf

fun! s:toggle_attribute(attrname)
  call colortemplate#syn#toggle_attribute(hlID(s:higroup), a:attrname)
  call s:set_higroup(s:higroup)
  call s:redraw()
endf

fun! s:toggle_bold()
  call s:toggle_attribute('bold')
endf

fun! s:toggle_italic()
  call s:toggle_attribute('italic')
endf

fun! s:toggle_underline()
  call s:toggle_attribute('underline')
endf

fun! s:toggle_undercurl()
  call s:toggle_attribute('undercurl')
endf

fun! s:toggle_standout()
  call s:toggle_attribute('standout')
endf

fun! s:toggle_inverse()
  call s:toggle_attribute('inverse')
endf

fun! s:toggle_strike()
  call s:toggle_attribute('strikethrough')
endf

fun! s:edit_color()
  if s:mode ==# 'gui'
    call s:choose_gui_color()
  else
    call s:choose_term_color()
  endif
endf

fun! s:edit_name()
  let l:name = input('Highlight group: ', '', 'highlight')
  if !has('patch-8.1.1456')
    redraw! " see https://github.com/vim/vim/issues/4473
  endif
  if l:name =~# '\m^\w\+$'
    call s:set_higroup(l:name)
    call s:redraw()
  endif
endf

fun! s:set_pane(p)
  let s:pane = a:p
  call s:redraw()
endf

fun! s:switch_to_rgb()
  call s:set_pane('rgb')
endf

fun! s:switch_to_hsl()
  call s:set_pane('hsl')
endf

fun! s:switch_to_grayscale()
  call s:set_pane('gray')
endf

fun! s:switch_to_help()
  call s:set_pane('help')
endf

fun! s:notify_change()
  silent doautocmd User ColortemplateStyleChanged
endf

fun! s:apply_color()
  let l:tfg = colortemplate#colorspace#approx(s:color.fg)
  let l:tbg = colortemplate#colorspace#approx(s:color.bg)
  execute "hi!" s:higroup "guifg=".s:color['fg'] "guibg=".s:color['bg'] "ctermfg=".l:tfg.index "ctermbg=".l:tbg.index
endf

fun! s:move_right()
  let l:props = map(prop_list(s:active_line, #{bufnr: winbufnr(s:popup_id)}), { i,v -> v.type })
  if s:has_property(l:props, 'rgb')
    call s:rgb_increase_level(l:props)
  endif
  call s:apply_color()
  call s:redraw()
endf

fun! s:move_left()
  let l:props = map(prop_list(s:active_line, #{bufnr: winbufnr(s:popup_id)}), { i,v -> v.type })
  if s:has_property(l:props, 'rgb')
    call s:rgb_decrease_level(l:props)
  endif
  call s:apply_color()
  call s:redraw()
endf

fun! s:redraw()
  if s:pane ==# 'rgb'
    call s:redraw_rgb()
  elseif s:pane ==# 'hsl'
    call s:redraw_hsl()
  elseif s:pane ==# 'gray'
    call s:redraw_gray()
  elseif s:pane ==# 'help'
    call s:redraw_help()
  endif
endf
" }}}
" Keymap {{{
let s:keymap = {
      \ "x"           : function('s:commit'),
      \ "X"           : function('s:cancel'),
      \ "y"           : function('s:yank'),
      \ "\<down>"     : function('s:select_next_item'),
      \ "\<up>"       : function('s:select_prev_item'),
      \ "\<left>"     : function('s:move_left'),
      \ "\<right>"    : function('s:move_right'),
      \ "\<tab>"      : function('s:fgbgsp_next'),
      \ "\<s-tab>"    : function('s:fgbgsp_prev'),
      \ "B"           : function('s:toggle_bold'),
      \ "I"           : function('s:toggle_italic'),
      \ "U"           : function('s:toggle_underline'),
      \ "S"           : function('s:toggle_standout'),
      \ "V"           : function('s:toggle_inverse'),
      \ "~"           : function('s:toggle_undercurl'),
      \ "-"           : function('s:toggle_strike'),
      \ "E"           : function('s:edit_color'),
      \ "N"           : function('s:edit_name'),
      \ "R"           : function('s:switch_to_rgb'),
      \ "H"           : function('s:switch_to_hsl'),
      \ "G"           : function('s:switch_to_grayscale'),
      \ "?"           : function('s:switch_to_help'),
      \ }

fun! colortemplate#style#filter(winid, key)
  if has_key(s:keymap, a:key)
    call s:keymap[a:key]()
    return 1
  endif
  return 0
endf
" }}}
" Public interface {{{
" Callback for when the popup is closed
fun! colortemplate#style#closed(id, result)
  if exists('#colortemplate_style')
    autocmd! colortemplate_style
    augroup! colortemplate_style
  endif
  call s:save_popup_position(a:id)
  let s:popup_id = -1
endf

" Optional argument is the name of a highlight group
" If no name is used, then the popup updates as the cursor moves,
" selecting the highlight group under the cursor.
" TODO: open at the upper right of the screen/window
" TODO: remember last position
fun! colortemplate#style#open(...)
  if s:popup_id > -1 " Already open
    return s:popup_id
  endif

  if empty(a:000) || empty(a:1)
    call s:set_higroup_under_cursor()
    " Track the cursot
    augroup colortemplate_style
      " TODO: do not redraw unnecessarily
      autocmd CursorMoved * call s:update_higroup()
    augroup END
  else
    call s:set_higroup(a:1)
  endif

  call s:set_highlight()
  augroup colortemplate_style
    autocmd ColorScheme * call s:set_highlight()
  augroup END

  let s:popup_id = popup_create('', #{
        \ border: [1,1,1,1],
        \ borderchars: ['-', '|', '-', '|', '┌', '┐', '┘', '└'],
        \ callback: 'colortemplate#style#closed',
        \ close: 'button',
        \ cursorline: 0,
        \ drag: 1,
        \ filter: 'colortemplate#style#filter',
        \ filtermode: 'n',
        \ highlight: 'Normal',
        \ mapping: 0,
        \ maxwidth: s:width,
        \ minwidth: s:width,
        \ padding: [0,1,0,1],
        \ pos: 'topleft',
        \ line: s:popup_y,
        \ col: s:popup_x,
        \ resize: 0,
        \ scrollbar: 0,
        \ tabpage: 0,
        \ title: '',
        \ wrap: 0,
        \ zindex: 200,
        \ })
  echomsg s:popup_id
  call s:add_prop_types()
  let s:active_line = 3
  call s:redraw()
  return s:popup_id
endf
" }}}
