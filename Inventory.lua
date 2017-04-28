--[[

  Inventory component class
  
  By Phil Garner
  April 2017
  
  Serves as the list of Items (see Item component class Item.lua) that an
  object (units/settlements, etc) contains.
  
  Each item in the slot (object in array) has a type, quantity, price (or 'cost')
  and base_price (the item's ideal condition base price, used for tuning the economy).
  
  Adding an item object to the list will trigger a consolidation operation where the two
  item objects are added together (adding their quantities and averaging their prices ['cost']).
  
  This way if the player sells their cheaper cost grain (IE: the price property is lower on their
  Grain object), the average cost of grain in that market would decrease.
  
  The maximum tonnage will be checked every time an item object is added and if it would
  exceed the maxiumum then the add operation will fail (calling function should anticipate
  this and if it fails then split the difference on the Item object and add that to the
  inventory instead).
  
  If the item is depleted for the inventory object, it will not be removed from the list
  but rather the quantity will be set to 0 and the price will be set to the base_price.
  
  Usage:
  
  -- Create new inventory.
  local new_inv = Inventory:new("Schooner Cargo", 150, 75) -- Name, max mass, max volume.
  
  -- Get inventory contents
  for v in ipairs(new_inv:getAll()) do
    print(v.name, v.quantity, v.price)
  end
  
]]--

local Inventory = {}
Inventory.__index = Inventory

function Inventory:new(name, max_mass, max_volume)

  local inv = {}
  setmetatable(inv, Inventory)

  inv.items = {}
  inv.max_mass = max_mass
  inv.max_volume = max_volume
  inv.name = name

  return inv

end

function Inventory:getAll()
  
  return self.items
  
end

function Inventory:mass()
  local v = 0
  for i=1, #self.items do
    v = v + self.items[i]:mass()
  end
  return v
end

function Inventory:volume()
  local v = 0
  for i=1, #self.items do
    v = v + self.items[i]:volume()
  end
  return v
end

function Inventory:get(index)
  
  if self.items[index] ~= nil then
    return self.items[index]
  else
    return false
  end
  
end

function Inventory:add(item)
  
  table.insert(self.items, item)

end

function Inventory:remove(index)
  
  if self.items[index] == nil then
    return false
  else
    table.remove(self.items, index)
    return true
  end
  
end

return Inventory