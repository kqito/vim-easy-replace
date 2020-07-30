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
  let context.arrow_index = 0

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
    echon self.mode == s:mode_pattern ? 'Pattern: ': 'Replace: '

    let index = 0
    let l:target = self.get_target()
    for char in split(l:target, '\zs')
      if self.arrow_index == index
        echohl Cursor
      endif

      echon char

      let index += 1
      echohl None
    endfor

    " if cursor position is last
    if self.arrow_index == strlen(l:target)
      echohl Cursor
      echon " "
      echohl None
    else
      echon " "
    endif
  endfun

  fun! context.add_char(c)
    let l:target = self.get_target()
    let prefix = self.arrow_index - 1 >= 0 ? l:target[0:self.arrow_index - 1] : ""
    let suffix = l:target[self.arrow_index:-1]

    call self.update(prefix . nr2char(a:c) . suffix)
    call self.update_arrow_index(1)
  endfun

  fun! context.remove_char()
    let l:new = ""
    let index = 0
    for char in split(self.get_target(), '\zs')
      if self.arrow_index != index + 1
        let l:new = l:new . char
      endif

      let index += 1
    endfor

    call self.update(l:new)
    call self.update_arrow_index(-1)
  endfun

  fun! context.remove_all_char()
    call self.update('')
    let self.arrow_index = 0
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

  fun! context.update_arrow_index(i)
    let l:target = self.get_target()
    let new_arrow_index = self.arrow_index + a:i
    if new_arrow_index <= strlen(l:target) && new_arrow_index >= 0
      let self.arrow_index = new_arrow_index
    endif
  endfun

  return context
endfun

let &cpo = s:save_cpo
