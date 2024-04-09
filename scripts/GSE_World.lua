-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions World" <GSE_World>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds functions to Figura's world api.

local ID = "GSE_World"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds functions to Figura's world api.  
---Most involve getting times and sun angles.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `<World>`
---  * `.newEntity()`
---  * `.getSunAngle()`
---  * `.getSunDir()`
---  * `.getDayTime()`
---  * `.getDay()`
---* `_ENV`
---  * `WORLD_DIM`
---@class Lib.GS.Extensions.World
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}


local world = world
local w_getTimeOfDay = world.getTimeOfDay
local w_getBlockState = world.getBlockState
local w_getBlocks = world.getBlocks

local vectors = vectors
local v_rotateAroundAxis = vectors.rotateAroundAxis

local v_vec3 = vectors.vec3
local _VEC_UP = v_vec3(0, 1)
local _VEC_SOUTH = v_vec3(0, 0, 1)

local math = math
local m_pi = math.pi
local m_deg = math.deg
local m_cos = math.cos
local m_floor = math.floor

local t_unpack = table.unpack


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---The name of the dimension this world is in.
WORLD_DIM = world.getDimension()


---==================================================================================================================---
---====  METATABLES  ================================================================================================---
---==================================================================================================================---

local day_divisor = 1 / 24000

--- (1/3) * 6.2831855  
--- Taken straight from Minecraft's source.
local sun_magic = 6.2831855 / 3

local ent_task = models:newEntity("GSE_Entity"):remove()

---@class WorldAPI
local World = figuraMetatables.WorldAPI.__index

---### [GS Extensions]
---Creates a new entity from the given values.
---@param id Minecraft.entityID
---@param nbt? string
---@return Entity
function World.newEntity(id, nbt)
  return ent_task:setNbt(id, nbt or "{}"):asEntity()
end

---### [GS Extensions]
---Gets the angle of the sun.  
---0° is straight up, the angle increases as time goes forward.
---@param delta? number
---@return number
function World.getSunAngle(delta)
  local frac = (w_getTimeOfDay(delta) * day_divisor - 0.25) % 1
  return m_deg((frac * 2 + (0.5 - m_cos(frac * m_pi) * 0.5)) * sun_magic) % 360
end

---### [GS Extensions]
---Returns a vector that points toward the sun.
---@param delta? number
---@return Vector3
function World.getSunDir(delta)
  local frac = (w_getTimeOfDay(delta) * day_divisor - 0.25) % 1
  return v_rotateAroundAxis(
    m_deg((frac * 2 + (0.5 - m_cos(frac * m_pi) * 0.5)) * sun_magic),
    _VEC_UP,
    _VEC_SOUTH
  )
end

-- ---### [GS Extensions]
-- ---Returns the time of the current day.
-- ---
-- ---This is similar to `.getTimeOfDay()` but loops between [0, 24000) instead of continuing.
-- ---@param delta? number
-- ---@return number
-- function World.getDayTime(delta)
--   return w_getTimeOfDay(delta) % 24000
-- end
-- 
-- ---### [GS Extensions]
-- ---Returns the current game day.
-- ---@param delta? number
-- ---@return integer
-- function World.getDay(delta)
--   return m_floor(w_getTimeOfDay(delta) * day_divisor)
-- end

---@class Lib.GS.Extensions.World.date
---@field year integer
---@field year_day integer
---@field day integer
---@field hour integer
---@field minute integer
---@field second integer
---@field millisecond integer

local year_divisor = 1 / 8760000
function World.getDate(delta)
  local time = w_getTimeOfDay(delta) + 6000
  return {
    year = m_floor(time * year_divisor),
    year_day = m_floor(time * day_divisor) % 365,
    day = m_floor(time * day_divisor),
    hour = m_floor(time * 0.001) % 24,
    minute = m_floor(time * 0.06) % 60,
    second = m_floor(time * 3.6) % 60,
    millisecond = m_floor(time * 3600) % 1000
  }
end

---### [GS Extensions]
---Determines if a world position is not inside block collision and is inside the playable world bounds.
---
---If `ignore_void` is set, the void and areas outside the current view are considered in-bounds.
---@param pos Vector3
---@param ignore_void? boolean
---@return boolean
function World.inBounds(pos, ignore_void)
  if pos.x > 32000000 or pos.z > 32000000 or pos.x < -32000000 or pos.z < -32000000 then return false end
  local block = w_getBlockState(pos)
  if block.id == "minecraft:void_air" then return ignore_void and true or false end

  if block:hasCollision() then
    if block:isFullCube() then return false end

    local posx, posy, posz = pos:copy():sub(block:getPos()):unpack()
    ---@type Vector3, Vector3
    local bbox1, bbox2
    for _, bbox in ipairs(block:getCollisionShape()) do
      bbox1, bbox2 = t_unpack(bbox)
      if (bbox1.x < posx and posx < bbox2.x)
        and (bbox1.y < posy and posy < bbox2.y)
        and (bbox1.z < posz and posz < bbox2.z)
      then return false end
    end
  end

  return true
end

---@alias Lib.GS.Extensions.World.findPredicate string | {[string]: boolean} | fun(block: BlockState): boolean?

---### [GS Extensions]
---Finds a single block in an area matching the given predicate.
---
---The `predicate` determines which block should be found.
---* If it is a string, it will be used as a Lua Pattern to match the id of a block. Succeeds if a match is found.
---* If it is a table, it will be indexed with the id of a block. Succeeds if a value of `true` is found.
---* If it is a function, it is called with the argument being a block. Succeeds if `true` is returned.
---@param area_min Vector3
---@param area_max Vector3
---@param predicate Lib.GS.Extensions.World.findPredicate
---@return BlockState?
function World.findBlock(area_min, area_max, predicate)
  ---@type BlockState[]
  local blocks = w_getBlocks(area_min, area_max)

  if type(predicate) == "string" then
    for _, block in ipairs(blocks) do
      if block.id:match(predicate) then return block end
    end
  elseif type(predicate) == "table" then
    for _, block in ipairs(blocks) do
      if predicate[block.id] then return block end
    end
  else
    for _, block in ipairs(blocks) do
      if predicate(block) then return block end
    end
  end

  return nil
end

---### [GS Extensions]
---Finds every block in an area matching the given predicate.
---
---The `predicate` determines which block should be found.
---* If it is a string, it will be used as a Lua Pattern to match the id of a block. Succeeds if a match is found.
---* If it is a table, it will be indexed with the id of a block. Succeeds if a value of `true` is found.
---* If it is a function, it is called with the argument being a block. Succeeds if `true` is returned.
---@param area_min Vector3
---@param area_max Vector3
---@param predicate Lib.GS.Extensions.World.findPredicate
---@return BlockState[]
function World.findBlocks(area_min, area_max, predicate)
  ---@type BlockState[]
  local blocks = w_getBlocks(area_min, area_max)

  local ret = {}
  if type(predicate) == "string" then
    for _, block in ipairs(blocks) do
      if block.id:match(predicate) then ret[#ret+1] = block end
    end
  elseif type(predicate) == "table" then
    for _, block in ipairs(blocks) do
      if predicate[block.id] then ret[#ret+1] = block end
    end
  else
    for _, block in ipairs(blocks) do
      if predicate(block) then ret[#ret+1] = block end
    end
  end

  return ret
end


return setmetatable(this, thismt)
