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
let s:mark = ''                  " Marker for the current line (set when the popup is open)
let s:width = 0                  " Popup width (set when the popup is open)
let s:star = ''                  " Star for colors (set when the popup is open)
let s:popup_x = 0                " Horizontal position of the popup (0=center)
let s:popup_y = 0                " Vertical position of the popup (0=center)
let s:popup_id = -1              " Popup buffer ID
let s:active_line = 1            " Where the marker is located in the popup
let s:pane = 'rgb'               " Current pane ('rgb', 'gray', 'hsl')
let s:coltype = 'fg'             " Currently displayed color ('fg', 'bg', 'sp')
let s:step = 1                   " Step for increasing/decreasing levels
let s:step_reset = 1             " Status of the step counter
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

" Assign up to five stars to a pair of colors according to how many criteria
" the pair satifies. Thresholds follow W3C guidelines.
fun! s:stars(c1, c2)
  let l:cr = colortemplate#colorspace#contrast_ratio(a:c1, a:c2)
  let l:cd = colortemplate#colorspace#color_difference(a:c1, a:c2)
  let l:bd = colortemplate#colorspace#brightness_diff(a:c1, a:c2)
  return repeat(s:star, (l:cr >= 3.0) + (l:cr >= 4.5) + (l:cr >= 7.0) + (l:cd >= 500) + (l:bd >= 125))
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
  let l:c = synIDattr(synIDtrans(hlID('Label')), 'fg', s:mode)
  hi! clear ColortemplateStyleGUIColor
  hi! clear ColortemplateStyleTermColor
  execute printf("hi! ColortemplateStyleBold %sfg=%s cterm=bold gui=bold", s:mode, l:c)
  execute printf("hi! ColortemplateStyleItalic %sfg=%s cterm=italic gui=italic", s:mode, l:c)
  execute printf("hi! ColortemplateStyleUnderline %sfg=%s cterm=underline gui=underline", s:mode, l:c)
  execute printf("hi! ColortemplateStyleUndercurl %sfg=%s cterm=inverse gui=inverse", s:mode, l:c)
  execute printf("hi! ColortemplateStyleStandout %sfg=%s cterm=standout gui=standout", s:mode, l:c)
  execute printf("hi! ColortemplateStyleInverse %sfg=%s cterm=inverse gui=inverse", s:mode, l:c)
  execute printf("hi! ColortemplateStyleStrike %sfg=%s cterm=inverse gui=inverse", s:mode, l:c)

  " FIXME: decorative highlights, to be eliminated:
  hi! ColortemplateC1 guibg=#a62317 ctermbg=124
  hi! ColortemplateC2 guibg=#ff966e ctermbg=209
  hi! ColortemplateC3 guibg=#d5b088 ctermbg=180
  hi! ColortemplateC4 guibg=#0c594e ctermbg=23
  hi! ColortemplateC5 guibg=#ffd393 ctermbg=222
endf

fun! s:add_prop_types()
  " Title of the pane
  call prop_type_add('title', #{bufnr: winbufnr(s:popup_id), highlight: 'Title'})
  " Mark line as an item that can be selected
  call prop_type_add('item',  #{bufnr: winbufnr(s:popup_id), highlight: 'Ignore'})
  " Mark line as a label
  call prop_type_add('label', #{bufnr: winbufnr(s:popup_id), highlight: 'Label'})
  " Mark line as a level bar (slider)
  call prop_type_add('level', #{bufnr: winbufnr(s:popup_id), highlight: 'Ignore'})
  " To highlight text with the currently selected highglight group
  call prop_type_add('curr',  #{bufnr: winbufnr(s:popup_id), highlight: s:higroup})
  " Highglight for the current GUI color
  call prop_type_add('gcol',  #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleGUIColor'})
  " Highlight for the current cterm color
  call prop_type_add('tcol',  #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleTermColor'})
  " Highlight for attributes
  call prop_type_add('bold',  #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleBold'})
  call prop_type_add('it',    #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleItalic'})
  call prop_type_add('ul',    #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleUnderline'})
  call prop_type_add('uc',    #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleUndercurl'})
  call prop_type_add('st',    #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleStandout'})
  call prop_type_add('inv',   #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleInverse'})
  call prop_type_add('strik', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplateStyleStrike'})
  call prop_type_add('disabled', #{bufnr: winbufnr(s:popup_id), highlight: 'Comment'})
  " RGB pane
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

fun! s:init_pane()
  let s:__line__ = 0 " Keeps track of the line being built
endf

" Defines a new generic, non-selectable, text line with properties.
"
" t: a String
" props: an Array of text properties, as in popup_settext().
"
" Returns a Dictionary.
fun! s:prop(t, props)
  let s:__line__ += 1
  return #{ text: a:t, props: a:props }
endf

" Defines a new selectable line in the popup. If the line is currently
" selected, a marker is prepended to it.
fun! s:prop_item(t, props = [])
  let s:__line__ += 1
  return #{ text: (s:__line__ == s:active_line ? s:mark : repeat(' ', len(s:mark)))..a:t,
        \   props: extend([#{ col: 1, length: 0, type: 'item' }], a:props),
        \}
endf

fun! s:blank()
  return s:prop('', [])
endf

fun! s:noprop(t)
  return s:prop(a:t, [])
endfunc

fun! s:prop_level_bar(t, pane, name)
  return s:prop_item(a:t, [#{ col: 1, length: 0, type: 'level' },
        \                  #{ col: 1, length: 0, type: a:pane },
        \                  #{ col: 1, length: 0, type: a:name }])
endf

fun! s:prop_label(t)
  return s:prop(a:t, [#{ col: 1, length: s:width, type: 'label' }])
endf

fun! s:prop_current(t)
  return s:prop(a:t, [#{ col: 1, length: s:width, type: 'curr' }])
endf

" Returns the list of the names of the text properties for the given line
fun! s:get_properties(linenr)
  return map(prop_list(a:linenr, #{bufnr: winbufnr(s:popup_id)}), { i,v -> v.type })
endf

fun! s:has_property(list, prop)
  return index(a:list, a:prop) != - 1
endf

" Returns the next line after linenr, which has an 'item' property.
" It wraps at the last item.
fun! s:find_next_item(linenr)
  let l:next = prop_find(#{bufnr: winbufnr(s:popup_id), type: 'item', lnum: a:linenr, col: 1, skipstart: 1}, 'f')
  if empty(l:next)
    let l:next = prop_find(#{bufnr: winbufnr(s:popup_id), type: 'item', lnum: 1, col: 1}, 'f')
  endif
    return empty(l:next) ? a:linenr : l:next.lnum
endf

" Returns the previous line before linenr, which has an 'item' property.
" It wraps at the first item.
fun! s:find_prev_item(linenr)
  let l:prev = prop_find(#{bufnr: winbufnr(s:popup_id), type: 'item', lnum: a:linenr - 1, col: 1,}, 'b')
  if empty(l:prev)
    let l:prev = prop_find(#{bufnr: winbufnr(s:popup_id), type: 'item', lnum: line('$', s:popup_id), col: 1}, 'b')
  endif
  return empty(l:prev) ? a:linenr : l:prev.lnum
endf

" }}}
" Title of a pane {{{
fun! s:title_section(pane) " -> List of Dictionaries
  let l:n = (a:pane ==# 'R' ? 1 : a:pane==# 'H' ? 2 : a:pane ==# 'G' ? 3 : 4)
  let l:ct = (s:coltype ==# 'fg' ? 'Fg' : (s:coltype ==# 'bg' ? 'Bg' : 'Sp'))
  return [
        \ s:prop(
        \   printf('%s [%s]%s%s', s:higroup, l:ct, repeat(' ', s:width - (len(s:higroup) + len(l:ct)) - 7), 'RHG?'),
        \   [#{ col: 1, length: s:width, type: 'title' }, #{ col: 38 + l:n, length: 1, type: 'label' }],
        \ ),
        \]
endf
" }}}
" Info section of a pane {{{
fun! s:info_section() " -> List of Dictionaries
  let l:tc = {}
  let l:th = {}
  if s:coltype ==# 'sp'
    let l:tc['sp']   = colortemplate#colorspace#approx(s:color['sp'])
    let l:tc['bg']   = colortemplate#colorspace#approx(s:color['bg'])
    let l:th['sp']   = colortemplate#colorspace#xterm256_hexvalue(l:tc['sp']['index'])
    let l:th['bg']   = colortemplate#colorspace#xterm256_hexvalue(l:tc['bg']['index'])
    let s:term_stars = s:stars(l:th['sp'], l:th['bg'])
    let s:gui_stars  = s:stars(s:color['sp'], s:color['bg'])
  else
    let l:tc['fg']   = colortemplate#colorspace#approx(s:color['fg'])
    let l:tc['bg']   = colortemplate#colorspace#approx(s:color['bg'])
    let l:th['fg']   = colortemplate#colorspace#xterm256_hexvalue(l:tc['fg']['index'])
    let l:th['bg']   = colortemplate#colorspace#xterm256_hexvalue(l:tc['bg']['index'])
    let s:term_stars = s:stars(l:th['fg'], l:th['bg'])
    let s:gui_stars  = s:stars(s:color['fg'], s:color['bg'])
  endif
  if s:mode ==# 'gui'
    execute printf('hi! ColortemplateStyleGUIColor guibg=%s ctermbg=%d', s:color[s:coltype], l:tc[s:coltype]['index'])
  endif
  execute printf('hi! ColortemplateStyleTermColor guibg=%s ctermbg=%d', l:th[s:coltype], l:tc[s:coltype]['index'])
  call prop_type_change('curr', #{bufnr: winbufnr(s:popup_id), highlight: s:higroup})
  let l:delta = l:tc[s:coltype]['delta']

  return [
        \ s:blank(),
        \ s:prop(printf('   %s %-5s    %3d %-5s Δ%.'..(l:delta>=10.0?'f  ':'1f ')..'BIUSV~-',
        \          s:color[s:coltype], s:gui_stars, l:tc[s:coltype]['index'], s:term_stars, l:tc[s:coltype]['delta']),
        \        [
        \         #{ col:  1, length: 2, type: 'label' },
        \         #{ col:  1, length: 2, type: (s:mode ==# 'gui' ? 'gcol' : 'disabled') },
        \         #{ col: 18, length: 2, type: 'tcol' },
        \         #{ col: 37, length: 1, type: (s:bold      ? 'bold'  : 'disabled') },
        \         #{ col: 38, length: 1, type: (s:italic    ? 'it'    : 'disabled') },
        \         #{ col: 39, length: 1, type: (s:underline ? 'ul'    : 'disabled') },
        \         #{ col: 40, length: 1, type: (s:standout  ? 'st'    : 'disabled') },
        \         #{ col: 41, length: 1, type: (s:inverse   ? 'inv'   : 'disabled') },
        \         #{ col: 42, length: 1, type: (s:undercurl ? 'uc'    : 'disabled') },
        \         #{ col: 43, length: 1, type: (s:strike    ? 'strik' : 'disabled') },
        \        ]),
        \ s:blank(),
        \ s:prop('The quick brown fox jumped over the lazy dog', [#{ col: 1, length: s:width, type: 'curr' }]),
        \]
endf
" }}}
" Recently used colors section {{{
fun! s:recent_section() " -> List of Dictionaries
  return [
        \ s:blank(),
        \ s:prop_label('Recent'),
        \ s:prop_item('0    1    2    not implemented yet      ',
        \               [
        \                 #{col:  6, length: 2, type: 'C1'},
        \                 #{col: 11, length: 2, type: 'C2'},
        \                 #{col: 16, length: 2, type: 'C3'}
        \               ]),
        \]
endf
" }}}
" Favorites section {{{
fun! s:favorites_section() " -> List of Dictionaries
  return [
        \ s:blank(),
        \ s:prop_label('Favorites'),
        \ s:prop_item('0    1         not implemented yet      ',
        \               [
        \                 #{col:  6, length: 2, type: 'C4'},
        \                 #{col: 11, length: 2, type: 'C5'},
        \               ]),
        \]
endf
" }}}
" RGB Pane {{{
fun! s:rgb_increase_level(props, value)
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:color[s:coltype])
  if s:has_property(a:props, 'red')
    let l:r += a:value
    if l:r > 255 | let l:r = 255 | endif
  elseif s:has_property(a:props, 'green')
    let l:g += a:value
    if l:g > 255 | let l:g = 255 | endif
  elseif s:has_property(a:props, 'blue')
    let l:b += a:value
    if l:b > 255 | let l:b = 255 | endif
  endif
  let s:color[s:coltype] = colortemplate#colorspace#rgb2hex(l:r, l:g, l:b)
endf

fun! s:rgb_decrease_level(props, value)
 let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:color[s:coltype])
  if s:has_property(a:props, 'red')
    let l:r -= a:value
    if l:r < 0 | let l:r = 0 | endif
  elseif s:has_property(a:props, 'green')
    let l:g -= a:value
    if l:g < 0 | let l:g = 0 | endif
  elseif s:has_property(a:props, 'blue')
    let l:b -= a:value
    if l:b < 0 | let l:b = 0 | endif
  endif
  let s:color[s:coltype] = colortemplate#colorspace#rgb2hex(l:r, l:g, l:b)
endf

fun! s:rgb_slider(r, g, b) " -> List of Dictionaries
  return [
        \ s:blank(),
        \ s:prop_level_bar(s:slider('R', a:r), 'rgb', 'red'),
        \ s:prop_level_bar(s:slider('G', a:g), 'rgb', 'green'),
        \ s:prop_level_bar(s:slider('B', a:b), 'rgb', 'blue'),
        \ s:prop_label(printf('%s%02d', repeat(' ', len(s:mark) + 3), s:step)),
        \]
endf

fun! s:redraw_rgb()
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:color[s:coltype])
  call s:init_pane()
  call popup_settext(s:popup_id,
        \ extend(extend(extend(extend(
        \   s:title_section('R'),
        \   s:rgb_slider(l:r, l:g, l:b)),
        \   s:info_section()),
        \   s:recent_section()),
        \   s:favorites_section())
        \)
endf
" }}}
" HSL Pane {{{
fun! s:redraw_hsl()
  call popup_settext(s:popup_id, [
        \ s:prop_title(printf('%s%s%s', s:higroup, repeat(' ', s:width - len(s:higroup) - 4), 'RHG?')),
        \ s:blank(),
        \ s:prop_label('Not implemented yet.'),
        \ s:prop_label('Please switch back to R.'),
        \ ])
  call prop_add(1, 40, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'label'})
endf
" }}}
" Grayscale Pane {{{
fun! s:redraw_gray()
  call popup_settext(s:popup_id, [
        \ s:prop_title(printf('%s%s%s', s:higroup, repeat(' ', s:width - len(s:higroup) - 4), 'RHG?')),
        \ s:blank(),
        \ s:prop_label('Not implemented yet.'),
        \ s:prop_label('Please switch back to R.'),
        \ ])
  call prop_add(1, 41, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'label'})
endf
" }}}
" Help pane {{{
fun! s:redraw_help()
  call popup_settext(s:popup_id, [
        \ s:prop_title(printf('Keyboard Controls%s%s', repeat(' ', s:width - 21), 'RHG?')),
        \ s:blank(),
        \ s:prop_label('Popup'),
        \ s:noprop('[x] Close             [R] RGB'),
        \ s:noprop('[X] Cancel            [H] HSL'),
        \ s:noprop('[Tab] fg->bg->sp      [G] Grayscale'),
        \ s:noprop('[S-Tab] sp->bg->fg    [?] Help pane'),
        \ s:blank(),
        \ s:prop_label('Attributes'),
        \ s:noprop('[B] Toggle boldface   [V] Toggle reverse'),
        \ s:noprop('[I] Toggle italics    [S] Toggle standout'),
        \ s:noprop('[U] Toggle underline  [~] Toggle undercurl'),
        \ s:noprop('[-] Toggle strikethrough'),
        \ s:blank(),
        \ s:prop_label('Color'),
        \ s:noprop('[→] Increase value    [E] New value'),
        \ s:noprop('[←] Decrease value    [N] New hi group'),
        \ s:noprop('[y] Yank color        [Z] Clear color'),
        \ ])
  call prop_add(1, 42, #{bufnr: winbufnr(s:popup_id), length: 1, type: 'label'})
endf
" }}}
" Popup actions {{{
fun! s:commit()
  call popup_close(s:popup_id)
  return 1
endf

fun! s:cancel()
  call popup_close(s:popup_id)
  if exists('g:colors_name') && !empty('g:colors_name')
    execute 'colorscheme' g:colors_name
  endif
  return 1
endf

fun! s:yank()
  let @"=s:color[s:coltype]
  return 1
endf

fun! s:mouse_clicked()
  echo string(s:popup_id) . ' ' . string(getmousepos())
  return 1
endf

fun! s:select_next_item()
  let s:active_line = s:find_next_item(s:active_line)
  call s:redraw()
  return 1
endf

fun! s:select_prev_item()
  let s:active_line = s:find_prev_item(s:active_line)
  call s:redraw()
  return 1
endf

fun! s:update_higroup()
  call s:set_higroup_under_cursor()
  " TODO: save current color to recent colors if modified
  call s:redraw()
  return 1
endf

fun! s:fgbgsp_next()
  let s:coltype = (s:coltype == 'fg' ? 'bg' : (s:coltype == 'bg' ? 'sp' : 'fg'))
  call s:redraw()
  return 1
endf

fun! s:fgbgsp_prev()
  let s:coltype = (s:coltype == 'bg' ? 'fg' : (s:coltype == 'fg' ? 'sp' : 'bg'))
  call s:redraw()
  return 1
endf

fun! s:toggle_attribute(attrname)
  call colortemplate#syn#toggle_attribute(hlID(s:higroup), a:attrname)
  call s:set_higroup(s:higroup)
  call s:redraw()
  return 1
endf

fun! s:toggle_bold()
  return s:toggle_attribute('bold')
endf

fun! s:toggle_italic()
  return s:toggle_attribute('italic')
endf

fun! s:toggle_underline()
  return s:toggle_attribute('underline')
endf

fun! s:toggle_undercurl()
  return s:toggle_attribute('undercurl')
endf

fun! s:toggle_standout()
  return s:toggle_attribute('standout')
endf

fun! s:toggle_inverse()
  return s:toggle_attribute('inverse')
endf

fun! s:toggle_strike()
  return s:toggle_attribute('strikethrough')
endf

fun! s:edit_color()
  if s:mode ==# 'gui'
    call s:choose_gui_color()
  else
    call s:choose_term_color()
  endif
  return 1
endf

fun! s:clear_color()
  if tolower(s:higroup) ==# 'normal'
    return 1
  endif
  let l:ct = (s:mode ==# 'cterm' && s:coltype ==# 'sp' ? 'ul' : s:coltype)
  execute "hi!" s:higroup s:mode..l:ct.."=NONE"
  call s:set_higroup(s:higroup)
  call s:redraw()
  return 1
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
  return 1
endf

fun! s:set_pane(p)
  let s:pane = a:p
  call s:redraw()
  return 1
endf

fun! s:switch_to_rgb()
  return s:set_pane('rgb')
endf

fun! s:switch_to_hsl()
  return s:set_pane('hsl')
endf

fun! s:switch_to_grayscale()
  return s:set_pane('gray')
endf

fun! s:switch_to_help()
  return s:set_pane('help')
endf

fun! s:notify_change()
  silent doautocmd User ColortemplateStyleChanged
endf

fun! s:apply_color()
  let l:ct = (s:coltype ==# 'sp' && s:mode ==# 'cterm') ? 'ul' : s:coltype
  let l:col = (s:mode ==# 'gui' ? s:color[s:coltype] : colortemplate#colorspace#approx(s:color[s:coltype])['index'])
  execute 'hi!' s:higroup s:mode..l:ct..'='..l:col
endf

fun! s:move_right()
  let l:props = s:get_properties(s:active_line)
  if s:has_property(l:props, 'rgb')
    call s:rgb_increase_level(l:props, s:step)
    call s:apply_color()
    call s:redraw()
  endif
  return 1
endf

fun! s:move_left()
  let l:props = s:get_properties(s:active_line)
  if s:has_property(l:props, 'rgb')
    call s:rgb_decrease_level(l:props, s:step)
    call s:apply_color()
    call s:redraw()
  endif
  return 1
endf

fun! s:handle_digit(n)
  let l:props = s:get_properties(s:active_line)
  if !s:has_property(l:props, 'level')
    return 0
  endif
  if s:step_reset
    let s:step = a:n
    let s:step_reset = 0
  else
    let s:step = 10 * s:step + a:n
    if s:step > 99
      let s:step = a:n
    endif
  endif
  if s:step < 1
    let s:step = 1
  endif
  call s:redraw()
  return 1
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
      \ "Z"           : function('s:clear_color'),
      \ "R"           : function('s:switch_to_rgb'),
      \ "H"           : function('s:switch_to_hsl'),
      \ "G"           : function('s:switch_to_grayscale'),
      \ "?"           : function('s:switch_to_help'),
      \ }

fun! colortemplate#style#filter(winid, key)
  if a:key =~ '\m\d'
    return s:handle_digit(a:key)
  endif
  if has_key(s:keymap, a:key)
    let s:step_reset = 1
    return s:keymap[a:key]()
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
" If no name is used, then the popup updates as the cursor moves.
fun! colortemplate#style#open(...)
  if s:popup_id > -1 " Already open
    return s:popup_id
  endif

  let s:mark    = get(g:, 'colortemplate_style_marker', '=> ')
  let s:width   = max([39 + len(s:mark), 42])
  let s:star    = get(g:, 'colortemplate_style_star', '*')
  let s:compact = get(g:, 'colortemplate_style_compact', 0)

  if empty(a:000) || empty(a:1)
    call s:set_higroup_under_cursor()
    " Track the cursor
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
        \ mapping: 1,
        \ maxwidth: s:width,
        \ minwidth: s:width,
        \ padding: (s:compact ? [0,0,0,0] : [0,1,0,1]),
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
  let s:active_line = 3
  call s:add_prop_types()
  call s:redraw()
  return s:popup_id
endf
" }}}
