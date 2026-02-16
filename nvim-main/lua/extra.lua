local M = {}

local function strip_quotes(s)
  return s and s:gsub("^['\"]", ""):gsub("['\"]$", "") or s
end

local function is_debugpy_running(cb)
  local uv = vim.loop
  local sock = uv.new_tcp()

  sock:connect("127.0.0.1", 5678, function(err)
    if err then
      cb(false)
    else
      sock:shutdown()
      sock:close()
      cb(true)
    end
  end)
end

local dap = require('dap')

function M.StartDebugging()
  require('dap').continue()
  vim.cmd("DapViewOpen")
end

M.RunDebugFromComment = function()
    -- Setup dap-python using 'which python'
  local python_path = vim.fn.system("which python"):gsub("\n", "")
  require("dap-python").setup(python_path)

  -- Read current buffer lines
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local debug_cmd = nil

  for _, line in ipairs(lines) do
    local match = line:match("^%s*#%s*Debug:%s*(.+)")
    if match then
      debug_cmd = match
      break
    end
  end

  if not debug_cmd then
    print("No '# Debug:' comment found in file.")
    return
  end

  -- Split the command string into parts
  local parts = {}
  for part in debug_cmd:gmatch("%S+") do
    table.insert(parts, part)
  end

  if #parts < 2 then
    print("Invalid debug command.")
    return
  end

  -- Parse environment variables (before the python executable)
  local env = {}
  local i = 1
  while parts[i] and parts[i]:find("=") do
    local key, val = parts[i]:match("^(.-)=(.*)$")
    if key and val then
      env[key] = tostring(val)
    end
    i = i + 1
  end

  local python_bin = parts[i]
  local script = parts[i + 1]
  local args = {}

  for j = i + 2, #parts do
    table.insert(args, strip_quotes(parts[j]))
  end

   -- Construct config
  local config = {
    type = "python",
    request = "launch",
    name = "Debug from comment",
    program = script,
    args = args,
    pythonPath = python_bin,
    console = "integratedTerminal",
  }

  -- Only add env if it's not empty
  if next(env) ~= nil then
    config.env = env
  end
  require("dap").run(config)
end


function GetParents(dir)
  dir = vim.fn.fnamemodify(dir, ':p:h')
  local arr = { dir }

  while true do
    local par = vim.fn.fnamemodify(dir, ':h')
    if par == dir then
      break
    end

    table.insert(arr, par)
    dir = par
  end

  return arr
end

function RgModeFZFLua()
  local gitpath = vim.fn.system('cd ' .. vim.fn.shellescape(vim.fn.expand('%:p:h')) .. ' && git rev-parse --show-toplevel 2> /dev/null'):sub(1, -2)
  local file = vim.fn.expand("%")

  local folders = GetParents(file)

  local list = {" 0:G) git   [" .. gitpath .. "]"}
  local counter = 1
  for _, i in ipairs(folders) do
    local ts = tostring(counter)
    if counter < 10 then
      ts = ' ' .. ts
    end
    local alias = '     '
    if i == gitpath then
      alias = 'git  '
    elseif i == vim.fn.expand('~') then
      alias = 'home '
    end

    table.insert(list, ts .. ':' .. string.char(string.byte('a') + counter - 1) .. ') ' .. alias .. ' [' .. i .. ']')
    counter = counter + 1
  end

  return list
end

M.fzf_change_dir = function(opts)
  local fzf_lua = require'fzf-lua'
  opts = opts or {}
  opts.prompt = "> "
  -- opts.fn_transform = function(x)
    -- return fzf_lua.utils.ansi_codes.magenta(x)
  -- end
  opts.actions = {
    ['default'] = function(selected)
      -- check if there's symbol '[' in selected[1]
      -- if so, then it's a special path and cd to the path inside []
      -- if not, then it's a normal path and cd to selected[1]
      local start, _ = string.find(selected[1], '%[')
      local cd = selected[1]
      if start ~= nil then
        local endd, _ = string.find(selected[1], '%]')
        local path = string.sub(selected[1], start + 1, endd - 1)
        cd = path
      end
      vim.cmd("cd " .. cd)
      -- vim.notify(' ' .. cd, vim.log.levels.INFO, {title="Find Path Cwd"})
    end
  }

  local parents = RgModeFZFLua()
  local olddir = require 'olddirs'.get()

  for _, d in ipairs(olddir) do
    table.insert(parents, d)
  end

  fzf_lua.fzf_exec(parents, opts)
end

return M
