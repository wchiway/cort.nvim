# Installation

[README](README.md) · [简体中文](README.zh-CN.md) · [Development](DEV.md)

This guide separates the editor configuration from the external programs that power individual features. Install only the tools you intend to use.

## 1. Prepare the toolchain

| Tool | Requirement / purpose |
| --- | --- |
| Neovim | **0.12+**; startup rejects older versions |
| Git | lazy.nvim bootstrap and plugin downloads |
| `rg` and `fd` | Telescope text/file searches |
| A C compiler | Treesitter parser compilation |
| `make` | telescope-fzf-native build |
| `tar` and `curl` | Required by the current nvim-treesitter installer |
| tree-sitter CLI | **0.26.1+**; install with a package manager, not npm |
| Other download/unpack tools | Some Mason packages may require `unzip` or additional tools |
| Nerd Font | Recommended for icons; configure it in your terminal |

Use your preferred package manager. For example, a Debian/Ubuntu toolchain with mise-managed modern CLIs can be prepared manually with:

```bash
sudo apt install git ripgrep build-essential tar curl unzip pkg-config
mise use -g neovim@0.12.5 tree-sitter@0.27.2 fd
```

These are optional, user-run setup commands, not actions performed by cort.nvim. Skip tools that are already available. You do not need to change system or proxy settings to load the configuration.

Verify the programs are on the PATH inherited by Neovim:

```bash
nvim --version
git --version
rg --version
fd --version
tree-sitter --version
```

The current nvim-treesitter `main` is an incompatible rewrite of older configurations. Do not mix it with the old `require('nvim-treesitter.configs').setup(...)` API. Parser requirements follow the plugin revision in `lazy-lock.json`; consult [upstream sources](docs/plugin-sources.md) when updating.

## 2. Back up existing state

Back up or move an existing Neovim configuration before installing cort.nvim. Do not clone over an active configuration or write stale buffers back into the new directory.

On Linux, the usual configuration path is `~/.config/nvim`. A custom `XDG_CONFIG_HOME` or Windows installation can use a different path. Plugin data, cache, and session state live separately under Neovim's standard paths; cort.nvim does not delete those directories for you.

```bash
git clone https://github.com/wchiway/cort.nvim.git ~/.config/nvim
```

Use your actual configuration directory if it differs from the example.

## 3. Install plugins explicitly

If a complete lazy.nvim installation is missing, startup clones its stable branch from GitHub. A partial installation produces an error rather than being overwritten; back up or move that partial directory before retrying.

Missing plugin installation and update checks are disabled by default. Install the configured plugins deliberately:

```bash
nvim --headless -i NONE -c 'Lazy! install' -c 'qa!'
```

Alternatively, open `:Lazy` in Neovim and install missing plugins there.

This step downloads third-party code and may execute build hooks, including `make` for fzf-native and `TSUpdate` for nvim-treesitter. See [plugin and parser sources](docs/plugin-sources.md) before installing. Keep `lazy-lock.json`; do not replace recorded revisions with arbitrary values.

Git inherits your existing environment. The configuration does not hard-code proxy addresses or disable TLS verification.

## 4. Install syntax parsers

Inside Neovim, run:

```vim
:TSInstallConfigured
```

The default parser list is:

```text
c, cpp, rust, lua, python, go, javascript, typescript, tsx,
json, yaml, bash, cmake, markdown, markdown_inline, vim, vimdoc
```

Missing parsers are not installed automatically unless you opt into `treesitter.install_missing` in `lua/config/settings.lua`. Installation is asynchronous; wait for it to finish before relying on parser availability.

After an intentional nvim-treesitter update, run `:TSUpdate` so parser revisions remain compatible with the installed queries.

## 5. Add language tools as needed

Servers are configured through native Neovim LSP and enabled only when their commands are executable. Existing system tools are reused. Mason is an optional installer, not a prerequisite for every language.

```vim
:Mason
:LspEnableAvailable
:LspInfo
```

For example, to add Lua tooling through Mason:

```vim
:MasonInstall lua-language-server stylua
:LspEnableAvailable
```

| Language | LSP configuration | Formatter |
| --- | --- | --- |
| C / C++ | `clangd` | `clang-format` |
| Rust | `rust_analyzer` | `rustfmt` |
| Lua | `lua_ls` | `stylua` |
| Python | `basedpyright` | `ruff` |
| Go | `gopls` | `goimports` + `gofmt` |
| JavaScript / TypeScript | `ts_ls` | `prettier` |
| JSON | `jsonls` | `prettier` |
| YAML | `yamlls` | `prettier` |
| Bash | `bashls` | `shfmt` |
| CMake | `neocmake` | `gersemi` |

Python prefers project `.venv` / `venv` environments. Prettier can resolve a project's `node_modules/.bin` installation; a global npm install is not required.

Formatting and lint-on-save are off by default. Use `Space cf` to format and `Space cL` to run available lint tools. `:ConformInfo` explains formatter detection. Conform uses an available external formatter first and falls back to LSP when appropriate. Ruff provides Python linting; basedpyright provides type checking.

Set `auto_install_lsp=true` only if you explicitly want Mason to install the configured missing servers. Some language servers can run their own project tooling after attaching.

### CMake and compile commands

clangd checks the project root, `build`, and `cmake-build-*` for `compile_commands.json`.

- `:CMakeConfigure` / `Space mc` configures the project with compile-command export.
- `:CMakeBuild` / `Space mb` builds it and sends output to quickfix.

Both are explicit project operations. Installing cort.nvim does not invoke these commands for you.

## 6. Configure debugging

### C / C++ / Rust

The adapter uses GDB's built-in DAP support: **GDB 14+ with Python support** is required. An executable named `gdb` alone is not sufficient.

Build your program with debug information, then use `F5` / `Space dc` to choose a launch configuration and provide its executable path. No user program is launched during plugin loading or the DAP handshake test.

### Python

Install debugpy explicitly in a project environment or through `:MasonInstall debugpy`. It is not installed automatically.

Adapter detection prefers the project environment, then Mason's debugpy environment, then an available system installation. The target interpreter prefers the project environment. Use `Space du` for the debug UI and `Space dx` to stop a session.

## 7. Clipboard and terminal notes

`clipboard='auto'` detects a usable native provider. Under WSL, unreliable WSLg synchronization can fall back to a Windows PowerShell Unicode implementation.

Other options are `native`, `windows`, `osc52`, and `off`. Set `windows_powershell` for a nonstandard PowerShell path. These settings are in `lua/config/settings.lua`.

Clipboard behavior depends on the host and terminal. Windows fallback can add visible latency; do not assume every Linux/Windows bridge behaves identically. Automated tests use a substitute and do not read or write your real clipboard.

If icons appear as boxes, select a Nerd Font in your terminal. A GUI Neovim installation is not required. Shell and proxy settings are inherited, not rewritten.

## 8. Verify and troubleshoot

Inside Neovim:

```vim
:checkhealth config
:Lazy
:LspInfo
:ConformInfo
```

| Symptom | Check |
| --- | --- |
| Startup rejects the version | Make sure the selected `nvim` is 0.12+ |
| Missing theme or plugin | Run the explicit plugin installation step and inspect `:Lazy` |
| Parser build failure | Check tree-sitter CLI, C compiler, `tar`, and `curl` |
| Missing LSP features | Check the server executable, project root, and `:LspInfo` |
| No formatting | Check `:ConformInfo`; install a formatter or use an attached LSP |
| DAP unavailable | Check GDB's version/Python support or install debugpy |
| Missing icons | Check the terminal font |
| Large file has fewer features | The 1 MiB / 20,000-line guard is enabled by default |
| Sessions do not restore on startup | Restoration is explicit: `Space qs` or `Space ql` |

Warnings about uninstalled optional language tools do not necessarily mean startup is broken. Full automated verification needs a more complete toolchain; see [DEV.md](DEV.md).
