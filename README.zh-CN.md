# cort.nvim

[English](README.md) · [安装指南（英文）](INSTALL.md) · [开发指南（英文）](DEV.md)

从零构建的模块化 Neovim IDE 配置，基于 **Neovim 0.12+ 原生 API**、**lazy.nvim** 和 **OneDarkPro / onedark**，不依赖配置发行版。

集成导航、编辑增强、原生 LSP、补全、格式化、Git、调试和会话管理，同时保留对外部工具与自动操作的控制。**接入某项功能不代表对应语言服务器、格式化器或调试器已经安装。**

## 特性

- **统一界面**：onedark、lualine、which-key、文件图标、圆角浮窗与实际行号。
- **导航搜索**：Neo-tree、Telescope + fzf-native、Flash 跳转与 TODO 搜索。
- **编辑增强**：Treesitter 高亮、缩进参考线、自动括号、注释、Surround 与保持窗口布局的 Buffer 关闭。
- **语言工具**：原生 Neovim LSP、blink.cmp、可选 Mason 安装、Conform、nvim-lint 与 Trouble。
- **Git**：Gitsigns Hunk 操作、Telescope Git 搜索与可选 LazyGit。
- **调试与项目**：nvim-dap / dap-ui、GDB / debugpy、显式 CMake 配置与构建、大文件保护。
- **会话与剪贴板**：自动保存会话但不自动恢复；原生剪贴板检测，WSL 可回退到 PowerShell Unicode 通道。

完整上游列表见 [插件与 parser 来源（英文）](docs/plugin-sources.md)。

## 环境要求

- Neovim **0.12+**，当前在 0.12.5 上验证。
- Git、`rg`、`fd`。
- C 编译器、`make`、`tar`、`curl`，供相关插件和 parser 构建使用。
- tree-sitter CLI **0.26.1+**，适配当前 nvim-treesitter `main`。
- 推荐终端使用 Nerd Font，以正确显示图标。

语言服务器、格式化器、Lint 和调试器按需准备。具体步骤及平台说明见 [INSTALL.md](INSTALL.md)。

## 快速开始

已有 Neovim 配置时先备份或移走，不要覆盖正在使用的目录。

```bash
git clone https://github.com/wchiway/cort.nvim.git ~/.config/nvim
nvim --headless -i NONE -c 'Lazy! install' -c 'qa!'
```

Windows 或自定义 `XDG_CONFIG_HOME` 环境请使用自己的 Neovim 配置目录。

缺少 lazy.nvim 时，配置会从 GitHub 引导安装。其它缺失插件不会在启动时静默安装；上面的命令会主动下载插件并可能执行构建步骤。

进入 Neovim 后执行：

```vim
:TSInstallConfigured
:checkhealth config
```

默认列表包含 17 种语言/parser 变体。语言服务器仅在可执行命令存在时启用；可在 `:Mason` 中按需安装，再执行 `:LspEnableAvailable`。

## 默认行为

用户开关位于 [`lua/config/settings.lua`](lua/config/settings.lua)。

| 设置 | 默认值 | 行为 |
| --- | --- | --- |
| `format_on_save` | `false` | `Space cf` 手动格式化 |
| `lint_on_save` | `false` | `Space cL` 手动运行可用 Lint |
| `auto_install_lsp` | `false` | 不批量安装语言服务器 |
| `treesitter.install_missing` | `false` | 显式安装已配置 parser |
| `session_autosave` | `true` | 自动保存，但不自动恢复会话 |
| `clipboard` | `'auto'` | 检测可用通道；WSL 可使用 PowerShell |
| `large_file` | 1 MiB / 20000 行 | 大文件停用重功能 |

基础选项位于 [`lua/config/options.lua`](lua/config/options.lua)。行号默认使用连续的实际行号，不使用相对行号；主题与当前行高亮独立保留。

## 常用快捷键

Leader / LocalLeader 均为 **Space**，字母大小写有意义。

| 按键 | 功能 |
| --- | --- |
| `Space e` | 文件树 |
| `Space ff` / `fg` / `fb` / `fr` | 文件 / 全文 / Buffer / 最近文件 |
| `Space sv` / `sh` / `se` / `sc` | 垂直分屏 / 水平分屏 / 等分 / 关闭 |
| `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` | 切换窗口 |
| `Space bd` / `bn` / `bp` | 安全关闭 / 下一个 / 上一个 Buffer |
| `gd` / `gD` / `gI` / `gr` | 定义 / 声明 / 实现 / 引用 |
| `K` / 插入模式 `Ctrl+k` | Hover / 签名帮助 |
| `Space ca` / `cr` / `cf` / `cL` | Code Action / 重命名 / 格式化 / Lint |
| `Space xx` / `xX` | 工作区 / 当前 Buffer 诊断 |
| `Space gg` | LazyGit；缺失时使用 Telescope Git 状态 |
| `Space hs` / `hr` / `hp` / `hb` | 暂存 / 撤销 / 预览 Hunk / Blame |
| `F5` / `F10` / `F11` / `Shift+F11` | 调试继续 / 跳过 / 进入 / 跳出 |
| `Space db` / `dc` / `du` / `dx` | 断点 / 调试继续 / 调试界面 / 停止 |
| `Space qs` / `ql` / `qd` | 当前目录会话恢复 / 最近恢复 / 停止保存 |
| `gcc` / `gbc` | 行注释 / 块注释 |
| `ys` / `ds` / `cs` | 添加 / 删除 / 修改 Surround |
| `Ctrl+S` / `Space w` | 保存 |
| 可视/选择模式 `Ctrl+C` / `Space p` | 复制选区 / 粘贴系统剪贴板 |
| 终端模式 `Esc Esc` | 离开终端输入模式 |

插件功能键按需加载，LSP 功能键在服务器附着后注册。完整快捷键见 [英文 README](README.md)。

## 配置与开发

- `init.lua`：版本检查、Leader 与模块入口。
- `lua/config/`：用户设置、基础选项、键位、事件、剪贴板、健康检查与项目辅助。
- `lua/plugins/`：按功能拆分的 lazy.nvim spec。
- `lazy-lock.json`：插件版本记录。
- `tests/`：集成测试与 GDB DAP 握手测试。

架构、验证、文档和提交规范见 [DEV.md（英文）](DEV.md)。英文 README 是主文档，中文版本用于快速了解；其余公开文档统一使用英文。

插件安装/更新会下载并可能执行上游代码。CMake 构建、调试启动、格式化、Lint 与剪贴板操作默认主动触发；语言服务器启用后可能调用自己的项目工具。本配置不修改 Shell、系统包管理器或代理设置。
