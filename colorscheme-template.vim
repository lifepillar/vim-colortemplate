" Name:        Colorscheme template
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

" Helper functions (do not change this block) {{{

" Convert a hexadecimal color string into a three-elements list of RGB values.
fun! s:hex2rgb(col)
  return map(matchlist(a:col, '^#\?\(..\)\(..\)\(..\)$')[1:3], 'str2nr(v:val,16)')
endf

" Convert an RGB color into the equivalent hexadecimal String.
"
" Example: call s:rgb(255,255,255) -> '#ffffff'
fun! s:rgb(r,g,b)
  return '#' . printf('%02x', a:r) . printf('%02x', a:g) . printf('%02x', a:b)
endf

" Append a String to the end of the current buffer.
fun! s:put(line)
  call append(line('$'), a:line)
endf

" Return a string specifying cterm/gui attributes for a highlight group.
"
" dict: a Dictionary whose values are Strings of attributes (e.g., 'bold,reverse')
" key: a String among 'cterm', 'gui', 'guisp'
fun! s:attr(dict, key)
  return a:key.'=NONE'.(empty(get(a:dict, a:key, '')) ? '' : ','.a:dict[a:key])
endf

" Return a highlight group definition as a String.
"
" group: the name of the highlight group
" fg: the foreground color for the group
" bg: the background color for the group
" attrs: a Dictionary of additional attributes
"
" fg and bg must be three-element arrays of them form:
" [GUI color, 256-based color, 16-based color]
fun! s:hlstring(group, fg, bg, attrs)
  return join([
        \ 'hi', a:group,
        \ 'ctermfg=' . s:palette[a:fg][get(g:, 'base16colors', 0) ? 2 : 1],
        \ 'ctermbg=' . s:palette[a:bg][get(g:, 'base16colors', 0) ? 2 : 1],
        \ 'guifg='   . s:palette[a:fg][0],
        \ 'guibg='   . s:palette[a:bg][0],
        \ 'guisp='   . get(s:palette, get(a:attrs, 'guisp', ''), ['NONE'])[0],
        \ s:attr(a:attrs, 'cterm'),
        \ s:attr(a:attrs, 'gui')
        \ ])
endf

" Parse a highlight group specification of the form:
"   Group fg bg [attributes] [guisp=color]
" or
"   Group fg bg [t=term_attr] [g=gui_attr] [s=color]
" where the parts in [.] are optional.
" Append the result at the end of the current buffer.
fun! s:hl(line)
  let l:elem = split(a:line, '\s\+')
  let l:group = l:elem[0]
  let l:fg = l:elem[1]
  let l:bg = l:elem[2]
  let l:term = ''
  let l:gui = ''
  let l:guisp = ''
  for l:i in range(3, len(l:elem) - 1)
    if l:elem[l:i] =~ '='
      let [l:key, l:value] = split(l:elem[l:i], '=')
      if l:key =~ '^t\a*'
        let l:term = l:value
      elseif l:key =~ '^g\a*'
        let l:gui = l:value
      elseif l:key =~ 's\a*'
        let l:guisp = l:value
      endif
    else
      let l:term = l:elem[l:i]
      let l:gui = l:elem[l:i]
    endif
  endfor
  call append('$', s:hlstring(l:group, l:fg, l:bg, { 'cterm': l:term, 'gui': l:gui, 'guisp': l:guisp }))
endf

" Append a linked highlight group definition (hi link) to the current buffer.
fun! s:li(src_group, tgt_group, ...) " Optional argument is for indentation
  call append(line('$'), repeat(' ', get(get(a:000, 0, {}), 'indent', 0))
        \   . 'hi! link '.a:src_group.' '.a:tgt_group)
endf

fun! s:new_buffer()
  silent tabnew +setlocal\ ft=vim
  execute 'file' s:colors_name.(get(g:, 'base16colors', 0) ? '_16' : '').'.vim'
endf

fun! s:print_header()
  call setline(1, '" Name:         ' . s:colors_fullname . ' colorscheme for Vim'                     )
  call s:put  (   '" Author:       ' . s:author. ' <' . s:author_email. '>'                           )
  call s:put  (   '" Maintainer:   ' . s:maintainer . ' <' . s:maintainer_email. '>'                  )
  call s:put  (   '" License:      Vim License  (see `:help license`)'                                )
  call s:put  (   ''                                                                                  )
  call s:put  (   '" Color palette:'                                                                  )
  call s:print_palette()
  call s:put  (   ''                                                                                  )
  call s:put  (   "if !exists('&t_Co')"                                                               )
  call s:put  (   '" FIXME: Do something?'                                                            )
  call s:put  (   'endif'                                                                             )
  call s:put  (   ''                                                                                  )
  call s:put  (   "set background=" . s:background                                                    )
  call s:put  (   ''                                                                                  )
  call s:put  (   'hi clear'                                                                          )
  call s:put  (   "if exists('syntax_on')"                                                            )
  call s:put  (   '  syntax reset'                                                                    )
  call s:put  (   'endif'                                                                             )
  call s:put  (   ''                                                                                  )
  call s:put  (   "let g:colors_name = '".s:colors_name.(get(g:, 'base16colors', 0 ) ? '_16' : '')."'")
endf

fun! s:print_palette()
  for l:color in keys(s:palette)
    call s:put('"  "' . l:color . '": ["'
          \ . s:palette[l:color][0] . '", '
          \ . s:palette[l:color][1] . ', "'
          \ . s:palette[l:color][2] . '"]')
  endfor
endf
" }}}

" Mandatory information about your colorscheme {{{
let s:colors_fullname  = 'Wonderful Colors' " Descriptive name
let s:colors_name      = 'wonderful_colors' " Only letters, numbers, and underscore (no spaces!)
let s:author           = 'Myself'
let s:author_email     = 'me at somewhere.org'
let s:maintainer       = 'Myself'
let s:maintainer_email = 'me at somewhere.org'
let s:background       = 'dark' " 'dark' or 'light'
" }}}

" Define your color palette {{{
" Change the color names as you see fit. Use those names to define the
" highlight groups later. Define as many or as few colors as you need, but
" leave the 'none' entry untouched.
" You should always define GUI colors and base-256 colors. If you do not plan
" to generate a base-16 colorscheme, you may leave the base-16 colors as they
" are.
"
"        color name         :  [GUI color, base-256 color, base-16 color]
let s:palette = {
      \ 'black'             : [s:rgb(41,  44,  54),    191,        'Black'],
      \ 'red'               : [s:rgb(220, 60,  60),    192,      'DarkRed'],
      \ 'green'             : [s:rgb(220, 60,  60),    193,    'DarkGreen'],
      \ 'yellow'            : [s:rgb(220, 60,  60),    194,   'DarkYellow'],
      \ 'blue'              : [s:rgb(220, 60,  60),    195,     'DarkBlue'],
      \ 'magenta'           : [s:rgb(220, 60,  60),    196,  'DarkMagenta'],
      \ 'cyan'              : [s:rgb(220, 60,  60),    197,     'DarkCyan'],
      \ 'white'             : [s:rgb(220, 60,  60),    198,    'LightGrey'],
      \ 'brightblack'       : [s:rgb(220, 60,  60),    199,     'DarkGrey'],
      \ 'brightred'         : [s:rgb(220, 60,  60),    200,     'LightRed'],
      \ 'brightgreen'       : [s:rgb(220, 60,  60),    201,   'LightGreen'],
      \ 'brightyellow'      : [s:rgb(220, 60,  60),    202,  'LightYellow'],
      \ 'brightblue'        : [s:rgb(220, 60,  60),    203,    'LightBlue'],
      \ 'brightmagenta'     : [s:rgb(220, 60,  60),    204, 'LightMagenta'],
      \ 'brightcyan'        : [s:rgb(220, 60,  60),    205,    'LightCyan'],
      \ 'brightwhite'       : [s:rgb(220, 60,  60),    206,        'White'],
      \ 'bg'                : [s:rgb(220, 60,  60),    208,        'Black'],
      \ 'fg'                : [s:rgb(220, 60,  60),    207,        'White'],
      \ 'none'              : [             'NONE', 'NONE',         'NONE']
      \ }
" }}}

" Define the colorscheme {{{
call s:new_buffer()
call s:print_header()
call s:put('')
call s:put("if !has('gui_running') && get(g:,'".s:colors_name."_transp_bg', 0)")
call s:hl(  'Normal fg none')
" Move here other definitions that depend on the background being transparent
call s:put("else")
call s:hl(  'Normal fg bg')
" Move here other definitions that depend on the background not being transparent
call s:put("endif")
call s:put("")
" Default highlight groups (see `:help highlight-default`)
call s:hl('ColorColumn none brightblack')
call s:hl('Conceal cyan none')
call s:hl('Cursor fg blue')
call s:hl('CursorColumn none brightblack')
call s:hl('CursorLine none brightblack')
call s:hl('CursorLineNr fg none')
call s:hl('DiffAdd brightgreen bg reverse')
call s:hl('DiffChange yellow fg reverse')
call s:hl('DiffDelete red fg reverse')
call s:hl('DiffText green fg bold,reverse')
call s:hl('Directory brightgreen none')
call s:hl('EndOfBuffer brightblack none')
call s:hl('Error red fg reverse')
call s:hl('ErrorMsg red fg reverse')
call s:hl('FoldColumn white none')
call s:hl('Folded white black italic')
call s:hl('IncSearch yellow fg t=reverse g=standout')
call s:hl('LineNr white none')
call s:hl('MatchParen brightblack yellow bold,reverse')
call s:hl('ModeMsg fg none')
call s:hl('MoreMsg white none')
call s:hl('NonText fg none')
call s:hl('Pmenu bg cyan')
call s:hl('PmenuSbar brightblack brightblack')
call s:hl('PmenuSel fg yellow')
call s:hl('PmenuThumb brightblack yellow')
call s:hl('Question white none')
call s:li('QuickFixLine', "Search")
call s:hl('Search yellow fg')
call s:hl('SignColumn white none')
call s:hl('SpecialKey white none')
call s:hl('SpellBad brightmagenta none')
call s:hl('SpellCap brightmagenta none')
call s:hl('SpellLocal brightmagenta none')
call s:hl('SpellRare brightmagenta none')
call s:hl('StatusLine cyan fg')
call s:hl('StatusLineNC cyan bg')
call s:li('StatusLineTerm',   "StatusLine")
call s:li('StatusLineTermNC', "StatusLineNC")
call s:hl('TabLine bg cyan')
call s:hl('TabLineFill fg cyan')
call s:hl('TabLineSel fg cyan')
call s:hl('Title yellow none')
call s:hl('VertSplit cyan cyan')
call s:hl('Visual blue fg')
call s:hl('VisualNOS fg blue')
call s:hl('WarningMsg red none')
call s:hl('WildMenu fg magenta')
" Other conventional group names (see `:help group-name`)
call s:hl('Boolean brightgreen none')
call s:hl('Character yellow none')
call s:hl('Comment white none')
call s:hl('Constant yellow none')
call s:hl('Debug magenta none')
call s:hl('Delimiter fg none')
call s:hl('Float brightgreen none')
call s:hl('Function green none')
call s:hl('Identifier brightcyan none')
call s:hl('Ignore fg none')
call s:hl('Include red none')
call s:hl('Keyword cyan none')
call s:hl('Label green none')
call s:hl('Number brightgreen none')
call s:hl('Operator brightcyan none')
call s:hl('PreProc magenta none')
call s:hl('Special magenta none')
call s:hl('SpecialChar magenta none')
call s:hl('SpecialComment red none')
call s:hl('Statement cyan none')
call s:hl('StorageClass brightcyan none')
call s:hl('String brightgreen none')
call s:hl('Structure red none')
call s:hl('Todo magenta none')
call s:hl('Type brightmagenta none')
call s:hl('Underlined none none')
" See `:help lCursor`
call s:li('lCursor',          "Cursor")
" See `:help CursorIM`
call s:hl('CursorIM none fg')
" Vim
call s:hl('vimCommentTitle red none')
call s:hl('vimMapModKey yellow none')
call s:hl('vimMapMod yellow none')
call s:hl('vimBracket brightcyan none')
call s:hl('vimNotation brightcyan none')
call s:li('vimUserFunc',      "Function")
" Git
call s:hl('gitcommitComment brightblack none')

if !get(g:, s:colors_name.'_test', 0)
  finish
endif
" Done! Good job! }}}

" Test colors (let g:<colorscheme_name>_test = 1 to enable) {{{
silent tabnew
so $VIMRUNTIME/syntax/hitest.vim
" }}}
" vim: foldmethod=marker nowrap
