" 在 LaTeX 文件中高亮 MetaPost 和 LaTeX 代码块
" 支持以下环境：
"   - \begin{mpostfig} ... \end{mpostfig} - MetaPost 代码块
"   - \begin{mpostdef} ... \end{mpostdef} - MetaPost 定义块
"   - \begin{mposttex} ... \end{mposttex} - LaTeX 代码块
" 尝试使用 Vim 内置的 MetaPost 语法文件 (syntax/mp.vim)，与 ft=mp 保持一致

" 先包含 MetaPost 语法（必须在定义区域之前）
if !exists("b:mpost_syntax_loaded")
  let b:mpost_syntax_loaded = 1
  let s:mpost_syntax_save = exists("b:current_syntax") ? b:current_syntax : ""
  
  " 保存当前的 iskeyword 设置
  let s:mpost_iskeyword_save = &iskeyword
  
  " 临时取消 current_syntax，以便加载 mp.vim
  unlet b:current_syntax
  
  " 尝试使用内置的 mp.vim 语法文件
  " 注意：mp.vim 使用 vim9script，syn include 可能不兼容
  " 默认使用自定义语法（兼容性更好），但可以通过设置变量尝试使用内置语法
  let s:use_builtin = exists("g:metapost_use_builtin_syntax") && g:metapost_use_builtin_syntax
  
  if s:use_builtin
    " 尝试使用内置语法（可能不工作，因为 vim9script）
    try
      syn include @mpostSyntax $VIMRUNTIME/syntax/mp.vim
      let s:loaded_builtin = 1
    catch
      " 如果失败，回退到自定义语法
      syn include @mpostSyntax syntax/mpost.vim
      let s:loaded_builtin = 0
    endtry
  else
    " 默认使用自定义语法（推荐，更兼容且包含所有必要的 MetaPost 元素）
    syn include @mpostSyntax syntax/mpost.vim
    let s:loaded_builtin = 0
  endif
  
  " 恢复 current_syntax
  if s:mpost_syntax_save != ""
    let b:current_syntax = s:mpost_syntax_save
  endif
  
  " 恢复 iskeyword 设置
  let &iskeyword = s:mpost_iskeyword_save
endif

" 定义 mpostfig 环境区域
" 使用 contains=@mpostSyntax 来包含所有 MetaPost 语法元素
" 这样在 tex 文件中的 mpostfig 块内，会应用与 ft=mp 相同的语法高亮
syn region texMpostFig matchgroup=texMpostFigDelimiter
      \ start="\\begin{mpostfig}"
      \ end="\\end{mpostfig}"
      \ contains=@mpostSyntax
      \ keepend

" 定义 mpostdef 环境区域（MetaPost 定义块）
" 使用与 mpostfig 相同的 MetaPost 语法高亮
syn region texMpostDef matchgroup=texMpostDefDelimiter
      \ start="\\begin{mpostdef}"
      \ end="\\end{mpostdef}"
      \ contains=@mpostSyntax
      \ keepend

" 定义 mposttex 环境区域（LaTeX 代码块）
" 使用标准的 LaTeX 语法高亮
" 注意：由于已经在 tex 文件中，使用 texMatchGroup 确保正确的 LaTeX 语法高亮
syn region texMpostTex matchgroup=texMpostTexDelimiter
      \ start="\\begin{mposttex}"
      \ end="\\end{mposttex}"
      \ contains=@texMatchGroup
      \ keepend

" 高亮组
hi def link texMpostFig NONE
hi def link texMpostFigDelimiter texDelimiter
hi def link texMpostDef NONE
hi def link texMpostDefDelimiter texDelimiter
hi def link texMpostTex NONE
hi def link texMpostTexDelimiter texDelimiter

