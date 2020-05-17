if exists('g:loaded_autoload_easy_replace')
  finish
endif

let g:loaded_autoload_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

fun! easy_replace#replace(context)
  let l:line_start = get(a:context['line'], 'start', -1)
  let l:line_end = get(a:context['line'], 'end', -1)
  let l:range = l:line_start != -1 && l:line_end != -1 ?
    \ l:line_start . ',' . l:line_end :
    \ '%'

  try
    exe ':' . l:range . 's/' . a:context.pattern . '/' . a:context.replace . '/g'
  catch
    redraw
    echo 'Failed replace.'
  endtry

endfun

fun! easy_replace#highlight(context)
  if a:context.pattern == ''
    match none
    return
  endif

  exe 'highlight EasyReplace ctermbg=' . g:easy_replace_highlight_ctermbg . ' guibg=' . g:easy_replace_highlight_guibg
  let l:line_start = get(a:context['line'], 'start', -1)
  let l:line_end = get(a:context['line'], 'end', -1)
  let l:range = l:line_start != -1 && l:line_end != -1 ?
    \ '\%>' . (l:line_start - 1) . 'l\%<' . (l:line_end + 1) . 'l':
    \ ''

  try
    exe 'match EasyReplace /' . l:range . a:context.pattern . '/'
  catch
  endtry
endfun

let &cpo = s:save_cpo
