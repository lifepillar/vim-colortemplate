" Global constants {{{
" Mode for colors
const s:mode = (has('gui_running') || (has('termguicolors') && &termguicolors) ? 'gui': 'cterm')
" Mode for attributes
const s:attrmode = (has('gui_running') ? 'gui' : 'cterm')
" }}}
" Popup configuration {{{
let s:keymap = {}      " Dictionary of key controls (initialized below)
let s:mark_sym = ''    " Marker for the current line (set when the popup is open)
let s:width = 0        " Popup width (set when the popup is open)
let s:gutter_width = 0 " The 'gutter' is the space reserved for the marker (set when the popup is open)
let s:popup_bg = ''    " Popup background (initialized below)
let s:star_sym = ''    " Symbol for stars (set when the popup is open)
let s:popup_x = 0      " Horizontal position of the popup (0=center)
let s:popup_y = 0      " Vertical position of the popup (0=center)
let s:popup_winid = -1 " Popup window ID
let s:popup_bufnr = -1 " Popup buffer number
let s:active_line = 1  " Where the marker is located in the popup
let s:pane = ''        " Current pane ('rgb', 'gray', 'hsb', 'help')
let s:step = 1         " Step for increasing/decreasing the values of level bars
let s:step_reset = 1   " Status of the step counter
let s:sample_texts = get(g:, 'colortemplate_popup_quotes', [
      \ "Absentem edit cum ebrio qui litigat",
      \ "Accipere quam facere praestat iniuriam",
      \ "Amicum cum vides obliviscere miserias",
      \ "Diligite iustitiam qui iudicatis terram",
      \ "Etiam capillus unus habet umbram suam",
      \ "Impunitas semper ad deteriora invitat",
      \ "Mala tempora currunt sed peiora parantur",
      \ "Nec quod fuimusve sumusve, cras erimus",
      \ "Nec sine te, nec tecum vivere possum",
      \ "Quis custodiet ipsos custodes?",
      \ "Quod non vetat lex, hoc vetat fieri pudor",
      \ "Vim vi repellere licet",
      \ "Vana gloria spica ingens est sine grano",
      \])
let s:sample_text = '' " Text displayed in the style picker
" }}}
" Helper functions {{{
fun! s:save_popup_position(id)
  let s:popup_x = popup_getoptions(a:id)['col']
  let s:popup_y = popup_getoptions(a:id)['line']
endf

fun! s:gutter(lnum)
  return (a:lnum == s:active_line)
        \ ? s:mark_sym
        \ : repeat(' ', strdisplaywidth(s:mark_sym, 0))
endf

fun! s:center(text, width)
  return printf('%s%s%s',
        \ repeat(' ', (a:width + 1 - strwidth(a:text)) / 2),
        \ a:text,
        \ repeat(' ', (a:width  - strwidth(a:text)) / 2))
endf

fun! s:msg(msg, type = 'w')
  if a:type ==# 'e'
    echohl Error
  else
    echohl WarningMsg
  endif
  echomsg '[Colortemplate]' a:msg .. '.'
  echohl None
endf
" }}}
" Highlight groups {{{
let s:hlgroup = '' " Name of the currently displayed highlight group
let s:hlID = -1    " ID of the currently displayed highlight group
let s:tab = 'fg'   " Which color (foreground/background/special) is displayed

" There are three colors for each highlight group (a 'color set'):
"
" - foreground
" - background
" - special
"
" Each color is a dictionary with the following keys:
" - gui: the GUI hex value of the color
" - index: the best cterm approximation for the color (16-255)
" - approx: the hex value of the cterm approximation
" - delta: the difference between the GUI and the cterm color
" - guess: a flag indicating whether the color is a guess (1) or not (0)
" - edited: flag indicating if the color has been edited in the style picker
let s:colorset = #{ fg: {}, bg: {}, sp: {} }

" The attributes of the current highlight group
let s:attrs = #{
      \ bold:          0,
      \ italic:        0,
      \ inverse:       0,
      \ standout:      0,
      \ underline:     0,
      \ undercurl:     0,
      \ strikethrough: 0,
      \ }

" Stars assigned to fg/bg or sp/bg color pairs.
" Each dictionary has two keys, gui and cterm.
let s:stars = #{ fg: {}, bg: {}, sp: {} }

" Assigns up to five stars to a pair of colors according to how many criteria
" the pair satifies. Thresholds follow W3C guidelines.
fun! s:__compute_stars__(c1, c2)
  let l:cr = colortemplate#colorspace#contrast_ratio(a:c1, a:c2)
  let l:cd = colortemplate#colorspace#color_difference(a:c1, a:c2)
  let l:bd = colortemplate#colorspace#brightness_diff(a:c1, a:c2)
  return repeat(s:star_sym, (l:cr >= 3.0) + (l:cr >= 4.5) + (l:cr >= 7.0) + (l:cd >= 500) + (l:bd >= 125))
endf

fun! s:__update_stars__(tab = s:tab)
  let l:tab = (a:tab ==# 'bg' ? 'fg' : a:tab)
  " Compute stars (GUI)
  let s:stars[a:tab].gui = s:__compute_stars__(s:colorset[l:tab].gui, s:colorset.bg.gui)
  " Compute stars (cterm)
  let s:stars[a:tab].cterm = s:__compute_stars__(s:colorset[l:tab].approx, s:colorset.bg.approx)
endf

" Applies the current color to the color scheme.
if s:mode ==# 'gui'
  fun! s:apply_color()
    execute printf('hi %s gui%s=%s', s:hlgroup, s:tab, s:colorset[s:tab].gui)
  endf

  fun! s:update_curr_text_property()
    execute printf('hi colortemplatePopupGCol guibg=%s', s:colorset[s:tab].gui)
    execute printf('hi colortemplatePopupTCol guibg=%s', s:colorset[s:tab].approx)
    call prop_type_change('_curr', #{ bufnr: s:popup_bufnr, highlight: s:hlgroup })
  endf
else
  fun! s:apply_color()
    execute printf('hi %s cterm%s=%s', s:hlgroup, (s:tab ==# 'sp' ? 'ul' : s:tab), s:colorset[s:tab].index)
  endf

  fun! s:update_curr_text_property()
    execute printf('hi colortemplatePopupTCol ctermbg=%s', s:colorset[s:tab].index)
    call prop_type_change('_curr', #{ bufnr: s:popup_bufnr, highlight: s:hlgroup })
  endf
endif

" Sets the internal state to the specified color.
fun! s:__setc__(hexvalue, tab, is_guess)
  let s:colorset[a:tab].gui   = a:hexvalue
  let s:colorset[a:tab].guess = a:is_guess
  call extend(s:colorset[a:tab], colortemplate#colorspace#approx(a:hexvalue))
endf

" Sets the current tab of the style picker to a new, un-edited, color.
"
" hexvalue: a hex color
" guess:    is the color a guess (1) or not (0)?
fun! s:set_color(hexvalue, guess = 0)
  call s:__setc__(a:hexvalue, s:tab, a:guess)
  let s:colorset[s:tab].edited = 0
  call s:__update_stars__(s:tab)
  call s:update_curr_text_property()
  call s:apply_color()
endf

" As above, but using an xterm color as input (16-255).
fun! s:set_cterm_color(num, guess = 0)
  call s:__setc__(colortemplate#colorspace#xterm256_hexvalue(a:num), s:tab, a:guess)
  let s:colorset[s:tab].edited = 0
  call s:__update_stars__(s:tab)
  call s:update_curr_text_property()
  call s:apply_color()
endf

" Modifies the current color (e.g., using a slider), marking it as 'edited'.
fun! s:change_color(hexvalue)
  call s:__setc__(a:hexvalue, s:tab, 0)
  let s:colorset[s:tab].edited = 1
  call s:__update_stars__(s:tab)
  call s:update_curr_text_property()
  call s:apply_color()
endf

fun! s:__read_color_from_hlgroup__(tab)
    let l:col = colortemplate#syn#higroup2hex(s:hlgroup, a:tab)
    call s:__setc__(l:col.hex, a:tab, l:col.guess)
    let s:colorset[a:tab].edited = 0
endf

" Sets the internal state to match the specified highlight group.
fun! s:set_hlgroup(name)
  let s:hlgroup = empty(a:name) ? 'Normal' : a:name
  let s:hlID = hlID(s:hlgroup)
  call s:__read_color_from_hlgroup__('fg')
  call s:__read_color_from_hlgroup__('bg')
  call s:__read_color_from_hlgroup__('sp')
  let s:attrs = #{
        \ bold:          synIDattr(s:hlID, 'bold',      s:attrmode) ==# '1' ? 1 : 0,
        \ italic:        synIDattr(s:hlID, 'italic',    s:attrmode) ==# '1' ? 1 : 0,
        \ inverse:       synIDattr(s:hlID, 'reverse',   s:attrmode) ==# '1' ? 1 : 0,
        \ standout:      synIDattr(s:hlID, 'standout',  s:attrmode) ==# '1' ? 1 : 0,
        \ underline:     synIDattr(s:hlID, 'underline', s:attrmode) ==# '1' ? 1 : 0,
        \ undercurl:     synIDattr(s:hlID, 'undercurl', s:attrmode) ==# '1' ? 1 : 0,
        \ strikethrough: synIDattr(s:hlID, 'strike',    s:attrmode) ==# '1' ? 1 : 0
        \ }
  call s:__update_stars__('fg')
  call s:__update_stars__('sp')
  let s:stars.bg = s:stars.fg
  call s:update_curr_text_property()
endf

fun! s:set_attr_state(attrname)
  let s:attrs[a:attrname] = synIDattr(s:hlID, a:attrname, s:attrmode) ==# '1' ? 1 : 0
endf
" }}}
" HSB values {{{
" - h: the hue value of the color
" - s: the saturation value of the color
" - v/b: the brightness value of the color
"
" Note: HSV values must be stored, because RGB -> HSV and HSV -> RGB are not
" inverse to each other. For instance, HSV(1,1,1) -> RGB(3,3,3), but when
" converting back, RGB(3,3,3) -> HSV(0,0,1). We don't want the sliders to
" appear to jump around randomly.
let s:hsv_h = -1
let s:hsv_s = -1
let s:hsv_v = -1

fun! s:set_hsb_color()
  let [s:hsv_h, s:hsv_s, s:hsv_v] = colortemplate#colorspace#hex2hsv(s:colorset[s:tab].gui)
endf
" }}}
" Notification popup {{{
fun! s:notification(msg, duration = 2000)
  if get(g:, 'colortemplate_popup_notifications', 1)
    call popup_notification(s:center(a:msg, s:width), #{
          \ pos: 'topleft',
          \ line: popup_getoptions(s:popup_winid)['line'],
          \ col: popup_getoptions(s:popup_winid)['col'],
          \ highlight: 'Normal',
          \ time: a:duration,
          \ moved: 'any',
          \ mousemoved: 'any',
          \ minwidth: s:width,
          \ maxwidth: s:width,
          \ borderchars: get(g:, 'colortemplate_popup_borderchars', ['─', '│', '─', '│', '┌', '┐', '┘', '└']),
          \})
  endif
endf
" }}}
" Sliders {{{
fun! s:init_slider_symbols()
  let l:defaults = get(g:, 'colortemplate_slider_ascii', 0)
      \ ? [" ", ".", ":", "!", "|", "/", "-", "=", "#"]
      \ : [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", '█']
  let s:slider_symbols =  get(g:, 'colortemplate_slider_symbols', l:defaults)
  if len(s:slider_symbols) != 9
    call s:msg('g:colortemplate_slider_symbols must be a List with 9 elements')
    let s:slider_symbols = l:defaults
  endif
endf

" Builds a level bar (for simplicity called a "slider") with a specified
" value.
"
" name: The label for the level bar
" value: the value of the level bar (0–255)
" width: the maximum width of the bar
"
" NOTE: to be rendered correctly, ambiwidth must be set to 'single'.
fun! s:slider(name, value, max = 256, width = 32)
  let l:whole = a:value * a:width / a:max
  let l:frac = a:value * a:width / (1.0 * a:max) - l:whole
  let l:bar = repeat(s:slider_symbols[8], l:whole)
  let l:part_char = s:slider_symbols[1 + float2nr(floor(l:frac * 8))]
  return printf("%s %3d %s%s", a:name, a:value, l:bar, l:part_char)
endf
" }}}
" Text properties {{{
fun! s:reset_common_highlight()
  let l:warncol = synIDattr(synIDtrans(hlID('WarningMsg')), 'fg', s:mode)
  execute printf("hi colortemplatePopupWarn %sfg=%s cterm=bold gui=bold", s:mode, l:warncol)
  hi clear colortemplatePopupGCol
  hi clear colortemplatePopupTCol
endf

fun! s:add_common_prop_types()
  " Property for Normal text
  call prop_type_add('_norm', #{ bufnr: s:popup_bufnr, highlight: 'Normal' })
  " Property for 'disabled' stuff
  call prop_type_add('_off_', #{ bufnr: s:popup_bufnr, highlight: 'Comment' })
  " Mark line as an item that can be selected
  call prop_type_add('_item', #{ bufnr: s:popup_bufnr })
  " Mark line as a label
  call prop_type_add('_labe', #{ bufnr: s:popup_bufnr, highlight: 'Label' })
  " Mark line as a level bar (slider)
  call prop_type_add('_leve', #{ bufnr: s:popup_bufnr })
  " Mark line as a 'recent colors' line
  call prop_type_add('_mru_', #{ bufnr: s:popup_bufnr })
  " Mark line as a 'favorite colors' line
  call prop_type_add('_favl', #{ bufnr: s:popup_bufnr })
  " To highlight text with the currently selected highglight group
  call prop_type_add('_curr', #{ bufnr: s:popup_bufnr })
  " Highlight for warning symbols
  call prop_type_add('_warn', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupWarn'})
endf

" Defines a new generic text line with properties.
"
" t: a String
" props: an Array of text properties, as in popup_settext().
"
" Returns a Dictionary.
fun! s:prop(t, props)
  return #{ text: a:t, props: a:props }
endf

fun! s:prop_item(t, props = [])
  return #{ text: a:t, props: extend([#{ col: 1, length: 0, type: '_item' }], a:props) }
endf

fun! s:blank()
  return s:prop('', [])
endf

fun! s:noprop(t)
  return s:prop(a:t, [])
endfunc

fun! s:prop_level_bar(t, id, props = [])
  return s:prop_item(a:t, extend([#{ col: 1, length: 0, type: '_leve', id: a:id }], a:props))
endf

fun! s:prop_label(t)
  return s:prop(a:t, [#{ col: 1, length: s:width, type: '_labe' }])
endf

fun! s:prop_current(t)
  return s:prop(a:t, [#{ col: 1, length: s:width, type: '_curr' }])
endf

" Returns the list of the names of the text properties for the active line
fun! s:get_props()
  return map(prop_list(s:active_line, #{ bufnr: s:popup_bufnr }), { i,v -> v.type })
endf

" Returns the id of the property of the specified type in the active line.
" NOTE: the property must exist!
fun! s:get_prop_id(type)
  return prop_find(#{ bufnr: s:popup_bufnr, lnum: s:active_line, col: 1, type: a:type })['id']
endf

fun! s:select_first_item(linenr)
  let l:next = prop_find(#{bufnr: s:popup_bufnr, type: '_item', lnum: 1, col: 1}, 'f')
  return empty(l:next) ? a:linenr : l:next.lnum
endf

fun! s:select_last_item(linenr)
  let l:prev = prop_find(#{bufnr: s:popup_bufnr, type: '_item', lnum: line('$', s:popup_winid), col: 1}, 'b')
  return empty(l:prev) ? a:linenr : l:prev.lnum
endf

" Returns the next line after linenr, which has an 'item' property.
" It wraps at the last item.
fun! s:find_next_item(linenr)
  let l:next = prop_find(#{bufnr: s:popup_bufnr, type: '_item', lnum: a:linenr, col: 1, skipstart: 1}, 'f')
  return empty(l:next) ? s:select_first_item(a:linenr) : l:next.lnum
endf

" Returns the previous line before linenr, which has an 'item' property.
" It wraps at the first item.
fun! s:find_prev_item(linenr)
  let l:prev = prop_find(#{bufnr: s:popup_bufnr, type: '_item', lnum: a:linenr, col: 0}, 'b')
  return empty(l:prev) ? s:select_last_item(a:linenr) : l:prev.lnum
endf
" }}}
" Title section {{{
fun! s:add_title_section_prop_types()
  call prop_type_add('_titl', #{bufnr: s:popup_bufnr, highlight: 'Title'})
endf

fun! s:title_section(pane) " -> List of Dictionaries
  let l:n = (a:pane ==# 'R' ? 1 : a:pane==# 'H' ? 2 : a:pane ==# 'G' ? 3 : 4)
  let l:ct = (s:tab ==# 'fg' ? 'Fg' : (s:tab ==# 'bg' ? 'Bg' : 'Sp'))
  let l:title = (l:n == 4 ? 'Keyboard Controls' : printf('%s [%s]', s:hlgroup[0:s:width-12], l:ct))
  return [
        \ s:prop(
        \   printf('%s%s%s', l:title, repeat(' ', s:width - strchars(l:title) - 4), 'RHG?'),
        \   [#{ col: 1, length: s:width, type: '_titl' }, #{ col: 38 + l:n, length: 1, type: '_labe' }],
        \ ),
        \]
endf
" }}}
" Info section {{{
fun! s:reset_info_section_highlight()
  let l:labecol = synIDattr(synIDtrans(hlID('Label')), 'fg', s:mode)
  execute printf("hi colortemplatePopupBold %sfg=%s cterm=bold gui=bold", s:mode, l:labecol)
  execute printf("hi colortemplatePopupItal %sfg=%s cterm=italic gui=italic", s:mode, l:labecol)
  execute printf("hi colortemplatePopupULin %sfg=%s cterm=underline gui=underline", s:mode, l:labecol)
  execute printf("hi colortemplatePopupCurl %sfg=%s cterm=inverse gui=inverse", s:mode, l:labecol)
  execute printf("hi colortemplatePopupSOut %sfg=%s cterm=standout gui=standout", s:mode, l:labecol)
  execute printf("hi colortemplatePopupInvr %sfg=%s cterm=inverse gui=inverse", s:mode, l:labecol)
  execute printf("hi colortemplatePopupStrk %sfg=%s cterm=inverse gui=inverse", s:mode, l:labecol)
endf

fun! s:add_info_section_prop_types()
  " Highglight for the current GUI color
  call prop_type_add('_gcol', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupGCol'})
  " Highlight for the current cterm color
  call prop_type_add('_tcol', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupTCol'})
  " Highlight for attributes
  call prop_type_add('_bold', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupBold'})
  call prop_type_add('_ital', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupItal'})
  call prop_type_add('_ulin', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupULin'})
  call prop_type_add('_curl', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupCurl'})
  call prop_type_add('_sout', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupSOut'})
  call prop_type_add('_invr', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupInvr'})
  call prop_type_add('_strk', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupStrk'})
endf

fun! s:info_section(text) " -> List of Dictionaries
  let l:col = s:colorset[s:tab]
  let l:warn = l:col.guess
  let l:excl = (l:warn ? '!' : ' ')

  return extend(a:text, [
        \ s:blank(),
        \ s:prop(printf('   %s%s%-5s    %3d%s%-5s Δ%.'..(l:col.delta>=10.0?'f  ':'1f ')..'BIUSV~-',
        \          l:col.gui, l:excl, s:stars[s:tab].gui, l:col.index, l:excl, s:stars[s:tab].cterm, l:col.delta),
        \        [
        \         #{ col:  1, length: 2, type: '_labe'                                        },
        \         #{ col:  1, length: 2, type: (s:mode ==# 'gui'         ? '_gcol' : '_off_') },
        \         #{ col:  4, length: 8, type: (l:warn                   ? '_warn' : '_norm') },
        \         #{ col: 18, length: 2, type: '_tcol'                                        },
        \         #{ col: 21, length: 4, type: (l:warn                   ? '_warn' : '_norm') },
        \         #{ col: 37, length: 1, type: (s:attrs.bold             ? '_bold' : '_off_') },
        \         #{ col: 38, length: 1, type: (s:attrs.italic           ? '_ital' : '_off_') },
        \         #{ col: 39, length: 1, type: (s:attrs.underline        ? '_ulin' : '_off_') },
        \         #{ col: 40, length: 1, type: (s:attrs.standout         ? '_sout' : '_off_') },
        \         #{ col: 41, length: 1, type: (s:attrs.inverse          ? '_invr' : '_off_') },
        \         #{ col: 42, length: 1, type: (s:attrs.undercurl        ? '_curl' : '_off_') },
        \         #{ col: 43, length: 1, type: (s:attrs.strikethrough    ? '_strk' : '_off_') },
        \        ]),
        \ s:blank(),
        \ s:prop(s:center(s:sample_text, s:width),
        \       [#{ col: 1 + (s:width + 1 - strwidth(s:sample_text)) / 2, length: len(s:sample_text), type: '_curr' }]),
        \])
endf
" }}}
" Recent colors section {{{
const s:recent_capacity = 10 " Number of colors to remember
let s:recent_colors  = [] " List of hex color values

fun! colortemplate#style#recent()
  return s:recent_colors
endf

if s:mode ==# 'gui'
  fun! s:reset_recent_section_highlight()
    for l:i in range(len(s:recent_colors))
      execute printf('hi colortemplatePopupMRU%d guibg=%s', l:i, s:recent_colors[l:i])
    endfor
  endf
else
  fun! s:reset_recent_section_highlight()
    for l:i in range(len(s:recent_colors))
      execute printf('hi colortemplatePopupMRU%d ctermbg=%s', l:i,
            \ colortemplate#colorspace#approx(s:recent_colors[l:i])['index'])
    endfor
  endf
endif

fun! s:add_recent_section_prop_types()
  for l:i in range(len(s:recent_colors))
    call prop_type_add('_mru' .. l:i, #{ bufnr: s:popup_bufnr, highlight: 'colortemplatePopupMRU' .. l:i})
  endfor
endf

if s:mode ==# 'gui'
  fun! s:update_recent_text_properties()
    let l:i = len(s:recent_colors) - 1
    execute printf('hi colortemplatePopupMRU%d guibg=%s', l:i, s:colorset[s:tab].gui)
    call prop_type_delete('_mru' .. l:i, #{ bufnr: s:popup_bufnr })
    call prop_type_add('_mru' .. l:i, #{ bufnr: s:popup_bufnr, highlight: 'colortemplatePopupMRU' .. l:i })
  endf
else
  fun! s:update_recent_text_properties()
    let l:i = len(s:recent_colors) - 1
    execute printf('hi colortemplatePopupMRU%d ctermbg=%s', l:i,
          \ colortemplate#colorspace#approx(s:colorset[s:tab].gui)['index'])
    call prop_type_delete('_mru' .. l:i, #{ bufnr: s:popup_bufnr })
    call prop_type_add('_mru' .. l:i, #{ bufnr: s:popup_bufnr, highlight: 'colortemplatePopupMRU' .. l:i })
  endf
endif

" Adds the current color to the list of recent colors
fun! s:save_to_recent()
  let l:col = s:colorset[s:tab].gui
  if index(s:recent_colors, l:col) != -1
    return
  endif
  call add(s:recent_colors, l:col)
  if len(s:recent_colors) > s:recent_capacity
    call remove(s:recent_colors, 0)
    call s:reset_recent_section_highlight()
    return
  endif
  call s:update_recent_text_properties()
endf

fun! s:remove_from_recent(n)
  if a:n >= 0 && a:n < len(s:recent_colors)
    call remove(s:recent_colors, a:n)
    call s:reset_recent_section_highlight()
  endif
endf

fun! s:recent_section(text) " -> List of Dictionaries
  let l:props = [#{ col: 1, length: 0, type: '_mru_' }]
  let l:lnum = len(a:text) + 4
  let l:gutter = s:gutter(l:lnum)
  for l:i in range(len(s:recent_colors))
    call add(l:props, #{ col: 1 + len(l:gutter) + 4 * l:i, length: 3, type: '_mru'.. l:i })
  endfor

  return extend(a:text, [
        \ s:blank(),
        \ s:prop_label('Recent colors'),
        \ s:prop_label(repeat(' ', s:gutter_width + 1) .. join(range(len(s:recent_colors)), '   ')),
        \ (empty(s:recent_colors) ? s:blank() : s:prop_item(l:gutter .. repeat(' ', s:width - s:gutter_width), l:props)),
        \])
endf
" }}}
" Favorites section {{{
const s:fav_capacity = 10  " Number of favorite colors per line
let s:favorite_colors = [] " List of favorite colors
let s:fav_loaded = 0       " Have favorite colors been loaded from disk?

fun! colortemplate#style#favorite()
  return s:favorite_colors
endf

fun! colortemplate#style#force_reload_favorite()
  let s:fav_loaded = 0
  call s:load_favorite_colors()
endf

fun! s:save_favorite_colors()
  let l:favpath = fnamemodify(expand(get(g:, 'colortemplate_popup_fav_path',
        \ "$HOME/.vim/colortemplate_favorites.txt")), ":p")
  try " May raise an error, e.g., if a temporary file cannot be written
    if writefile(s:favorite_colors, l:favpath, "s") < 0
      call s:msg('Failed to write ' .. l:favpath, 'e')
    endif
  catch /.*/
    call s:msg('Could not persist favorite colors: ' .. v:exception)
  endtry
endf

" Fills the list of favorite colors from persisted values.
fun! s:load_favorite_colors()
  if s:fav_loaded
    return
  endif
  let l:favpath = fnamemodify(expand(get(g:, 'colortemplate_popup_fav_path',
        \ "$HOME/.vim/colortemplate_favorites.txt")), ":p")
  if !filereadable(l:favpath)
    let s:favorite_colors = []
    return
  endif
  try
    let s:favorite_colors = readfile(l:favpath)
  catch /.*/
    call s:msg('Could not load favorite colors: ' .. v:exception, 'e')
    let s:favorite_colors = []
    return
  endtry
  call map(s:favorite_colors, 'trim(v:val)')
  call filter(s:favorite_colors, { i,v -> v =~ '\m^#[A-Fa-f0-9]\{6}$' })
  let s:fav_loaded = 1
endf

if s:mode ==# 'gui'
  fun! s:reset_favorite_section_highlight()
    for l:i in range(len(s:favorite_colors))
      execute printf('hi colortemplatePopupFav%d guibg=%s', l:i, s:favorite_colors[l:i])
    endfor
  endf
else
  fun! s:reset_favorite_section_highlight()
    for l:i in range(len(s:favorite_colors))
      execute printf('hi colortemplatePopupFav%d ctermbg=%s', l:i,
            \ colortemplate#colorspace#approx(s:favorite_colors[l:i])['index'])
    endfor
  endf
endif

fun! s:add_favorite_section_prop_types()
  for l:i in range(len(s:favorite_colors))
    call prop_type_add('_fav' .. l:i, #{ bufnr: s:popup_bufnr, highlight: 'colortemplatePopupFav' .. l:i })
  endfor
endf

if s:mode ==# 'gui'
  fun! s:update_favorite_text_properties()
    let l:i = len(s:favorite_colors) - 1
    execute printf('hi colortemplatePopupFav%d guibg=%s', l:i, s:favorite_colors[l:i])
    call prop_type_delete('_fav' .. l:i, #{ bufnr: s:popup_bufnr })
    call prop_type_add('_fav' .. l:i, #{ bufnr: s:popup_bufnr, highlight: 'colortemplatePopupFav' .. l:i })
  endf
else
  fun! s:update_favorite_text_properties()
    let l:i = len(s:favorite_colors) - 1
    execute printf('hi colortemplatePopupFav%d ctermbg=%s', l:i,
          \ colortemplate#colorspace#approx(s:favorite_colors[l:i])['index'])
    call prop_type_delete('_fav' .. l:i, #{ bufnr: s:popup_bufnr })
    call prop_type_add('_fav' .. l:i, #{ bufnr: s:popup_bufnr, highlight: 'colortemplatePopupFav' .. l:i })
  endf
endif

fun! s:save_to_favorite(col)
  if index(s:favorite_colors, a:col) != -1
    return
  endif
  " Add and save to disk
  call add(s:favorite_colors, a:col)
  call s:save_favorite_colors()
  call s:update_favorite_text_properties()
endf

" Remove item i from line lnum of the favorite section.
fun! s:remove_from_favorite(lnum, n)
  let l:i = a:lnum * s:fav_capacity + a:n
  if l:i >= 0 && l:i < len(s:favorite_colors)
    call remove(s:favorite_colors, l:i)
    call s:save_favorite_colors()
    call s:reset_favorite_section_highlight()
  endif
endf

" Returns the i-th line of favorite colors.
fun! s:favorite_line(i)
  return s:favorite_colors[(a:i * s:fav_capacity):(a:i * s:fav_capacity + s:fav_capacity - 1)]
endf

fun! s:favorite_section(text) " -> List of Dictionaries
  if len(s:favorite_colors) == 0
    return a:text
  endif

  let l:fav_section = extend(a:text, [s:blank(), s:prop_label('Favorite colors')])
  let l:lnum = len(a:text) + 2
  let l:i = 0

  while l:i < len(s:favorite_colors)
    let l:gutter = s:gutter(l:lnum)
    let l:props = [#{ col: 1, length: 0, type: '_favl', id: (l:i / s:fav_capacity) }]
    let l:colors = s:favorite_line(l:i / s:fav_capacity)

    for l:j in range(len(l:colors))
      call add(l:props, #{ col: 1 + len(l:gutter) + 4 * l:j, length: 3, type: '_fav'.. (l:i + l:j) })
    endfor

    call extend(l:fav_section, [
          \ s:prop_label(repeat(' ', s:gutter_width + 1) .. join(range(len(l:colors)), '   ')),
          \ s:prop_item(l:gutter .. repeat(' ', s:width), l:props),
          \ ])

    let l:lnum += 2
    let l:i += s:fav_capacity
  endwhile

  return l:fav_section
endf
" }}}
" RGB pane {{{
fun! s:rgb_increase_level(value)
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:colorset[s:tab].gui)
  let l:id = s:get_prop_id('_leve')
  if l:id == 1
    if l:r == 255 | return | endif
    let l:r += a:value
    if l:r > 255 | let l:r = 255 | endif
  elseif l:id == 2
    if l:g == 255 | return | endif
    let l:g += a:value
    if l:g > 255 | let l:g = 255 | endif
  elseif l:id == 3
    if l:b == 255 | return | endif
    let l:b += a:value
    if l:b > 255 | let l:b = 255 | endif
  endif
if !s:colorset[s:tab].edited
    call s:save_to_recent()
  endif
  call s:change_color(colortemplate#colorspace#rgb2hex(l:r, l:g, l:b))
endf

fun! s:rgb_decrease_level(value)
 let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:colorset[s:tab].gui)
  let l:id = s:get_prop_id('_leve')
  if l:id == 1
    if l:r == 0 | return | endif
    let l:r -= a:value
    if l:r < 0 | let l:r = 0 | endif
  elseif l:id == 2
    if l:g == 0 | return | endif
    let l:g -= a:value
    if l:g < 0 | let l:g = 0 | endif
  elseif l:id == 3
    if l:b == 0 | return | endif
    let l:b -= a:value
    if l:b < 0 | let l:b = 0 | endif
  endif
  if !s:colorset[s:tab].edited
    call s:save_to_recent()
  endif
  call s:change_color(colortemplate#colorspace#rgb2hex(l:r, l:g, l:b))
endf

fun! s:rgb_slider_section(text, r, g, b) " -> List of Dictionaries
  let l:lnum = len(a:text)
  return extend(a:text, [
        \ s:blank(),
        \ s:prop_level_bar(s:gutter(l:lnum + 2) .. s:slider('R', a:r), 1, [#{ col: len(s:gutter(l:lnum + 2)) + 1, length: 1, type: '_labe' }]),
        \ s:prop_level_bar(s:gutter(l:lnum + 3) .. s:slider('G', a:g), 2, [#{ col: len(s:gutter(l:lnum + 3)) + 1, length: 1, type: '_labe' }]),
        \ s:prop_level_bar(s:gutter(l:lnum + 4) .. s:slider('B', a:b), 3, [#{ col: len(s:gutter(l:lnum + 4)) + 1, length: 1, type: '_labe' }]),
        \ s:noprop(printf('%s%02d', repeat(' ', s:gutter_width + 3), s:step)),
        \])
endf

fun! s:redraw_rgb()
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:colorset[s:tab].gui)
  call popup_settext(s:popup_winid,
        \ s:favorite_section(
        \ s:recent_section(
        \ s:info_section(
        \ s:rgb_slider_section(s:title_section('R'), l:r, l:g, l:b)
        \ ))))
endf
" }}}
" HSB pane {{{
fun! s:hsb_increase_level(value)
  let l:id = s:get_prop_id('_leve')
  if l:id == 1
    if s:hsv_h == 359 | return | endif
    let s:hsv_h += a:value
    if s:hsv_h > 359 | let s:hsv_h = 359 | endif
  elseif l:id == 2
    if s:hsv_s == 100 | return | endif
    let s:hsv_s += a:value
    if s:hsv_s > 100 | let s:hsv_s = 100 | endif
  elseif l:id == 3
    if s:hsv_v == 100 | return | endif
    let s:hsv_v += a:value
    if s:hsv_v > 100 | let s:hsv_v = 100 | endif
  endif
  if !s:colorset[s:tab].edited
    call s:save_to_recent()
  endif
  call s:change_color(colortemplate#colorspace#hsv2hex(s:hsv_h, s:hsv_s, s:hsv_v))
endf

fun! s:hsb_decrease_level(value)
  let l:id = s:get_prop_id('_leve')
  if l:id == 1
    if s:hsv_h == 0 | return | endif
    let s:hsv_h -= a:value
    if s:hsv_h < 0 | let s:hsv_h = 0 | endif
  elseif l:id == 2
    if s:hsv_s == 0 | return | endif
    let s:hsv_s -= a:value
    if s:hsv_s < 0 | let s:hsv_s = 0 | endif
  elseif l:id == 3
    if s:hsv_v == 0 | return | endif
    let s:hsv_v -= a:value
    if s:hsv_v < 0 | let s:hsv_v = 0 | endif
  endif
  if !s:colorset[s:tab].edited
    call s:save_to_recent()
  endif
  call s:change_color(colortemplate#colorspace#hsv2hex(s:hsv_h, s:hsv_s, s:hsv_v))
endf

fun! s:hsb_slider_section(text) " -> List of Dictionaries
  let l:lnum = len(a:text)
  return extend(a:text, [
        \ s:blank(),
        \ s:prop_level_bar(s:gutter(l:lnum + 2) .. s:slider('H', s:hsv_h, 359), 1, [#{ col: len(s:gutter(l:lnum + 2)) + 1, length: 1, type: '_labe' }]),
        \ s:prop_level_bar(s:gutter(l:lnum + 3) .. s:slider('S', s:hsv_s, 100), 2, [#{ col: len(s:gutter(l:lnum + 3)) + 1, length: 1, type: '_labe' }]),
        \ s:prop_level_bar(s:gutter(l:lnum + 4) .. s:slider('B', s:hsv_v, 100), 3, [#{ col: len(s:gutter(l:lnum + 4)) + 1, length: 1, type: '_labe' }]),
        \ s:noprop(printf('%s%02d', repeat(' ', s:gutter_width + 3), s:step)),
        \])
endf

fun! s:redraw_hsb()
  call popup_settext(s:popup_winid,
        \ s:favorite_section(
        \ s:recent_section(
        \ s:info_section(
        \ s:hsb_slider_section(s:title_section('H'))
        \ ))))
endf
" }}}
" Grayscale pane {{{
fun! s:reset_grayscale_highlight()
  let l:labcol = synIDattr(synIDtrans(hlID('Label')), 'fg', s:mode)
  let l:warncol = synIDattr(synIDtrans(hlID('WarningMsg')), 'fg', s:mode)
  execute printf("hi! colortemplatePopupG000 guibg=#000000 ctermbg=16")
  execute printf("hi! colortemplatePopupG025 guibg=#404040 ctermbg=238")
  execute printf("hi! colortemplatePopupG050 guibg=#7f7f7f ctermbg=244")
  execute printf("hi! colortemplatePopupG075 guibg=#bfbfbf ctermbg=250")
  execute printf("hi! colortemplatePopupG100 guibg=#ffffff ctermbg=231")
endf

fun! s:add_grayscale_prop_types()
  call prop_type_add('_gray', #{bufnr: s:popup_bufnr})
  call prop_type_add('_g000', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupG000'})
  call prop_type_add('_g025', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupG025'})
  call prop_type_add('_g050', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupG050'})
  call prop_type_add('_g075', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupG075'})
  call prop_type_add('_g100', #{bufnr: s:popup_bufnr, highlight: 'colortemplatePopupG100'})
endf

fun! s:gray_increase(value)
  let l:g = colortemplate#colorspace#hex2gray(s:colorset[s:tab].gui)
  if l:g == 255 | return | endif
  if !s:colorset[s:tab].edited
    call s:save_to_recent()
  endif
  let l:g += a:value
  if l:g > 255 | let l:g = 255 | endif
  call s:change_color(colortemplate#colorspace#rgb2hex(l:g, l:g, l:g))
endf

fun! s:gray_decrease(value)
  let l:g = colortemplate#colorspace#hex2gray(s:colorset[s:tab].gui)
  if l:g == 0 | return | endif
  if !s:colorset[s:tab].edited
    call s:save_to_recent()
  endif
  let l:g -= a:value
  if l:g < 0 | let l:g = 0 | endif
  call s:change_color(colortemplate#colorspace#rgb2hex(l:g, l:g, l:g))
endf

fun! s:gray_slider_section(text, shade) " -> List of Dictionaries
  let l:lnum = len(a:text)
  return extend(a:text, [
        \ s:blank(),
        \ s:prop_label('Grayscale'),
        \ s:prop(repeat(' ', s:width), [
        \ #{ col: s:gutter_width + 6, length: 2, type: '_g000'},
        \ #{ col: s:gutter_width + 14, length: 2, type: '_g025'},
        \ #{ col: s:gutter_width + 22, length: 2, type: '_g050'},
        \ #{ col: s:gutter_width + 30, length: 2, type: '_g075'},
        \ #{ col: s:gutter_width + 38, length: 2, type: '_g100'},
        \ ]),
        \ s:prop_level_bar(s:gutter(l:lnum + 4) .. s:slider(' ', a:shade), 1),
        \ s:noprop(printf('%s%02d', repeat(' ', s:gutter_width + 3), s:step)),
        \])
endf

fun! s:redraw_gray()
  let l:g = colortemplate#colorspace#hex2gray(s:colorset[s:tab].gui)
  call popup_settext(s:popup_winid,
        \ s:favorite_section(
        \ s:recent_section(
        \ s:info_section(
        \ s:gray_slider_section(s:title_section('G'), l:g)
        \ ))))
endf
" }}}
" Help pane {{{
fun! s:redraw_help()
  call popup_settext(s:popup_winid,
        \ extend(s:title_section('?'), [
        \ s:blank(),
        \ s:prop_label('Popup'),
        \ s:noprop('[↑] Move up           [R] RGB'),
        \ s:noprop('[↓] Move down         [H] HSB'),
        \ s:noprop('[T] Go to top         [G] Grayscale'),
        \ s:noprop('[Tab] fg->bg->sp      [x] Close'),
        \ s:noprop('[S-Tab] sp->bg->fg    [X] Close and reset'),
        \ s:noprop('[?] Help pane'),
        \ s:blank(),
        \ s:prop_label('Attributes'),
        \ s:noprop('[B] Toggle boldface   [V] Toggle reverse'),
        \ s:noprop('[I] Toggle italics    [S] Toggle standout'),
        \ s:noprop('[U] Toggle underline  [~] Toggle undercurl'),
        \ s:noprop('[-] Toggle strikethrough'),
        \ s:blank(),
        \ s:prop_label('Color'),
        \ s:noprop('[→] Increment value   [E] New value'),
        \ s:noprop('[←] Decrement value   [N] New hi group'),
        \ s:noprop('[Y] Yank color        [Z] Clear color'),
        \ s:noprop('[P] Paste color       [A] Add to favorites'),
        \ s:blank(),
        \ s:prop_label('Recent & Favorites'),
        \ s:noprop('[Enter] Pick color    [D] Delete color'),
        \ ]))
  call prop_add(1, 42, #{ bufnr: s:popup_bufnr, length: 1, type: '_labe' })
endf
" }}}
" Popup actions {{{
fun! s:action_commit()
  call popup_close(s:popup_winid)
  return 1
endf

fun! s:action_cancel()
  call popup_close(s:popup_winid)
  if exists('g:colors_name') && !empty('g:colors_name')
    execute 'colorscheme' g:colors_name
  endif
  return 1
endf

fun! s:action_yank_recent()
  echo printf('[Colortemplate] Yank color (0-%d)? ', len(s:recent_colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$' && str2nr(l:n) < len(s:recent_colors)
    let @" = s:recent_colors[str2nr(l:n)]
    call s:notification('Color yanked: ' .. @")
  endif
  return 1
endf

fun! s:action_yank_favorite()
  let l:lnum = s:get_prop_id('_favl')
  let l:colors = s:favorite_line(l:lnum)
  echo printf('[Colortemplate] Yank color (0-%d)? ', len(l:colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$' && str2nr(l:n) < len(l:colors)
    let @" = l:colors[str2nr(l:n)]
    call s:notification('Color yanked: ' .. @")
  endif
  return 1
endf

fun! s:action_yank()
  let l:props = s:get_props()
  if index(l:props, '_leve') != - 1
    let @" = s:colorset[s:tab].gui
    call s:save_to_recent()
    call s:redraw()
    call s:notification('Color yanked: ' .. @")
  elseif index(l:props, '_mru_') != -1
    call s:action_yank_recent()
  elseif index(l:props, '_favl') != -1
    call s:action_yank_favorite()
  endif
  return 1
endf

fun! s:action_paste()
  if @" =~# '\m^#\=[A-Fa-f0-9]\{6}$'
    call s:save_to_recent()
    call s:set_color(@"[0] ==# '#' ? @" : '#'..@")
    if s:pane ==# 'hsb'
      call s:set_hsb_color()
    endif
    call s:redraw()
    return 1
  endif
  return 0
endf

fun! s:action_select_next()
  let s:active_line = s:find_next_item(s:active_line)
  call s:redraw()
  return 1
endf

fun! s:action_select_prev()
  let s:active_line = s:find_prev_item(s:active_line)
  call s:redraw()
  return 1
endf

fun! s:action_to_top()
  let s:active_line = s:select_first_item(s:active_line)
  call s:redraw()
  return 1
endf

fun! s:action_fgbgsp_next()
  let s:tab = (s:tab == 'fg' ? 'bg' : (s:tab == 'bg' ? 'sp' : 'fg'))
  call s:update_curr_text_property()
  if s:pane ==# 'hsb'
    call s:set_hsb_color()
  endif
  call s:redraw()
  return 1
endf

fun! s:action_fgbgsp_prev()
  let s:tab = (s:tab == 'bg' ? 'fg' : (s:tab == 'fg' ? 'sp' : 'bg'))
  call s:update_curr_text_property()
  if s:pane ==# 'hsb'
    call s:set_hsb_color()
  endif
  call s:redraw()
  return 1
endf

fun! s:action_add_to_favorite()
  call s:save_to_favorite(s:colorset[s:tab].gui)
  call s:redraw()
  return 1
endf

fun! s:action_pick_recent()
  echo printf('[Colortemplate] Which color (0-%d)? ', len(s:recent_colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$' && str2nr(l:n) < len(s:recent_colors)
    let l:col = s:recent_colors[str2nr(l:n)]
    call s:save_to_recent()
    call s:set_color(l:col)
    if s:pane ==# 'hsb'
      call s:set_hsb_color()
    endif
    call s:redraw()
  endif
  return 1
endf

fun! s:action_pick_favorite()
  let l:lnum = s:get_prop_id('_favl')
  let l:colors = s:favorite_line(l:lnum)
  echo printf('[Colortemplate] Which color (0-%d)? ', len(l:colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$' && str2nr(l:n) < len(l:colors)
    let l:new = l:colors[str2nr(l:n)]
    call s:save_to_recent()
    call s:set_color(l:new)
    if s:pane ==# 'hsb'
      call s:set_hsb_color()
    endif
    call s:redraw()
  endif
  return 1
endf

fun! s:action_pick_color()
  let l:props = s:get_props()
  if index(l:props, '_mru_') != - 1
    return s:action_pick_recent()
  elseif index(l:props, '_favl') != - 1
    return s:action_pick_favorite()
  else
    return 0
  endif
endf

fun! s:action_remove_from_recent()
  echo printf('[Colortemplate] Remove color (0-%d)? ', len(s:recent_colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$'
    call s:remove_from_recent(str2nr(l:n))
    if (empty(s:recent_colors))
      call s:action_select_prev()
    endif
    call s:redraw()
  endif
  return 1
endf

fun! s:action_remove_from_favorite()
  let l:lnum = s:get_prop_id('_favl')
  let l:colors = s:favorite_line(l:lnum)
  echo printf('[Colortemplate] Remove color (0-%d)? ', len(l:colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$'
    call s:remove_from_favorite(l:lnum, str2nr(l:n))
    if (empty(s:favorite_line(l:lnum)))
      call s:action_select_prev()
    endif
    call s:redraw()
  endif
  return 1
endf

fun! s:action_remove_color()
  let l:props = s:get_props()
  if index(l:props, '_mru_') != - 1
    return s:action_remove_from_recent()
  elseif index(l:props, '_favl') != - 1
    return s:action_remove_from_favorite()
  else
    return 0
  endif
endf

fun! s:toggle_attribute(attrname)
  if s:hlgroup == 'Normal'
    call s:notification('You cannot set Normal attributes')
    return 1
  endif
  call colortemplate#syn#toggle_attribute(hlID(s:hlgroup), a:attrname)
  call s:set_attr_state(a:attrname)
  call s:redraw()
  return 1
endf

fun! s:action_toggle_bold()
  return s:toggle_attribute('bold')
endf

fun! s:action_toggle_italic()
  return s:toggle_attribute('italic')
endf

fun! s:action_toggle_underline()
  return s:toggle_attribute('underline')
endf

fun! s:action_toggle_undercurl()
  return s:toggle_attribute('undercurl')
endf

fun! s:action_toggle_standout()
  return s:toggle_attribute('standout')
endf

fun! s:action_toggle_inverse()
  return s:toggle_attribute('inverse')
endf

fun! s:action_toggle_strike()
  return s:toggle_attribute('strikethrough')
endf

fun! s:choose_gui_color()
  let l:col = input('New color: #', '')
  echo "\r"
  if l:col =~# '\m^[0-9a-fa-f]\{1,6}$'
    if len(l:col) <= 3
      let l:col = repeat(l:col, 6 /  len(l:col))
    endif
    if len(l:col) == 6
      call s:save_to_recent()
      call s:set_color('#'..l:col)
      if s:pane ==# 'hsb'
        call s:set_hsb_color()
      endif
      call s:redraw()
    endif
  end
endf

fun! s:choose_cterm_color()
  let l:col = input('New terminal color [16-255]: ', '')
  echo "\r"
  if l:col =~# '\m^[0-9]\{1,3}$' && str2nr(l:col) > 15 && str2nr(l:col) < 256
    call s:save_to_recent()
    call s:set_cterm_color(str2nr(l:col))
    if s:pane ==# 'hsb'
      call s:set_hsb_color()
    endif
    call s:redraw()
  endif
endf

if s:mode ==# 'gui'
  fun! s:action_edit_color()
    call s:choose_gui_color()
    return 1
  endf
else
  fun! s:action_edit_color()
    call s:choose_cterm_color()
    return 1
  endf
endif

fun! s:action_clear_color()
  if s:hlgroup == 'Normal' && s:tab != 'sp'
    call s:notification('You cannot clear Normal ' .. s:tab)
    return 1
  endif
  let l:ct = (s:mode ==# 'cterm' && s:tab ==# 'sp' ? 'ul' : s:tab)
  execute "hi!" s:hlgroup s:mode..l:ct.."=NONE"
  call s:notification('Color cleared')
  call s:save_to_recent()
  call s:set_hlgroup(s:hlgroup)
  if s:pane ==# 'hsb'
    call s:set_hsb_color()
  endif
  call s:redraw()
  return 1
endf

fun! s:action_edit_name()
  let l:name = input('Highlight group: ', '', 'highlight')
  echo "\r"
  if !has('patch-8.1.1456')
    redraw! " see https://github.com/vim/vim/issues/4473
  endif
  if l:name =~# '\m^\w\+$'
    call s:set_hlgroup(l:name)
    if s:pane ==# 'hsb'
      call s:set_hsb_color()
    endif
    call s:redraw()
  endif
  return 1
endf

fun! s:set_pane(p)
  let s:pane = a:p
  call s:redraw()
  " Realign marker if it's not on an item
  if s:active_line > line('$', s:popup_winid) || index(s:get_props(), '_item') == -1
    let s:active_line = s:find_next_item(1)
    call s:redraw()
  endif
  return 1
endf

fun! s:action_switch_to_rgb()
  return s:set_pane('rgb')
endf

fun! s:action_switch_to_hsb()
  let s:colorset[s:tab].edited = 0
  call s:set_hsb_color()
  return s:set_pane('hsb')
endf

fun! s:action_switch_to_grayscale()
  let s:colorset[s:tab].edited = 0
  return s:set_pane('gray')
endf

fun! s:action_switch_to_help()
  return s:set_pane('help')
endf

fun! s:action_to_right()
  let l:props = s:get_props()
  if index(l:props, '_leve') == -1
    return 1
  endif
  if s:pane ==# 'rgb'
    call s:rgb_increase_level(s:step)
    call s:redraw()
  elseif s:pane ==# 'hsb'
    call s:hsb_increase_level(s:step)
    call s:redraw()
  elseif s:pane ==# 'gray'
    call s:gray_increase(s:step)
    call s:redraw()
  endif
  return 1
endf

fun! s:action_to_left()
  let l:props = s:get_props()
  if index(l:props, '_leve') == -1
    return 1
  endif
  if s:pane ==# 'rgb'
    call s:rgb_decrease_level(s:step)
    call s:redraw()
  elseif s:pane ==# 'hsb'
    call s:hsb_decrease_level(s:step)
    call s:redraw()
  elseif s:pane ==# 'gray'
    call s:gray_decrease(s:step)
    call s:redraw()
  endif
  return 1
endf

fun! s:update_hlgroup_when_cursor_moves()
  let l:synid = synIDtrans(synID(line('.'), col('.'), 1))
  if l:synid == s:hlID || (l:synid == 0 && s:hlgroup == 'Normal')
    return
  endif
  if s:colorset[s:tab].edited
    call s:save_to_recent()
  endif
  call s:set_hlgroup(synIDattr(l:synid, 'name'))
  if s:pane ==# 'hsb'
    call s:set_hsb_color()
  endif
  call s:redraw()
endf

fun! s:handle_digit(n)
  let l:props = s:get_props()
  if index(l:props, '_leve') == -1
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
  elseif s:pane ==# 'hsb'
    call s:redraw_hsb()
  elseif s:pane ==# 'gray'
    call s:redraw_gray()
  elseif s:pane ==# 'help'
    call s:redraw_help()
  endif
endf

fun! s:switch_to_pane(pane)
  if a:pane ==# 'rgb'
    call s:action_switch_to_rgb()
  elseif a:pane ==# 'hsb'
    call s:action_switch_to_hsb()
  elseif a:pane ==# 'gray'
    call s:action_switch_to_grayscale()
  else
    call s:action_switch_to_help()
  endif
endf
" }}}
" Keymap {{{
let s:__key__ = extend({
      \ 'close':            "x",
      \ 'cancel':           "X",
      \ 'yank':             "Y",
      \ 'paste':            "P",
      \ 'down':             "\<down>",
      \ 'up':               "\<up>",
      \ 'top':              "T",
      \ 'decrement':        "\<left>",
      \ 'increment':        "\<right>",
      \ 'fg>bg>sp':         "\<tab>",
      \ 'fg<bg<sp':         "\<s-tab>",
      \ 'pick-color':       "\<enter>",
      \ 'remove-color':     "D",
      \ 'toggle-bold':      "B",
      \ 'toggle-italic':    "I",
      \ 'toggle-underline': "U",
      \ 'toggle-standout':  "S",
      \ 'toggle-inverse':   "V",
      \ 'toggle-undercurl': "~",
      \ 'toggle-strike':    "-",
      \ 'new-color':        "E",
      \ 'new-higroup':      "N",
      \ 'clear':            "Z",
      \ 'add-to-fav':       "A",
      \ 'rgb':              "R",
      \ 'hsb':              "H",
      \ 'gray':             "G",
      \ 'help':             "?",
      \ }, get(g:, 'colortemplate_popup_keys', {}), "force")

" TODO: escape
let s:pane_key = printf('\m[%s%s%s%s%s]',
      \ s:__key__['rgb'], s:__key__['hsb'], s:__key__['gray'], s:__key__['close'], s:__key__['cancel'])

let s:keymap = {
      \ s:__key__['close']:            function('s:action_commit'),
      \ s:__key__['cancel']:           function('s:action_cancel'),
      \ s:__key__['yank']:             function('s:action_yank'),
      \ s:__key__['paste']:            function('s:action_paste'),
      \ s:__key__['down']:             function('s:action_select_next'),
      \ s:__key__['up']:               function('s:action_select_prev'),
      \ s:__key__['top']:              function('s:action_to_top'),
      \ s:__key__['decrement']:        function('s:action_to_left'),
      \ s:__key__['increment']:        function('s:action_to_right'),
      \ s:__key__['fg>bg>sp']:         function('s:action_fgbgsp_next'),
      \ s:__key__['fg<bg<sp']:         function('s:action_fgbgsp_prev'),
      \ s:__key__['pick-color']:       function('s:action_pick_color'),
      \ s:__key__['remove-color']:     function('s:action_remove_color'),
      \ s:__key__['toggle-bold']:      function('s:action_toggle_bold'),
      \ s:__key__['toggle-italic']:    function('s:action_toggle_italic'),
      \ s:__key__['toggle-underline']: function('s:action_toggle_underline'),
      \ s:__key__['toggle-standout']:  function('s:action_toggle_standout'),
      \ s:__key__['toggle-inverse']:   function('s:action_toggle_inverse'),
      \ s:__key__['toggle-undercurl']: function('s:action_toggle_undercurl'),
      \ s:__key__['toggle-strike']:    function('s:action_toggle_strike'),
      \ s:__key__['new-color']:        function('s:action_edit_color'),
      \ s:__key__['new-higroup']:      function('s:action_edit_name'),
      \ s:__key__['clear']:            function('s:action_clear_color'),
      \ s:__key__['add-to-fav']:       function('s:action_add_to_favorite'),
      \ s:__key__['rgb']:              function('s:action_switch_to_rgb'),
      \ s:__key__['hsb']:              function('s:action_switch_to_hsb'),
      \ s:__key__['gray']:             function('s:action_switch_to_grayscale'),
      \ s:__key__['help']:             function('s:action_switch_to_help'),
      \ }

fun! colortemplate#style#filter(winid, key)
  if s:pane ==# 'help' && a:key !~# s:pane_key
    return 0
  endif

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
" Initialization {{{
fun! s:reset_highlight()
  call s:reset_common_highlight()
  call s:reset_info_section_highlight()
  call s:reset_recent_section_highlight()
  call s:reset_favorite_section_highlight()
  call s:reset_grayscale_highlight()
endf

fun! s:add_prop_types(bufnr)
  call s:add_common_prop_types()
  call s:add_title_section_prop_types()
  call s:add_info_section_prop_types()
  call s:add_recent_section_prop_types()
  call s:add_favorite_section_prop_types()
  call s:add_grayscale_prop_types()
endf
" }}}
" Public interface {{{
" Callback for when the popup is closed
fun! colortemplate#style#closed(id, result)
  if exists('#colortemplate_popup')
    autocmd! colortemplate_popup
    augroup! colortemplate_popup
  endif
  call s:save_popup_position(a:id)
  let s:popup_winid = -1
endf

" Optional argument is the name of a highlight group
" If no name is used, then the popup updates as the cursor moves.
fun! colortemplate#style#open(...)
  if s:popup_winid > -1 " Already open
    return s:popup_winid
  endif

  let s:mark_sym     = get(g:, 'colortemplate_popup_marker', '❯❯ ')
  let s:width        = max([39 + strdisplaywidth(s:mark_sym), 42])
  let s:gutter_width = strdisplaywidth(s:mark_sym, 0)
  let s:star_sym     = get(g:, 'colortemplate_popup_star', '*')
  let s:sample_text  = s:sample_texts[rand() % len(s:sample_texts)]

  call s:init_slider_symbols()
  call s:load_favorite_colors() " Must be done before resetting the highlight
  call s:reset_highlight()

  augroup colortemplate_popup
    autocmd ColorScheme * call s:reset_highlight()
  augroup END

  let s:popup_winid = popup_create('', #{
        \ border: [1,1,1,1],
        \ borderchars: get(g:, 'colortemplate_popup_borderchars', ['─', '│', '─', '│', '┌', '┐', '┘', '└']),
        \ callback: 'colortemplate#style#closed',
        \ close: 'button',
        \ cursorline: 0,
        \ drag: 1,
        \ filter: 'colortemplate#style#filter',
        \ filtermode: 'n',
        \ highlight: get(g:, 'colortemplate_popup_bg', 'Normal'),
        \ mapping: get(g:, 'colortemplate_popup_mapping', 1),
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
  let s:popup_bufnr = winbufnr(s:popup_winid)
  call setbufvar(s:popup_bufnr, '&tabstop', &tabstop)  " Inherit global tabstop value
  call s:add_prop_types(s:popup_bufnr)

  if empty(a:000) || empty(a:1)
    call s:set_hlgroup(synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name'))
    " Track the cursor
    augroup colortemplate_popup
      autocmd CursorMoved * call s:update_hlgroup_when_cursor_moves()
    augroup END
  else
    call s:set_hlgroup(a:1)
  endif

  let s:active_line = 3
  call s:switch_to_pane(get(g:, 'colortemplate_popup_default_pane', 'rgb'))

  return s:popup_winid
endf

fun! colortemplate#style#popup_id()
  return s:popup_winid
endf
" }}}
