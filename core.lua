-----------------------------------------------------------------------
-- Globals
--

GGRL = LibStub("AceAddon-3.0"):NewAddon("GGRL", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0")

GGRL.Bosses = {}
GGRL.timerCount = 0
GGRL.currentBoss = nil
GGRL.currentBossTimes = {}
GGRL.currentBossPhase = 1

-----------------------------------------------------------------------
-- Utility
--

local function GetBossEvent(table, val)
  for i = 1, #table do
    if table[i]["time"] == val then
      return table[i]
    end
  end
  return false
end

local function GetEventTimes(table)
  local t = {}
  for i = 1, #table do
    tinsert(t, table[i]["time"])
  end
  return t
end

local function IsBossLoaded(table, encounterId)
  if table[encounterId] ~= nil then
    return true
  end
  return false
end

-----------------------------------------------------------------------
-- Events
--

function GGRL:ENCOUNTER_START(evt, encounterID)
  -- Temp
  --local _, instanceType, _, _, _, _, _, id = GetInstanceInfo()
  --GGRL.Antorus:Load(id)

  -- Check in GGRL.Bosses if encounterid exists to start timer, otherwise do nothing
  if IsBossLoaded(self.Bosses, encounterID) then
    GGRL:Print("Boss Loaded")
    GGRL:StartEncounterTimer(encounterID)
  end
end

function GGRL:ENCOUNTER_END()
  GGRL:StopEncounterTimer()
end

function GGRL:COMBAT_LOG_EVENT_UNFILTERED(...)
  GGRL.Antorus:OnCombatEvent(self.currentBoss, ...)
end

-----------------------------------------------------------------------
-- Addon
--

function GGRL:OnEnable()
  --[[self.Bosses = {}
  self.timerCount = 0
  self.currentBoss = nil
  self.currentBossTimes = {}
  self.currentBossPhase = 1--]]
end

function GGRL:LoadBosses()
  local _, instanceType, _, _, _, _, _, id = GetInstanceInfo()
  if instanceType == "none" then
    return false
  end

  -- Load Bosses here. (Clear Bosses table before loading the new ones?)
  GGRL.Antorus:Load(id)
end

function GGRL:LoadBoss(id, timers)
  self.Bosses[id] = timers
end

function GGRL:StartEncounterTimer(encounterID)
  self:Print("Timer started")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self.currentBoss = encounterID
  self.currentBossPhase = 1
  self.currentBossTimes = GetEventTimes(GGRL.Bosses[encounterID][1])
  self.combatTimer = GGRL:ScheduleRepeatingTimer("TimerTick", 1)
end

function GGRL:StopEncounterTimer()
  self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self:CancelTimer(GGRL.combatTimer)
  self.currentBoss = nil
  self.timerCount = 0
  self.currentBossTimes = {}
  self.currentBossPhase = 1
  SendAddonMessage("GGRL_CLEAR", "", "RAID")
end

function GGRL:TimerTick()
  self.timerCount = self.timerCount + 1

  -- Process boss events here and send message
  local event = GetBossEvent(self.Bosses[self.currentBoss][self.currentBossPhase], self.timerCount)
  if event then
    self:Print(event["type"], event["target"], event["text"])
    --GGRL GGRL_DURATION GGRL_SOUND GGRL_MESSAGE
    if event["type"] == "RAID" then
      SendAddonMessage("GGRL", event["text"], "RAID")
    end

    if event["type"] == "WHISPER" then
      -- If target is a table then iterate through it and send a whisper to each target.
      if type(event["target"]) == "table" then
        for i = 1, #event["target"] do
          if (UnitExists(event["target"][i])) then
            SendAddonMessage("GGRL", event["text"], "WHISPER", event["target"][i])
          end
        end
      else
        if (UnitExists(event["target"])) then
          SendAddonMessage("GGRL", event["text"], "WHISPER", event["target"])
        end
      end
    end
  end
end

function GGRL:SetPhase(phase)
  self.currentBossPhase = phase
  self.timerCount = 0
end

function GGRL:HandleSlash(input)
  if input == "start" then
    GGRL:StartEncounterTimer(2092)
  end

  if input == "stop" then
    GGRL:StopEncounterTimer()
  end

  if input == "argus" then
    GGRL.Antorus:Load(1712)
    self.currentBoss = 2092
  end
end

-----------------------------------------------------------------------
-- Register Events & ChatCommands
--

GGRL:RegisterChatCommand("ggrl", "HandleSlash")
GGRL:RegisterEvent("ENCOUNTER_START")
GGRL:RegisterEvent("ENCOUNTER_END")
GGRL:RegisterEvent("ZONE_CHANGED_NEW_AREA", "LoadBosses")
GGRL:RegisterEvent("PLAYER_ENTERING_WORLD", "LoadBosses")
