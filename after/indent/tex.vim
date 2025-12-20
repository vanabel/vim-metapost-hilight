" 在 LaTeX 文件中的 MetaPost 代码块中启用缩进
" 检测 MetaPost 环境并应用 MetaPost 缩进规则
" 使用 indent/mpost.vim 中定义的 MetaPost 缩进函数

" 检查是否在 MetaPost 环境中
function! IsInMetaPostBlock(lnum)
  let l:line = a:lnum
  let l:last_begin = 0
  let l:last_end = 0
  
  " 从当前行向上查找最近的开始和结束标记
  while l:line > 0
    let l:text = getline(l:line)
    
    " 检查结束标记
    if l:text =~# '\\end{mpostfig}\|\\end{mpostdef}\|\\end{mpisplay}\|\\end{mpinline}\|\\end{mpdefs}'
      if l:last_end == 0 || l:line > l:last_end
        let l:last_end = l:line
      endif
    endif
    
    " 检查开始标记
    if l:text =~# '\\begin{mpostfig}\|\\begin{mpostdef}\|\\begin{mpisplay}\|\\begin{mpinline}\|\\begin{mpdefs}'
      if l:last_begin == 0 || l:line > l:last_begin
        let l:last_begin = l:line
      endif
    endif
    
    let l:line -= 1
  endwhile
  
  " 如果找到了开始标记，且没有结束标记或结束标记在开始标记之前，则在块中
  if l:last_begin > 0
    if l:last_end == 0 || l:last_begin > l:last_end
      return 1
    endif
  endif
  
  return 0
endfunction

" 查找最近的 \begin{xxx} 行的缩进
function! FindBeginIndent(lnum)
  let l:line = a:lnum - 1
  while l:line > 0
    let l:text = getline(l:line)
    " 检查是否是 \begin{xxx}
    if l:text =~# '\\begin{mpostfig}\|\\begin{mpostdef}\|\\begin{mpisplay}\|\\begin{mpinline}\|\\begin{mpdefs}'
      return indent(l:line)
    endif
    let l:line -= 1
  endwhile
  return -1
endfunction

" 加载 MetaPost 缩进函数（从 indent/mpost.vim）
" 如果函数不存在，定义它
if !exists("*GetMetaPostIndent")
  " 尝试加载我们的 MetaPost 缩进文件
  runtime! indent/mpost.vim
endif

" 如果仍然不存在，定义默认的 MetaPost 缩进函数
if !exists("*GetMetaPostIndent")
  function! GetMetaPostIndent()
    let l:prevlnum = prevnonblank(v:lnum - 1)
    if l:prevlnum == 0
      return 0
    endif

    let l:prevline = getline(l:prevlnum)
    let l:curline = getline(v:lnum)
    let l:indent = indent(l:prevlnum)

    " 增加缩进的情况：def, vardef, if, for, forever, beginfig, begingroup
    if l:prevline =~# '\<def\>\s\|\<vardef\>\s\|\<if\>\s\|\<for\>\s\|\<forever\>\s\|\<beginfig\>\s\|\<begingroup\>\s'
      let l:indent += shiftwidth()
    endif

    " 减少缩进的情况：enddef, endfor, fi, endfig, endgroup, end
    if l:curline =~# '\<enddef\>\|\<endfor\>\|\<fi\>\|\<endfig\>\|\<endgroup\>\|\<end\>'
      let l:indent -= shiftwidth()
    endif

    " else, elseif 减少一级缩进
    if l:curline =~# '\<else\>\|\<elseif\>'
      let l:indent -= shiftwidth()
    endif

    return l:indent < 0 ? 0 : l:indent
  endfunction
endif

" 重写缩进函数，兼容 vimtex 和其他 LaTeX 缩进插件
function! GetTexIndentWithMetaPost()
  " 如果当前行在 MetaPost 块中，使用 MetaPost 缩进
  if IsInMetaPostBlock(v:lnum)
    " 检查当前行是否是 \end{xxx}
    let l:curline = getline(v:lnum)
    if l:curline =~# '\\end{mpostfig}\|\\end{mpostdef}\|\\end{mpisplay}\|\\end{mpinline}\|\\end{mpdefs}'
      " \end{xxx} 应该与 \begin{xxx} 对齐
      let l:begin_indent = FindBeginIndent(v:lnum)
      if l:begin_indent >= 0
        return l:begin_indent
      endif
    endif
    
    " 查找最近的 \begin{xxx} 行的缩进
    let l:begin_indent = FindBeginIndent(v:lnum)
    
    if l:begin_indent >= 0
      " 检查上一行是否是 \begin{xxx} 行或空行
      let l:prevlnum = prevnonblank(v:lnum - 1)
      let l:prevline = ""
      if l:prevlnum > 0
        let l:prevline = getline(l:prevlnum)
      endif
      
      " 如果是环境内的第一行内容（上一行是 \begin 或空行），直接使用 \begin 的缩进 + 2
      if l:prevline =~# '\\begin{mpostfig}\|\\begin{mpostdef}\|\\begin{mpisplay}\|\\begin{mpinline}\|\\begin{mpdefs}' || l:prevline == ""
        return l:begin_indent + 2
      endif
      
      " 否则，使用 MetaPost 缩进函数计算相对缩进
      " 但是我们需要确保环境内的内容至少缩进 2 个空格（相对于 \begin）
      let l:mpost_indent = GetMetaPostIndent()
      
      " 如果 MetaPost 缩进小于或等于 \begin 的缩进，说明需要至少缩进 2 个空格
      if l:mpost_indent <= l:begin_indent
        return l:begin_indent + 2
      endif
      
      " 否则使用 MetaPost 计算的缩进（它已经考虑了 if/else/fi 等结构）
      return l:mpost_indent
    else
      " 如果找不到 \begin，使用标准的 MetaPost 缩进
      return GetMetaPostIndent()
    endif
  endif
  
  " 否则调用 vimtex 的缩进函数（如果存在）
  if exists("*GetTeXIndent")
    return GetTeXIndent()
  endif
  
  " 如果没有 vimtex，尝试使用当前设置的 indentexpr（可能是其他插件的）
  " 但我们需要避免递归调用自己
  let l:current_expr = &indentexpr
  if l:current_expr != "" && l:current_expr != "GetTexIndentWithMetaPost()"
    try
      " 如果是一个函数调用，尝试执行它
      if l:current_expr =~# '()$'
        let l:func_name = substitute(l:current_expr, '()$', '', '')
        if exists("*" . l:func_name) && l:func_name != "GetTexIndentWithMetaPost"
          return call(l:func_name, [])
        endif
      endif
    catch
      " 如果调用失败，继续使用默认行为
    endtry
  endif
  
  " 如果没有其他缩进函数，使用简单的缩进（保持上一行的缩进）
  let l:prevlnum = prevnonblank(v:lnum - 1)
  return l:prevlnum > 0 ? indent(l:prevlnum) : 0
endfunction

" 保存原始的缩进表达式（如果存在）
if exists("b:undo_indent")
  let b:undo_indent .= "| setlocal indentexpr< indentkeys<"
else
  let b:undo_indent = "setlocal indentexpr< indentkeys<"
endif

" 使用延迟加载机制，确保在 vimtex 之后设置
" 这样我们可以检测并调用 vimtex 的函数
augroup MetaPostIndent
  autocmd!
  " 在 FileType 事件后设置，确保其他插件（如 vimtex）已经加载
  autocmd FileType tex,plaintex,context
        \ call s:SetupIndent()
augroup END

" 设置缩进的辅助函数
function! s:SetupIndent()
  " 设置我们的缩进函数
  setlocal indentexpr=GetTexIndentWithMetaPost()
  " 添加 MetaPost 特定的缩进键（追加，不覆盖现有的）
  setlocal indentkeys+=0=enddef,0=endfor,0=fi,0=endfig,0=endgroup,0=end,0=else,0=elseif
endfunction

" 如果文件类型已经设置，立即调用设置函数
if &filetype =~# '^tex$\|^plaintex$\|^context$'
  call s:SetupIndent()
endif
