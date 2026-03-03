-- ============================================================================
-- Neovim Configuration
-- ============================================================================
-- Single-file setup for Scala/Go/Gleam development.
-- Plugins are managed by lazy.nvim (auto-installs on first run).
--
-- Useful commands:
--   :checkhealth   → diagnose issues with your setup
--   :Lazy          → install, update, or remove plugins
--   :Mason         → install or update LSP servers and tools
--   :TSUpdate      → update treesitter parsers (syntax highlighting)
--
-- Tip: press Space (leader key) and wait — which-key will show all
-- available keybindings in a popup.
-- ============================================================================

-- ============================================================================
-- LEADER KEY (must be set before plugins load)
-- ============================================================================
-- The leader key is the prefix for most custom keybindings.
-- Space is the most popular choice because it's easy to reach with either hand.
-- Example: pressing Space then s then f triggers "Search Files".

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ============================================================================
-- NEOVIDE (GPU-accelerated GUI for Neovim)
-- ============================================================================
-- Neovide is an optional desktop app that renders Neovim with smooth
-- animations and GPU acceleration. Install with: brew install --cask neovide
-- Launch with: neovide (it reads this same config automatically)
-- These settings only apply when running inside Neovide; they are
-- silently ignored in a regular terminal.

if vim.g.neovide then
  vim.o.guifont = 'JetBrainsMono Nerd Font Mono'
  vim.g.neovide_scale_factor = 1
  vim.opt.linespace = 2
end

-- Tell plugins we have a Nerd Font installed (enables icons everywhere)
vim.g.have_nerd_font = true

-- ============================================================================
-- OPTIONS
-- ============================================================================
-- These control how Neovim looks and behaves. Each setting is explained below.

vim.o.number = true           -- show line numbers in the gutter
vim.o.foldmethod = 'expr'     -- use treesitter for code folding
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldlevel = 99          -- start with all folds open (99 = don't fold anything)
vim.o.mouse = 'a'             -- enable mouse in all modes (click, scroll, select)
vim.o.showmode = false         -- hide "-- INSERT --" from the bottom (statusline shows it)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus' -- use system clipboard for yank/paste (y, p, d, etc.)
end)
vim.o.breakindent = true       -- wrapped lines continue at the same indent level
vim.o.undofile = true          -- persist undo history across sessions (saved to disk)
vim.o.ignorecase = true        -- search is case-insensitive by default...
vim.o.smartcase = true         -- ...unless you type an uppercase letter
vim.o.signcolumn = 'yes'      -- always show the sign column (git signs, diagnostics)
vim.o.updatetime = 250         -- ms of idle before CursorHold fires (affects LSP highlights)
vim.o.timeoutlen = 300         -- ms to wait for a mapped key sequence (e.g. <leader>sf)
vim.o.splitright = true        -- new vertical splits open to the right
vim.o.splitbelow = true        -- new horizontal splits open below
vim.o.list = true              -- show invisible characters (tabs, trailing spaces)
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'    -- live preview of :s substitutions in a split
vim.o.cursorline = true        -- highlight the line your cursor is on
vim.o.scrolloff = 10           -- keep 10 lines visible above/below cursor when scrolling
vim.o.confirm = true           -- ask to save instead of failing on :q with unsaved changes
vim.o.swapfile = false         -- don't create .swp files (we have undofile + autosave)
vim.o.tabstop = 4              -- display tab characters as 4 spaces wide

-- ============================================================================
-- KEYMAPS (built-in, no plugins required)
-- ============================================================================

-- Clear search highlighting by pressing Escape
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Show all diagnostics (errors/warnings) for the current buffer in a list
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Show the full error/warning message in a floating window at the current line
-- (much easier to read than the truncated inline text)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror float' })

-- Press Escape twice in terminal mode to go back to normal mode
-- (useful when running :terminal or lazygit inside Neovim)
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Move between split windows with Ctrl+hjkl (instead of Ctrl-W then hjkl)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Quickfix list navigation (quickfix = a list of locations, like search results or errors)
vim.keymap.set('n', '<leader>qo', ':copen<CR>', { desc = '[Q]uickfix [O]pen' })
vim.keymap.set('n', '<leader>qc', ':cclose<CR>', { desc = '[Q]uickfix [C]lose' })
vim.keymap.set('n', '[q', ':cprevious<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', ']q', ':cnext<CR>', { desc = 'Next quickfix item' })

-- ============================================================================
-- AUTOCOMMANDS (things that happen automatically in response to events)
-- ============================================================================

-- Briefly highlight yanked (copied) text so you can see what was selected
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto-save files when you leave insert mode, switch buffers, or alt-tab away.
-- This means you never need to manually :w — and it also triggers LSP
-- recompilation (Metals, gopls) so diagnostics update immediately after edits.
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertLeave' }, {
  desc = 'Autosave on focus loss or leaving insert mode',
  group = vim.api.nvim_create_augroup('autosave', { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    if vim.bo[buf].modified and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= '' then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd 'write'
      end)
    end
  end,
})

-- ============================================================================
-- JAVA VERSION RESOLUTION (for Scala/Metals)
-- ============================================================================
-- Scala projects need a specific Java version for compilation. This module
-- reads the .sdkmanrc file in your project root (e.g. java=11.0.29-zulu)
-- and tells Metals which Java to use.
--
-- How it works:
--   1. Finds the project root by looking for build.sbt
--   2. Reads .sdkmanrc for the java= line
--   3. Returns paths for both the project Java and Metals server Java (>= 17)
--
-- If no .sdkmanrc is found, falls back to the defaults below.
-- Java versions are managed by SDKMAN (https://sdkman.io/).

local java_version = (function()
  local M = {}
  local sdkman_java_dir = vim.fn.expand '~/.sdkman/candidates/java'
  local default_java_home = sdkman_java_dir .. '/11.0.29-zulu'
  local default_server_java = sdkman_java_dir .. '/17.0.17-zulu'

  local function read_sdkmanrc(root)
    local file = io.open(root .. '/.sdkmanrc', 'r')
    if not file then
      return nil
    end
    for line in file:lines() do
      local id = line:match '^%s*java%s*=%s*(.+)%s*$'
      if id then
        file:close()
        return id
      end
    end
    file:close()
    return nil
  end

  function M.resolve(bufpath)
    bufpath = bufpath or vim.api.nvim_buf_get_name(0)
    local root = vim.fs.root(bufpath, { 'build.sbt' })
    local defaults = { java_home = default_java_home, server_java = default_server_java, project_root = root }

    if not root then
      return defaults
    end

    local java_id = read_sdkmanrc(root)
    if not java_id then
      return defaults
    end

    local java_path = sdkman_java_dir .. '/' .. java_id
    if vim.fn.isdirectory(java_path) == 0 then
      vim.notify('java_version: Java ' .. java_id .. ' not installed, using defaults', vim.log.levels.WARN)
      return defaults
    end

    local major = tonumber(java_id:match '^(%d+)')
    local server_java = (major and major >= 17) and java_path or default_server_java

    return {
      java_home = java_path,
      server_java = server_java,
      java_id = java_id,
      major = major,
      project_root = root,
    }
  end

  return M
end)()

-- ============================================================================
-- LAZY.NVIM BOOTSTRAP (auto-installs the plugin manager on first run)
-- ============================================================================

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PLUGINS
-- ============================================================================
-- Everything below is a plugin specification for lazy.nvim.
-- Use :Lazy to see installed plugins, update them, or clean unused ones.
--
-- How lazy-loading works:
--   event = 'VimEnter'    → load when Neovim finishes starting
--   event = 'InsertEnter' → load when you first enter insert mode
--   event = 'BufWritePre' → load just before saving a file
--   ft = 'scala'          → load only for Scala files
--   cmd = { 'Git' }       → load when you first run :Git
--   keys = { ... }        → load when you first press that keymap

require('lazy').setup({

  -- --------------------------------------------------------------------------
  -- Editing helpers
  -- --------------------------------------------------------------------------

  'NMAC427/guess-indent.nvim', -- auto-detect indentation (tabs vs spaces) per file
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} }, -- auto-close brackets, quotes, etc.

  -- --------------------------------------------------------------------------
  -- Git
  -- --------------------------------------------------------------------------
  -- Two git plugins working together:
  --   gitsigns = gutter indicators + hunk-level operations (stage, reset, preview)
  --   fugitive = full git commands (:Git status, blame, diff, push, merge)
  --
  -- Common workflow:
  --   ]c / [c           → jump between changed hunks
  --   <leader>hp        → preview what changed in this hunk
  --   <leader>hs        → stage this hunk
  --   <leader>gs        → open git status (fugitive)
  --   <leader>gm        → 3-way merge for conflict resolution (see below)

  { -- Shows +/~/- signs in the gutter for git changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Jump between changed hunks with ]c and [c
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gs.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })
        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gs.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Stage or reset hunks (visual mode = selected lines only)
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gs.stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hb', gs.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })

        -- Toggle inline blame and deleted lines
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gs.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
  },

  { -- Git commands via :Git (fugitive.vim by Tim Pope)
    --
    -- Conflict resolution workflow (like IntelliJ's 3-panel merge):
    --   1. Open a file with merge conflicts
    --   2. Press <leader>gm to open the 3-way split:
    --      ┌──────────┬──────────┬──────────┐
    --      │  LEFT    │  MIDDLE  │  RIGHT   │
    --      │  (ours)  │ (working)│ (theirs) │
    --      │  //2     │  file    │  //3     │
    --      └──────────┴──────────┴──────────┘
    --   3. Put cursor in the MIDDLE pane, then:
    --      ]c / [c             → jump between conflicts
    --      :diffget //2        → take change from LEFT (ours)
    --      :diffget //3        → take change from RIGHT (theirs)
    --      (or just edit the middle pane manually)
    --   4. :w then :only when done
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gvdiffsplit', 'Gread', 'Gwrite' },
    keys = {
      { '<leader>gs', '<cmd>Git<CR>', desc = '[G]it [S]tatus' },
      { '<leader>gb', '<cmd>Git blame<CR>', desc = '[G]it [B]lame' },
      { '<leader>gd', '<cmd>Gvdiffsplit<CR>', desc = '[G]it [D]iff split' },
      { '<leader>gm', '<cmd>Gvdiffsplit!<CR>', desc = '[G]it [M]erge 3-way (conflicts)' },
      { '<leader>gl', '<cmd>Git log --oneline<CR>', desc = '[G]it [L]og' },
      { '<leader>gp', '<cmd>Git push<CR>', desc = '[G]it [P]ush' },
    },
  },

  -- --------------------------------------------------------------------------
  -- UI: which-key, telescope, bufferline, statusline, colorscheme
  -- --------------------------------------------------------------------------

  { -- Popup that shows available keybindings as you type
    -- Press <leader> (Space) and wait to see all options
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font, keys = vim.g.have_nerd_font and {} or nil },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>m', group = '[M]etals (Scala)' },
        { '<leader>d', group = '[D]ebug' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>q', group = '[Q]uickfix' },
      },
    },
  },

  { -- Telescope: fuzzy finder for files, text, LSP symbols, and more
    -- This is the Swiss Army knife of navigation. Key bindings:
    --   <leader>sf  → find files by name
    --   <leader>sg  → grep (search text) across all files
    --   <leader>sd  → search diagnostics (errors/warnings)
    --   <leader>s.  → recently opened files
    --   <leader>/   → search within the current file
    --   <leader><leader> → switch between open buffers
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- Makes telescope sorting much faster using a compiled C library
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' }, -- use telescope for vim.ui.select
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          -- Hide build artifacts and dependency folders from search results
          file_ignore_patterns = { 'target/', 'project/target', '.bloop/', '.metals/', '.bsp/', 'build/', 'node_modules/', '.git/' },
          -- Show filename FIRST, then the path (critical for Scala/Java with deep package paths)
          path_display = {
            filename_first = { reverse_directories = false },
          },
        },
        extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in Open Files' })
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  { -- Tab bar showing open buffers (like browser tabs)
    -- Shift+H / Shift+L to cycle through tabs
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = 'VimEnter',
    opts = function()
      return {
        options = {
          style_preset = require('bufferline').style_preset.minimal,
          diagnostics = 'nvim_lsp', -- show error/warning counts on tabs
          show_close_icon = false,
          show_buffer_close_icons = false,
          always_show_bufferline = true,
          separator_style = { '', '' },
          indicator = { style = 'icon', icon = '▎' },
          offsets = { { filetype = 'neo-tree', text = 'File Explorer', highlight = 'Directory' } },
        },
      }
    end,
    keys = {
      { '<S-h>', '<cmd>BufferLineCyclePrev<CR>', desc = 'Previous buffer' },
      { '<S-l>', '<cmd>BufferLineCycleNext<CR>', desc = 'Next buffer' },
      { '<leader>bp', '<cmd>BufferLineTogglePin<CR>', desc = '[B]uffer [P]in toggle' },
      { '<leader>bc', '<cmd>bd<CR>', desc = '[B]uffer [C]lose' },
    },
  },

  { -- Collection of small useful plugins (mini.nvim)
    --   mini.ai       → better text objects (e.g. "daf" = delete around function)
    --   mini.surround → add/change/delete surrounding chars (e.g. ysaw" = surround word with ")
    --   mini.statusline → minimal status bar at the bottom
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  { -- Kanagawa colorscheme (dark, warm Japanese aesthetic)
    'rebelot/kanagawa.nvim',
    priority = 1000, -- load before other plugins so colors are ready
    config = function()
      require('kanagawa').setup {
        commentStyle = { italic = true },
        keywordStyle = { italic = false },
        statementStyle = { bold = true },
        colors = { theme = { all = { ui = { bg_gutter = 'none' } } } },
      }
    end,
  },
  { -- Gruber Darker colorscheme (alternative, switch with :colorscheme gruber-darker)
    'blazkowolf/gruber-darker.nvim',
    priority = 1000,
    config = function()
      require('gruber-darker').setup()
      vim.cmd.colorscheme 'kanagawa-dragon' -- active colorscheme (change here to switch)
    end,
  },

  -- --------------------------------------------------------------------------
  -- File explorer
  -- --------------------------------------------------------------------------

  { -- Neo-tree: sidebar file browser (toggle with \)
    -- Inside neo-tree: a = new file, d = delete, r = rename, c = copy, m = move
    -- group_empty_dirs collapses long Java/Scala paths like src/main/scala/com/...
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' },
    lazy = false,
    keys = {
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      default_component_configs = {
        indent = { indent_size = 2 },
        file_size = { enabled = false },    -- hide file sizes to keep the panel narrow
        last_modified = { enabled = false }, -- hide timestamps
      },
      window = { width = 40 },
      filesystem = {
        group_empty_dirs = true, -- collapse empty directories into one line
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
        window = {
          mappings = {
            ['\\'] = 'close_window',
            ['i'] = 'show_file_details', -- show full path/size in a popup
          },
        },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Treesitter: syntax highlighting, code folding, smart indentation
  -- --------------------------------------------------------------------------
  -- Treesitter parses your code into an AST (abstract syntax tree) for much
  -- better syntax highlighting than regex-based approaches. It also powers
  -- code folding (zc/zo) and smart indentation.

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash', 'c', 'diff', 'gleam', 'go', 'gomod', 'gosum', 'gotmpl',
        'html', 'json', 'lua', 'luadoc', 'markdown', 'markdown_inline',
        'proto', 'query', 'scala', 'sql', 'vim', 'vimdoc', 'yaml',
      },
      auto_install = true, -- automatically install parsers for new filetypes
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby' } },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  -- --------------------------------------------------------------------------
  -- LSP (Language Server Protocol): code intelligence
  -- --------------------------------------------------------------------------
  -- LSP provides IDE features: go to definition, find references, rename,
  -- code actions, diagnostics (errors/warnings), hover docs, etc.
  --
  -- How it works:
  --   Mason installs the LSP servers (gopls, lua_ls, etc.)
  --   nvim-lspconfig configures them
  --   When you open a file, the matching server starts automatically
  --
  -- Key bindings (only active when an LSP server is attached):
  --   K           → hover documentation (show type/docs under cursor)
  --   grd         → go to definition
  --   grr         → find all references
  --   gri         → go to implementation
  --   grn         → rename symbol across the project
  --   gra         → code actions (quick fixes, refactors)
  --   gO          → document symbols (functions, classes in current file)
  --   <leader>th  → toggle inlay hints (inline type annotations)

  { -- Enhanced Lua LSP for editing this Neovim config (autocomplete vim.* APIs)
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } },
  },

  { -- LSP configuration + Mason for installing servers
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },       -- LSP/tool installer UI (:Mason)
      'mason-org/mason-lspconfig.nvim',             -- bridges Mason and lspconfig
      'WhoIsSethDaniel/mason-tool-installer.nvim',  -- auto-install specified tools
      { 'j-hui/fidget.nvim', opts = {} },           -- shows LSP progress in bottom-right
      'saghen/blink.cmp',                           -- completion engine (provides capabilities)
    },
    config = function()
      -- Set up keymaps when an LSP server attaches to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', function()
            vim.lsp.buf.definition {
              on_list = function(options)
                vim.fn.setqflist({}, ' ', options)
                if #options.items == 1 then
                  vim.cmd 'cfirst'
                else
                  require('telescope.builtin').quickfix()
                end
              end,
            }
          end, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- When cursor rests on a symbol, highlight all other occurrences
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Toggle inlay hints (inline type annotations shown in gray text)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- How diagnostics (errors/warnings) appear in the editor
      vim.diagnostic.config {
        severity_sort = true,                                        -- show errors before warnings
        float = { border = 'rounded', source = 'if_many' },         -- floating window style
        underline = { severity = vim.diagnostic.severity.ERROR },    -- only underline errors
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = { source = 'if_many', spacing = 2 },         -- inline text after the line
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- LSP servers to install and configure via Mason
      -- Add new servers here — Mason will auto-install them on next startup
      local servers = {
        lua_ls = { settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
        gopls = {
          settings = {
            gopls = {
              analyses = { unusedparams = true },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
        jsonls = {},
        yamlls = {},
        dockerls = {},
      }

      -- Also install these tools (formatters, linters) via Mason
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua' }) -- Lua formatter
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      -- Servers NOT managed by Mason (installed system-wide)
      vim.lsp.config('gleam', { capabilities = capabilities })
      vim.lsp.enable('gleam')
    end,
  },

  -- --------------------------------------------------------------------------
  -- Formatting
  -- --------------------------------------------------------------------------

  { -- Auto-format code on save (conform.nvim)
    -- Runs the appropriate formatter for each filetype.
    -- Also available manually with <leader>f
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        -- Scala formatting (scalafmt) is slow, give it extra time
        local timeout = vim.bo[bufnr].filetype == 'scala' and 3000 or 500
        return { timeout_ms = timeout, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },     -- configured in .stylua.toml
        scala = { 'scalafmt' }, -- configured in .scalafmt.conf (in project root)
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Autocompletion
  -- --------------------------------------------------------------------------

  { -- blink.cmp: fast autocompletion engine
    -- Completions appear automatically as you type. Use:
    --   Tab/Shift-Tab   → navigate the completion menu
    --   Enter           → accept the selected completion
    --   Ctrl-Space      → manually trigger completions
    --   Ctrl-e          → dismiss the menu
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      { -- Snippet engine (provides template expansions like for loops, etc.)
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (vim.fn.has 'win32' == 0 and vim.fn.executable 'make' == 1) and 'make install_jsregexp' or nil,
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        menu = { auto_show = true },           -- show completions automatically
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 }, -- show docs popup
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = { lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 } },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true }, -- show function signature as you type arguments
    },
  },

  -- --------------------------------------------------------------------------
  -- Misc
  -- --------------------------------------------------------------------------

  -- Highlights TODO, FIXME, HACK, NOTE comments in your code
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Indent guides (vertical lines showing indentation levels)
    -- Starts disabled; toggle with <leader>ti
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = { enabled = false },
    keys = {
      { '<leader>ti', '<cmd>IBLToggle<CR>', desc = '[T]oggle [I]ndent guides' },
    },
  },

  -- --------------------------------------------------------------------------
  -- Scala / Metals / DAP (Debug Adapter Protocol)
  -- --------------------------------------------------------------------------
  -- Metals is the Scala LSP server. It provides the same features as the
  -- generic LSP section above, plus Scala-specific features like:
  --   - Import build (download dependencies)
  --   - Organize imports
  --   - Code lenses (run/test buttons above main/test classes)
  --   - Worksheet evaluation
  --   - DAP debugging (breakpoints, step through, inspect variables)
  --
  -- Java version is resolved per-project from .sdkmanrc (see section above).

  {
    'scalameta/nvim-metals',
    dependencies = { 'nvim-lua/plenary.nvim', 'mfussenegger/nvim-dap' },
    ft = { 'scala', 'sbt', 'java' },
    config = function()
      local metals = require 'metals'

      -- Metals-specific keymaps (<leader>m prefix)
      vim.keymap.set('n', '<leader>mc', function() require('metals').commands() end, { desc = '[M]etals [C]ommands' })
      vim.keymap.set('n', '<leader>mo', function() require('metals').organize_imports() end, { desc = '[M]etals [O]rganize imports' })
      vim.keymap.set('n', '<leader>mr', vim.lsp.codelens.run, { desc = '[M]etals [R]un code lens (run/debug)' })
      vim.keymap.set('n', '<leader>mt', require('metals.tvp').toggle_tree_view, { desc = '[M]etals [T]ree view toggle' })
      vim.keymap.set('n', '<leader>mf', require('metals.tvp').reveal_in_tree, { desc = '[M]etals reveal [F]ile in tree' })
      vim.keymap.set('n', '<leader>mi', function() require('metals').import_build() end, { desc = '[M]etals [I]mport build' })

      -- DAP (debugger) keymaps (<leader>d prefix)
      local dap = require 'dap'
      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[D]ebug [C]ontinue/start' })
      vim.keymap.set('n', '<leader>dr', dap.repl.toggle, { desc = '[D]ebug [R]EPL (output)' })
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[D]ebug toggle [B]reakpoint' })
      vim.keymap.set('n', '<leader>dso', dap.step_over, { desc = '[D]ebug [S]tep [O]ver' })
      vim.keymap.set('n', '<leader>dsi', dap.step_into, { desc = '[D]ebug [S]tep [I]nto' })
      vim.keymap.set('n', '<leader>dK', require('dap.ui.widgets').hover, { desc = '[D]ebug hover value' })

      -- Debug launch configurations for Scala
      dap.configurations.scala = {
        { type = 'scala', request = 'launch', name = 'Run or Test', metals = { runType = 'runOrTestFile' } },
        { type = 'scala', request = 'launch', name = 'Test Target', metals = { runType = 'testTarget' } },
      }

      -- Auto-attach Metals when opening Scala/SBT/Java files
      local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'scala', 'sbt', 'java' },
        callback = function()
          local bufpath = vim.api.nvim_buf_get_name(0)
          local jv = java_version.resolve(bufpath)

          local metals_config = metals.bare_config()
          metals_config.capabilities = require('blink.cmp').get_lsp_capabilities()
          metals_config.init_options.statusBarProvider = 'on'
          metals_config.settings = {
            metals = {
              javaHome = jv.java_home,
              inlayHints = {
                inferredTypes = { enable = true },
                implicitArguments = { enable = true },
                implicitConversions = { enable = true },
                typeParameters = { enable = true },
                hintsInPatternMatch = { enable = true },
              },
            },
          }

          metals_config.on_attach = function(client, bufnr)
            require('metals').setup_dap()
            vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
              buffer = bufnr,
              callback = vim.lsp.codelens.refresh,
            })
          end

          -- Metals server needs Java >= 17; project code uses .sdkmanrc version
          vim.env.JAVA_HOME = jv.server_java
          metals.initialize_or_attach(metals_config)
          vim.env.JAVA_HOME = jv.java_home

          local project_name = jv.project_root and vim.fn.fnamemodify(jv.project_root, ':t') or 'unknown'
          local java_label = jv.java_id or vim.fn.fnamemodify(jv.java_home, ':t')
          vim.notify('Metals: ' .. project_name .. ' → Java ' .. java_label, vim.log.levels.INFO)
        end,
        group = nvim_metals_group,
      })
    end,
  },
}, {
  ui = { icons = vim.g.have_nerd_font and {} or nil },
})

-- vim: ts=2 sts=2 sw=2 et
