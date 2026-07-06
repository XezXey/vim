_G.fzf_dirs = function(opts)
  local fzf_lua = require'fzf-lua'
  opts = opts or {}
  opts.prompt = "Directories> "
  opts.fn_transform = function(x)
    return fzf_lua.utils.ansi_codes.magenta(x)
  end
  opts.actions = {
    ['default'] = function(selected)
      vim.cmd("cd " .. selected[1])
    end
  }
  opts.multiprocess = false
  fzf_lua.fzf_exec("fd --type d", opts)
end

-- map our provider to a user command ':Directories'
vim.cmd([[command! -nargs=* Directories lua _G.fzf_dirs()]])

