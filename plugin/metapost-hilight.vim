" MetaPost 高亮插件
" 为 LaTeX 文件中的 MetaPost 代码块提供语法高亮
"
" 使用方法：
" 1. 将插件目录放到 ~/.vim/ 或使用插件管理器
" 2. 打开包含 \begin{mpostfig} ... \end{mpostfig} 的 tex 文件
" 3. 语法高亮会自动应用

if exists("g:loaded_metapost_hilight")
  finish
endif
let g:loaded_metapost_hilight = 1

" 检测 tex 文件类型并启用语法高亮
augroup MetaPostHilight
  autocmd!
  autocmd FileType tex,plaintex,context syntax sync minlines=50
augroup END

" 命令：手动重新加载语法
command! MetaPostReload syntax sync fromstart

