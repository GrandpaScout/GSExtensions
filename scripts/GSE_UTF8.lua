-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions UTF-8" <GSE_UTF8>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds some helpful global variables that can be used as shortcuts.

local ID = "GSE_UTF8"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Backports Lua 5.3's UTF-8 library.  
---**⚠ THIS IS A WIP, DO NOT ATTEMPT TO USE IT. ⚠**
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `utf8`
---  * `.charpattern`
---  * `.char()`
---  * `.codes()`
---  * `.codepoint()`
---  * `.len()`
---  * `.offset()`
---@class Lib.GS.Extensions.UTF8
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}


local m_floor = math.floor

local s_char = string.char

local table = table
local t_concat = table.concat
local t_insert = table.insert
local t_unpack = table.unpack


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---

local charpattern = "[\x00-\x7F\xC2-\xF4][\x80-\xBF]*"

---### [GS Extensions]
---An extension library that offers some utf8 functions.
---@class Lib.GS.Extensions.UTF8.Lib
local utf8 = {
  --- A pattern that matches exactly one UTF-8 byte sequence, assuming the string is valid UTF-8.
  charpattern = charpattern
}

-- TODO: Complete UTF8 extension

---comment
---@param ... integer
---@return string
function utf8.char(...)
  local input = {...}
  local output = {}
  for i, code in ipairs(input) do
    if code ~= code or m_floor(code) ~= code or code <= 0 or code >= 0x10FFFF then
      error("code " .. i .. " out of range", 2)
    end

    if code <= 0x7F then
      t_insert(output, s_char(code))
    elseif code <= 0x07FF then
      t_insert(output, s_char(
        m_floor(code * 0.015625) + 0xC0,
        (code % 0x40) + 0x80
      ))
    elseif code <= 0x010000 then
      t_insert(output, s_char(
        m_floor(code * 0.000244140625) + 0xE0,
        m_floor(code * 0.015625 % 0x40) + 0x80,
        (code % 0x40) + 0x80
      ))
    else
      t_insert(output, s_char(
        m_floor(code * 0.000003814697265625) + 0xF0,
        m_floor(code * 0.000244140625 % 0x40) + 0x80,
        m_floor(code * 0.015625 % 0x40) + 0x80,
        (code % 0x40) + 0x80
      ))
    end
  end

  return t_concat(output)
end

---comment
---@param str string
---@return fun(s: string): (position: integer, code: integer), string
function utf8.codes(str)
  local pos = 1
  return function(s)
    local cpos, fchar, cchar1, cchar2, cchar3 = s:match(
      "^()(.)([\x80-\xBF]?)([\x80-\xBF]?)([\x80-\xBF]?)",
      pos
    )
    ---@diagnostic disable-next-line: missing-return-value
    if not fchar then return nil end

    -- print(
    --   ("%d | \\x%02X \\x%02X \\x%02X \\x%02X")
    --   :format(cpos, fchar:byte() or 255, cchar1:byte() or 255, cchar2:byte() or 255, cchar3:byte() or 255)
    -- )


    local fbyte = fchar:byte()
    if fbyte <= 0x7F then
      if cchar1 ~= "" then
        error("invalid UTF-8 code at byte " .. cpos .. " (expected 0 continuation bytes)", 2)
      end
      pos = pos + 1
      return cpos, fbyte
    elseif fbyte <= 0xC1 then
      if fbyte <= 0xBF then
        error("invalid UTF-8 code at byte " .. cpos .. " (unexpected continuation byte)", 2)
      else
        error("invalid UTF-8 code at byte " .. cpos .. " (leading byte out of bounds)", 2)
      end
    elseif fbyte <= 0xDF then
      if cchar1 == "" or cchar2 ~= "" then
        error("invalid UTF-8 code at byte " .. cpos .. " (expected 1 continuation byte)", 2)
      end
      pos = pos + 2
      return cpos,
        (fbyte % 0x20) * 0x000040
        + (cchar1:byte() % 0x40)
    elseif fbyte <= 0xEF then
      local cbyte1 = cchar1:byte()
      if cchar2 == "" or cchar3 ~= "" then
        error("invalid UTF-8 code at byte " .. cpos .. " (expected 2 continuation bytes)", 2)
      elseif cbyte1 < 0xA0 then
        if fbyte == 0xE0 then
          error("invalid UTF-8 code at byte " .. cpos .. " (overlong encoding)", 2)
        end
      elseif fbyte == 0xED then
        error("invalid UTF-8 code at byte " .. cpos .. " (surrogates forbidden)", 2)
      end
      pos = pos + 3
      return cpos,
        (fbyte % 0x10) * 0x001000
        + (cchar1:byte() % 0x40) * 0x000040
        + (cchar2:byte() % 0x40)
    elseif fbyte <= 0xF4 then
      local cbyte1 = cchar1:byte()
      if cchar3 == "" then
        error("invalid UTF-8 code at byte " .. cpos .. " (expected 3 continuation bytes)", 2)
      elseif fbyte == 0xF0 and cbyte1 < 0x90 then
        error("invalid UTF-8 code at byte " .. cpos .. " (overlong encoding)", 2)
      elseif fbyte == 0xF4 and cbyte1 > 0x8F then
        error("invalid UTF-8 code at byte " .. cpos .. " (continuation byte 1 out of bounds)", 2)
      end
      pos = pos + 4
      return cpos,
        (fbyte % 0x08) * 0x040000
        + (cbyte1 % 0x40) * 0x001000
        + (cchar2:byte() % 0x40) * 0x000040
        + (cchar3:byte() % 0x40)
    else
      error("invalid UTF-8 code at byte " .. cpos .. " (leading byte out of bounds)", 2)
    end
  end, str
end

---comment
---@param str string
---@param i? integer
---@param j? integer
---@return integer ...
function utf8.codepoint(str, i, j)
  local output = {}
  local strlen = #str
  i = i and (i < 0 and strlen + i + 1 or i) or 1
  j = j and (j < 0 and strlen + j + 1 or j) or strlen
  if i > j then
    return
  elseif i <= 0 or i > strlen then
    error("bad argument #2 to 'codepoint' (out of range)")
  elseif j <= 0 or j > strlen then
    error("bad argument #3 to 'codepoint' (out of range)")
  end

  local fchar, cchar1, cchar2, cchar3, spos
  local epos = i
  while epos <= j do
    spos, fchar = str:match("^()(.)", epos)
    if not fchar then return t_unpack(output) end


    spos, fchar, cchar1, cchar2, cchar3, epos = str:match(
      "^()(.)([\x80-\xBF]?)([\x80-\xBF]?)([\x80-\xBF]?)()",
      epos
    )
    

    -- print(
    --   ("%d | \\x%02X \\x%02X \\x%02X \\x%02X")
    --   :format(cpos, fchar:byte() or 255, cchar1:byte() or 255, cchar2:byte() or 255, cchar3:byte() or 255)
    -- )


    local fbyte = fchar:byte()
    if fbyte <= 0x7F then
      t_insert(output, fbyte)
    elseif fbyte <= 0xC1 then
      if fbyte <= 0xBF then
        error("invalid UTF-8 code at byte " .. spos .. " (unexpected continuation byte)", 2)
      else
        error("invalid UTF-8 code at byte " .. spos .. " (leading byte out of bounds)", 2)
      end
    elseif fbyte <= 0xDF then
      if cchar1 == "" or cchar2 ~= "" then
        error("invalid UTF-8 code at byte " .. spos .. " (expected 1 continuation byte)", 2)
      end
      t_insert(output
        (fbyte % 0x20) * 0x000040
        + (cchar1:byte() % 0x40)
      )
    elseif fbyte <= 0xEF then
      cchar1, epos = str:match("^([\x80-\xBF])()", spos + 1)
      local cbyte1 = cchar1:byte()
      if not cchar1 then
        error("invalid UTF-8 code at byte " .. spos .. " (expected 2 continuation bytes)", 2)
      elseif cbyte1 < 0xA0 then
        if fbyte == 0xE0 then
          error("invalid UTF-8 code at byte " .. spos .. " (overlong encoding)", 2)
        end
      elseif fbyte == 0xED then
        error("invalid UTF-8 code at byte " .. spos .. " (surrogates forbidden)", 2)
      end
      t_insert(output,
        (fbyte % 0x10) * 0x001000
        + (cchar1:byte() % 0x40) * 0x000040
        + (cchar2:byte() % 0x40)
      )
    elseif fbyte <= 0xF4 then
      local cbyte1 = cchar1:byte()
      if cchar3 == "" then
        error("invalid UTF-8 code at byte " .. spos .. " (expected 3 continuation bytes)", 2)
      elseif fbyte == 0xF0 and cbyte1 < 0x90 then
        error("invalid UTF-8 code at byte " .. spos .. " (overlong encoding)", 2)
      elseif fbyte == 0xF4 and cbyte1 > 0x8F then
        error("invalid UTF-8 code at byte " .. spos .. " (continuation byte 1 out of bounds)", 2)
      end
      t_insert(output,
        (fbyte % 0x08) * 0x040000
        + (cbyte1 % 0x40) * 0x001000
        + (cchar2:byte() % 0x40) * 0x000040
        + (cchar3:byte() % 0x40)
      )
    else
      error("invalid UTF-8 code at byte " .. spos .. " (leading byte out of bounds)", 2)
    end
  end



  return t_unpack(output)
end

---comment
---@param str string
---@return integer? length
---@return integer? error_pos
function utf8.len(str)
  local len = 0
  local strlen = #str
  local spos, fchar, cchar1
  local epos = 1
  while epos <= strlen do
    spos, fchar = str:match("^()(.)", epos)
    if not fchar then return len end

    -- print(
    --   ("%d | \\x%02X \\x%02X \\x%02X \\x%02X")
    --   :format(cpos, fchar:byte() or 255, cchar1:byte() or 255, cchar2:byte() or 255, cchar3:byte() or 255)
    -- )


    local fbyte = fchar:byte()
    if fbyte > 0x7F then
      epos = spos + 1
    elseif fbyte <= 0xC1 then
      return nil, spos
    elseif fbyte <= 0xDF then
      cchar1, epos = str:match("^([\x80-\xBF])()", spos + 1)
      if not cchar1 then return nil, spos end
    elseif fbyte <= 0xEF then
      cchar1, epos = str:match("^([\x80-\xBF])[\x80-\xBF]()", spos + 1)
      if not cchar1
        or (fbyte == "0xE0" and cchar1:byte() < 0xA0)
      then
        return nil, spos
      end
    elseif fbyte <= 0xF4 then
      cchar1, epos = str:match("^([\x80-\xBF])[\x80-\xBF][\x80-\xBF]()", spos + 1)
      local cbyte1 = cchar1:byte()
      if not cchar1
        or (fbyte == 0xF0 and cbyte1 < 0x90)
        or (fbyte == 0xF4 and cbyte1 > 0x8F)
      then
        return nil, spos
      end
    else
      return nil, spos
    end

    len = len + 1
  end

  return len
end

---comment
---@param str string
---@param pos integer
---@param byte? integer
function utf8.offset(str, pos, byte)

end


error("WIP! Do not use!", 2)

return setmetatable(this, thismt)
