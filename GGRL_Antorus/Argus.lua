-- GLOBALS: GGRL
local GGRL = GGRL
local Boss = {}
GGRL.Raid.Antorus.Argus = Boss

--[[ 
  1 type (string)
  2 time (int)
  3 duration (int)
  4 text (string)
  5 target (string)
  6 sound (bool)
  7 soundfile (string)
]]

local timers = {
  -- Phases
  [1] = {
    {"RAID", 7, 5, "Melee Spread"},
    {"RAID", 26, 6, "Cone"},
    {"RAID", 42, 5, "Melee Spread"},
    {"RAID", 47, 6, "Cone"},
    {"RAID", 60, 3, "POTS"},
    {"RAID", 67, 6, "Cone"},
    {"RAID", 73, 9, "Buff -> Spread"},
    {"RAID", 87, 6, "Cone"},
    {"RAID", 107, 6, "Cone"}
  },
  [2] = {
    {"RAID", 3, 10, "Spread + Bombs"},
    {"RAID", 43, 5, "Bomb inc"},
    {"RAID", 64, 8, "Spread"},
    {"RAID", 87, 10, "Bomb inc"}
  },
  [3] = {
    {"RAID", 0, 5, "Rune"},
    {"RAID", 19, 5, "Spread"},
    {"RAID", 24, 6, "Bait"},
    {"RAID", 31, 5, "Potion"},
    {"RAID", 49, 4, "Chains inc"},
    {"RAID", 72, 6, "Bait"},
    {"RAID", 93, 5, "Spread"},
    {"RAID", 101, 4, "Die"},
    {"RAID", 109, 5, "Release"},
    {"RAID", 115, 3, "Rune"},
    {"RAID", 119, 6, "Bait"},
    {"RAID", 164, 3, "Spread"},
    {"RAID", 167, 6, "Bait"},
    {"RAID", 216, 4, "Spread"},
    {"RAID", 220, 6, "Bait"},
    {"RAID", 226, 4, "Potion"},
    {"RAID", 269, 4, "Spread"},
    {"RAID", 273, 6, "Bait"}
  }
}

function Boss:Init()
  GGRL:LoadBoss(2092, timers)
end

function Boss.OnCombatEvent(...)
  local _, _, event, _, _, _, _, _, _, _, _, _, spellID, _, _, extraspellID = ...
  if event == "SPELL_AURA_APPLIED" and spellID == 255199 and GGRL.currentBossPhase == 1 then
    GGRL:SetPhase(2)
  end

  if event == "SPELL_INTERRUPT" and (spellID == 256544 or extraspellID == 256544) then
    GGRL:SetPhase(3)
  end
end
