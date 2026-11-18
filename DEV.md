# Development

[README](README.md) · [Installation](INSTALL.md) · [简体中文](README.zh-CN.md)

cort.nvim is a from-scratch Neovim configuration, not a distribution or a plugin framework. Changes should keep the configuration modular, native-first, and explicit about external actions.

## Architecture

```text
cort.nvim/
├── init.lua
├── lazy-lock.json
├── lua/config/
│   ├── settings.lua
│   ├── options.lua
│   ├── keymaps.lua
│   ├── autocmds.lua
│   ├── bigfile.lua
│   ├── clipboard.lua
│   ├── projects.lua
│   ├── dap_helpers.lua
│   ├── health.lua
│   └── lazy.lua
├── lua/plugins/
│   ├── colorscheme.lua
│   ├── ui.lua
│   ├── explorer.lua
│   ├── telescope.lua
│   ├── treesitter.lua
│   ├── editor.lua
│   ├── completion.lua
│   ├── lsp.lua
│   ├── formatting.lua
│   ├── lint.lua
│   ├── git.lua
│   ├── dap.lua
│   └── session.lua
├── tests/
│   ├── integration.lua
│   └── dap.lua
└── docs/plugin-sources.md
```

`init.lua` checks Neovim compatibility, sets Leader/LocalLeader, then loads options, keymaps, autocmds, project commands, and lazy.nvim. It should remain a small entry point.

### Module responsibilities

- **`settings.lua`:** user-facing switches and thresholds, without plugin side effects.
- **`options.lua`:** base editor options, provider setup, diagnostics, and process-local tool PATH handling.
- **`keymaps.lua`:** basic editor mappings; plugin mappings belong in their lazy specs or LSP attachment handlers.
- **`autocmds.lua` / `bigfile.lua`:** editor events and safeguards for expensive features.
- **`clipboard.lua`:** provider selection and conditional platform fallback.
- **`projects.lua` / `dap_helpers.lua`:** explicit CMake actions and debugger/tool detection.
- **`health.lua`:** environment checks that distinguish required tools from optional integrations.
- **`lazy.lua`:** manager bootstrap and plugin loading policy.
- **`lua/plugins/`:** one feature-oriented spec per area, with dependencies declared through lazy.nvim.

Do not restore the retired `G` facade or `lua/pack/` architecture.

## Implementation conventions

- Target **Neovim 0.12+** and use native `vim.*` APIs.
- Use 4-space Lua indentation and follow surrounding naming, quoting, and comment density.
- Prefer native `vim.lsp.config` / `vim.lsp.enable`; do not introduce deprecated `lspconfig.setup` configuration.
- Keep OneDarkPro's `onedark` as the active theme.
- Use the maintained nvim-treesitter `main` APIs. Do not mix old `configs.setup` examples into the current integration or replace `vim.treesitter.start` globally.
- Check upstream documentation for the installed plugin revision before changing an API integration.
- Do not add overlapping plugins for functionality already covered by the configuration.
- Preserve large-file protection when adding highlighting, completion, LSP, or scanning features.
- Detect optional executables instead of assuming they are installed. Missing optional tools should not break unrelated startup paths.
- Keep shell, system package manager, proxy, and unrelated user files outside configuration changes.

## External-action policy

Default startup must not bulk-install language servers, automatically restore sessions, build user projects through CMake helpers, or launch user debug targets.

The lazy.nvim manager bootstraps when missing. Explicit plugin installs/updates and parser builds can download and execute third-party code; document those actions and their sources. Language servers may invoke their own tooling after they are enabled.

Formatting and lint-on-save remain opt-in. Debugger launches and CMake builds require an explicit user action. Do not access a real clipboard during automated tests; use the existing substitute provider.

`lazy-lock.json` records plugin revisions. Do not hand-edit it, silently upgrade unrelated plugins, or bypass TLS checks to make downloads succeed. An intentional update should be scoped, documented, and tested.

## Validation

### Static analysis

From the repository root:

```bash
luacheck init.lua lua tests --std luajit --no-config --no-default-config --no-cache \
    --no-max-line-length --globals vim
git diff --check
```

### Integration suite

```bash
nvim --headless -i NONE -u tests/integration.lua
```

This suite requires the configured plugins and parsers plus available clangd, rust-analyzer, and a GDB with DAP support. It creates temporary projects and uses a clipboard substitute.

Coverage includes:

- Plugin installation/configuration and parser/query availability.
- Native LSP configuration and real clangd/rust-analyzer attachment to temporary projects.
- Absolute line-number options and split-window inheritance.
- Comments, surrounds, autopairs, and layout-preserving buffer removal.
- Telescope, Neo-tree, diagnostics, and debug UI setup.
- Formatting behavior and large-file protection.
- Keymap consistency and registered project commands.

The suite does not install missing external tools or prove that every optional language/debug adapter works. In particular, configuring Python DAP is not a substitute for testing an installed debugpy adapter.

### GDB DAP protocol test

```bash
nvim --headless -u NONE -i NONE -l tests/dap.lua
```

This starts GDB's DAP interpreter, verifies initialization/disconnection, and does not launch an inferior or a user program. It requires GDB 14+ with Python support.

### Manual checks

Use `:checkhealth config`, `:Lazy`, `:LspInfo`, and `:ConformInfo` as appropriate. Inspect real terminal behavior when changing UI, fonts, clipboard handling, or key mappings; headless tests alone do not verify rendering or host clipboard synchronization.

Report failures and skipped checks accurately. Do not remove a safeguard or weaken an assertion merely to hide an unavailable dependency.

## Performance checks

Measure with a fresh log and state the cache conditions:

```bash
startup_log=$(mktemp /tmp/cort-nvim-startup.XXXXXX)
nvim --headless -i NONE --startuptime "$startup_log" -c 'qa!'
bat "$startup_log"
```

Headless startup measurements exclude later lazy loads, language-server initialization, and real terminal rendering. Do not present a local number as an all-platform performance guarantee.

## Documentation

- `README.md` is the primary, English project overview.
- `README.zh-CN.md` is the explicitly supported Chinese translation and links back to the English overview.
- `INSTALL.md`, `DEV.md`, and other public documentation are written in English.
- Keep installation commands, defaults, keybindings, tool requirements, and links synchronized with the implementation.
- Do not publish personal backup paths, private assistant instructions, machine-specific state, or unqualified installation/test claims.

Personal `AGENTS.md` and `CLAUDE.md` files remain local and untracked. Use `.git/info/exclude` for local ignore rules rather than adding these personal rules to the shared `.gitignore`:

```gitignore
AGENTS.md
CLAUDE.md
```

Local exclude rules are not distributed to clones. Ignoring a name does not untrack a file that is already in Git; remove it from the index while preserving its working copy if necessary. Historical commits are not rewritten by this operation.

## Git workflow

Work on a topic branch and keep commits focused. Use English [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), for example:

```text
feat: add an editor integration
fix: preserve absolute line numbers in split windows
test: cover optional tool detection
docs: clarify installation requirements
chore: remove retired runtime files
```

Use the configured Git author identity. Do not append automated `Co-Authored-By` trailers or invite repository collaborators as part of routine maintenance. Commit, push, and publish only when explicitly requested; binding a remote is not permission to push.
