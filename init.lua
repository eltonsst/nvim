-- ============================================================================ini
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

-- Tell plugins we have a Nerd Font installed (enables icons everywhere)
vim.g.have_nerd_font = true

-- ============================================================================
-- OPTIONS
-- ============================================================================
-- These control how Neovim looks and behaves. Each setting is explained below.

vim.o.number = true -- show line numbers in the gutter
vim.o.foldmethod = 'expr' -- use treesitter for code folding
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldlevel = 99 -- start with all folds open (99 = don't fold anything)
vim.o.mouse = 'a' -- enable mouse in all modes (click, scroll, select)
vim.o.showmode = false -- hide "-- INSERT --" from the bottom (statusline shows it)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus' -- use system clipboard for yank/paste (y, p, d, etc.)
end)
vim.o.breakindent = true -- wrapped lines continue at the same indent level
vim.o.undofile = true -- persist undo history across sessions (saved to disk)
vim.o.ignorecase = true -- search is case-insensitive by default...
vim.o.smartcase = true -- ...unless you type an uppercase letter
vim.o.signcolumn = 'yes' -- always show the sign column (git signs, diagnostics)
vim.o.updatetime = 250 -- ms of idle before CursorHold fires (affects LSP highlights)
vim.o.timeoutlen = 300 -- ms to wait for a mapped key sequence (e.g. <leader>sf)
vim.o.splitright = true -- new vertical splits open to the right
vim.o.splitbelow = true -- new horizontal splits open below
vim.o.list = true -- show invisible characters (tabs, trailing spaces)
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split' -- live preview of :s substitutions in a split
vim.o.cursorline = true -- highlight the line your cursor is on
vim.o.scrolloff = 10 -- keep 10 lines visible above/below cursor when scrolling
vim.o.confirm = true -- ask to save instead of failing on :q with unsaved changes
vim.o.swapfile = false -- don't create .swp files (we have undofile + autosave)
vim.o.tabstop = 4 -- display tab characters as 4 spaces wide

-- ============================================================================
-- KEYMAPS (built-in, no plugins required)
-- ============================================================================

-- Clear search highlighting by pressing Escape
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Show the full error/warning message in a floating window at the current line
-- (much easier to read than the truncated inline text)
local function open_diagnostic_float()
  local _, winid = vim.diagnostic.open_float(nil, {
    scope = 'line',
    focusable = true,
    border = 'rounded',
    source = 'if_many',
    max_width = math.floor(vim.o.columns * 0.6),
    max_height = math.floor(vim.o.lines * 0.3),
  })

  if winid then
    vim.wo[winid].wrap = true
    vim.wo[winid].linebreak = true
  end
end

vim.keymap.set('n', '<leader>e', open_diagnostic_float, { desc = 'Show diagnostic [E]rror float' })

local function wrap_floating_window(winid, highlight)
  if winid then
    vim.wo[winid].wrap = true
    vim.wo[winid].linebreak = true
    if highlight then
      vim.api.nvim_set_option_value('winhighlight', highlight, { scope = 'local', win = winid })
    end
  end
end

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

local function open_workspace_diagnostics()
  vim.diagnostic.setqflist { open = false }
  vim.cmd.copen()
end

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

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Wrap quickfix entries so long diagnostics remain readable',
  group = vim.api.nvim_create_augroup('quickfix-wrap', { clear = true }),
  pattern = 'qf',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
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

  {
    'eltonsst/local-review.nvim',
    config = function()
      require('local_review').setup {
        keymap = '<leader>rc',
      }
    end,
  },

  -- --------------------------------------------------------------------------
  -- Editing helpers
  -- --------------------------------------------------------------------------

  'NMAC427/guess-indent.nvim', -- auto-detect indentation (tabs vs spaces) per file
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} }, -- auto-close brackets, quotes, etc.

  -- --------------------------------------------------------------------------
  -- Git
  -- --------------------------------------------------------------------------
  -- Two focused git tools:
  --   gitsigns     = gutter indicators + hunk-level operations (stage, reset, preview)
  --   git-conflict = merge-conflict resolution when markers are present
  --
  -- Common workflow:
  --   ]c / [c           → jump between changed hunks
  --   <leader>hp        → preview what changed in this hunk
  --   <leader>hs        → stage this hunk
  --   ]x / [x           → jump between merge conflicts
  --   <leader>go        → choose ours for the current conflict
  --   <leader>gt        → choose theirs for the current conflict

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
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
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

  { -- Conflict-focused merge resolution
    'akinsho/git-conflict.nvim',
    version = '*',
    event = 'BufReadPost',
    cmd = {
      'GitConflictChooseOurs',
      'GitConflictChooseTheirs',
      'GitConflictChooseBoth',
      'GitConflictChooseNone',
      'GitConflictNextConflict',
      'GitConflictPrevConflict',
      'GitConflictListQf',
    },
    opts = {
      default_mappings = false,
      default_commands = true,
      disable_diagnostics = false,
      highlights = {
        incoming = 'DiffAdd',
        current = 'DiffText',
      },
    },
    keys = {
      { '<leader>go', '<cmd>GitConflictChooseOurs<CR>', desc = '[G]it conflict choose [O]urs' },
      { '<leader>gt', '<cmd>GitConflictChooseTheirs<CR>', desc = '[G]it conflict choose [T]heirs' },
      { '<leader>gb', '<cmd>GitConflictChooseBoth<CR>', desc = '[G]it conflict choose [B]oth' },
      { '<leader>g0', '<cmd>GitConflictChooseNone<CR>', desc = '[G]it conflict choose [0] none' },
      { '<leader>gq', '<cmd>GitConflictListQf<CR>', desc = '[G]it conflict [Q]uickfix list' },
      { ']x', '<cmd>GitConflictNextConflict<CR>', desc = 'Next git conflict' },
      { '[x', '<cmd>GitConflictPrevConflict<CR>', desc = 'Previous git conflict' },
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
        { '<leader>t', group = '[T]oggle & [T]est' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>m', group = '[M]etals (Scala)' },
        { '<leader>d', group = '[D]ebug' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>q', group = '[Q]uickfix' },
        { '<leader>z', group = '[Z]en' },
      },
    },
  },

  { -- Telescope: fuzzy finder for files, text, LSP symbols, and more
    -- This is the Swiss Army knife of navigation. Key bindings:
    --   <leader>sf  → find files by name
    --   <leader>sg  → grep (search text) across all files
    --   <leader>sd  → open workspace diagnostics in a wrapped quickfix list
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
      'nvim-telescope/telescope-smart-history.nvim', -- remember previous searches across restarts
      'kkharji/sqlite.lua', -- storage backend for telescope-smart-history
      { 'nvim-telescope/telescope-ui-select.nvim' }, -- use telescope for vim.ui.select
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local telescope_history_dir = vim.fs.joinpath(vim.fn.stdpath 'data', 'databases')
      local telescope_history = vim.fs.joinpath(telescope_history_dir, 'telescope_history.sqlite3')
      vim.fn.mkdir(telescope_history_dir, 'p')
      require('telescope').setup {
        defaults = {
          -- Hide build artifacts and dependency folders from search results
          file_ignore_patterns = { 'target/', 'project/target', '.bloop/', '.metals/', '.bsp/', 'build/', 'node_modules/', '.git/' },
          -- Show filename FIRST, then the path (critical for Scala/Java with deep package paths)
          path_display = {
            filename_first = { reverse_directories = false },
          },
          history = {
            path = telescope_history,
            limit = 100,
          },
        },
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'smart_history')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', open_workspace_diagnostics, { desc = '[S]how workspace [D]iagnostics' })
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

  { -- Smooth scrolling for Ctrl-u/d, Ctrl-b/f, Ctrl-y/e, zt/zz/zb
    'karb94/neoscroll.nvim',
    opts = {},
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
        overrides = function(colors)
          local ui = colors.theme.ui
          local syn = colors.theme.syn
          return {
            NormalFloat = { fg = ui.fg, bg = ui.bg },
            FloatBorder = { fg = ui.float.fg_border, bg = ui.bg },
            FloatTitle = { fg = ui.special, bg = ui.bg, bold = true },
            OilFloat = { fg = ui.fg, bg = ui.bg },
            OilFloatBorder = { fg = ui.float.fg_border, bg = ui.bg },
            OilFloatTitle = { fg = ui.special, bg = ui.bg, bold = true },
            BlinkCmpMenu = { fg = ui.fg, bg = ui.bg },
            BlinkCmpMenuBorder = { fg = ui.float.fg_border, bg = ui.bg },
            BlinkCmpMenuSelection = { fg = ui.fg, bg = ui.bg_p1 },
            BlinkCmpScrollBarGutter = { bg = ui.bg },
            BlinkCmpScrollBarThumb = { bg = ui.bg_p2 },
            BlinkCmpLabel = { fg = ui.fg },
            BlinkCmpLabelMatch = { fg = syn.fun, bold = true },
            BlinkCmpLabelDetail = { fg = ui.fg_dim },
            BlinkCmpLabelDescription = { fg = ui.fg_dim },
            BlinkCmpSource = { fg = ui.special },
            BlinkCmpKind = { fg = syn.type },
            BlinkCmpDoc = { fg = ui.fg, bg = ui.bg },
            BlinkCmpDocBorder = { fg = ui.float.fg_border, bg = ui.bg },
            BlinkCmpDocSeparator = { fg = ui.bg_p1, bg = ui.bg },
            BlinkCmpSignatureHelp = { fg = ui.fg, bg = ui.bg },
            BlinkCmpSignatureHelpBorder = { fg = ui.float.fg_border, bg = ui.bg },
            BlinkCmpSignatureHelpActiveParameter = { fg = syn.parameter, bold = true },
          }
        end,
      }
    end,
  },
  { -- Catppuccin (light alternative: :colorscheme catppuccin-latte)
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        integrations = {
          blink_cmp = true,
          gitsigns = true,
          mini = { enabled = true },
          telescope = { enabled = true },
          treesitter = true,
          which_key = true,
        },
      }
    end,
  },

  -- --------------------------------------------------------------------------
  -- File explorer
  -- --------------------------------------------------------------------------

  { -- Oil: directory editor / lightweight file explorer
    -- `\\` opens a floating explorer, `-` opens the parent directory in-place.
    -- This keeps file navigation simple while staying closer to normal editing.
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    keys = {
      {
        '\\',
        function()
          require('oil').toggle_float()
        end,
        desc = 'Open file explorer',
      },
      { '-', '<cmd>Oil<CR>', desc = 'Open parent directory' },
    },
    opts = {
      columns = { 'icon' },
      win_options = {
        wrap = false,
        signcolumn = 'no',
        cursorcolumn = false,
        foldcolumn = '0',
        spell = false,
        list = false,
      },
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ['q'] = 'actions.close',
        ['<Esc>'] = { 'actions.close', mode = 'n' },
        ['<C-h>'] = false,
        ['<C-l>'] = false,
        ['<C-k>'] = false,
        ['<C-j>'] = false,
      },
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 1,
        max_width = 0.72,
        max_height = 0.78,
        border = 'rounded',
        win_options = {
          winblend = 0,
          winhighlight = 'NormalFloat:OilFloat,FloatBorder:OilFloatBorder,FloatTitle:OilFloatTitle',
        },
        get_win_title = function()
          return ' Oil '
        end,
        preview_split = 'right',
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
        'bash',
        'c',
        'diff',
        'gleam',
        'go',
        'gomod',
        'gosum',
        'gotmpl',
        'html',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'proto',
        'query',
        'scala',
        'sql',
        'vim',
        'vimdoc',
        'yaml',
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
      { 'mason-org/mason.nvim', opts = {} }, -- LSP/tool installer UI (:Mason)
      'mason-org/mason-lspconfig.nvim', -- bridges Mason and lspconfig
      'WhoIsSethDaniel/mason-tool-installer.nvim', -- auto-install specified tools
      { 'j-hui/fidget.nvim', opts = {} }, -- shows LSP progress in bottom-right
      'saghen/blink.cmp', -- completion engine (provides capabilities)
      'b0o/SchemaStore.nvim', -- bundled JSON/YAML schemas (GitLab CI, Docker Compose, k8s, etc.)
    },
    config = function()
      local hover_handler = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
        focusable = true,
        max_width = math.floor(vim.o.columns * 0.6),
        max_height = math.floor(vim.o.lines * 0.3),
      })

      local signature_handler = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = 'rounded',
        focusable = true,
        max_width = math.floor(vim.o.columns * 0.6),
        max_height = math.floor(vim.o.lines * 0.3),
      })

      vim.lsp.handlers['textDocument/hover'] = function(err, result, ctx, config)
        local bufnr, winid = hover_handler(err, result, ctx, config)
        wrap_floating_window(winid, 'NormalFloat:LspFloat,FloatBorder:LspFloatBorder,FloatTitle:LspFloatTitle')
        return bufnr, winid
      end

      vim.lsp.handlers['textDocument/signatureHelp'] = function(err, result, ctx, config)
        local bufnr, winid = signature_handler(err, result, ctx, config)
        wrap_floating_window(winid, 'NormalFloat:LspFloat,FloatBorder:LspFloatBorder,FloatTitle:LspFloatTitle')
        return bufnr, winid
      end

      -- Set up keymaps when an LSP server attaches to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('K', function()
            vim.lsp.buf.hover {
              border = 'rounded',
              title = ' Info ',
              title_pos = 'center',
              focusable = true,
              max_width = math.floor(vim.o.columns * 0.6),
              max_height = math.floor(vim.o.lines * 0.3),
            }
          end, 'Hover Documentation')
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
        severity_sort = true, -- show errors before warnings
        float = {
          border = 'rounded',
          source = 'if_many',
          focusable = true,
          max_width = math.floor(vim.o.columns * 0.6),
          max_height = math.floor(vim.o.lines * 0.3),
        },
        underline = { severity = vim.diagnostic.severity.ERROR }, -- only underline errors
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = false,
        virtual_lines = false,
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- LSP servers to install and configure via Mason
      -- Add new servers here — Mason will auto-install them on next startup
      local servers = {
        lua_ls = { settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
        gopls = {
          -- Settings adapted from TJ DeVries's config — he's a Go core contributor,
          -- so these are effectively the authoritative defaults for gopls in nvim.
          settings = {
            gopls = {
              analyses = {
                unusedparams = true, -- flag function parameters that are never read
                shadow = true, -- warn when an outer variable is shadowed
                nilness = true, -- catch nil-dereference bugs
                unusedwrite = true, -- flag stores to variables that are never read
              },
              staticcheck = true, -- extra linting beyond `go vet`
              gofumpt = true, -- stricter formatting on top of gofmt
              usePlaceholders = true, -- fill function arguments on completion
              completeUnimported = true, -- autocomplete types/funcs from unimported packages
              experimentalPostfixCompletions = true, -- e.g. typing `xs.for` expands to a for-range loop
              codelenses = { -- run/test/tidy buttons shown above functions
                generate = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
              },
              -- Inline type annotations shown in gray text.
              -- Toggle on/off once a .go file is open with: <leader>th
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
        jsonls = {
          settings = {
            json = {
              -- Validate against well-known schemas (package.json, tsconfig, etc.)
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              -- Disable the built-in schema store (it's stale) and use SchemaStore.nvim
              -- instead. Auto-matches .gitlab-ci.yml, docker-compose.yml, GitHub Actions, etc.
              schemaStore = { enable = false, url = '' },
              schemas = require('schemastore').yaml.schemas(),
              -- To add repo-local schemas (e.g. when working in ledger-specifications),
              -- drop a `.nvim.lua` at the project root with:
              --   vim.lsp.config('yamlls', { settings = { yaml = { schemas = {
              --     ['./schema/posting_rules_schema.json'] = 'posting_rules.yaml',
              --   } } } })
              -- and allow it with `:trust` (or set vim.o.exrc = true).
            },
          },
        },
        dockerls = {},
        pyright = {
          -- Pyright handles type info, hover (K), go-to-definition, completions.
          -- Linting/import-organization is handled by ruff via conform.nvim
          -- (formatter only, not attached as an LSP). mypy runs via nvim-lint.
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'basic',
                diagnosticMode = 'openFilesOnly',
              },
            },
          },
        },
      }

      -- Also install these tools (formatters, linters) via Mason
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Lua formatter
        'goimports', -- Go formatter (adds/removes imports automatically)
        'gofumpt', -- stricter Go formatter (superset of gofmt)
        'delve', -- Go debugger (used by nvim-dap-go below)
        'golangci-lint', -- Go linter bundle
        'yamlfmt', -- YAML formatter (used by conform on save)
        'yamllint', -- YAML linter (used by nvim-lint on save/open)
        'protolint', -- Protocol Buffer linter (used by nvim-lint on save/open)
        'ruff', -- Python formatter (used by conform on save)
        'mypy', -- Python type checker (used by nvim-lint on save/open)
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for server_name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
      end

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_enable = true,
      }

      -- Servers NOT managed by Mason (installed system-wide)
      vim.lsp.config('gleam', { capabilities = capabilities })
      vim.lsp.enable 'gleam'
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
        -- Some formatters are slow enough on real projects that 500ms is too aggressive.
        -- Give Scala and Go a bit more headroom on save.
        local filetype = vim.bo[bufnr].filetype
        local timeout = ({
          scala = 3000,
          go = 2000,
        })[filetype] or 500
        return { timeout_ms = timeout, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' }, -- configured in .stylua.toml
        scala = { 'scalafmt' }, -- configured in .scalafmt.conf (in project root)
        go = { 'goimports', 'gofumpt' }, -- runs in order: organize imports, then format
        yaml = { 'yamlfmt' }, -- configured in .yamlfmt.yaml at project root (if present)
        python = { 'ruff_organize_imports', 'ruff_format' }, -- matches the project's `ruff format` / `ruff check` workflow
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Linting (diagnostics from external tools, not from LSP)
  -- --------------------------------------------------------------------------
  -- LSP provides diagnostics from language servers (gopls, metals, yamlls…).
  -- Some tools aren't LSPs but still report errors — e.g. yamllint. nvim-lint
  -- runs those CLIs on save/open and feeds the results into `vim.diagnostic`,
  -- so they show up alongside LSP errors in the signcolumn and diagnostics views like `<leader>e` and `<leader>sd`.

  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufWritePost' },
    config = function()
      require('lint').linters_by_ft = {
        yaml = { 'yamllint' }, -- honors .yamllint.yaml at project root
        proto = { 'protolint' },
        python = { 'mypy' }, -- pyright handles types via LSP; mypy adds a second pass
      }
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
        group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
        callback = function()
          require('lint').try_lint()
        end,
      })
      -- Lint the buffer that triggered the lazy-load too
      require('lint').try_lint()
    end,
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
    },
    opts = {
      keymap = { preset = 'enter' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        menu = {
          auto_show = true,
          border = 'rounded',
        }, -- show completions automatically
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = 'rounded' },
        }, -- show docs popup
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = { lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 } },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = {
        enabled = true,
        window = { border = 'rounded' },
      }, -- show function signature as you type arguments
    },
  },

  -- --------------------------------------------------------------------------
  -- Misc
  -- --------------------------------------------------------------------------

  -- Highlights TODO, FIXME, HACK, NOTE comments in your code
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Zen mode: distraction-free editing in the current window
    'folke/zen-mode.nvim',
    keys = {
      { '<leader>zz', '<cmd>ZenMode<CR>', desc = '[Z]en mode toggle' },
    },
    opts = {
      window = {
        width = 90,
        options = {
          number = false,
          relativenumber = false,
          cursorline = false,
          signcolumn = 'no',
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
        },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- DAP (Debug Adapter Protocol) — shared debugger core
  -- --------------------------------------------------------------------------
  -- DAP is the same protocol VS Code uses for debugging. Each language plugs
  -- in its own adapter on top:
  --   Scala  → nvim-metals registers the adapter on LSP attach (next block)
  --   Go     → nvim-dap-go registers delve as the adapter (further below)
  --
  -- The <leader>d keymaps are defined here once and work across all languages.
  -- Keys load lazy-on-first-press; the whole debugger doesn't start Neovim.
  --
  --   <leader>dc   → Continue (or start) the debugger
  --   <leader>db   → toggle Breakpoint on current line
  --   <leader>dso  → Step Over (next line, don't enter functions)
  --   <leader>dsi  → Step Into (enter the function under the cursor)
  --   <leader>dr   → toggle the REPL panel (program output + expressions)
  --   <leader>dK   → hover to show the value of the variable under the cursor

  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = '[D]ebug [C]ontinue/start',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle()
        end,
        desc = '[D]ebug [R]EPL (output)',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = '[D]ebug toggle [B]reakpoint',
      },
      {
        '<leader>dso',
        function()
          require('dap').step_over()
        end,
        desc = '[D]ebug [S]tep [O]ver',
      },
      {
        '<leader>dsi',
        function()
          require('dap').step_into()
        end,
        desc = '[D]ebug [S]tep [I]nto',
      },
      {
        '<leader>dK',
        function()
          require('dap.ui.widgets').hover()
        end,
        desc = '[D]ebug hover value',
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Scala / Metals
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
      vim.keymap.set('n', '<leader>mc', function()
        require('metals').commands()
      end, { desc = '[M]etals [C]ommands' })
      vim.keymap.set('n', '<leader>mo', function()
        require('metals').organize_imports()
      end, { desc = '[M]etals [O]rganize imports' })
      vim.keymap.set('n', '<leader>mr', vim.lsp.codelens.run, { desc = '[M]etals [R]un code lens (run/debug)' })
      vim.keymap.set('n', '<leader>mt', require('metals.tvp').toggle_tree_view, { desc = '[M]etals [T]ree view toggle' })
      vim.keymap.set('n', '<leader>mf', require('metals.tvp').reveal_in_tree, { desc = '[M]etals reveal [F]ile in tree' })
      vim.keymap.set('n', '<leader>mi', function()
        require('metals').import_build()
      end, { desc = '[M]etals [I]mport build' })

      -- DAP keymaps (<leader>d) are defined once in the shared nvim-dap block
      -- further down — they bind the same way for Scala, Go, and any other
      -- language whose adapter we register. Below we only wire up the
      -- Scala-specific launch configurations.
      local dap = require 'dap'
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

  -- --------------------------------------------------------------------------
  -- Go
  -- --------------------------------------------------------------------------
  -- gopls is already configured in the LSP section above with inlay hints,
  -- staticcheck, gofumpt, postfix completions, and codelenses. That gives you
  -- the "smart editor" half of the Scala story. This section adds the rest:
  --
  --   nvim-dap-go  → auto-wires delve (the Go debugger) as a DAP adapter.
  --                  No config needed — opening a .go file makes the
  --                  <leader>d* keymaps work for Go too.
  --
  --   neotest      → unified test runner with pass/fail icons in the gutter,
  --                  a summary panel, and output viewer.
  --
  -- Debugging uses the same <leader>d keymaps as Scala (shared DAP block above).
  -- Test keybindings (<leader>t prefix, filetype-agnostic — will also drive
  -- other neotest adapters you add later):
  --
  --   <leader>tn  → run the [N]earest test (the one under your cursor)
  --   <leader>tf  → run every test in the current [F]ile
  --   <leader>ts  → toggle the [S]ummary panel (tree view of all tests)
  --   <leader>to  → open the [O]utput of the last test run

  { -- Go DAP adapter — zero-config, registers `Debug test`/`Debug main`/`Attach`
    'leoluz/nvim-dap-go',
    dependencies = { 'mfussenegger/nvim-dap' },
    ft = 'go',
    opts = {}, -- opts = {} with no `config` field means: call .setup({}) automatically
  },

  { -- Neotest: unified test runner. The Go adapter (neotest-golang) wraps
    -- `go test` output and also hands off to nvim-dap-go when you run a test
    -- in debug mode. One interface today for Go; easy to add more languages
    -- later (e.g. neotest-plenary for Lua, neotest-vitest for JS/TS).
    'nvim-neotest/neotest',
    ft = 'go',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neotest/nvim-nio',
      'nvim-treesitter/nvim-treesitter',
      {
        'fredrikaverpil/neotest-golang',
        dependencies = { 'leoluz/nvim-dap-go' }, -- lets neotest drive the debugger
      },
    },
    keys = {
      {
        '<leader>tn',
        function()
          require('neotest').run.run()
        end,
        desc = '[T]est [N]earest',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = '[T]est [F]ile',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = '[T]est [S]ummary panel',
      },
      {
        '<leader>to',
        function()
          require('neotest').output.open { enter = true }
        end,
        desc = '[T]est [O]utput',
      },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-golang' { dap_go_enabled = true },
        },
      }
    end,
  },
}, {
  ui = { icons = vim.g.have_nerd_font and {} or nil },
})

vim.cmd.colorscheme 'kanagawa-dragon'

-- vim: ts=2 sts=2 sw=2 et
