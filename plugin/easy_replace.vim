if exists("g:loaded_easy_replace")
  finish
endif

let g:loaded_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

const s:default_replace_key = '<Leader>ra'
const s:default_replace_current_key = '<Leader>rc'
const s:mode_pattern = 'pattern'
const s:mode_replace = 'replace'

let g:easy_replace_key = get(g:, 'default_start_key', s:default_replace_key)
let g:easy_replace_current_key = get(g:, 'default_start_key', s:default_replace_current_key)
let g:easy_replace_enable = get(g:, 'easy_replace_enable', 1)
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
com! EasyReplaceWordInVisual call s:replaceWord('', s:getLine())
com! EasyReplaceCurrentWord call s:replaceWord(s:getCurrentWord())
com! EasyReplaceCurrentWordInVisual call s:replaceWord(s:getCurrentWord(), s:getLine())

exe 'nnoremap ' . g:easy_replace_key .            ' :EasyReplaceWord<CR>'
exe 'nnoremap ' . g:easy_replace_current_key .    ' :EasyReplaceCurrentWord<CR>'
exe 'vnoremap ' . g:easy_replace_key .            ' <Esc>:EasyReplaceWordInVisual<CR>'
exe 'vnoremap ' . g:easy_replace_current_key .    ' <Esc>:EasyReplaceCurrentWordInVisual<CR>'

fun! s:replaceWord(...)
  if g:easy_replace_enable == 0
    return
  endif

  let l:current_word = get(a:, 1, '')
  let l:line = get(a:, 2, {})

  " Define context
  let context = s:generateContext(l:current_word, l:line)

  if context.pattern != ''
    call easy_replace#highlight(context)
  endif

  redraw

  while 1
    call context.echoMessage()

    let c = getchar()

    if c == s:code_list['enter']
      let isFinish = context.nextMode()
      if isFinish == 1
        break
      endif
    elseif c == s:code_list['backspace'] || c == s:code_list['delete']
      call context.removeChar()
    elseif c == s:code_list['ctrl-u']
      call context.removeAllChar()
    elseif c == s:code_list['escape']
      redraw
      echo "Canceled!"
      break
    else
      call context.addChar(c)
    endif

    call easy_replace#highlight(context)

    redraw
  endwhile

  match none

endfun

fun! s:generateContext(current_word, line)
  let context = {}
  let context.pattern = a:current_word
  let context.replace = ''
  let context.line = a:line
  let context.mode = s:mode_pattern

  fun! context.getTarget()
    return self.mode == s:mode_pattern ? self.pattern : self.replace
  endfun

  fun! context.update(result)
    if self.mode == s:mode_pattern
      let self.pattern = a:result
    else
      let self.replace = a:result
    endif
  endfun

  fun! context.echoMessage()
    echo self.mode == s:mode_pattern ?
      \ 'Pattern: ' . self.pattern :
      \ 'Replace: ' . self.replace
  endfun

  fun! context.addChar(c)
    let l:target = self.getTarget()
    call self.update(l:target . nr2char(a:c))
  endfun

  fun! context.removeChar()
    let l:target = self.getTarget()
    call self.update(l:target[:-2])
  endfun

  fun! context.removeAllChar()
    call self.update('')
  endfun

  fun! context.nextMode()
    if self.mode == s:mode_pattern
      let self.mode = s:mode_replace
      return 0
    elseif self.mode == s:mode_replace
      call easy_replace#replace(self)
      return 1
    endif

    return 0
  endfun

  return context
endfun

fun! s:getCurrentWord()
  let line = line(".")
  let col  = col(".")
  return expand("<cword>")
endfun

fun! s:getLine()
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
