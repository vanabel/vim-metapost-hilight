# MetaPost 高亮插件

这是一个 Vim 插件，用于在 LaTeX 文件中高亮显示 MetaPost 代码块。

## 功能特性

- 自动识别以下环境并提供语法高亮：
  - `\begin{mpostfig} ... \end{mpostfig}` - MetaPost 代码块
  - `\begin{mpostdef} ... \end{mpostdef}` - MetaPost 定义块
  - `\begin{mposttex} ... \end{mposttex}` - LaTeX 代码块
- **mpgraphics 包支持**：
  - `\begin{mpdisplay} ... \end{mpdisplay}` - MetaPost 图形（居中显示）
  - `\begin{mpinline} ... \end{mpinline}` - MetaPost 图形（内联模式）
  - `\begin{mpdefs} ... \end{mpdefs}` - MetaPost 全局定义
  - `\begin{ltxpreamble} ... \end{ltxpreamble}` - LaTeX 包和宏
- 高亮 MetaPost 关键字、函数、变量、注释等
- 支持常见的 MetaPost 语法元素
- 自动应用于 `.tex` 文件

## 安装方法

### 手动安装

1. 将整个插件目录复制到 Vim 的运行时路径：
   ```bash
   cp -r MetaPostHilight ~/.vim/
   ```

   或者如果使用 Neovim：
   ```bash
   cp -r MetaPostHilight ~/.config/nvim/
   ```

### 使用插件管理器

#### Vim-Plug

**方式一：使用本地路径（推荐用于本地开发）**

如果您的插件目录在本地，例如 `/Users/vanabel/development/vim/MetaPostHilight`，在 `~/.vimrc` 中添加：

```vim
call plug#begin('~/.vim/myvim/plugged/')
Plug '/Users/vanabel/development/vim/MetaPostHilight'
call plug#end()
```

或者使用相对路径（如果插件在您的 home 目录下）：

```vim
call plug#begin('~/.vim/myvim/plugged/')
Plug '~/development/vim/MetaPostHilight'
call plug#end()
```

**方式二：使用 Git 仓库**

如果插件已推送到 Git 仓库，可以使用：

```vim
call plug#begin('~/.vim/myvim/plugged/')
Plug 'vanabel/vim-metapost-hilight'
call plug#end()
```

然后运行 `:PlugInstall` 安装插件。

#### Pathogen
```bash
cd ~/.vim/bundle
git clone https://github.com/vanabel/vim-metapost-hilight.git
```

#### Vundle
在 `~/.vimrc` 中添加：
```vim
Plugin 'vanabel/vim-metapost-hilight'
```

#### Packer (Neovim)
在 `~/.config/nvim/lua/plugins.lua` 中添加：
```lua
use 'vanabel/vim-metapost-hilight'
```

## 使用方法

1. 打开包含 MetaPost 代码的 LaTeX 文件（`.tex` 扩展名）
2. 语法高亮会自动应用到以下环境中的代码：
   - `\begin{mpostfig} ... \end{mpostfig}` - MetaPost 代码
   - `\begin{mpostdef} ... \end{mpostdef}` - MetaPost 定义
   - `\begin{mposttex} ... \end{mposttex}` - LaTeX 代码
   - `\begin{mpdisplay} ... \end{mpdisplay}` - MetaPost 图形（mpgraphics 包）
   - `\begin{mpinline} ... \end{mpinline}` - MetaPost 图形内联（mpgraphics 包）
   - `\begin{mpdefs} ... \end{mpdefs}` - MetaPost 全局定义（mpgraphics 包）
   - `\begin{ltxpreamble} ... \end{ltxpreamble}` - LaTeX 包和宏（mpgraphics 包）
3. 无需额外配置，插件会自动工作

### 示例

#### 基础用法（`mpostinl` 包）

```latex
\begin{mpostdef}
  input 3danim; drawing_scale:=10cm;
\end{mpostdef}

\begin{mposttex}
\usepackage[enc]{inputenc}
\end{mposttex}

\begin{mpostfig}
  numeric pi, b, c, d, e;
  pi = 3.14;
  b = pi/6; c = pi/3;
  set_point_(1)(0,0,0); %A
  vec_def_vec_(v_a, vec_I);
  vec_rotate_(v_a, vec_K, d);
\end{mpostfig}
```

#### mpgraphics 包示例

根据 [mpgraphics 包文档](https://mirror-hk.koddos.net/CTAN/macros/latex/contrib/mpgraphics/mpgraphics.pdf)，以下示例展示了如何使用 mpgraphics 包：

```latex
% 全局 MetaPost 定义和输入
\begin{mpdefs}
  input boxes;
  u := 1cm;
\end{mpdefs}

% LaTeX 包和宏（在 MetaPost 图形中使用的包）
\begin{ltxpreamble}
\usepackage{amsmath}
\usepackage{graphicx}
\end{ltxpreamble}

% 居中显示的 MetaPost 图形
\begin{mpdisplay}
beginfig(1);
  u := 1cm;
  draw (2u,2u) -- (0,0) -- (0,3u) -- (3u,0) -- (0,0);
  label.top(btex $x$ etex, (1.5u, 3u));
  label.rt(btex $y$ etex, (3u, 1.5u));
endfig;
\end{mpdisplay}

% 内联模式的 MetaPost 图形
\begin{mpinline}
beginfig(2);
  draw fullcircle scaled 1cm;
endfig;
\end{mpinline}
```

**注意**：使用 mpgraphics 包时，需要：
- 使用 `-shell-escape` 选项编译 LaTeX 文档
- 确保已安装 MetaPost 和 epstopdf 程序

## 高亮元素

- **关键字**：`numeric`, `string`, `boolean`, `new_vec`, `free_vec`, `set_point_`, `vec_def_vec_`, `vec_rotate_`, `vec_prod_`, `vec_mult_`, `vec_sum_`, `vec_diff`, `vec_unit` 等
- **函数**：`cosd`, `sind`, `cos`, `sin`, `sqrt`, `pnt`, `length`, `angle`, `direction` 等
- **常量**：`vec_I`, `vec_J`, `vec_K`, `vec_0`, `true`, `false`, `infinity` 等
- **注释**：以 `%` 开头的行
- **数字**：整数和浮点数（包括科学计数法）
- **运算符**：`+`, `-`, `*`, `/`, `=`, `==`, `!=`, `<=`, `>=` 等
- **变量和标识符**：包含字母、数字和下划线的标识符
- **字符串**：双引号包围的字符串

## 命令

- `:MetaPostReload` - 手动重新加载语法高亮（如果高亮没有正确显示，可以尝试此命令）

## 文件结构

```
vim-metapost-hilight/
├── syntax/
│   └── mpost.vim              # MetaPost 语法定义
├── after/
│   └── syntax/
│       └── tex.vim            # LaTeX 文件中的嵌入语法
├── plugin/
│   └── metapost-hilight.vim   # 主插件文件
├── test-mpostinl.tex         # mpostinl 包测试文件
├── test-mpgraphics.tex       # mpgraphics 包测试文件
└── README.md
```

## 工作原理

插件通过以下方式工作：

1. `syntax/mpost.vim` 定义了 MetaPost 的语法规则，包括关键字、函数、运算符等
2. `after/syntax/tex.vim` 检测 LaTeX 文件中的以下环境：
   - `\begin{mpostfig} ... \end{mpostfig}` - 应用 MetaPost 语法高亮
   - `\begin{mpostdef} ... \end{mpostdef}` - 应用 MetaPost 语法高亮
   - `\begin{mposttex} ... \end{mposttex}` - 应用 LaTeX 语法高亮
   - `\begin{mpdisplay} ... \end{mpdisplay}` - 应用 MetaPost 语法高亮（mpgraphics 包）
   - `\begin{mpinline} ... \end{mpinline}` - 应用 MetaPost 语法高亮（mpgraphics 包）
   - `\begin{mpdefs} ... \end{mpdefs}` - 应用 MetaPost 语法高亮（mpgraphics 包）
   - `\begin{ltxpreamble} ... \end{ltxpreamble}` - 应用 LaTeX 语法高亮（mpgraphics 包）
3. 在检测到的环境中，应用相应的语法高亮（MetaPost 环境与 `ft=mp` 文件的高亮效果一致）
4. `plugin/metapost-hilight.vim` 提供插件初始化和命令

### 支持的包

- **mpostinl 包**：支持 `mpostfig`、`mpostdef`、`mposttex` 环境
- **mpgraphics 包**：支持 `mpdisplay`、`mpinline`、`mpdefs`、`ltxpreamble` 环境
  - 参考：[mpgraphics 包文档](https://mirror-hk.koddos.net/CTAN/macros/latex/contrib/mpgraphics/mpgraphics.pdf)

### 使用内置 MetaPost 语法

默认情况下，插件使用自定义的 MetaPost 语法文件（兼容性更好）。如果您想尝试使用 Vim 内置的 `syntax/mp.vim`（与 `ft=mp` 完全一致），可以在 `~/.vimrc` 中设置：

```vim
let g:metapost_use_builtin_syntax = 1
```

**说明**：
- 这个变量**确实会影响高亮行为**：它控制 MetaPost 代码块使用哪个语法定义文件
- `= 1`：使用 Vim 内置的 `$VIMRUNTIME/syntax/mp.vim`（与 `ft=mp` 文件的高亮一致）
- `= 0` 或未设置：使用自定义的 `syntax/mpost.vim`（推荐，包含所有非标准关键字）
- **注意**：由于 Vim 内置的 `mp.vim` 使用 vim9script，在某些情况下可能无法正常工作。如果遇到问题，请移除该设置，使用默认的自定义语法。

**关于 tex 语法**：
- 本插件**不控制** LaTeX/TeX 语法本身，tex 语法由 Vim 的标准语法文件控制
- 本插件只在 tex 文件中添加对 MetaPost 环境的支持
- 因此**不需要** `g:tex_use_builtin_syntax` 变量

### 自定义关键字、函数和常量

如果您使用扩展的 MetaPost 库（如自定义宏或第三方库），可以在 `~/.vimrc` 中添加自定义关键字、函数和常量，让它们也被正确高亮：

```vim
" 自定义关键字（如扩展库提供的特殊命令）
let g:metapost_custom_keywords = [
  \ 'my_custom_keyword',
  \ 'another_keyword',
  \ 'special_command'
\ ]

" 自定义函数（如扩展库提供的函数）
let g:metapost_custom_functions = [
  \ 'my_function',
  \ 'another_func',
  \ 'custom_transform'
\ ]

" 自定义常量（如扩展库提供的常量）
let g:metapost_custom_constants = [
  \ 'MY_CONSTANT',
  \ 'PI_VALUE',
  \ 'DEFAULT_SCALE'
\ ]
```

**说明**：
- 支持包含下划线的名称（如 `set_point_`、`vec_def_vec_` 等）
- 关键字会被高亮为 `Keyword` 类型
- 函数会被高亮为 `Function` 类型
- 常量会被高亮为 `Constant` 类型
- 这些自定义定义会与内置的关键字、函数和常量一起工作

## 故障排除

如果语法高亮没有正确显示：

1. 确保文件类型正确设置为 `tex`：`:set filetype=tex`
2. 手动重新加载语法：`:MetaPostReload`
3. 检查 Vim 版本（建议 7.4+ 或 Neovim）
4. 确保插件文件在正确的路径下

## 许可证

MIT License

