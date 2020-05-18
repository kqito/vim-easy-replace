if exists('g:loaded_autoload_easy_replace')
  finish
endif

let g:loaded_autoload_easy_replace = 1

let s:save_cpo = &cpo
set cpo&vim

const s:mode_pattern = 'pattern'
const s:mode_replace = 'replace'

fun! easy_replace#replace(context)
  let l:line_start = get(a:context['line'], 'start', -1)
  let l:line_end = get(a:context['line'], 'end', -1)
  let l:range = l:line_start != -1 && l:line_end != -1 ?
    \ l:line_start . ',' . l:line_end :
    \ '%'
  let l:replace = l:range . 's/' . a:context.pattern . '/' . a:context.replace . '/g'

  try
    exe ':' . l:replace

    if g:easy_replace_add_history
      call histadd(':', l:replace)
    endif
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

fun! easy_replace#generate_context(current_word, line)
  let context = {}
  let context.pattern = a:current_word
  let context.replace = ''
  let context.line = a:line
  let context.mode = s:mode_pattern

  fun! context.get_target()
    return self.mode == s:mode_pattern ? self.pattern : self.replace
  endfun

  fun! context.update(result)
    if self.mode == s:mode_pattern
      let self.pattern = a:result
    else
      let self.replace = a:result
    endif
  endfun

  fun! context.echo_message()
    echo self.mode == s:mode_pattern ?
      \ 'Pattern: ' . self.pattern :
      \ 'Replace: ' . self.replace
  endfun

  fun! context.add_char(c)
    let l:target = self.get_target()
    call self.update(l:target . nr2char(a:c))
  endfun

  fun! context.remove_char()
    let l:target = self.get_target()
    call self.update(l:target[:-2])
  endfun

  fun! context.remove_all_char()
    call self.update('')
  endfun

  fun! context.next_mode()
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

let &cpo = s:save_cpo
