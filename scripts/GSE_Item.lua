-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Items" <GSE_Item>
---@version v1.0.1
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds a library for manipulating items and adds more methods to Figura's ItemStacks.

local ID = "GSE_Item"
local VER = "1.0.1"
local FIG = {"0.1.1", "0.1.4"}


---Adds an itemstacks library for manipulating item stacks and adds methods to Figura's ItemStacks.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---### *Does not require GSECommon!*
---
---**<u>Contributes:</u>**
---* `itemstacks`
---  * `.stack()`
---  * `.enchant()
---* `<ItemStack>`
---  * `:hasItemTag()`
---  * `:isEmpty()`
---  * `:getPredicateValue()`
---* `_ENV`
---  * `ITEM_AIR`
---@class Lib.GS.Extensions.Item
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}


local math = math
local m_huge = math.huge
local m_pi = math.pi
local m_atan2 = math.atan2
local m_clamp = math.clamp
local m_cos = math.cos
local m_deg = math.deg

local table = table
local t_insert = table.insert
local t_remove = table.remove

local world = world
local w_newItem = world.newItem
local w_getDimension = world.getDimension
local w_getSpawnPoint = world.getSpawnPoint


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---An Air item.
ITEM_AIR = w_newItem("minecraft:air")


---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---An extension library that offers some item stack functions.
---@class Lib.GS.Extensions.Item.Lib
itemstacks = {}
local itemstacks = itemstacks

---Attempt to stack two item stacks together. If the resulting stack would overflow, a second item stack is returned as
---the remainder.
---
---If a single item stack is given, it will be split if it is overflowing.
---@param item1 ItemStack
---@param item2? ItemStack
---@return ItemStack stacked
---@return ItemStack? remainder
function itemstacks.stack(item1, item2)
  local stackstr = item1:toStackString()

  if not item2 then -- Unstack
    local count, maxcount = item1:getCount(), item1:getMaxCount()
    if count <= maxcount then return item1:copy() end

    return w_newItem(stackstr, maxcount), w_newItem(stackstr, count - maxcount)
  end

  if stackstr ~= item2:toStackString() then return item1:copy(), item2:copy() end

  local count, maxcount = item1:getCount() + item2:getCount(), item1:getMaxCount()
  if count <= maxcount then return w_newItem(stackstr, count) end

  return w_newItem(stackstr, maxcount), w_newItem(stackstr, count - maxcount)
end

---Returns a copy of an item with the enchantment glint applied or removed.
---
---Does not do anything to items that always have the glint.
---@param item ItemStack
---@param state? boolean
---@return ItemStack
function itemstacks.enchant(item, state)
  local stackstr = item:toStackString()

  if state then
    if stackstr:match("{}$") then
      return w_newItem(stackstr:gsub("}$", "Enchantments:[{}]}"), item:getCount())
    elseif stackstr:match("}$") then
      return w_newItem(stackstr:gsub("}$", ",Enchantments:[{}]}"), item:getCount())
    else
      return w_newItem(stackstr .. "{Enchantments:[{}]}", item:getCount())
    end
  else
    return w_newItem(
      stackstr
        :gsub(",Enchantments:%[{[^%]]-}%],", ",")
        :gsub(",?Enchantments:%[{.-}%],?", "")
        :gsub("{}$", ""),
      item:getCount()
    )
  end
end


---==================================================================================================================---
---====  METATABLES  ================================================================================================---
---==================================================================================================================---

local ItemStack_index = figuraMetatables.ItemStack.__index

---@class ItemStack
local ItemStackMethods = {}

---### [GS Extensions]
---Checks if this item has the given item tag.
---@param tag string
---@return boolean
function ItemStackMethods:hasItemTag(tag)
  local tags = self:getTags()

  for _, t in ipairs(tags) do
    if tag == t then return true end
  end
  return false
end

---### [GS Extensions]
---Checks if this item stack is empty.
---@return boolean
function ItemStackMethods:isEmpty()
  return self.id == "minecraft:air"
end

local vec_half = vec(0.5, 0, 0.5)
local vecmul = vec(1, 0, 1)
local degfloat = 1 / 360
local day_divisor = 1 / 24000

---@alias Lib.GS.Extensions.Item.predicate string
---| "angle"             # Gets the angle of a compass.
---| "blocking"          # Gets if an item could be blocking.
---| "broken"            # Gets if an elytra is broken.
---| "cast"              # Gets if a fishing rod could be cast.
---| "cooldown"          # Only returns 0, it is not possible to get the cooldown of an item.
---| "damage"            # Gets the damage of an item as a percentage.
---| "damaged"           # Gets if an item has been damaged. Unbreakable items are never damaged.
---| "lefthanded"        # Gets if an entity is left handed.
---| "pull"              # Gets the amount a bow or crossbow has been pulled as a percentage.
---| "pulling"           # Gets if a bow or crossbow is being pulled.
---| "charged"           # Gets if a crossbow is loaded.
---| "firework"          # Gets if a crossbow is loaded with a firework.
---| "throwing"          # Gets if a trident is ready to be thrown.
---| "time"              # Gets the time of a clock.
---| "custom_model_data" # Gets the `CustomModelData` tag of an item.
---| "level"             # Gets the light level of a light block.
---| "tooting"           # Gets if a goat horn is being used.
---| "trim_type"         # Gets the type of trim of an armor item.
---| "brushing"          # Gets the animation progress of a brushing brush.

local trims = {
  ["minecraft:quartz"] = 0.1,
  ["minecraft:iron"] = 0.2,
  ["minecraft:netherite"] = 0.3,
  ["minecraft:redstone"] = 0.4,
  ["minecraft:copper"] = 0.5,
  ["minecraft:gold"] = 0.6,
  ["minecraft:emerald"] = 0.7,
  ["minecraft:diamond"] = 0.8,
  ["minecraft:lapis"] = 0.9,
  ["minecraft:amethyst"] = 1,
}

---@type {[string]: fun(item: ItemStack, ent: LivingEntity): number}
local predicates = {
  angle = function(item, ent)
    if not ent then return 0 end
    local data, dir
    if item.id == "minecraft:compass" then
      data = item.tag
      if data.LodestonePos then
        if w_getDimension() ~= data.LodestoneDimension then return 0 end
        data = data.LodestonePos
        dir = vec(data.X, 0, data.Z):add(vec_half):sub(ent:getPos():mul(vecmul)):normalize()
      else
        dir = w_getSpawnPoint():add(vec_half):mul(vecmul):sub(ent:getPos():mul(vecmul)):normalize()
      end
    elseif item.id == "minecraft:recovery_compass" then
      data = ent:getNbt().LastDeathLocation
      if not data or w_getDimension() ~= data.dimension then return 0 end
      data = data.pos
      dir = vec(data[1], 0, data[3]):add(vec_half):sub(ent:getPos():mul(vecmul)):normalize()
    else
      return 0
    end

    return (m_deg(m_atan2(-dir.x, dir.z)) - ent:getRot().y) % 360 * degfloat
  end,
  blocking = function(item, ent)
    return (item:getUseAction() == "BLOCK" and ent and ent:isBlocking()) and 1 or 0
  end,
  broken = function(item)
    return (item.id == "minecraft:elytra" and (item:getMaxDamage() - item:getDamage()) <= 1) and 1 or 0
  end,
  cast = function(item, ent)
    ---@cast ent Player
    return (item.id == "minecraft:fishing_rod" and ent and ent.isFishing and ent:isFishing()) and 1 or 0
  end,
  cooldown = function(item, ent)
    ---@cast ent Player
    return ent.getCooldownPercent and ent:getCooldownPercent(item) or 0
  end,
  damage = function(item) return m_clamp(item:getDamage() / item:getMaxDamage(), 0, 1) end,
  damaged = function(item)
    if item:getMaxDamage() <= 0 or item.tag.Unbreakable then return 0 end
    return item:getDamage() > 0 and 1 or 0
  end,
  lefthanded = function(_, ent) return ent and ent:isLeftHanded() and 1 or 0 end,
  pull = function(item, ent)
    local action = item:getUseAction()
    if not ent or ent:getActiveItem():getUseAction() ~= action then return 0 end

    if action == "BOW" then
      return m_clamp(ent:getActiveItemTime() * 0.05, 0, 1)
    elseif action == "CROSSBOW" then
      if item.tag.Charged == 1 then return 0 end
      return m_clamp(ent:getActiveItemTime() / (item:getUseDuration() - 3), 0, 1)
    end

    return 0
  end,
  pulling = function(item, ent)
    local action = item:getUseAction()
    if not ent or ent:getActiveItem():getUseAction() ~= action then return 0 end

    return (action == "BOW" or (action == "CROSSBOW" and item.tag.Charged ~= 1)) and 1 or 0
  end,
  charged = function(item)
    return (item:getUseAction() == "CROSSBOW" and item.tag.Charged == 1) and 1 or 0
  end,
  firework = function(item)
    if item:getUseAction() ~= "CROSSBOW" then return 0 end
    local loaded = item.tag.ChargedProjectiles
    loaded = loaded and loaded[1]
    return (loaded and loaded.id == "minecraft:firework_rocket") and 1 or 0
  end,
  throwing = function(item, ent)
    local action = item:getUseAction()
    if not ent or ent:getActiveItem():getUseAction() ~= action then return 0 end

    return (action == "SPEAR") and 1 or 0
  end,
  time = function(item)
    if item.id ~= "minecraft:clock" or w_getDimension() ~= "minecraft:overworld" then return 0 end
    local frac = (world.getTimeOfDay() * day_divisor - 0.25) % 1
    return (m_deg((frac * 2 + (0.5 - m_cos(frac * m_pi) * 0.5)) / 3) % 360) * degfloat
  end,
  custom_model_data = function(item) return tonumber(item.tag.CustomModelData) or 0 end,
  level = function(item)
    if item.id ~= "minecraft:light" then return 0 end
    local level = item.tag.BlockStateTag
    level = level and level.level
    return level and (level / 16) or 1
  end,
  filled = function(item)
    if item.id ~= "minecraft:bundle" then return 0 end
    local items = item.tag.Items
    if not items or #items == 0 then return 0 end

    local weight = 0
    local deferred_bundles = {}
    for _, itm in ipairs(items) do
      if itm.id == "minecraft:bundle" then
        t_insert(deferred_bundles, itm)
      elseif (itm.id == "minecraft:bee_nest" or itm.id == "minecraft:beehive") then
        local tag = itm.tag
        tag = tag and tag.BlockEntityData
        tag = tag and tag.Bees
        if not tag or #tag == 0 then
          weight = weight + (64 / world.newItem(itm.id):getMaxCount() * itm.Count)
        else
          return 1
        end
      else
        weight = weight + (64 / world.newItem(itm.id):getMaxCount() * itm.Count)
      end

      if weight >= 64 then return 1 end
    end


    local bundle, contents
    while deferred_bundles[1] do
      bundle = deferred_bundles[1]
      weight = weight + 4
      contents = bundle.tag
      contents = contents and contents.Items
      if contents and #contents ~= 0 then
        for _, itm in ipairs(contents) do
          if itm.id == "minecraft:bundle" then
            t_insert(deferred_bundles, itm)
          elseif (itm.id == "minecraft:bee_nest" or itm.id == "minecraft:beehive") then
            local tag = itm.tag
            tag = tag and tag.BlockEntityData
            tag = tag and tag.Bees
            if not tag or #tag == 0 then
              weight = weight + (64 / world.newItem(itm.id) * itm.Count)
            else
              return 1
            end
          else
            weight = weight + (64 / world.newItem(itm.id) * itm.Count)
          end

          if weight >= 64 then return 1 end
        end
      end

      t_remove(deferred_bundles, 1)
    end

    return m_clamp(weight / 64, 0, 1)
  end,
  tooting = function(item, ent)
    local action = item:getUseAction()
    if not ent or ent:getActiveItem():getUseAction() ~= action then return 0 end

    return (action == "TOOT_HORN") and 1 or 0
  end,
  trim_type = function(item)
    if not item:isArmor() then return -m_huge end
    local trim = item.tag.Trim
    return trim and trims[trim.material] or 0
  end,
  brushing = function(item, ent)
    local action = item:getUseAction()
    if not ent or ent:getActiveItem():getUseAction() ~= action then return 0 end

    return (action == "BRUSH") and (-ent:getActiveItemTime() % 10) * 0.1 or 0
  end
}
---### [GS Extensions]
---Returns the result of a predicate on an item.  
---Some predicates require an entity for more context.
---
---*Due to limitations imposed by Figura, some predicates may not be entirely accurate.*  
---Always confirm that the item you are checking the predicate of is able to get the returned value.  
---(I.e. A fishing rod that isn't in the player's hand cannot be cast.)
---@param predicate Lib.GS.Extensions.Item.predicate
---@param ent? LivingEntity
function ItemStackMethods:getPredicateValue(predicate, ent)
  local func = predicates[predicate]
  return func and func(self, ent) or 0
end

function figuraMetatables.ItemStack:__index(key)
  return ItemStackMethods[key] or ItemStack_index(self, key)
end


return setmetatable(this, thismt)
