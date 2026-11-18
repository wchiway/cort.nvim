# Plugin and parser sources

[README](../README.md) · [Installation](../INSTALL.md) · [Development](../DEV.md)

Plugin installation downloads code from the public upstream repositories below and may run configuration or build steps. Specs live in `lua/plugins/`; `lazy-lock.json` records plugin revisions. The manager is bootstrapped separately by `lua/config/lazy.lua`.

## Neovim plugins

| Integration | Upstream |
| --- | --- |
| Plugin manager | [folke/lazy.nvim](https://github.com/folke/lazy.nvim) |
| onedark theme | [olimorris/onedarkpro.nvim](https://github.com/olimorris/onedarkpro.nvim) |
| Statusline | [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) |
| File explorer | [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) |
| Search UI | [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) |
| Native fuzzy sorter | [nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim), built with `make` |
| Shared Lua utilities | [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) |
| UI dependency | [MunifTanjim/nui.nvim](https://github.com/MunifTanjim/nui.nvim) |
| File icons | [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) |
| Keymap help | [folke/which-key.nvim](https://github.com/folke/which-key.nvim) |
| Git signs and hunks | [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) |
| Diagnostics UI | [folke/trouble.nvim](https://github.com/folke/trouble.nvim) |
| Indentation guides | [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) |
| Parser management and queries | [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter), maintained `main` branch |
| Automatic pairs | [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) |
| Comments | [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) |
| Surround operations | [kylechui/nvim-surround](https://github.com/kylechui/nvim-surround) |
| TODO search | [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim) |
| Jump and selection | [folke/flash.nvim](https://github.com/folke/flash.nvim) |
| Buffer removal | [nvim-mini/mini.bufremove](https://github.com/nvim-mini/mini.bufremove) |
| Native LSP configurations | [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) |
| Optional tool installer | [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim) |
| Mason/LSP integration | [mason-org/mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) |
| Completion | [saghen/blink.cmp](https://github.com/saghen/blink.cmp) |
| Formatting | [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) |
| Lint | [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint) |
| DAP client | [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap) |
| DAP UI | [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) |
| Async dependency | [nvim-neotest/nvim-nio](https://github.com/nvim-neotest/nvim-nio) |
| Sessions | [folke/persistence.nvim](https://github.com/folke/persistence.nvim) |

## Syntax parser sources

nvim-treesitter's installed parser manifest specifies source revisions. Parser builds use a C compiler and are installed in Neovim's data directory. Keep parsers compatible with the installed plugin/query revision when updating.

| Parsers | Upstream |
| --- | --- |
| C | [tree-sitter-grammars/tree-sitter-c](https://github.com/tree-sitter-grammars/tree-sitter-c) |
| C++ | [tree-sitter/tree-sitter-cpp](https://github.com/tree-sitter/tree-sitter-cpp) |
| Rust | [tree-sitter/tree-sitter-rust](https://github.com/tree-sitter/tree-sitter-rust) |
| Lua | [tree-sitter-grammars/tree-sitter-lua](https://github.com/tree-sitter-grammars/tree-sitter-lua) |
| Python | [tree-sitter/tree-sitter-python](https://github.com/tree-sitter/tree-sitter-python) |
| Go | [tree-sitter/tree-sitter-go](https://github.com/tree-sitter/tree-sitter-go) |
| JavaScript | [tree-sitter/tree-sitter-javascript](https://github.com/tree-sitter/tree-sitter-javascript) |
| TypeScript / TSX | [tree-sitter/tree-sitter-typescript](https://github.com/tree-sitter/tree-sitter-typescript) |
| JSON | [tree-sitter/tree-sitter-json](https://github.com/tree-sitter/tree-sitter-json) |
| YAML | [tree-sitter-grammars/tree-sitter-yaml](https://github.com/tree-sitter-grammars/tree-sitter-yaml) |
| Bash | [tree-sitter/tree-sitter-bash](https://github.com/tree-sitter/tree-sitter-bash) |
| CMake | [uyha/tree-sitter-cmake](https://github.com/uyha/tree-sitter-cmake) |
| Markdown / inline Markdown | [tree-sitter-grammars/tree-sitter-markdown](https://github.com/tree-sitter-grammars/tree-sitter-markdown) |
| Vim | [tree-sitter-grammars/tree-sitter-vim](https://github.com/tree-sitter-grammars/tree-sitter-vim) |
| Vim help | [neovim/tree-sitter-vimdoc](https://github.com/neovim/tree-sitter-vimdoc) |

## Installation boundaries

- Missing plugins, missing parsers, Mason language servers, and debugpy are not bulk-installed on startup by default. A missing lazy.nvim manager is bootstrapped from its upstream repository.
- Explicit plugin installs/updates and parser builds can download and execute upstream code. Automatic LSP/parser installation is an opt-in setting.
- CMake builds and debug-target launches are explicit project actions. Language servers can invoke their own tooling once enabled.
- Shell, system package manager, and proxy settings are not changed by the configuration.
- Prepare tree-sitter CLI separately. If Neovim's data directory contains `tools/bin`, the configuration adds it to the current process PATH; it does not install a system-wide tool for you.
