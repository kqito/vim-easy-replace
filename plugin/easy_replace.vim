if exists("g:loaded_easy_replace")
  finish
endif

let g:loaded_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

let s:default_replace_key = '<Leader>ra'
let s:default_replace_current_key = '<Leader>rc'

let g:easy_replace_key = get(g:, 'default_start_key', s:default_replace_key)
let g:easy_replace_current_key = get(g:, 'default_start_key', s:default_replace_current_key)
let g:easy_replace_enable = get(g:, 'easy_replace_enable', 1)

let s:code_list = {
  \  'enter':        char2nr("\<CR>"),
  \  'escape':       char2nr("\<Esc>"),
  \  'backspace':    "\<BS>",
  \  'delete':       "\<DEL>",
  \  'ctrl-u':       char2nr("\<C-u>"),
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
    call s:echoMessage(context)

    let c = getchar()

    if c == s:code_list['enter']
      let isFinish =  s:nextMode(context)
      if isFinish == 1
        break
      endif
    elseif c == s:code_list['backspace'] || c == s:code_list['delete']
      call context.update(function('s:removeChar'))
    elseif c == s:code_list['ctrl-u']
      call context.update(function('s:removeAllChar'))
    elseif c == s:code_list['escape']
      redraw
      echo "Canceled!"
      break
    else
      call context.update(function('s:addChar', [c]))
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
  let context.mode = 'pattern'

  fun! context.getTarget()
    return self.mode == 'pattern' ? self.pattern : self.replace
  endfun

  fun! context.update(handler)
    let target = self.getTarget()

    let result = a:handler(target)

    if self.mode == 'pattern'
      let self.pattern = result
    else
      let self.replace = result
    endif
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

fun! s:echoMessage(context)
  echo a:context.mode == 'pattern' ?
    \ 'Pattern: ' . a:context.pattern :
    \ 'Replace: ' . a:context.replace
endfun

fun! s:addChar(c, target)
  return a:target . nr2char(a:c)
endfun

fun! s:removeChar(target)
  return a:target[:-2]
endfun

fun! s:removeAllChar(target)
  return ''
endfun

fun! s:nextMode(context)
  if a:context.mode == 'pattern'
    let a:context.mode = 'replace'
    return 0
  elseif a:context.mode == 'replace'
    call easy_replace#replace(a:context)
    return 1
  endif

  return 0
endfun

let &cpo = s:save_cpo
