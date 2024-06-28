-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Common" <GSECommon>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds functions to Figura's world api.

local ID = "GSECommon"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Common functions and values for most GSE scripts.
---
---All scripts that require this will attempt to grab it from the folder it is contained in.
---@class Lib.GS.Extensions.Common
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}

local enum_data = setmetatable({}, {__mode = "k"})
local enum_isc = setmetatable({}, {__mode = "k"})

---Iterates over an enum value's keys.
---
---Used automatically by `pairs()` when an enum is given.
---@generic K, V
---@param t table<K, V>
---@param k K
---@return K
---@return V
function this.enum_next(t, k)
  if not enum_data[t] then return next(t, k) end
  local nk, v = next(enum_data[t], k)
  if enum_isc[t] and v then return nk, v:copy() end
  return nk, v
end

---Iterates over an enum value's keys.
---
---Used automatically by `ipairs()` when an enum is given.
---@generic V
---@param t table<integer, V>
---@param i integer
---@return integer
---@return V
function this.enum_iter(t, i)
  i = (i or 0) + 1
  if not enum_data[t] then return i, t[i] end
  local v = enum_data[t][i]
  if enum_isc[t] and v then return i, v:copy() end
  return i, v
end

local enum_next = this.enum_next
local enum_iter = this.enum_iter

local enum_mt = {
  __index = function(self, key)
    if enum_isc[self] and enum_data[self][key] then return enum_data[self][key]:copy() end
    return enum_data[self][key]
  end,
  __newindex = function() error("attempt to write to read-only enum", 2) end,
  __pairs = function(self) return enum_next, self end,
  __ipairs = function(self) return enum_iter, self end,
  __len = function(self) return #enum_data[self] end,
  __type = "enum"
}

---Turns a table into an enum by GSE's standards.
---@generic T
---@param tbl T
---@return T
function this.enum(tbl)
  local o = setmetatable({}, enum_mt)
  enum_data[o] = tbl
  return o
end

---Turns a table into an enum by GSE's standards.
---
---This version copies its internal values instead of returning them directly.
---@generic T
---@param tbl T
---@return T
function this.enumcopy(tbl)
  local o = setmetatable({}, enum_mt)
  enum_isc[o] = true
  enum_data[o] = tbl
  return o
end


return setmetatable(this, thismt)
