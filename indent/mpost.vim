" MetaPost 缩进文件
" 用于在 MetaPost 代码块中提供自动缩进
" 这个文件定义 GetMetaPostIndent() 函数，可以在其他缩进文件中使用
" 基于 Vim 内置的 mp.vim 缩进逻辑

" 只在函数未定义时加载
if exists("*GetMetaPostIndent")
  finish
endif

" 检查上一行是否以开放标签结尾
function! s:LastTagIsOpen(line)
  " 移除注释
  let l:clean_line = substitute(a:line, '%.*$', '', '')
  " 移除行尾空白
  let l:clean_line = substitute(l:clean_line, '\s*$', '', '')
  
  " 检查是否以开放标签结尾：def, vardef, if, for, forever, begingroup, beginfig 等
  if l:clean_line =~# '\<def\>\s*$'
    return 1
  endif
  if l:clean_line =~# '\<vardef\>\s*$'
    return 1
  endif
  if l:clean_line =~# '\<if\>.*:\s*$'
    return 1
  endif
  if l:clean_line =~# '\<for\>.*:\s*$'
    return 1
  endif
  if l:clean_line =~# '\<forever\>\s*$'
    return 1
  endif
  if l:clean_line =~# '\<begingroup\>\s*$'
    return 1
  endif
  if l:clean_line =~# '\<beginfig\>\s*$'
    return 1
  endif
  " 检查是否以 = 结尾（未终止的定义或赋值）
  if l:clean_line =~# '=\s*$'
    return 1
  endif
  " 检查是否以开放括号结尾
  if l:clean_line =~# '[([{]\s*$'
    return 1
  endif
  return 0
endfunction

" 检查当前行是否以闭合标签开头
function! s:StartsWithCloseTag(line)
  " 检查是否以闭合标签开头：enddef, endfor, fi, endfig, endgroup, end
  if a:line =~# '^\s*\<enddef\>'
    return 1
  endif
  if a:line =~# '^\s*\<endfor\>'
    return 1
  endif
  if a:line =~# '^\s*\<fi\>'
    return 1
  endif
  if a:line =~# '^\s*\<endfig\>'
    return 1
  endif
  if a:line =~# '^\s*\<endgroup\>'
    return 1
  endif
  if a:line =~# '^\s*\<end\>'
    return 1
  endif
  " 检查 else, elseif
  if a:line =~# '^\s*\<else\>'
    return 1
  endif
  if a:line =~# '^\s*\<elseif\>'
    return 1
  endif
  " 检查闭合括号
  if a:line =~# '^\s*[)\]}]'
    return 1
  endif
  return 0
endfunction

" 检查上一行是否包含未终止的语句（以语句关键字结尾但没有分号）
function! s:HasUnterminatedStatement(line)
  " 移除注释
  let l:clean_line = substitute(a:line, '%.*$', '', '')
  " 检查是否以分号结尾
  if l:clean_line =~# ';\s*$'
    return 0
  endif
  " 检查是否包含语句关键字但未以分号结尾
  if l:clean_line =~# '\<save\>.*[^;]\s*$'
    return 1
  endif
  if l:clean_line =~# '\<draw\>.*[^;]\s*$'
    return 1
  endif
  if l:clean_line =~# '\<fill\>.*[^;]\s*$'
    return 1
  endif
  if l:clean_line =~# ':\==.*[^;]\s*$'
    return 1
  endif
  return 0
endfunction

" 获取当前行的缩进
function! GetMetaPostIndent()
  let l:prevlnum = prevnonblank(v:lnum - 1)
  if l:prevlnum == 0
    return 0
  endif

  let l:prevline = getline(l:prevlnum)
  let l:curline = getline(v:lnum)
  let l:indent = indent(l:prevlnum)

  " 如果上一行以开放标签结尾，增加缩进
  if s:LastTagIsOpen(l:prevline)
    let l:indent += shiftwidth()
  endif

  " 如果上一行包含未终止的语句，增加缩进
  if s:HasUnterminatedStatement(l:prevline)
    let l:indent += shiftwidth()
  endif

  " 如果当前行以闭合标签开头，减少缩进
  if s:StartsWithCloseTag(l:curline)
    let l:indent -= shiftwidth()
  endif

  " 确保缩进不为负
  return l:indent < 0 ? 0 : l:indent
endfunction
