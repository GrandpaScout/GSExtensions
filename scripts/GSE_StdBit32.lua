-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions StdBit32" <GSE_StdBit32>
---@version v1.1.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds more functions to Lua's standard bit32 library.

local ID = "GSE_StdBit32"
local VER = "1.1.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds functions to Lua's `bit32` library.  
---These functions include inverted versions of some bitwise functions and the ability to convert float/double bits to
---integer bits and back.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---### *Does not require GSECommon!*
---
---**<u>Contributes:</u>**
---* `bit32`
---  * `.bnand()`
---  * `.bnor()`
---  * `.bxnor()`
---  * `.clz()`
---  * `.clo()`
---  * `.tofloat()`
---  * `.todouble()`
---  * `.floatbits()`
---  * `.doublebits()`
---* `_ENV`
---  * `NOT`
---  * `AND`
---  * `OR`
---  * `XOR`
---  * `SHL`
---  * `SHR`
---  * `SHAR`
---  * `ROL`
---  * `ROR`
---  * `NAND`
---  * `NOR`
---  * `XNOR`
---@class Lib.GS.Extensions.StdLib
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

local stdbit32 = bit32
local b_bnot = stdbit32.bnot
local b_band = stdbit32.band
local b_bor = stdbit32.bor
local b_bxor = stdbit32.bxor
local b_rshift = stdbit32.rshift

local math = math
local m_huge = math.huge
local m_abs = math.abs
local m_floor = math.floor
local m_frexp = math.frexp
local m_ldexp = math.ldexp
local m_log = math.log


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---

-- LuaLS shenanigans
---@type table
local _G = _ENV
_G.NOT = b_bnot
_G.AND = b_band
_G.OR = b_bor
_G.XOR = b_bxor
_G.SHL = stdbit32.lshift
_G.SHR = stdbit32.rshift
_G.SHAR = stdbit32.arshift
_G.ROL = stdbit32.lrotate
_G.ROR = stdbit32.rrotate

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Alias of `bit32.bnot()`.
  ---@param x integer
  ---@return integer
  function NOT(x) end

  ---### [GS Extensions]
  ---Alias of `bit32.band()`.
  ---@param ... integer
  ---@return integer
  function AND(...) end

  ---### [GS Extensions]
  ---Alias of `bit32.bor()`.
  ---@param ... integer
  ---@return integer
  function OR(...) end

  ---### [GS Extensions]
  ---Alias of `bit32.bxor()`.
  ---@param ... integer
  ---@return integer
  function XOR(...) end

  ---### [GS Extensions]
  ---Alias of `bit32.lshift()`.
  ---@param x integer
  ---@param disp integer
  ---@return integer
  function SHL(x, disp) end

  ---### [GS Extensions]
  ---Alias of `bit32.rshift()`.
  ---@param x integer
  ---@param disp integer
  ---@return integer
  function SHR(x, disp) end

  ---### [GS Extensions]
  ---Alias of `bit32.arshift()`.
  ---@param x integer
  ---@param disp integer
  ---@return integer
  function SHAR(x, disp) end

  ---### [GS Extensions]
  ---Alias of `bit32.lrotate()`.
  ---@param x integer
  ---@param disp integer
  ---@return integer
  function ROL(x, disp) end

  ---### [GS Extensions]
  ---Alias of `bit32.rrotate()`.
  ---@param x integer
  ---@param disp integer
  ---@return integer
  function ROR(x, disp) end

  ---### [GS Extensions]
  ---Alias of `bit32.bnand()`.
  ---@param ... integer
  ---@return integer
  function NAND(...) end

  ---### [GS Extensions]
  ---Alias of `bit32.bnor()`.
  ---@param ... integer
  ---@return integer
  function NOR(...) end

  ---### [GS Extensions]
  ---Alias of `bit32.bxnor()`.
  ---@param ... integer
  ---@return integer
  function XNOR(...) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field


---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---##### Requires `.loadStdLib()`
---Returns the bitwise *nand* of its operands.
function bit32.bnand(...)
  return b_bnot(b_band(...))
end
_G.NAND = stdbit32.bnand

---### [GS Extensions]
---##### Requires `.loadStdLib()`
---Returns the bitwise *nor* of its operands.
function bit32.bnor(...)
  return b_bnot(b_bor(...))
end
_G.NOR = stdbit32.bnor

---### [GS Extensions]
---Returns the bitwise *exclusive nor* of its operands.
function bit32.bxnor(...)
  return b_bnot(b_bxor(...))
end
_G.XNOR = stdbit32.bxnor

---### [GS Extensions]
---Returns the amount of leading zeros in the given number.
---@param x integer
---@return integer
function bit32.clz(x)
  return 32 - m_floor(m_log(x % 0x100000000, 2))
end

---### [GS Extensions]
---Returns the amount of leading ones in the given number.
---@param x integer
---@return integer
function bit32.clo(x)
  return 32 - m_floor(m_log(b_bnot(x), 2))
end

---### [GSExtensions]
---Converts a single-precision float value into an integer containing the float's bits.
---@param x number
---@return integer bits
function bit32.floatbits(x)
  if x ~= x then return 0xFFC00000 end
  if x < _MINFLOAT then return 0 end

  local sign = x < 0 and 0x80000000 or 0
  if m_abs(x) > _MAXFLOAT then return 0x7F800000 + sign end

  local d = (x * 0.5) * (2 ^ 30)
  x = d - (d - x)

  local frac, exp = m_frexp(m_abs(x))

  return exp == -1022
    and (frac * 2^23 + sign)
    or ((frac * 2^24) % 0x800000 + ((exp + 0x7E) * 2^23) + sign)
end

---### [GSExtensions]
---Converts a double-precision number value into two integers containing the double's bits.
---@param x number
---@return integer high
---@return integer low
function bit32.doublebits(x)
  if x ~= x then return 0xFFF80000, 0 end
  if x == 0 then return 0, 0 end

  local sign = x < 0 and 0x80000000 or 0
  if m_abs(x) == m_huge then return 0x7FF00000 + sign, 0 end

  local frac, exp = m_frexp(m_abs(x))

  if exp == -1022 then
    local fracbits = frac * 2^52
    return b_rshift(fracbits, 32) + sign, fracbits % 0x100000000
  else
    local fracbits = (frac * 2^53) % 0x10000000000000
    return (b_rshift(fracbits, 32) + (exp + 0x3FE) * 2^20) + sign, fracbits % 0x100000000
  end
end

---### [GSExtensions]
---Converts the bits of an integer into the bits of a single-precision float value.
---@param bits integer
---@return number float
function bit32.tofloat(bits)
  bits = (bits or 0) % 0x100000000
  if bits == 0 then return 0 end

  local sign = b_rshift(bits, 31) == 0 and 1 or -1
  local expbits = b_rshift(bits, 23) % 0x100
  local fracbits = bits % 0x800000

  if expbits == 0xFF then
    if fracbits ~= 0 then return _NAN end
    return math.huge * sign
  end

  if expbits == 0 then
    return m_ldexp(fracbits * 2^-23, -126) * sign
  else
    return m_ldexp((fracbits + 0x800000) * 2^-24, expbits - 0x7E) * sign
  end
end

---### [GSExtensions]
---Converts the bits of two integers into the bits of a double-precision number value.
---@param high integer
---@param low integer
---@return number double
function bit32.todouble(high, low)
  high, low = (high or 0) % 0x100000000, (low or 0) % 0x100000000
  if high + low == 0 then return 0 end

  local sign = b_rshift(high, 31) == 0 and 1 or -1
  local expbits = b_rshift(high, 20) % 0x800
  if expbits == 0x7FF then
    if low ~= 0 or high % 0x100000 ~= 0 then return _NAN end
    return math.huge * sign
  end

  local fracbits = (high % 0x100000) * 2^32 + low

  if expbits == 0 then
    return m_ldexp(fracbits * 2^-52, -1022) * sign
  else
    return m_ldexp((fracbits + 0x10000000000000) * 2^-53, expbits - 0x3FE) * sign
  end
end


return setmetatable(this, thismt)
