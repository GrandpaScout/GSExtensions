-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Globals" <GSE_Global>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds some helpful global variables that can be used as shortcuts.

local ID = "GSE_Global"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds some miscellaneous global variables for convenience.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `_ENV`
---  * `AVATAR_NAME`
---  * `AVATAR_SIZE`
---  * `HOST`
---  * `viewer`
---  * `_MCVERSION`
---  * `_MCBRAND`
---  * `_JAVAVERSION`
---  * `_FIGVERSION`
---  * `_AVATARVERSION`
---@class Lib.GS.Extensions.Global
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
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---The avatar's name.
AVATAR_NAME = avatar:getName()
---### [GS Extensions]
---The avatar's size in bytes.
AVATAR_SIZE = avatar:getSize()

---### [GS Extensions]
---Whether this instance of the script is running on the avatar owner's computer.
---
---A static version of `host:isHost()`. Saves on instructions.
HOST = host:isHost()
---### [GS Extensions]
---The viewing client as a player.
---
---A static version of `client.getViewer()`. Saves on instructions.
---<!--
---@diagnostic disable-next-line: lowercase-global
viewer = client.getViewer()

---### [GS Extensions]
---The current Minecraft version.
_MCVERSION = client.getVersionName()
---### [GS Extensions]
---The current Minecraft brand.
_MCBRAND = client.getClientBrand():gsub("^(.)", string.upper, 1)

---### [GS Extensions]
---The current Java version
_JAVAVERSION = client.getJavaVersion()

---### [GS Extensions]
---The current Figura version.
---@type Figura.version
_FIGVERSION = client.getFiguraVersion():gsub("%+.*$", "")
---### [GS Extensions]
---The avatar's recommended version.
---@type Figura.version
_AVATARVERSION = avatar:getVersion():gsub("%+.*$", "")

---### [GS Extensions]
---A null value for use with `toJson()`.
---@type unknown
---@diagnostic disable-next-line: lowercase-global
null = function() end


return setmetatable(this, thismt)
