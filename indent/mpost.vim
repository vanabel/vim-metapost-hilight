" MetaPost 缩进文件
" 用于在 MetaPost 代码块中提供自动缩进

" 只在未定义时加载
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" 设置缩进选项
setlocal indentexpr=GetMetaPostIndent()
setlocal indentkeys=!^F,o,O,0=enddef,0=endfor,0=fi,0=endfig,0=endgroup,0=end,0=else,0=elseif

" 获取当前行的缩进
function! GetMetaPostIndent()
  let l:prevlnum = prevnonblank(v:lnum - 1)
  if l:prevlnum == 0
    return 0
  endif

  let l:prevline = getline(l:prevlnum)
  let l:curline = getline(v:lnum)
  let l:indent = indent(l:prevlnum)

  " 增加缩进的情况
  " def, vardef, if, for, forever, beginfig, begingroup
  if l:prevline =~# '\<def\>\s\|\<vardef\>\s\|\<if\>\s\|\<for\>\s\|\<forever\>\s\|\<beginfig\>\s\|\<begingroup\>\s'
    let l:indent += shiftwidth()
  endif

  " 减少缩进的情况
  " enddef, endfor, fi, endfig, endgroup, end
  if l:curline =~# '\<enddef\>\|<endfor\>\|<fi\>\|<endfig\>\|<endgroup\>\|<end\>'
    let l:indent -= shiftwidth()
  endif

  " else, elseif 减少一级缩进
  if l:curline =~# '\<else\>\|<elseif\>'
    let l:indent -= shiftwidth()
  endif

  " 确保缩进不为负
  return l:indent < 0 ? 0 : l:indent
endfunction

