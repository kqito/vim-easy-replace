if exists('g:loaded_autoload_easy_replace')
  finish
endif

let g:loaded_autoload_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

const s:mode_pattern = 'pattern'
const s:mode_replace = 'replace'

fun! easy_replace#replace()
  let context = g:easy_replace_context

  let l:line_start = get(context['line'], 'start', -1)
  let l:line_end = get(context['line'], 'end', -1)
  let l:range = l:line_start != -1 && l:line_end != -1 ?
    \ l:line_start . ',' . l:line_end :
    \ '%'
  let l:replace = l:range . 's/' . context.pattern . '/' . context.replace . '/g'

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
  let context = g:easy_replace_context
  if context.pattern == ''
    match none
    return
  endif

  exe 'highlight EasyReplace ctermbg=' . g:easy_replace_highlight_ctermbg . ' guibg=' . g:easy_replace_highlight_guibg
  let l:line_start = get(context['line'], 'start', -1)
  let l:line_end = get(context['line'], 'end', -1)
  let l:range = l:line_start != -1 && l:line_end != -1 ?
    \ '\%>' . (l:line_start - 1) . 'l\%<' . (l:line_end + 1) . 'l':
    \ ''

  try
    call win_gotoid(context.origin_window_id)
    exe 'match EasyReplace /' . l:range . context.pattern . '/'
    call win_gotoid(context.easy_replace_window_id)
  catch
    echo v:exception
    call easy_replace#exit()
  endtry
endfun

fun! easy_replace#update_char(char)
  let char = getline(".") . a:char
  call g:easy_replace_context.add_char(char)
endfun

fun! easy_replace#next_mode()
  call g:easy_replace_context.next_mode()
endfun

fun! easy_replace#exit()
  if &filetype != 'easy_replace'
    return
  endif

  stopinsert
  bwipeout!

  " Go back origin window
  let context = g:easy_replace_context
  call win_gotoid(context.origin_window_id)

  match none
endfun

fun! easy_replace#register_map()
  inoremap <buffer> <silent> <ESC> <ESC>:call easy_replace#exit()<CR>
  inoremap <buffer> <silent> <CR> <ESC>:call easy_replace#next_mode()<CR>
endfun

fun! easy_replace#generate_context(current_word, line)
  let context = {}
  let context.pattern = a:current_word
  let context.replace = ''
  let context.line = a:line
  let context.mode = s:mode_pattern
  let context.origin_window_id = 0
  let context.easy_replace_window_id = 0

  fun! context.get_target()
    return self.mode == s:mode_pattern ? self.pattern : self.replace
  endfun

  fun! context.update(char)
    if self.mode == s:mode_pattern
      let self.pattern = a:char
    else
      let self.replace = a:char
    endif
  endfun

  fun! context.add_char(char)
    call self.update(a:char)
    call easy_replace#highlight()
  endfun

  fun! context.next_mode()
    call win_gotoid(self.easy_replace_window_id)
    if &filetype != 'easy_replace'
      return
    endif

    if self.mode == s:mode_pattern
      let self.mode = s:mode_replace
      silent normal! ggdG
      silent file \[easy-replace\] replace mode
      startinsert
      return
    endif

    call easy_replace#replace()
  endfun

  fun! context.start()
    let self.origin_window_id = win_getid()

    bo 1new
    call easy_replace#register_map()
    let self.easy_replace_window_id = win_getid()
    set filetype=easy_replace
    setl nonumber
    set bufhidden=wipe
    silent file \[easy-replace\] target mode

    " Insert pattern if current word is read
    call setline(".", self.pattern)

    startinsert!

    call easy_replace#highlight()
  endfun

  return context
endfun

let &cpo = s:save_cpo
