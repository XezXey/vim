local function fd_dir_and_file_cmd(dir)
  return "(fd . " .. dir .. " --max-depth 1 --type d; fd . " .. dir .. " --max-depth 1 --type f)"
end

local function is_directory(path)
  return vim.fn.isdirectory(path) == 1
end

_G.fzf_dirs = function(opts)
  local fzf_lua = require'fzf-lua'
  opts = opts or {}
  -- local cwd = opts.cwd or vim.fn.getcwd()
  local cwd = opts.cwd or vim.fn.getcwd()
  -- add trailing / if missing
  if cwd:sub(-1) ~= "/" then
    cwd = cwd .. "/"
  end
  vim.notify("fzf_dirs called: " .. cwd)
  opts.cwd = cwd
  opts.prompt = cwd .. "> "

  opts.fn_transform = function(x)
    x = x:gsub("^" .. cwd, "")
    return x
  end
  opts.actions = {
    ['default'] = function(selected)
      local path = cwd .. selected[1]
      if is_directory(path) then
        local new_opts = vim.tbl_deep_extend("force", opts, {cwd = path})
        _G.fzf_dirs(new_opts)
        -- fzf_lua.actions.set_prompt("yay >")
        -- Reload with the absolute path command
        -- fzf_lua.actions.reload(fd_dir_and_file_cmd(path))
      else
        vim.cmd("edit " .. path)
      end
    end,
    ['ctrl-w'] = {
      function(selected, opts)
        local prompt_text = opts.prompt_text or ""
        print("selected item:", selected[1])
        print(prompt_text)
      end,
      fzf_lua.actions.resume
    },
    ['ctrl-x'] = {
      fn = function(selected)
        for _, f in ipairs(selected) do
          print("deleting:", f)
          -- uncomment to enable deletion
          -- vim.fn.delete(f)
        end
      end,
      reload = true,
    }
  }
  opts.multiprocess = false
  fzf_lua.fzf_exec(fd_dir_and_file_cmd(cwd), opts)
end

-- map our provider to a user command ':Directories'
vim.cmd([[command! -nargs=* Directories lua _G.fzf_dirs()]])

-- or to a keybind, both below are (sort of) equal
-- vim.keymap.set('n', '<C-k>', _G.fzf_dirs)
-- vim.keymap.set('n', '<C-k>', '<cmd>lua _G.fzf_dirs()<CR>')

-- We can also send call options directly
-- :lua _G.fzf_dirs({ cwd = <other directory> })
