-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Configs" <GSE_Config>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds more methods to Figura's Config api.

local ID = "GSE_Config"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds some methods to Figura's config api.  
---These methods deal with saving and loading information from files that are not currently active.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---### *Does not require GSECommon!*
---
---**<u>Contributes:</u>**
---* `<ConfigAPI>`
---  * `:loadFrom()`
---  * `:saveTo()`
---@class Lib.GS.Extensions.Config
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

---@class ConfigAPI
local ConfigAPI = figuraMetatables.ConfigAPI.__index

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Loads the entire config file with the given name.
  ---@param name string
  ---@return {[string]: ConfigAPI.validType}
  function ConfigAPI:loadFrom(name) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

---### [GS Extensions]
---Loads the given key from the config file with the given name.
---@param name string
---@param key string
---@return any
function ConfigAPI:loadFrom(name, key)
  local oldname = self:getName()
  self:setName(name)
  local data = self:load(key)
  self:setName(oldname)
  return data
end

---### [GS Extensions]
---Saves the given key and value to the config file with the given name.
---@generic self
---@param self self
---@param name string
---@param key string
---@param value? any
---@return self
function ConfigAPI:saveTo(name, key, value)
  ---@cast self ConfigAPI
  local oldname = self:getName()
  self:setName(name)
  self:save(key, value)
  self:setName(oldname)
  return self
end


return setmetatable(this, thismt)
