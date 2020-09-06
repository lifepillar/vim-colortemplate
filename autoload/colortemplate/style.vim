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
let s:key = {}                   " Dictionary of key controls (initialized below)
let s:mark = ''                  " Marker for the current line (set when the popup is open)
let s:width = 0                  " Popup width (set when the popup is open)
let s:star = ''                  " Star for colors (set when the popup is open)
let s:popup_x = 0                " Horizontal position of the popup (0=center)
let s:popup_y = 0                " Vertical position of the popup (0=center)
let s:popup_id = -1              " Popup buffer ID
let s:active_line = 1            " Where the marker is located in the popup
let s:pane = 'rgb'               " Current pane ('rgb', 'gray', 'hsb')
let s:coltype = 'fg'             " Currently displayed color ('fg', 'bg', 'sp')
let s:step = 1                   " Step for increasing/decreasing levels
let s:step_reset = 1             " Status of the step counter
let s:recent  = []               " List of recent colors
let s:favorites = []             " List of favorite colors
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
  let s:higroup     = empty(a:name) ? 'Normal' : a:name
  let l:id          = hlID(s:higroup)
  let s:color.fg    = colortemplate#syn#higroup2hex(a:name, 'fg')
  let s:color.bg    = colortemplate#syn#higroup2hex(a:name, 'bg')
  let s:color.sp    = colortemplate#syn#higroup2hex(a:name, 'sp')
  let s:bold        = synIDattr(l:id, '_bold',      s:attrmode) ==# '1' ? 1 : 0
  let s:italic      = synIDattr(l:id, 'italic',    s:attrmode) ==# '1' ? 1 : 0
  let s:inverse     = synIDattr(l:id, 'reverse',   s:attrmode) ==# '1' ? 1 : 0
  let s:standout    = synIDattr(l:id, 'standout',  s:attrmode) ==# '1' ? 1 : 0
  let s:underline   = synIDattr(l:id, 'underline', s:attrmode) ==# '1' ? 1 : 0
  let s:undercurl   = synIDattr(l:id, 'undercurl', s:attrmode) ==# '1' ? 1 : 0
  let s:strike      = synIDattr(l:id, 'strike',    s:attrmode) ==# '1' ? 1 : 0
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
  if !has('patch-8.1.1456')
    redraw! " see https://github.com/vim/vim/issues/4473
  endif
  if l:col =~# '\m^[0-9a-fa-f]\{1,6}$'
    if len(l:col) <= 3
      let l:col = repeat(l:col, 6 /  len(l:col))
    endif
    if len(l:col) == 6
      call s:set_color(s:coltype, '#'..l:col)
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
  return printf('%s%s', repeat(' ', (a:width - len(a:text)) / 2), a:text)
endf
" }}}
" Notification popup {{{
fun! s:notification(msg, duration = 2000)
  if get(g:, 'colortemplate_popup_notifications', 1)
    call popup_notification(s:center(a:msg, s:width), #{
          \ pos: 'topleft',
          \ line: popup_getoptions(s:popup_id)['line'],
          \ col: popup_getoptions(s:popup_id)['col'],
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

  " FIXME: decorative highlights, to be eliminated:
  hi! ColortemplateC1 guibg=#a62317 ctermbg=124
  hi! ColortemplateC2 guibg=#ff966e ctermbg=209
  hi! ColortemplateC3 guibg=#d5b088 ctermbg=180
  hi! ColortemplateC4 guibg=#0c594e ctermbg=23
  hi! ColortemplateC5 guibg=#ffd393 ctermbg=222
endf

fun! s:add_prop_types()
  " Property for Normal text
  call prop_type_add('_norm', #{bufnr: winbufnr(s:popup_id), highlight: 'Normal'})
  " Title of the pane
  call prop_type_add('_titl', #{bufnr: winbufnr(s:popup_id), highlight: 'Title'})
  " Mark line as an item that can be selected
  call prop_type_add('_item', #{bufnr: winbufnr(s:popup_id), highlight: 'Normal'})
  " Mark line as a label
  call prop_type_add('_labe', #{bufnr: winbufnr(s:popup_id), highlight: 'Label'})
  " Mark line as a level bar (slider)
  call prop_type_add('_leve', #{bufnr: winbufnr(s:popup_id), highlight: 'Normal'})
  " To highlight text with the currently selected highglight group
  call prop_type_add('_curr', #{bufnr: winbufnr(s:popup_id), highlight: s:higroup})
  " Highlight for warning symbol
  call prop_type_add('_warn', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupWarn'})
  " Highglight for the current GUI color
  call prop_type_add('_gcol', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupGCol'})
  " Highlight for the current cterm color
  call prop_type_add('_tcol', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupTCol'})
  " Highlight for attributes
  call prop_type_add('_bold', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupBold'})
  call prop_type_add('_ital', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupItal'})
  call prop_type_add('_ulin', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupULin'})
  call prop_type_add('_curl', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupCurl'})
  call prop_type_add('_sout', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupSOut'})
  call prop_type_add('_invr', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupInvr'})
  call prop_type_add('_strk', #{bufnr: winbufnr(s:popup_id), highlight: 'ColortemplatePopupStrk'})
  call prop_type_add('_off_', #{bufnr: winbufnr(s:popup_id), highlight: 'Comment'})
  " RGB pane
  call prop_type_add('_rgb_', #{bufnr: winbufnr(s:popup_id), highlight: 'Normal'})
  call prop_type_add('_red_', #{bufnr: winbufnr(s:popup_id), highlight: 'Normal'})
  call prop_type_add('_gree', #{bufnr: winbufnr(s:popup_id), highlight: 'Normal'})
  call prop_type_add('_blue', #{bufnr: winbufnr(s:popup_id), highlight: 'Normal'})

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
        \   props: extend([#{ col: 1, length: 0, type: '_item' }], a:props),
        \}
endf

fun! s:blank()
  return s:prop('', [])
endf

fun! s:noprop(t)
  return s:prop(a:t, [])
endfunc

fun! s:prop_level_bar(t, pane, name)
  return s:prop_item(a:t, [#{ col: 1, length: 0, type: '_leve' },
        \                  #{ col: 1, length: 0, type: a:pane },
        \                  #{ col: 1, length: 0, type: a:name }])
endf

fun! s:prop_label(t)
  return s:prop(a:t, [#{ col: 1, length: s:width, type: '_labe' }])
endf

fun! s:prop_current(t)
  return s:prop(a:t, [#{ col: 1, length: s:width, type: '_curr' }])
endf

" Returns the list of the names of the text properties for the given line
fun! s:get_properties(linenr)
  return map(prop_list(a:linenr, #{bufnr: winbufnr(s:popup_id)}), { i,v -> v.type })
endf

fun! s:has_property(list, prop)
  return index(a:list, a:prop) != - 1
endf

fun! s:select_first_item(linenr)
  let l:next = prop_find(#{bufnr: winbufnr(s:popup_id), type: '_item', lnum: 1, col: 1}, 'f')
  return empty(l:next) ? a:linenr : l:next.lnum
endf

" Returns the next line after linenr, which has an 'item' property.
" It wraps at the last item.
fun! s:find_next_item(linenr)
  let l:next = prop_find(#{bufnr: winbufnr(s:popup_id), type: '_item', lnum: a:linenr, col: 1, skipstart: 1}, 'f')
  return empty(l:next) ? s:select_first_item(a:linenr) : l:next.lnum
endf

" Returns the previous line before linenr, which has an 'item' property.
" It wraps at the first item.
fun! s:find_prev_item(linenr)
  let l:prev = prop_find(#{bufnr: winbufnr(s:popup_id), type: '_item', lnum: a:linenr - 1, col: 1,}, 'b')
  if empty(l:prev)
    let l:prev = prop_find(#{bufnr: winbufnr(s:popup_id), type: '_item', lnum: line('$', s:popup_id), col: 1}, 'b')
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
  call prop_type_change('_curr', #{bufnr: winbufnr(s:popup_id), highlight: s:higroup})
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
fun! s:recent_section() " -> List of Dictionaries
  return [
        \ s:blank(),
        \ s:prop_label('Recent'),
        \ s:prop_item('                                   ',
        \               [
        \                 #{col:  4, length: 3, type: 'C1'},
        \                 #{col:  7, length: 3, type: 'C2'},
        \                 #{col: 10, length: 3, type: 'C3'},
        \                 #{col: 13, length: 3, type: 'C4'},
        \                 #{col: 16, length: 3, type: 'C5'},
        \               ]),
        \s:prop_label('    a  b  c  d  e  f  g  h  i  j  k  l  m'),
        \]
endf
" }}}
" Favorites section {{{
fun! s:favorites_section() " -> List of Dictionaries
  return [
        \ s:prop_label('Favorites'),
        \ s:prop_item('                                       ',
        \               [
        \                 #{col:  4, length: 3, type: 'C4'},
        \                 #{col:  7, length: 3, type: 'C1'},
        \                 #{col: 10, length: 3, type: 'C5'},
        \                 #{col: 13, length: 3, type: 'C3'},
        \                 #{col: 16, length: 3, type: 'C2'},
        \                 #{col: 19, length: 3, type: 'C1'},
        \                 #{col: 22, length: 3, type: 'C4'},
        \                 #{col: 25, length: 3, type: 'C2'},
        \                 #{col: 28, length: 3, type: 'C5'},
        \                 #{col: 31, length: 3, type: 'C1'},
        \                 #{col: 34, length: 3, type: 'C4'},
        \                 #{col: 37, length: 3, type: 'C3'},
        \                 #{col: 40, length: 3, type: 'C5'},
        \               ]),
        \ s:prop_label('    a  b  c  d  e  f  g  h  i  j  k  l  m'),
        \ s:prop_item('                                       ',
        \               [
        \                 #{col:  4, length: 3, type: 'C1'},
        \                 #{col:  7, length: 3, type: 'C3'},
        \                 #{col: 10, length: 3, type: 'C2'},
        \                 #{col: 13, length: 3, type: 'C5'},
        \                 #{col: 16, length: 3, type: 'C4'},
        \                 #{col: 19, length: 3, type: 'C1'},
        \                 #{col: 22, length: 3, type: 'C2'},
        \                 #{col: 25, length: 3, type: 'C5'},
        \                 #{col: 28, length: 3, type: 'C3'},
        \                 #{col: 31, length: 3, type: 'C1'},
        \                 #{col: 34, length: 3, type: 'C4'},
        \                 #{col: 37, length: 3, type: 'C5'},
        \                 #{col: 40, length: 3, type: 'C2'},
        \               ]),
        \ s:prop_label('    a  b  c  d  e  f  g  h  i  j  k  l  m'),
        \ s:prop_item('                                       ',
        \               [
        \                 #{col:  4, length: 3, type: 'C4'},
        \                 #{col:  7, length: 3, type: 'C1'},
        \                 #{col: 10, length: 3, type: 'C5'},
        \                 #{col: 13, length: 3, type: 'C3'},
        \                 #{col: 16, length: 3, type: 'C2'},
        \                 #{col: 19, length: 3, type: 'C1'},
        \                 #{col: 22, length: 3, type: 'C4'},
        \                 #{col: 25, length: 3, type: 'C2'},
        \                 #{col: 28, length: 3, type: 'C5'},
        \                 #{col: 31, length: 3, type: 'C1'},
        \                 #{col: 34, length: 3, type: 'C4'},
        \                 #{col: 37, length: 3, type: 'C3'},
        \                 #{col: 40, length: 3, type: 'C5'},
        \               ]),
        \ s:prop_label('    a  b  c  d  e  f  g  h  i  j  k  l  m'),
        \ s:prop_item('                                       ',
        \               [
        \                 #{col:  4, length: 3, type: 'C1'},
        \                 #{col:  7, length: 3, type: 'C3'},
        \                 #{col: 10, length: 3, type: 'C2'},
        \                 #{col: 13, length: 3, type: 'C5'},
        \                 #{col: 16, length: 3, type: 'C4'},
        \                 #{col: 19, length: 3, type: 'C1'},
        \                 #{col: 22, length: 3, type: 'C2'},
        \                 #{col: 25, length: 3, type: 'C5'},
        \                 #{col: 28, length: 3, type: 'C3'},
        \                 #{col: 31, length: 3, type: 'C1'},
        \                 #{col: 34, length: 3, type: 'C4'},
        \                 #{col: 37, length: 3, type: 'C5'},
        \                 #{col: 40, length: 3, type: 'C2'},
        \               ]),
        \ s:prop_label('    a  b  c  d  e  f  g  h  i  j  k  l  m'),
        \]
endf
" }}}
" RGB Pane {{{
fun! s:rgb_increase_level(props, value)
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:col(s:coltype))
  if s:has_property(a:props, '_red_')
    let l:r += a:value
    if l:r > 255 | let l:r = 255 | endif
  elseif s:has_property(a:props, '_gree')
    let l:g += a:value
    if l:g > 255 | let l:g = 255 | endif
  elseif s:has_property(a:props, '_blue')
    let l:b += a:value
    if l:b > 255 | let l:b = 255 | endif
  endif
  call s:set_color(s:coltype, colortemplate#colorspace#rgb2hex(l:r, l:g, l:b))
endf

fun! s:rgb_decrease_level(props, value)
 let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:col(s:coltype))
  if s:has_property(a:props, '_red_')
    let l:r -= a:value
    if l:r < 0 | let l:r = 0 | endif
  elseif s:has_property(a:props, '_gree')
    let l:g -= a:value
    if l:g < 0 | let l:g = 0 | endif
  elseif s:has_property(a:props, '_blue')
    let l:b -= a:value
    if l:b < 0 | let l:b = 0 | endif
  endif
  call s:set_color(s:coltype, colortemplate#colorspace#rgb2hex(l:r, l:g, l:b))
endf

fun! s:rgb_slider(r, g, b) " -> List of Dictionaries
  return [
        \ s:blank(),
        \ s:prop_level_bar(s:slider('R', a:r), '_rgb_', '_red_'),
        \ s:prop_level_bar(s:slider('G', a:g), '_rgb_', '_gree'),
        \ s:prop_level_bar(s:slider('B', a:b), '_rgb_', '_blue'),
        \ s:prop_label(printf('%s%02d', repeat(' ', len(s:mark) + 3), s:step)),
        \]
endf

fun! s:redraw_rgb()
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(s:col(s:coltype))
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
" HSB Pane {{{
fun! s:redraw_hsb()
  call popup_settext(s:popup_id,
        \ extend(s:title_section('H'), [
        \ s:blank(),
        \ s:prop_label('Not implemented yet.'),
        \ s:prop_label('Please switch back to R.'),
        \ ]))
  call prop_add(1, 40, #{bufnr: winbufnr(s:popup_id), length: 1, type: '_labe'})
endf
" }}}
" Grayscale Pane {{{
fun! s:redraw_gray()
  call popup_settext(s:popup_id,
        \ extend(s:title_section('G'), [
        \ s:blank(),
        \ s:prop_label('Not implemented yet.'),
        \ s:prop_label('Please switch back to R.'),
        \ ]))
  call prop_add(1, 41, #{bufnr: winbufnr(s:popup_id), length: 1, type: '_labe'})
endf
" }}}
" Help pane {{{
fun! s:redraw_help()
  call popup_settext(s:popup_id,
        \ extend(s:title_section('?'), [
        \ s:blank(),
        \ s:prop_label('Popup'),
        \ s:noprop('[↑] Move up           [R] RGB'),
        \ s:noprop('[↓] Move down         [H] HSB'),
        \ s:noprop('[T] Go to top         [G] Grayscale'),
        \ s:noprop('[Tab] fg->bg->sp      [x] Close'),
        \ s:noprop('[S-Tab] sp->bg->fg    [X] Cancel'),
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
        \ ]))
  call prop_add(1, 42, #{bufnr: winbufnr(s:popup_id), length: 1, type: '_labe'})
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
  let @"=s:col(s:coltype)
  call s:notification('Color yanked')
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

fun! s:go_to_top()
  let s:active_line = s:select_first_item(s:active_line)
  call s:redraw()
  return 1
endf

fun! s:update_higroup()
  if s:update_higroup_under_cursor()
    " TODO: save current color to recent colors if modified
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
    call s:rgb_increase_level(l:props, s:step)
    call s:apply_color()
    call s:redraw()
  endif
  return 1
endf

fun! s:move_left()
  let l:props = s:get_properties(s:active_line)
  if s:has_property(l:props, '_rgb_')
    call s:rgb_decrease_level(l:props, s:step)
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
      \ 'down':             "\<down>",
      \ 'up':               "\<up>",
      \ 'top':              "T",
      \ 'decrement':        "\<left>",
      \ 'increment':        "\<right>",
      \ 'next-color':       "\<tab>",
      \ 'prev-color':       "\<s-tab>",
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
      \ s:key['down']:             function('s:select_next_item'),
      \ s:key['up']:               function('s:select_prev_item'),
      \ s:key['top']:              function('s:go_to_top'),
      \ s:key['decrement']:        function('s:move_left'),
      \ s:key['increment']:        function('s:move_right'),
      \ s:key['next-color']:       function('s:fgbgsp_next'),
      \ s:key['prev-color']:       function('s:fgbgsp_prev'),
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
  let s:popup_id = -1
endf

" Optional argument is the name of a highlight group
" If no name is used, then the popup updates as the cursor moves.
fun! colortemplate#style#open(...)
  if s:popup_id > -1 " Already open
    return s:popup_id
  endif

  let s:mark    = get(g:, 'colortemplate_popup_marker', '=> ')
  let s:width   = max([39 + len(s:mark), 42])
  let s:star    = get(g:, 'colortemplate_popup_star', '*')
  let s:sample_text = s:center(s:sample_texts[rand() % len(s:sample_texts)], s:width)

  call s:set_slider_symbols(0)
  if len(s:slider_symbols) != 9
    echohl WarningMsg
    echomsg '[Colortemplate] g:colortemplate_slider_symbols must be a List with 9 elements.'
    echohl None
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
  let s:active_line = 3
  call s:add_prop_types()
  call s:redraw()
  return s:popup_id
endf

fun! colortemplate#style#popup_id()
  return s:popup_id
endf
" }}}
