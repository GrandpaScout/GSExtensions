-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Strings" <GSE_StdString>
---@version v1.1.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds functions to Lua's standard string library.

local ID = "GSE_StdString"
local VER = "1.1.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds functions to Lua's `string` library.  
---Most methods involve manipulating strings, but some also create human-readable file sizes, make string safe for use
---in lua patterns, and allow packing and unpacking number and string values into and out of a single string.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---### *Does not require GSECommon!*
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
local m_log = math.log

local fs_suffix = {[0]=
  " bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB", " RB", " QB",
  one_byte = " byte"
}


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

  plain = plain and true or false
  local pos = 1
  -- Make sure the splitting doesn't take an infinte amount of time
  for i = 1, #str do
    local s, e = str:find(sep, pos, plain)
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
    return "0" .. fs_suffix[0]
  elseif bytes == 1 then
    return "1" .. fs_suffix.one_byte
  else
    local base = dec and 1000 or 1024
    local mag = m_floor(m_log(bytes, base))

    if mag >= #fs_suffix then
      local maxmag = #fs_suffix
      return (m_floor(bytes * 100 / base^maxmag + 0.5) * 0.01) .. fs_suffix[maxmag]
    end

    local edge = dec and (999.9945 / 1000) or (1023.9945 / 1024)
    if bytes >= (base^(mag+1) * edge) then return "1" .. fs_suffix[mag + 1] end

    return (m_floor(bytes * 100 / base^mag + 0.5) * 0.01) .. fs_suffix[mag]
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
