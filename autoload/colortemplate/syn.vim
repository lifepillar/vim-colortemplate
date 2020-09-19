" Utility functions {{{
" Returns the background color of the given highlight group, as a two-element
" array containing the cterm and the gui entry.
fun! colortemplate#syn#hi_group_bg(hl)
  return [synIDattr(synIDtrans(hlID(a:hl)), "bg", "cterm"), synIDattr(synIDtrans(hlID(a:hl)), "bg", "gui")]
endf

" Ditto, for the foreground color.
fun! colortemplate#syn#hi_group_fg(hl)
  return [synIDattr(synIDtrans(hlID(a:hl)), "fg", "cterm"), synIDattr(synIDtrans(hlID(a:hl)), "fg", "gui")]
endf
" }}}
" Info about attributes {{{
fun! colortemplate#syn#attributes(synid, mode)
  let l:attrs = []
  for l:a in ['bold', 'italic', 'inverse', 'standout', 'underline', 'undercurl']
    if '1' ==# synIDattr(a:synid, l:a, a:mode)
      call add(l:attrs, l:a)
    endif
  endfor
  if '1' ==# synIDattr(a:synid, 'strike', a:mode)
    call add(l:attrs, 'strikethrough')
  endif
  return l:attrs
endf

fun! s:toggle_attribute(synid, attr)
  " Note that in terminals, Vim (correctly) always uses cterm attributes, even
  " when termguicolors is set (termguicolors is only about colors, not
  " attributes). NeoVim does not get it right, IMO (and Bram's), because it
  " uses gui attributes when termguicolors is set.
  let l:mode = (has('gui_running') ? 'gui' : 'cterm')
  let l:synid = synIDtrans(a:synid)
  let l:old_attrs = colortemplate#syn#attributes(l:synid, l:mode)
  let l:name = synIDattr(l:synid, 'name')
  if empty(l:name) || l:name == 'Normal'
    echohl WarningMsg
    unsilent echo '[Colortemplate] Attributes cannot be set for Normal.'
    echohl None
    return
  endif
  let l:i = index(l:old_attrs, a:attr)
  if l:i == -1
    execute 'hi' l:name l:mode..'='..a:attr..','..join(l:old_attrs, ',')
  else
    call remove(l:old_attrs, l:i)
    execute 'hi' l:name l:mode..'='..(empty(l:old_attrs) ? 'NONE' : join(l:old_attrs, ','))
  endif
endf

fun! colortemplate#syn#toggle_attribute(synid, attr)
  call s:toggle_attribute(a:synid, a:attr)
endf
" }}}
" Info about the highlighting under cursor/mouse {{{
hi clear ColortemplateInfoFg
hi clear ColortemplateInfoBg
hi clear ColortemplateInfoSp
hi ColortemplateInfoBlack ctermbg=16 guibg=#000000

let s:cached_higroup = #{ synid: -1 }

" Returns a Dictionary with information about the highlight group at the
" specified position.
"
" See: http://vim.wikia.com/wiki/VimTip99 and hilinks.vim script.
fun! s:get_higroup_info(line, col)
  let synid = synID(a:line, a:col, 0)
  if empty(synid) || synid == 0 " Apparently, sometimes synID() fails to return a value
    return {}
  endif
  let trans = synIDattr(synID(a:line, a:col, 0), "name")
  let synid = synID(a:line, a:col, 1)
  let higrp = synIDattr(synid, "name")
  let synid = synIDtrans(synid)
  let logrp = synIDattr(synid, "name")
  if synid == s:cached_higroup.synid
    return s:cached_higroup
  else
    let fgterm = synIDattr(synid, "fg", "cterm")
    let fggui  = synIDattr(synid, "fg#", "gui")
    let bgterm = synIDattr(synid, "bg", "cterm")
    let bggui  = synIDattr(synid, "bg#", "gui")
    let spterm = synIDattr(synid, "ul", "cterm") " TODO: Not implemented? Should be 'sp'?
    let spgui  = synIDattr(synid, "sp#", "gui")
    let s:cached_higroup = #{
          \ synid:     synid,
          \ tname:     trans,
          \ name:      higrp,
          \ transname: logrp,
          \ fgterm:    empty(fgterm) ? 'NONE' : fgterm,
          \ fggui:     empty(fggui)  ? 'NONE' : fggui,
          \ bgterm:    empty(bgterm) ? 'NONE' : bgterm,
          \ bggui:     empty(bggui)  ? 'NONE' : bggui,
          \ spterm:    empty(spterm) ? 'NONE' : spterm,
          \ spgui:     empty(spgui)  ? 'NONE' : spgui,
          \ }
  endif
  try " The following may raise an error, e.g., if CtrlP is opened while this is active
    execute "hi!" "ColortemplateInfoFg" "ctermbg=".s:cached_higroup.fgterm "guibg=".s:cached_higroup.fggui
    execute "hi!" "ColortemplateInfoBg" "ctermbg=".s:cached_higroup.bgterm "guibg=".s:cached_higroup.bggui
    execute "hi!" "ColortemplateInfoSp" "ctermbg=".s:cached_higroup.spterm "guibg=".s:cached_higroup.spgui
  catch /^Vim\%((\a\+)\)\=:E254/ " Cannot allocate color
    hi clear ColortemplateInfoFg
    hi clear ColortemplateInfoBg
  endtry
  let synstack = synstack(a:line, a:col)
  " Sometimes, Vim spits E896: Argument of map() must be a List, Dictionary or Blob
  " even if synstack is a List...
  if !empty(synstack)
    let s:cached_higroup['synstack'] = map(reverse(synstack), { i,v -> synIDattr(v, "name") })
  else
    let s:cached_higroup['synstack'] = []
  endif
  return s:cached_higroup
endf

let s:balloon_id = 0
let s:last_text = ''
let s:ballon_text = []

call prop_type_delete('ct_hifg')
call prop_type_delete('ct_hibg')
call prop_type_delete('ct_hisp')
call prop_type_add('ct_hifg', #{ highlight: 'ColortemplateInfoFg' })
call prop_type_add('ct_hibg', #{ highlight: 'ColortemplateInfoBg' })
call prop_type_add('ct_hisp', #{ highlight: 'ColortemplateInfoSp' })

" Display info about the highlight group under the cursor in a popup when
" ballooneval or balloonevalterm is set.
"
" See :help popup_beval_example
fun! colortemplate#syn#balloonexpr()
  if s:balloon_id && popup_getpos(s:balloon_id) != {}
    " Previous popup window still shows
    if v:beval_text == s:last_text
      " Still the same text, keep the existing popup
      return ''
    endif
    call popup_close(s:balloon_id)
  endif
  let info = s:get_higroup_info(v:beval_lnum, v:beval_col)
  if !empty(info)
    let l:beval = [
          \ #{ text: printf('%s%s%s',
          \                (info['tname'] == info['name'] ? '' : 'T:'..info['tname']..' → '),
          \                 info['name'],
          \                 info['name'] == info['transname'] ? '' :  ' → '..info['transname']
          \               ),
          \    props: []
          \  },
          \ #{ text: printf('     Fg %7s %4s     ', info.fggui, info.fgterm),
          \   props: [#{ col: 2, length:  2, type: 'ct_hifg' }]
          \  },
          \]
    if info.bggui != 'NONE' || info.bgterm != 'NONE'
      call add(l:beval,
          \ #{ text: printf('     Bg %7s %4s     ', info.bggui, info.bgterm),
          \   props: [#{ col: 2, length:  2, type: 'ct_hibg' }]
          \ })
    endif
    if info.spgui != 'NONE' || info.spterm != 'NONE'
      call add(l:beval,
          \ #{ text: printf('     Sp %7s %4s     ', info.spgui, info.spterm),
          \   props: [#{ col: 2, length:  2, type: 'ct_hisp' }]
          \ })
    endif
    call add(l:beval, #{ text: join(info['synstack'], " ⊂ "), props: [] })

    let s:balloon_id = popup_beval(l:beval, #{
          \ mousemoved: 'word',
          \ moved: 'any',
          \ close: 'click',
          \ padding: [0,1,0,1],
          \ })
    let s:last_text = v:beval_text
  endif
  return ''
endfunc

" Displays some information about the highlight group under the cursor
" in the command line.
fun! colortemplate#syn#hi_group()
  let info = s:get_higroup_info(line('.'), col('.'))
  if empty(info)
    return ''
  endif
  echo join(info.synstack, " ⊂ ")
  execute "echohl" info.transname | echon " xxx " | echohl None
  echon (info.name != info.tname ? "T:".info['tname']." → ".info['name'] : info['name'])
        \ . (info.name != info.transname ? " → ".info['transname'] : "")." "
  echohl ColortemplateInfoFg | echon "  " | echohl None
  echon printf(" fg=%s/%s ", info.fggui, info.fgterm)
  if info.bggui != 'NONE' || info.bgterm != 'NONE'
    echohl ColortemplateInfoBg | echon "  " | echohl None
    echon printf(" bg=%s/%s ", info.bggui, info.bgterm)
  endif
  if info.spgui != 'NONE' || info.spterm != 'NONE'
    echohl ColortemplateInfoSp | echon "  " | echohl None
    echon printf(" sp=%s/%s ", info.spgui, info.spterm)
  endif
endf

fun! colortemplate#syn#toggle()
  if get(g:, 'colortemplate_higroup_balloon', 1)
    if s:balloon_id && popup_getpos(s:balloon_id) != {}
      call popup_close(s:balloon_id)
    endif
    set ballooneval! balloonevalterm!
  endif
  if get(g:, 'colortemplate_higroup_command_line', 1)
    if exists("#colortemplate_syn_info")
      autocmd! colortemplate_syn_info
      augroup! colortemplate_syn_info
      echo "\r"
    else
      let s:cached_higroup = #{ synid: -1 }
      augroup colortemplate_syn_info
        autocmd CursorMoved * call colortemplate#syn#hi_group()
      augroup END
    endif
  endif
endf
" }}}
" Highlight -> RGB {{{
" Configurable values for the 16 terminal ANSI colors.
"
" The 24 bit RGB values used for the 16 ANSI colors differ greatly for each
" terminal implementation. Below is a system that is both consistent and 12
" bit compatible. See https://mudhalla.net/tintin/info/ansicolor/

" These are arbitrary hex values for terminal colors in the range 0-15. These
" are defined for situations in which a hex value must be returned under any
" circumstances, even if it is an approximate value.
let g:colortemplate#syn#ansi_colors = [
      \ '#000000',
      \ '#aa0000',
      \ '#00aa00',
      \ '#aaaa00',
      \ '#0000aa',
      \ '#aa00aa',
      \ '#00aaaa',
      \ '#aaaaaa',
      \ '#555555',
      \ '#ff5555',
      \ '#55ff55',
      \ '#ffff55',
      \ '#5555ff',
      \ '#ff55ff',
      \ '#55ffff',
      \ '#ffffff',
      \ ]

fun! s:fallback_color(type)
  return #{ hex: a:type ==# 'bg'
        \                   ? (&bg ==# 'dark' ? '#000000' : '#ffffff')
        \                   : (&bg ==# 'dark' ? '#ffffff' : '#000000'),
        \   guess: 1 }
endf

" Try (hard) to derive a more or less reasonable hex value for a given
" highlight group color. This is trivial if the environment supports millions
" of colors and the highlight group defines guifg/guibg/guisp; it is easy if
" the cterm color is a number >15 (see above). But the highlight group may not
" define guifg/guibg/guisp, the environment may support only 256 colors, and
" the terminal color might be a number in [0-15], a name (e.g., Magenta), or
" fg/bg (or it may not exist either).
"
" This function is useful, for instance, when importing highlight group
" definitions to create a template, or in the style popup. In such cases,
" getting an approximate value is better than nothing.
"
" name: the name of a highlight group
" type: 'fg', 'bg', or 'sp'
"
" Returns a Dictionary with two keys:
" hex: the color value
" guess: a flag indicating whether the color is a guess (1) or exact (0)
fun! colortemplate#syn#higroup2hex(name, type)
  if has('gui_running') || (has('termguicolors') && &termguicolors)
    let l:gui = synIDattr(synIDtrans(hlID(a:name)), a:type.'#', 'gui')

    if !empty(l:gui) " Fast path
      return #{ hex: l:gui, guess: 0}
    endif

    if a:type ==# 'sp'
      return colortemplate#syn#higroup2hex(a:name, 'fg')
    elseif a:name == 'Normal'
      return s:fallback_color(a:type)
    endif
    return colortemplate#syn#higroup2hex('Normal', a:type)
  endif

  " Assume 256-color terminal
  let l:term = synIDattr(hlID(a:name), a:type, 'cterm')

  if !empty(l:term) && str2nr(l:term) > 15 " Fast path
    return #{ hex: colortemplate#colorspace#xterm256_hexvalue(str2nr(l:term)), guess: 0}
  endif

  if empty(l:term)
    if a:type ==# 'sp'
      return colortemplate#syn#higroup2hex(a:name, 'fg')
    elseif a:name == 'Normal'
      return s:fallback_color(a:type)
    endif
    return colortemplate#syn#higroup2hex('Normal', a:type)
  endif

  if l:term =~ '\m^\d\+$' " If it's a number, it must be between 0 and 15
    return #{ hex: g:colortemplate#syn#ansi_colors[str2nr(l:term)], guess: 1}
  endif

  if l:term =~# '\m^\(fg\|bg\|ul\)$' " fg/bg/ul
    if a:name == 'Normal' " ? Should never happen
      return s:fallback_color(a:type)
    endif
    return colortemplate#syn#higroup2hex('Normal', (l:term ==# 'ul' ? 'sp' : l:term))
  endif

  " Term color is a color name
  try " to convert name to number
    let l:term = string(colortemplate#colorspace#ctermcolor(tolower(l:term), 16))
    return #{ hex: colortemplate#colorspace#xterm256_hexvalue(str2nr(l:term)), guess: 0}
  catch " What?!
    return s:fallback_color(a:type)
  endtry
  endif
endf
" }}}

" vim: foldmethod=marker nowrap et ts=2 sw=2
