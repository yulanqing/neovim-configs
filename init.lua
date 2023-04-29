--------------------------------------------------------------------------------
-- filetype
--------------------------------------------------------------------------------

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

--------------------------------------------------------------------------------
-- misc
--------------------------------------------------------------------------------

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.swapfile = false

vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.undofile = true

--------------------------------------------------------------------------------
-- search
--------------------------------------------------------------------------------

vim.opt.ignorecase = true
vim.opt.smartcase = true

--------------------------------------------------------------------------------
-- visual
--------------------------------------------------------------------------------

-- highlight the cursor line
vim.opt.cursorline = true

vim.opt.number = true
vim.opt.relativenumber = true

-- always show the sign column
vim.opt.signcolumn = "yes"

-- always show the tab line
vim.opt.showtabline = 2

vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = false,
  float = { border = "rounded" },
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = "rounded" }
)

--------------------------------------------------------------------------------
-- keymaps
--------------------------------------------------------------------------------

vim.g.mapleader = " "

local keymap = vim.keymap.set

keymap("n", "<M-->", "<Cmd>split<CR>")
keymap("n", "<M-\\>", "<Cmd>vsplit<CR>")
keymap("n", "<M-H>", "<C-w>h")
keymap("n", "<M-J>", "<C-w>j")
keymap("n", "<M-K>", "<C-w>k")
keymap("n", "<M-L>", "<C-w>l")
keymap("n", "<Leader><Leader>", "<C-^>")

-- paste without yank
keymap("v", "p", '"_dP')

-- shift continuously
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

keymap("n", "j",  "gj")
keymap("n", "k",  "gk")

keymap("n", "<M-w>",  "<Cmd>bd<CR>")
keymap("n", "<M-h>", "<Cmd>tabp<CR>")
keymap("n", "<M-j>", "<C-i>")
keymap("n", "<M-k>", "<C-o>")
keymap("n", "<M-l>", "<Cmd>tabn<CR>")

--------------------------------------------------------------------------------
-- plugins
--------------------------------------------------------------------------------

-- https://github.com/folke/lazy.nvim
local path_lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(path_lazy) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",  -- latest stable release
    path_lazy,
  })
end
vim.opt.rtp:prepend(path_lazy)

require("lazy").setup({
  -- colorscheme
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.g.tokyonight_style = "night"
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- lsp
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").pylsp.setup({
        settings = {
          pylsp = {
            plugins = {
              flake8 = {
                enabled = true,
                maxLineLength = 119,
              },
              pycodestyle = {
                enabled = false,
              },
              pyflakes = {
                enabled = false,
              },
            },
          },
        },
      })

      keymap("n", "gR", vim.lsp.buf.rename)
      keymap("n", "gr", vim.lsp.buf.references)
      keymap("n", "gt", vim.diagnostic.open_float)
      keymap("n", "gD", vim.lsp.buf.declaration)
      keymap("n", "gd", vim.lsp.buf.definition)
      keymap("n", "gF", function() vim.lsp.buf.format({ async = true }) end)
      keymap("n", "gh", vim.lsp.buf.hover)
      keymap("n", "gN", vim.diagnostic.goto_prev)
      keymap("n", "gn", vim.diagnostic.goto_next)
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
        },
        mapping = cmp.mapping.preset.insert({
          -- enable tab completion
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" })
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },

  -- utils
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      keymap("n", "<M-o>", require("telescope.builtin").find_files)
      keymap("n", "<M-f>", require("telescope.builtin").live_grep)
    end
  },

  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        open_mapping = "<M-CR>",
        direction = "vertical",
        size = function (term)
          return vim.o.columns * .4
        end,
      })
    end,
  },

  { "windwp/nvim-autopairs", event = "InsertEnter", config = true, },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({ mappings = false })
      keymap("n", "gC", "<Plug>(comment_toggle_linewise_current)")
      keymap("v", "gC", "<Plug>(comment_toggle_linewise_visual)")
    end,
  },

  { "rmagatti/auto-session", config = true, },
})
