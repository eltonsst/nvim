# Neovim Configuration

Single-file Neovim setup for Scala, Go, Gleam, and general backend work.
It started from [kickstart.nvim](https://github.com/nvim-kickstart/kickstart.nvim), but it is now a custom `lazy.nvim` config with:

- native LSP hover/signature popups styled to match Kanagawa
- a polished floating [Oil](https://github.com/stevearc/oil.nvim) explorer
- Scala/Metals support with per-project Java resolution via `.sdkmanrc`
- Go debugging and test running
- documented plugin sections directly inside `init.lua`

## Requirements

- **Neovim** >= 0.11
- **Git**
- **ripgrep** for Telescope live grep
- **make** for `telescope-fzf-native`
- **[Nerd Font](https://www.nerdfonts.com/)** for icons

### Scala

- **[SDKMAN](https://sdkman.io/)** for Java version management
- Java 17+ for the Metals server
- A `.sdkmanrc` file in your project root when the project needs a specific Java version

### Optional external tools

Most LSP servers, formatters, linters, and debugger tools are auto-installed through Mason / mason-tool-installer.

Not managed by Mason in this setup:

- `gleam` LSP support: install `gleam` yourself
- `metals`: managed by `nvim-metals`

## Installation

```bash
# Back up existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this repo
git clone https://github.com/YOUR_USERNAME/nvim.git ~/.config/nvim

# Start Neovim
nvim
```

On first launch, `lazy.nvim` installs the plugin set automatically.

Useful commands after startup:

- `:checkhealth`
- `:Lazy`
- `:Mason`
- `:TSUpdate`

## File Structure

```text
~/.config/nvim/
├── init.lua        # entire config
├── README.md
├── lazy-lock.json  # pinned plugin versions
├── .stylua.toml
└── .gitignore
```

There is no `lua/` directory. Everything lives in `init.lua`.

## Defaults

- Leader key: `Space`
- Colorscheme: `kanagawa-dragon`
- Alternate colorscheme installed: `catppuccin`
- Hover docs on `K` use native Neovim LSP with rounded borders and Kanagawa-matched background
- Oil opens in a styled floating window on `\`
- Files auto-save on `BufLeave`, `FocusLost`, and `InsertLeave`

## Keybindings

Press `Space` and wait to see available leader mappings through `which-key`.

### Navigation

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between split windows |
| `Shift+H` / `Shift+L` | Previous / next buffer |
| `\` | Toggle floating Oil explorer |
| `-` | Open parent directory in the current window |
| `<leader>zz` | Toggle Zen mode |
| `[q` / `]q` | Previous / next quickfix item |
| `<leader>qo` / `<leader>qc` | Open / close quickfix |

### Search

| Key | Action |
|-----|--------|
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>sf` | Find files |
| `<leader>ss` | Telescope builtins |
| `<leader>sw` | Search current word |
| `<leader>sg` | Live grep |
| `<leader>sd` | Workspace diagnostics to quickfix |
| `<leader>sr` | Resume last Telescope picker |
| `<leader>s.` | Recent files |
| `<leader>/` | Search in current buffer |
| `<leader>s/` | Grep in open files |
| `<leader>sn` | Search Neovim config files |
| `<leader><leader>` | Open buffers |

### LSP

| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `grd` | Go to definition |
| `grD` | Go to declaration |
| `grr` | References |
| `gri` | Implementation |
| `grt` | Type definition |
| `grn` | Rename |
| `gra` | Code action |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `<leader>e` | Diagnostic float for current line |
| `<leader>f` | Format buffer |
| `<leader>th` | Toggle inlay hints when supported |

### Git

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next / previous git hunk |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk |
| `<leader>hS` / `<leader>hu` | Stage buffer / undo staged hunk |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame current line |
| `<leader>hd` / `<leader>hD` | Diff against index / last commit |
| `<leader>tb` | Toggle inline blame |
| `<leader>tD` | Preview deleted lines inline |

### Merge Conflicts

| Key | Action |
|-----|--------|
| `]x` / `[x` | Next / previous conflict |
| `<leader>go` | Choose ours |
| `<leader>gt` | Choose theirs |
| `<leader>gb` | Choose both |
| `<leader>g0` | Choose none |
| `<leader>gq` | Remaining conflicts to quickfix |

### Scala / Metals

| Key | Action |
|-----|--------|
| `<leader>mc` | Metals commands |
| `<leader>mi` | Import build |
| `<leader>mo` | Organize imports |
| `<leader>mr` | Run code lens |
| `<leader>mt` | Toggle tree view |
| `<leader>mf` | Reveal file in tree view |

### Debugging

| Key | Action |
|-----|--------|
| `<leader>dc` | Start / continue |
| `<leader>db` | Toggle breakpoint |
| `<leader>dso` | Step over |
| `<leader>dsi` | Step into |
| `<leader>dr` | Toggle REPL |
| `<leader>dK` | Hover value |

### Tests

| Key | Action |
|-----|--------|
| `<leader>tn` | Run nearest test |
| `<leader>tf` | Run current file tests |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Open test output |

### Buffers

| Key | Action |
|-----|--------|
| `Shift+H` / `Shift+L` | Previous / next buffer |
| `<leader>bp` | Pin / unpin buffer |
| `<leader>bc` | Close buffer |

## Included Plugins

### Core UI and navigation

- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [which-key.nvim](https://github.com/folke/which-key.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)
- [telescope-smart-history.nvim](https://github.com/nvim-telescope/telescope-smart-history.nvim)
- [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim)
- [bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
- [mini.nvim](https://github.com/echasnovski/mini.nvim)
- [oil.nvim](https://github.com/stevearc/oil.nvim)
- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim)

### Editing

- [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim)
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs)
- [blink.cmp](https://github.com/saghen/blink.cmp)
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [conform.nvim](https://github.com/stevearc/conform.nvim)
- [nvim-lint](https://github.com/mfussenegger/nvim-lint)
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim)

### Syntax and language tooling

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [mason.nvim](https://github.com/mason-org/mason.nvim)
- [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim)
- [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)
- [lazydev.nvim](https://github.com/folke/lazydev.nvim)
- [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim)
- [fidget.nvim](https://github.com/j-hui/fidget.nvim)
- [nvim-metals](https://github.com/scalameta/nvim-metals)

### Git, debugging, and tests

- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [git-conflict.nvim](https://github.com/akinsho/git-conflict.nvim)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [nvim-dap-go](https://github.com/leoluz/nvim-dap-go)
- [neotest](https://github.com/nvim-neotest/neotest)
- [neotest-golang](https://github.com/fredrikaverpil/neotest-golang)

### Theme

- [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim)
- [catppuccin](https://github.com/catppuccin/nvim)

## LSP Servers

Configured in the `servers` table:

- `lua_ls`
- `gopls`
- `jsonls`
- `yamlls`
- `dockerls`
- `pyright`

Enabled separately outside Mason:

- `gleam`
- `metals`

## Formatters, Linters, and Tools

### Formatters

- Lua: `stylua`
- Scala: `scalafmt`
- Go: `goimports`, `gofumpt`
- YAML: `yamlfmt`
- Python: `ruff_organize_imports`, `ruff_format`

### Linters

- YAML: `yamllint`
- Proto: `protolint`
- Python: `mypy`

### Debug / test tools

- Go debugging: `delve`
- Go tests: `neotest-golang`

## Customization

Everything lives in `init.lua`, organized into labeled sections:

1. Leader key
2. Options
3. Built-in keymaps
4. Autocommands
5. Java version resolution for Metals
6. Plugin specs and configuration

Common edits:

- Change colorscheme:
  edit the final `vim.cmd.colorscheme 'kanagawa-dragon'`
- Add an LSP server:
  add it to the `servers` table in the LSP section
- Add a formatter:
  update `formatters_by_ft` in the `conform.nvim` section
- Add a linter:
  update `linters_by_ft` in the `nvim-lint` section

## Notes

- The hover popup on `K` is native Neovim LSP, not a UI plugin.
- Oil and hover floats are styled to match the main Kanagawa background.
- Quickfix is a first-class workflow in this setup, especially for diagnostics and merge conflicts.
