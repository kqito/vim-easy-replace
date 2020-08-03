if exists('g:loaded_autoload_easy_replace')
  finish
endif

let g:loaded_autoload_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

let s:context = {}

const s:mode_pattern = 'pattern'
const s:mode_replace = 'replace'

fun! easy_replace#start(current_word, line)
  if has_key(s:context, "easy_replace_window_id") && win_gotoid(s:context.easy_replace_window_id)
    let context = s:context.mode == s:mode_pattern ?
      \ s:context.pattern :
      \ s:context.replace

    " Insert pattern if current word is read
    call setline(".", context)

    startinsert!
  else
    let s:context = easy_replace#generate_context(a:current_word, a:line)
    call easy_replace#create_window()
  endif

  call easy_replace#echo_status()
  call easy_replace#highlight()
endfun

fun! easy_replace#generate_context(current_word, line)
  let l:line_start = get(a:line, 'start', -1)
  let l:line_end = get(a:line, 'end', -1)

  let context = {}
  let context.pattern = a:current_word
  let context.replace = ''
  let context.replace_range = l:line_start != -1 && l:line_end != -1 ?
    \ l:line_start . ',' . l:line_end :
    \ '%'
  let context.highlight_range = l:line_start != -1 && l:line_end != -1 ?
    \ '\%>' . (l:line_start - 1) . 'l\%<' . (l:line_end + 1) . 'l':
    \ ''
  let context.mode = s:mode_pattern
  let context.origin_window_id = win_getid()
  let context.easy_replace_window_id = 0

  return context
endfun

fun! easy_replace#replace()
  let l:replace = s:context.replace_range . 's/' . s:context.pattern . '/' . s:context.replace . '/g'

  redraw

  call easy_replace#exit()

  try
    exe ':' . l:replace

    if g:easy_replace_add_history
      call histadd(':', l:replace)
    endif
  catch
    echo 'Failed replace.'
  endtry
endfun

fun! easy_replace#highlight()
  exe 'highlight EasyReplace ctermbg=' . g:easy_replace_highlight_ctermbg . ' guibg=' . g:easy_replace_highlight_guibg

  try
    call win_gotoid(s:context.origin_window_id)
    if s:context.pattern != ""
      exe 'match EasyReplace /' . s:context.highlight_range . s:context.pattern . '/'
    else
      match none
    endif

    call win_gotoid(s:context.easy_replace_window_id)
  catch
    echo v:exception
    call easy_replace#exit()
  endtry
endfun

fun! easy_replace#update_char()
  let char = getline(".")

  if s:context.mode == s:mode_pattern
    let s:context.pattern = char
    call easy_replace#highlight()
  else
    let s:context.replace = char
  endif

endfun

fun! easy_replace#next_mode()
  call win_gotoid(s:context.easy_replace_window_id)
  if &filetype != 'easy_replace'
    return
  endif

  if s:context.mode == s:mode_pattern
    let s:context.mode = s:mode_replace
    normal! ggdG
    startinsert
    call easy_replace#echo_status()
    return
  endif

  call easy_replace#replace()
endfun

fun! easy_replace#exit()
  if &filetype != 'easy_replace'
    return
  endif

  stopinsert
  bwipeout!

  " Go back origin window
  call win_gotoid(s:context.origin_window_id)

  match none
endfun

fun! easy_replace#register_map()
  inoremap <buffer> <silent> <ESC> <ESC>:call easy_replace#exit()<CR>
  inoremap <buffer> <silent> <CR> <ESC>:call easy_replace#next_mode()<CR>
endfun

fun! easy_replace#create_window()
  bo 1new
  call easy_replace#register_map()
  let s:context.easy_replace_window_id = win_getid()
  set filetype=easy_replace
  setl nonumber
  set bufhidden=wipe

  " Insert pattern if current word is read
  call setline(".", s:context.pattern)

  startinsert!
endfun

fun! easy_replace#echo_status()
  echon s:context.mode == s:mode_pattern ?
    \ '[easy-replace] pattern mode':
    \ '[easy-replace] replace mode'
endfun

let &cpo = s:save_cpo
