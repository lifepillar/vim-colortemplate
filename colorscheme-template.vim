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
" attrs: a Dictionary of Lists of additional attributes
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
        \ s:attr(a:attrs, 'cterm'),
        \ s:attr(a:attrs, 'gui'),
        \ s:attr(a:attrs, 'guisp')
        \ ])
endf

" Append a highlight group definition to the current buffer.
" See s:hlstring() for the meaning of the parameters.
fun! s:hl(group, fg, bg, attrs)
  call append(line('$'), repeat(' ', get(a:attrs, 'indent', 0))
        \   . s:hlstring(a:group, a:fg, a:bg, a:attrs))
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
  call s:put  (   '" Maintainer:   ' . s:author. ' <' . s:maintainer_email. '>'                       )
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
" Change the color names as you see fit. Use such names to define the
" highlight groups later. Define as many or as few colors as you need.
" It is recommended not to use more than sixteen colors.
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
call s:hl(  "Normal", 'fg', 'none', {'indent': 2})
" Move here other definitions that depend on the background being transparent
call s:put("else")
call s:hl(  "Normal", 'fg', 'bg', {'indent': 2})
" Move here other definitions that depend on the background not being transparent
call s:put("else")
call s:put("endif")
call s:put("")
" Default highlight groups (see `:help highlight-default`)
call s:hl("ColorColumn",      'none',          'brightblack', {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Conceal",          'cyan',          'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Cursor",           'fg',            'blue',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("CursorColumn",     'none',          'brightblack', {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("CursorLine",       'none',          'brightblack', {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("CursorLineNr",     'fg',            'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("DiffAdd",          'brightgreen',   'bg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:hl("DiffChange",       'yellow',        'fg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:hl("DiffDelete",       'red',           'fg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:hl("DiffText",         'green',         'fg',          {'cterm': 'bold,reverse',        'gui': 'bold,reverse',        'guisp': ''                    })
call s:hl("Directory",        'brightgreen',   'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("EndOfBuffer",      'brightblack',   'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Error",            'red',           'fg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:hl("ErrorMsg",         'red',           'fg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:hl("FoldColumn",       'white',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Folded",           'white',         'brightblack', {'gui':   'italic'                                                                            })
call s:hl("IncSearch",        'yellow',        'fg',          {'cterm': 'reverse',             'gui': 'standout',            'guisp': ''                    })
call s:hl("LineNr",           'white',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("MatchParen",       'brightblack',   'yellow',      {'cterm': 'bold,reverse',        'gui': 'bold,reverse',        'guisp': ''                    })
call s:hl("ModeMsg",          'fg',            'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("MoreMsg",          'white',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("NonText",          'fg',            'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Pmenu",            'bg',            'cyan',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("PmenuSbar",        'brightblack',   'brightblack', {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("PmenuSel",         'fg',            'yellow',      {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("PmenuThumb",       'brightblack',   'yellow',      {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Question",         'white',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:li("QuickFixLine",     "Search")
call s:hl("Search",           'yellow',        'fg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:hl("SignColumn",       'white',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("SpecialKey",       'white',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("SpellBad",         'brightmagenta', 'none',        {'cterm': 'underline',           'gui': 'undercurl',           'guisp': 'undecurl'            })
call s:hl("SpellCap",         'brightmagenta', 'none',        {'cterm': 'underline',           'gui': 'undercurl',           'guisp': 'undecurl'            })
call s:hl("SpellLocal",       'brightmagenta', 'none',        {'cterm': 'underline',           'gui': 'undercurl',           'guisp': 'undecurl'            })
call s:hl("SpellRare",        'brightmagenta', 'none',        {'cterm': 'underline',           'gui': 'undercurl',           'guisp': 'undecurl'            })
call s:hl("StatusLine",       'cyan',          'fg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:hl("StatusLineNC",     'cyan',          'bg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:li("StatusLineTerm",   "StatusLine")
call s:li("StatusLineTermNC", "StatusLineNC")
call s:hl("TabLine",          'bg',            'cyan',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("TabLineFill",      'fg',            'cyan',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("TabLineSel",       'fg',            'cyan',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Title",            'yellow',        'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("VertSplit",        'cyan',          'cyan',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Visual",           'blue',          'fg',          {'cterm': 'reverse',             'gui': 'reverse',             'guisp': ''                    })
call s:hl("VisualNOS",        'fg',            'blue',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("WarningMsg",       'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("WildMenu",         'fg',            'magenta',     {'cterm': '',                    'gui': '',                    'guisp': ''                    })
" Other conventional group names (see `:help group-name`)
call s:hl("Boolean",          'brightgreen',   'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Character",        'yellow',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Comment",          'white',         'none',        {'cterm': 'italic',              'gui': 'italic',              'guisp': ''                    })
call s:hl("Constant",         'yellow',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Debug",            'magenta',       'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Delimiter",        'fg',            'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Float",            'brightgreen',   'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Function",         'green',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Identifier",       'brightcyan',    'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Ignore",           'fg',            'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Include",          'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Keyword",          'cyan',          'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Label",            'green',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Number",           'brightgreen',   'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Operator",         'brightcyan',    'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("PreProc",          'magenta',       'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Special",          'magenta',       'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("SpecialChar",      'magenta',       'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("SpecialComment",   'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Statement",        'cyan',          'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("StorageClass",     'brightcyan',    'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("String",           'brightgreen',   'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Structure",        'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Todo",             'magenta',       'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("Type",             'brightmagenta', 'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Underlined",       'none',          'none',        {'cterm': 'underline',           'gui': 'underline',           'guisp': ''                    })
" See `:help lCursor`
call s:li("lCursor",          "Cursor")
" See :help CursorIM
call s:hl("CursorIM",         'none',          'fg',          {'cterm': '',                    'gui': '',                    'guisp': ''                    })
" Vim
call s:hl("vimCommentTitle",  'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("vimMapModKey",     'yellow',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("vimMapMod",        'yellow',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("vimBracket",       'brightcyan',    'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("vimNotation",      'brightcyan',    'none',        {'cterm': 'bold,reverse,italic', 'gui': 'bold,reverse,italic', 'guisp': 'bold,reverse,italic' })
call s:li("vimUserFunc",      "Function")
" Git
call s:hl("gitcommitComment", 'brightblack',   'none',        {'cterm': 'italic',              'gui': 'italic',              'guisp': ''                    })

if !get(g:, s:colors_name.'_test', 0)
  finish
endif
" Done! Good job! }}}

" Test colors (let g:<colorscheme_name>_test = 1 to enable) {{{
silent tabnew
so $VIMRUNTIME/syntax/hitest.vim
" }}}
" vim: foldmethod=marker nowrap
