--[[

  Item component class
  
  By Phil Garner
  April 2017
  
  Stores price and quantity of an item type, when more
  of the same type of item are added to the stack it
  averages the price so that the player has an accurate
  estimate of their costs for the items and can make
  educated decisions when buying/selling.
  
  Usage:
  
  -- Create new item.
  local new_item = Item:new("Grain", 10)
  
  -- Clone copy of the item object.
  local new_item_copy = new_item:clone()
  
  -- 'Safe' getting/setting.
  local qty = Item:get("quantity")
  qty = qty + 10
  Item:set("quantity", qty)
  
  -- 'Split' the object (creates a new
  -- clone with the specified quantity and
  -- subtracts that amount from the parent
  -- object.
  local new_item_split = new_item:split(5) -- Now each object's quantity is 5.
  
  -- Calculate the object's volume and mass based on the
  -- quantity and the values in the object lookup table.
  
  local mass = new_item:mass()
  local vol = new_item:volume()
  
]]--

local Item = {}
Item.__index = Item

local item_defs = require "data/item_defs"

function Item:new(name, quantity)
  if item_defs[name] == nil then
    return false
  end
  
  local itm = {}
  setmetatable(itm, Item)
  itm.quantity = quantity
  itm.base_price = item_defs[name].price
  itm.price = itm.base_price
  itm.name = name
  itm.quantity = quantity
  itm.item_mass = item_defs[name].mass
  itm.item_volume = item_defs[name].volume
  
  return itm
  
end

function Item:set(prop, val)
  
  if self[prop] == nil then
    return false
  end
  
  self[prop] = val
  
  return true
  
end

function Item:get(prop)
    
  if self[prop] == nil then
    return false
  end
  
  return self[prop]
  
end

function Item:clone()
  
  local itm = {}
  setmetatable(itm, Item)
  
  itm.quantity = self.quantity
  itm.base_price = self.base_price
  itm.price = self.price
  itm.name = self.name
  itm.quantity = self.quantity
  itm.item_mass = self.item_mass
  itm.item_volume = self.item_volume
  
  return itm
  
end

function Item:mass()
  return self.quantity * self.item_mass
end

function Item:volume()
  return self.quantity * self.item_volume
end

function Item:add(quantity, price)
  
  local iprice = self.price
  local iqty = self.quantity
  
  iprice = iprice + price
  iqty = iqty + quantity
  
  iprice = iprice / 2
  
end

function Item:split(quantity)
  
  if self.quantity - quantity <= 0 then
    return false
  end
  self.quantity = self.quantity - quantity

  return self:new(self.name, quantity)
  
end

return Item