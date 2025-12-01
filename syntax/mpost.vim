" MetaPost 语法高亮文件
" 用于高亮 LaTeX 文件中的 MetaPost 代码块

" 检查是否已经加载（仅在独立模式下）
if !exists("b:mpost_syntax_included")
  let b:mpost_syntax_included = 1
endif

" 关键字
syn keyword mpostKeyword contained numeric string boolean path pair transform color
syn keyword mpostKeyword contained if else fi for endfor forever enddef def vardef

" 非标准 MetaPost 关键字（使用 match 确保包含下划线的关键字被正确匹配）
" 这些是扩展库（如 3danim）提供的函数
syn match mpostKeyword contained "\<new_vec\>"
syn match mpostKeyword contained "\<free_vec\>"
syn match mpostKeyword contained "\<set_point_\>"
syn match mpostKeyword contained "\<vec_def_vec_\>"
syn match mpostKeyword contained "\<vec_rotate_\>"
syn match mpostKeyword contained "\<vec_prod_\>"
syn match mpostKeyword contained "\<vec_mult_\>"
syn match mpostKeyword contained "\<vec_sum_\>"
syn match mpostKeyword contained "\<vec_diff\>"
syn match mpostKeyword contained "\<vec_unit\>"

" 内置函数
syn keyword mpostFunction contained cosd sind cos sin sqrt abs round floor ceiling
syn keyword mpostFunction contained pnt length angle direction
syn keyword mpostFunction contained unitvector dir intersectionpoint

" 预定义常量和向量
syn keyword mpostConstant contained vec_I vec_J vec_K vec_0
syn keyword mpostConstant contained true false infinity

" 运算符
syn match mpostOperator contained "[-+*/=<>]"
syn match mpostOperator contained "=="
syn match mpostOperator contained "!="
syn match mpostOperator contained "<="
syn match mpostOperator contained ">="

" 注释
syn match mpostComment contained "%.*$"

" 数字
syn match mpostNumber contained "\<\d\+\(\.\d\+\)\?\>"
syn match mpostNumber contained "\<\d\+\.\d\+[eE][+-]\?\d\+\>"

" 字符串
syn region mpostString contained start=+"+ end=+"+ skip=+\\"+

" 变量和函数名（包含下划线的标识符）
" 注意：关键字已经在上面定义，syn keyword 优先级高于 syn match
" 所以关键字会被正确高亮，这里只匹配非关键字的标识符
syn match mpostIdentifier contained "\<[a-zA-Z_][a-zA-Z0-9_]*\>"

" 括号
syn match mpostDelimiter contained "[()\[\]]"

" 将语法定义添加到集群中（用于嵌入）
syn cluster mpostSyntax contains=mpostKeyword,mpostFunction,mpostConstant,mpostOperator,mpostComment,mpostNumber,mpostString,mpostIdentifier,mpostDelimiter

" 高亮组定义
hi def link mpostKeyword Keyword
hi def link mpostFunction Function
hi def link mpostConstant Constant
hi def link mpostOperator Operator
hi def link mpostComment Comment
hi def link mpostNumber Number
hi def link mpostString String
hi def link mpostIdentifier Identifier
hi def link mpostDelimiter Delimiter

