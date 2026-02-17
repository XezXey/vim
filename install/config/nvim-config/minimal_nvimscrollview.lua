vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local plugins = {
  {
    "dstein64/nvim-scrollview",
    opts = {
      excluded_filetypes = { 'nerdtree' },
      current_only = true,
      base = 'right',
      column = 1,
      signs_on_startup = { '' },
      diagnostics_severities = { vim.diagnostic.severity.ERROR }
    }
  },
}

require("lazy.minit").repro({ spec = plugins })

