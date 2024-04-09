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


local _NAN = 0 / 0
local _MAXFLOAT = 340282346638528859811704183484516925440
local _MINFLOAT = 2 ^ -149

local b_rshift = bit32.rshift

local math = math
local m_huge = math.huge
local m_abs = math.abs
local m_floor = math.floor
local m_frexp = math.frexp
local m_ldexp = math.ldexp

local table = table
local t_concat = table.concat
local t_insert = table.insert
local t_unpack = table.unpack

local s_char = string.char

local kb, mb, gb, tb, pb = 1024, 1048576, 1073741824, 1099511627776, 1125899906842624
local ikb, imb, igb, itb, ipb = 100 / kb, 100 / mb, 100 / gb, 100 / tb, 100 / pb
local dkb, dmb, dgb, dtb, dpb = 1000, 1000000, 1000000000, 1000000000000, 1000000000000000
local idkb, idmb, idgb, idtb, idpb = 100 / dkb, 100 / dmb, 100 / dgb, 100 / dtb, 100 / dpb


---==================================================================================================================---
---====  UTILITY  ===================================================================================================---
---==================================================================================================================---

local pack_fmt = {
  b = function(x)
    if m_floor(x) ~= x or m_abs(x) == m_huge then
      return nil, "number has no integer representation"
    elseif x > 0x7F or x < -0x80 then
      return nil, "integer overflow"
    else
      return s_char(x % 0x100)
    end
  end,
  B = function(x)
    if m_floor(x) ~= x or m_abs(x) == m_huge then
      return nil, "number has no integer representation"
    elseif x > 0xFF then
      return nil, "integer overflow"
    else
      return s_char(x)
    end
  end,
  h = function(x)
    if m_floor(x) ~= x or m_abs(x) == m_huge then
      return nil, "number has no integer representation"
    elseif x > 0x7FFF or x < -0x8000 then
      return nil, "integer overflow"
    else
      x = x % 0x10000
      return s_char(x % 0x100, b_rshift(x, 8))
    end
  end,
  H = function(x)
    if m_floor(x) ~= x or m_abs(x) == m_huge then
      return nil, "number has no integer representation"
    elseif x > 0xFFFF then
      return nil, "integer overflow"
    else
      return s_char(x % 0x100, b_rshift(x, 8))
    end
  end,
  i = function(x, n)
    if not n then
      n = 4
    elseif n < 1 or n > 4 then
      return nil, "integral size (" .. n .. ") out of limits [1,4]", 1
    end

    if m_floor(x) ~= x or m_abs(x) == m_huge then
      return nil, "number has no integer representation"
    elseif x > (2 ^ (n * 8 - 1) - 1) or x < -2 ^ (n * 8 - 1) then
      return nil, "integer overflow"
    else
      x = x % (2 ^ (n * 8))

      local bytes = {}
      for i = 1, n do
        bytes[i] = x % 0x100
        x = b_rshift(x, 8)
      end

      return s_char(t_unpack(bytes))
    end
  end,
  I = function(x, n)
    if not n then
      n = 4
    elseif n < 1 or n > 4 then
      return nil, "integral size (" .. n .. ") out of limits [1,4]", 1
    end

    if m_floor(x) ~= x or m_abs(x) == m_huge then
      return nil, "number has no integer representation"
    elseif x > (2 ^ (n * 8) - 1) then
      return nil, "integer overflow"
    else
      local bytes = {}
      for i = 1, n do
        bytes[i] = x % 0x100
        x = b_rshift(x, 8)
      end

      return s_char(t_unpack(bytes))
    end
  end,
  f = function(x)
    if x ~= x then return "\x00\x00\xC0\xFF" end
    if m_abs(x) > _MAXFLOAT then return (x < 0 and "\x00\x00\x80\xFF" or "\x00\x00\x80\x7F") end
    if m_abs(x) < _MINFLOAT then return "\x00\x00\x00\x00" end

    local d = (x * 0.5) * (2 ^ 30)
    x = d - (d - x)

    local sign = x < 0 and 0x80000000 or 0
    local frac, exp = m_frexp(m_abs(x))

    local bits = exp == -1022
      and (frac * 2^23 + sign)
      or ((frac * 2^24) % 0x800000 + ((exp + 0x7E) * 2^23) + sign)

    return s_char(
      bits % 100, b_rshift(bits, 8) % 0x100,
      b_rshift(bits, 16) % 0x100, b_rshift(bits, 24) % 0x100
    )
  end,
  d = function(x)
    if x ~= x then return "\x00\x00\x00\x00\x00\x00\xF8\xFF" end
    if m_abs(x) >= math.huge then
      return (x < 0 and "\x00\x00\x00\x00\x00\x00\xF0\xFF" or "\x00\x00\x00\x00\x00\x00\xF0\x7F")
    end
    if x == 0 then return "\x00\x00\x00\x00\x00\x00\x00\x00" end

    local sign = x < 0 and 0x80000000 or 0
    local frac, exp = m_frexp(m_abs(x))

    local fracbits, high, low
    if exp == -1022 then
      fracbits = frac * 2^52
      high = b_rshift(fracbits, 32) + sign
    else
      fracbits = (frac * 2^53) % 0x10000000000000
      high = (b_rshift(fracbits, 32) + (exp + 0x3FE) * 2^20) + sign
    end

    low = fracbits % 0x100000000
    return s_char(
      low % 100, b_rshift(low, 8) % 0x100,
      b_rshift(low, 16) % 0x100, b_rshift(low, 24) % 0x100,
      high % 100, b_rshift(high, 8) % 0x100,
      b_rshift(high, 16) % 0x100, b_rshift(high, 24) % 0x100
    )
  end,
  c = function(x, n)
    if not n then
      return nil, "missing size for format option 'c'", 1
    elseif n < 0 or n > 2097152 then
      return nil, "string size (" .. n .. ") out of limits [0,2097152]", 1
    elseif #x > n then
      return nil, "string longer than given size"
    else
      return x .. ("\x00"):rep(n - #x)
    end
  end,
  z = function(x)
    if x:match("\x00") then
      return nil, "string contains zeros"
    else
      return x .. "\x00"
    end
  end,
  s = function(x, n)
    if not n then
      n = 4
    elseif n < 1 or n > 4 then
      return nil, "integral size (" .. n .. ") out of limits [1,4]", 1
    end

    if #x > (2 ^ (n * 8) - 1) then
      return nil, "string length does not fit in given size"
    else
      local len = #x
      local bytes = {}
      for i = 1, n do
        bytes[i] = len % 0x100
        len = b_rshift(len, 8) % 0x100
      end

      return s_char(t_unpack(bytes)) .. x
    end
  end
}
pack_fmt.n = pack_fmt.d

local unpack_fmt = {
  b = function(str, pos)
    return (str:byte(pos) + 0x80) % 0x100 - 0x80, pos + 1
  end,
  B = function(str, pos)
    return str:byte(pos), pos + 1
  end,
  h = function(str, pos, rev)
    local low, high = str:byte(pos, pos + 1)
    if not high then return nil, nil, "data string too short" end
    if rev then low, high = high, low end
    return ((high * (2 ^ 8) + low) + 0x8000) % 0x10000 - 0x8000, pos + 2
  end,
  H = function(str, pos, rev)
    local low, high = str:byte(pos, pos + 1)
    if not high then return nil, nil, "data string too short" end
    if rev then low, high = high, low end
    return high * (2 ^ 8) + low, pos + 2
  end,
  i = function(str, pos, n, rev)
    if not n then
      n = 4
    elseif n < 1 or n > 4 then
      return nil, nil, "integral size (" .. n .. ") out of limits [1,4]", 1
    end

    local bytes = str:sub(pos, pos + n - 1)
    if #bytes ~= n then return nil, nil, "data string too short" end
    if not rev then bytes = bytes:reverse() end

    local value = 0
    for i = 1, n do value = value * (2 ^ 8) + bytes:byte(i) end

    local half = 2 ^ (n * 8 - 1)
    return (value + half) % (2 ^ (n * 8)) - half, pos + n
  end,
  I = function(str, pos, n, rev)
    if not n then
      n = 4
    elseif n < 1 or n > 4 then
      return nil, nil, "integral size (" .. n .. ") out of limits [1,4]", 1
    end

    local bytes = str:sub(pos, pos + n - 1)
    if #bytes ~= n then return nil, nil, "data string too short" end
    if not rev then bytes = bytes:reverse() end

    local value = 0
    for i = 1, n do value = value * (2 ^ 8) + bytes:byte(i) end

    return value, pos + n
  end,
  f = function(str, pos, rev)
    local bytes = str:sub(pos, pos + 3)
    if #bytes < 4 then return nil, nil, "data string too short" end
    if bytes == "\x00\x00\x00\x00" then return 0, pos + 4 end
    if rev then bytes = bytes:reverse() end

    if bytes == "\x00\x00\x80\x7F" then
      return m_huge, pos + 8
    elseif bytes == "\x00\x00\x80\xFF" then
      return -m_huge, pos + 8
    elseif bytes:match("..[\x81-\xFF][\x7F\xFF]") then
      return _NAN, pos + 8
    end

    local b1, b2, b3, b4 = bytes:byte(1, 4)
    local bits = b4 * (2 ^ 24) + b3 * (2 ^ 16) + b2 * (2 ^ 8) + b1

    local sign = b_rshift(bits, 31) == 0 and 1 or -1
    local expbits = b_rshift(bits, 23) % 0x100

    if expbits == 0 then
      return m_ldexp((bits % 0x800000) * 2^-23, -126) * sign, pos + 4
    else
      return m_ldexp(((bits % 0x800000) + 0x800000) * 2^-24, expbits - 0x7E) * sign, pos + 4
    end
  end,
  d = function(str, pos, rev)
    local bytes = str:sub(pos, pos + 7)
    if #bytes < 8 then return nil, nil, "data string too short" end
    if bytes == "\x00\x00\x00\x00\x00\x00\x00\x00" then return 0, pos + 8 end
    if rev then bytes = bytes:reverse() end

    if bytes == "\x00\x00\x00\x00\x00\x00\xF0\x7F" then
      return m_huge, pos + 8
    elseif bytes == "\x00\x00\x00\x00\x00\x00\xF0\xFF" then
      return -m_huge, pos + 8
    elseif bytes:match("......[\xF1-\xFF][\x7F\xFF]") then
      return _NAN, pos + 8
    end

    local l1, l2, l3, l4, h1, h2, h3, h4 = bytes:byte(1, 8)
    local low = l4 * (2 ^ 24) + l3 * (2 ^ 16) + l2 * (2 ^ 8) + l1
    local high = h4 * (2 ^ 24) + h3 * (2 ^ 16) + h2 * (2 ^ 8) + h1

    local sign = b_rshift(high, 31) == 0 and 1 or -1
    local expbits = b_rshift(high, 20) % 0x800

    if expbits == 0 then
      return m_ldexp(((high % 0x100000) * 2^32 + low) * 2^-52, -1022) * sign
    else
      return m_ldexp((((high % 0x100000) * 2^32 + low) + 0x10000000000000) * 2^-53, expbits - 0x3FE) * sign
    end
  end,
  c = function(str, pos, n, _)
    if not n then
      return nil, nil, "missing size for format option 'c'", 1
    elseif n < 0 or n > 2097152 then
      return nil, "string size (" .. n .. ") out of limits [0,2097152]", 1
    end

    local data = str:sub(pos, pos + n - 1)
    if #data < n then return nil, nil, "data string too short" end

    return data, pos + n
  end,
  z = function(str, pos, _)
    local data = str:match("^[^\x00]*\x00?", pos)
    return data:gsub("\x00$", ""), pos + #data
  end,
  s = function(str, pos, n, rev)
    if not n then
      n = 4
    elseif n < 1 or n > 4 then
      return nil, nil, "integral size (" .. n .. ") out of limits [1,4]", 1
    end

    local sizebytes = str:sub(pos, pos + n - 1)
    if #sizebytes ~= n then return nil, nil, "data string too short" end
    if not rev then sizebytes = sizebytes:reverse() end

    local size = 0
    for i = 1, n do size = size * (2 ^ 8) + sizebytes:byte(i) end

    local data = str:sub(pos + n, pos + n + size - 1)
    if #data < size then return nil, nil, "data string too short" end

    return data
  end
}
unpack_fmt.n = unpack_fmt.d

local packsize_fmt = {
  b = 1, B = 1, h = 2, H = 2, f = 4, d = 8, n = 8,
  i = function(n)
    if n and n < 1 or n > 4 then
      return nil, "integral size (" .. n .. ") out of limits [1,4]"
    else
      return n
    end
  end,
  c = function(n)
    if not n then
      return nil, "missing size for format option 'c'"
    elseif n < 0 or n > 2097152 then
      return nil, "string size (" .. n .. ") out of limits [0,2097152]"
    else
      return n
    end
  end
}
packsize_fmt.I = packsize_fmt.i


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

---### [GS Extensions]
---Returns a binary string containing the values `v1`, `v2`, etc. packed (that is, serialized in binary form) according
---to the format string `fmt`. (see [§6.4.2](command:extension.lua.doc?["en-us/53/manual.html/6.4.2"]))
---
---The following format codes are changed:
---* **`=`:** is an alias of `<`
---* **`i[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---* **`I[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---* **`n`:** is an alias of `d`
---* **`cn`:** n is explicitly limited to 0-2097152
---* **`s[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---
---The following format codes do not exist due to their types not existing in LuaJ 5.2:
---* **`l`:** signed `long`
---* **`L`:** unsigned `long`
---* **`j`:** signed `lua_Integer`
---* **`J`:** unsigned `lua_Integer`
---* **`T`:** `size_t`
---
---The following format codes are unsupported:
---* **`![n]`**
---* **`Xop`**
---
---[View documents](command:extension.lua.doc?["en-us/53/manual.html/pdf-string.pack"])
---@param fmt string
---@param ... any
---@return string binary
function string.pack(fmt, ...)
  if fmt == "" then return "" end

  local reverse = false
  local values = {...}

  local strs = {}

  local fmtlen = #fmt
  local pos = 1
  local opt, size, str, err, erri
  local i = 1
  while pos <= fmtlen do
    opt, pos = fmt:match("^(.)()", pos)

    if opt == "x" then
      t_insert(strs, "\x00")
    elseif opt:match("[<=>]") then
      reverse = opt == ">"
    elseif opt:match("[!X]") then
      error("bad argument #1 to 'pack' (unsupported format option '" .. opt .. "')", 2)
    elseif opt ~= " " then
      if opt:match("^[iIcs]$") then
        size, pos = fmt:match("^(%d*)()", pos)
        str, err, erri = pack_fmt[opt](values[i], tonumber(size))
      elseif opt:match("^[bBhHfdnz]$") then
        str, err, erri = pack_fmt[opt](values[i])
      else
        error("bad argument #1 to 'pack' (invalid format option '" .. opt .. "')", 2)
      end

      if not str then error("bad argument #" .. (erri or i + 1) .. " to 'pack' (" .. err .. ")", 2) end
      i = i + 1

      t_insert(strs, reverse and str:reverse() or str)
    end
  end

  return t_concat(strs)
end

---Returns the values packed in string according to the format string `fmt` (see [§6.4.2](command:extension.lua.doc?["en-us/53/manual.html/6.4.2"])) .
---
---[View documents](command:extension.lua.doc?["en-us/53/manual.html/pdf-string.unpack"])
---
---The following format codes are changed:
---* **`=`:** is an alias of `<`
---* **`i[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---* **`I[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---* **`n`:** is an alias of `d`
---* **`cn`:** n is explicitly limited to 0-2097152
---* **`s[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---
---The following format codes do not exist due to their types not existing in LuaJ 5.2:
---* **`l`:** signed `long`
---* **`L`:** unsigned `long`
---* **`j`:** signed `lua_Integer`
---* **`J`:** unsigned `lua_Integer`
---* **`T`:** `size_t`
---
---The following format codes are unsupported:
---* **`![n]`**
---* **`Xop`**
---
---[View documents](command:extension.lua.doc?["en-us/53/manual.html/pdf-string.pack"])
---@param fmt string
---@param str string
---@param offset? integer
---@return any ...
---@return integer offset
---@nodiscard
function string.unpack(fmt, str, offset)
  ---@diagnostic disable-next-line: missing-return-value
  if fmt == "" then return 1 end

  local reverse = false
  local values = {}

  local fmtlen = #fmt
  local opt, size, value, err, erri
  local pos = 1
  local i = offset or 1
  while pos <= fmtlen do
    opt, pos = fmt:match("^(.)()", pos)

    if opt == "x" then
      i = i + 1
    elseif opt:match("[<=>]") then
      reverse = opt == ">"
    elseif opt:match("[!X]") then
      error("bad argument #1 to 'unpack' (unsupported format option '" .. opt .. "')", 2)
    elseif opt ~= " " then
      if opt:match("[iIcs]") then
        size, pos = fmt:match("^(%d*)()", pos)
        value, i, err, erri = unpack_fmt[opt](str, i, tonumber(size), reverse)
      elseif opt:match("[bBhHfdnz]") then
        value, i, err, erri = unpack_fmt[opt](str, i, reverse)
      else
        error("bad argument #1 to 'unpack' (invalid format option '" .. opt .. "')", 2)
      end

      if not value then error("bad argument #" .. (erri or 2) .. " to 'unpack' (" .. err .. ")", 2) end

      t_insert(values, value)
    end
  end

  t_insert(values, i)

  return t_unpack(values)
end

---### [GSExtensions]
---Returns the size of a string resulting from `string.pack` with the given format string `fmt`. (see
---[§6.4.2](command:extension.lua.doc?["en-us/53/manual.html/6.4.2"]))
---
---The following format codes are changed:
---* **`i[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---* **`I[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---* **`n`:** is an alias of `d`
---* **`cn`:** n is explicitly limited to 0-2097152
---* **`s[n]`:** n is limited to 1-4, n defaults to 4 instead of `size_t`
---
---The following format codes do not exist due to their types not existing in LuaJ 5.2:
---* **`l`:** signed `long`
---* **`L`:** unsigned `long`
---* **`j`:** signed `lua_Integer`
---* **`J`:** unsigned `lua_Integer`
---* **`T`:** `size_t`
---
---The following format codes are unsupported:
---* **`![n]`**
---* **`Xop`**
---
---[View documents](command:extension.lua.doc?["en-us/53/manual.html/pdf-string.packsize"])
---@param fmt string
---@return integer
function string.packsize(fmt)
  if fmt == "" then return 0 end

  local len = 0

  local fmtlen = #fmt
  local opt, size, err
  local pos = 1
  while pos <= fmtlen do
    opt, pos = fmt:match("^(.)()", pos)

    if not opt:match("[<=> ]") then
      if opt:match("[!X]") then
        error("bad argument #1 to 'packsize' (unsupported format option '" .. opt .. "')", 2)
      elseif opt:match("[sz]") then
        error("bad argument #1 to 'packsize' (variable-length format)", 2)
      elseif opt:match("[iIc]") then
        size, pos = fmt:match("^(%d*)()", pos)
        size, err = packsize_fmt[opt](size)
      elseif opt:match("[bBhHfdn]") then
        size = packsize_fmt[opt]
      end

      if not size then error("bad argument #1 to 'packsize' (" .. err .. ")", 2) end

      len = len + size
    end
  end

  return len
end


return setmetatable(this, thismt)
