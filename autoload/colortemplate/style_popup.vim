let s:attributes = ['bold', 'italic', 'reverse', 'standout', 'underline', 'undercurl']
let s:mode = has('gui_running') ? 'gui' : 'cterm'

fun! s:notify_change()
  silent doautocmd User ColortemplateStyleChanged
endf

fun! s:go_down(popup_id)
  let l:curline = line('.', a:popup_id)
  if l:curline < getwinvar(a:popup_id, 'maxline')
    call win_execute(a:popup_id, 'call cursor('.(l:curline + 1).',1)')
  endif
  return 1
endf

fun! s:go_up(popup_id)
  let l:curline = line('.', a:popup_id)
  if l:curline > getwinvar(a:popup_id, 'minline')
    call win_execute(a:popup_id, 'call cursor('.(l:curline - 1).',1)')
  endif
  return 1
endf

fun! s:popup_update(popup_id)
  call popup_settext(a:popup_id, s:cs_text())
endf

fun! s:toggle_attribute(popup_id)
  call colortemplate#syn#toggle_attribute(s:attributes[line('.', a:popup_id) - 1])
  call s:popup_update(a:popup_id)
endf

fun! s:close_popup(popup_id)
  call popup_close(a:popup_id)
endf

fun! s:mouse(popup_id)
  echo string(a:popup_id) . ' ' . string(getmousepos())
endf

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Current Style Popup Menu
"
" Allows you to change the style attributes (bold, italics, etc.) of the
" highlight group under the cursor.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:cs_popup_id = -1

let s:cs_keymap = {
      \ "\<down>"     : function('s:go_down'),
      \ "\<up>"       : function('s:go_up'),
      \ "\<space>"    : function('s:toggle_attribute'),
      \ "x"           : function('s:close_popup'),
      \ }

fun! s:cs_text()
  let l:attrs = colortemplate#syn#attributes(synIDtrans(synID(line('.'), col('.'), 1)), s:mode)
  let l:menu = []
  for l:a in s:attributes
    call add(l:menu, index(l:attrs, l:a) == -1 ? l:a : 'X ' .. l:a)
  endfor
  return l:menu
endf

fun! colortemplate#style_popup#cs_filter(winid, key)
  if has_key(s:cs_keymap, a:key)
    call s:cs_keymap[a:key](a:winid)
    return 1
  endif
  return 0
endf

fun! colortemplate#style_popup#cs_closed(id, result)
  autocmd! colortemplate_style
  augroup! colortemplate_style
  let s:cs_popup_id = -1
endf

fun! colortemplate#style_popup#open()
  if !hlexists('PopupSelected')
    hi PopupSelected cterm=reverse gui=reverse
  endif

  if s:cs_popup_id > -1
    return s:cs_popup_id
  endif

  augroup colortemplate_style
    autocmd CursorMoved * call s:popup_update(s:cs_popup_id)
  augroup END

  let s:cs_popup_id = popup_create(s:cs_text(), #{
        \ border: [1,1,1,1],
        \ borderchars: ['-', '|', '-', '|', '┌', '┐', '┘', '└'],
        \ callback: 'colortemplate#style_popup#cs_closed',
        \ close: 'button',
        \ cursorline: 1,
        \ drag: 1,
        \ filter: 'colortemplate#style_popup#cs_filter',
        \ filtermode: 'n',
        \ highlight: 'Normal',
        \ mapping: 0,
        \ maxwidth: 16,
        \ minwidth: 16,
        \ padding: [0,1,0,1],
        \ pos: 'center',
        \ resize: 0,
        \ scrollbar: 0,
        \ tabpage: 0,
        \ title: 'Current Style',
        \ wrap: 0,
        \ zindex: 200,
        \ })
  call setwinvar(s:cs_popup_id, 'minline', 1)
  call setwinvar(s:cs_popup_id, 'maxline', len(s:attributes))
  return s:cs_popup_id
endf

