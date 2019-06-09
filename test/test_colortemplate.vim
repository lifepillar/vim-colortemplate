let s:testdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:colordir = s:testdir . '/colors'
let s:docdir = s:testdir . '/doc'
execute 'lcd' s:testdir
execute 'source' s:testdir.'/test.vim'

fun! s:verify(f)
  let l:fail = assert_equalfile(s:testdir.'/expected/'.a:f.'.vim', s:testdir.'/colors/'.a:f.'.vim')
  if !l:fail
    call delete(s:testdir.'/colors/'.a:f.'.vim')
  endif
endf

fun! Test_CT_fine()
  edit test1.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test1')
  bwipe test1.txt
endf

fun! Test_CT_color_typo()
  edit test2.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Undefined color name: wwhite', l:qflist[0]['text'])
  cclose
  bwipe test2.txt
endf

fun! Test_CT_invalid_token()
  edit test3.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Invalid token', l:qflist[0]['text'])
  cclose
  bwipe test3.txt
endf

fun! Test_CT_fg_bg_none_colors()
  edit test4.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:qflist[0]['text'])
  call assert_equal(7, l:qflist[0]['lnum'])
  call assert_equal(8, l:qflist[0]['col'])
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:qflist[1]['text'])
  call assert_equal(8, l:qflist[1]['lnum'])
  call assert_equal(9, l:qflist[1]['col'])
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:qflist[2]['text'])
  call assert_equal(9, l:qflist[2]['lnum'])
  call assert_equal(7, l:qflist[2]['col'])
  cclose
  bwipe test4.txt
endf

fun! Test_CT_Normal_must_be_first()
  edit test5.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test5.txt
endf

fun! Test_CT_Normal_alt_background()
  edit test6.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal("Invalid token", l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(19, l:qflist[0]['col'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[1]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[2]['text'])
  cclose
  bwipe test6.txt
endf

" reverse in Normal is accepted by Colortemplate! v2.0, but should be
" detected by Vim's check_colors.vim script.
fun! Test_CT_Normal_reverse()
  edit test7.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test7.txt
endf

fun! Test_CT_extra_chars_after_verbatim()
  edit test8.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal("Extra characters after 'verbatim'", l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal("Extra characters after 'endverbatim'", l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  cclose
  bwipe test8.txt
endf

fun! Test_CT_undefined_color_in_verbatim_block()
  edit test9.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(4, len(l:qflist))
  call assert_equal("Undefined @ value", l:qflist[0]['text'])
  call assert_equal(12, l:qflist[0]['lnum'])
  call assert_equal("Undefined @ value", l:qflist[1]['text'])
  call assert_equal(13, l:qflist[1]['lnum'])
  call assert_equal("Undefined @ value", l:qflist[2]['text'])
  call assert_equal(14, l:qflist[2]['lnum'])
  call assert_equal("Undefined @ value", l:qflist[3]['text'])
  call assert_equal(15, l:qflist[3]['lnum'])
  cclose
  bwipe test9.txt
endf

fun! Test_CT_unexpected_token_at_start_of_line()
  edit test10.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Unexpected token at start of line', l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  cclose
  bwipe test10.txt
endf

fun! Test_CT_invalid_chars_in_key()
  edit test11.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Only letters from a to z and underscores are allowed in keys', l:qflist[0]['text'])
  call assert_equal(5, l:qflist[0]['lnum'])
  cclose
  bwipe test11.txt
endf

fun! Test_CT_invalid_background()
  edit test12.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal("Background can only be 'dark', 'light' or 'any'", l:qflist[0]['text'])
  call assert_equal("Cannot define highlight group before Variant or Background is set", l:qflist[1]['text'])
  cclose
  bwipe test12.txt
endf

fun! Test_CT_unknown_key()
  edit test13.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Metadata value cannot be empty', l:qflist[0]['text'])
  call assert_equal(5, l:qflist[0]['lnum'])
  call assert_equal(4, l:qflist[0]['col'])
  call assert_equal('Unknown key: abcdef', l:qflist[1]['text'])
  call assert_equal(6, l:qflist[1]['lnum'])
  call assert_equal(8, l:qflist[1]['col'])
  cclose
  bwipe test13.txt
endf

fun! Test_CT_colon_after_color_key()
  edit test14.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal('Expected colon after Color keyword', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal("Undefined color name: black", l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[2]['text'])
  cclose
  bwipe test14.txt
endf

fun! Test_CT_invalid_color_name()
  edit test15.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal('Invalid color name', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal(8, l:qflist[0]['col'])
  call assert_equal("Undefined color name: black", l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal(14, l:qflist[1]['col'])
  call assert_equal("Please define the Normal highlight group for 16-color variant", l:qflist[2]['text'])
  cclose
  bwipe test15.txt
endf

fun! Test_CT_invalid_gui_value()
  edit test16.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(5, len(l:qflist))
  call assert_equal('Invalid GUI color value', l:qflist[0]['text'])
  call assert_equal(7, l:qflist[0]['lnum'])
  call assert_equal(13, l:qflist[0]['col'])
  call assert_equal("Undefined color name: black", l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[2]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[3]['text'])
  call assert_equal("Please define the Normal highlight group for 2-color variant", l:qflist[4]['text'])
  cclose
  bwipe test16.txt
endf

fun! Test_CT_invalid_gui_value_bis()
  edit test17.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(5, len(l:qflist))
  call assert_equal('Unknown RGB color name: cmyk', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal(13, l:qflist[0]['col'])
  call assert_equal("Undefined color name: black", l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal(14, l:qflist[1]['col'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[2]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[3]['text'])
  call assert_equal("Please define the Normal highlight group for 8-color variant", l:qflist[4]['text'])
  cclose
  bwipe test17.txt
endf

fun! Test_CT_invalid_rgb_values()
  edit test18.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(14, len(l:qflist))
  call assert_equal('Missing opening parenthesis', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal(17, l:qflist[0]['col'])
  call assert_equal('Expected number', l:qflist[1]['text'])
  call assert_equal(9, l:qflist[1]['lnum'])
  call assert_equal(17, l:qflist[1]['col'])
  call assert_equal('RGB red component value is out of range', l:qflist[2]['text'])
  call assert_equal(10, l:qflist[2]['lnum'])
  call assert_equal(17, l:qflist[2]['col'])
  call assert_equal('Missing comma', l:qflist[3]['text'])
  call assert_equal(11, l:qflist[3]['lnum'])
  call assert_equal(18, l:qflist[3]['col'])
  call assert_equal('Expected number', l:qflist[4]['text'])
  call assert_equal(13, l:qflist[4]['lnum'])
  call assert_equal(19, l:qflist[4]['col'])
  call assert_equal('RGB green component value is out of range', l:qflist[5]['text'])
  call assert_equal(14, l:qflist[5]['lnum'])
  call assert_equal(19, l:qflist[5]['col'])
  call assert_equal('Missing comma', l:qflist[6]['text'])
  call assert_equal(15, l:qflist[6]['lnum'])
  call assert_equal(20, l:qflist[6]['col'])
  call assert_equal('Expected number', l:qflist[7]['text'])
  call assert_equal(16, l:qflist[7]['lnum'])
  call assert_equal(21, l:qflist[7]['col'])
  call assert_equal('RGB blue component value is out of range', l:qflist[8]['text'])
  call assert_equal(17, l:qflist[8]['lnum'])
  call assert_equal(21, l:qflist[8]['col'])
  call assert_equal('Missing closing parenthesis', l:qflist[9]['text'])
  call assert_equal(18, l:qflist[9]['lnum'])
  call assert_equal(23, l:qflist[9]['col'])
  call assert_equal("Undefined color name: black", l:qflist[10]['text'])
  call assert_equal(19, l:qflist[10]['lnum'])
  call assert_equal(14, l:qflist[10]['col'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[11]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[12]['text'])
  call assert_equal("Please define the Normal highlight group for 88-color variant", l:qflist[13]['text'])
  cclose
  bwipe test18.txt
endf

fun! Test_CT_base_256_value()
  edit test19.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(4, len(l:qflist))
  call assert_equal('Color value is out of range [0,255]', l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(21, l:qflist[0]['col'])
  call assert_equal('Expected number or tilde', l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal(21, l:qflist[1]['col'])
  call assert_equal("Undefined color name: white", l:qflist[2]['text'])
  call assert_equal(11, l:qflist[2]['lnum'])
  call assert_equal(8, l:qflist[2]['col'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[3]['text'])
  cclose
  bwipe test19.txt
endf

fun! Test_CT_base_16_value()
  edit test20.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Expected number or color name', l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(23, l:qflist[0]['col'])
  call assert_equal('Color value is out of range [0,15]', l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal(23, l:qflist[1]['col'])
  cclose
  bwipe test20.txt
endf

fun! Test_CT_parse_hi_group_def()
  edit test21.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(4, len(l:qflist))
  call assert_equal('Foreground color name missing', l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(11, l:qflist[0]['col'])
  call assert_equal('Background color name missing', l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  call assert_equal(14, l:qflist[1]['col'])
  call assert_equal('Invalid token', l:qflist[2]['text'])
  call assert_equal(12, l:qflist[2]['lnum'])
  call assert_equal(18, l:qflist[2]['col'])
  call assert_equal('Invalid token', l:qflist[3]['text'])
  call assert_equal(13, l:qflist[3]['lnum'])
  call assert_equal(18, l:qflist[3]['col'])
  cclose
  bwipe test21.txt
endf

fun! Test_CT_attributes_ok()
  edit test22.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test22.txt
endf

fun! Test_CT_attributes_errors()
  edit test23.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(7, len(l:qflist))
  call assert_equal('Invalid attributes', l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(19, l:qflist[0]['col'])
  call assert_equal('Invalid attributes', l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  call assert_equal(19, l:qflist[1]['col'])
  call assert_equal('Invalid attribute list', l:qflist[2]['text'])
  call assert_equal(12, l:qflist[2]['lnum'])
  call assert_equal(24, l:qflist[2]['col'])
  call assert_equal('Invalid attribute list', l:qflist[3]['text'])
  call assert_equal(13, l:qflist[3]['lnum'])
  call assert_equal(24, l:qflist[3]['col'])
  call assert_equal("Expected = symbol after 'term'", l:qflist[4]['text'])
  call assert_equal(14, l:qflist[4]['lnum'])
  call assert_equal(20, l:qflist[4]['col'])
  call assert_equal('Invalid attribute', l:qflist[5]['text'])
  call assert_equal(15, l:qflist[5]['lnum'])
  call assert_equal(21, l:qflist[5]['col'])
  call assert_equal("Expected = symbol after 'gui'", l:qflist[6]['text'])
  call assert_equal(16, l:qflist[6]['lnum'])
  call assert_equal(20, l:qflist[6]['col'])
  cclose
  bwipe test23.txt
endf

fun! Test_CT_parse_linked_group_ok()
  edit test24.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test24.txt
endf

fun! Test_CT_parse_linked_group_errors()
  edit test25.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal('Expected highlight group name', l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(14, l:qflist[0]['col'])
  call assert_equal('Expected ->', l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  call assert_equal(14, l:qflist[1]['col'])
  call assert_equal('Expected highlight group name', l:qflist[2]['text'])
  call assert_equal(12, l:qflist[2]['lnum'])
  call assert_equal(17, l:qflist[2]['col'])
  cclose
  bwipe test25.txt
endf

fun! Test_CT_minimal()
  edit test27.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test27.txt
endf

fun! Test_CT_verbatim_interpolation()
  edit test28.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test28.txt
endf

fun! Test_CT_wrong_keyword_in_doc()
  edit test29.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("Undefined @ value", l:qflist[0]['text'])
  call assert_equal(7, l:qflist[0]['lnum'])
  call assert_equal(1, l:qflist[0]['col'])
  cclose
  bwipe test29.txt
endf

fun! Test_CT_keyword_followed_by_underscore_in_doc()
  edit test30.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test30.txt
endf

fun! Test_CT_empty_short_name()
  edit test31.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal("Metadata value cannot be empty", l:qflist[0]['text'])
  call assert_equal("Please specify the short name of your color scheme", l:qflist[1]['text'])
  cclose
  bwipe test31.txt
endf

fun! Test_CT_invalid_short_name()
  edit test32.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("The short name may contain only letters, numbers and underscore", l:qflist[0]['text'])
  call assert_equal(3, l:qflist[0]['lnum'])
  call assert_equal(11, l:qflist[0]['col'])
  cclose
  bwipe test32.txt
endf

fun! Test_CT_commented_hex_color()
  edit test33.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test33.txt
endf

fun! Test_CT_comments_after_hi_group_defs()
  edit test34.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test34.txt
endf

fun! Test_CT_color_already_defined()
  edit test35.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("Color already defined for dark background", l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(25, l:qflist[0]['col'])
  cclose
  bwipe test35.txt
endf
"
fun! Test_CT_color_def_before_background_is_set()
  edit test36.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Undefined color name: black', l:qflist[0]['text'])
  call assert_equal(14, l:qflist[0]['lnum'])
  call assert_equal(19, l:qflist[0]['col'])
  cclose
  bwipe test36.txt
endf

fun! Test_CT_background_selected_twice()
  edit test37.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test37.txt
endf

fun! Test_CT_template_with_included_files()
  edit test38a.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test38a.txt
endf

fun! Test_CT_error_in_included_file()
  edit test39a.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Undefined color name: pink', l:qflist[0]['text'])
  call assert_equal('test39b.txt', bufname(l:qflist[0]['bufnr']))
  call assert_equal(6, l:qflist[0]['lnum'])
  call assert_equal(14, l:qflist[0]['col'])
  cclose
  bwipe test39a.txt
endf

fun! Test_CT_short_name_too_long()
  edit test40.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("The short name must be at most 24 characters long", l:qflist[0]['text'])
  call assert_equal(3, l:qflist[0]['lnum'])
  call assert_equal(11, l:qflist[0]['col'])
  cclose
  bwipe test40.txt
endf

fun! Test_CT_comment_after_base256_color()
  edit test41.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test41.txt
endf

fun! Test_CT_colors_from_rgb_txt()
  edit test42.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test42.txt
endf

fun! Test_CT_trailing_spaces_are_skipped()
  edit test43.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test43.txt
endf

fun! Test_CT_first_line_of_included_file_is_not_skipped()
  edit test44a.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test44a.txt
endf

fun! Test_CT_check_for_missing_short_name()
  edit test45.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Please specify the short name of your color scheme', l:qflist[0]['text'])
  cclose
  bwipe test45.txt
endf

fun! Test_CT_include_empty_file()
  edit test46a.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test46a.txt
endf

" Palette keyword no longer supported in v2.0.0
fun! Test_CT_use_vimspectr_palette()
  edit test47.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Unknown key: palette', l:qflist[0]['text'])
  cclose
  bwipe test47.txt
endf

fun! Test_CT_multiple_nested_inclusions()
  edit test48a.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal("Unexpected token at start of line", l:qflist[0]['text'])
  call assert_equal(4, l:qflist[0]['lnum'])
  call assert_equal(3, l:qflist[0]['col'])
  call assert_equal("Unexpected token at start of line", l:qflist[1]['text'])
  call assert_equal(9, l:qflist[1]['lnum'])
  call assert_equal(6, l:qflist[1]['col'])
  cclose
  bwipe test48a.txt
endf

fun! Test_CT_sequential_inclusions()
  edit test49a.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("Unexpected token at start of line", l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(6, l:qflist[0]['col'])
  cclose
  bwipe test49a.txt
endf

" If terminal colors are not defined, v2.0.0 raises only a warning
fun! Test_CT_terminal_ansi_colors_not_defined()
  edit test50a.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test50a.txt
endf

" Ditto
fun! Test_CT_terminal_ansi_colors_defined_verbatim()
  edit test50b.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test50b.txt
endf

fun! Test_CT_rgb_color_names_stats_issue_12()
  edit test51.txt
  " ColortemplateStats parses the file: parsing should not give errors
  ColortemplateStats
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  wincmd c " Stat scratch buffer
  bwipe test51.txt
endf

fun! Test_CT_out_of_range_base256_colors()
  edit test52.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(4, len(l:qflist))
  call assert_equal("Color value is out of range [0,255]", l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(21, l:qflist[0]['col'])
  call assert_equal("Undefined color name: white", l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  call assert_equal(8, l:qflist[1]['col'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[2]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[3]['text'])
  cclose
  bwipe test52.txt
endf

fun! Test_CT_colon_in_comment_is_not_kv_pair()
  edit test53.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  bwipe test53.txt
endf

fun! Test_CT_color_typo()
  edit test54.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Invalid attribute', l:qflist[0]['text'])
  call assert_equal(17, l:qflist[0]['lnum'])
  call assert_equal(25, l:qflist[0]['col'])
  cclose
  bwipe test54.txt
endf

fun! Test_CT_color_typo()
  edit test57.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Cannot define highlight group before Variant or Background is set', l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(24, l:qflist[0]['col'])
  cclose
  bwipe test57.txt
endf

fun! Test_CT_conditional_commands()
  edit test58.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test58')
  bwipe test58.txt
endf

fun! Test_CT_italic_is_flushed_before_command()
  edit test59.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test59')
  bwipe test59.txt
endf

fun! Test_CT_let_unlet()
  edit test60.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test60')
  bwipe test60.txt
endf

fun! Test_CT_global_interpolation()
  edit test61.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test61')
  bwipe test61.txt
endf

fun! Test_CT_call_command()
  edit test63.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test63')
  bwipe test63.txt
endf

fun! Test_CT_if_in_multiple_variants()
  edit test64.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test64')
  bwipe test64.txt
endf

fun! Test_CT_guifg_guibg_none()
  edit test65.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test65')
  bwipe test65.txt
endf

fun! Test_CT_unbalanced_if()
  edit test66.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('#if without #endif', l:qflist[0]['text'])
  cclose
  bwipe test66.txt
endf

fun! Test_CT_include_without_suffix()
  edit test68a.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify('test68')
  bwipe test68a.txt
endf

fun! Test_CT_undefined_base16_value()
  edit test69.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Base-16 value undefined for color black', l:qflist[0]['text'])
  cclose
  bwipe test69.txt
endf

let s:old_warnings  = get(g:, 'colortemplate_warnings',       -1)
let s:old_creator   = get(g:, 'colortemplate_creator',        -1)
let s:old_timestamp = get(g:, 'colortemplate_timestamp',      -1)
let s:old_comment   = get(g:, 'colortemplate_source_comment', -1)
let g:colortemplate_warnings       = 0
let g:colortemplate_timestamp      = 0
let g:colortemplate_creator        = 0
let g:colortemplate_source_comment = 0

call RunBabyRun('CT')

if s:old_warnings == -1
  unlet g:colortemplate_warnings
else
  let g:colortemplate_warnings = s:old_warnings
endif
if s:old_creator == -1
  unlet g:colortemplate_creator
else
  let g:colortemplate_creator = s:old_creator
endif
if s:old_timestamp == -1
  unlet g:colortemplate_timestamp
else
  let g:colortemplate_timestamp = s:old_timestamp
endif
if s:old_comment == -1
  unlet g:colortemplate_source_comment
else
  let g:colortemplate_source_comment = s:old_comment
endif
unlet s:old_warnings s:old_creator s:old_timestamp s:old_comment

call delete(s:colordir, "d") " Delete if empty
call delete(s:docdir, "rf")

