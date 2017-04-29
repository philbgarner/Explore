--[[

  Flags class
  
  By Phil Garner
  April 2017
  
  Dynamically build nation flags using layered colours
  blended according to the blend masks supplied
  as an external PNG.  The non-transparent parts of the
  masks are the parts that will be drawn with the specified
  colour for that layer.
  
  Future state: Badges and heraldic devices will be supplied
  in an external PNG and can be overlaid on one of the 4
  quadrants or centre-aligned.
  
  Usage:
  
  -- Create new flag.
  local new_flag = Flag:new("Union Jack", 18, 12, 0, 0, 255) -- Give a name to the flag, specify width/height and set the background colour.
  
  -- Add a new layer.
  new_flag:addLayer(10, 255, 255, 0) -- Place a yellow cross on the background
  
  
  
]]--

local Flag = {}
Flag.__index = Flag

local ui_flag_blends = love.graphics.newImage("images/ui_flag_blends_90x60.png")

function Flag:new(name, width, height, r, g, b)
  
  local itm = {}
  setmetatable(itm, Flag)
  itm.name = name
  itm.width = width
  itm.height = height
  itm.layers = {}
  itm:addLayer(0, r, g, b)
  
  itm.ui_blends_quads = {}
  
  local dx = 0
  for i=1, 255 do
    table.insert(itm.ui_blends_quads, love.graphics.newQuad(dx, 0, width, height, ui_flag_blends:getDimensions()))
    dx = dx + width
  end
  
  return itm
  
end

function Flag:addLayer(blendId, r, g, b)
  
  table.insert(self.layers, {id = blendId, r = r, g = g, b = b})
  
end

function Flag:getLayer(layer)
  
  if self.layers[layer] == nil then return false end
  
  return self.layers[layer]
  
end

function Flag:draw(x, y, scale)
  
  if scale == nil then scale = 1 end
  
  love.graphics.push()
  love.graphics.scale(scale, scale)
  for i=1, #self.layers do
    
    local blendID = self.layers[i].id
    local r = self.layers[i].r
    local g = self.layers[i].g
    local b = self.layers[i].b
    
    -- Blending is only necessary if blendID > 0
    if blendID > 0 then
      love.graphics.setColor(r, g, b)
      love.graphics.draw(ui_flag_blends, self.ui_blends_quads[blendID], x, y)
    else
      love.graphics.setColor(r, g, b)
      love.graphics.rectangle("fill", x, y, self.width, self.height)
    end
    
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.pop()
  
end

return Flag