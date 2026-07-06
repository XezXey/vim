local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")

local RgbHslCmykInput = setmetatable({
  name = "HSL/RGB",
  max = { 360, 1, 1, 1, 1, 1 },
  min = { 0, 0, 0, 0, 0, 0 },
  delta = { 1, 0.01, 0.01, 1 / 255, 1 / 255, 1 / 255 },
  bar_name = { "H", "S", "L", "R", "G", "B" },
}, { __index = ColorInput })

function RgbHslCmykInput.format(n, i)
  if i >= 4 and i <= 6 then
    -- RGB
    n = n * 255
  elseif i == 2 or i == 3 then
    -- S or L of HSL
    n = n * 100
  end
  return ("%6d"):format(n)
end

function RgbHslCmykInput.from_rgb(RGB)
  local HSL = convert.rgb2hsl(RGB)
  local R, G, B = unpack(RGB)
  local H, S, L = unpack(HSL)
  return { H, S, L, R, G, B }
end

function RgbHslCmykInput.to_rgb(value)
  return { value[4], value[5], value[6] }
end

function RgbHslCmykInput:_set_rgb(RGB)
  self.value[4] = RGB[1]
  self.value[5] = RGB[2]
  self.value[6] = RGB[3]
end

function RgbHslCmykInput:_set_hsl(HSL)
  self.value[1] = HSL[1]
  self.value[2] = HSL[2]
  self.value[3] = HSL[3]
end

function RgbHslCmykInput:callback(index, new_value)
  self.value[index] = new_value
  local v = self.value
  if index >= 4 and index <= 6 then
    local RGB = { v[4], v[5], v[6] }
    local HSL = convert.rgb2hsl(RGB)
    local CMYK = convert.rgb2cmyk(RGB)
    self:_set_hsl(HSL)
  elseif index <= 3 then
    local HSL = { v[1], v[2], v[3] }
    local RGB = convert.hsl2rgb(HSL)
    local CMYK = convert.rgb2cmyk(RGB)
    self:_set_rgb(RGB)
  end
end

return RgbHslCmykInput
