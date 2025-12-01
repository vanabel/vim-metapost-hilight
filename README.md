# MetaPost 高亮插件

这是一个 Vim 插件，用于在 LaTeX 文件中高亮显示 MetaPost 代码块。

## 功能特性

- 自动识别以下环境并提供语法高亮：
  - `\begin{mpostfig} ... \end{mpostfig}` - MetaPost 代码块
  - `\begin{mpostdef} ... \end{mpostdef}` - MetaPost 定义块
  - `\begin{mposttex} ... \end{mposttex}` - LaTeX 代码块
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
Plug 'your-username/MetaPostHilight'
call plug#end()
```

然后运行 `:PlugInstall` 安装插件。

#### Pathogen
```bash
cd ~/.vim/bundle
git clone https://github.com/your-username/MetaPostHilight.git
```

#### Vundle
在 `~/.vimrc` 中添加：
```vim
Plugin 'your-username/MetaPostHilight'
```

#### Packer (Neovim)
在 `~/.config/nvim/lua/plugins.lua` 中添加：
```lua
use 'your-username/MetaPostHilight'
```

## 使用方法

1. 打开包含 MetaPost 代码的 LaTeX 文件（`.tex` 扩展名）
2. 语法高亮会自动应用到以下环境中的代码：
   - `\begin{mpostfig} ... \end{mpostfig}` - MetaPost 代码
   - `\begin{mpostdef} ... \end{mpostdef}` - MetaPost 定义
   - `\begin{mposttex} ... \end{mposttex}` - LaTeX 代码
3. 无需额外配置，插件会自动工作

### 示例

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
MetaPostHilight/
├── syntax/
│   └── mpost.vim              # MetaPost 语法定义
├── after/
│   └── syntax/
│       └── tex.vim            # LaTeX 文件中的嵌入语法
├── plugin/
│   └── metapost-hilight.vim   # 主插件文件
├── test.tex                   # 测试文件
└── README.md
```

## 工作原理

插件通过以下方式工作：

1. `syntax/mpost.vim` 定义了 MetaPost 的语法规则，包括关键字、函数、运算符等
2. `after/syntax/tex.vim` 检测 LaTeX 文件中的以下环境：
   - `\begin{mpostfig} ... \end{mpostfig}` - 应用 MetaPost 语法高亮
   - `\begin{mpostdef} ... \end{mpostdef}` - 应用 MetaPost 语法高亮
   - `\begin{mposttex} ... \end{mposttex}` - 应用 LaTeX 语法高亮
3. 在检测到的环境中，应用相应的语法高亮（MetaPost 环境与 `ft=mp` 文件的高亮效果一致）
4. `plugin/metapost-hilight.vim` 提供插件初始化和命令

### 使用内置 MetaPost 语法

默认情况下，插件使用自定义的 MetaPost 语法文件（兼容性更好）。如果您想尝试使用 Vim 内置的 `syntax/mp.vim`（与 `ft=mp` 完全一致），可以在 `~/.vimrc` 中设置：

```vim
let g:metapost_use_builtin_syntax = 1
```

**注意**：由于 Vim 内置的 `mp.vim` 使用 vim9script，在某些情况下可能无法正常工作。如果遇到问题，请移除该设置，使用默认的自定义语法。

## 故障排除

如果语法高亮没有正确显示：

1. 确保文件类型正确设置为 `tex`：`:set filetype=tex`
2. 手动重新加载语法：`:MetaPostReload`
3. 检查 Vim 版本（建议 7.4+ 或 Neovim）
4. 确保插件文件在正确的路径下

## 许可证

MIT License

