
console = require "Console"
world = require "worldmap"
bitser = require "bitser"
local ui = require "bareui"
suit = require 'suit'

console_active = false

-- Game UI settings
world_x = 640
world_y = 270

-- Minimap
minimap_show = 1
sel_voronoi = 0

map_image = nil

-- Tile Palette
page_no = 1
page_max = 1
tile_sel = 1
blend_sel = 0
tile2_sel = 1
sel_layer = 1

-- Main Map Stuff

tooltip_x = 0
tooltip_y = 0
tooltip = false
tooltip_desc = ""

-- Preview Canvas Stuff
prvCanvas = nil
prvImage = nil
prvZoom = 1
prvOffsetX = 0
prvOffsetY = 0
prvProvinceName = {text = ""}

function love.draw()

  world:draw()
  
  ui.draw()
  
  if tooltip then
    local dx = tooltip_x * 32
    local dy = tooltip_y * 32
    
    love.graphics.print(tooltip_desc, dx, dy)
  end
  
  if map_image ~= nil then
    love.graphics.draw(map_image, 50, 50)
  end
  
  suit.draw()
  if console_active then
    console:draw()
  end
  
end

function love.textinput(key)
  
  if key == "~" then
    console_active = not console_active
    return
  end
  
  if console_active then
    console:keyInput(key)
  else
    suit.textinput(key)
  end
  
end

function love.keypressed(key, scancode)

  if console_active then
    console:keypress(key, scancode)
  else
    suit.keypressed(key)
  end
  
end

function love.mousepressed(x, y, button)
  
  ui:mousepressed(x, y, button)

  if button == 2 then
    local mx = tonumber(math.floor(x / world:getTileset().width)) + world.scrollx
    local my = tonumber(math.floor(y / world:getTileset().height)) + world.scrolly
    local t = world.data.map[1][my][mx]
    local p = world.data.provinces[my][mx]
    local a = world:getHeight(mx, my)
    tooltip_desc = "Prov: " .. t.name .. ",Alt: " .. a .. ",Lat: " .. 0 .. ",Precip: " .. p.precipitation
    tooltip_x = tonumber(math.floor(x / world:getTileset().width)) + 1
    tooltip_y = tonumber(math.floor(y / world:getTileset().height))
    tooltip = true
  end
  
end

function love.mousemoved(x, y, dx, dy)
   
  if love.mouse.isDown(1) then
    local mx = tonumber(math.floor(x / world:getTileset().width)) + 1
    local my = tonumber(math.floor(y / world:getTileset().height)) + 1
    
    world:setMap(sel_layer, mx, my, blend_sel, tile_sel, tile2_sel)
  end
  
end

function love.update(dt)
  
  if love.keyboard.isDown("up") then
    world.scrolly = world.scrolly - 1
  end
  if love.keyboard.isDown("left") then
    world.scrollx = world.scrollx - 1
  end
  if love.keyboard.isDown("right") then
    world.scrollx = world.scrollx + 1
  end
  if love.keyboard.isDown("down") then
    world.scrolly = world.scrolly + 1
  end
  if world.scrollx < 1 then world.scrollx = 1 end
  if world.scrolly < 1 then world.scrolly = 1 end
  world:update(dt)
  
end

function refreshPreview()
  local pts = world:getProvincePoints()
    
  local wl = world.data.water_level
  
  local type_colours = {
      {0, 200, 0}
      ,{200, 200, 0}
      ,{190, 160, 160}
      ,{60, 170, 225}
      ,{0, 75, 0}
      ,{240, 240, 250}
    }
  
  love.graphics.setCanvas(prvCanvas)
  for i=1, world.data.map_height do
    for j=1, world.data.map_width do
      local id = world.data.provinces[i][j].id
      local h = 0.5
      if pts[id] ~= nil then
        h = pts[id].avg_height
      end
      if id ~= nil and id > 0 then
        local cl = type_colours[pts[id].province_type]
        love.graphics.setColor(cl[1], cl[2], cl[3])
        love.graphics.rectangle("line", pts[id].x, pts[id].y, 1, 1)
        love.graphics.setColor(255, 255, 255)
      end
      local th = world:getHeight(j - 1, i - 1) * h
      if th <= wl then
        love.graphics.setColor(15, 75, 225)
      else
        local cl = {150, 150, 150}
        if pts[id] ~= nil then
          cl = type_colours[pts[id].province_type]
        end
        love.graphics.setColor(th * (cl[1]), th * (cl[2]), th * (cl[3]), 255)
      end
      love.graphics.points(j, i)
      love.graphics.setColor(255, 255, 255)
    end
  end
  love.graphics.setCanvas()
  prvImage = love.graphics.newImage(prvCanvas:newImageData())
end

function love.load()
  
  console:create(function () end,
    function (command, args) -- Command callback (command controller function).

      if command == "help" then

        console:write("-= Help =-", console.color_yellow)
        console:write("world - This command gives access to the properties and objects inside the game engine.")
        console:write("       Example: Entering 'game name' will output the level name, while 'game name TestLevel1' will set the level name. ")

        return "help - Displays this help command."
      elseif command == "world" and args[1] == "data" then

        if #args == 0 then return "Error: No game object reference provided in the first argument." end

        local cmd = "world." .. args[1] .. "." .. args[2]

        if #args == 3 then
          local p1type = loadstring("return type(" .. cmd .. ")")
          local pt = p1type()
          console:write("Type: " .. pt)
          if string.sub(pt, 1, 5) == "table" then
            local cmd = "return world." .. args[1] .. "." .. args[2]

            local comm = loadstring(cmd)
            local v = comm()
            return "Get Value: " .. cmd .. " -> " .. tostring(v)
          else
            local vtype = loadstring("return type(" .. args[2] .. ")")
           
            if vtype() == "number" then
              cmd = cmd .. " = " .. args[2]
            elseif string.sub(vtype(), 1, 5) == "table" then
              console:write("TODO: List the members of this table and return that value to console.")
            elseif vtype() == "nil" and args[2] ~= nil then -- then we'll just assume it's a string and wrap it in quotes...
              cmd = cmd .. " = \"" .. args[2] .. "\""
            end
            local comm = loadstring(cmd)
            local v = comm()
            return "Successfully set value to " .. args[2] .. "."
          end
        elseif #args == 4 then 
          -- TODO: Set the value in the nested table (Example: game properties water_level 2500)
        elseif #args == 2 then
          local comm = loadstring("return " .. cmd)
          local v = comm()
          return "Get Value: " .. cmd .. " -> " .. tostring(v)
        end 
      elseif command == "world" and #args == 1 then
        local cmd = "world." .. args[1]
        local p1type = loadstring("return type(" .. cmd .. ")")
        local pt = p1type()
        local v = ""
        if pt == "function" then
          cmd = "world:" .. args[1] .. "()"
          local comm = loadstring("return " .. cmd)
          v = comm()
        else
          local comm = loadstring("return " .. cmd)
          v = comm()
        end
        if v == nil then v = "Command '" .. cmd .. "' executed." end
        return "" .. v
      end

      return "Command '" .. command .. "' not found."
    end
  )
  console:write("-= Game Console =-")

  world:create("World1", world_x, world_y)
  world:tileset("images/tileset.png", "images/blendtiles.png", 32, 32)
  world:map(world_x, world_y)
  --world:loadProvincePoints()
  world:voronoi()
  --world:generateMap()
  
  prvCanvas = love.graphics.newCanvas(world_x, world_y)
  refreshPreview()
  
  --world:heightMap(0.2, 0.8, 0.5)

  ui:create()

  ui:addWidget("tile_palette", "Tile Palette", 350, 0, 303, 243
      ,function () -- fnDraw
        love.graphics.draw(ui:getImages().ui_background_tilepalette, 500, 0)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(ui:getWidgets().tile_palette.text, 560, 33)
        love.graphics.setColor(255, 255, 255)
        
        local c = 1
        local ix = 515
        local dx = ix
        local dy = 76
        
        for k, v in pairs(world:getTileset().tiles) do
       
          love.graphics.draw(world:getTileset().image, v, dx, dy)
          if tile_sel == c then
            love.graphics.setColor(255, 255, 0)  
            love.graphics.rectangle("line", dx, dy, world:getTileset().width, world:getTileset().height)
            love.graphics.setColor(255, 255, 255)  
          end   
        
          love.graphics.draw(world:getTileset().blend_image, v, dx, dy + 165)
          love.graphics.setColor(255, 255, 255)  
          if blend_sel ~= nil and blend_sel == c then
            love.graphics.setColor(255, 255, 0)  
            love.graphics.rectangle("line", dx, dy + 165, world:getTileset().width, world:getTileset().height)
            love.graphics.setColor(255, 255, 255)  
          end    

          love.graphics.draw(world:getTileset().image, v, dx, dy + 320) 
          if tile2_sel == c then
            love.graphics.setColor(255, 255, 0)  
            love.graphics.rectangle("line", dx, dy + 320, world:getTileset().width, world:getTileset().height)
            love.graphics.setColor(255, 255, 255)  
          end          
          
          dx = dx + world:getTileset().width + 1
          if dx > 753 then
            dx = ix
            dy = dy + world:getTileset().height + 1
          end
          c = c + 1
        end
        
      end
      ,function (x, y, button) -- fnClick
        
        if x < 515 or x > 771 then
   
          return
          
        end
        
        if button == 1 then
          
          if y >= 76 and y < 76 + 96 then
            tsx = tonumber(math.floor((x - 515) / world:getTileset().width))
            tsy = tonumber(math.floor((y - 76) / world:getTileset().height))
            tile_sel = (tsy * (world:getTileset().image_height / world:getTileset().height)) + tsx + 1
          end
          
          if y >= 240 and y < 240 + 96 then
            tsx = tonumber(math.floor((x - 515) / world:getTileset().width))
            tsy = tonumber(math.floor((y - 240) / world:getTileset().height))
            blend_sel = (tsy * (world:getTileset().image_height / world:getTileset().height)) + tsx + 1
          end
          
          if y >= 398 and y < 398 + 96 then
             tsx = tonumber(math.floor((x - 515) / world:getTileset().width))
            tsy = tonumber(math.floor((y - 398) / world:getTileset().height))
            tile2_sel = (tsy * (world:getTileset().image_height / world:getTileset().height)) + tsx + 1
          end
          
          return
        end
        
        if button == 2 then
          
          if y >= 76 and y <= 76 + 118 then
            tile_sel = 1
          end
          
          if y >= 165 and y <= 165 + 118 then
            blend_sel = 0
          end
          
          if y >= 320 and y <= 320 + 118 then
            tile2_sel = 1
          end
        end 
          
      end 
      ,function (key, scancode)
        
      end
    
    )
    ui:addWidget("minimap", "Minimap", 25, 25, 303, 243
      ,function () -- fnDraw
        love.graphics.draw(ui:getImages().ui_background_mapborder, 25, 25)
  
        love.graphics.draw(ui:getImages().ui_select_jewel_off, 155, 15)
        love.graphics.draw(ui:getImages().ui_select_jewel_off, 260, 15)
        love.graphics.draw(ui:getImages().ui_select_jewel_off, 50, 15)
        
        love.graphics.print("Selected Prov. #: ".. sel_voronoi, 50, 385)
        love.graphics.draw(ui:getImages().ui_left_right_button, 25, 400)
        
        if #world:getProvincePoints() > 0 and sel_voronoi > 0 then
          local pts = world:getProvincePoints()
          love.graphics.setColor(0, 150, 225)
          local hw = math.floor(pts[sel_voronoi].avg_height * 100)
          love.graphics.rectangle("fill", 275, 385, hw, 15)
          love.graphics.setColor(255, 255, 255)
          love.graphics.rectangle("line", 275, 385, 100, 15)
          love.graphics.print("Avg. Height: ".. pts[sel_voronoi].avg_height, 190, 385)

          love.graphics.draw(ui.getImages().ui_terrain_types, 190, 410)
          love.graphics.rectangle("line", 190 + 37 * (pts[sel_voronoi].province_type - 1), 410, 37, 25)
                
          -- SUIT UI Stuff
          prvProvinceName.text = pts[sel_voronoi].name
          suit.Input(prvProvinceName, 390, 385, 120, 15)
          pts[sel_voronoi].name = prvProvinceName.text
          
          suit.layout:reset(520, 385, 0, 0)
          
          if suit.Button("Del", suit.layout:row(35,15)).hit then
            world:delProvince(sel_voronoi)
            world:voronoi()
            refreshPreview()
          end
          
        end
        
        local viewport_w = (world.data.map_width / prvZoom) / 2
        local viewport_h = (world.data.map_height / prvZoom) / 2
        if minimap_show == 3 then -- Preview
          love.graphics.draw(ui:getImages().ui_select_jewel, 260, 15)
          
          local pts = world:getProvincePoints()
          if #pts > 0 then
            love.graphics.setScissor(40, 40, world.data.map_width, world.data.map_height)
            
            love.graphics.push()
            love.graphics.scale(prvZoom)
            love.graphics.translate(-prvOffsetX + viewport_w, -prvOffsetY + viewport_h)     
            if world.data.map_width ~= nil then
              love.graphics.draw(prvImage, 0, 0)
              if sel_voronoi > 0 then
                love.graphics.setColor(255, 0, 0)
                love.graphics.rectangle("line", pts[sel_voronoi].x - 4, pts[sel_voronoi].y - 4, 8, 8)
                love.graphics.setColor(255, 255, 255)
              end
            end
            love.graphics.pop()
            love.graphics.setScissor()
          end
          --love.graphics.draw(world.data.heightmap, 41, 40)
          
        elseif minimap_show == 2 then -- Provinces
          love.graphics.draw(ui:getImages().ui_select_jewel, 155, 15)
          local pids = world:getProvincePoints()
          
          if world.data.map_width ~= nil then
            love.graphics.setScissor(40, 40, world.data.map_width, world.data.map_height)
            love.graphics.push()
            love.graphics.scale(prvZoom)
            love.graphics.translate(-prvOffsetX, -prvOffsetY)
            for i=1, world.data.map_height do
              for j=1, world.data.map_width do
                local id = world.data.provinces[i][j].id
                local avg_height = world.data.provinces[i][j].avg_height
                if id ~= nil and id > 0 then
                  love.graphics.setColor(pids[id].avg_height * 255, pids[id].avg_height * 255, pids[id].avg_height * 255, 255)
                  love.graphics.points(40 + j, 40 + i)
                  love.graphics.setColor(255, 0, 0)
                  love.graphics.circle("line", pids[id].x + 40, pids[id].y + 40, 4)
                  love.graphics.setColor(255, 255, 255)
                  if sel_voronoi > 0 then
                    love.graphics.setColor(255, 255, 0)
                    love.graphics.rectangle("line", pids[sel_voronoi].x - 4 + 40, pids[sel_voronoi].y - 4 + 40, 8, 8)
                    love.graphics.setColor(255, 255, 255)
                  end
                end
              end
            end
            love.graphics.pop()
            love.graphics.setScissor()
          end
        elseif minimap_show == 1 then -- Heightmap
          love.graphics.draw(ui:getImages().ui_select_jewel, 50, 15)
          love.graphics.setScissor(40, 40, world.data.map_width, world.data.map_height)
          love.graphics.push()
          love.graphics.scale(prvZoom)
          love.graphics.translate(-prvOffsetX, -prvOffsetY)  
            love.graphics.draw(world.data.heightmap, 41, 40) 
          love.graphics.pop()
          love.graphics.setScissor()
        end
        
        local offz = 0
        if prvZoom <= 1 then
          offz = (87) * prvZoom
        else
          offz = 87 + (prvZoom / 10) * 87
        end
        love.graphics.draw(ui.getImages().ui_zoom_control, 60, 50)
        love.graphics.rectangle("fill", 60, 66 + 174 - offz, 16, 4)
        love.graphics.print("z" .. prvZoom, 60, 35)
        
        love.graphics.print("Heightmap", 80, 23)
        love.graphics.print("Provinces", 185, 23)
        love.graphics.print("Preview", 290, 23)
        
        love.graphics.draw(ui.getImages().ui_button, 580, 400)
        love.graphics.print("Generate Map", 590, 405)
              
      end
      ,function (x, y, button) -- fnClick
          
        if button == 2 then
          
          prvOffsetX = x - 40
          prvOffsetY = y - 40
          return
          
        end
          
        if x > 50 and y > 15 and x < 77 and y < 45 then
          minimap_show = 1
          return
        elseif x > 155 and y > 15 and x < 182 and y < 45 then
          minimap_show = 2
          return
        elseif x > 260 and y > 15 and x < 287 and y < 45 then
          minimap_show = 3
          return
        end
        
        if x > 190 and y > 410 and x < 228 + 190 and y < 425 then
          local ptype = math.floor((x - 190) / 38) + 1;
          world:setProvinceType(sel_voronoi, ptype)
          refreshPreview()
          return
        end
        
        if x > 580 and x < 580 + 220 and y > 400 and y < 435 then
          world:generateMap()
          ui:removeWidget("minimap")
          return
        end
        
        -- Left/right province selector.
        if x > 25 and x < 76 and y > 400 and y < 430 then
          sel_voronoi = sel_voronoi - 1
          if sel_voronoi < 1 then sel_voronoi = #world:getProvincePoints() end
          prvOffsetX = world:getProvincePoints()[sel_voronoi].x
          prvOffsetY = world:getProvincePoints()[sel_voronoi].y
          return
        elseif x > 76 and x < 101 and y > 400 and y < 430 then
          sel_voronoi = sel_voronoi + 1
          if sel_voronoi > #world:getProvincePoints() then sel_voronoi = 1 end
          prvOffsetX = world:getProvincePoints()[sel_voronoi].x
          prvOffsetY = world:getProvincePoints()[sel_voronoi].y
          return
        end
        
        -- Height setting.
        if x >= 275 and x <= 375 and y > 385 and y < 400 then
          local ah = (x - 275) / 100
          world:setProvinceHeight(sel_voronoi, ah)
          refreshPreview()
          return
        end
        
        -- Zoom Control
--         love.graphics.draw(ui.getImages().ui_zoom_control, 60, 50)
--        love.graphics.rectangle("fill", 60, 66 + 174 - offz, 16, 4)
        if x > 60 and x < 76 and y > 50 and y < 66 then
          prvZoom = prvZoom + 0.1
          return
        elseif x > 60 and x < 76 and y > 50 + 174 and y < 66 + 174 then
          prvZoom = prvZoom - 0.1
          return
        end        
        
                
        if x > 40 and y > 40 and x < 40 + world.data.map_width and y < 40 + world.data.map_height then
          local viewport_w = (world.data.map_width / prvZoom) / 2
          local viewport_h = (world.data.map_height / prvZoom) / 2
          local ph = 1.0 --world:getHeight(x, y)

          local mx = x
          local my = y
          local mapx = math.floor((mx) / prvZoom + prvOffsetX - viewport_w)
          local mapy = math.floor((my) / prvZoom + prvOffsetY - viewport_h)
          world:addProvince(mapx, mapy, ph)
          world:voronoi()
          refreshPreview()
        end
        
      end 
      ,function (key, scancode)
        
      end
    
    )

end