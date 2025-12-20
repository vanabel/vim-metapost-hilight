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
  " if 语句：检查是否以 : 结尾（如 if condition:）
  if l:clean_line =~# '\<if\>.*:\s*$'
    return 1
  endif
  " elseif 语句：检查是否以 : 结尾（如 elseif condition:）
  if l:clean_line =~# '\<elseif\>.*:\s*$'
    return 1
  endif
  " else 语句：检查是否以 : 结尾（如 else:）
  if l:clean_line =~# '\<else\>:\s*$'
    return 1
  endif
  " for 语句：检查是否以 : 结尾
  if l:clean_line =~# '\<for\>.*:\s*$'
    return 1
  endif
  if l:clean_line =~# '\<forever\>\s*$'
    return 1
  endif
  " begingroup 后应该增加缩进
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
  " endgroup 应该减少缩进（与 begingroup 对齐）
  if a:line =~# '^\s*\<endgroup\>'
    return 1
  endif
  if a:line =~# '^\s*\<end\>'
    return 1
  endif
  " 检查 else, elseif - 它们应该与 if 对齐（减少一级缩进）
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

" 向上查找最近的 if/elseif/else 语句的缩进
function! s:FindIfIndent(lnum)
  let l:line = a:lnum - 1
  while l:line > 0
    let l:text = getline(l:line)
    let l:clean_text = substitute(l:text, '%.*$', '', '')
    
    " 如果找到 if、elseif 或 else，返回它的缩进
    if l:clean_text =~# '\<if\>.*:\s*$'
      return indent(l:line)
    elseif l:clean_text =~# '\<elseif\>.*:\s*$'
      return indent(l:line)
    elseif l:clean_text =~# '\<else\>:\s*$'
      return indent(l:line)
    " 如果遇到 fi，跳过这个 if 块
    elseif l:clean_text =~# '\<fi\>'
      " 跳过这个 if 块，继续向上查找
      let l:level = 1
      let l:line -= 1
      while l:line > 0 && l:level > 0
        let l:text2 = getline(l:line)
        let l:clean_text2 = substitute(l:text2, '%.*$', '', '')
        if l:clean_text2 =~# '\<fi\>'
          let l:level += 1
        elseif l:clean_text2 =~# '\<if\>.*:\s*$'
          let l:level -= 1
        endif
        let l:line -= 1
      endwhile
      continue
    endif
    
    let l:line -= 1
  endwhile
  return -1
endfunction

" 向上查找最近的 begingroup 的缩进
function! s:FindBeginGroupIndent(lnum)
  let l:line = a:lnum - 1
  while l:line > 0
    let l:text = getline(l:line)
    let l:clean_text = substitute(l:text, '%.*$', '', '')
    
    if l:clean_text =~# '\<begingroup\>\s*$'
      return indent(l:line)
    " 如果遇到 endgroup，跳过这个 begingroup 块
    elseif l:clean_text =~# '\<endgroup\>'
      let l:level = 1
      let l:line -= 1
      while l:line > 0 && l:level > 0
        let l:text2 = getline(l:line)
        let l:clean_text2 = substitute(l:text2, '%.*$', '', '')
        if l:clean_text2 =~# '\<endgroup\>'
          let l:level += 1
        elseif l:clean_text2 =~# '\<begingroup\>\s*$'
          let l:level -= 1
        endif
        let l:line -= 1
      endwhile
      continue
    endif
    
    let l:line -= 1
  endwhile
  return -1
endfunction

" 向上查找最近的 def/vardef 的缩进
function! s:FindDefIndent(lnum)
  let l:line = a:lnum - 1
  while l:line > 0
    let l:text = getline(l:line)
    let l:clean_text = substitute(l:text, '%.*$', '', '')
    
    if l:clean_text =~# '\<\(vardef\|def\)\>'
      return indent(l:line)
    " 如果遇到 enddef，跳过这个 def 块
    elseif l:clean_text =~# '\<enddef\>'
      let l:level = 1
      let l:line -= 1
      while l:line > 0 && l:level > 0
        let l:text2 = getline(l:line)
        let l:clean_text2 = substitute(l:text2, '%.*$', '', '')
        if l:clean_text2 =~# '\<enddef\>'
          let l:level += 1
        elseif l:clean_text2 =~# '\<\(vardef\|def\)\>'
          let l:level -= 1
        endif
        let l:line -= 1
      endwhile
      continue
    endif
    
    let l:line -= 1
  endwhile
  return -1
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

  " 特殊处理：elseif 和 else 应该与最近的 if/elseif/else 对齐
  if l:curline =~# '^\s*\<elseif\>'
    let l:if_indent = s:FindIfIndent(v:lnum)
    if l:if_indent >= 0
      return l:if_indent
    endif
    " 如果找不到匹配的 if，减少缩进
    let l:indent -= shiftwidth()
  elseif l:curline =~# '^\s*\<else\>:\s*$'
    let l:if_indent = s:FindIfIndent(v:lnum)
    if l:if_indent >= 0
      return l:if_indent
    endif
    " 如果找不到匹配的 if，减少缩进
    let l:indent -= shiftwidth()
  " 特殊处理：fi 应该与最近的 if 对齐
  elseif l:curline =~# '^\s*\<fi\>'
    let l:if_indent = s:FindIfIndent(v:lnum)
    if l:if_indent >= 0
      return l:if_indent
    endif
    " 如果找不到匹配的 if，减少缩进
    let l:indent -= shiftwidth()
  " 特殊处理：endgroup 应该与最近的 begingroup 对齐
  elseif l:curline =~# '^\s*\<endgroup\>'
    let l:begin_indent = s:FindBeginGroupIndent(v:lnum)
    if l:begin_indent >= 0
      return l:begin_indent
    endif
    " 如果找不到匹配的 begingroup，减少缩进
    let l:indent -= shiftwidth()
  " 特殊处理：enddef 应该与最近的 def/vardef 对齐
  elseif l:curline =~# '^\s*\<enddef\>'
    let l:def_indent = s:FindDefIndent(v:lnum)
    if l:def_indent >= 0
      return l:def_indent
    endif
    " 如果找不到匹配的 def，减少缩进
    let l:indent -= shiftwidth()
  " 标准逻辑：如果当前行以其他闭合标签开头，减少缩进
  elseif s:StartsWithCloseTag(l:curline)
    let l:indent -= shiftwidth()
  endif

  " 如果上一行以开放标签结尾（if, for, def, begingroup 等），增加缩进
  if s:LastTagIsOpen(l:prevline)
    let l:indent += shiftwidth()
  endif

  " 如果上一行包含未终止的语句，增加缩进
  if s:HasUnterminatedStatement(l:prevline)
    let l:indent += shiftwidth()
  endif

  " 确保缩进不为负
  return l:indent < 0 ? 0 : l:indent
endfunction
