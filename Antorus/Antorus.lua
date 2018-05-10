-- GLOBALS: GGRL
local GGRL = GGRL
local Raid = {}
GGRL.Antorus = Raid

function Raid:Load()
  GGRL:Print("Loaded Antorus")

  -- Init Bosses
  Raid.Argus:Init()
end

function Raid:OnCombatEvent(encounterId, ...)
  -- Argus
  if encounterId == 2092 then
    Raid.Argus:OnCombatEvent(...)
  end
end
