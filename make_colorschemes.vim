" Source this script to parse all the templates in the templates folder except
" for the default ones ({dark,dark_and_light,light}.colortemplate) and
" default_clone.colortemplate. Generate corresponding colorschemes in the
" colors folder of this plugin (the colors folder will be created if it does
" not exist).
" Note: existing files in the colors folder are overridden.

let s:curdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:errors = 0
let s:exceptions = ['dark', 'dark_and_light', 'light', 'default_clone']

execute 'lcd' s:curdir

for s:template in glob(s:curdir . '/templates/[a-z]*.colortemplate', 1, 1)
  let s:template_name = fnamemodify(s:template, ':t:r')
  if index(s:exceptions, s:template_name) > -1
    next
  endif
  execute "edit" s:template
  execute "Colortemplate!" fnameescape(s:curdir . '/colors')
  if g:colortemplate_exit_status != 0
    echoerr 'ERROR:' s:template_name 'could not be built'
    let s:errors = 1
  endif
endfor

if s:errors > 0
  redraw
  echo "\r"
  echoerr "There were errors: see messages"
endif
