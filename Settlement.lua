--[[

  Settlement class
  
  By Phil Garner
  April 2017
  
  Populations belong to settlements, which are attached
  to their nations.  Manpower is determined by counting the
  populations in settlements (labour pool, roughly approximated).
  
  Units can belong to settlements (garrison or docked).
  
  Settlements start off as outposts and can be upgraded along a
  hierarchy of subtypes:
  
  Hinterland Activites ( < 500 population)
  ==============================================
  Outpost -> Grain Farm
  Outpost -> Animal Farm
  Outpost -> Cotton Plantation
  Outpost -> Sugar Plantation
  Outpost -> Tea Plantation
  Outpost -> Coffee Plantation
  Outpost -> Spice Plantation
  Outpost -> Metals Mine
  Outpost -> Coal Mine
  Outpost -> Gem Mine
  
  Towns ( >= 500 population)
  ==================================
  Outpost -> Town
  Town -> City
  Town -> Port Town
  City -> Port City
  
  Fortifications
  ====================
  Outpost -> Pallisade
  Pallisade -> Log Fort
  Log Fort -> Bastion
  
  Usage:
  
  -- Create new nation.
  local new_item = Settlement:new("United Kingdom")
  
]]--

local Settlement = {}
Settlement.__index = Settlement

function Settlement:new(name)
  
  local itm = {}
  setmetatable(itm, Settlement)
  itm.name = name
  
  return itm
  
end

function Settlement:set(prop, val)
  
  if self[prop] == nil then
    return false
  end
  
  self[prop] = val
  
  return true
  
end

function Settlement:get(prop)
    
  if self[prop] == nil then
    return false
  end
  
  return self[prop]
  
end

return `Settlement