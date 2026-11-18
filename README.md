# cort.nvim

[简体中文](README.zh-CN.md) · [Installation](INSTALL.md) · [Development](DEV.md)

A modular, native-first Neovim IDE configuration built from scratch. **Neovim 0.12+**, **lazy.nvim**, and **OneDarkPro / onedark** form the foundation; no configuration distribution is required.

cort.nvim brings navigation, editing, native LSP, completion, formatting, Git, debugging, and sessions together while keeping external tools and automatic actions under your control. A configured integration does **not** mean its language server, formatter, or debugger is already installed.

## Features

- **Consistent UI:** onedark, lualine, which-key, file icons, rounded floats, and absolute line numbers.
- **Navigation:** Neo-tree, Telescope with fzf-native, Flash jumps, and TODO search.
- **Editing:** Treesitter highlighting, indentation guides, autopairs, comments, surround operations, and layout-preserving buffer removal.
- **Language tooling:** native Neovim LSP, blink.cmp, optional Mason installs, Conform, nvim-lint, and Trouble.
- **Git:** Gitsigns hunk actions, Telescope Git pickers, and an optional LazyGit terminal.
- **Debugging:** nvim-dap and dap-ui, GDB for C/C++/Rust, and optional debugpy for Python.
- **Project helpers:** explicit CMake configure/build commands and large-file protection.
- **Sessions and clipboard:** automatic session saving with explicit restoration, native clipboard detection, and a conditional WSL/PowerShell fallback.

See [plugin and parser sources](docs/plugin-sources.md) for the complete upstream list.

## Requirements

- Neovim **0.12+**; the configuration has been validated on 0.12.5.
- Git, `rg`, and `fd`.
- A C compiler, `make`, `tar`, and `curl` for the relevant plugin/parser builds.
- tree-sitter CLI **0.26.1+** for the current nvim-treesitter `main` branch.
- A Nerd Font is recommended for icons.

Language servers, formatters, lint tools, and debuggers are optional, feature-specific dependencies. See [INSTALL.md](INSTALL.md) for setup, platform notes, and troubleshooting.

## Quick start

Back up any existing Neovim configuration before cloning. Do not overwrite a directory that is still in use.

```bash
git clone https://github.com/wchiway/cort.nvim.git ~/.config/nvim
nvim --headless -i NONE -c 'Lazy! install' -c 'qa!'
```

Use your actual Neovim configuration directory on Windows or with a custom `XDG_CONFIG_HOME`.

If lazy.nvim is missing, the configuration bootstraps it from GitHub. Other missing plugins are **not** silently installed on startup; the command above explicitly installs them and may run their build hooks.

Then open Neovim and run:

```vim
:TSInstallConfigured
:checkhealth config
```

The configured parser list contains 17 languages/parser variants. Language servers are enabled only when their executable commands are available; use `:Mason` for optional installs and `:LspEnableAvailable` after adding tools.

## Defaults

Edit [`lua/config/settings.lua`](lua/config/settings.lua) to change user-facing switches.

| Setting | Default | Behavior |
| --- | --- | --- |
| `format_on_save` | `false` | Format explicitly with `Space cf` |
| `lint_on_save` | `false` | Run available lint tools with `Space cL` |
| `auto_install_lsp` | `false` | Do not bulk-install language servers |
| `treesitter.install_missing` | `false` | Install configured parsers explicitly |
| `session_autosave` | `true` | Save sessions, but never restore them automatically |
| `clipboard` | `'auto'` | Detect an available provider; WSL may use PowerShell |
| `large_file` | 1 MiB / 20,000 lines | Disable expensive features for large files |

Base editor options live in [`lua/config/options.lua`](lua/config/options.lua). Line numbers are absolute, not relative. Theme and current-line highlighting remain enabled.

## Keybindings

Both Leader and LocalLeader are **Space**. Letter case matters; `Space cL` and `Space cl` are different mappings.

| Keys | Action |
| --- | --- |
| `Space e` | File tree |
| `Space ff` / `fg` / `fb` / `fr` | Files / live text search / buffers / recent files |
| `Space fk` / `ft` | Keymaps / TODO search |
| `Space sv` / `sh` / `se` / `sc` | Vertical split / horizontal split / equalize / close |
| `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` | Navigate windows |
| `Space bd` / `bn` / `bp` | Remove buffer / next buffer / previous buffer |
| `gd` / `gD` / `gI` / `gr` | LSP definition / declaration / implementation / references |
| `K` / insert-mode `Ctrl+k` | Hover / signature help |
| `Space ca` / `cr` / `cf` | Code action / rename / format |
| `Space ch` / `cR` / `cL` | Inlay hints / CodeLens / lint |
| `Space xx` / `xX` / `xq` / `xl` | Workspace diagnostics / buffer diagnostics / quickfix / location list |
| `Space gg` | LazyGit, or Telescope Git status when unavailable |
| `Space hs` / `hr` / `hp` / `hb` | Stage / reset / preview hunk / blame |
| `]c` / `[c` | Next / previous hunk; native behavior is preserved in diff mode |
| `Space db` / `dB` / `dc` / `du` | Breakpoint / conditional breakpoint / continue / debug UI |
| `F5` / `F10` / `F11` / `Shift+F11` | Continue / step over / step into / step out |
| `Space dr` / `dx` | Debug REPL / stop debugging |
| `Space qs` / `ql` / `qd` / `qq` | Restore directory session / last session / stop saving / confirm quit |
| `s` / `S` | Flash jump / syntax selection |
| `gcc` / `gbc` | Line / block comment |
| `ys` / `ds` / `cs` | Add / delete / change surround |
| `Ctrl+S` / `Space w` | Save |
| Visual/select `Ctrl+C` / `Space p` | Copy selection / paste system clipboard |
| Terminal `Esc Esc` | Leave terminal-input mode |

Plugin mappings load on demand. LSP mappings become available after a server attaches. See [installation and tool setup](INSTALL.md) for language support, CMake, and debugging requirements.

## Layout and development

- `init.lua`: version guard, Leader keys, and module loading.
- `lua/config/`: settings, editor options, keymaps, events, clipboard, health, and project helpers.
- `lua/plugins/`: lazy.nvim specs grouped by feature.
- `lazy-lock.json`: recorded plugin revisions.
- `tests/`: integration coverage and a GDB DAP protocol test.

[DEV.md](DEV.md) describes architecture, validation, documentation conventions, and commit guidelines.

Plugin installation/update can download and execute upstream code. CMake builds, debugger launches, formatting, lint, and clipboard actions are explicit by default. Language servers may invoke their own project tooling once enabled. cort.nvim does not modify your shell, system package manager, or proxy configuration.
