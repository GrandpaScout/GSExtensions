-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Colors" <GSE_Color>
---@version v1.0.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds a new library for handling colors.

local ID = "GSE_Color"
local VER = "1.0.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds a color library for getting and handling colors.
---Most functions in this library use more common number ranges. (0-255 instead of 0-1)
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---**<u>Contributes:</u>**
---* `colors`
---  * `.hueShift()`
---  * `.cssColor()`
---  * `.rainbow()`
---* `_ENV`
---  * `color()`
---  * `hsv()`
---  * `COLOR`
---    * *129 Items*
---@class Lib.GS.Extensions.Color
local this = {}
local thismt = {
  __type = ID,
  __metatable = false,
  __index = {
    _ID = ID,
    _VERSION = VER
  }
}


local m_clamp = math.clamp

local c_coldiv = 1 / 255
local c_huediv, c_satdiv = 1 / 360, 1 / 100

local vec3 = vectors.vec3
local _VEC_ZERO = vec3()
local _VEC_ONE = vec3(1, 1, 1)
local v_icol = vectors.intToRGB

local frameTime = client.getFrameTime


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---


if false then ---@diagnostic disable: unused-local, missing-return, duplicate-set-field
  ---### [GS Extensions]
  ---##### Requires `.loadColor()`
  ---Generates a color vector out of numbers `0-255`.
  ---@param r? number
  ---@param g? number
  ---@param b? number
  ---@return Vector3 color
  ---@diagnostic disable-next-line: lowercase-global
  function color(r, g, b) end

  ---### [GS Extensions]
  ---##### Requires `.loadColor()`
  ---Generates a color vector out of a hue of `0-360` and saturation and value of `0-100`.
  ---@param h? number
  ---@param s? number
  ---@param v? number
  ---@return Vector3 color
  ---@diagnostic disable-next-line: lowercase-global
  function hsv(h, s, v) end
end ---@diagnostic enable: unused-local, missing-return, duplicate-set-field

---### [GS Extensions]
---Generates a color vector out of numbers `0-255`.
---@param r? number
---@param g? number
---@param b? number
---@param a number
---@return Vector4 color
---@diagnostic disable-next-line: lowercase-global
function color(r, g, b, a)
  ---@diagnostic disable: return-type-mismatch
  if r and not (g or b or a) then
    local rt = type(r)
    if rt == "number" then
      return vectors.intToRGB(r)
    elseif rt == "string" then
      return vectors.hexToRGB(r)
    end
  end
  r = m_clamp(r or 0, 0, 255)
  g = m_clamp(g or 0, 0, 255)
  b = m_clamp(b or 0, 0, 255)

  if a then
    a = m_clamp(a, 0, 255)
    return vec(r * c_coldiv, g * c_coldiv, b * c_coldiv, a * c_coldiv)
  else
    return vec(r * c_coldiv, g * c_coldiv, b * c_coldiv)
  end
  ---@diagnostic enable: return-type-mismatch
end

---### [GS Extensions]
---##### Requires `.loadColor()`
---Generates a color vector out of a hue of `0-360`, saturation and value of `0-100`, and alpha of `0-255`.
---@param h? number
---@param s? number
---@param v? number
---@param a number
---@return Vector4 color
---@diagnostic disable-next-line: lowercase-global
function hsv(h, s, v, a)
  ---@diagnostic disable: return-type-mismatch
  local ret = vectors.hsvToRGB(
    m_clamp(h or 0, 0, 360) * c_huediv,
    m_clamp(s or 0, 0, 100) * c_satdiv,
    m_clamp(v or 0, 0, 100) * c_satdiv
  )
  if a then return ret:augmented(m_clamp(a, 0, 255) * c_coldiv) end
  return ret
  ---@diagnostic enable: return-type-mismatch
end

---### [GS Extensions]
---Contains preset colors for ease of access.
---
---Categories include:
---* `BRIGHT_`: Bright colors. While `WHITE` doesn't have this prefix, it is included anyways.
---* `MEDIUM_`: Medium brightness colors.
---* `DIM_`: Darker colors.
---* `DARK_`: Very dark colors. While `BLACK` doesn't have this prefix, it is included anyways.
---* `MC_`: Minecraft's default chat colors.
---* `BE_`: Chat colors exclusive to Bedrock Edition.
---* `CC_`: Computercraft's default terminal colors.
---* `VSC_`: Text colors of VSCode's Dark theme.
---* `SM_`: Source console text colors.
---* `FIG_`: Base Figura colors or colors of Figura assets.
---* `USR_`: Colors of well-known Figura users. Want your color in this category? Ask GrandpaScout.
COLOR = {
  ---### `#FFFFFF`
  WHITE = v_icol(0xFFFFFF),

  ---### `#CFCFCF`
  BRIGHT_GRAY = v_icol(0xCFCFCF),
  ---### `#FF0000`
  BRIGHT_RED = v_icol(0xFF0000),
  ---### `#FF7F00`
  BRIGHT_ORANGE = v_icol(0xFF7F00),
  ---### `#FFFF00`
  BRIGHT_YELLOW = v_icol(0xFFFF00),
  ---### `#7FFF00`
  BRIGHT_LIME = v_icol(0x7FFF00),
  ---### `#00FF00`
  BRIGHT_GREEN = v_icol(0x00FF00),
  ---### `#00FF7F`
  BRIGHT_TEAL = v_icol(0x00FF7F),
  ---### `#00FFFF`
  BRIGHT_AQUA = v_icol(0x00FFFF),
  ---### `#007FFF`
  BRIGHT_SKYBLUE = v_icol(0x007FFF),
  ---### `#0000FF`
  BRIGHT_BLUE = v_icol(0x0000FF),
  ---### `#7F00FF`
  BRIGHT_PURPLE = v_icol(0x7F00FF),
  ---### `#FF00FF`
  BRIGHT_MAGENTA = v_icol(0xFF00FF),
  ---### `#FF007F`
  BRIGHT_HOTPINK = v_icol(0xFF007F),

  ---### `#7F7F7F`
  MEDIUM_GRAY = v_icol(0x7F7F7F),
  ---### `#CF0000`
  MEDIUM_RED = v_icol(0xCF0000),
  ---### `#CF6700`
  MEDIUM_ORANGE = v_icol(0xCF6700),
  ---### `#CFCF00`
  MEDIUM_YELLOW = v_icol(0xCFCF00),
  ---### `#67CF00`
  MEDIUM_LIME = v_icol(0x67CF00),
  ---### `#00CF00`
  MEDIUM_GREEN = v_icol(0x00CF00),
  ---### `#00CF67`
  MEDIUM_TEAL = v_icol(0x00CF67),
  ---### `#00CFCF`
  MEDIUM_AQUA = v_icol(0x00CFCF),
  ---### `#0067CF`
  MEDIUM_SKYBLUE = v_icol(0x0067CF),
  ---### `#0000CF`
  MEDIUM_BLUE = v_icol(0x0000CF),
  ---### `#6700CF`
  MEDIUM_PURPLE = v_icol(0x6700CF),
  ---### `#CF00CF`
  MEDIUM_MAGENTA = v_icol(0xCF00CF),
  ---### `#CF0067`
  MEDIUM_HOTPINK = v_icol(0xCF0067),

  ---### `#3F3F3F`
  DIM_GRAY = v_icol(0x3F3F3F),
  ---### `#7F0000`
  DIM_RED = v_icol(0x7F0000),
  ---### `#7F3F00`
  DIM_ORANGE = v_icol(0x7F3F00),
  ---### `#7F7F00`
  DIM_YELLOW = v_icol(0x7F7F00),
  ---### `#3F7F00`
  DIM_LIME = v_icol(0x3F7F00),
  ---### `#007F00`
  DIM_GREEN = v_icol(0x007F00),
  ---### `#007F3F`
  DIM_TEAL = v_icol(0x007F3F),
  ---### `#007F7F`
  DIM_AQUA = v_icol(0x007F7F),
  ---### `#003F7F`
  DIM_SKYBLUE = v_icol(0x003F7F),
  ---### `#00007F`
  DIM_BLUE = v_icol(0x00007F),
  ---### `#3F007F`
  DIM_PURPLE = v_icol(0x3F007F),
  ---### `#7F007F`
  DIM_MAGENTA = v_icol(0x7F007F),
  ---### `#7F003F`
  DIM_HOTPINK = v_icol(0x7F003F),

  ---### `#1F1F1F`
  DARK_GRAY = v_icol(0x1F1F1F),
  ---### `#3F0000`
  DARK_RED = v_icol(0x3F0000),
  ---### `#3F1F00`
  DARK_ORANGE = v_icol(0x3F1F00),
  ---### `#3F3F00`
  DARK_YELLOW = v_icol(0x3F3F00),
  ---### `#1F3F00`
  DARK_LIME = v_icol(0x1F3F00),
  ---### `#003F00`
  DARK_GREEN = v_icol(0x003F00),
  ---### `#003F1F`
  DARK_TEAL = v_icol(0x003F1F),
  ---### `#003F3F`
  DARK_AQUA = v_icol(0x003F3F),
  ---### `#001F3F`
  DARK_SKYBLUE = v_icol(0x001F3F),
  ---### `#00003F`
  DARK_BLUE = v_icol(0x00003F),
  ---### `#1F003F`
  DARK_PURPLE = v_icol(0x1F003F),
  ---### `#3F003F`
  DARK_MAGENTA = v_icol(0x3F003F),
  ---### `#3F001F`
  DARK_HOTPINK = v_icol(0x3F001F),

  ---### `#000000`
  BLACK = v_icol(0x000000),

  ---### `#000000`
  ---Minecraft's black text color.
  MC_BLACK = v_icol(0x000000),
  ---### `#0000AA`
  ---Minecraft's dark blue text color.
  MC_DARKBLUE = v_icol(0x0000AA),
  ---### `#00AA00`
  ---Minecraft's dark green text color.
  MC_DARKGREEN = v_icol(0x00AA00),
  ---### `#00AAAA`
  ---Minecraft's dark aqua text color.
  MC_DARKAQUA = v_icol(0x00AAAA),
  ---### `#AA0000`
  ---Minecraft's dark red text color.
  MC_DARKRED = v_icol(0xAA0000),
  ---### `#AA00AA`
  ---Minecraft's dark purple text color.
  MC_DARKPURPLE = v_icol(0xAA00AA),
  ---### `#FFAA00`
  ---Minecraft's gold text color.
  MC_GOLD = v_icol(0xFFAA00),
  ---### `#AAAAAA`
  ---Minecraft's gray text color.
  MC_GRAY = v_icol(0xAAAAAA),
  ---### `#555555`
  ---Minecraft's darkgray text color.
  MC_DARKGRAY = v_icol(0x555555),
  ---### `#5555FF`
  ---Minecraft's blue text color.
  MC_BLUE = v_icol(0x5555FF),
  ---### `#55FF55`
  ---Minecraft's green text color.
  MC_GREEN = v_icol(0x55FF55),
  ---### `#55FFFF`
  ---Minecraft's aqua text color.
  MC_AQUA = v_icol(0x55FFFF),
  ---### `#FF5555`
  ---Minecraft's red text color.
  MC_RED = v_icol(0xFF5555),
  ---### `#FF55FF`
  ---Minecraft's light purple text color.
  MC_LIGHTPURPLE = v_icol(0xFF55FF),
  ---### `#FFFF55`
  ---Minecraft's yellow text color.
  MC_YELLOW = v_icol(0xFFFF55),
  ---### `#FFFFFF`
  ---Minecraft's white text color.
  MC_WHITE = v_icol(0xFFFFFF),

  ---### `#DDD605`
  ---Bedrock Edition's Minecoin gold text color.
  BE_MINECOIN = v_icol(0xDDD605),
  ---### `#E3D4D1`
  ---Bedrock Edition's quartz text color.
  BE_QUARTZ = v_icol(0xE3D4D1),
  ---### `#CECACA`
  ---Bedrock Edition's iron text color.
  BE_IRON = v_icol(0xCECACA),
  ---### `#553A3B`
  ---Bedrock Edition's netherite text color.
  BE_NETHERITE = v_icol(0x443A3B),
  ---### `#971607`
  ---Bedrock Edition's redstone text color.
  BE_REDSTONE = v_icol(0x971607),
  ---### `#B4684D`
  ---Bedrock Edition's copper text color.
  BE_COPPER = v_icol(0xB4684D),
  ---### `#DEB12D`
  ---Bedrock Edition's gold (material) text color.
  BE_GOLD = v_icol(0xDEB12D),
  ---### `#47A036`
  ---Bedrock Edition's emerald text color.
  BE_EMERALD = v_icol(0x47A036),
  ---### `#2CBAA8`
  ---Bedrock Edition's diamond text color.
  BE_DIAMOND = v_icol(0x2CBAA8),
  ---### `#21497B`
  ---Bedrock Edition's lapis text color.
  BE_LAPIS = v_icol(0x21497B),
  ---### `#9A5CC6`
  ---Bedrock Edition's amethyst text color.
  BE_AMETHYST = v_icol(0x9A5CC6),

  ---### `#F0F0F0`
  ---Computercraft's white color.
  CC_WHITE = v_icol(0xF0F0F0),
  ---### `#F2B233`
  ---Computercraft's orange color.
  CC_ORANGE = v_icol(0xF2B233),
  ---### `#E57FD8`
  ---Computercraft's magenta color.
  CC_MAGENTA = v_icol(0xE57FD8),
  ---### `#99B2F2`
  ---Computercraft's light blue color.
  CC_LIGHTBLUE = v_icol(0x99B2F2),
  ---### `#DEDE6C`
  ---Computercraft's yellow color.
  CC_YELLOW = v_icol(0xDEDE6C),
  ---### `#7FCC19`
  ---Computercraft's lime color.
  CC_LIME = v_icol(0x7FCC19),
  ---### `#F2B2CC`
  ---Computercraft's pink color.
  CC_PINK = v_icol(0xF2B2CC),
  ---### `#4C4C4C`
  ---Computercraft's gray color.
  CC_GRAY = v_icol(0x4C4C4C),
  ---### `#999999`
  ---Computercraft's light gray color.
  CC_LIGHTGRAY = v_icol(0x999999),
  ---### `#3C99B2`
  ---Computercraft's cyan color.
  CC_CYAN = v_icol(0x4C99B2),
  ---### `#B266E5`
  ---Computercraft's purple color.
  CC_PURPLE = v_icol(0xB266E5),
  ---### `#3366CC`
  ---Computercraft's blue color.
  CC_BLUE = v_icol(0x3366CC),
  ---### `#7F664C`
  ---Computercraft's brown color.
  CC_BROWN = v_icol(0x7F664C),
  ---### `#57A64E`
  ---Computercraft's green color.
  CC_GREEN = v_icol(0x57A64E),
  ---### `#CC4C4C`
  ---Computercraft's red color.
  CC_RED = v_icol(0xCC4C4C),
  ---### `#111111`
  ---Computercraft's black color.
  CC_BLACK = v_icol(0x111111),

  ---### `#D16969`
  ---VSCode Dark's red font color.
  VSC_RED = v_icol(0xD16969),
  ---### `#D16969`
  ---VSCode Dark's orange font color.
  VSC_ORANGE = v_icol(0xCE9178),
  ---### `#D7BA7D`
  ---VSCode Dark's light orange font color.
  VSC_LIGHTORANGE = v_icol(0xD7BA7D),
  ---### `#DCDCAA`
  ---VSCode Dark's yellow font color.
  VSC_YELLOW = v_icol(0xDCDCAA),
  ---### `#6A9955`
  ---VSCode Dark's green font color.
  VSC_GREEN = v_icol(0x6A9955),
  ---### `#B5CEA8`
  ---VSCode Dark's light green font color.
  VSC_LIGHTGREEN = v_icol(0xB5CEA8),
  ---### `#4EC9B0`
  ---VSCode Dark's teal font color.
  VSC_TEAL = v_icol(0x4EC9B0),
  ---### `#9CDCFE`
  ---VSCode Dark's aqua font color.
  VSC_AQUA = v_icol(0x9CDCFE),
  ---### `#4FC1FF`
  ---VSCode Dark's light blue font color.
  VSC_LIGHTBLUE = v_icol(0x4FC1FF),
  ---### `#569CD6`
  ---VSCode Dark's blue font color.
  VSC_BLUE = v_icol(0x569CD6),
  ---### `#C586C0`
  ---VSCode Dark's magenta font color.
  VSC_MAGENTA = v_icol(0xC586C0),

  ---### `#88DDFF`
  ---Source server text
  SM_SERVER = v_icol(0x88DDFF),
  ---### `#FFDD66`
  ---Source client text
  SM_CLIENT = v_icol(0xFFDD66),
  ---### `#64DC64`
  ---Source menu text
  SM_MENU = v_icol(0x64DC64),

  ---### `#FF72AD`
  ---Figura pink.
  FIG_PINK = v_icol(0xFF72AD),
  ---### `#A672EF`
  ---Figura purple.
  FIG_PURPLE = v_icol(0xA672EF),
  ---### `#00F0FF`
  ---Figura aqua.
  FIG_AQUA = v_icol(0x00F0FF),
  ---### `#99BBEE`
  ---Figura blue.
  FIG_BLUE = v_icol(0x99BBEE),
  ---### `#FF2400`
  ---Figura red.
  FIG_RED = v_icol(0xFF2400),
  ---### `#FF2400`
  ---Figura orange.
  FIG_ORANGE = v_icol(0xFFC400),
  ---### `#F8C53A`
  ---Figura cheese orange.
  FIG_CHEESE = v_icol(0xF8C53A),
  ---### `#5555FF`
  ---Figura Lua blue.
  FIG_LUA = v_icol(0x5555FF),
  ---### `#FF5555`
  ---Figura error red.
  FIG_ERROR = v_icol(0xFF5555),
  ---### `#A155DA`
  ---Figura ping purple.
  FIG_PING = v_icol(0xA155DA),
  ---### `#5AAAFF`
  ---Figura default blue.
  FIG_DEFAULT = v_icol(0x5AAAFF),
  ---### `#5865F2`
  ---Figura Discord blue.
  FIG_DISCORD = v_icol(0x5865F2),
  ---### `#27AAE0`
  ---Figura Kofi blue.
  FIG_KOFI = v_icol(0x27AAE0),
  ---### `#FFFFFF`
  ---Figura Github white.
  FIG_GITHUB = v_icol(0xFFFFFF),
  ---### `#FF4400`
  ---Figura Reddit orange.
  FIG_REDDIT = v_icol(0xFF4400),
  ---### `#1BD96A`
  ---Figura Modrinth green.
  FIG_MODRINTH = v_icol(0x1BD96A),
  ---### `#F16436`
  ---Figura Curseforge orange.
  FIG_CURSEFORGE = v_icol(0xF16436),

  ---### `#00A4FF`
  ---GrandpaScout
  USR_GS = v_icol(0x00A4FF),
}


---==================================================================================================================---
---====  LIBRARY  ===================================================================================================---
---==================================================================================================================---

---### [GS Extensions]
---An extension library that offers some color functions.
---@class Lib.GS.Extensions.Color.Lib
colors = {}
local colors = colors

local css_colors = "XaliceblueF0F8FFantiquewhiteFAEBD7aqua0FFaquamarine7FFFD4azureF0FFFFbeigeF5F5DCbisqueFFE4C4black0\z
blanchedalmondFFEBCDblue00Fblueviolet8A2BE2brownA52A2AburlywoodDEB887cadetblue5F9EAchartreuse7FFFchocolateD2691E\z
coralFF7F5cornflowerblue6495EDcornsilkFFF8DCcrimsonDC143Ccyan0FFdarkblue00008Bdarkcyan008B8BdarkgoldenrodB8860B\z
darkgrayA9A9A9darkgreyA9A9A9darkgreen0064darkkhakiBDB76Bdarkmagenta8B008Bdarkolivegreen556B2FdarkorangeFF8C\z
darkorchid9932CCdarkred8BdarksalmonE9967Adarkseagreen8FBC8Fdarkslateblue483D8Bdarkslategray2F4F4Fdarkslategrey2F4F4F\z
darkturquoise00CED1darkviolet9400D3deeppinkFF1493deepskyblue00BFFFdimgray696969dimgrey696969dodgerblue1E90FF\z
firebrickB22222floralwhiteFFFAFforestgreen228B22fuchsiaF0FgainsboroDCDCDCghostwhiteF8F8FFgoldFFD7goldenrodDAA52\z
gray80808grey80808green0080greenyellowADFF2FhoneydewF0FFFhotpinkFF69B4indianredCD5C5Cindigo4B0082ivoryFFFFFkhakiF0E68C\z
lavenderE6E6FAlavenderblushFFF0F5lawngreen7CFClemonchiffonFFFACDlightblueADD8E6lightcoralF0808lightcyanE0FFFF\z
lightgoldenrodyellowFAFAD2lightgrayD3D3D3lightgreyD3D3D3lightgreen90EE9lightpinkFFB6C1lightsalmonFFA07A\z
lightseagreen20B2AAlightskyblue87CEFAlightslategray789lightslategrey789lightsteelblueB0C4DElightyellowFFFFElime0F0\z
limegreen32CD32linenFAF0E6magentaF0Fmaroon8mediumaquamarine66CDAAmediumblue0000CDmediumorchidBA55D3mediumpurple9370DB\z
mediumseagreen3CB371mediumslateblue7B68EEmediumspringgreen00FA9Amediumturquoise48D1CCmediumvioletredC71585\z
midnightblue19197mintcreamF5FFFAmistyroseFFE4E1moccasinFFE4B5navajowhiteFFDEADnavy00008oldlaceFDF5E6olive8080\z
olivedrab6B8E23orangeFFA5orangeredFF45orchidDA70D6palegoldenrodEEE8AApalegreen98FB98paleturquoiseAFEEEE\z
palevioletredDB7093papayawhipFFEFD5peachpuffFFDAB9peruCD853FpinkFFC0CBplumDDA0DDpowderblueB0E0E6purple80008\z
rebeccapurple639redFFrosybrownBC8F8Froyalblue4169E1saddlebrown8B4513salmonFA8072sandybrownF4A46seagreen2E8B57\z
seashellFFF5EEsiennaA0522DsilverC0C0Cskyblue87CEEBslateblue6A5ACDslategray70809slategrey70809snowFFFAFA\z
springgreen00FF7Fsteelblue4682B4tanD2B48Cteal00808thistleD8BFD8tomatoFF6347turquoise40E0DvioletEE82EEwheatF5DEB3\z
whiteFFFwhitesmokeF5F5F5yellowFF0yellowgreen9ACD32"

local css_colorcache = {}

---Hue-shift a color by the given amount.
---
---This function does not support colors with alpha values.
---@param vec Vector3
---@param shift number
---@return Vector3 color
function colors.hueShift(vec, shift)
  local hsv = vectors.rgbToHSV(vec)
  hsv.x = hsv.x + (shift * c_huediv)
  return vectors.hsvToRGB(hsv)
end

---Saturates or desaturates a color by the given multiplier.
---
---This function does not support colors with alpha values.
---@param vec Vector3
---@param mult number
---@return Vector3 color
function colors.saturate(vec, mult)
  local hsv = vectors.rgbToHSV(vec)
  hsv.y = hsv.y * mult
  return vectors.hsvToRGB(hsv)
end

---Brightens or darkens a color by the given multiplier.
---
---This function does not support colors with alpha values.
---@param vec Vector3
---@param mult number
---@return Vector3 color
function colors.brighten(vec, mult)
  local hsv = vectors.rgbToHSV(vec)
  hsv.z = hsv.z * mult
  return vectors.hsvToRGB(hsv)
end

---Get a CSS color by name.
---
---Invalid names will return nothing.
---@param name string
---@return Vector3? color
function colors.cssColor(name)
  name = name:lower()
  if css_colorcache[name] then
    return vectors.hexToRGB(css_colorcache[name])
  elseif name:match("^[a-z]+$") then
    local hex = css_colors:match("[0-9A-FX]" .. name .. "([0-9A-F]+)")
    if hex then
      css_colorcache[name] = hex
      return vectors.hexToRGB(hex)
    end
  end
end

---Picks a color out of a shifting color made from the given arguments.
---
---Speed is measured in cycles/second.
---@param speed number
---@param offset number
---@param sat? number
---@param val? number
---@return Vector3 color
function colors.rainbow(speed, offset, sat, val)
  if sat == 0 then
    return _VEC_ONE:copy():scale(val and m_clamp(val, 0, 1) or 1)
  elseif val == 0 then
    return _VEC_ZERO:copy()
  else
    return vectors.hsvToRGB(
      (world.getTime(frameTime()) * speed * 0.05 + offset) % 1,
      sat and m_clamp(sat, 0, 1) or 1,
      val and m_clamp(val, 0, 1) or 1
    )
  end
end


return setmetatable(this, thismt)
