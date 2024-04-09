-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Math" <GSE_StdMath>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds functions and constants to Lua's standard math library.

local ID = "GSE_StdMath"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds functions and constants to Lua's `math` library.  
---Some of the constants include `nan`, very tiny values, machine epsilon, Euler's number, and the minimum/maximum safe
---integers.  
---Some of the methods include getting parts of a number, checking if a number is an integer or finite, converting
---between numbers with different bit lengths, and rounding to the nearest float value.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `math`
---  * `.nan`
---  * `.qnan`
---  * `.tiny`
---  * `.subtiny`
---  * `.epsilon`
---  * `.maxinteger`
---  * `.mininteger`
---  * `.maxfloat`
---  * `.minfloat`
---  * `.e`
---  * `.tau`
---  * `.sqrt2`
---  * `.snap()`
---  * `.trunc()`
---  * `.frac()`
---  * `.isinteger()`
---  * `.issafeinteger()`
---  * `.isfinite()`
---  * `.isinfinite()`
---  * `.isnan()`
---  * `.tobyte()`
---  * `.toubyte()`
---  * `.toshort()`
---  * `.toushort()`
---  * `.toint()`
---  * `.touint()`
---  * `.tointn()`
---  * `.touintn()`
---  * `.fround()`
---@class Lib.GS.Extensions.StdMath
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

local m_huge = math.huge
local m_abs = math.abs
local m_floor = math.floor
local m_fmod = math.fmod
local m_modf = math.modf



---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---NaN, not a number.
math.nan = _NAN

---### [GS Extensions]
---qNaN, quiet not a number.
math.qnan = -_NAN

---### [GS Extensions]
---The smallest positive normal number that can be represented in Lua.
math.tiny = 2 ^ -1022

---### [GS Extensions]
---The smallest positive subnormal number that can be represented in Lua.
math.subtiny = 2 ^ -1074

---### [GS Extensions]
---The smallest positive number that can be added to `1` to get a different number.
math.epsilon = 2 ^ -52

---### [GS Extensions]
---The largest possible *safe* integer.
math.maxinteger = 2 ^ 53 - 1

---### [GS Extensions]
---The smallest possible *safe* integer.
math.mininteger = -2 ^ 53 + 1

---### [GS Extensions]
---The largest positive finite single-precision float value.
math.maxfloat = _MAXFLOAT

---### [GS Extensions]
---The smallest positive single-precision float value.
math.minfloat = _MINFLOAT

---### [GS Extensions]
---Euler's number.
math.e = math.exp(1)

---### [GS Extensions]
---The value of *τ*. (2*π*)
math.tau = math.pi * 2

---### [GS Extensions]
---The square root of 2.
math.sqrt2 = math.sqrt(2)

---### [GS Extensions]
---Snaps a number to a multiple of another number
---@param x number
---@param snap number
---@return number
function math.snap(x, snap)
  return m_floor(x / snap + 0.5) * snap
end

---### [GS Extensions]
---Rounds a number toward zero.
---
---If you want both the integral and fractional parts of a number, use `math.modf`.
---@param x number
---@return number
function math.trunc(x)
  return (m_modf(x))
end

---### [GS Extensions]
---Returns the fractional part of a number.
---
---If you want both the integral and fractional parts of a number, use `math.modf`.
---@param x number
---@return number
function math.frac(x)
  return m_fmod(x, 1)
end

---### [GS Extensions]
---Gets if a number is an integer
---@param x number
---@return boolean
function math.isinteger(x)
  return m_abs(x) ~= m_huge and m_floor(x) == x
end

---### [GS Extensions]
---Gets if a number is a safe integer
---@param x number
---@return boolean
function math.issafeinteger(x)
  return m_abs(x) <= (2 ^ 53 - 1) and m_floor(x) == x
end

---### [GS Extensions]
---Gets if a number is finite.
---@param x number
---@return boolean
function math.isfinite(x)
  return x == x and m_abs(x) < m_huge
end

---### [GS Extensions]
---Gets if a number is infinite.
---@param x number
---@return boolean
function math.isinfinite(x)
  return m_abs(x) == m_huge
end

---### [GS Extensions]
---Gets if a number is NaN.
---@param x number
---@return boolean
function math.isnan(x)
  return x ~= x
end

---### [GS Extensions]
---Converts a number to a signed byte.
---@param x number
---@return integer
function math.tobyte(x)
  return (m_floor(x) + 0x80) % 0x100 - 0x80
end

---### [GS Extensions]
---Converts a number to an unsigned byte.
---@param x number
---@return integer
function math.toubyte(x)
  return m_floor(x) % 0x100
end

---### [GS Extensions]
---Converts a number to a signed short.
---@param x number
---@return integer
function math.toshort(x)
  return (m_floor(x) + 0x8000) % 0x10000 - 0x8000
end

---### [GS Extensions]
---Converts a number to an unsigned short.
---@param x number
---@return integer
function math.toushort(x)
  return m_floor(x) % 0x10000
end

---### [GS Extensions]
---Converts a number to a signed integer.
---@param x number
---@return integer
function math.toint(x)
  return (m_floor(x) + 0x80000000) % 0x100000000 - 0x80000000
end

---### [GS Extensions]
---Converts a number to an unsigned integer.
---@param x number
---@return integer
function math.touint(x)
  return m_floor(x) % 0x100000000
end

---### [GS Extensions]
---Converts a number to a signed integer with the given number of bits.
---
---Valid numbers of bits are between 2 and 53.
---@param x number
---@param bits integer
---@return integer
function math.tointn(x, bits)
  if bits < 2 or bits >= 54 then
    error("invalid number of bits given (expected 2-53, got " .. bits .. ")", 2)
  end
  bits = m_floor(bits)
  local half = 2 ^ (bits - 1)
  return (m_floor(x) + half) % (2 ^ bits) - half
end

---### [GS Extensions]
---Converts a number to an unsigned integer with the given number of bits.
---
---Valid numbers of bits are between 1 and 53.
---@param x number
---@param bits integer
---@return integer
function math.touintn(x, bits)
  if bits < 1 or bits >= 54 then
    error("invalid number of bits given (expected 1-53, got " .. bits .. ")", 2)
  end
  return m_floor(x) % (2 ^ m_floor(bits))
end

---### [GS Extensions]
---Rounds a number to the nearest single-precision float.
---@param x number
---@return number
---@source https://stackoverflow.com/a/14285800 Minor change to make it follow `Math.fround()` better.
function math.fround(x)
  if x ~= x then return _NAN end
  if m_abs(x) < _MINFLOAT then return 0 end
  if m_abs(x) > _MAXFLOAT then return (x < 0 and -m_huge or m_huge) end

  local d = (x * 0.5) * 2^30
  return d - (d - x)
end


return setmetatable(this, thismt)
