-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Strings" <GSE_StdString>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds functions to Lua's standard string library.

local ID = "GSE_StdString"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds functions to Lua's `string` library.  
---Most methods involve manipulating strings, but some also create human-readable file sizes, make string safe for use
---in lua patterns, and allow packing and unpacking number and string values into and out of a single string.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `string`
---  * `.startswith()`
---  * `.endswith()`
---  * `.split()`
---  * `.patternsafe()`
---  * `.filesize()`
---  * `.trim()`
---  * `.trimleft()`
---  * `.trimright()`
---  * `.pack()`
---  * `.unpack()`
---  * `.packsize()`
---@class Lib.GS.Extensions.StdString
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

local kb, mb, gb, tb, pb = 2^10, 2^20, 2^30, 2^40, 2^50
local ikb, imb, igb, itb, ipb = 100 / 2^10, 100 / 2^20, 100 / 2^30, 100 / 2^40, 100 / 2^50
local dkb, dmb, dgb, dtb, dpb = 1e3, 1e6, 1e9, 1e12, 1e15
local idkb, idmb, idgb, idtb, idpb = 0.1, 1e-4, 1e-7, 1e-10, 1e-13


---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---


---### [GS Extensions]
---Gets if a string starts with the given substring
---
---This function is not available in `<string>:method()` form due to Figura disallowing string metatable edits.
function string.startswith(str, substr)
  return str:sub(1, #substr) == substr
end

---### [GS Extensions]
---Gets if a string ends with the given substring
---
---This function is not available in `<string>:method()` form due to Figura disallowing string metatable edits.
function string.endswith(str, substr)
  return substr == "" or str:sub(-#substr) == substr
end

---### [GS Extensions]
---Splits a string with the given seperator.  
---If a seperator is not given, the string is split into single characters.
---
---This function is not available in `<string>:method()` form due to Figura disallowing string metatable edits.
---@param str string
---@param sep? string
---@param plain? boolean
---@return string[]
function string.split(str, sep, plain)
  local ret = {}
  if not sep or sep == "" then
    for i = 1, #str do
      ret[i] = str:sub(i, i)
    end
    return ret
  end

  local pos = 1
  -- Make sure the splitting doesn't take an infinte amount of time
  for i = 1, #str do
    local s, e = str:find(sep, pos, plain and true or false)
    if not s then break end
    ret[i] = str:sub(pos, s - 1)
    pos = e + 1
  end
  ret[#ret+1] = str:sub(pos)

  return ret
end

---### [GS Extensions]
---Returns a version of the given string that can be safely embedded in a pattern.
---
---This function is not available in `<string>:method()` form due to Figura disallowing string metatable edits.
---@param str string
---@return string
function string.patternsafe(str)
  return (str:gsub("([%[%]%(%)%.%+%-%*%?%^%$%%])", "%%%1"))
end

---### [GS Extensions]
---Returns a human-readable string for the given number of bytes.
---
---If `dec` is set, a kilobyte is 1000 bytes instead of 1024.
---@param bytes integer
---@param dec? boolean
---@return string
function string.filesize(bytes, dec)
  bytes = m_floor(tonumber(bytes))

  if bytes <= 0 then
    return "0 bytes"
  elseif dec then
    if bytes < dkb then
      return bytes .. " bytes"
    elseif bytes < dmb then
      return (m_floor(bytes * idkb + 0.5) * 0.01) .. " KB"
    elseif bytes < dgb then
      return (m_floor(bytes * idmb + 0.5) * 0.01) .. " MB"
    elseif bytes < dtb then
      return (m_floor(bytes * idgb + 0.5) * 0.01) .. " GB"
    elseif bytes < dpb then
      return (m_floor(bytes * idtb + 0.5) * 0.01) .. " TB"
    else
      return (m_floor(bytes * idpb + 0.5) * 0.01) .. " PB"
    end
  else
    if bytes < kb then
      return bytes .. " bytes"
    elseif bytes < mb then
      return (m_floor(bytes * ikb + 0.5) * 0.01) .. " KB"
    elseif bytes < gb then
      return (m_floor(bytes * imb + 0.5) * 0.01) .. " MB"
    elseif bytes < tb then
      return (m_floor(bytes * igb + 0.5) * 0.01) .. " GB"
    elseif bytes < pb then
      return (m_floor(bytes * itb + 0.5) * 0.01) .. " TB"
    else
      return (m_floor(bytes * ipb + 0.5) * 0.01) .. " PB"
    end
  end
end

---### [GS Extensions]
---Trims leading and trailing spaces from a string.
---
---This function is not available in `<string>:method()` form due to Figura disallowing string metatable edits.
function string.trim(str)
  return str:match("^%s*(.-)%s*$")
end

---### [GS Extensions]
---Trims leading spaces from a string.
---
---This function is not available in `<string>:method()` form due to Figura disallowing string metatable edits.
function string.trimleft(str)
  return str:match("^%s*(.+)$")
end

---### [GS Extensions]
---Trims trailing spaces from a string.
---
---This function is not available in `<string>:method()` form due to Figura disallowing string metatable edits.
function string.trimright(str)
  return str:match("^(.-)%s*$")
end


return setmetatable(this, thismt)
