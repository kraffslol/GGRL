-----------------------------------------------------------------------
-- Globals
--
-- GLOBALS: LibStub, GGRL, C_ChatInfo, SendAddonMessage, RegisterAddonMessagePrefix, tinsert, table, GetInstanceInfo, UnitExists, type

GGRL = LibStub("AceAddon-3.0"):NewAddon("GGRL", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0")

-- 8.0 Compat
if C_ChatInfo then
  RegisterAddonMessagePrefix, SendAddonMessage = C_ChatInfo.RegisterAddonMessagePrefix, C_ChatInfo.SendAddonMessage
end

local SendAddonMessage = SendAddonMessage
local tinsert, twipe, type = table.insert, table.wipe, type
local GetInstanceInfo = GetInstanceInfo
local UnitExists = UnitExists

GGRL.loadedBosses = {}
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
  -- Check in GGRL.loadedBosses if encounterid exists to start timer, otherwise do nothing
  if IsBossLoaded(self.loadedBosses, encounterID) then
    self:Print("Boss Loaded")
    self:StartEncounterTimer(encounterID)
  end
end

function GGRL:ENCOUNTER_END()
  self:StopEncounterTimer()
end

function GGRL:COMBAT_LOG_EVENT_UNFILTERED(...)
  self.Antorus:OnCombatEvent(self.currentBoss, ...)
end

-----------------------------------------------------------------------
-- Addon
--

function GGRL:LoadRaid()
  local _, instanceType, _, _, _, _, _, id = GetInstanceInfo()
  if instanceType == "none" then
    return false
  end

  -- Load Raid bosses here. (Clear Bosses table before loading the new ones?)
  twipe(self.loadedBosses)
  -- Antorus
  if id == 1712 then
    self.Antorus:Load()
  end
end

function GGRL:LoadBoss(id, timers)
  self.loadedBosses[id] = timers
end

function GGRL:StartEncounterTimer(encounterID)
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self.currentBoss = encounterID
  self.currentBossPhase = 1
  self.currentBossTimes = GetEventTimes(GGRL.loadedBosses[encounterID][1])
  self.combatTimer = GGRL:ScheduleRepeatingTimer("TimerTick", 1)
  self:Print("Timer started")
end

function GGRL:StopEncounterTimer()
  self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self:CancelTimer(self.combatTimer)
  self.currentBoss = nil
  self.timerCount = 0
  self.currentBossTimes = {}
  self.currentBossPhase = 1
  SendAddonMessage("GGRL_CLEAR", "", "RAID")
end

function GGRL:TimerTick()
  self.timerCount = self.timerCount + 1

  -- Process boss events here and send message
  local event = GetBossEvent(self.loadedBosses[self.currentBoss][self.currentBossPhase], self.timerCount)
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
    self:StartEncounterTimer(2092)
  end

  if input == "stop" then
    self:StopEncounterTimer()
  end

  if input == "argus" then
    self.Antorus:Load(1712)
    self.currentBoss = 2092
  end
end

-----------------------------------------------------------------------
-- Register Events & ChatCommands
--

GGRL:RegisterChatCommand("ggrl", "HandleSlash")
GGRL:RegisterEvent("ENCOUNTER_START")
GGRL:RegisterEvent("ENCOUNTER_END")
GGRL:RegisterEvent("ZONE_CHANGED_NEW_AREA", "LoadRaid")
GGRL:RegisterEvent("PLAYER_ENTERING_WORLD", "LoadRaid")
