# Neovim Configuration

A single-file Neovim setup optimized for Scala, Go, and Gleam development. Based on [kickstart.nvim](https://github.com/nvim-kickstart/kickstart.nvim), simplified into one `init.lua` with everything included.

## Requirements

- **Neovim** >= 0.10 (`brew install neovim`)
- **Git** (`brew install git`)
- **ripgrep** for live grep search (`brew install ripgrep`)
- **make** for building telescope-fzf-native
- **[Nerd Font](https://www.nerdfonts.com/)** for icons (recommended: JetBrainsMono Nerd Font)

### For Scala development

- **[SDKMAN](https://sdkman.io/)** for managing Java versions
- Java 17+ (for the Metals LSP server)
- A `.sdkmanrc` file in your project root specifying the Java version

## Installation

```bash
# Back up your existing config (if any)
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this repo
git clone https://github.com/YOUR_USERNAME/nvim.git ~/.config/nvim

# Start Neovim — plugins will auto-install on first launch
nvim
```

On first launch, lazy.nvim will automatically download and install all plugins. This may take a minute. You'll also want to run `:Mason` to verify LSP servers are installed.

## File Structure

```
~/.config/nvim/
├── init.lua        ← entire configuration (single file)
├── .stylua.toml    ← Lua formatter settings
└── .gitignore
```

That's it. No `lua/` directory, no scattered plugin files.

## Keybinding Reference

The leader key is **Space**. Press it and wait — [which-key](https://github.com/folke/which-key.nvim) will show all available bindings.

### Navigation

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between split windows |
| `Shift+H` / `Shift+L` | Previous / next buffer tab |
| `\` | Toggle file explorer (Neo-tree) |
| `[q` / `]q` | Previous / next quickfix item |

### Search (Telescope)

| Key | Action |
|-----|--------|
| `<leader>sf` | Find files by name |
| `<leader>sg` | Grep (search text) across all files |
| `<leader>sd` | Search diagnostics (errors/warnings) |
| `<leader>s.` | Recently opened files |
| `<leader>/` | Search within the current file |
| `<leader><leader>` | Switch between open buffers |
| `<leader>sk` | Search all keybindings |
| `<leader>sh` | Search help documentation |

### LSP (code intelligence)

| Key | Action |
|-----|--------|
| `K` | Hover documentation (type info, docs) |
| `grd` | Go to definition |
| `grr` | Find all references |
| `gri` | Go to implementation |
| `grn` | Rename symbol across the project |
| `gra` | Code actions (quick fixes, refactors) |
| `gO` | Document symbols (outline of current file) |
| `<leader>e` | Show full error message in a float |
| `<leader>th` | Toggle inlay hints (inline type annotations) |
| `<leader>f` | Format the current buffer |

### Git

| Key | Action |
|-----|--------|
| `<leader>gs` | Git status (fugitive) |
| `<leader>gb` | Git blame |
| `<leader>gd` | Diff current file against index |
| `<leader>gm` | **3-way merge** for conflict resolution |
| `<leader>gl` | Git log |
| `<leader>gp` | Git push |
| `]c` / `[c` | Jump between git hunks / diff conflicts |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame current line |
| `<leader>tb` | Toggle inline blame |

### Git Conflict Resolution

When you have merge conflicts, this setup provides IntelliJ-style 3-panel resolution:

1. Open a file with conflicts
2. Press `<leader>gm` to open the 3-way split:
   ```
   ┌──────────┬──────────┬──────────┐
   │  LEFT    │  MIDDLE  │  RIGHT   │
   │  (ours)  │ (working)│ (theirs) │
   └──────────┴──────────┴──────────┘
   ```
3. Put your cursor in the **middle** pane, then:
   - `]c` / `[c` — jump between conflicts
   - `:diffget //2` — take the change from the left (ours)
   - `:diffget //3` — take the change from the right (theirs)
   - Or just edit the middle pane manually
4. `:w` to save, then `:only` to close the side panes

### Scala / Metals

| Key | Action |
|-----|--------|
| `<leader>mc` | Metals commands menu |
| `<leader>mi` | Import build (download dependencies) |
| `<leader>mo` | Organize imports |
| `<leader>mr` | Run code lens (run/test above classes) |
| `<leader>mt` | Toggle metals tree view |

### Debugging (DAP)

| Key | Action |
|-----|--------|
| `<leader>dc` | Start / continue debugging |
| `<leader>db` | Toggle breakpoint |
| `<leader>dso` | Step over |
| `<leader>dsi` | Step into |
| `<leader>dK` | Hover value (inspect variable) |
| `<leader>dr` | Toggle REPL |

### Toggles

| Key | Action |
|-----|--------|
| `<leader>th` | Toggle inlay hints |
| `<leader>tb` | Toggle inline git blame |
| `<leader>ti` | Toggle indent guides |
| `<leader>tD` | Toggle deleted lines preview |

### Buffers

| Key | Action |
|-----|--------|
| `Shift+H` / `Shift+L` | Cycle through buffer tabs |
| `<leader>bp` | Pin/unpin buffer |
| `<leader>bc` | Close buffer |

## Included Plugins

| Plugin | Purpose |
|--------|---------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP configuration |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP/tool installer |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Autocompletion |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Code formatting |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git gutter signs |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Git commands |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Buffer tabs |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding popup |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | Statusline, surround, text objects |
| [nvim-metals](https://github.com/scalameta/nvim-metals) | Scala LSP (Metals) |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug adapter |
| [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | Colorscheme |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [fidget.nvim](https://github.com/j-hui/fidget.nvim) | LSP progress indicator |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight TODO/FIXME |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indent guides |

## LSP Servers

Managed by Mason (auto-installed):
- **lua_ls** — Lua
- **gopls** — Go
- **jsonls** — JSON
- **yamlls** — YAML
- **dockerls** — Dockerfile

Not managed by Mason:
- **gleam** — Gleam (install with `brew install gleam`)
- **metals** — Scala (managed by nvim-metals plugin)

## Customization

Everything is in `init.lua`. The file is organized into clearly labeled sections:

1. **Leader key** — change your prefix key
2. **Options** — Neovim behavior settings
3. **Keymaps** — non-plugin keybindings
4. **Autocommands** — automatic actions (autosave, yank highlight)
5. **Java version** — Scala/SDKMAN configuration
6. **Plugins** — all plugin specs with inline comments

To add a new LSP server, add it to the `servers` table in the LSP section and restart Neovim. Mason will install it automatically.

To change the colorscheme, find `vim.cmd.colorscheme 'kanagawa-dragon'` and replace it. Available: `kanagawa`, `kanagawa-wave`, `kanagawa-dragon`, `kanagawa-lotus`, `gruber-darker`.
