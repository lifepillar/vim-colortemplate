"
" The tests
"

fun! Test_CT_fine()
  call s:assert_build('test1')
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
  call assert_equal("'none' is a reserved name and cannot be overridden", l:qflist[0]['text'])
  call assert_equal(7, l:qflist[0]['lnum'])
  call assert_equal(8, l:qflist[0]['col'])
  call assert_equal("'fg' is a reserved name and cannot be overridden", l:qflist[1]['text'])
  call assert_equal(8, l:qflist[1]['lnum'])
  call assert_equal(9, l:qflist[1]['col'])
  call assert_equal("'bg' is a reserved name and cannot be overridden", l:qflist[2]['text'])
  call assert_equal(9, l:qflist[2]['lnum'])
  call assert_equal(7, l:qflist[2]['col'])
  cclose
  bwipe test4.txt
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
  call assert_equal("Please define the Normal highlight group for 0-color variant", l:qflist[4]['text'])
  cclose
  bwipe test16.txt
endf

fun! Test_CT_invalid_gui_value_bis()
  edit test17.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(5, len(l:qflist))
  call assert_equal('Expected number or tilde', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal(17, l:qflist[0]['col'])
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

fun! Test_CT_doc_interpolation()
  call s:assert_build('test29')
  " Check help file
  let l:fail = assert_equalfile(s:testdir.'/expected/test29.txt', s:testdir.'/doc/test29.txt')
  if !l:fail
    call delete(s:testdir.'/doc/test29.txt')
  endif
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
  call assert_equal("The short name may contain only letters, numbers, underscores, and hyphens", l:qflist[0]['text'])
  call assert_equal(3, l:qflist[0]['lnum'])
  call assert_equal(11, l:qflist[0]['col'])
  cclose
  bwipe test32.txt
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

fun! Test_CT_error_in_included_file()
  edit test39a.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Undefined color name: pink', l:qflist[0]['text'])
  call assert_equal('test39b.txt', bufname(l:qflist[0]['bufnr']))
  call assert_equal(5, l:qflist[0]['lnum'])
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

fun! Test_CT_check_for_missing_short_name()
  edit test45.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Please specify the short name of your color scheme', l:qflist[0]['text'])
  cclose
  bwipe test45.txt
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
  call assert_equal(3, l:qflist[0]['lnum'])
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

fun! Test_CT_rgb_color_names_stats_issue_12()
  edit test51.txt
  " ColortemplateStats parses the file: parsing should not give errors
  ColortemplateStats
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  execute 'write' s:testdir.'/colors/test51.txt'
  let l:fail = assert_equalfile(s:testdir.'/expected/test51.txt', s:testdir.'/colors/test51.txt')
  if !l:fail
    call delete(s:testdir.'/colors/test51.txt')
  endif
  wincmd c " Wipe out stat scratch buffer
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

fun! Test_CT_unbalanced_if()
  edit test66.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('#if without #endif', l:qflist[0]['text'])
  cclose
  bwipe test66.txt
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


fun! Test_CT_vacuous_hi_group()
  edit test71.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Vacuous definition for Normal (8 colors, dark background)', l:qflist[0]['text'])
  call assert_equal('Vacuous definition for CursorLine (0 colors, dark background)', l:qflist[1]['text'])
  cclose
  bwipe test71.txt
endf

fun! Test_CT_linked_group_with_multiple_tokens()
  edit test75.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Extra token in linked group definition', l:qflist[0]['text'])
  call assert_equal(11, l:qflist[0]['lnum'])
  call assert_equal(13, l:qflist[0]['col'])
  call assert_equal('Extra token in linked group definition', l:qflist[1]['text'])
  call assert_equal(13, l:qflist[1]['lnum'])
  call assert_equal(20, l:qflist[1]['col'])
  cclose
  bwipe test75.txt
endf

fun! Test_CT_ambiguous_hi_group_color_definition()
  edit test85.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Ambiguous definition: must be in the scope of `Background: dark` or `Background: light`', l:qflist[0]['text'])
  call assert_equal(14, l:qflist[0]['lnum'])
  call assert_equal(8, l:qflist[0]['col'])
  call assert_equal('Please define the Normal highlight group for true-color variant', l:qflist[1]['text'])
  call assert_equal(1, l:qflist[1]['lnum'])
  call assert_equal(1, l:qflist[1]['col'])
  cclose
  bwipe test85.txt
endf

" Verify that a color scheme can be loaded with compatible set (-C)
fun! Test_CT_compatible_set()
  edit test86.txt
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  let l:opt = " -C -m -n -u NONE -i NONE --not-a-term --noplugin -c 'source " .. s:testdir .. "/colors/test86.vim' -c 'quit!'"
  call assert_notmatch('E10', system(v:progpath .. l:opt))
  call delete(s:testdir .. '/colors/test86.vim')
  bwipe test86.txt
endf

" See also: https://github.com/lifepillar/vim-colortemplate/issues/48
fun! Test_CT_working_dir_is_not_changed()
  try
    edit test87/test87.txt
    let l:wd = getcwd()
    Colortemplate!
    call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
    call assert_equal(l:wd, getcwd())
    bwipe test87.txt
  finally
    execute 'lcd' s:testdir
    call delete(s:testdir . '/test87/colors/test87.vim')
    call delete(s:testdir . '/test87/colors/', 'd')
  endtry
endf

" See https://github.com/lifepillar/vim-colortemplate/issues/51
fun! Test_CT_wiping_source_should_not_fail_with_E94()
  try
    edit test88.txt
    Colortemplate!
    call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
    edit colors/test88.vim
    buffer #
    Colortemplate!
    call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
    buffer #
    buffer #
    Colortemplate!
    call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  finally
    bwipe colors/test88.vim
    bwipe test88.txt
    call delete(s:testdir .. '/colors/test88.vim')
  endtry
endf


"
" Runner!
"
let s:exit = RunBabyRun('CT')

call delete(s:colordir, "d") " Delete if empty
call delete(s:docdir, "rf")

if get(g:, 'autotest', 0)
  if s:exit > 0
    execute "write >>" s:testdir.'/test.log'
    cquit
  else
    call delete(s:testdir.'/test.log')
    qall!
  endif
endif

" vim: nowrap et ts=2 sw=2
