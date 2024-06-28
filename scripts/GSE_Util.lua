-- ┌───┐                ┌───┐ --
-- │ ┌─┘ ┌─────┐┌─────┐ └─┐ │ --
-- │ │   │ ┌───┘│ ╶───┤   │ │ --
-- │ │   │ ├───┐└───┐ │   │ │ --
-- │ │   │ └─╴ │┌───┘ │   │ │ --
-- │ └─┐ └─────┘└─────┘ ┌─┘ │ --
-- └───┘                └───┘ --
---@module  "Figura Lua Extensions Utilities" <GSE_Util>
---@version v1.1.0
---@see     GrandpaScout @ https://github.com/GrandpaScout
-- GSExtensions adds some miscellaneous functions and variables to the standard Figura library for convenience.
-- This extension adds a library that contains functions that couldn't be put anywhere else.

local ID = "GSE_Util"
local VER = "1.1.0"
local FIG = {"0.1.1", "0.1.4"}


---Adds a library full of random utility functions.  
---Currently only contains functions for calculating damage.
---
---Any fields, functions, and methods injected by this library will be prefixed with **[GS&nbsp;Extensions]** in their
---description to avoid confusion between features of the standard library and this extension.
---
---### *Does not require GSECommon!*
---
---**<u>Contributes:</u>**
---* `util`
---@class Lib.GS.Extensions.Util
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
local m_clamp = math.clamp
local m_min = math.min
local m_max = math.max

local bit32 = bit32
local b_btest = bit32.btest
local b_band = bit32.band


---==================================================================================================================---
---====  GLOBALS  ===================================================================================================---
---==================================================================================================================---


---### [GS Extensions]
---An extension library with a bunch of utility functions.
---@class Lib.GS.Extensions.Util.Lib
gseutil = {}
local util = gseutil

---Calculates total damage done after armor and resistances have been applied.
---
---If a certain variable does not affect the damage being done, don't include it.  
---(Fall damage ignores armor and toughness, but not epf.)
---@param dmg number
---@param armor? number
---@param toughness? number
---@param breach? number
---@param epf? number
---@param res? number
---@return number
function util.calculateDamage(dmg, armor, toughness, breach, epf, res)
  dmg = m_clamp(dmg, 0, 0x7FFFFFFF)
  armor = armor and m_clamp(armor, 0, 30) or 0
  toughness = toughness and m_clamp(toughness, 0, 20) or 0
  breach = breach and m_clamp(breach, 0, 7) or 0
  epf = epf and m_clamp(epf, 0, 20) or 0
  res = res and m_clamp(res, 0, 5) or 0

  local zero_armor = armor == 0 and toughness == 0
  local zero_epf = epf == 0
  local zero_res = res == 0
  if dmg == 0 or (zero_armor and zero_epf and zero_res) then return dmg end
  if res == 5 then return 0 end

  if not zero_armor then
    dmg = dmg * (1 - (m_max(0, m_min(20, m_max(armor * 0.2, armor - 4 * dmg / (toughness + 8))) * 0.04 - breach * 0.15)))
  end

  if not zero_epf then dmg = dmg * (1 - (epf * 0.04)) end
  if not zero_res then return m_max(0, dmg * (1 - (res * 0.2))) end

  return m_max(0, dmg)
end

---@alias Lib.GS.Extensions.Util.damageMask number
---|>0   # `xxxx 0000` **Generic** - Untyped damage.
---| 1   # `xxxx xxx1` **Fire** - Fire damage.
---| 2   # `xxxx xx1x` **Blast** - Blast damage.
---| 4   # `xxxx x1xx` **Projectile** - Projectile damage.
---| 8   # `xxxx 1xxx` **Fall** - Fall damage.
---| 16  # `xxx1 xxxx` **Piercing** - Ignores all armor and armor toughness.
---| 32  # `xx1x xxxx` **Nullifying** - Ignores protection enchantments.
---| 64  # `x1xx xxxx` **Unstoppable** - Ignores potion effects.
---
---`0000 0000` **Generic**: Any basic untyped attack.  
---> `cactus`, `falling_anvil`, `falling_block`, `falling_stalactite`, `lightning_bolt`, `mob_attack`,
---> `mob_attack_no_aggro`, `player_attack`, `sting`, `sweet_berry_bush`, `thorns`
---|>"GENERIC"
---`0000 0001` **Fire**: Any basic fire attack.  
---> `hot_floor`, `in_fire`, `lava`
---| "FIRE"
---`0000 0010` **Blast**: Any basic explosive attack.  
---> `bad_respawn_point`, `explosion`, `fireworks`, `player_explosion`
---| "EXPLOSION"
---`0000 0100` **Projectile**: Any basic projectile attack.  
---> `arrow`, `mob_projectile`, `thrown`, `trident`, `wither_skull`
---| "PROJECTILE"
---`0001 1000` **Piercing Fall**: Fall damage.  
---> `fall`, `stalagmite`
---| "FALL"
---`0000 0101` **Fire Projectile**: Fireball damage.  
---> `fireball`, `unattributed_fireball`
---| "FIREBALL"
---`0001 0000` **Piercing Generic**: Ignores armor.
---> `cramming`, `dragon_breath`, `drown`, `fly_into_wall`, `freeze`, `generic`, `in_wall`, `indirect_magic`,
---> `magic`, `outside_border`, `wither`
---| "IGNORE_ARMOR"
---`0001 0001` **Piercing Fire**: On fire damage.  
---> `on_fire`
---| "ON_FIRE"
---`0011 0000` **Nullifying Piercing Generic**: Ignores armor and enchantments.
---> `sonic_boom`
---| "SONIC"
---`0111 0000` **Unstoppable Nullifying Piercing Generic**: Ignores everything.
---> `generic_kill`, `starve`, `out_of_world`
---| "IGNORE_ALL"

local damage_alias = {
  GENERIC = 0,
  FIRE = 1,
  EXPLOSION = 2,
  PROJECTILE = 4,
  FALL = 24,
  FIREBALL = 5,
  IGNORE_ARMOR = 16,
  ON_FIRE = 17,
  FALLING_BLOCK = 128,
  SONIC = 48,
  IGNORE_ALL = 112
}
---@type {[string]: {[1]: integer, [2]: integer}}
local armor_stats = {
  ["minecraft:leather_helmet"] = {1, 0},
  ["minecraft:leather_chestplate"] = {3, 0},
  ["minecraft:leather_leggings"] = {2, 0},
  ["minecraft:leather_boots"] = {1, 0},

  ["minecraft:chainmail_helmet"] = {2, 0},
  ["minecraft:chainmail_chestplate"] = {5, 0},
  ["minecraft:chainmail_leggings"] = {4, 0},
  ["minecraft:chainmail_boots"] = {1, 0},

  ["minecraft:gold_helmet"] = {2, 0},
  ["minecraft:gold_chestplate"] = {5, 0},
  ["minecraft:gold_leggings"] = {3, 0},
  ["minecraft:gold_boots"] = {1, 0},

  ["minecraft:iron_helmet"] = {2, 0},
  ["minecraft:iron_chestplate"] = {6, 0},
  ["minecraft:iron_leggings"] = {5, 0},
  ["minecraft:iron_boots"] = {2, 0},

  ["minecraft:diamond_helmet"] = {3, 2},
  ["minecraft:diamond_chestplate"] = {8, 2},
  ["minecraft:diamond_leggings"] = {6, 2},
  ["minecraft:diamond_boots"] = {3, 2},

  ["minecraft:netherite_helmet"] = {3, 3},
  ["minecraft:netherite_chestplate"] = {8, 3},
  ["minecraft:netherite_leggings"] = {6, 3},
  ["minecraft:netherite_boots"] = {3, 3},

  ["minecraft:turtle_helmet"] = {2, 0}
}
---Gets the armor, armor toughness, EPF, and resistance that an item or entity has against a damage type.
---
---If the given damage type ignores a certain protection value, it will be set to 0.
---@param target ItemStack | LivingEntity
---@param dmgmask Lib.GS.Extensions.Util.damageMask
---@param breach number
---@return number armor
---@return number toughness
---@return number breach
---@return number epf
---@return number res
function util.getProtectionValues(target, dmgmask, breach)
  dmgmask = damage_alias[dmgmask] or dmgmask or 1

  if b_band(dmgmask, 112) == 112 then return 0, 0, 0, 0, 0 end

  local armor, toughness, epf = 0, 0, 0
  if type(target) == "ItemStack" then

    if not b_btest(dmgmask, 16) then
      local attrmod = target.tag.AttributeModifiers
      if attrmod then
        local armorM, toughnessM = 1, 1

        for _, mod in ipairs(attrmod) do
          local modname = mod.AttributeName:gsub("^minecraft:", "")
          if modname == "generic.armor" then
            if mod.Operation == 0 then
              armor = armor + mod.Amount
            elseif mod.Operation == 2 then
              armorM = armorM * (1 + mod.Amount)
            end
          elseif modname == "generic.armor_toughness" then
            if mod.Operation == 0 then
              toughness = toughness + mod.Amount
            elseif mod.Operation == 2 then
              toughnessM = toughnessM * (1 + mod.Amount)
            end
          end
        end

        armor = armor * armorM
        toughness = toughness * toughnessM
      else
        local stats = armor_stats[target.id]
        if stats then armor, toughness = stats[1], stats[2] end
      end
    end
    if not b_btest(dmgmask, 32) then
      local enchantments = target.tag.Enchantments
      if enchantments then
        local IS_FIRE, IS_EXPL = b_btest(dmgmask, 1), b_btest(dmgmask, 2)
        local IS_PROJ, IS_FALL = b_btest(dmgmask, 4), b_btest(dmgmask, 8)
        local IS_SPEC = b_btest(dmgmask, 15)

        for _, ench in ipairs(enchantments) do
          local enchid = ench.id:gsub("^minecraft:", "")
          if enchid == "protection" then
            epf = epf + ench.lvl
          elseif IS_SPEC then
            if enchid == "fire_protection" then
              if IS_FIRE then epf = epf + ench.lvl * 2 end
            elseif enchid == "blast_protection" then
              if IS_EXPL then epf = epf + ench.lvl * 2 end
            elseif enchid == "projectile_protection" then
              if IS_PROJ then epf = epf + ench.lvl * 2 end
            elseif enchid == "feather_falling" then
              if IS_FALL then epf = epf + ench.lvl * 3 end
            end
          end
        end
      end
    end

    return m_clamp(armor, 0, 30), m_clamp(toughness, 0, 20), breach or 0, m_clamp(epf, 0, 20), 0
  elseif target.getArmor --[[Duck LivingEntityAPI]] then
    local res = 0
    local equip = {
      target:getItem(6), target:getItem(5),
      target:getItem(4), target:getItem(3)
    }

    local IGNORE_ARMOR = b_btest(dmgmask, 16)
    local IGNORE_ENCH = b_btest(dmgmask, 32)

    local nbt = target:getNbt()

    if not IGNORE_ARMOR then
      armor = target:getArmor()
      for _, attr in ipairs(nbt.Attributes) do
        if attr.Name == "minecraft:generic.armor_toughness" then
          toughness = attr.Base
          break
        end
      end

      local toughnessB, toughnessM, toughnessM2 = toughness, 1, 1
      local attrmods
      for _, item in ipairs(equip) do
        attrmods = item.tag.AttributeModifiers
        if attrmods then

          local modopr
          for _, mod in ipairs(attrmods) do
            if mod.AttributeName:gsub("^minecraft:", "") == "generic.armor_toughness" then
              modopr = mod.Operation
              if modopr == 0 then
                toughness = toughness + mod.Amount
              elseif modopr == 1 then
                toughnessM = toughnessM + mod.Amount
              elseif modopr == 2 then
                toughnessM2 = toughnessM2 * (1 + mod.Amount)
              end
            end
          end
        else
          local stats = armor_stats[item.id]
          if stats then toughness = toughness + stats[2] end
        end
      end

      toughness = (toughness + (toughnessB * toughnessM)) * toughnessM2
    end

    if not IGNORE_ENCH then
      local IS_FIRE, IS_EXPL = b_btest(dmgmask, 1), b_btest(dmgmask, 2)
      local IS_PROJ, IS_FALL = b_btest(dmgmask, 4), b_btest(dmgmask, 8)
      local IS_SPEC = b_btest(dmgmask, 15)

      local enchantments
      for _, item in ipairs(equip) do
        enchantments = item.tag.Enchantments
        if enchantments then
          for _, ench in ipairs(enchantments) do
            local enchid = ench.id:gsub("^minecraft:", "")
            if enchid == "protection" then
              epf = epf + ench.lvl
            elseif IS_SPEC then
              if enchid == "fire_protection" then
                if IS_FIRE then epf = epf + ench.lvl * 2 end
              elseif enchid == "blast_protection" then
                if IS_EXPL then epf = epf + ench.lvl * 2 end
              elseif enchid == "projectile_protection" then
                if IS_PROJ then epf = epf + ench.lvl * 2 end
              elseif enchid == "feather_falling" then
                if IS_FALL then epf = epf + ench.lvl * 3 end
              end
            end
          end
        end
      end
    end

    if not b_btest(dmgmask, 64) then
      local uuid = target:getUUID()
      if uuid == player:getUUID() then
        local IS_FIRE = b_btest(dmgmask, 1)
        for _, effect in ipairs(host:getStatusEffects()) do
          if effect.name == "effect.minecraft.resistance" then
            res = effect.amplifier + 1
            if not IS_FIRE then break end
          elseif IS_FIRE and effect.name == "effect.minecraft.fire_resistance" then
            res = 5
            break
          end
        end
      end
    end

    return
      m_clamp(armor, 0, 30), m_clamp(toughness, 0, 20), breach or 0,
      m_clamp(epf, 0, 20), m_clamp(res, 0, 5)
  end

  return 0, 0, 0, 0, 0
end


return setmetatable(this, thismt)
