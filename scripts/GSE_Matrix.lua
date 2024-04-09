-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Matrices" <GSE_Matrix>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds global functions for making matrices.

local ID = "GSE_Matrix"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds some global functions for creating matrices.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `_ENV`
---  * `mat()`
---  * `mat2()`
---  * `mat3()`
---  * `mat4()`
---@class Lib.GS.Extensions.Matrix
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}


local vectors = vectors
local vec2 = vectors.vec2
local vec3 = vectors.vec3
local vec4 = vectors.vec4

local _V4_ZERO = vec2()
local _V3_ZERO = vec3()
local _V2_ZERO = vec4()

local matrices = matrices
local mat2 = matrices.mat2
local mat3 = matrices.mat3
local mat4 = matrices.mat4


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Creates an identity matrix of the given size.
  ---@param size 2|3|4
  ---@return Matrix2 | Matrix3 | Matrix4
  ---@diagnostic disable-next-line: lowercase-global
  function mat(size) end

  ---### [GS Extensions]
  ---Creates a Matrix2 out of 2 Vector2s.
  ---@param c1 Vector2
  ---@param c2 Vector2
  ---@return Matrix2
  ---@diagnostic disable-next-line: lowercase-global
  function mat(c1, c2) end

  ---### [GS Extensions]
  ---Creates a Matrix3 out of 3 Vector3s.
  ---@param c1 Vector3
  ---@param c2 Vector3
  ---@param c3 Vector3
  ---@return Matrix3
  ---@diagnostic disable-next-line: lowercase-global
  function mat(c1, c2, c3) end

  ---### [GS Extensions]
  ---Creates a Matrix4 out of 4 Vector4s.
  ---@param c1 Vector4
  ---@param c2 Vector4
  ---@param c3 Vector4
  ---@param c4 Vector4
  ---@return Matrix4
  ---@diagnostic disable-next-line: lowercase-global
  function mat(c1, c2, c3, c4) end

  ---### [GS Extensions]
  ---Creates a Matrix2 out of 4 numbers.
  ---@param v11 number
  ---@param v12 number
  ---@param v21 number
  ---@param v22 number
  ---@return Matrix2
  ---@diagnostic disable-next-line: lowercase-global
  function mat(v11, v12, v21, v22) end

  ---### [GS Extensions]
  ---Creates a Matrix3 out of 9 numbers.
  ---@param v11 number
  ---@param v12 number
  ---@param v13 number
  ---@param v21 number
  ---@param v22 number
  ---@param v23 number
  ---@param v31 number
  ---@param v32 number
  ---@param v33 number
  ---@return Matrix3
  ---@diagnostic disable-next-line: lowercase-global
  function mat(v11, v12, v13, v21, v22, v23, v31, v32, v33) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

---### [GS Extensions]
---Creates a Matrix4 out of 16 numbers.
---@param v11 number
---@param v12 number
---@param v13 number
---@param v14 number
---@param v21 number
---@param v22 number
---@param v23 number
---@param v24 number
---@param v31 number
---@param v32 number
---@param v33 number
---@param v34 number
---@param v41 number
---@param v42 number
---@param v43 number
---@param v44 number
---@return Matrix4
---@diagnostic disable-next-line: lowercase-global
function mat(
  v11, v12, v13, v14,
  v21, v22, v23, v24,
  v31, v32, v33, v34,
  v41, v42, v43, v44
)
  ---@diagnostic disable: return-type-mismatch
  if v32 then -- Matrix4
    return mat4(
      vec4(v11, v21, v31, v41),
      vec4(v12, v22, v32, v42),
      vec4(v13, v23, v33, v43),
      vec4(v14, v24, v34, v44)
    )
  elseif v21 then -- Matrix3
    return mat3(
      vec3(v11, v14, v23),
      vec3(v12, v21, v24),
      vec3(v13, v22, v31)
    )
  end
  -- Shit's about to get complex
  local at = type(v11)
  local bt = type(v12)
  local ct = type(v13)
  local dt = type(v14)

  if bt == "number" or ct == "number" or dt == "number" then -- Matrix2
    return mat2(
      vec2(v11, v13),
      vec2(v12, v14)
    )
  elseif at == "Vector4" or bt == "Vector4" or ct == "Vector4" or dt == "Vector4" then -- Matrix4
    ---@cast v11 Vector4
    return mat4(v11 or _V4_ZERO, v12 or _V4_ZERO, v13 or _V4_ZERO, v14 or _V4_ZERO)
  elseif at == "Vector3" or bt == "Vector3" or ct == "Vector3" then -- Matrix3
    ---@cast v11 Vector3
    return mat3(v11 or _V3_ZERO, v12 or _V3_ZERO, v13 or _V3_ZERO)
  elseif at == "Vector2" or bt == "Vector2" then -- Matrix2
    ---@cast v11 Vector2
    return mat2(v11 or _V2_ZERO, v12 or _V2_ZERO)
  elseif v11 >= 2 and v11 <= 4 then -- Identity matrix
    return ((v11 == 4 and mat4) or (v11 == 3 and mat3) or (v11 == 2 and mat2))()
  end
  error("could not find matching matrix for the given values", 2)
  ---@diagnostic enable: return-type-mismatch
end


-- LuaLS shenanigans
---@type table
local _G = _ENV
_G.mat2 = mat2
_G.mat3 = mat3
_G.mat4 = mat4

if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---Alias of `matrices.mat2()`.
  ---@return Matrix2
  ---@diagnostic disable-next-line: lowercase-global
  function mat2() end

  ---### [GS Extensions]
  ---Alias of `matrices.mat2()`.
  ---@param col1 Vector2
  ---@param col2 Vector2
  ---@return Matrix2
  ---@diagnostic disable-next-line: lowercase-global
  function mat2(col1, col2) end

  ---### [GS Extensions]
  ---Alias of `matrices.mat3()`.
  ---@return Matrix3
  ---@diagnostic disable-next-line: lowercase-global
  function mat3() end

  ---### [GS Extensions]
  ---Alias of `matrices.mat3()`.
  ---@param col1 Vector3
  ---@param col2 Vector3
  ---@param col3 Vector3
  ---@return Matrix3
  ---@diagnostic disable-next-line: lowercase-global
  function mat3(col1, col2, col3) end

  ---### [GS Extensions]
  ---Alias of `matrices.mat4()`.
  ---@return Matrix4
  ---@diagnostic disable-next-line: lowercase-global
  function mat4() end

  ---### [GS Extensions]
  ---Alias of `matrices.mat4()`.
  ---@param col1 Vector4
  ---@param col2 Vector4
  ---@param col3 Vector4
  ---@param col4 Vector4
  ---@return Matrix4
  ---@diagnostic disable-next-line: lowercase-global
  function mat4(col1, col2, col3, col4) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field


return setmetatable(this, thismt)
