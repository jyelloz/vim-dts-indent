if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nosmartindent nocindent
setlocal indentkeys+=#if,0=#ifdef,0=#endif,0=#else,;

function! DtsIsCppDirective(line)
  return a:line =~ '^#\s*\S\+.*$'
endfunction

function! DtsIsIndentedCppDirective(line)
  return a:line =~ '^\s\+#\s*\S\+$'
endfunction

function! DtsPrevNonBlank(lnum)

  let l:lnum = a:lnum

  while l:lnum > 0

    " get nearest nonblank
    let l:lnum = prevnonblank(l:lnum)

    let line = getline(l:lnum)

    " if it's a cpp directive, ignore it
    if DtsIsCppDirective(line)
      let l:lnum = l:lnum - 1
      continue
    endif

    return l:lnum

  endwhile

  return l:lnum

endfunction

function! DtsIndent(lnum)

  let l:current_line = getline(a:lnum)

  if current_line =~ '^\s*#if\s\+'
    return 0
  endif

  let l:prev_lnum = DtsPrevNonBlank(a:lnum - 1)
  let l:prev_indent = indent(l:prev_lnum)
  let l:prev_line = getline(l:prev_lnum)

  if l:current_line =~ '^\s*\(}\|>\);\s*$'
    return l:prev_indent - &sw
  endif

  if l:prev_line =~ '\({\|<\)\s*$'
    return l:prev_indent + &sw
  endif

  return l:prev_indent

endfunction

setlocal indentexpr=DtsIndent(v:lnum)

" vim: ts=2 sts=2 sw=2 et :
