-- Our lua/utils.lua file
local M = {}
local api = vim.api
local autocmd = vim.api.nvim_create_autocmd


function M.map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    -- print(vim.inspect(options))
    vim.keymap.set(mode, lhs, rhs, options)
end

function M.isempty(s)
    return s == nil or s == ''
end


M.run_without_TSContext = function(f, opts)
  opts = opts or {}
  return function()
    vim.cmd ":TSContext disable"
    f(opts)
    -- require'hop'.hint_char1()
    vim.cmd ":TSContext enable"
    if opts["postcmd"] ~= nil then
      vim.api.nvim_feedkeys(opts["postcmd"], '', true)
    end
  end
end

function M.getHl(hlname)
  return vim.api.nvim_get_hl_by_name(hlname, true)
end

return M
