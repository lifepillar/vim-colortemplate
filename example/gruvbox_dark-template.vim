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
        \ 'guisp='   . get(s:palette, get(a:attrs, 'guisp', ''), ['NONE'])[0],
        \ s:attr(a:attrs, 'cterm'),
        \ s:attr(a:attrs, 'gui')
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
let s:colors_fullname  = 'Gruvbox Dark' " Descriptive name
let s:colors_name      = 'gruvbox_dark' " Only letters, numbers, and underscore (no spaces!)
let s:author           = 'morhetz'
let s:author_email     = 'morhetz@gmail.com'
let s:maintainer       = 'Lifepillar'
let s:maintainer_email = 'lifepillar@lifepillar.me'
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
      \ 'dark0'             : [s:rgb(40,  40,  40),    235,        'Black'],
      \ 'dark1'             : [s:rgb(60,  56,  54),    237,      'DarkRed'],
      \ 'dark2'             : [s:rgb(80,  73,  69),    239,    'DarkGreen'],
      \ 'dark3'             : [s:rgb(102, 92,  84),    241,   'DarkYellow'],
      \ 'dark4'             : [s:rgb(124, 111, 100),   243,     'DarkBlue'],
      \ 'grey'              : [s:rgb(146, 131, 116),   245,  'DarkMagenta'],
      \ 'light0'            : [s:rgb(253, 244, 193),   229,     'DarkCyan'],
      \ 'light1'            : [s:rgb(235, 219, 178),   223,    'LightGrey'],
      \ 'light2'            : [s:rgb(213, 196, 161),   250,     'DarkGrey'],
      \ 'light3'            : [s:rgb(189, 174, 147),   248,     'LightRed'],
      \ 'light4'            : [s:rgb(168, 153, 132),   246,   'LightGreen'],
      \ 'red'               : [s:rgb(251, 73,  52),    167,     'LightRed'],
      \ 'green'             : [s:rgb(184, 187, 38),    142,   'LightGreen'],
      \ 'yellow'            : [s:rgb(250, 189, 47),    214,  'LightYellow'],
      \ 'blue'              : [s:rgb(131, 165, 152),   109,    'LightBlue'],
      \ 'purple'            : [s:rgb(211, 134, 155),   175,    'LightBlue'],
      \ 'aqua'              : [s:rgb(142, 192, 124),   108,    'LightCyan'],
      \ 'orange'            : [s:rgb(254, 128, 25),    208,  'LightYellow'],
      \ 'bg'                : [s:rgb( 40, 40,  40),    235,        'Black'],
      \ 'fg'                : [s:rgb(235, 219, 178),   223,    'LightGrey'],
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
call s:put("endif")
call s:put("")
" Default highlight groups (see `:help highlight-default`)
call s:hl("ColorColumn",      'none',          'dark1',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Conceal",          'blue',          'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Cursor",           'none',          'none',        {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:li("CursorColumn",     'CursorLine')
call s:hl("CursorLine",       'none',          'dark1',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("CursorLineNr",     'yellow',        'dark1',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("DiffAdd",          'green',         'bg',          {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:hl("DiffChange",       'aqua',          'bg',          {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:hl("DiffDelete",       'red',           'bg',          {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:hl("DiffText",         'yellow',        'bg',          {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:hl("Directory",        'green',         'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("EndOfBuffer",      'dark0',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Error",            'red',           'bg',          {'cterm': 'bold,inverse',        'gui': 'bold,inverse',        'guisp': ''                    })
call s:hl("ErrorMsg",         'dark0',         'red',         {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("FoldColumn",       'grey',          'dark1',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Folded",           'grey',          'dark1',       {'cterm': 'italic',              'gui': 'italic',              'guisp': ''                    })
call s:hl("IncSearch",        'orange',        'bg',          {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:hl("LineNr",           'dark4',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("MatchParen",       'none',          'dark3',       {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("ModeMsg",          'yellow',        'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("MoreMsg",          'yellow',        'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("NonText",          'dark2',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Pmenu",            'light1',        'dark2',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("PmenuSbar",        'none',          'dark2',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("PmenuSel",         'dark2',         'blue',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("PmenuThumb",       'none',          'dark4',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Question",         'orange',        'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:li("QuickFixLine",     "Search")
call s:hl("Search",           'yellow',        'bg',          {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:hl("SignColumn",       'none',          'dark1',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("SpecialKey",       'dark2',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("SpellBad",         'none',          'none',        {'cterm': 'underline',           'gui': 'undercurl',           'guisp': 'blue'                })
call s:hl("SpellCap",         'none',          'none',        {'cterm': 'underline',           'gui': 'undercurl',           'guisp': 'red'                 })
call s:hl("SpellLocal",       'none',          'none',        {'cterm': 'underline',           'gui': 'undercurl',           'guisp': 'aqua'                })
call s:hl("SpellRare",        'none',          'none',        {'cterm': 'underline',           'gui': 'undercurl',           'guisp': 'magenta'             })
call s:hl("StatusLine",       'dark2',         'light1',      {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:hl("StatusLineNC",     'dark1',         'light4',      {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
call s:li("StatusLineTerm",   "StatusLine")
call s:li("StatusLineTermNC", "StatusLineNC")
call s:li("TabLine",          "TabLineFill")
call s:hl("TabLineFill",      'dark4',         'dark1',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("TabLineSel",       'green',         'dark1',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Title",            'green',         'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("VertSplit",        'dark3',         'dark0',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Visual",           'none',          'dark3',       {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:li("VisualNOS",        "Visual")
call s:hl("WarningMsg",       'red',           'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("WildMenu",         'blue',          'dark2',       {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
" Other conventional group names (see `:help group-name`)
call s:hl("Boolean",          'purple',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Character",        'purple',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Comment",          'grey',          'none',        {'cterm': 'italic',              'gui': 'italic',              'guisp': ''                    })
call s:hl("Constant",         'purple',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Debug",            'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Delimiter",        'orange',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Float",            'purple',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Function",         'green',         'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("Identifier",       'blue',          'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Ignore",           'fg',            'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Include",          'aqua',          'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Keyword",          'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Label",            'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Number",           'purple',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:li("Operator",         "Normal")
call s:hl("PreProc",          'aqua',          'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Special",          'orange',        'dark1',       {'cterm': 'italic',              'gui': 'italic',              'guisp': ''                    })
call s:hl("SpecialChar",      'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("SpecialComment",   'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Statement",        'red',           'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("StorageClass",     'orange',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("String",           'green',         'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Structure",        'aqua',          'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Todo",             'fg',            'bg',          {'cterm': 'bold,italic',         'gui': 'bold,italic',         'guisp': ''                    })
call s:hl("Type",             'yellow',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("Underlined",       'blue',          'none',        {'cterm': 'underline',           'gui': 'underline',           'guisp': ''                    })
" See `:help lCursor`
call s:li("lCursor",          "Cursor")
" See `:help CursorIM`
call s:hl("CursorIM",         'none',          'none',        {'cterm': 'inverse',             'gui': 'inverse',             'guisp': ''                    })
" Vim
call s:hl("vimCommentTitle",  'light4',        'none',        {'cterm': 'bold',                'gui': 'bold',                'guisp': ''                    })
call s:hl("vimMapModKey",     'orange',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:li("vimMapMod",        "vimMapModKey")
call s:hl("vimBracket",       'orange',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
call s:hl("vimNotation",      'orange',        'none',        {'cterm': '',                    'gui': '',                    'guisp': ''                    })
" Git
call s:li("gitcommitComment", "Comment")

if !get(g:, s:colors_name.'_test', 0)
  finish
endif
" Done! Good job! }}}

" Test colors (let g:<colorscheme_name>_test = 1 to enable) {{{
silent tabnew
so $VIMRUNTIME/syntax/hitest.vim
" }}}
" vim: foldmethod=marker nowrap
