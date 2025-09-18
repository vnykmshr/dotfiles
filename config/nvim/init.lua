-- Modern Neovim Configuration
-- Professional setup with LSP, Treesitter, and modern plugins

-- =============================================================================
-- Core Settings
-- =============================================================================

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic options
local opt = vim.opt

-- Appearance
opt.number = true              -- Show line numbers
opt.relativenumber = true      -- Relative line numbers
opt.signcolumn = 'yes'         -- Always show sign column
opt.colorcolumn = '100'        -- Highlight column at 100 chars
opt.cursorline = true          -- Highlight current line
opt.termguicolors = true       -- True color support

-- Behavior
opt.mouse = 'a'               -- Enable mouse support
opt.clipboard = 'unnamedplus' -- Use system clipboard
opt.undofile = true           -- Persistent undo
opt.backup = false            -- No backup files
opt.writebackup = false       -- No backup while editing
opt.swapfile = false          -- No swap files

-- Indentation
opt.tabstop = 4               -- Tab width
opt.shiftwidth = 4            -- Indent width
opt.expandtab = true          -- Use spaces instead of tabs
opt.smartindent = true        -- Smart auto-indenting
opt.autoindent = true         -- Copy indent from current line

-- Search
opt.hlsearch = true           -- Highlight search results
opt.incsearch = true          -- Incremental search
opt.ignorecase = true         -- Case insensitive search
opt.smartcase = true          -- Case sensitive if uppercase present

-- Splits
opt.splitbelow = true         -- Horizontal splits below
opt.splitright = true         -- Vertical splits to the right

-- Performance
opt.updatetime = 250          -- Faster completion
opt.timeoutlen = 300          -- Key timeout
opt.lazyredraw = true         -- Faster scrolling

-- =============================================================================
-- Plugin Management with lazy.nvim
-- =============================================================================

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- ==========================================================================
  -- UI Enhancements
  -- ==========================================================================

  -- Color scheme
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        transparent = false,
        terminal_colors = true,
      })
      vim.cmd[[colorscheme tokyonight]]
    end,
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'tokyonight',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1, -- Show relative path
            }
          }
        }
      })
    end,
  },

  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup({
        disable_netrw = true,
        hijack_netrw = true,
        view = {
          width = 30,
          side = 'left',
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = { '.git', 'node_modules', '.cache' },
        },
      })
    end,
  },

  -- ==========================================================================
  -- LSP and Completion
  -- ==========================================================================

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'j-hui/fidget.nvim',
    },
  },

  -- Auto-completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
  },

  -- ==========================================================================
  -- Syntax Highlighting and Parsing
  -- ==========================================================================

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'lua', 'vim', 'vimdoc', 'query',
          'javascript', 'typescript', 'tsx',
          'html', 'css', 'json',
          'python', 'rust', 'go',
          'bash', 'yaml', 'toml',
          'markdown', 'markdown_inline',
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- ==========================================================================
  -- Fuzzy Finder
  -- ==========================================================================

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
        pickers = {
          find_files = {
            theme = 'ivy',
          },
        },
      })
      telescope.load_extension('fzf')
    end,
  },

  -- ==========================================================================
  -- Git Integration
  -- ==========================================================================

  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      })
    end,
  },

  -- ==========================================================================
  -- Utilities
  -- ==========================================================================

  -- Comment toggling
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },

  -- Auto pairs
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup({})
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup()
    end,
  },

  -- Which key
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      require('which-key').setup()
    end,
  },
})

-- =============================================================================
-- LSP Configuration
-- =============================================================================

-- Mason setup
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'lua_ls',
    'rust_analyzer',
    'tsserver',
    'pyright',
    'gopls',
    'bashls',
    'yamlls',
  },
})

-- LSP keymaps
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- LSP server configurations
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Lua
require('lspconfig').lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- =============================================================================
-- Auto-completion Setup
-- =============================================================================

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

-- =============================================================================
-- Key Mappings
-- =============================================================================

local keymap = vim.keymap.set

-- General
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
keymap('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
keymap('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save' })

-- File explorer
keymap('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })

-- Telescope
keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = 'Live grep' })
keymap('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = 'Find buffers' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = 'Help tags' })

-- Window navigation
keymap('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Buffer navigation
keymap('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next buffer' })
keymap('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
keymap('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

-- Terminal
keymap('n', '<leader>t', '<cmd>terminal<CR>', { desc = 'Open terminal' })
keymap('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- =============================================================================
-- Auto Commands
-- =============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto-format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Format on save',
  group = vim.api.nvim_create_augroup('format-on-save', { clear = true }),
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
