local K, C, L = unpack(select(2, ...))
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Tags.lua code!")
	return
end

local _G = _G

local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
local CHAT_MSG_AFK = _G.CHAT_MSG_AFK
local DEAD = _G.DEAD
local DND = _G.DND
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local HEALER = _G.HEALER
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local TANK = _G.TANK
local UNKNOWN = _G.UNKNOWN
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitEffectiveLevel = _G.UnitEffectiveLevel
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsAFK = _G.UnitIsAFK
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDND = _G.UnitIsDND
local UnitIsDead = _G.UnitIsDead
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsGhost = _G.UnitIsGhost
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsRaidOfficer = _G.UnitIsRaidOfficer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitPower = _G.UnitPower
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction
local UnitStagger = _G.UnitStagger

local function ColorPercent(value)
	local r, g, b
	if value < 20 then
		r, g, b = 1, 0.1, 0.1
	elseif value < 35 then
		r, g, b = 1, 0.5, 0
	elseif value < 80 then
		r, g, b = 1, 0.9, 0.3
	else
		r, g, b = 1, 1, 1
	end

	return K.RGBToHex(r, g, b)..value
end

local function ValueAndPercent(cur, per)
	if per < 100 then
		return K.ShortValue(cur).." - "..ColorPercent(per)
	else
		return K.ShortValue(cur)
	end
end

oUF.Tags.Methods["hp"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	else
		local per = oUF.Tags.Methods["perhp"](unit) or 0
		local cur = UnitHealth(unit)
		if (unit == "player" and not UnitHasVehicleUI(unit)) or unit == "target" or unit == "focus" or string.find(unit, "party") then
			return ValueAndPercent(cur, per)
		else
			return ColorPercent(per)
		end
	end
end
oUF.Tags.Events["hp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["power"] = function(unit)
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if (unit == "player" and not UnitHasVehicleUI(unit)) or unit == "target" or unit == "focus" then
		if per < 100 and UnitPowerType(unit) == 0 then
			return K.ShortValue(cur).." - "..per
		else
			return K.ShortValue(cur)
		end
	else
		return per
	end
end
oUF.Tags.Events["power"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["color"] = function(unit)
	local class = select(2, UnitClass(unit))
	local reaction = UnitReaction(unit, "player")

	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return "|cffA0A0A0"
	elseif UnitIsTapDenied(unit) then
		return K.RGBToHex(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) then
		return K.RGBToHex(K.Colors.class[class])
	elseif reaction then
		return K.RGBToHex(K.Colors.reaction[reaction])
	else
		return K.RGBToHex(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["afkdnd"] = function(unit)
	if UnitIsAFK(unit) then
		return "|cffCFCFCF <"..CHAT_MSG_AFK..">|r"
	elseif UnitIsDND(unit) then
		return "|cffCFCFCF <"..DND..">|r"
	else
		return ""
	end
end
oUF.Tags.Events["afkdnd"] = "PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["DDG"] = function(unit)
	if UnitIsDead(unit) then
		return "|cffCFCFCF"..DEAD.."|r"
	elseif UnitIsGhost(unit) then
		return "|cffCFCFCF"..L["Ghost"].."|r"
	elseif not UnitIsConnected(unit) and GetNumArenaOpponentSpecs() == 0 then
		return "|cffCFCFCF"..PLAYER_OFFLINE.."|r"
	end
end
oUF.Tags.Events["DDG"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Level tags
oUF.Tags.Methods["fulllevel"] = function(unit)
	if not UnitIsConnected(unit) then
		return "??"
	end

	local realLevel = UnitLevel(unit)
	local level = UnitEffectiveLevel(unit)
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
		realLevel = level
	end

	local color = K.RGBToHex(GetCreatureDifficultyColor(level))
	local str
	if level > 0 then
		local realTag = level ~= realLevel and "*" or ""
		str = color..level..realTag.."|r"
	else
		str = "|cffff0000??|r"
	end

	local class = UnitClassification(unit)
	if class == "worldboss" then
		str = "|cffAF5050Boss|r"
	elseif class == "rareelite" then
		str = str.."|cffAF5050R|r+"
	elseif class == "elite" then
		str = str.."|cffAF5050+|r"
	elseif class == "rare" then
		str = str.."|cffAF5050R|r"
	end

	return str
end
oUF.Tags.Events["fulllevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

-- RaidFrame tags
oUF.Tags.Methods["raidhp"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	elseif C["Raid"].HealthFormat.Value == 2 then
		local per = oUF.Tags.Methods["perhp"](unit) or 0
		return ColorPercent(per)
	elseif C["Raid"].HealthFormat.Value == 3 then
		local cur = UnitHealth(unit)
		return K.ShortValue(cur)
	elseif C["Raid"].HealthFormat.Value == 4 then
		local loss = UnitHealthMax(unit) - UnitHealth(unit)
		if loss == 0 then return end
		return K.ShortValue(loss)
	end
end
oUF.Tags.Events["raidhp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Nameplate tags
oUF.Tags.Methods["nphp"] = function(unit)
	local per = oUF.Tags.Methods["perhp"](unit) or 0
	if C["Nameplate"].FullHealth then
		local cur = UnitHealth(unit)
		return ValueAndPercent(cur, per)
	elseif per < 100 then
		return ColorPercent(per)
	end
end
oUF.Tags.Events["nphp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["nppp"] = function(unit)
	local per = oUF.Tags.Methods["perpp"](unit)
	local color
	if per > 85 then
		color = K.RGBToHex(1, .1, .1)
	elseif per > 50 then
		color = K.RGBToHex(1, 1, .1)
	else
		color = K.RGBToHex(.8, .8, 1)
	end
	per = color..per.."|r"

	return per
end
oUF.Tags.Events["nppp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

oUF.Tags.Methods["nplevel"] = function(unit)
	local level = UnitLevel(unit)
	if level and level ~= UnitLevel("player") then
		if level > 0 then
			level = K.RGBToHex(GetCreatureDifficultyColor(level))..level.."|r "
		else
			level = "|cffff0000??|r "
		end
	else
		level = ""
	end

	return level
end
oUF.Tags.Events["nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["pppower"] = function(unit)
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if UnitPowerType(unit) == 0 then
		return per
	else
		return cur
	end
end
oUF.Tags.Events["pppower"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["npctitle"] = function(unit)
	if UnitIsPlayer(unit) then return end

	K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetUnit(unit)

	local title = _G[format("KKUI_ScanTooltipTextLeft%d", GetCVarBool("colorblindmode") and 3 or 2)]:GetText()
	if title and not strfind(title, "^"..LEVEL) then
		return title
	end
end
oUF.Tags.Events["npctitle"] = "UNIT_NAME_UPDATE"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		local _, r, g, b = UnitAlternatePowerTextureInfo(unit, 2)
		if not r then
			r, g, b = 1, 1, 1
		end

		return K.RGBToHex(r, g, b)..cur
	else
		return nil
	end
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE"

-- Monk stagger
oUF.Tags.Methods["monkstagger"] = function(unit)
	if unit ~= "player" or K.Class ~= "MONK" then
		return
	end

	local cur = UnitStagger(unit) or 0
	local perc = cur / UnitHealthMax(unit)
	if cur == 0 then
		return
	end

	return K.ShortValue(cur).." - "..K.MyClassColor..K.Round(perc * 100).."%"
end
oUF.Tags.Events["monkstagger"] = "UNIT_MAXHEALTH UNIT_AURA"

oUF.Tags.Methods["leadassist"] = function(unit)
	local isLeader = UnitIsGroupLeader(unit)
	local isAssistant = UnitIsGroupAssistant(unit) or UnitIsRaidOfficer(unit)
	local Assist, Lead = isAssistant and "|cffffd100[A]|r " or "", isLeader and "|cffffd100[L]|r " or ""

	return (Lead..Assist)
end
oUF.Tags.Events["leadassist"] = "UNIT_NAME_UPDATE PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"

oUF.Tags.Methods["lfdrole"] = function(unit)
	local isRole = UnitGroupRolesAssigned(unit)
	local isTank, isHealer, isDamage = isRole == "TANK", isRole == "HEALER", isRole == "DAMAGER"
	local Tank, Healer, Damage = isTank and "|cff0099CC[T]|r " or "", isHealer and "|cff00FF00[H]|r " or "", isDamage and "" or ""

	return (Tank..Healer..Damage)
end
oUF.Tags.Events["lfdrole"] = "UNIT_NAME_UPDATE PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE"