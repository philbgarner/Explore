local world = {
    scrollx = 1
    ,scrolly = 1
    ,data = {}
  }

  
local shaders = {
    mix = love.graphics.newShader([[
      extern float threshold;
      extern Image tile2;
      extern Image blendTile;
      
      vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 tx;
        if (threshold < Texel(blendTile, texture_coords).a)
        {
          tx = Texel(texture, texture_coords);
        }
        else
        {
          tx = Texel(tile2, texture_coords);
        }
        
        if (tx.r == 1.0 && tx.g == 0.0 && tx.b == 1.0)
        {
          return vec4(0.0, 0.0, 0.0, 0.0);
        }
        
        return tx;
        
      }
      
    ]])
  }

function world:tileset(name, blends, width, height)
  
  local img = love.graphics.newImage(name)
  local imgh = img:getHeight()
  local imgw = img:getWidth()
  local imgBlends = love.graphics.newImage(blends)

  local ts = {}
  local cx = 0
  local cy = 0
  while cy < imgh do
    
    table.insert(ts, love.graphics.newQuad(cx, cy, width, height, imgw, imgh))

    cx = cx + width
    if cx > imgw then
      cx = 0
      cy = cy + height
    end
    
  end

  world.data.tileset = {
          name = name
          ,width = width
          ,height = height
          ,image_width = img:getWidth()
          ,image_height = img:getHeight()
          ,image = img
          ,blend_image = imgBlends
          ,tiles = ts
      }
      
  tile2 = love.graphics.newCanvas(world.data.tileset.width, world.data.tileset.height)
  blendTile = love.graphics.newCanvas(world.data.tileset.width, world.data.tileset.height)
  tile1 = love.graphics.newCanvas(world.data.tileset.width, world.data.tileset.height)

end

function world:getTileset()
  
  return world.data.tileset
  
end 

function world:map(width, height)
  world.data.map_height = height
  world.data.map_width = width
  
  local layerdata = {}
  
  for l=1, 3 do
    local mapdata = {}
    for i=1, height do
      local rowdata = {}
      for j=1, width do
        local coldata = {blend = 0, tile = 1, tile2 = 1}
        table.insert(rowdata, coldata)
      end
      table.insert(mapdata, rowdata)
    end
    table.insert(layerdata, mapdata)
  end
  
  world.data.map = layerdata
  
  world.data.heightmap = love.graphics.newImage("last_heightmap.png")

end

local function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function world:getProvincePoints()
  return world.data.provincePoints
end

function world:addProvince(x, y, avg)
  table.insert(world.data.provincePoints, {
        r = 100
        ,g = 100
        ,b = 100
        ,x = x
        ,y = y
        ,name = "Province"
        ,province_type = 1
        ,avg_height = avg
        ,precipitation = 0.5
      })
end

function world:delProvince(id)
  local newp = {}
  local provs = world:getProvincePoints()
  for i=1, #provs do 
    local p = provs[i]
    if id ~= i then
      table.insert(newp, p)
    end
  end
  
  world.data.provincePoints = newp
end

function world:setPrecipitation(x, y, v)
  x = math.floor(x)
  y = math.floor(y)
  if y >= world.data.map_height or x >= world.data.map_width or x < 0 or y < 0 then return 0 end
  
  world.data.provinces[y][x].precipitation = v
end

function world:saveProvincePoints(filename)
  if filename == nil then
    filename = "province_points.pts"
  end
  love.filesystem.write( filename, bitser.dumps(world.data.provincePoints) )
  
end

function world:loadProvincePoints(filename)
  if filename == nil then
    filename = "province_points.pts"
  end
  world.data.provincePoints = bitser.loads(love.filesystem.read( filename ))
  world:voronoi()
end

function world:setProvinceHeight(id, h)
  local newp = {}
  local provs = world:getProvincePoints()
  for i=1, #provs do 
    local p = provs[i]
    if id == i then
      p.avg_height = h
    end
    table.insert(newp, p)
  end
  
  world.data.provincePoints = newp
end


function world:setProvinceType(id, h)
 
  local newp = {}
  local provs = world:getProvincePoints()
  for i=1, #provs do 
    local p = provs[i]
    if id == i then
      p.province_type = h
    end
    table.insert(newp, p)
  end
  
  world.data.provincePoints = newp
end


function world:voronoi()

  local precipitation_lookup = {
      0.35 -- Grassland
      ,0.1 -- Desert
      ,0.3 -- Highlands
      ,0.6 -- Coastal
      ,0.65 -- Forest
      ,0.1 -- Arctic
    }

  local points = world:getProvincePoints()
  

  local mapdata = {}
  for i=1, world.data.map_height do
    local rowdata = {}
    for j=1, world.data.map_width do
      local coldata = { id = 0 }
      table.insert(rowdata, coldata)
    end
    table.insert(mapdata, rowdata)
  end
  
  for i=1, world.data.map_height do
    for j=1, world.data.map_width do
      local od = world.data.map_width * 2
      local id = 0
      for p=1, #points do
        if points[p] ~= nil then
          local nd = distance(points[p].x, points[p].y, j, i)
          if od > nd then
            od = nd
            id = p
          end
        end
      end
      mapdata[i][j].id = id
      if points[id] ~= nil then
        mapdata[i][j].province_type = points[id].province_type
      else
        mapdata[i][j].province_type = 1
      end
      if points[id] ~= nil then
        mapdata[i][j].precipitation = precipitation_lookup[points[id].province_type]
      else
        mapdata[i][j].precipitation = 1.0
      end
      --console:write("Precip Lookup" .. precipitation_lookup[h] .. ", h=" .. h)
    end
  end
  
  world.data.provinces = mapdata

end

local function plasma(x1, y1, x2, y2, min, max)
  
  local w = (x2 - x1 - 1) / 2
  local h = (y2 - y1 - 1) / 2
  
  local nx = x1 + w
  local ny = y1 + h
  
  -- Diamond Step
  local r = (love.math.random() * max) + min
  local nh = (world:getHeight(x1, y1) + world:getHeight(x2, y1) + world:getHeight(x2, y2) + world:getHeight(x1, y2)) / 4 + r
  world:setHeight(nx, ny, nh)
  
  -- Square Step
  r = (love.math.random() * max) + min
  nh = (world:getHeight(x1, y1) + world:getHeight(x2, y1) + world:getHeight(x2, y2) + world:getHeight(x1, y2)) / 4 + r
  local lx = (x2 - x1 - 1) / 2
  local ly = (y2 - y1 - 1) / 2
  world:setHeight(x1, ly, nh)
  world:setHeight(x2, ly, nh)
  world:setHeight(lx, y1, nh)
  world:setHeight(lx, y2, nh)
end

function world:saveHeightMap(filename)
  if filename == nil then
    filename = "last_heightmap.png"
  end
  world.data.heightmap:getData():encode("png", filename)
  
  return filename .. " saved."
end

function world:heightMap(min, max, med)
  
  if min == nil then min = 0.3 end
  if max == nil then max = 0.7 end
  if med == nil then med = 0.5 end

  height = world.data.map_height + 1
  width = world.data.map_width + 1
  local heightmap = love.graphics.newCanvas(world.data.map_width, world.data.map_height)

  love.graphics.setCanvas(heightmap)
  local coldata = med
  love.graphics.setColor(coldata * 255, coldata * 255, coldata * 255)
  love.graphics.rectangle("fill", 0, 0, width - 1, height - 1)
  love.graphics.setCanvas()
  love.graphics.setColor(255, 255, 255)
  world.data.heightmap = love.graphics.newImage(heightmap:newImageData())
  
  local rv = (love.math.random() * max) + min
  
  world:setHeight(0, 0, rv)
  world:setHeight(width - 1, height - 1, rv)
  world:setHeight(width - 1, 0, rv)
  world:setHeight(0, height - 1, rv)
  
  local w = width - 1
  local x1 = 0
  local y1 = 0
  local x2 = width - 1
  local y2 = height - 1
  
  while w >= 1 do
    --console:write("t" .. y1 .. " b" .. y2 .. " l" .. x1 .. " r" .. x2 .. " w" .. w)
    
    plasma(x1, y1, x2, y2, min, max)
    
    x1 = x2
    x2 = x1 + w
    if x2 > width then
      x1 = 0
      x2 = x1 + w
      y1 = y2
      y2 = y1 + w
    end
    if y2 >= height then
      w = w / 2
      x1 = 0
      x2 = w - 1
      y1 = 0
      y2 = w - 1
    end  
  end

  
  
end

function world:update(dt)
  
end

function world:draw()
  
  local dx = 0
  local dy = 0
  
  local sx = world.scrollx
  local sy = world.scrolly
  local vw = sx + 16
  local vh = sy + 19
  
  if vh > world.data.map_height then vh = world.data.map_height end
  if vw > world.data.map_width then vw = world.data.map_width end
  
  for l=1, 3 do
    for i=sy, vh do
      local rowdata = {}
      for j=sx, vw do
        local t = world.data.map[l][i][j]
        world:drawTile(t.blend, t.tile, t.tile2, dx, dy)
        dx = dx + world.data.tileset.width
      end
      dx = 0
      dy = dy + world.data.tileset.height
    end
  end
  
end

function world:create(name)
  
  world.data = {
        name = name
        ,tileset = nil
        ,provincePoints = {}
        ,water_level = 0.3
    }
  
end

function world:setMap(l, x, y, blend, t1, t2)
  world.data.map[l][y][x].blend = blend
  world.data.map[l][y][x].tile = t1
  world.data.map[l][y][x].tile2 = t2
  
  local pid = world.data.provinces[y][x].id
  local provinceName = ""
  if pid ~= nil and pid > 0 and world.data.provincePoints[pid] ~= nil then
    provinceName = world.data.provincePoints[pid].name
  end
  
  world.data.map[1][y][x].name = provinceName
  world.data.map[1][y][x].province_id = pid
end

function world:setHeight(x, y, v)
  x = math.floor(x)
  y = math.floor(y)
  if y >= world.data.map_height or x >= world.data.map_width or x < 0 or y < 0 or world.data.heightmap == nil then return 0 end
  world.data.heightmap:getData():setPixel(x, y, v * 255, v * 255, v * 255, 255)
  world.data.heightmap:refresh()
end

function world:getHeight(x, y)
  x = math.floor(x)
  y = math.floor(y)
  if y >= world.data.map_height or x >= world.data.map_width or x < 0 or y < 0 then return 0 end
  local r, g, b, a = world.data.heightmap:getData():getPixel(x, y)
  return (r / 255)
end

function world:getPrecipitation(x, y)
  x = math.floor(x)
  y = math.floor(y)
  if y >= world.data.map_height or x >= world.data.map_width or x < 0 or y < 0 then return 0 end
  
  return world.data.provinces[y][x].precipitation
end

function world:drawTile(blendMode, tileid, tile2id, x, y)
  local sd = shaders.mix
  
  if blendMode > 0 and tile2id > 1 then    
    sd:send("threshold", 0.5)

    love.graphics.setCanvas(tile2)
      love.graphics.draw(world.data.tileset.image, world.data.tileset.tiles[tile2id], 0, 0)
    love.graphics.setCanvas()
    sd:send("tile2", tile2)
    love.graphics.setCanvas(blendTile)
      love.graphics.draw(world.data.tileset.blend_image,  world.data.tileset.tiles[blendMode], 0, 0)
    love.graphics.setCanvas()
    sd:send("blendTile", blendTile)
    love.graphics.setCanvas(tile1)
      love.graphics.draw(world.data.tileset.image, world.data.tileset.tiles[tileid], 0, 0)
    love.graphics.setCanvas()
    love.graphics.setShader(sd)
      love.graphics.draw(tile1, x, y)
    love.graphics.setShader()
  else
    love.graphics.draw(world.data.tileset.image, world.data.tileset.tiles[tileid], x, y)
  end
end

function tileCandidates(biome_id, altitude, latitude, precipitation)
  
  local cnd = {}
  
  local mountain_h = 0.35
  
  if altitude <= 0 then
    table.insert(cnd, 2) -- Sea
  else
    
    if (biome_id == 1 or biome_id == 3) and (altitude >= 0 and altitude <= mountain_h) and (latitude <= 40 and latitude >= -40) and (precipitation > 0.25 and precipitation <= 0.6) then
      table.insert(cnd, 3) -- Grassland
    end
    
    if (biome_id == 1 or biome_id == 2 or biome_id == 3 or biome_id == 4 or biome_id == 5 or biome_id == 6)
      and (altitude >= mountain_h and altitude <= 1) and (latitude <= 90 and latitude >= -90) and (precipitation >= 0 and precipitation <= 1)
    then
      table.insert(cnd, 5) -- Mountains
    end
    
    if (biome_id == 2 or biome_id == 4)
      and (altitude >= 0 and altitude <= 1) and (latitude <= 20 and latitude >= -20) and (precipitation >= 0 and precipitation <= 0.25)
    then
      table.insert(cnd, 4) -- Desert
    end
    
    if (biome_id == 1 or biome_id == 4 or biome_id == 5)
      and (altitude >= 0 and altitude <= mountain_h) and (latitude <= 55 and latitude >= -55) and (precipitation > 0.25 and precipitation <= 0.8)
    then
      table.insert(cnd, 6) -- Forest
    end

    if (biome_id == 6)
      and (altitude >= 0 and altitude <= 1) and (latitude <= 90 and latitude >= -90) and (precipitation > 0.0 and precipitation <= 1.0)
    then
      table.insert(cnd, 7) -- Tundra
    end
    
     if (biome_id == 6)
      and (altitude >= 0 and altitude <= 0.85) and (latitude <= 80 and latitude >= -80) and (precipitation > 0.15 and precipitation <= 0.5)
    then
      table.insert(cnd, 8) -- Taiga
    end
    
  end
  
  if #cnd == 0 then
    table.insert(cnd, 1) -- Empty Tile.
  end
  
  return cnd
  
end

function world:generateMap()
  
  for k=1, world.data.map_height do
    for i=1, world.data.map_width do
        local ph = world:getHeight(i, k) - world.data.water_level
        local pr = world:getPrecipitation(i, k)
        local ptype = world.data.provinces[k][i].province_type
        local name = world.data.provinces[k][i].name
        local tc = tileCandidates(ptype, ph, 0, pr)
        local tcid = math.floor((math.random() * #tc) + 1)
        world:setMap(1, i, k, 0, tc[tcid], 0)
    end
  end
  
  local canv = love.graphics.newCanvas(world.data.map_width, world.data.map_height)
  
  local tiles1x1 = love.graphics.newImage("images/tileset1x1.png")
  
  love.graphics.setCanvas(canv)

    for k=1, world.data.map_height do
      for i=1, world.data.map_width do
        local tid = world.data.map[1][k][i].tile
        
        local r, g, b, a = tiles1x1:getData():getPixel(tid - 1, 0)
        love.graphics.setColor(r, g, b, 255)
        love.graphics.points(i, k)
        love.graphics.setColor(255, 255, 255)
      end
    end
    
  love.graphics.setCanvas()
  map_image = love.graphics.newImage(canv:newImageData())
  
end

return world