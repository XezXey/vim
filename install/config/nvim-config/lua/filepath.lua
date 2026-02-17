local M = {}

local status_web_devicons_ok, web_devicons = pcall(require, 'nvim-web-devicons')
local opts = {
  show_file_path = true,
  icons = {
    file_icon_default = '',
    seperator = '>',
    editor_state = '●',
    lock_icon = '',
  },
  exclude_filetype = {
    'help',
    'startify',
    'dashboard',
    'packer',
    'neogitstatus',
    'NvimTree',
    'Trouble',
    'alpha',
    'lir',
    'Outline',
    'spectre_panel',
    'toggleterm',
    'qf',
  }
}
local f = require("utils")

local hl_winbar_path = 'WinBarPath'
local hl_winbar_file = 'WinBarFile'
local hl_winbar_symbols = 'WinBarSymbols'
local hl_winbar_file_icon = 'WinBarFileIcon'

M.get_path = function()
  local file_path = vim.fn.expand('%:~:.:h')
  local filename = vim.fn.expand('%:t')
  local value = ''

  file_path = file_path:gsub('^%.', '')
  file_path = file_path:gsub('^%/', '')

  if not f.isempty(filename) then
    value = ' '
    local file_path_list = {}
    local _ = string.gsub(file_path, '[^/]+', function(w)
      table.insert(file_path_list, w)
    end)

    for i = 1, #file_path_list do
      -- value = value .. '%#' .. hl_winbar_path .. '#' .. file_path_list[i] .. ' ' .. opts.icons.seperator .. ' %*'
      -- value = value .. '%#' .. hl_winbar_path .. '#' .. file_path_list[i] .. '/%*'
      value = value .. file_path_list[i] .. '/'
    end
  end
  -- return '' .. value
  return value
end

local excludes = function()
  return vim.tbl_contains(opts.exclude_filetype, vim.bo.filetype)
end

-- M.init = function()
-- vim.api.nvim_set_hl(0, hl_winbar_path, { fg = f.getHl("LineNR").fg })
-- vim.api.nvim_set_hl(0, hl_winbar_file, { fg = 'blue' })

-- if f.isempty(opts.colors.symbols) then
-- hl_winbar_symbols = 'Function'
-- else
-- vim.api.nvim_set_hl(0, hl_winbar_symbols, { fg = opts.colors.symbols })
-- end
-- end

return M
