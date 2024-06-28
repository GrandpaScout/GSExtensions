-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions StdTable" <GSE_StdTable>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension functions to Lua's standard table library.

local ID = "GSE_StdTable"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds functions to Lua's `table` library.  
---Most functions involve manipulation of tables, however some may also manipulate metatables.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---### *Does not require GSECommon!*
---
---**<u>Contributes:</u>**
---* `table`
---  * `.append()`
---  * `.copy()`
---  * `.deepcopy()`
---  * `.isempty()`
---  * `.inherit()`
---  * `.complete()`
---  * `.merge()`
---  * `.shuffle()`
---  * `.clear()`
---  * `.size()`
---  * `.random()`
---  * `.keys()`
---  * `.values()`
---  * `.pairs()`
---  * `.reverse()`
---@class Lib.GS.Extensions.StdTable
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
local m_floor = math.floor
local m_random = math.random

local t_insert = table.insert

local w_newBlock = world.newBlock


---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---Appends the source table onto the target table.
---
---This function only works on sequential tables.
---@param target any[]
---@param source any[]
function table.append(target, source)
  for _, v in ipairs(source) do
    t_insert(target, v)
  end
end

---### [GS Extensions]
---Creates a shallow copy of a table.
---@generic table
---@param tbl table
---@return table
function table.copy(tbl)
  local copy = {}
  for k, v in pairs(tbl) do copy[k] = v end
  return copy
end

local datatypes = {
  Vector2 = true, Vector3 = true, Vector4 = true,
  Matrix2 = true, Matrix3 = true, Matrix4 = true,
  BlockState = true, ItemStack = true
}
local deepcopy
---### [GS Extensions]
---Creates a deep copy of a table.
---
---If `data` is set, certain Figura objects are also copied.
---@generic table
---@param tbl table
---@param data? boolean
---@param _DONE? {[unknown]: unknown}
---@return table
function table.deepcopy(tbl, data, _DONE)
  local copy = {}
  _DONE = _DONE or {}
  _DONE[tbl] = copy
  for k, v in pairs(tbl) do
    local t = type(v)
    if t == "table" then
      copy[k] = _DONE[v] or deepcopy(v, data, _DONE)
    elseif data and datatypes[t] then
      if _DONE[v] then
        copy[k] = _DONE[v]
      elseif t == "BlockState" then
        copy[k] = w_newBlock(v:toStateString(), v:getPos())
      else
        copy[k] = v:copy()
      end
    else
      copy[k] = v
    end
  end
  return copy
end
deepcopy = table.deepcopy

---### [GS Extensions]
---Gets if a table is completely empty.
---@param tbl table
---@return boolean
function table.isempty(tbl)
  return next(tbl) == nil
end

---### [GS Extensions]
---Makes the target table inherit the values of the source table.
---
---This is done by modifying the target's `__index` metamethod.  
---If the target table already has an `__index` metamethod, it is overwritten.
---
---If `chain` is set, the `__index` metamethod found on the target table becomes the `__index` metamethod of the
---source table. This will overwrite the `source` table's `__index` metamethod.
---
---To do something similar without metamethods, see `table.complete()` or `table.merge()`.
---@param target table
---@param source table
---@param chain? boolean
function table.inherit(target, source, chain)
  local mt = getmetatable(target)
  if not mt then
    setmetatable(target, {__index = source})
  else
    if chain then
      local smt = getmetatable(source)
      if smt then
        smt.__index = mt.__index
      else
        setmetatable(source, {__index = mt.__index})
      end
    end
    mt.__index = source
  end
end

---### [GS Extensions]
---Adds the keys from the source table that the target table is missing.
---
---To do something similar with metamethods, see `table.inherit()`.
---@param target table
---@param source table
function table.complete(target, source)
  for k, v in pairs(source) do
    if v ~= nil then target[k] = v end
  end
end

---### [GS Extensions]
---Merges the values of the source table onto the target table.
---
---This will overwrite keys on the target table that the source table has.
---
---To do something similar with metamethods, see `table.inherit()`.
---@param target table
---@param source table
function table.merge(target, source)
  for k, v in pairs(source) do
    target[k] = v
  end
end

---### [GS Extensions]
---Performs a Fisher-Yates shuffle on a sequential table.
---@param tbl any[]
function table.shuffle(tbl)
  local len = #tbl
  for i = 1, len - 1 do
    local tgt = m_random(i, len)
    tbl[i], tbl[tgt] = tbl[tgt], tbl[i]
  end
end

---### [GS Extensions]
---Removes all keys from a table.
---
---This does not remove the table's current metatable.
---@param tbl table
function table.clear(tbl)
  for key in pairs(tbl) do tbl[key] = nil end
end

---### [GS Extensions]
---Gets the number of keys in a table.
---
---This is different from `#tbl` as this function gets *every* key, not just the sequential ones.
---@param tbl table
---@return integer
function table.size(tbl)
  local i = 0
  for _ in pairs(tbl) do i = i + 1 end
  return i
end

---### [GS Extensions]
---Gets a random value from a table.
---@generic K, V
---@param tbl table<K, V>
---@return V value
---@return K key
function table.random(tbl)
  local keys = {}
  for key in pairs(tbl) do t_insert(keys, key) end
  local key = keys[m_random(#keys)]
  return tbl[key], key
end

---### [GS Extensions]
---Gets the keys of a table.
---@generic K
---@param tbl table<K, any>
---@return K[]
function table.keys(tbl)
  local keys = {}
  for key in pairs(tbl) do t_insert(keys, key) end
  return keys
end

---### [GS Extensions]
---Gets the values of a table.
---@generic V
---@param tbl table<any, V>
---@return V[]
function table.values(tbl)
  local values = {}
  for _, value in pairs(tbl) do t_insert(values, value) end
  return values
end

---### [GS Extensions]
---Gets the key-value pairs of a table.
---@generic K, V
---@param tbl table<K, V>
---@return {[1]: K, [2]: V}[]
function table.pairs(tbl)
  local pairs = {}
  for k, v in pairs(tbl) do t_insert(pairs, {k, v}) end
  return pairs
end

---### [GS Extensions]
---Reverses the order of the given sequential table.
---@param tbl any[]
function table.reverse(tbl)
  local len = #tbl
  local half = m_floor(len / 2)
  local rev
  for i = 1, half do
    rev = len - i + 1
    tbl[i], tbl[rev] = tbl[rev], tbl[i]
  end
end

---### [GS Extensions]
---Creates a copy of a sequential table in reverse order.
---@generic V
---@param tbl V[]
---@return V[]
function table.reversed(tbl)
  local rev = {}
  local len = #tbl
  for i = 1, len do rev[i] = tbl[len - i + 1] end
  return rev
end

---### [GS Extensions]
---Creates a set-like table out of the values of a sequential table.
---@generic V
---@param tbl V[]
---@return {[V]: true}
function table.toset(tbl)
  local ret = {}
  for _, v in ipairs(tbl) do ret[v] = true end

  return ret
end


return setmetatable(this, thismt)
