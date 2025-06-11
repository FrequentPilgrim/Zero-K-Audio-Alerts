function widget:GetInfo()
  return {
    name      = "Audio Alert - Commander Damage Sound",
    desc      = "Plays a sound when your commander takes damage (supports all commander types)",
    author    = "FrequentPilgrim",
    date      = "2025-06-09",
    license   = "GNU GPL v2",
    layer     = 0,
    enabled   = true,
  }
end

-- Spring functions
local GetMyTeamID         = Spring.GetMyTeamID
local GetUnitRulesParam   = Spring.GetUnitRulesParam
local GetGameFrame        = Spring.GetGameFrame
local PlaySoundFile       = Spring.PlaySoundFile
local VFS_FileExists      = VFS.FileExists

local UnitDefs            = UnitDefs
local SOUND_FILE          = "LuaUI/sounds/commanderistakingfire.ogg"
local COOLDOWN_FRAMES     = 660  -- 22 seconds * 30 frames per second
local lastPlayFrame       = 0

-- Known commander unitDef name patterns
local commanderPrefixes = {
  "dynrecon", "dynstrike", "dynassault", "dynsupport", "dynknight",
  "dyntrainer", "zk_commander", "zk_custom", "zk_chassis", "comm"
}

-- Commander detection logic
local function IsCommander(unitID, unitDefID)
  local unitDef = UnitDefs[unitDefID]
  if not unitDef then return false end

  local name = unitDef.name or ""
  local isCmd = GetUnitRulesParam(unitID, "iscommander")
  local commtype = GetUnitRulesParam(unitID, "commtype")
  local level = GetUnitRulesParam(unitID, "level")

  if isCmd == 1 then return true end
  if commtype or (level and level > 0) then return true end

  for _, prefix in ipairs(commanderPrefixes) do
    if name:sub(1, #prefix) == prefix then return true end
  end

  if name:find("_base") then return true end

  return false
end

function widget:UnitDamaged(unitID, unitDefID, unitTeam)
  if unitTeam ~= GetMyTeamID() then return end
  if not IsCommander(unitID, unitDefID) then return end

  local currentFrame = GetGameFrame()
  if currentFrame - lastPlayFrame < COOLDOWN_FRAMES then return end

  PlaySoundFile(SOUND_FILE, 1.0)
  lastPlayFrame = currentFrame
end

function widget:Initialize()
  if not VFS_FileExists(SOUND_FILE) then
    widgetHandler:RemoveWidget(self)
  end
end
