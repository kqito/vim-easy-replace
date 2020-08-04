""
" @section Introduction, intro
" easy-reaplace is a plugin that makes it easy to perform replacements.
" It highlights the replacement target in real time, allowing you to do interactive replacements.
" By default, you can use "<Leader>ra" for easy-replace


if exists("g:loaded_easy_replace")
  finish
endif

let g:loaded_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

const s:default_launch_key = '<Leader>ra'
const s:default_launch_cword_key = '<Leader>rc'
const s:default_launch_in_visual_key = '<Leader>ra'
const s:default_launch_cword_in_visual_key = '<Leader>rc'

""
" Enable easy-replace. (If set 0, easy-replace will not work.)
let g:easy_replace_enable =
  \ get(g:, 'easy_replace_enable', 1)

""
" Key to launch easy_replace
let g:easy_replace_launch_key =
  \ get(g:, 'easy_replace_launch_key', s:default_launch_key)

""
" Key to launch in visual mode easy_replace
let g:easy_replace_launch_cword_key =
  \ get(g:, 'easy_replace_launch_cword_key', s:default_launch_cword_key)

""
" Key to replace the word under the cursor with "easy_replace".
let g:easy_replace_launch_in_visual_key =
  \ get(g:, 'easy_replace_launch_in_visual_key', s:default_launch_in_visual_key)

""
"	Key to replace the word under the cursor in visual mode with "easy_replace".
let g:easy_replace_launch_cword_in_visual_key =
  \ get(g:, 'easy_replace_launch_cword_in_visual_key', s:default_launch_cword_in_visual_key)

""
" Color for highlighting the replacement target.
let g:easy_replace_highlight_ctermbg =
  \ get(g:, 'easy_replace_highlight_ctermbg', 'green')

""
" Color for highlighting the replacement target.
let g:easy_replace_highlight_guibg =
  \ get(g:, 'easy_replace_highlight_guibg', 'green')

""
" Leave the replace command in the command line history after the replacement.
let g:easy_replace_add_history =
  \ get(g:, 'easy_replace_add_history', 1)

""
" Start replacing with the easy replace plugin.
com! EasyReplaceWord call s:replaceWord('', {})

""
" Start replacing with the easy replace plugin;
" unlike the EasyReplaceWord command,
" it will start replacing with the word under the current cursor set as the target.
com! EasyReplaceWordInVisual call s:replaceWord('', s:get_line())

""
" Start replacing the selected line in visual mode with the easy replace plugin.
com! EasyReplaceCword call s:replaceWord(s:get_current_word(), {})

""
" Start replacing the selected line in visual mode with the easy replace plugin.
" unlike the EasyReplaceCword command,
" it will start replacing with the word under the current cursor set as the target.
com! EasyReplaceCwordInVisual call s:replaceWord(s:get_current_word(), s:get_line())


exe 'nnoremap ' . g:easy_replace_launch_key .                 ' :EasyReplaceWord<CR>'
exe 'nnoremap ' . g:easy_replace_launch_cword_key .            ' :EasyReplaceCword<CR>'
exe 'vnoremap ' . g:easy_replace_launch_in_visual_key .       ' <Esc>:EasyReplaceWordInVisual<CR>'
exe 'vnoremap ' . g:easy_replace_launch_cword_in_visual_key .  ' <Esc>:EasyReplaceCwordInVisual<CR>'

fun! s:replaceWord(...)
  if g:easy_replace_enable == 0
    return
  endif

  let l:current_word = get(a:, 1, '')
  let l:line = get(a:, 2, {})

  call easy_replace#start(l:current_word, l:line)
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
