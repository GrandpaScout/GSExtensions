-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Clients" <GSE_Client>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds more fields and methods to Figura's Client api.

local ID = "GSE_Client"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds some fields and methods to Figura's client api.  
---Most involve getting true FOV and information about the camera.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `client`
---  * `.fovEffects`
---  * `.getCameraForward()`
---  * `.getCameraRight()`
---  * `.getCameraUp()`
---  * `.getFOVMultiplier()`
---  * `.getTrueFOV()`
---  * `.getCameraMatrix()`
---  * `.getAimDir()`
---@class Lib.GS.Extensions.Client
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}


local _HOST = host:isHost()
local _VIEWER = client.getViewer()
local _EPSILON = 2 ^ -52
local _VEC_UP = vectors.vec3(0, 1)

local math = math
local m_huge = math.huge
local m_abs = math.abs
local m_atan = math.atan
local m_clamp = math.clamp
local m_lerp = math.lerp
local m_min = math.min
local m_rad = math.rad
local m_tan = math.tan

local client = client
local c_getCameraPos = client.getCameraPos
local c_getFrameTime = client.getFrameTime



---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---

local _truefov, truefov = 1, 1
local fov_mult = 1
local speed_index = 0
local fov_effects = 1
events.TICK:register(function()
  local action = _VIEWER:getActiveItem():getUseAction()
  if action == "SPYGLASS"
    and (
      (_HOST and renderer:isFirstPerson())
      -- Shitty `client.isFirstPerson()` check because it doesn't exist.
      or (not _HOST and _VIEWER:getPos()
        :add(0, _VIEWER:getEyeHeight(), 0)
        :sub(c_getCameraPos())
        :lengthSquared() < 0.1075
      )
    )
  then
    fov_mult = 0.1
  elseif fov_effects == 0 then
    fov_mult = 1
  else
    local nbt = _VIEWER:getNbt()
    local walk_speed = nbt.abilities.walkSpeed

    fov_mult = _VIEWER:isFlying() and 1.1 or 1

    if walk_speed == 0 then
      fov_mult = 1
    else
      local attrs = nbt.Attributes
      if not (attrs[speed_index] and attrs[speed_index].Name == "minecraft:generic.movement_speed") then
        for i, attr in ipairs(attrs) do
          if attr.Name == "minecraft:generic.movement_speed" then
            speed_index = i
            break
          end
        end
      end
      local speed_attr = attrs[speed_index]
      -- Use the default speed if it can't be found.
      speed_attr = speed_attr and speed_attr.Base or 0.10000000149011612
      if _VIEWER:isSprinting() then speed_attr = speed_attr * 1.3 end
      local foundspeed, foundslow
      for _, effect in ipairs(_VIEWER:getStatusEffects()) do
        if effect.name == "effect.minecraft.speed" then
          speed_attr = speed_attr * (1 + (0.2 * (effect.amplifier + 1)))
          if foundslow then break end
          foundspeed = true
        elseif effect.name == "effect.minecraft.slowness" then
          speed_attr = speed_attr * (1 + (-0.15 * (effect.amplifier + 1)))
          if foundspeed then break end
          foundslow = true
        end
      end
      if speed_attr ~= walk_speed then
        fov_mult = fov_mult * ((speed_attr / walk_speed + 1) * 0.5)
      end

      if fov_mult ~= fov_mult or m_abs(fov_mult) == m_huge then fov_mult = 1 end
    end

    if action == "BOW" then
      local time = _VIEWER:getActiveItemTime() * 0.05
      fov_mult = fov_mult * (1 - m_min(1, time ^ 2) * 0.15)
    end
  end

  fov_mult = m_clamp(fov_effects == 1 and fov_mult or m_lerp(1, fov_mult, fov_effects), 0.1, 1.5)

  _truefov = truefov
  truefov = truefov + ((fov_mult - truefov) * 0.5)
  if m_abs(truefov - fov_mult) <= _EPSILON then truefov = fov_mult end
end, "GSE_Client:Tick_TrueFOV")

---@class ClientAPI
---### [GS Extensions]
---Emulates the "FOV Effects" accessibility setting.
---
---This is used by some functions for their calculations
---
---Figura does not have a method for getting this setting so it must be set manually.
---@field fovEffects number
local Client = figuraMetatables.ClientAPI.__index

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions
  ---Returns a unit vector pointing forward relative to the direction the camera is looking in.
  ---@return Vector3
  function Client.getCameraForward() end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

--- LuaLS shenanigans
Client["" .. "getCameraForward"] = Client.getCameraDir

---### [GS Extensions]
---Returns a unit vector pointing right relative to the direction the camera is looking in.
---@return Vector3
function Client.getCameraRight()
  return client.getCameraForward():cross(_VEC_UP):normalize()
end

---### [GS Extensions]
---Returns a unit vector pointing up relative to the direction the camera is looking in.
---@return Vector3
function Client.getCameraUp()
  return client.getCameraForward():scale(-1):cross(
    client.getCameraForward():cross(_VEC_UP):normalize()
  )
end

---### [GS Extensions]
---Gets the current multiplier on the client's FOV.
---
---This does not include the "FOV Effects" setting due to Figura not having a way to get that information.  
---Modify the `.fovEffects` field to emulate this setting.
---@return number
function Client.getFOVMultiplier()
  return fov_mult
end

---### [GS Extensions]
---Gets the client's *actual* FOV after all modifications.
---
---This does not include the "FOV Effects" setting due to Figura not having a way to get that information.  
---Modify the `.fovEffects` field to emulate this setting.
---@return number
function Client.getTrueFOV()
  return m_lerp(_truefov, truefov, c_getFrameTime()) * client.getFOV()
end

local localm4 = matrices.mat4()
local mulvec = vec(-1, 1, -1)
---### [GS Extensions]
---Returns a matrix that converts world vectors to camera-space vectors.
---
---This is slower than using `vectors.toCameraSpace()` to convert position vectors, but this supports direction
---vectors with `:applyDir()`.
---@return Matrix4
function Client.getCameraMatrix()
  local cam_rot = client.getCameraRot()
  return localm4
    :reset()
    :rotateX(-cam_rot.x)
    :rotateY(-cam_rot.y)
    :scale(mulvec)
    :copy()
end

---### [GS Extensions]
---Gets a vector pointing in the same direction as the mouse.
---
---If the mouse is not currently visible, this behaves exactly like `.getCameraDir()`.
---@return Vector3
function Client.getAimDir()
  if _VIEWER == _HOST and not (host:getScreen() or action_wheel:isEnabled() or host.unlockCursor) then
    return client.getCameraDir()
  end

  local scr_size = client.getWindowSize()
  local mouse_pos = client.getMousePos():div(scr_size)

  if mouse_pos.x < 0 or mouse_pos.x > 1
    or mouse_pos.y < 0 or mouse_pos.y > 1
    or mouse_pos.x == 0.5 and mouse_pos.y == 0.5
  then
    return client.getCameraDir()
  end

  mouse_pos:scale(2):sub(1, 1)

  local ratio = (scr_size.x / scr_size.y)

  local fov = m_rad(m_lerp(_truefov, truefov, c_getFrameTime()) * client.getFOV())
  local hfov = 2 * m_atan(m_tan(fov * 0.5) * ratio)
  local cam_rot = client.getCameraRot()
  local ret = localm4
    :reset()
    :rotateX(-cam_rot.x)
    :rotateY(-cam_rot.y)
    :scale(mulvec)
    :applyDir(
      mouse_pos.x * m_tan(hfov * 0.5),
      -mouse_pos.y * m_tan(fov * 0.5),
      -1
    )
    :normalize()

  return ret
end

function figuraMetatables.ClientAPI:__newindex(key, value)
  --TODO: Make fovEffects client-side.
  if key == "fovEffects" then
    if _HOST then
      fov_effects = type(value) == "number"
        and value == value and m_abs(value) < m_huge and value
        or 1
    end
    return
  end
  rawset(self, key, value)
end

setmetatable(Client, {
  __index = function(self, key)
    if key == "fovEffects" then return fov_effects end
    return rawget(self, key)
  end
})


return setmetatable(this, thismt)
