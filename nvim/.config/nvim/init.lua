vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.cursorlineopt = "number"
opt.colorcolumn = "120"
opt.signcolumn = "yes"
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 4
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 4
opt.undofile = true
opt.updatetime = 200
opt.confirm = true
opt.wrap = false
opt.list = true
opt.listchars = { tab = "│ ", trail = "·", nbsp = "␣" }

local function update_indent_guides()
  local width = vim.fn.shiftwidth()
  vim.opt_local.listchars:append({ leadmultispace = "│" .. string.rep(" ", width - 1) })
end
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, { callback = update_indent_guides })
vim.api.nvim_create_autocmd("OptionSet", { pattern = { "shiftwidth", "tabstop" }, callback = update_indent_guides })

local map = vim.keymap.set

-- Karabiner turns left Ctrl+hjkl into arrow keys, so arrows act as Neovim's Ctrl+hjkl window navigation
map("n", "<Left>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<Down>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<Up>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<Right>", "<C-w>l", { desc = "Go to Right Window" })

map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>")
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File browser (netrw)" })

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      local plain = { link = "GruvboxFg1" }
      require("gruvbox").setup({
        contrast = "soft",
        bold = false,
        italic = { strings = false, emphasis = false },
        overrides = {
          ["@variable.parameter"] = plain,
          ["@lsp.type.parameter"] = plain,
          ["@variable.member"] = plain,
          ["@property"] = plain,
          ["@punctuation.delimiter"] = plain,
          -- Otherwise gopls paints package names inside import strings as plain text
          ["@lsp.type.namespace"] = {},
        },
      })
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>f.", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = { layout_config = { prompt_position = "top" }, sorting_strategy = "ascending" },
      })
      telescope.load_extension("fzf")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").install({
        "go", "gomod", "gowork", "gosum", "python", "c", "cpp", "lua", "vim", "vimdoc",
        "bash", "json", "yaml", "toml", "markdown", "markdown_inline",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  { "HiPhish/rainbow-delimiters.nvim", lazy = false },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        map("n", "]h", function() gs.nav_hunk("next") end, { buffer = buf, desc = "Next hunk" })
        map("n", "[h", function() gs.nav_hunk("prev") end, { buffer = buf, desc = "Previous hunk" })
        map("n", "<leader>gp", gs.preview_hunk, { buffer = buf, desc = "Preview hunk" })
        map("n", "<leader>gr", gs.reset_hunk, { buffer = buf, desc = "Reset hunk" })
        map("n", "<leader>gb", gs.blame_line, { buffer = buf, desc = "Blame line" })
      end,
    },
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "enter" },
      completion = { ghost_text = { enabled = false }, documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "buffer" } },
    },
  },

  { "mason-org/mason.nvim", opts = {} },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
    config = function()
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      vim.lsp.config("pylsp", {
        settings = { pylsp = { plugins = { jedi = {} } } },
        before_init = function(_, config)
          local python = config.root_dir and config.root_dir .. "/venv/bin/python"
          config.settings.pylsp.plugins.jedi.environment = python and vim.uv.fs_stat(python) and python or nil
        end,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
          },
        },
      })

      vim.lsp.enable({ "gopls", "pylsp", "clangd", "lua_ls" })
      vim.diagnostic.config({ virtual_text = true, severity_sort = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local builtin = require("telescope.builtin")
          local function lmap(lhs, rhs, desc, mode)
            map(mode or "n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          lmap("gh", vim.lsp.buf.hover, "Hover")
          lmap("g.", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
          lmap("cd", vim.lsp.buf.rename, "Rename")
          lmap("gd", builtin.lsp_definitions, "Go to Definition")
          lmap("gy", builtin.lsp_type_definitions, "Go to Type Definition")
          lmap("gI", builtin.lsp_implementations, "Go to Implementation")
          lmap("gA", builtin.lsp_references, "All References")
          lmap("gs", builtin.lsp_document_symbols, "Document Symbols")
          lmap("gS", builtin.lsp_dynamic_workspace_symbols, "Workspace Symbols")
        end,
      })
    end,
  },
}, {
  install = { colorscheme = { "gruvbox" } },
  change_detection = { notify = false },
})
