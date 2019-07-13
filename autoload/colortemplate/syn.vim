" Returns the background color of the given highlight group, as a two-element
" array containing the cterm and the gui entry.
fun! colortemplate#syn#hi_group_bg(hl)
  return [synIDattr(synIDtrans(hlID(a:hl)), "bg", "cterm"), synIDattr(synIDtrans(hlID(a:hl)), "bg", "gui")]
endf

" Ditto, for the foreground color.
fun! colortemplate#syn#hi_group_fg(hl)
  return [synIDattr(synIDtrans(hlID(a:hl)), "fg", "cterm"), synIDattr(synIDtrans(hlID(a:hl)), "fg", "gui")]
endf

" Prints information about the highlight group at the cursor position.
" See: http://vim.wikia.com/wiki/VimTip99 and hilinks.vim script.
fun! colortemplate#syn#hi_group()
  let trans = synIDattr(synID(line("."), col("."), 0), "name")
  let synid = synID(line("."), col("."), 1)
  let higrp = synIDattr(synid, "name")
  let synid = synIDtrans(synid)
  let logrp = synIDattr(synid, "name")
  let fgcol = [synIDattr(synid, "fg", "cterm"), synIDattr(synid, "fg", "gui")]
  let bgcol = [synIDattr(synid, "bg", "cterm"), synIDattr(synid, "bg", "gui")]
  try " The following may raise an error, e.g., if CtrlP is opened while this is active
    execute "hi!" "ColortemplateInfoFg" "ctermbg=".(empty(fgcol[0])?"NONE":fgcol[0]) "guibg=".(empty(fgcol[1])?"NONE":fgcol[1])
    execute "hi!" "ColortemplateInfoBg" "ctermbg=".(empty(bgcol[0])?"NONE":bgcol[0]) "guibg=".(empty(bgcol[1])?"NONE":bgcol[1])
  catch /^Vim\%((\a\+)\)\=:E254/ " Cannot allocate color
    hi clear ColortemplateInfoFg
    hi clear ColortemplateInfoBg
  endtry
  echo join(map(reverse(synstack(line("."), col("."))), {i,v -> synIDattr(v, "name")}), " ⊂ ")
  execute "echohl" logrp | echon " xxx " | echohl None
  echon (higrp != trans ? "T:".trans." → ".higrp : higrp) . (higrp != logrp ? " → ".logrp : "")." "
  echohl ColortemplateInfoFg | echon "  " | echohl None
  echon " fg=".join(fgcol, "/")." "
  echohl ColortemplateInfoBg | echon "  " | echohl None
  echon " bg=".join(bgcol, "/")
endf

fun! colortemplate#syn#toggle()
  if exists("#colortemplate_syn_info")
    autocmd! colortemplate_syn_info
    augroup! colortemplate_syn_info
  else
    augroup colortemplate_syn_info
      autocmd CursorMoved * call colortemplate#syn#hi_group()
    augroup END
  endif
endf

" vim: foldmethod=marker nowrap et ts=2 sw=2
