local M = {}
-- local frames = { "⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏" }
-- local frames = { "◢", "◣", "◤", "◥" }
local frames = { "◐", "◓", "◑", "◒" }
local timer = nil
local index = 1

local function any_building()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local ok, building = pcall(vim.api.nvim_buf_get_var, buf, 'building')
    -- Check for Vim's v:true (1) or Lua true
    if ok and (building == 1 or building == true) then return true end
  end
  return false
end

function M.start()
  if timer then return end
  timer = vim.loop.new_timer()

  timer:start(0, 50, vim.schedule_wrap(function()
    if any_building() then
      vim.cmd("redrawstatus")
    else
      M.stop()
    end
  end))
end

function M.stop()
  if timer then
    timer:stop()
    if not timer:is_closing() then timer:close() end
    timer = nil
  end
  index = 1 -- Reset for next time
  vim.cmd("redrawstatus")
end

function M.spinner_component()
  index = (index % #frames) + 1
  return frames[index]
end

return M
