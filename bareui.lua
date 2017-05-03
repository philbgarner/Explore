local bareui = {}


function bareui:addWidget(id, text, x, y, w, h, draw, click, keypress)

  bareui.widgets[id] = {id = id, visible = true, text = text, x = x, y = y, w = w, h = h, fnDraw = draw, fnClick = click, fnKeyPress = keypress}

end

function bareui:removeWidget(id)
  bareui.widgets[id] = nil
end

function bareui:create()

  bareui = {
      widgets = {}
      ,images = {}
    }
    
  bareui.images.ui_background_tilepalette = love.graphics.newImage("images/ui_background_tilepalette.png")
  bareui.images.ui_background_mapborder = love.graphics.newImage("images/ui_mapborder.png")
  bareui.images.ui_select_jewel = love.graphics.newImage("images/ui_select_jewel.png")
  bareui.images.ui_select_jewel_off = love.graphics.newImage("images/ui_select_jewel_off.png")
  bareui.images.ui_left_right_button = love.graphics.newImage("images/left-right-buttons.png")
  bareui.images.ui_terrain_types = love.graphics.newImage("images/terraintypes.png")
  bareui.images.ui_button = love.graphics.newImage("images/ui_button.png")
  bareui.images.ui_zoom_control = love.graphics.newImage("images/ui_zoom_control.png")
  bareui.images.ui_flags = love.graphics.newImage("images/ui_flags.png")
  
end

function bareui:getImages()
  
  return bareui.images
  
end

function bareui:getWidgets()
  
  return bareui.widgets
  
end

function bareui:draw()

  for k, v in pairs(bareui.widgets) do
    bareui.widgets[k].fnDraw()
  end

end


function bareui:mousepressed(x, y, button)

  for k, v in pairs(bareui.widgets) do
    bareui.widgets[k].fnClick(x, y, button)
  end

end

return bareui