if exists('g:loaded_autoload_easy_replace')
  finish
endif

let g:loaded_autoload_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

fun! easy_replace#replace(context)
  let l:line = get(a:, 2, [])
  let l:range = len(l:line) != 0 ?
    \ l:line[0] . ',' . l:line[1] :
    \ '%'

  try
    exe ':' . l:range . 's/' . a:context.pattern . '/' . a:context.replace . '/g'
  catch
    redraw
    echo 'Failed replace.'
  endtry

endfun

fun! easy_replace#highlight(context)
  highlight EasyReplace ctermbg=green guibg=green
  try
    exe 'match EasyReplace /' . a:context.pattern . '/'
  catch
  endtry
endfun

let &cpo = s:save_cpo
