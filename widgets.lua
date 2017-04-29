
--  ui:addWidget("tile_palette", "Tile Palette", 350, 0, 303, 243
--      ,function () -- fnDraw
--        love.graphics.draw(ui:getImages().ui_background_tilepalette, 500, 0)
--        love.graphics.setColor(0, 0, 0)
--        love.graphics.print(ui:getWidgets().tile_palette.text, 560, 33)
--        love.graphics.setColor(255, 255, 255)
        
--        local c = 1
--        local ix = 515
--        local dx = ix
--        local dy = 76
        
--        for k, v in pairs(world:getTileset().tiles) do
       
--          love.graphics.draw(world:getTileset().image, v, dx, dy)
--          if tile_sel == c then
--            love.graphics.setColor(255, 255, 0)  
--            love.graphics.rectangle("line", dx, dy, world:getTileset().width, world:getTileset().height)
--            love.graphics.setColor(255, 255, 255)  
--          end   
        
--          love.graphics.draw(world:getTileset().blend_image, v, dx, dy + 165)
--          love.graphics.setColor(255, 255, 255)  
--          if blend_sel ~= nil and blend_sel == c then
--            love.graphics.setColor(255, 255, 0)  
--            love.graphics.rectangle("line", dx, dy + 165, world:getTileset().width, world:getTileset().height)
--            love.graphics.setColor(255, 255, 255)  
--          end    

--          love.graphics.draw(world:getTileset().image, v, dx, dy + 320) 
--          if tile2_sel == c then
--            love.graphics.setColor(255, 255, 0)  
--            love.graphics.rectangle("line", dx, dy + 320, world:getTileset().width, world:getTileset().height)
--            love.graphics.setColor(255, 255, 255)  
--          end          
          
--          dx = dx + world:getTileset().width + 1
--          if dx > 753 then
--            dx = ix
--            dy = dy + world:getTileset().height + 1
--          end
--          c = c + 1
--        end
        
--      end
--      ,function (x, y, button) -- fnClick
        
--        if x < 515 or x > 771 then
   
--          return
          
--        end
        
--        if button == 1 then
          
--          if y >= 76 and y < 76 + 96 then
--            tsx = tonumber(math.floor((x - 515) / world:getTileset().width))
--            tsy = tonumber(math.floor((y - 76) / world:getTileset().height))
--            tile_sel = (tsy * (world:getTileset().image_height / world:getTileset().height)) + tsx + 1
--          end
          
--          if y >= 240 and y < 240 + 96 then
--            tsx = tonumber(math.floor((x - 515) / world:getTileset().width))
--            tsy = tonumber(math.floor((y - 240) / world:getTileset().height))
--            blend_sel = (tsy * (world:getTileset().image_height / world:getTileset().height)) + tsx + 1
--          end
          
--          if y >= 398 and y < 398 + 96 then
--             tsx = tonumber(math.floor((x - 515) / world:getTileset().width))
--            tsy = tonumber(math.floor((y - 398) / world:getTileset().height))
--            tile2_sel = (tsy * (world:getTileset().image_height / world:getTileset().height)) + tsx + 1
--          end
          
--          return
--        end
        
--        if button == 2 then
          
--          if y >= 76 and y <= 76 + 118 then
--            tile_sel = 1
--          end
          
--          if y >= 165 and y <= 165 + 118 then
--            blend_sel = 0
--          end
          
--          if y >= 320 and y <= 320 + 118 then
--            tile2_sel = 1
--          end
--        end 
          
--      end 
--      ,function (key, scancode)
        
--      end
    
--    )

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
          
          prvProvinceX.text = tostring(pts[sel_voronoi].x)
          love.graphics.print("X", 380, 365)
          suit.Input(prvProvinceX, 390, 365, 90, 15)
          pts[sel_voronoi].x = tonumber(prvProvinceX.text)
          prvProvinceY.text = tostring(pts[sel_voronoi].y)
          love.graphics.print("Y", 480, 365)
          suit.Input(prvProvinceY, 490, 365, 90, 15)
          pts[sel_voronoi].y = tonumber(prvProvinceY.text)
          
          suit.layout:reset(520, 385, 0, 0)
          
          if suit.Button("Del", suit.layout:row(35,15)).hit then
            world:delProvince(sel_voronoi)
            if sel_voronoi > #world:getProvincePoints() then
              sel_voronoi = #world:getProvincePoints()
            end
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
          prvZoom = prvZoom + 0.5
          return
        elseif x > 60 and x < 76 and y > 50 + 174 and y < 66 + 174 then
          prvZoom = prvZoom - 0.5
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