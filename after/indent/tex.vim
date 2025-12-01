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

" 重写缩进函数
function! GetTexIndentWithMetaPost()
  " 如果当前行在 MetaPost 块中，使用 MetaPost 缩进
  if IsInMetaPostBlock(v:lnum)
    " 使用 MetaPost 缩进函数
    return GetMetaPostIndent()
  endif
  
  " 否则使用默认的 tex 缩进
  if exists("*GetTeXIndent")
    return GetTeXIndent()
  endif
  
  " 如果没有原始函数，使用简单的缩进
  let l:prevlnum = prevnonblank(v:lnum - 1)
  return l:prevlnum > 0 ? indent(l:prevlnum) : 0
endfunction

" 保存原始的缩进表达式（如果存在）
if exists("b:undo_indent")
  let b:undo_indent .= "| setlocal indentexpr< indentkeys<"
else
  let b:undo_indent = "setlocal indentexpr< indentkeys<"
endif

" 设置缩进表达式
setlocal indentexpr=GetTexIndentWithMetaPost()
" 添加 MetaPost 缩进键
setlocal indentkeys+=!^F,o,O,0=enddef,0=endfor,0=fi,0=endfig,0=endgroup,0=end,0=else,0=elseif
