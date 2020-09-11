" Popup state {{{
" Current style
let s:higroup   = ''
let s:color     = #{ fg: {}, bg: {}, sp: {} }
let s:bold      = 0
let s:italic    = 0
let s:inverse   = 0
let s:standout  = 0
let s:underline = 0
let s:undercurl = 0
let s:strike    = 0

" Popup configuration
" Mode for colors
const s:mode = (has('gui_running') || (has('termguicolors') && &termguicolors) ? 'gui': 'cterm')
" Mode for attributes
const s:attrmode = (has('gui_running') || (has('nvim' && has('termguicolors') && &termguicolors))) ? 'gui' : 'cterm'
let s:key = {}                           " Dictionary of key controls (initialized below)
let s:mark = ''                          " Marker for the current line (set when the popup is open)
let s:width = 0                          " Popup width (set when the popup is open)
let s:popup_bg = ''                      " Popup background (initialized below)
let s:star = ''                          " Star for colors (set when the popup is open)
let s:popup_x = 0                        " Horizontal position of the popup (0=center)
let s:popup_y = 0                        " Vertical position of the popup (0=center)
let s:popup_winid = -1                   " Popup window ID
let s:popup_bufnr = -1                   " Popup buffer number
let s:active_line = 1                    " Where the marker is located in the popup
let s:pane = 'rgb'                       " Current pane ('rgb', 'gray', 'hsb')
let s:coltype = 'fg'                     " Currently displayed color ('fg', 'bg', 'sp')
let s:color_edited = #{fg:0, bg:0, sp:0} " Set to 1 when the current color has been modified
let s:step = 1                           " Step for increasing/decreasing levels
let s:step_reset = 1                     " Status of the step counter
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
let s:sample_text = ''
" }}}
" Helper functions {{{
fun! s:set_color(type, hex, is_good = 1)
  let s:color[a:type].hex = a:hex
  let s:color[a:type].good = a:is_good
endf

fun! s:col(type)
  return s:color[a:type].hex
endf

fun! s:fgcol()
  return s:color.fg.hex
endf

fun! s:bgcol()
  return s:color.bg.hex
endf

fun! s:spcol()
  return s:color.sp.hex
endf

fun! s:is_good(type)
  return s:color[a:type].good
endf

fun! s:set_slider_symbols(force_default)
  let l:defaults = get(g:, 'colortemplate_slider_ascii', 0)
      \ ? [" ", ".", ":", "!", "|", "/", "-", "=", "#"]
      \ : [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", '█']
  let s:slider_symbols =  a:force_default
        \ ? l:defaults
        \ : get(g:, 'colortemplate_slider_symbols', l:defaults)
endf

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
  let l:bar = repeat(s:slider_symbols[8], l:whole)
  let l:part_width = float2nr(floor(l:frac * 8))
  let l:part_char = s:slider_symbols[l:part_width]
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
  if s:color_edited[s:coltype]
    call s:add_to_recent(s:col(s:coltype))
  endif
  let s:higroup      = empty(a:name) ? 'Normal' : a:name
  let l:id           = hlID(s:higroup)
  let s:color.fg     = colortemplate#syn#higroup2hex(a:name, 'fg')
  let s:color.bg     = colortemplate#syn#higroup2hex(a:name, 'bg')
  let s:color.sp     = colortemplate#syn#higroup2hex(a:name, 'sp')
  let s:color_edited = #{fg: 0, bg: 0, sp: 0}
  let s:bold         = synIDattr(l:id, 'bold',      s:attrmode) ==# '1' ? 1 : 0
  let s:italic       = synIDattr(l:id, 'italic',    s:attrmode) ==# '1' ? 1 : 0
  let s:inverse      = synIDattr(l:id, 'reverse',   s:attrmode) ==# '1' ? 1 : 0
  let s:standout     = synIDattr(l:id, 'standout',  s:attrmode) ==# '1' ? 1 : 0
  let s:underline    = synIDattr(l:id, 'underline', s:attrmode) ==# '1' ? 1 : 0
  let s:undercurl    = synIDattr(l:id, 'undercurl', s:attrmode) ==# '1' ? 1 : 0
  let s:strike       = synIDattr(l:id, 'strike',    s:attrmode) ==# '1' ? 1 : 0
  return 1
endf

fun! s:init_higroup_under_cursor()
  call s:set_higroup(synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name'))
endf

fun! s:update_higroup_under_cursor()
  let l:group = synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
  return (l:group == s:higroup ? 0 : s:set_higroup(l:group))
endf

fun! s:choose_gui_color()
  let l:col = input('New color: #', '')
  echo "\r"
  if !has('patch-8.1.1456')
    redraw! " see https://github.com/vim/vim/issues/4473
  endif
  if l:col =~# '\m^[0-9a-fa-f]\{1,6}$'
    if len(l:col) <= 3
      let l:col = repeat(l:col, 6 /  len(l:col))
    endif
    if len(l:col) == 6
      call s:add_to_recent(s:col(s:coltype))
      call s:set_color(s:coltype, '#'..l:col)
      call s:apply_color()
      call s:redraw()
    endif
  endif
endf

fun! s:choose_term_color()
  let l:col = input('New terminal color [16-255]: ', '')
  echo "\r"
  if !has('patch-8.1.1456')
    redraw! " see https://github.com/vim/vim/issues/4473
  endif
  if l:col =~# '\m^[0-9]\{1,3}$' && str2nr(l:col) > 15 && str2nr(l:col) < 256
    call s:add_to_recent(s:col(s:coltype))
    call s:set_color(s:coltype, colortemplate#colorspace#xterm256_hexvalue(str2nr(l:col)))
    call s:apply_color()
    call s:redraw()
  endif
endf

fun! s:save_popup_position(id)
  let s:popup_x = popup_getoptions(a:id)['col']
  let s:popup_y = popup_getoptions(a:id)['line']
endf

fun! s:center(text, width)
  return printf('%s%s%s',
        \ repeat(' ', (a:width - len(a:text)) / 2),
        \ a:text,
        \ repeat(' ', (a:width + 1 - len(a:text)) / 2))
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
          \})
  endif
endf
" }}}
" Text properties {{{
fun! s:set_highlight()
  let l:labcol = synIDattr(synIDtrans(hlID('Label')), 'fg', s:mode)
  let l:warncol = synIDattr(synIDtrans(hlID('WarningMsg')), 'fg', s:mode)
  hi! clear ColortemplatePopupGCol
  hi! clear ColortemplatePopupTCol
  execute printf("hi! ColortemplatePopupBold %sfg=%s cterm=bold gui=bold", s:mode, l:labcol)
  execute printf("hi! ColortemplatePopupItal %sfg=%s cterm=italic gui=italic", s:mode, l:labcol)
  execute printf("hi! ColortemplatePopupULin %sfg=%s cterm=underline gui=underline", s:mode, l:labcol)
  execute printf("hi! ColortemplatePopupCurl %sfg=%s cterm=inverse gui=inverse", s:mode, l:labcol)
  execute printf("hi! ColortemplatePopupSOut %sfg=%s cterm=standout gui=standout", s:mode, l:labcol)
  execute printf("hi! ColortemplatePopupInvr %sfg=%s cterm=inverse gui=inverse", s:mode, l:labcol)
  execute printf("hi! ColortemplatePopupStrk %sfg=%s cterm=inverse gui=inverse", s:mode, l:labcol)
  execute printf("hi! ColortemplatePopupWarn %sfg=%s cterm=bold gui=bold", s:mode, l:warncol)
endf

fun! s:add_prop_types()
  " Property for Normal text
  call prop_type_add('_norm', #{bufnr: s:popup_bufnr, highlight: 'Normal'})
  " Title of the pane
  call prop_type_add('_titl', #{bufnr: s:popup_bufnr, highlight: 'Title'})
  " Mark line as an item that can be selected
  call prop_type_add('_item', #{bufnr: s:popup_bufnr})
  " Mark line as a label
  call prop_type_add('_labe', #{bufnr: s:popup_bufnr})
  " Mark line as a level bar (slider)
  call prop_type_add('_leve', #{bufnr: s:popup_bufnr})
  " Mark line as a "recent colors" line
  call prop_type_add('_mru_', #{bufnr: s:popup_bufnr})
  " Mark line as a "favorite colors" line
  call prop_type_add('_fav_', #{bufnr: s:popup_bufnr})
  " To highlight text with the currently selected highglight group
  call prop_type_add('_curr', #{bufnr: s:popup_bufnr, highlight: s:higroup})
  " Highlight for warning symbol
  call prop_type_add('_warn', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupWarn'})
  " Highglight for the current GUI color
  call prop_type_add('_gcol', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupGCol'})
  " Highlight for the current cterm color
  call prop_type_add('_tcol', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupTCol'})
  " Highlight for attributes
  call prop_type_add('_bold', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupBold'})
  call prop_type_add('_ital', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupItal'})
  call prop_type_add('_ulin', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupULin'})
  call prop_type_add('_curl', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupCurl'})
  call prop_type_add('_sout', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupSOut'})
  call prop_type_add('_invr', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupInvr'})
  call prop_type_add('_strk', #{bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupStrk'})
  call prop_type_add('_off_', #{bufnr: s:popup_bufnr, highlight: 'Comment'})
  " RGB pane
  call prop_type_add('_rgb_', #{bufnr: s:popup_bufnr})
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
        \   props: extend([#{ col: 1, length: 0, type: '_item' }], a:props),
        \}
endf

fun! s:blank()
  return s:prop('', [])
endf

fun! s:noprop(t)
  return s:prop(a:t, [])
endfunc

fun! s:prop_level_bar(t, pane, id)
  return s:prop_item(a:t, [#{ col: 1, length: 0, type: '_leve', id: a:id },
        \                  #{ col: 1, length: 0, type: a:pane }])
endf

fun! s:prop_label(t)
  return s:prop(a:t, [#{ col: 1, length: s:width, type: '_labe' }])
endf

fun! s:prop_indented_label(t)
  return s:prop(repeat(' ', len(s:mark))..a:t, [#{ col: 1, length: s:width, type: '_labe' }])
endf

fun! s:prop_current(t)
  return s:prop(a:t, [#{ col: 1, length: s:width, type: '_curr' }])
endf

" Returns the list of the names of the text properties for the given line
fun! s:get_properties(linenr)
  return map(prop_list(a:linenr, #{bufnr: s:popup_bufnr}), { i,v -> v.type })
endf

" Returns the id of the property of the specified type in the given line.
" NOTE: the property must exist!
fun! s:get_property_id(linenr, type)
  return prop_find(#{bufnr: s:popup_bufnr, lnum: a:linenr, col: 1, type: a:type})['id']
endf

fun! s:has_property(list, prop)
  return index(a:list, a:prop) != - 1
endf

fun! s:select_first_item(linenr)
  let l:next = prop_find(#{bufnr: s:popup_bufnr, type: '_item', lnum: 1, col: 1}, 'f')
  return empty(l:next) ? a:linenr : l:next.lnum
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
  let l:prev = prop_find(#{bufnr: s:popup_bufnr, type: '_item', lnum: a:linenr - 1, col: 1,}, 'b')
  if empty(l:prev)
    let l:prev = prop_find(#{bufnr: s:popup_bufnr, type: '_item', lnum: line('$', s:popup_winid), col: 1}, 'b')
  endif
  return empty(l:prev) ? a:linenr : l:prev.lnum
endf

" }}}
" Title of a pane {{{
fun! s:title_section(pane) " -> List of Dictionaries
  let l:n = (a:pane ==# 'R' ? 1 : a:pane==# 'H' ? 2 : a:pane ==# 'G' ? 3 : 4)
  let l:ct = (s:coltype ==# 'fg' ? 'Fg' : (s:coltype ==# 'bg' ? 'Bg' : 'Sp'))
  let l:title = (l:n == 4 ? 'Keyboard Controls' : printf('%s [%s]', s:higroup[0:s:width-12], l:ct))
  return [
        \ s:prop(
        \   printf('%s%s%s', l:title, repeat(' ', s:width - len(l:title) - 4), 'RHG?'),
        \   [#{ col: 1, length: s:width, type: '_titl' }, #{ col: 38 + l:n, length: 1, type: '_labe' }],
        \ ),
        \]
endf
" }}}
" Info section of a pane {{{
fun! s:info_section() " -> List of Dictionaries
  let l:termcol = {}
  let l:termhex = {}
  let l:fg = (s:coltype ==# 'sp' ? 'sp' : 'fg')
  " Compute stars
  let l:termcol[l:fg]   = colortemplate#colorspace#approx(s:col(l:fg))
  let l:termcol['bg']   = colortemplate#colorspace#approx(s:bgcol())
  let l:termhex[l:fg]   = colortemplate#colorspace#xterm256_hexvalue(l:termcol[l:fg]['index'])
  let l:termhex['bg']   = colortemplate#colorspace#xterm256_hexvalue(l:termcol['bg']['index'])
  let s:term_stars = s:stars(l:termhex[l:fg], l:termhex['bg'])
  let s:gui_stars  = s:stars(s:col(l:fg), s:bgcol())
  if s:mode ==# 'gui'
    execute printf('hi! ColortemplatePopupGCol guibg=%s ctermbg=%d', s:col(s:coltype), l:termcol[s:coltype]['index'])
  endif
  execute printf('hi! ColortemplatePopupTCol guibg=%s ctermbg=%d', l:termhex[s:coltype], l:termcol[s:coltype]['index'])
  call prop_type_change('_curr', #{bufnr: s:popup_bufnr, highlight: s:higroup})
  let l:delta = l:termcol[s:coltype]['delta']
  let l:warn = !s:is_good(s:coltype)
  let l:excl = (l:warn ? '!' : ' ')

  return [
        \ s:blank(),
        \ s:prop(printf('   %s%s%-5s    %3d%s%-5s Δ%.'..(l:delta>=10.0?'f  ':'1f ')..'BIUSV~-',
        \          s:col(s:coltype), l:excl, s:gui_stars, l:termcol[s:coltype]['index'], l:excl, s:term_stars, l:termcol[s:coltype]['delta']),
        \        [
        \         #{ col:  1, length: 2, type: '_labe' },
        \         #{ col:  1, length: 2, type: (s:mode ==# 'gui' ? '_gcol' : '_off_') },
        \         #{ col:  4, length: 8, type: (l:warn ? '_warn' : '_norm') },
        \         #{ col: 18, length: 2, type: '_tcol' },
        \         #{ col: 21, length: 4, type: (l:warn ? '_warn' : '_norm') },
        \         #{ col: 37, length: 1, type: (s:bold      ? '_bold' : '_off_') },
        \         #{ col: 38, length: 1, type: (s:italic    ? '_ital' : '_off_') },
        \         #{ col: 39, length: 1, type: (s:underline ? '_ulin' : '_off_') },
        \         #{ col: 40, length: 1, type: (s:standout  ? '_sout' : '_off_') },
        \         #{ col: 41, length: 1, type: (s:inverse   ? '_invr' : '_off_') },
        \         #{ col: 42, length: 1, type: (s:undercurl ? '_curl' : '_off_') },
        \         #{ col: 43, length: 1, type: (s:strike    ? '_strk' : '_off_') },
        \        ]),
        \ s:blank(),
        \ s:prop(s:sample_text, [#{ col: 1, length: s:width, type: '_curr' }]),
        \]
endf
" }}}
" Recently used colors section {{{
const s:recent_capacity = 10 " Number of colors to remember
let s:recent_colors  = []

fun! s:add_to_recent(color)
  if index(s:recent_colors, a:color) != -1 " Do not add the same color twice
    return
  endif
  " Less efficient but but much simpler to implement than a proper queue
  call insert(s:recent_colors, a:color, 0)
  if len(s:recent_colors) > s:recent_capacity
    call remove(s:recent_colors, -1)
  endif
endf

fun! s:remove_recent()
  echo printf('[Colortemplate] Remove color (0-%d)? ', len(s:recent_colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$' && str2nr(l:n) < len(s:recent_colors)
    call remove(s:recent_colors, str2nr(l:n))
    if (len(s:recent_colors) % s:recent_capacity == 0)
      call s:select_prev_item()
    endif
    call s:redraw()
  endif
  return 1
endf

fun! s:pick_recent()
  echo printf('[Colortemplate] Which color (0-%d)? ', len(s:recent_colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$' && str2nr(l:n) < len(s:recent_colors)
    let l:new = s:recent_colors[str2nr(l:n)]
    call s:add_to_recent(s:col(s:coltype))
    call s:set_color(s:coltype, l:new)
    call s:apply_color()
    call s:redraw()
  endif
  return 1
endf

fun! s:add_mru_prop_types()
  for l:i in range(s:recent_capacity)
    execute 'hi clear ColortemplatePopupMRU' .. i
    call prop_type_add('_mru' .. l:i, #{ bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupMRU' .. l:i})
  endfor
endf

fun! s:recent_section() " -> List of Dictionaries
  if len(s:recent_colors) == 0
    return []
  endif
  let l:props = [#{ col: 1, length: 0, type: '_mru_' }]
  for l:i in range(len(s:recent_colors))
    let l:approx = colortemplate#colorspace#approx(s:recent_colors[l:i])['index']
    execute printf('hi ColortemplatePopupMRU%d guibg=%s ctermbg=%s', l:i, s:recent_colors[l:i], l:approx)
    call add(l:props, #{ col: 1 + len(s:mark) + 4 * l:i, length: 3, type: '_mru'.. l:i })
  endfor

  return [
        \ s:blank(),
        \ s:prop_label('Recent'),
        \ s:prop_item(repeat(' ', s:width), l:props),
        \ s:prop_indented_label(' ' .. join(range(len(s:recent_colors)), '   ')),
        \]
endf
" }}}
" Favorites section {{{
const s:segment_capacity = 10 " Number of colors per line
let s:favorite_colors = []    " List of favorite colors

" Returns n colors, starting at index i.
fun! s:segment(i, n)
  return s:favorite_colors[(a:i):(a:i + a:n - 1)]
endf

fun! s:save_favorite_colors()
  let l:favpath = fnamemodify(expand(get(g:, 'colortemplate_popup_fav_path',
        \ "$HOME/.vim/colortemplate_favorites.txt")), ":p")

  if !filewritable(l:favpath)
   call s:msg(l:favpath .. ' is not writable', 'e')
   return
  endif

  try " May raise an error, e.g., if a temporary file cannot be written
    if writefile(s:favorite_colors, l:favpath, "s") < 0
      call s:msg('Failed to write ' .. l:favpath, 'e')
    endif
  catch /.*/
    call s:msg('Could not persist favorite colors: ' .. v:exception)
  endtry
endf

fun! s:prop_type_add_fav(i, col)
  let l:approx = colortemplate#colorspace#approx(a:col)['index']
  execute printf('hi ColortemplatePopupFav%d guibg=%s ctermbg=%s', a:i, a:col, l:approx)
  call prop_type_delete('_fav' .. a:i, #{bufnr: s:popup_bufnr})
  call prop_type_add('_fav' .. a:i, #{ bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupFav' .. a:i})
endf

fun! s:load_favorite_colors()
  if !empty(s:favorite_colors) " Already loaded
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
  for l:i in range(len(s:favorite_colors))
    call s:prop_type_add_fav(l:i, s:favorite_colors[l:i])
  endfor
endf

fun! s:add_to_favorite()
  " Do not add the same color twice
  let l:col = s:col(s:coltype)
  if index(s:favorite_colors, l:col) != -1
    return
  endif

  " Define a text property for the new element
  let l:i = len(s:favorite_colors)
  call s:prop_type_add_fav(l:i, l:col)

  " Add and save to disk
  call add(s:favorite_colors, l:col)
  call s:save_favorite_colors()
  call s:redraw()
  return 1
endf
"
fun! s:remove_favorite()
  let l:segnum = s:get_property_id(s:active_line, '_fav_')
  let l:colors = s:segment(l:segnum * s:segment_capacity, s:segment_capacity)
  echo printf('[Colortemplate] Remove color (0-%d)? ', len(l:colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$' && str2nr(l:n) < len(l:colors)
    call remove(s:favorite_colors, l:segnum * s:segment_capacity + str2nr(l:n))
    if (len(s:favorite_colors) % s:segment_capacity == 0)
      call s:select_prev_item()
    endif
    call s:save_favorite_colors()
    call s:redraw()
  endif
  return 1
endf
"
fun! s:pick_favorite()
  let l:segnum = s:get_property_id(s:active_line, '_fav_')
  let l:colors = s:segment(l:segnum * s:segment_capacity, s:segment_capacity)
  echo printf('[Colortemplate] Which color (0-%d)? ', len(l:colors) - 1)
  let l:n = nr2char(getchar())
  echo "\r"
  if l:n =~ '\m^\d$' && str2nr(l:n) < len(l:colors)
    let l:new = l:colors[str2nr(l:n)]
    call s:add_to_recent(s:col(s:coltype))
    call s:set_color(s:coltype, l:new)
    call s:apply_color()
    call s:redraw()
  endif
  return 1
endf

fun! s:add_fav_prop_types()
  for l:i in range(len(s:favorite_colors))
    execute 'hi clear ColortemplatePopupFav' .. i
    call prop_type_add('_fav' .. l:i, #{ bufnr: s:popup_bufnr, highlight: 'ColortemplatePopupFav' .. l:i})
  endfo
endf

fun! s:favorites_section() " -> List of Dictionaries
  if len(s:favorite_colors) == 0
    return []
  endif

  let l:fav_section = [s:blank(), s:prop_label('Favorites')]
  let l:i = 0

  while l:i < len(s:favorite_colors)
    let l:props = [#{ col: 1, length: 0, type: '_fav_', id: (l:i / s:segment_capacity) }]
    let l:colors = s:segment(l:i, s:segment_capacity)

    for l:j in range(len(l:colors))
      call s:prop_type_add_fav(l:i + l:j, l:colors[l:j])
      call add(l:props, #{ col: 1 + len(s:mark) + 4 * l:j, length: 3, type: '_fav'.. (l:i + l:j) })
    endfor

    call extend(l:fav_section, [
          \ s:prop_item(repeat(' ', s:width), l:props),
          \ s:prop_indented_label(' ' .. join(range(len(l:colors)), '   ')),
          \ ])

    let l:i += s:segment_capacity
  endwhile

  return l:fav_section
endf
" }}}
" RGB Pane {{{
fun! s:rgb_increase_level(value)
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:col(s:coltype))
  let l:id = s:get_property_id(s:active_line, '_leve')
  if l:id == 1
    let l:r += a:value
    if l:r > 255 | let l:r = 255 | endif
  elseif l:id == 2
    let l:g += a:value
    if l:g > 255 | let l:g = 255 | endif
  elseif l:id == 3
    let l:b += a:value
    if l:b > 255 | let l:b = 255 | endif
  endif
if !s:color_edited[s:coltype]
    call s:add_to_recent(s:col(s:coltype))
    let s:color_edited[s:coltype] = 1
  endif
  call s:set_color(s:coltype, colortemplate#colorspace#rgb2hex(l:r, l:g, l:b))
endf

fun! s:rgb_decrease_level(value)
 let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:col(s:coltype))
  let l:id = s:get_property_id(s:active_line, '_leve')
  if l:id == 1
    let l:r -= a:value
    if l:r < 0 | let l:r = 0 | endif
  elseif l:id == 2
    let l:g -= a:value
    if l:g < 0 | let l:g = 0 | endif
  elseif l:id == 3
    let l:b -= a:value
    if l:b < 0 | let l:b = 0 | endif
  endif
  if !s:color_edited[s:coltype]
    call s:add_to_recent(s:col(s:coltype))
    let s:color_edited[s:coltype] = 1
  endif
  call s:set_color(s:coltype, colortemplate#colorspace#rgb2hex(l:r, l:g, l:b))
endf

fun! s:rgb_slider(r, g, b) " -> List of Dictionaries
  return [
        \ s:blank(),
        \ s:prop_level_bar(s:slider('R', a:r), '_rgb_', 1),
        \ s:prop_level_bar(s:slider('G', a:g), '_rgb_', 2),
        \ s:prop_level_bar(s:slider('B', a:b), '_rgb_', 3),
        \ s:prop_label(printf('%s%02d', repeat(' ', len(s:mark) + 3), s:step)),
        \]
endf

fun! s:redraw_rgb()
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:col(s:coltype))
  call s:init_pane()
  call popup_settext(s:popup_winid,
        \ extend(extend(extend(extend(
        \   s:title_section('R'),
        \   s:rgb_slider(l:r, l:g, l:b)),
        \   s:info_section()),
        \   s:recent_section()),
        \   s:favorites_section())
        \)
endf
" }}}
" HSB Pane {{{
fun! s:redraw_hsb()
  call popup_settext(s:popup_winid,
        \ extend(s:title_section('H'), [
        \ s:blank(),
        \ s:prop_label('Not implemented yet.'),
        \ s:prop_label('Please switch back to R.'),
        \ ]))
  call prop_add(1, 40, #{bufnr: s:popup_bufnr, length: 1, type: '_labe'})
endf
" }}}
" Grayscale Pane {{{
fun! s:redraw_gray()
  call popup_settext(s:popup_winid,
        \ extend(s:title_section('G'), [
        \ s:blank(),
        \ s:prop_label('Not implemented yet.'),
        \ s:prop_label('Please switch back to R.'),
        \ ]))
  call prop_add(1, 41, #{bufnr: s:popup_bufnr, length: 1, type: '_labe'})
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
        \ s:noprop('[P] Paste color                      '),
        \ s:blank(),
        \ s:prop_label('Recent & Favorites'),
        \ s:noprop('[Enter] Pick color    [D] Delete color'),
        \ s:noprop('[A] Add to favorite                   '),
        \ ]))
  call prop_add(1, 42, #{bufnr: s:popup_bufnr, length: 1, type: '_labe'})
endf
" }}}
" Popup actions {{{
fun! s:commit()
  call popup_close(s:popup_winid)
  return 1
endf

fun! s:cancel()
  call popup_close(s:popup_winid)
  if exists('g:colors_name') && !empty('g:colors_name')
    execute 'colorscheme' g:colors_name
  endif
  return 1
endf

fun! s:yank()
  let @"=s:col(s:coltype)
  call s:add_to_recent(s:col(s:coltype))
  call s:redraw()
  call s:notification('Color yanked')
  return 1
endf

fun! s:paste()
  if @" =~# '\m^#\=[A-Fa-f0-9]\{6}$'
    call s:add_to_recent(s:col(s:coltype))
    call s:set_color(s:coltype, @"[0] ==# '#' ? @" : '#'..@")
    call s:apply_color()
    call s:redraw()
    return 1
  endif
  return 0
endf

fun! s:mouse_clicked()
  echo string(s:popup_winid) . ' ' . string(getmousepos())
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

fun! s:go_to_top()
  let s:active_line = s:select_first_item(s:active_line)
  call s:redraw()
  return 1
endf

fun! s:update_higroup()
  if s:update_higroup_under_cursor()
    call s:redraw()
  endif
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

fun! s:pick_color()
  let l:props = s:get_properties(s:active_line)
  if s:has_property(l:props, '_mru_')
    return s:pick_recent()
  elseif s:has_property(l:props, '_fav_')
    return s:pick_favorite()
  else
    return 0
  endif
endf

fun! s:remove_color()
  let l:props = s:get_properties(s:active_line)
  if s:has_property(l:props, '_mru_')
    return s:remove_recent()
  elseif s:has_property(l:props, '_fav_')
    return s:remove_favorite()
  else
    return 0
  endif
endf

fun! s:toggle_attribute(attrname)
  if s:higroup == 'Normal'
    call s:notification('You cannot set Normal attributes')
    return 1
  endif
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
  if s:higroup == 'Normal' && s:coltype != 'sp'
    call s:notification('You cannot clear Normal ' .. s:coltype)
    return 1
  endif
  let l:ct = (s:mode ==# 'cterm' && s:coltype ==# 'sp' ? 'ul' : s:coltype)
  execute "hi!" s:higroup s:mode..l:ct.."=NONE"
  call s:notification('Color cleared')
  call s:add_to_recent(s:col(s:coltype))
  call s:set_higroup(s:higroup)
  call s:redraw()
  return 1
endf

fun! s:edit_name()
  let l:name = input('Highlight group: ', '', 'highlight')
  echo "\r"
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

fun! s:switch_to_hsb()
  return s:set_pane('hsb')
endf

fun! s:switch_to_grayscale()
  return s:set_pane('gray')
endf

fun! s:switch_to_help()
  return s:set_pane('help')
endf

fun! s:notify_change()
  silent doautocmd User ColortemplatePopupChanged
endf

fun! s:apply_color()
  let l:ct = (s:coltype ==# 'sp' && s:mode ==# 'cterm') ? 'ul' : s:coltype
  let l:col = (s:mode ==# 'gui' ? s:col(s:coltype) : colortemplate#colorspace#approx(s:col(s:coltype))['index'])
  execute 'hi!' s:higroup s:mode..l:ct..'='..l:col
endf

fun! s:move_right()
  let l:props = s:get_properties(s:active_line)
  if s:has_property(l:props, '_rgb_')
    call s:rgb_increase_level(s:step)
    call s:apply_color()
    call s:redraw()
  endif
  return 1
endf

fun! s:move_left()
  let l:props = s:get_properties(s:active_line)
  if s:has_property(l:props, '_rgb_')
    call s:rgb_decrease_level(s:step)
    call s:apply_color()
    call s:redraw()
  endif
  return 1
endf

fun! s:handle_digit(n)
  let l:props = s:get_properties(s:active_line)
  if !s:has_property(l:props, '_leve')
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
" }}}
" Keymap {{{
let s:key = extend({
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
      \ s:key['rgb'], s:key['hsb'], s:key['gray'], s:key['close'], s:key['cancel'])

let s:keymap = {
      \ s:key['close']:            function('s:commit'),
      \ s:key['cancel']:           function('s:cancel'),
      \ s:key['yank']:             function('s:yank'),
      \ s:key['paste']:            function('s:paste'),
      \ s:key['down']:             function('s:select_next_item'),
      \ s:key['up']:               function('s:select_prev_item'),
      \ s:key['top']:              function('s:go_to_top'),
      \ s:key['decrement']:        function('s:move_left'),
      \ s:key['increment']:        function('s:move_right'),
      \ s:key['fg>bg>sp']:         function('s:fgbgsp_next'),
      \ s:key['fg<bg<sp']:         function('s:fgbgsp_prev'),
      \ s:key['pick-color']:       function('s:pick_color'),
      \ s:key['remove-color']:     function('s:remove_color'),
      \ s:key['toggle-bold']:      function('s:toggle_bold'),
      \ s:key['toggle-italic']:    function('s:toggle_italic'),
      \ s:key['toggle-underline']: function('s:toggle_underline'),
      \ s:key['toggle-standout']:  function('s:toggle_standout'),
      \ s:key['toggle-inverse']:   function('s:toggle_inverse'),
      \ s:key['toggle-undercurl']: function('s:toggle_undercurl'),
      \ s:key['toggle-strike']:    function('s:toggle_strike'),
      \ s:key['new-color']:        function('s:edit_color'),
      \ s:key['new-higroup']:      function('s:edit_name'),
      \ s:key['clear']:            function('s:clear_color'),
      \ s:key['add-to-fav']:       function('s:add_to_favorite'),
      \ s:key['rgb']:              function('s:switch_to_rgb'),
      \ s:key['hsb']:              function('s:switch_to_hsb'),
      \ s:key['gray']:             function('s:switch_to_grayscale'),
      \ s:key['help']:             function('s:switch_to_help'),
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

  let s:mark    = get(g:, 'colortemplate_popup_marker', '> ')
  let s:width   = max([39 + len(s:mark), 42])
  let s:star    = get(g:, 'colortemplate_popup_star', '*')
  let s:sample_text = s:center(s:sample_texts[rand() % len(s:sample_texts)], s:width)

  call s:set_slider_symbols(0)
  if len(s:slider_symbols) != 9
    call s:msg('g:colortemplate_slider_symbols must be a List with 9 elements')
    call s:set_slider_symbols(1)
  endif

  if empty(a:000) || empty(a:1)
    call s:init_higroup_under_cursor()
    " Track the cursor
    augroup colortemplate_popup
      autocmd CursorMoved * call s:update_higroup()
    augroup END
  else
    call s:set_higroup(a:1)
  endif

  call s:set_highlight()
  augroup colortemplate_popup
    autocmd ColorScheme * call s:set_highlight()
  augroup END

  let s:popup_winid = popup_create('', #{
        \ border: [1,1,1,1],
        \ borderchars: ['-', '|', '-', '|', '┌', '┐', '┘', '└'],
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
  let s:active_line = 3
  call s:add_prop_types()
  call s:add_mru_prop_types()
  call s:add_fav_prop_types()
  call s:load_favorite_colors()
  call s:redraw()
  return s:popup_winid
endf

fun! colortemplate#style#popup_id()
  return s:popup_winid
endf
" }}}
