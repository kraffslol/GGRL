-- GLOBALS: GGRL
local Boss = {}
GGRL.Antorus.Argus = Boss

local timers = {
  -- Phases
  [1] = {
    {type = "RAID", time = 7, duration = 5, text = "Melee Spread"},
    {type = "RAID", time = 26, duration = 6, text = "Cone"},
    {type = "RAID", time = 42, duration = 5, text = "Melee Spread"},
    {type = "RAID", time = 47, duration = 6, text = "Cone"},
    {type = "RAID", time = 60, duration = 3, text = "POTS"},
    {type = "RAID", time = 67, duration = 6, text = "Cone"},
    {type = "RAID", time = 73, duration = 9, text = "Buff -> Spread"},
    {type = "RAID", time = 87, duration = 6, text = "Cone"},
    {type = "RAID", time = 107, duration = 6, text = "Cone"}
  },
  [2] = {
    {type = "RAID", time = 3, duration = 10, text = "Spread + Bombs"},
    {type = "RAID", time = 43, duration = 5, text = "Bomb inc"},
    {type = "RAID", time = 64, duration = 8, text = "Spread"},
    {type = "RAID", time = 87, duration = 10, text = "Bomb inc -> Tank Suicide"}
  },
  [3] = {
    {type = "RAID", time = 0, duration = 5, text = "Rune"},
    {type = "RAID", time = 19, duration = 5, text = "Spread"},
    {type = "RAID", time = 24, duration = 6, text = "Bait"},
    {type = "RAID", time = 31, duration = 5, text = "Potion"},
    {type = "RAID", time = 49, duration = 4, text = "Chains inc"},
    {type = "RAID", time = 72, duration = 6, text = "Bait"},
    {type = "RAID", time = 93, duration = 5, text = "Spread"},
    {type = "RAID", time = 101, duration = 4, text = "Die"},
    {type = "RAID", time = 109, duration = 5, text = "Release"},
    {type = "RAID", time = 115, duration = 3, text = "Rune"},
    {type = "RAID", time = 119, duration = 6, text = "Bait"},
    {type = "RAID", time = 164, duration = 3, text = "Spread"},
    {type = "RAID", time = 167, duration = 6, text = "Bait"},
    {type = "RAID", time = 216, duration = 4, text = "Spread"},
    {type = "RAID", time = 220, duration = 6, text = "Bait"},
    {type = "RAID", time = 226, duration = 4, text = "Potion"},
    {type = "RAID", time = 269, duration = 4, text = "Spread"},
    {type = "RAID", time = 273, duration = 6, text = "Bait"}
  }
}

function Boss:Init()
  GGRL:LoadBoss(2092, timers)
end

function Boss:OnCombatEvent(...)
  local _, _, event, _, _, _, _, _, _, _, _, _, spellID, _, _, extraspellID = ...
  if event == "SPELL_AURA_APPLIED" and spellID == 255199 and GGRL.currentBossPhase == 1 then
    GGRL:SetPhase(2)
  end

  if event == "SPELL_INTERRUPT" and (spellID == 256544 or extraspellID == 256544) then
    GGRL:SetPhase(3)
  end
end
