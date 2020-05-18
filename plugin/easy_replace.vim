if exists("g:loaded_easy_replace")
  finish
endif

let g:loaded_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

const s:default_launch_key = '<Leader>ra'
const s:default_launch_word_key = '<Leader>rc'
const s:default_launch_in_visual_key = '<Leader>ra'
const s:default_launch_word_in_visual_key = '<Leader>rc'

let g:easy_replace_enable = get(g:, 'easy_replace_enable', 1)
let g:easy_replace_launch_key = get(g:, 'easy_replace_launch_key', s:default_launch_key)
let g:easy_replace_launch_word_key = get(g:, 'easy_replace_launch_word_key', s:default_launch_word_key)
let g:easy_replace_launch_in_visual_key = get(g:, 'easy_replace_launch_in_visual_key', s:default_launch_in_visual_key)
let g:easy_replace_launch_word_in_visual_key = get(g:, 'easy_replace_launch_word_in_visual_key', s:default_launch_word_in_visual_key)
let g:easy_replace_highlight_ctermbg = get(g:, 'easy_replace_highlight_ctermbg', 'green')
let g:easy_replace_highlight_guibg = get(g:, 'easy_replace_highlight_guibg', 'green')
let g:easy_replace_add_history = get(g:, 'easy_replace_add_history', 1)

let s:code_list = {
  \  'enter':        char2nr("\<CR>"),
  \  'escape':       char2nr("\<Esc>"),
  \  'ctrl-u':       char2nr("\<C-u>"),
  \  'backspace':    "\<BS>",
  \  'delete':       "\<DEL>",
\  }

com! EasyReplaceWord call s:replaceWord('')
com! EasyReplaceWordInVisual call s:replaceWord('', s:get_line())
com! EasyReplaceCurrentWord call s:replaceWord(s:get_current_word())
com! EasyReplaceCurrentWordInVisual call s:replaceWord(s:get_current_word(), s:get_line())

exe 'nnoremap ' . g:easy_replace_launch_key .                         ' :EasyReplaceWord<CR>'
exe 'nnoremap ' . g:easy_replace_launch_word_key .            ' :EasyReplaceCurrentWord<CR>'
exe 'vnoremap ' . g:easy_replace_launch_in_visual_key .               ' <Esc>:EasyReplaceWordInVisual<CR>'
exe 'vnoremap ' . g:easy_replace_launch_word_in_visual_key .  ' <Esc>:EasyReplaceCurrentWordInVisual<CR>'

fun! s:replaceWord(...)
  if g:easy_replace_enable == 0
    return
  endif

  let l:current_word = get(a:, 1, '')
  let l:line = get(a:, 2, {})

  let context = easy_replace#generate_context(l:current_word, l:line)

  if context.pattern != ''
    call easy_replace#highlight(context)
  endif

  redraw

  while 1
    call context.echo_message()

    let c = getchar()

    if c == s:code_list['enter']
      let isFinish = context.next_mode()
      if isFinish == 1
        break
      endif
    elseif c == s:code_list['backspace'] || c == s:code_list['delete']
      call context.remove_char()
    elseif c == s:code_list['ctrl-u']
      call context.remove_all_char()
    elseif c == s:code_list['escape']
      redraw
      echo "Canceled!"
      break
    else
      call context.add_char(c)
    endif

    call easy_replace#highlight(context)

    redraw
  endwhile

  match none

endfun

fun! s:get_current_word()
  let line = line(".")
  let col  = col(".")
  return expand("<cword>")
endfun

fun! s:get_line()
  normal `<
  let l:start = line(".")

  normal `>
  let l:end = line(".")

  let l:line = {
    \ 'start': l:start,
    \ 'end': l:end,
  \ }

  return l:line
endfun

let &cpo = s:save_cpo
