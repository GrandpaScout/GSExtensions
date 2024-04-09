-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Host" <GSE_Host>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds more fields and methods to Figura's Host api and viewers.

local ID = "GSE_Host"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds a method to Figura's Host api and viewer.  
---This method re-introduces `:getStatusEffect()` from prewrite.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `<HostAPI>`
---  * `:getStatusEffect()`
---* `<Viewer>`
---  * `:getStatusEffect()`
---@class Lib.GS.Extensions.Host
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}


---==================================================================================================================---
---====  METATABLES  ================================================================================================---
---==================================================================================================================---

---@class HostAPI
local Host = figuraMetatables.HostAPI.__index

---### [GS Extensions]
---Gets information about the specified status effect if it is found on the avatar host.
---
---Supports namespaced ids.
---@param id Minecraft.effectID
---@return HostAPI.statusEffect?
function Host:getStatusEffect(id)
  local effect_id
  if id:match("^effect%.[^%.]+%.[^%.]+$") then
    effect_id = id
  else
    local ns, name = id:match("^([^:]-):?(.*)$")
    if ns == "" then ns = "minecraft" end
    effect_id = "effect." .. ns .. "." .. name
  end

  for _, effect in ipairs(self:getStatusEffects()) do
    if effect.name == effect_id then return effect end
  end

  return nil
end


---@class Viewer
local Viewer = figuraMetatables.ViewerAPI.__index

---### [GS Extensions]
---Gets information about the specified status effect if it is found on the viewer.
---
---Supports namespaced ids.
---@param id Minecraft.effectID
---@return HostAPI.statusEffect?
function Viewer:getStatusEffect(id)
  local effect_id
  if id:match("^effect%.[^%.]+%.[^%.]+$") then
    effect_id = id
  else
    local ns, name = id:match("^([^:]-):?(.*)$")
    if ns == "" then ns = "minecraft" end
    effect_id = "effect." .. ns .. "." .. name
  end

  for _, effect in ipairs(self:getStatusEffects()) do
    if effect.name == effect_id then return effect end
  end

  return nil
end


return setmetatable(this, thismt)
