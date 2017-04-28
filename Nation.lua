--[[

  Nation class
  
  By Phil Garner
  April 2017
  
  Nations can own provinces and game objects like settlements
  or units.  Populations belong to settlements, which are attached
  to their nations. Population points (manpower) can be spent to create
  units which are attached to nations.
  
  Usage:
  
  -- Create new nation.
  local new_item = Nation:new("United Kingdom")
  
]]--

local Nation = {}
Nation.__index = Nation

function Nation:new(name)
  
  local itm = {}
  setmetatable(itm, Nation)
  itm.name = name
  itm.manpower = 0
  
  return itm
  
end

function Nation:set(prop, val)
  
  if self[prop] == nil then
    return false
  end
  
  self[prop] = val
  
  return true
  
end

function Nation:get(prop)
    
  if self[prop] == nil then
    return false
  end
  
  return self[prop]
  
end

function Nation:getAllSettlements()
  
end

function Nation:getAllUnits()
  
end

function Nation:addUnit()
  
end

function Nation:addSettlement()
  
end

function Nation:removeUnit()
  
end

function Nation:removeSettlement()
  
end

return Nation