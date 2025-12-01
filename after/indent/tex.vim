" 在 LaTeX 文件中的 MetaPost 代码块中启用缩进
" 检测 MetaPost 环境并应用 MetaPost 缩进规则

" 检查是否在 MetaPost 环境中
function! IsInMetaPostBlock(lnum)
  " 向后查找，检查是否在 MetaPost 块中
  let l:line = a:lnum
  let l:in_block = 0
  let l:block_start = 0
  
  while l:line > 0
    let l:text = getline(l:line)
    
    " 检查结束标记
    if l:text =~# '\\end{mpostfig}\|\\end{mpostdef}\|\\end{mpdisplay}\|\\end{mpinline}\|\\end{mpdefs}'
      if l:in_block && l:line < a:lnum
        return 0
      endif
    endif
    
    " 检查开始标记
    if l:text =~# '\\begin{mpostfig}\|\\begin{mpostdef}\|\\begin{mpdisplay}\|\\begin{mpinline}\|\\begin{mpdefs}'
      if l:line < a:lnum
        return 1
      endif
    endif
    
    let l:line -= 1
  endwhile
  
  return 0
endfunction

" 获取 MetaPost 缩进
function! GetMetaPostIndent()
  let l:prevlnum = prevnonblank(v:lnum - 1)
  if l:prevlnum == 0
    return 0
  endif

  let l:prevline = getline(l:prevlnum)
  let l:curline = getline(v:lnum)
  let l:indent = indent(l:prevlnum)

  " 增加缩进的情况
  if l:prevline =~# '\<def\>\s\|<vardef\>\s\|<if\>\s\|<for\>\s\|<forever\>\s\|<beginfig\>\s\|<begingroup\>\s'
    let l:indent += shiftwidth()
  endif

  " 减少缩进的情况
  if l:curline =~# '\<enddef\>\|<endfor\>\|<fi\>\|<endfig\>\|<endgroup\>\|<end\>'
    let l:indent -= shiftwidth()
  endif

  " else, elseif 减少一级缩进
  if l:curline =~# '\<else\>\|<elseif\>'
    let l:indent -= shiftwidth()
  endif

  return l:indent < 0 ? 0 : l:indent
endfunction

" 重写缩进函数
function! GetTexIndentWithMetaPost()
  " 如果当前行在 MetaPost 块中，使用 MetaPost 缩进
  if IsInMetaPostBlock(v:lnum)
    return GetMetaPostIndent()
  endif
  
  " 否则使用默认的 tex 缩进
  " 尝试调用原始的 tex 缩进函数
  if exists("*GetTeXIndent")
    return GetTeXIndent()
  endif
  
  " 如果没有原始函数，使用简单的缩进
  let l:prevlnum = prevnonblank(v:lnum - 1)
  return l:prevlnum > 0 ? indent(l:prevlnum) : 0
endfunction

" 设置缩进表达式
if &indentexpr == "" || &indentexpr =~# "GetTeXIndent"
  setlocal indentexpr=GetTexIndentWithMetaPost()
endif

" 设置缩进键
setlocal indentkeys+=!^F,o,O,0=enddef,0=endfor,0=fi,0=endfig,0=endgroup,0=end,0=else,0=elseif

