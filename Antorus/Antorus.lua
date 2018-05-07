local Raid = {
  Bosses = {}
}
GGRL.Antorus = Raid

function Raid:Load(instanceId)
  if not instanceId == 1712 then
    return false
  end
  GGRL:Print("Loaded Antorus")

  -- Init Bosses
  Raid.Bosses.Argus:Init()
end

function Raid:OnCombatEvent(encounterId, ...)
  -- Argus
  if encounterId == 2092 then
    Raid.Bosses.Argus:OnCombatEvent(...)
  end
end
