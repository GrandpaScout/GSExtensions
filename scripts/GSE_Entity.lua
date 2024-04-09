-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Entities" <GSE_Entity>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds a new library for getting entities and adds more methods to Figura's entities.

local ID = "GSE_Entity"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds an entities library and adds methods to Figura's entities.  
---These methods mostly fill in the gaps in the current methods.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `entities`
---  * `.get()`
---  * `.touching()`
---  * `.at()`
---  * `.inAABB()`
---* `<Entity>`
---  * `:getForward()`
---  * `:getRight()`
---  * `:getUp()`
---  * `:getLocalMatrix()`
---  * `:getLocalVelocity()`
---  * `:getLocalHVelocity()`
---  * `:getIntersectingBlocks()`
---  * `:getGroundBlocks()`
---* `<LivingEntity>`
---  * `:getBodyForward()`
---  * `:getBodyRight()`
---  * `:getBodyUp()`
---  * `:getBodyMatrix()`
---  * `:getBodyVelocity()`
---  * `:getHandItem()`
---@class Lib.GS.Extensions.Entity
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
local m_abs = math.abs
local m_floor = math.floor
local m_log = math.log
local m_max = math.max

local table = table
local t_insert = table.insert
local t_remove = table.remove

local v_vec3 = vectors.vec3
local _VEC_ZERO = v_vec3()
local _VEC_UP = v_vec3(0, 1)
local _VEC_SOUTH = v_vec3(0, 0, 1)
local _VEC_WEST = v_vec3(-1)

local frameTime = client.getFrameTime


---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---An extension library that offers some entity functions.
---@class Lib.GS.Extensions.Entity.Lib
entities = {}
local entities = entities

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---Get an entity from a UUID.
  ---@param uuid string|{[1]: integer, [2]: integer, [3]: integer, [4]: integer}
  ---@return Entity.any?
  function entities.get(uuid) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

local pattern_hexuuid = "^(%x%x%x%x%x%x%x%x)(%x%x%x%x)(%x%x%x%x)(%x%x%x%x)(%x%x%x%x%x%x%x%x%x%x%x%x)$"
local pattern_hypuuid = "^%x%x?%x?%x?%x?%x?%x?%x?%-%x%x?%x?%x?%-%x%x?%x?%x?%-%x%x?%x?%x?%-%x%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?$"

---Get an entity from a 4-int UUID.
---@param a integer
---@param b integer
---@param c integer
---@param d integer
---@return Entity.any?
function entities.get(a, b, c, d)
  local at = type(a)
  if at == "string" then
    if a:match(pattern_hypuuid) then
      return world.getEntity(a)
    else
      local aa, ab, ac, ad, ae = a:match(pattern_hexuuid)
      if aa then return world.getEntity(("%s-%s-%s-%s-%s"):format(aa, ab, ac, ad, ae)) end
    end
  elseif at == "table" then
    local a1, a2, a3, a4 = a[1], a[2], a[3], a[4]
    if type(a1) == "number" and type(a2) == "number" and type(a3) == "number" and type(a4) == "number" then
      return world.getEntity(client.intUUIDToString(a1, a2, a3, a4))
    end
  elseif at == "number" and type(b) == "number" and type(c) == "number" and type(d) == "number" then
    return world.getEntity(client.intUUIDToString(a, b, c, d))
  end

  error("invalid UUID given", 2)
end

---@type Entity[]
local ent_list

local function collect_entity(ent)
  t_insert(ent_list, ent)
  return false
end

---Gets a list of entities that have bounding boxes touching the given position.
---
---Does nothing in versions before `0.1.3`.
---@param pos Vector3
---@return Entity[]
function entities.touching(pos)
  if not raycast then return {} end

  ent_list = {}
  raycast:entity(pos, pos, collect_entity)

  return ent_list
end

---Gets the entity at the given position.
---
---A value can be given to make the position check less strict.  
---This value is expected to be very tiny (`0.1` or less) and defaults to some tiny number based on the distance from
---the world origin.
---
---Does nothing in versions before `0.1.3`.
---@param pos Vector3
---@param deviation? number
---@return Entity?
function entities.at(pos, deviation)
  if not raycast then return nil end
  if not deviation then
    local max = m_max(pos:copy():applyFunc(m_abs):unpack())
    deviation = (2 ^ -52) * m_floor(m_log(max, 2))
  end

  ent_list = {}
  raycast:entity(pos, pos:copy():add(0, deviation or (2 ^ -52)), collect_entity)

  local deviation_sqr = deviation ^ 2
  local deviation_vec = v_vec3(deviation, deviation, deviation)
  local min = pos - deviation_vec
  local max = pos + deviation_vec

  local best_index = 0
  local best_distance = m_huge

  for i, ent in ipairs(ent_list) do
    local entpos = ent:getPos()

    if min.x <= entpos.x and entpos.x <= max.x
      and min.y <= entpos.y and entpos.y <= max.y
      and min.z <= entpos.z and entpos.z <= max.z
    then
      local dist = (pos - entpos):lengthSquared()
      if dist <= deviation_sqr and dist < best_distance then
        best_index = i
        best_distance = dist
      end
    end
  end

  return ent_list[best_index]
end

---Gets all entities in the given area.
---
---This function is not guaranteed to work in all Minecraft versions as it relies on a implementation detail in
---Minecraft's raycasts.
---
---Does nothing in versions before `0.1.3`.
---@param min Vector3
---@param max Vector3
---@return Entity[]
function entities.inAABB(min, max)
  if not raycast then return {} end

  ent_list = {}
  raycast:entity(min, max, collect_entity)

  return ent_list
end


---==================================================================================================================---
---====  METATABLES  ================================================================================================---
---==================================================================================================================---

---@class Entity
local Entity = figuraMetatables.EntityAPI.__index

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Returns a unit vector pointing forward relative to the direction this entity is looking in.
  ---@return Vector3
  function Entity:getForward() end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

--- LuaLS shenanigans
Entity["" .. "getForward"] = Entity.getLookDir

---### [GS Extensions]
---Returns a unit vector pointing right relative to the direction this entity is looking in.
---@return Vector3
function Entity:getRight()
  return self:getForward():cross(_VEC_UP):normalize()
end

---### [GS Extensions]
---Returns a unit vector pointing up relative to the direction this entity is looking in.
---@return Vector3
function Entity:getUp()
  return self:getForward():scale(-1):cross(self:getForward():cross(_VEC_UP):normalize())
end

local localm4 = matrices.mat4()
local mulvec = vec(-1, 1, -1)

---### [GS Extensions]
---Returns a matrix that converts world vectors to local-space vectors.
---@return Matrix4
function Entity:getLocalMatrix()
  local delta = frameTime()
  local rot = self:getRot(delta)
  return localm4
    :reset()
    :translate(self:getPos(delta):mul(mulvec))
    :rotateY(rot.y)
    :rotateX(-rot.x)
    :scale(mulvec)
    :copy()
end

---### [GS Extensions]
---Gets the entity's local velocity.
---
---More optimized than getting the local matrix and using `:applyDir()`  
---on the velocity as this skips some useless calculations.
---@return Vector3
function Entity:getLocalVelocity()
  local delta = frameTime()
  local rot = self:getRot(delta)
  return localm4
    :reset()
    :rotateY(rot.y)
    :rotateX(-rot.x)
    :scale(mulvec)
    :applyDir(self:getVelocity())
end

---### [GS Extensions]
---Gets the entity's local velocity, ignoring the entity's pitch.
---@return Vector3
function Entity:getLocalHVelocity()
  return localm4
    :reset()
    :rotateY(self:getRot(frameTime()).y)
    :scale(mulvec)
    :applyDir(self:getVelocity())
end

local bboxmul = vec(0.5, 0, 0.5)

---### [GS Extensions]
---Gets all of the blocks this entity intersects with.
---
---If `collision` is set, only check if the entity is intersecting with the collision shape of blocks.
---@param collision? boolean
---@return BlockState[]
function Entity:getIntersectingBlocks(collision)
  local min = self:getPos(frameTime())
  local ebox = self:getBoundingBox()

  min:sub(ebox * bboxmul)
  local max = min + ebox

  local blocks = world.getBlocks(min, max)

  if collision then
    local block, blockpos
    local bbmin, bbmax
    local success
    local localmin, localmax = _VEC_ZERO:copy(), _VEC_ZERO:copy()
    for i = #blocks, 1, -1 do
      block = blocks[i]
      if not block:hasCollision() then
        t_remove(blocks, i)
      elseif not block:isFullCube() then
        success = false
        blockpos = block:getPos()
        localmin:set(min):sub(blockpos)
        localmax:set(max):sub(blockpos)
        for _, bbox in ipairs(block:getCollisionShape()) do
          bbmin, bbmax = bbox[1], bbox[2]

          if localmin.x < bbmax.x and localmax.x > bbmin.x
            and localmin.y < bbmax.y and localmax.y > bbmin.y
            and localmin.z < bbmax.z and localmax.z > bbmin.z
          then
            success = true
            break
          end
        end

        if not success then t_remove(blocks, i) end
      end
    end
  end

  return blocks
end

---### [GS Extensions]
---Gets all of the blocks that make up the ground this entity is standing on.
---TODO: Verify this.
---@return BlockState[]
function Entity:getGroundBlocks()
  local min = self:getPos(frameTime())
  local bbox = self:getBoundingBox()

  min:sub(bbox * bboxmul)

  return world.getBlocks(min, min + bbox)
end


---@class LivingEntity
local LivingEntity = figuraMetatables.LivingEntityAPI.__index

---### [GS Extensions]
---Gets a unit vector pointing forward relative to the body.
---@return Vector3
function LivingEntity:getBodyForward()
  local delta = frameTime()
  return vectors.rotateAroundAxis(-self:getBodyYaw(delta), _VEC_SOUTH, _VEC_UP)
end

---### [GS Extensions]
---Gets a unit vector pointing right relative to the body.
---@return Vector3
function LivingEntity:getBodyRight()
  local delta = frameTime()
  return vectors.rotateAroundAxis(-self:getBodyYaw(delta), _VEC_WEST, _VEC_UP)
end

---### [GS Extensions]
---Gets a unit vector pointing up relative to the body.
---@return Vector3
function LivingEntity:getBodyUp()
  return _VEC_UP:copy()
end

---### [GS Extensions]
---Returns a matrix that converts world vectors to body-space vectors.
---@return Matrix4
function LivingEntity:getBodyMatrix()
  local delta = frameTime()
  return localm4
    :reset()
    :translate(self:getPos(delta):mul(mulvec))
    :rotateY(self:getBodyYaw(delta))
    :scale(mulvec)
    :copy()
end

---### [GS Extensions]
---Gets the local velocity of this entity's body.
---
---More optimized than getting the body matrix and using `:applyDir()`  
---on the velocity as this skips some useless calculations.
---@return Vector3
function LivingEntity:getBodyVelocity()
  local delta = frameTime()
  return localm4
    :reset()
    :rotateY(self:getBodyYaw(delta))
    :scale(mulvec)
    :applyDir(player:getVelocity())
end

---### [GS Extensions]
---Gets the item in the specified hand.
---
---Not to be confused with `:getHeldItem()` which gets the item in the main-hand or off-hand specifically.
---@param hand "LEFT" | "RIGHT"
---@return ItemStack
function LivingEntity:getHandItem(hand)
  if hand == "LEFT" then
    return self:getHeldItem(not self:isLeftHanded())
  elseif hand == "RIGHT" then
    return self:getHeldItem(self:isLeftHanded())
  else
    error("invalid hand '" .. tostring(hand) .. "'", 2)
  end
end


return setmetatable(this, thismt)
