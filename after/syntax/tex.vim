" 在 LaTeX 文件中高亮 MetaPost 和 LaTeX 代码块
" 支持以下环境：
"   - \begin{mpostfig} ... \end{mpostfig} - MetaPost 代码块
"   - \begin{mpostdef} ... \end{mpostdef} - MetaPost 定义块
"   - \begin{mposttex} ... \end{mposttex} - LaTeX 代码块
" mpgraphics 包支持：
"   - \begin{mpdisplay} ... \end{mpdisplay} - MetaPost 代码块
"   - \begin{mpinline} ... \end{mpinline} - MetaPost 代码块
"   - \begin{mpdefs} ... \end{mpdefs} - MetaPost 定义块
"   - \begin{ltxpreamble} ... \end{ltxpreamble} - LaTeX 代码块
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
      " 内置语法不包含非标准关键字，需要额外添加
      " 使用 mpKeyword 组（内置语法使用的组名）或创建新组
      if hlexists("mpKeyword")
        syn match mpKeyword contained "\<new_vec\>"
        syn match mpKeyword contained "\<free_vec\>"
        syn match mpKeyword contained "\<set_point_\>"
        syn match mpKeyword contained "\<vec_def_vec_\>"
        syn match mpKeyword contained "\<vec_rotate_\>"
        syn match mpKeyword contained "\<vec_prod_\>"
        syn match mpKeyword contained "\<vec_mult_\>"
        syn match mpKeyword contained "\<vec_sum_\>"
        syn match mpKeyword contained "\<vec_diff\>"
        syn match mpKeyword contained "\<vec_unit\>"
      else
        " 如果内置语法组不存在，创建自定义关键字组
        syn match mpostKeyword contained "\<new_vec\>"
        syn match mpostKeyword contained "\<free_vec\>"
        syn match mpostKeyword contained "\<set_point_\>"
        syn match mpostKeyword contained "\<vec_def_vec_\>"
        syn match mpostKeyword contained "\<vec_rotate_\>"
        syn match mpostKeyword contained "\<vec_prod_\>"
        syn match mpostKeyword contained "\<vec_mult_\>"
        syn match mpostKeyword contained "\<vec_mult\>"
        syn match mpostKeyword contained "\<vec_sum_\>"
        syn match mpostKeyword contained "\<vec_sum\>"
        syn match mpostKeyword contained "\<vec_diff\>"
        syn match mpostKeyword contained "\<vec_unit\>"
        hi def link mpostKeyword Keyword
        syn cluster mpostSyntax add=mpostKeyword
      endif
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
  
  " ===== 添加用户自定义关键字、函数和常量 =====
  " 即使用户使用内置语法，也支持自定义关键字
  " 用户可以在 vimrc 中定义以下变量：
  "   - g:metapost_custom_keywords: 自定义关键字列表
  "   - g:metapost_custom_functions: 自定义函数列表
  "   - g:metapost_custom_constants: 自定义常量列表
  
  " 确定使用哪个语法组（内置语法使用 mpKeyword，自定义语法使用 mpostKeyword）
  let s:keyword_group = hlexists("mpKeyword") ? "mpKeyword" : "mpostKeyword"
  let s:function_group = hlexists("mpFunction") ? "mpFunction" : "mpostFunction"
  let s:constant_group = hlexists("mpConstant") ? "mpConstant" : "mpostConstant"
  
  " 用户自定义关键字
  if exists("g:metapost_custom_keywords")
    for keyword in g:metapost_custom_keywords
      if keyword != ""
        if keyword =~ '_'
          exe 'syn match ' . s:keyword_group . ' contained "\<' . escape(keyword, '\.*^$~[]') . '\>"'
        else
          exe 'syn keyword ' . s:keyword_group . ' contained ' . keyword
        endif
        " 确保添加到语法集群中
        if s:keyword_group == "mpostKeyword"
          syn cluster mpostSyntax add=mpostKeyword
        endif
      endif
    endfor
  endif
  
  " 用户自定义函数
  if exists("g:metapost_custom_functions")
    for func in g:metapost_custom_functions
      if func != ""
        if func =~ '_'
          exe 'syn match ' . s:function_group . ' contained "\<' . escape(func, '\.*^$~[]') . '\>"'
        else
          exe 'syn keyword ' . s:function_group . ' contained ' . func
        endif
        if s:function_group == "mpostFunction"
          syn cluster mpostSyntax add=mpostFunction
        endif
      endif
    endfor
  endif
  
  " 用户自定义常量
  if exists("g:metapost_custom_constants")
    for const in g:metapost_custom_constants
      if const != ""
        if const =~ '_'
          exe 'syn match ' . s:constant_group . ' contained "\<' . escape(const, '\.*^$~[]') . '\>"'
        else
          exe 'syn keyword ' . s:constant_group . ' contained ' . const
        endif
        if s:constant_group == "mpostConstant"
          syn cluster mpostSyntax add=mpostConstant
        endif
      endif
    endfor
  endif
endif

" 定义 mpostfig 环境
" 使用 matchgroup 让 \begin 和 \end 标记使用 texCmd 高亮（tex 命令的标准高亮）
" 内容部分使用 MetaPost 语法
syn region texMpostFigContent
      \ matchgroup=texCmd
      \ start="\\begin{mpostfig}"
      \ end="\\end{mpostfig}"
      \ contains=@mpostSyntax
      \ keepend

" 定义 mpostdef 环境（MetaPost 定义块）
" 使用与 mpostfig 相同的 MetaPost 语法高亮
syn region texMpostDefContent
      \ matchgroup=texCmd
      \ start="\\begin{mpostdef}"
      \ end="\\end{mpostdef}"
      \ contains=@mpostSyntax
      \ keepend

" 定义 mposttex 环境（LaTeX 代码块）
" 使用 transparent 让 tex 语法自然处理内容，确保 \usepackage 等命令被正确高亮
" matchgroup 确保 \begin 和 \end 标记被正确高亮
syn region texMpostTexContent
      \ matchgroup=texCmd
      \ start="\\begin{mposttex}"
      \ end="\\end{mposttex}"
      \ transparent
      \ keepend

" ===== mpgraphics 包支持 =====

" 定义 mpdisplay 环境（MetaPost 代码块）
" 使用与 mpostfig 相同的 MetaPost 语法高亮
syn region texMpDisplayContent
      \ matchgroup=texCmd
      \ start="\\begin{mpdisplay}"
      \ end="\\end{mpdisplay}"
      \ contains=@mpostSyntax
      \ keepend

" 定义 mpinline 环境（MetaPost 代码块）
" 使用与 mpostfig 相同的 MetaPost 语法高亮
syn region texMpInlineContent
      \ matchgroup=texCmd
      \ start="\\begin{mpinline}"
      \ end="\\end{mpinline}"
      \ contains=@mpostSyntax
      \ keepend

" 定义 mpdefs 环境（MetaPost 定义块）
" 使用与 mpostdef 相同的 MetaPost 语法高亮
syn region texMpDefsContent
      \ matchgroup=texCmd
      \ start="\\begin{mpdefs}"
      \ end="\\end{mpdefs}"
      \ contains=@mpostSyntax
      \ keepend

" 定义 ltxpreamble 环境（LaTeX 代码块）
" 使用 transparent 让 tex 语法自然处理内容，确保 \usepackage 等命令被正确高亮
" matchgroup 确保 \begin 和 \end 标记被正确高亮
syn region texLtxPreambleContent
      \ matchgroup=texCmd
      \ start="\\begin{ltxpreamble}"
      \ end="\\end{ltxpreamble}"
      \ transparent
      \ keepend

" 高亮组
" 内容区域不需要额外高亮（让内容使用各自的语法高亮）
hi def link texMpostFigContent NONE
hi def link texMpostDefContent NONE
hi def link texMpostTexContent NONE
hi def link texMpDisplayContent NONE
hi def link texMpInlineContent NONE
hi def link texMpDefsContent NONE
hi def link texLtxPreambleContent NONE

