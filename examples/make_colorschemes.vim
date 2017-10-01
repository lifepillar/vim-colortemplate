" Source this script to parse all the templates in the templates folder and
" generate corresponding colorschemes in the colors folder.
" Note: existing files in the colors folder are overridden.

let s:curdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:errors = 0

for s:template in glob(s:curdir . '/templates/*.txt', 1, 1)
  let s:template_name = fnamemodify(s:template, ':t:r')
  execute "edit" s:template
  execute "Colortemplate!" s:curdir . '/colors/' . s:template_name . '.vim'
  if g:colortemplate_exit_status != 0
    echohl Error
    echomsg 'ERROR:' s:template_name 'could not be built'
    echohl None
    let s:errors = 1
  endif
endfor

if s:errors > 0
  redraw
  echo "\r"
  echohl Error
  echomsg "There were errors: see messages"
  echohl None
endif
