-----------------------------------------------------------------------
-- Globals
--
-- GLOBALS: LibStub, GGRL, C_ChatInfo, SendAddonMessage, RegisterAddonMessagePrefix, table, GetInstanceInfo, UnitExists, type, _G, LoadAddOn

local GGRL = LibStub("AceAddon-3.0"):NewAddon("GGRL", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0")

-- 8.0 Compat
if C_ChatInfo then
  SendAddonMessage = C_ChatInfo.SendAddonMessage
end

local _G = _G
local SendAddonMessage = SendAddonMessage
local twipe, type = table.wipe, type
local GetInstanceInfo = GetInstanceInfo
local UnitExists = UnitExists
local LoadAddOn = LoadAddOn

GGRL.Raid = {}
GGRL.loadedBosses = {}
GGRL.timerCount = 0
GGRL.currentBoss = nil
GGRL.currentBossPhase = 1
GGRL.currentInstance = nil

_G["GGRL"] = GGRL

-----------------------------------------------------------------------
-- Utility
--

local function GetBossEvent(table, val)
  for i = 1, #table do
    if table[i][2] == val then
      return table[i]
    end
  end
  return false
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
  -- Antorus
  if self.currentInstance == 1712 then
    self.Raid.Antorus:OnCombatEvent(self.currentBoss, ...)
  end
end

-----------------------------------------------------------------------
-- Addon
--

function GGRL:OnInitialize()
  -- Register Events & ChatCommands
  self:RegisterChatCommand("ggrl", "HandleSlash")
  self:RegisterChatCommand("GGRL", "HandleSlash")

  self:RegisterEvent("ENCOUNTER_START")
  self:RegisterEvent("ENCOUNTER_END")
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "LoadRaid")
end

function GGRL:LoadRaid()
  local _, instanceType, _, _, _, _, _, id = GetInstanceInfo()
  if instanceType == "none" then
    GGRL.currentInstance = nil
    return
  end

  GGRL.currentInstance = id
  -- Load Raid bosses here. (Clear Bosses table before loading the new ones?)
  twipe(self.loadedBosses)
  -- Antorus
  if id == 1712 then
    LoadAddOn("GGRL_Antorus")
    self.Raid.Antorus:Load()
  end
end

function GGRL:LoadBoss(id, timers)
  self.loadedBosses[id] = timers
end

function GGRL:StartEncounterTimer(encounterID)
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self.currentBoss = encounterID
  self.currentBossPhase = 1
  self.combatTimer = GGRL:ScheduleRepeatingTimer("TimerTick", 1)
  self:Print("Timer started")
end

function GGRL:StopEncounterTimer()
  self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self:CancelTimer(self.combatTimer)
  self.currentBoss = nil
  self.timerCount = 0
  self.currentBossPhase = 1
  SendAddonMessage("GGRL_CLEAR", "", "RAID")
end

function GGRL:TimerTick()
  self.timerCount = self.timerCount + 1

  -- Process boss events here and send message
  local event = GetBossEvent(self.loadedBosses[self.currentBoss][self.currentBossPhase], self.timerCount)
  if event then
    --[[ 
      1 type (string)
      2 time (int)
      3 duration (int)
      4 text (string)
      5 target (string)
      6 sound (bool)
      7 soundfile (string)
    ]]
    self:Print(event[1], event[2], event[4])
    --GGRL GGRL_DURATION GGRL_SOUND GGRL_MESSAGE
    if event[1] == "RAID" then SendAddonMessage("GGRL", event[4], "RAID") end

    if event[1] == "WHISPER" and event[5] then
      -- If target is a table then iterate through it and send a whisper to each target.
      if type(event[5]) == "table" then
        for i = 1, #event[5] do
          if (UnitExists(event[5][i])) then
            SendAddonMessage("GGRL", event[4], "WHISPER", event[5][i])
          end
        end
      else
        if (UnitExists(event[5])) then
          SendAddonMessage("GGRL", event[4], "WHISPER", event[5])
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
    LoadAddOn("GGRL_Antorus")
    self.currentInstance = 1712
    self.Raid.Antorus:Load()
    self.currentBoss = 2092
  end
end