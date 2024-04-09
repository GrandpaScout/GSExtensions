-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Vectors" <GSE_Vector>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds functions to Figura's vectors library and methods to Figura's Vectors.

local ID = "GSE_Vector"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds functions to Figura's vectors library and methods to Figura's Vectors.  
---The functions added to the library manipulate vectors or create random ones.  
---The methods added to the Vectors add some minor manipulation or cloning methods.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `vectors`
---  * `.intersectRayAABB()`
---  * `.intersectRayPlane()`
---  * `.order()`
---  * `.inAABB()`
---  * `.random2()`
---  * `.random3()`
---  * `.random4()`
---* `<Vector2>`
---  * `:negate()`
---  * `:mod()`
---  * `:normalizeAngle()`
---  * `:normalizedAngle()`
---  * `:randomize()`
---* `<Vector3>`
---  * `:negate()`
---  * `:mod()`
---  * `:normalizeAngle()`
---  * `:normalizedAngle()`
---  * `:randomize()`
---* `<Vector4>`
---  * `:negate()`
---  * `:mod()`
---  * `:normalizeAngle()`
---  * `:normalizedAngle()`
---  * `:randomize()`
---* `_ENV`
---  * `vec2()`
---  * `vec3()`
---  * `vec4()`
---  * `VEC`
---    * `.ZERO`
---    * `.ONE`
---    * `.FORWARD`
---    * `.RIGHT`
---    * `.UP`
---    * `.NORTH`
---    * `.SOUTH`
---    * `.WEST`
---    * `.EAST`
---    * `.DOWN`
---@class Lib.GS.Extensions.Vector
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}

local vectors = vectors
local v_vec3 = vectors.vec3
local _VEC_ONE = v_vec3(1, 1, 1)
local _VEC_FWD = v_vec3(0, 0, -1)
local _VEC_RGT = v_vec3(1)
local _VEC_UP = v_vec3(0, 1)

local _EPSILON = 2 ^ (-52)

local math = math
local m_abs = math.abs
local m_max = math.max
local m_min = math.min
local m_random = math.random


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---Contains preset vectors for easy access.
VEC = {
  ---A vector sitting at the origin point. `⟨0, 0, 0⟩`
  ZERO = v_vec3(),
  ---A unit vector pointing forward. `⟨0, 0, -1⟩`
  FORWARD = _VEC_FWD,
  ---A unit vector pointing right. `⟨1, 0, 0⟩`
  RIGHT = _VEC_RGT,
  ---A unit vector pointing up. `⟨0, 1, 0⟩`
  UP = _VEC_UP,
  ---A vector with a one in every axis. `⟨1, 1, 1⟩`
  ONE = _VEC_ONE,

  ---A unit vector pointing north. `⟨0, 0, -1⟩`
  NORTH = _VEC_FWD,
  ---A unit vector pointing south. `⟨0, 0, 1⟩`
  SOUTH = _VEC_FWD:scale(-1),
  ---A unit vector pointing west. `⟨-1, 0, 0⟩`
  WEST = v_vec3(-1),
  ---A unit vector pointing east. `⟨1, 0, 0⟩`
  EAST = _VEC_RGT,
  ---A unit vector pointing down. `⟨0, -1, 0⟩`
  DOWN = _VEC_UP:scale(-1)
}

-- LuaLS shenanigans
---@type table
local _G = _ENV
_G.vec2 = vectors.vec2
_G.vec3 = v_vec3
_G.vec4 = vectors.vec4

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Alias of `vectors.vec2()`.
  ---@param x? number
  ---@param y? number
  ---@return Vector2
  ---@diagnostic disable-next-line: lowercase-global
  function vec2(x, y) end

  ---### [GS Extensions]
  ---Alias of `vectors.vec3()`.
  ---@param x? number
  ---@param y? number
  ---@param z? number
  ---@return Vector3
  ---@diagnostic disable-next-line: lowercase-global
  function v_vec3(x, y, z) end

  ---### [GS Extensions]
  ---Alias of `vectors.vec4()`.
  ---@param x? number
  ---@param y? number
  ---@param z? number
  ---@param w? number
  ---@return Vector4
  ---@diagnostic disable-next-line: lowercase-global
  function vec4(x, y, z, w) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field


---==================================================================================================================---
---====  METATABLES  ================================================================================================---
---==================================================================================================================---

local VectorsAPI = figuraMetatables.VectorsAPI.__index

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Creates a Vector2 with values between 0 and 1.
  ---@return Vector2
  function VectorsAPI.random2() end

  ---### [GS Extensions]
  ---Creates a Vector2 with values between 0 and the given max.
  ---@param max number
  ---@return Vector2
  function VectorsAPI.random2(max) end

  ---### [GS Extensions]
  ---Creates a Vector3 with values between 0 and 1.
  ---@return Vector3
  function VectorsAPI.random3() end

  ---### [GS Extensions]
  ---Creates a Vector3 with values between 0 and the given max.
  ---@param max number
  ---@return Vector3
  function VectorsAPI.random3(max) end

  ---### [GS Extensions]
  ---Creates a Vector4 with values between 0 and 1.
  ---@return Vector4
  function VectorsAPI.random4() end

  ---### [GS Extensions]
  ---Creates a Vector4 with values between 0 and the given max.
  ---@param max number
  ---@return Vector4
  function VectorsAPI.random4(max) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

---### [GS Extensions]
---Checks if a ray starting at `origin` and going in the given direction will hit the axis-aligned box defined by
---`bbmin` and `bbmax`.
---
---Returns the hit position and distance if successful.
---@param origin Vector3
---@param dir Vector3
---@param bbmin Vector3
---@param bbmax Vector3
---@return Vector3? hit_pos
---@return number? distance
---@source https://tavianator.com/2011/ray_box.html
function VectorsAPI.intersectRayAABB(origin, dir, bbmin, bbmax)
  local dir_i = _VEC_ONE / dir
  local tbbmin = (bbmin - origin):mul(dir_i)
  local tbbmax = (bbmax - origin):mul(dir_i)

  local tmin = m_max(
    0,
    m_min(tbbmin.x, tbbmax.x),
    m_min(tbbmin.y, tbbmax.y),
    m_min(tbbmin.z, tbbmax.z)
  )

  local tmax = m_min(
    m_max(tbbmin.x, tbbmax.x),
    m_max(tbbmin.y, tbbmax.y),
    m_max(tbbmin.z, tbbmax.z)
  )

  if tmax >= tmin then
    return (dir * tmin):add(origin), tmin
  end
  return nil
end

---### [GS Extensions]
---Checks if a ray starting at `origin` and going in the given direction will hit the plane defined by the plane
---origin and normal.  
---If `backface` is set, the ray will collide with the back of the plane.
---
---Returns the hit position and distance if successful.
---@param origin Vector3
---@param dir Vector3
---@param plane_origin Vector3
---@param plane_normal Vector3
---@param backface? boolean
---@return Vector3? hit_pos
---@return number? distance
function VectorsAPI.intersectRayPlane(origin, dir, plane_origin, plane_normal, backface)
  local dot = dir:dot(plane_normal)
  if m_abs(dot) > _EPSILON and (backface or dot < 0) then
    local t = (plane_origin - origin):dot(plane_normal) / dot
    if t >= 0 then return (dir * t):add(origin), t end
  end

  return nil
end

---### [GS Extensions]
---Orders two vectors by giving the min values to the first one and the max values to the second one.
---
---This modifies both vectors.
---@param tomin Vector
---@param tomax Vector
function VectorsAPI.order(tomin, tomax)
  local minv, maxv
  for i = 1, m_min(#tomin, #tomax) do
    minv, maxv = tomin[i], tomax[i]
    if minv > maxv then
      tomin[i], tomax[i] = maxv, minv
    end
  end
end

---### [GS Extensions]
---Checks if a point is within the axis-aligned bounds defined by `bbmin` and `bbmax`.
---@param point Vector
---@param bbmin Vector
---@param bbmax Vector
---@return boolean
function VectorsAPI.inAABB(point, bbmin, bbmax)
  for i = 1, m_min(#point, #bbmin, #bbmax) do
    if bbmin[i] < point[i] or point[i] > bbmax[i] then return false end
  end
  return true
end

---### [GS Extensions]
---Creates a Vector2 with values between the given min and max.
---@param min number
---@param max number
---@return Vector2
function VectorsAPI.random2(min, max)
  if not min then
    return vec(m_random(), m_random())
  elseif not max then
    return vec(m_random(), m_random()):scale(min)
  end

  return vec(m_random(), m_random()):scale(max - min):offset(min)
end

---### [GS Extensions]
---Creates a Vector3 with values between the given min and max.
---@param min number
---@param max number
---@return Vector3
function VectorsAPI.random3(min, max)
  if not min then
    return vec(m_random(), m_random(), m_random())
  elseif not max then
    return vec(m_random(), m_random(), m_random()):scale(min)
  end

  return vec(m_random(), m_random(), m_random()):scale(max - min):offset(min)
end

---### [GS Extensions]
---Creates a Vector4 with values between the given min and max.
---@param min number
---@param max number
---@return Vector4
function VectorsAPI.random4(min, max)
  if not min then
    return vec(m_random(), m_random(), m_random(), m_random())
  elseif not max then
    return vec(m_random(), m_random(), m_random(), m_random()):scale(min)
  end

  return vec(m_random(), m_random(), m_random(), m_random()):scale(max - min):offset(min)
end


---@class Vector2
local Vector2Methods = {}
local Vector2_old = figuraMetatables.Vector2.__index

function figuraMetatables.Vector2.__index(self, key)
  return Vector2Methods[key] or Vector2_old(self, key)
end

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Performs modulo on this vector.
  ---@generic self
  ---@param self self
  ---@param vec Vector2
  ---@return self
  function Vector2Methods:mod(vec) end

  ---### [GS Extensions]
  ---Randomizes the values of this vector between 0 and 1.
  ---@generic self
  ---@param self self
  ---@return self
  function Vector2Methods:randomize() end

  ---### [GS Extensions]
  ---Randomizes the values of this vector between 0 and the given max.
  ---@generic self
  ---@param self self
  ---@param max number
  ---@return self
  function Vector2Methods:randomize(max) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

---### [GS Extensions]
---Negates this vector.
---@generic self
---@param self self
---@return self
function Vector2Methods:negate()
  ---@cast self Vector2
  return self:scale(-1)
end

---### [GS Extensions]
---Performs modulo on this vector.
---@generic self
---@param self self
---@param x? number
---@param y? number
---@return self
function Vector2Methods:mod(x, y)
  ---@cast self Vector2
  if type(x) == "Vector2" then return self:set(self.x % x.x, self.y % x.y) end

  if x then self.x = self.x % x end
  if y then self.y = self.y % y end
  return self
end

---### [GS Extensions]
---Wraps all values of this vector between -180 and 180.
---
---If `unsigned` is set, values are wrapped between 0 and 360 instead.
---@generic self
---@param self self
---@param unsigned? boolean
---@return self
function Vector2Methods:normalizeAngle(unsigned)
  ---@cast self Vector2
  if unsigned then
    self:set(self.x % 360, self.y % 360)
  else
    self:offset(180):set(self.x % 360, self.y % 360):offset(-180)
  end
  return self
end

---### [GS Extensions]
---Creates a copy of this vector with all values wrapped between -180 and 180.
---
---If `unsigned` is set, values are wrapped between 0 and 360 instead.
---@param unsigned? boolean
---@return Vector2
function Vector2Methods:normalizedAngle(unsigned)
  if unsigned then return self % 360 end
  return (self + 180):set(self.x % 360, self.y % 360):offset(180)
end

---### [GS Extensions]
---Randomizes the values of this vector between the given min and max.
---@generic self
---@param self self
---@param min number
---@param max number
---@return self
function Vector2Methods:randomize(min, max)
  ---@cast self Vector2
  if not min then
    return self:set(m_random(), m_random())
  elseif not max then
    return self:set(m_random(), m_random()):scale(min)
  end

  return self:set(m_random(), m_random()):scale(max - min):offset(min)
end


---@class Vector3
local Vector3Methods = {}
local Vector3_old = figuraMetatables.Vector3.__index

function figuraMetatables.Vector3.__index(self, key)
  return Vector3Methods[key] or Vector3_old(self, key)
end

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Performs modulo on this vector.
  ---@generic self
  ---@param self self
  ---@param vec Vector3
  ---@return self
  function Vector3Methods:mod(vec) end

  ---### [GS Extensions]
  ---Randomizes the values of this vector between 0 and 1.
  ---@generic self
  ---@param self self
  ---@return self
  function Vector3Methods:randomize() end

  ---### [GS Extensions]
  ---Randomizes the values of this vector between 0 and the given max.
  ---@generic self
  ---@param self self
  ---@param max number
  ---@return self
  function Vector3Methods:randomize(max) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

---### [GS Extensions]
---Negates this vector.
---@generic self
---@param self self
---@return self
function Vector3Methods:negate()
  ---@cast self Vector3
  return self:scale(-1)
end

---### [GS Extensions]
---Performs modulo on this vector.
---@generic self
---@param self self
---@param x? number
---@param y? number
---@param z? number
---@return self
function Vector3Methods:mod(x, y, z)
  ---@cast self Vector3
  if type(x) == "Vector3" then return self:set(self.x % x.x, self.y % x.y, self.z % x.z) end

  if x then self.x = self.x % x end
  if y then self.y = self.y % y end
  if z then self.z = self.z % z end
  return self
end

---### [GS Extensions]
---Wraps all values of this vector between -180 and 180.
---
---If `unsigned` is set, values are wrapped between 0 and 360 instead.
---@generic self
---@param self self
---@param unsigned? boolean
---@return self
function Vector3Methods:normalizeAngle(unsigned)
  ---@cast self Vector3
  if unsigned then
    self:set(self.x % 360, self.y % 360, self.z % 360)
  else
    self:offset(180):set(self.x % 360, self.y % 360, self.z % 360):offset(-180)
  end
  return self
end

---### [GS Extensions]
---Creates a copy of this vector with all values wrapped between -180 and 180.
---
---If `unsigned` is set, values are wrapped between 0 and 360 instead.
---@param unsigned? boolean
---@return Vector3
function Vector3Methods:normalizedAngle(unsigned)
  if unsigned then return self % 360 end
  return (self + 180):set(self.x % 360, self.y % 360, self.z % 360):offset(-180)
end

---### [GS Extensions]
---Randomizes the values of this vector between the given min and max.
---@generic self
---@param self self
---@param min number
---@param max number
---@return self
function Vector3Methods:randomize(min, max)
  ---@cast self Vector3
  if not min then
    return self:set(m_random(), m_random(), m_random())
  elseif not max then
    return self:set(m_random(), m_random(), m_random()):scale(min)
  end

  return self:set(m_random(), m_random(), m_random()):scale(max - min):add(min, min, min)
end


---@class Vector4
local Vector4Methods = {}
local Vector4_old = figuraMetatables.Vector4.__index

function figuraMetatables.Vector4.__index(self, key)
  return Vector4Methods[key] or Vector4_old(self, key)
end

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Performs modulo on this vector.
  ---@generic self
  ---@param self self
  ---@param vec Vector4
  ---@return self
  function Vector4Methods:mod(vec) end

  ---### [GS Extensions]
  ---Randomizes the values of this vector between 0 and 1.
  ---@generic self
  ---@param self self
  ---@return self
  function Vector4Methods:randomize() end

  ---### [GS Extensions]
  ---##### Requires `.loadVector()`
  ---Randomizes the values of this vector between 0 and the given max.
  ---@generic self
  ---@param self self
  ---@param max number
  ---@return self
  function Vector4Methods:randomize(max) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

---### [GS Extensions]
---Negates this vector.
---@generic self
---@param self self
---@return self
function Vector4Methods:negate()
  ---@cast self Vector4
  return self:scale(-1)
end

---### [GS Extensions]
---Performs modulo on this vector.
---@generic self
---@param self self
---@param x? number
---@param y? number
---@param z? number
---@param w? number
---@return self
function Vector4Methods:mod(x, y, z, w)
  ---@cast self Vector4
  if type(x) == "Vector4" then return self:set(self.x % x.x, self.y % x.y, self.z % x.z) end

  if x then self.x = self.x % x end
  if y then self.y = self.y % y end
  if z then self.z = self.z % z end
  if w then self.w = self.w % w end
  return self
end

---### [GS Extensions]
---Wraps all values of this vector between -180 and 180.
---
---If `unsigned` is set, values are wrapped between 0 and 360 instead.
---@generic self
---@param self self
---@param unsigned? boolean
---@return self
function Vector4Methods:normalizeAngle(unsigned)
  ---@cast self Vector4
  if unsigned then
    self:set(self.x % 360, self.y % 360, self.z % 360, self.w % 360)
  else
    self:offset(180):set(self.x % 360, self.y % 360, self.z % 360, self.w % 360):offset(-180)
  end
  return self
end

---### [GS Extensions]
---Creates a copy of this vector with all values wrapped between -180 and 180.
---
---If `unsigned` is set, values are wrapped between 0 and 360 instead.
---@param unsigned? boolean
---@return Vector4
function Vector4Methods:normalizedAngle(unsigned)
  if unsigned then return self % 360 end
  return (self + 180):set(self.x % 360, self.y % 360, self.z % 360, self.w % 360):offset(-180)
end

---### [GS Extensions]
---Randomizes the values of this vector between the given min and max.
---@generic self
---@param self self
---@param min number
---@param max number
---@return self
function Vector4Methods:randomize(min, max)
  ---@cast self Vector4
  if not min then
    return self:set(m_random(), m_random(), m_random(), m_random())
  elseif not max then
    return self:set(m_random(), m_random(), m_random(), m_random()):scale(min)
  end

  return self:set(m_random(), m_random(), m_random(), m_random()):scale(max - min):offset(min)
end


return setmetatable(this, thismt)
