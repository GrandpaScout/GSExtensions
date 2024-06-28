-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Keybinds" <GSE_Keybind>
---@version v1.1.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds more methods to Figura's keybinds.

local ID = "GSE_Keybind"
local VER = "1.1.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds methods to Figura's keybinds.  
---Also introduces keybind autosaving, networking, and vanilla keybind watching.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---### *Requires GSECommon!*
---
---**<u>Contributes:</u>**
---* `pings`
---  * `GS$KBNet`
---* `<Keybind>`
---  * `:network()`
---  * `:isNetworked()`
---  * `:autosave()`
---  * `:isAutosaved()`
---  * `:watch()`
---  * `:isWatching()`
---  * `:reset()`
---* `_ENV`
---  * `KEYCODE`
---    * *131 Items*
---  * `KEYMOD`
---    * `.NONE`
---    * `.SHIFT`
---    * `.CONTROL`
---    * `.CTRL`
---    * `.ALT`
---    * `.WIN`
---    * `.META`
---  * `KEYSTATE`
---    * `.RELEASE`
---    * `.PRESS`
---    * `.HOLD`
---@class Lib.GS.Extensions.Keybind
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}

---@type Lib.GS.Extensions.Common
local common = require((...):gsub("(.)$", "%1.") .. "GSECommon")

local _HOST = host:isHost()

local keybinds = keybinds

local m_floor = math.floor

local t_unpack = table.unpack

local b_btest = bit32.btest


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---An enum of numerical key codes.
KEY = common.enum {
  -- Undefined key
  UNKNOWN = 0,

  ESCAPE = 256,
  F1 = 290, F2 = 291, F3 = 292, F4 = 293,
  F5 = 294, F6 = 295, F7 = 296, F8 = 297,
  F9 = 298, F10 = 299, F11 = 300, F12 = 301,

  F13 = 302, F14 = 303, F15 = 304, F16 = 305,
  F17 = 306, F18 = 307, F19 = 308, F20 = 309,
  F21 = 310, F22 = 311, F23 = 312, F24 = 313,

  GRAVE = 96,
  ONE = 49, TWO = 50, THREE = 51, FOUR = 52, FIVE = 53,
  SIX = 54, SEVEN = 55, EIGHT = 56, NINE = 57, ZERO = 48,
  MINUS = 45, EQUALS = 61, BACKSPACE = 259,

  TAB = 258,
  Q = 81, W = 87, E = 69, R = 82, T = 84, Y = 89, U = 85, I = 73, O = 79, P = 80,
  LEFT_BRACKET = 91, RIGHT_BRACKET = 93, BACKSLASH = 92,

  CAPS_LOCK = 280,
  A = 65, S = 83, D = 68, F = 70, G = 71, H = 72, J = 74, K = 75, L = 76,
  SEMICOLON = 59, APOSTROPHE = 39,
  ENTER = 257, RETURN = 257,

  LEFT_SHIFT = 340,
  Z = 90, X = 88, C = 67, V = 86, B = 66, N = 78, M = 77,
  COMMA = 44, PERIOD = 46, SLASH = 47,
  RIGHT_SHIFT = 344,

  LEFT_CONTROL = 341, LEFT_CTRL = 341,
  LEFT_WIN = 343, LEFT_META = 343,
  LEFT_ALT = 342,
  SPACE = 32,
  RIGHT_ALT = 346,
  RIGHT_WIN = 347, RIGHT_META = 347,
  MENU = 348,
  RIGHT_CONTROL = 345, RIGHT_CTRL = 345,

  PRINT_SCREEN = 283,
  SCROLL_LOCK = 281,
  PAUSE = 284, BREAK = 284,

  INSERT = 260, INS = 260,
  HOME = 268,
  PAGE_UP = 266, PGUP = 266,
  DELETE = 261, DEL = 261,
  END = 269,
  PAGE_DOWN = 267, PGDN = 267,

  UP = 265, DOWN = 264, LEFT = 263, RIGHT = 262,

  KP_0 = 320,
  KP_1 = 321, KP_2 = 322, KP_3 = 323,
  KP_4 = 324, KP_5 = 325, KP_6 = 326,
  KP_7 = 327, KP_8 = 328, KP_9 = 329,
  KP_PERIOD = 330,
  KP_DIVIDE = 331, KP_SLASH = 331,
  KP_MULTIPLY = 332,
  KP_SUBTRACT = 333, KP_MINUS = 333,
  KP_ADD = 334, KP_PLUS = 334,
  KP_ENTER = 335, KP_RETURN = 335,
  NUM_LOCK = 282,
}

---### [GS Extensions]
---An enum of modifer key bits.
KEYMOD = common.enum {
  NONE = 0,
  SHIFT = 1,
  CONTROL = 2, CTRL = 2,
  ALT = 4,
  WIN = 8, META = 8
}

---### [GS Extensions]
---An enum of key press states.
KEYSTATE = common.enum {
  RELEASE = 0,
  PRESS = 1,
  HOLD = 2
}


---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---

---@type {[Keybind]: {group: integer, bit: integer, on: boolean}}
local keybind_net = {}

---@type integer[]
local keybind_bits = {}
local keybind_nextbit = 0

---@type {[Keybind]: {config_key: string, saved_key?: string, last_key: string}}
local keybind_config = {}
---@type {[Keybind]: string}
local keybind_defaults = {}

---@type {[Keybind]: string}
local keybind_vanilla = {}
---@type {[Keybind]: string}
local keybind_watch = {}

---@type {[string]: string}
local vanilla_key = {}

local keybind_funcs = {}

pings["GS$KBNet"] = function(bitmask, ...)
  if _HOST then return end

  local bits = {...}

  local pressed
  for kb, data in pairs(keybind_net) do
    pressed = b_btest(bits[data.group], data.bit)
    if pressed ~= data.on then
      data.on = pressed
      ---@diagnostic disable-next-line: redundant-parameter
      if pressed then kb.press(bitmask, kb) else kb.release(bitmask, kb) end
    end
  end
end

local function sendKBNetMessage(bitmask)
  for kb, data in pairs(keybind_net) do
    local pressed = kb:isPressed()
    local group = data.group
    if pressed ~= data.on then
      if pressed then
        keybind_bits[group] = keybind_bits[group] + data.bit
      else
        keybind_bits[group] = keybind_bits[group] - data.bit
      end
      data.on = pressed
    end
  end

  pings["GS$KBNet"](bitmask, t_unpack(keybind_bits))
end

local function networkWrap(func)
  return function(bitmask, self)
    sendKBNetMessage(bitmask)
    func(bitmask, self)
  end
end

if _HOST then
  local localcfg, changed
  events.TICK:register(function()
    local time = world.getTime()
    if time % 20 == 0 then
      local key
      for kb, data in pairs(keybind_config) do
        key = kb:getKey()
        if key ~= data.last_key then
          data.last_key = key
          if key == keybind_defaults[kb] then key = nil end
          if not changed then
            changed = true
            ---@diagnostic disable-next-line: undefined-field
            localcfg = config:getName()
            config:setName("GSE-Keys")
          end
          config:save(data.config_key, key)
          data.saved_key = key
        end
      end

      if changed then
        config:setName(localcfg)
        changed = false
        localcfg = nil
      end
    elseif time % 5 == 4 then
      for vkb in pairs(vanilla_key) do
        vanilla_key[vkb] = keybinds:getVanillaKey(vkb)
      end

      for kb, data in pairs(keybind_watch) do
        if not keybind_config[kb] or keybind_config[kb].saved_key == nil then
          kb:setKey(vanilla_key[data])
        end
      end
    end
  end, "GSExtensions:Tick_Autosave_Watch")
end


---==================================================================================================================---
---====  METATABLES  ================================================================================================---
---==================================================================================================================---

local KeybindAPI = figuraMetatables.KeybindAPI.__index
local KAPI_newKeybind = KeybindAPI.newKeybind
local KAPI_fromVanilla = KeybindAPI.fromVanilla

---@param name string
---@param key? Minecraft.keyCode
---@param gui? boolean
---@return Keybind
function KeybindAPI:newKeybind(name, key, gui)
  local kb = KAPI_newKeybind(self, name, key, gui)
  keybind_defaults[kb] = key or "key.keyboard.unknown"
  return kb
end

-- LuaLS shenanigans
KeybindAPI.of = KeybindAPI.newKeybind

---@param keybind Minecraft.keybind
---@return Keybind
function KeybindAPI:fromVanilla(keybind)
  local kb = KAPI_fromVanilla(self, keybind)
  keybind_vanilla[kb] = keybind
  local vkb = keybinds:getVanillaKey(keybind)
  vanilla_key[keybind] = vkb
  keybind_defaults[kb] = vkb
  return kb
end


local Keybind = figuraMetatables.Keybind
local Keybind_index = Keybind.__index
local Keybind_newindex = Keybind.__newindex

---@class Keybind
local KeybindMethods = {}

---### [GS Extensions]
---Sets up a keybind for automatic networking over KBNet.
---
---Keybinds *must* be networked in the same order on the host and the client for this to work.
---@generic self
---@param self self
---@return self
function KeybindMethods:network()
  ---@cast self Keybind
  if keybind_net[self] then return self end
  local group = m_floor(keybind_nextbit * 0.03125) + 1
  local bit = 2 ^ (keybind_nextbit % 32)
  if bit == 1 then keybind_bits[group] = 0 end
  keybind_nextbit = keybind_nextbit + 1

  keybind_net[self] = {group = group, bit = bit, on = false}
  keybind_funcs[self] = {}
  return self
end

---### [GS Extensions]
---Gets if this keybind is set up for automatic networking.
---@return boolean
function KeybindMethods:isNetworked()
  return keybind_net[self] ~= nil
end

---### [GS Extensions]
---Sets up this keybind for autosaving.  
---If the given id was autosaved before, the key it saved will be restored.
---
---When an autosaved keybind's key changes, it is saved to file to be restored later.  
---If the keybind is reset to the default binding, the key will be *removed from the file and forgotten*.
---@generic self
---@param self self
---@return self
function KeybindMethods:autosave(id)
  ---@cast self Keybind
  if not _HOST then
    return self
  elseif not keybind_defaults[self] then
    error("cannot autosave a keybind created before the keybind extension was loaded", 2)
  end
  local oldcfg = config:getName()
  config:setName("GSE-Keys")
  local saved_key = config:load(id)
  config:setName(oldcfg)
  ---@cast saved_key string?
  keybind_config[self] = {
    config_key = id,
    saved_key = saved_key,
    last_key = saved_key or self:getKey()
  }

  if saved_key then self:setKey(saved_key) end
  return self
end

---### [GS Extensions]
---Gets this keybind's autosave key if it has one.
---@return string?
function KeybindMethods:isAutosaved()
  return _HOST and keybind_config[self] and keybind_config[self].config_key or nil
end

---### [GS Extensions]
---Sets up this keybind to watch the vanilla keybind it was created with.
---
---Whenever the vanilla keybind changes, this keybind will change with it.
---@generic self
---@param self self
---@return self
function KeybindMethods:watch()
  ---@cast self Keybind
  if not _HOST or keybind_watch[self] then
    return self
  elseif not keybind_vanilla[self] then
    error("cannot watch a keybind that was not created with :fromVanilla() or was created before the keybind extension was loaded", 2)
  end

  keybind_watch[self] = keybind_vanilla[self]
  keybind_vanilla[self] = nil

  return self
end

---### [GS Extensions]
---Gets the vanilla keybind this keybind is watching if it was created with one.
---@return Minecraft.keybind?
function KeybindMethods:isWatching()
  return _HOST and keybind_watch[self] or nil
end

---### [GS Extensions]
---Resets the key of this keybind to its original value.
---@generic self
---@param self self
---@return self
function KeybindMethods:reset()
  ---@cast self Keybind
  if not _HOST then
    return self
  elseif not keybind_defaults[self] then
    error("cannot reset a keybind created before the keybind extension was loaded", 2)
  end

  self:setKey(keybind_defaults[self])
  return self
end

if _HOST then
  local onpress = Keybind_index(nil, "onPress")
  ---@diagnostic disable-next-line: duplicate-set-field
  function KeybindMethods:onPress(func)
    if not keybind_net[self] then onpress(self, func) end
    keybind_funcs[self].press = func
    Keybind_newindex(self, "press", networkWrap(func))
  end
  KeybindMethods.setOnPress = KeybindMethods.onPress

  local onrelease = Keybind_index(nil, "onRelease")
  ---@diagnostic disable-next-line: duplicate-set-field
  function KeybindMethods:onRelease(func)
    if not keybind_net[self] then onrelease(self, func) end
    keybind_funcs[self].press = func
    Keybind_newindex(self, "release", networkWrap(func))
  end

  function Keybind:__index(key)
    if keybind_net[self] then
      if key == "press" or key == "release" then
        return keybind_funcs[key]
      end
    end

    return KeybindMethods[key] or Keybind_index(self, key)
  end

  function Keybind:__newindex(key, value)
    if keybind_net[self] then
      if key == "press" or key == "release" then
        keybind_funcs[key] = value
        Keybind_newindex(self, key, networkWrap(value))
        return
      end
    end

    Keybind_newindex(self, key, value)
  end
else
  ---@diagnostic disable-next-line: duplicate-set-field
  function KeybindMethods:isPressed()
    return keybind_net[self] and keybind_net[self].on or false
  end
end


return setmetatable(this, thismt)
