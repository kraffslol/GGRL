-- GLOBALS: GGRL
local GGRL = GGRL
local Raid = {}
GGRL.Raid.Antorus = Raid

function Raid:Load()
  GGRL:Print("Loaded Antorus")

  -- Init Bosses
  self.Argus:Init()
end

function Raid:OnCombatEvent(encounterId, ...)
  -- Argus
  if encounterId == 2092 then
    self.Argus.OnCombatEvent(...)
  end
end
