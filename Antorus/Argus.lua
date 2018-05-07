local Boss = {}
GGRL.Antorus.Bosses.Argus = Boss

function Boss:Init()
  GGRL:LoadBoss(
    2092,
    {
      -- Phases
      [1] = {
        {
          type = "RAID",
          target = "",
          text = "Dodge Shit",
          time = 3,
          duration = 5,
          sound = false
        },
        {
          type = "WHISPER",
          target = {"Mangisaurus", "Numinous"},
          text = "Soak ring",
          time = 6,
          duration = 5,
          sound = false
        }
      },
      [2] = {}
    }
  )
end

function Boss:OnCombatEvent(...)
  local _, _, event, _, _, _, _, _, _, _, _, _, spellID, _, _, extraspellID = ...
  if event == "SPELL_INTERRUPT" and (spellID == 256544 or extraspellID == 256544) then
    GGRL:SetPhase(2)
  end

  if event == "SPELL_AURA_APPLIED" and spellID == 255199 and GGRL.currentBossPhase == 1 then
    GGRL:SetPhase(3)
  end
end
