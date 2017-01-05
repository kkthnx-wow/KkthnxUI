local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true and C.Raidframe.Enable ~= true then return end

-- Lua API
local abs = math.abs
local format = string.format
local min, max = math.min, math.max
local pairs = pairs
local select = select
local tinsert = table.insert
local type = type
local unpack = unpack

-- Wow API
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsFriend = UnitIsFriend
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitSelectionColor = UnitSelectionColor

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: PLAYER_OFFLINE, DEAD, UnitFrame_OnLeave, UnitFrame_OnEnter

local _, ns = ...
local oUF = ns.oUF or oUF
local colors = K.Colors

function K.MatchUnit(unit)
	if (unit:match("vehicle")) then
		return "player"
	elseif (unit:match("party%d")) then
		return "party"
	elseif (unit:match("arena%d")) then
		return "arena"
	elseif (unit:match("boss%d")) then
		return "boss"
	elseif (unit:match("partypet%d")) then
		return "pet"
	else
		return unit
	end
end

function K.MultiCheck(what, ...)
	for i = 1, select("#", ...) do
		if (what == select(i, ...)) then
			return true
		end
	end

	return false
end

local function UpdatePortraitColor(self, unit, cur, max)
	if (not UnitIsConnected(unit)) then
		self.Portrait:SetVertexColor(0.5, 0.5, 0.5, 0.7)
	elseif (UnitIsDead(unit)) then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 0.7)
	elseif (UnitIsGhost(unit)) then
		self.Portrait:SetVertexColor(0.3, 0.3, 0.9, 0.7)
	elseif (cur / max * 100 < 25) then
		if (UnitIsPlayer(unit)) then
			if (self.MatchUnit ~= "player") then
				self.Portrait:SetVertexColor(1, 0, 0, 0.7)
			end
		end
	else
		self.Portrait:SetVertexColor(1, 1, 1, 1)
	end
end

local TEXT_PERCENT, TEXT_SHORT, TEXT_LONG, TEXT_MINMAX, TEXT_MAX, TEXT_DEF, TEXT_NONE = 0, 1, 2, 3, 4, 5, 6
local function SetValueText(element, tag, cur, max, notMana)
	if (not max or max == 0) then max = 100 end -- </ not sure why this happens > --

	if (tag == TEXT_PERCENT) and (max < 200) then
		tag = TEXT_SHORT -- </ Shows energy etc. with real number > --
	end

	local s

	if tag == TEXT_SHORT then
		s = format("%s", cur > 0 and K.ShortValue(cur) or "")
	elseif tag == TEXT_LONG then
		s = format("%s - %.1f%%", K.ShortValue(cur), cur / max * 100)
	elseif tag == TEXT_MINMAX then
		s = format("%s/%s", K.ShortValue(cur), K.ShortValue(max))
	elseif tag == TEXT_MAX then
		s = format("%s", K.ShortValue(max))
	elseif tag == TEXT_DEF then
		s = format("%s", (cur == max and "" or "-"..K.ShortValue(max - cur)))
	elseif tag == TEXT_PERCENT then
		s = format("%d%%", cur / max * 100)
	else
		s = ""
	end

	element:SetFormattedText("|cff%02x%02x%02x%s|r", 1 * 255, 1 * 255, 1 * 255, s)
end

-- </ PostHealth update > --
do
	local tagtable = {
		NUMERIC = {TEXT_MINMAX, TEXT_SHORT, TEXT_MAX},
		BOTH	= {TEXT_MINMAX, TEXT_LONG, TEXT_MAX},
		PERCENT = {TEXT_SHORT, TEXT_PERCENT, TEXT_PERCENT},
		MINIMAL = {TEXT_SHORT, TEXT_PERCENT, TEXT_NONE},
		DEFICIT = {TEXT_DEF, TEXT_DEF, TEXT_NONE},
	}

	function K.PostUpdateHealth(Health, unit, cur, max)
		if not unit then return end -- </ Blizz bug in 7.1 > --

		local absent = not UnitIsConnected(unit) and PLAYER_OFFLINE or UnitIsGhost(unit) and GetSpellInfo(8326) or UnitIsDead(unit) and DEAD
		local self = Health:GetParent()
		local uconfig = ns.config[self.MatchUnit]

		if (self.Portrait) then
			UpdatePortraitColor(self, unit, cur, max)
		end

		if (self.Name) and (self.Name.Bg) then -- </ For boss frames > --
			self.Name.Bg:SetVertexColor(UnitSelectionColor(unit))
		end

		if absent then
			Health:SetStatusBarColor(0.5, 0.5, 0.5)
			if Health.Value then
				Health.Value:SetText(absent)
			end
			return
		end

		if not cur then
			cur = UnitHealth(unit)
			max = UnitHealthMax(unit) or 1
		end

		if uconfig.HealthTag == "DISABLE" then
			Health.Value:SetText(nil)
		elseif self.isMouseOver then
			SetValueText(Health.Value, tagtable[uconfig.HealthTag][1], cur, max, 1, 1, 1)
		elseif cur < max then
			SetValueText(Health.Value, tagtable[uconfig.HealthTag][2], cur, max, 1, 1, 1)
		else
			SetValueText(Health.Value, tagtable[uconfig.HealthTag][3], cur, max, 1, 1, 1)
		end
	end
end

-- </ PostPower update > --
do
	local tagtable = {
		NUMERIC	= {TEXT_MINMAX, TEXT_SHORT, TEXT_MAX},
		PERCENT	= {TEXT_SHORT, TEXT_PERCENT, TEXT_PERCENT},
		MINIMAL	= {TEXT_SHORT, TEXT_PERCENT, TEXT_NONE},
	}

	function K.PostUpdatePower(Power, unit, cur, max)
		local self = Power:GetParent()
		local uconfig = ns.config[self.MatchUnit]

		if (UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)) or (max == 0) then
			Power:SetValue(0)
			if Power.Value then
				Power.Value:SetText("")
			end
			return
		end

		if not Power.Value then return end

		if (not cur) then
			max = UnitPower(unit) or 1
			cur = UnitPowerMax(unit)
		end

		if uconfig.PowerTag == "DISABLE" then
			Power.Value:SetText(nil)
		elseif self.isMouseOver then
			SetValueText(Power.Value, tagtable[uconfig.PowerTag][1], cur, max, 1, 1, 1)
		elseif cur < max then
			SetValueText(Power.Value, tagtable[uconfig.PowerTag][2], cur, max, 1, 1, 1)
		else
			SetValueText(Power.Value, tagtable[uconfig.PowerTag][3], cur, max, 1, 1, 1)
		end
	end
end

-- </ Mouseover enter > --
function K.UnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end
	if not self:IsEnabled() then return end -- </ arena prep > --

	UnitFrame_OnEnter(self)

	self.isMouseOver = true
	if self.mouseovers then
		for _, text in pairs (self.mouseovers) do
			text:ForceUpdate()
		end
	end

	if (self.AdditionalPower and self.AdditionalPower.Value) then
		self.AdditionalPower.Value:Show()
	end
end

-- </ Mouseover leave > --
function K.UnitFrame_OnLeave(self)
	if self.__owner then
		self = self.__owner
	end
	if not self:IsEnabled() then return end -- </ arena prep > --
	UnitFrame_OnLeave(self)

	self.isMouseOver = nil
	if self.mouseovers then
		for _, text in pairs (self.mouseovers) do
			text:ForceUpdate()
		end
	end

	if (self.AdditionalPower and self.AdditionalPower.Value) then
		self.AdditionalPower.Value:Hide()
	end
end

-- </ Statusbar functions > --
function K.CreateStatusBar(parent, layer, name, AddBackdrop)
	if type(layer) ~= "string" then layer = "BORDER" end
	local bar = CreateFrame("StatusBar", name, parent)
	bar:SetStatusBarTexture(C.Media.Texture, layer)
	bar.texture = C.Media.Texture

	if AddBackdrop then
		bar:SetBackdrop({bgFile = C.Media.Blank})
		local r,g,b,a = unpack(C.Media.Backdrop_Color)
		bar:SetBackdropColor(r, g, b, a)
	end

	return bar
end

K.RaidBuffsTrackingPosition = {
	TOPLEFT = {6, 1},
	TOPRIGHT = {-6, 1},
	BOTTOMLEFT = {6, 1},
	BOTTOMRIGHT = {-6, 1},
	LEFT = {6, 1},
	RIGHT = {-6, 1},
	TOP = {0, 0},
	BOTTOM = {0, 0},
}

function K.CreateAuraWatchIcon(self, icon)
	icon:SetBackdrop(K.TwoPixelBorder)
	icon.icon:SetPoint("TOPLEFT", 1, -1)
	icon.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon.icon:SetDrawLayer("ARTWORK")

	if (icon.cd) then
		icon.cd:SetHideCountdownNumbers(true)
		icon.cd:SetReverse(true)
	end

	icon.overlay:SetTexture()
end

-- </ Create the icon > --
function K.CreateAuraWatch(self)
	local Class = select(2, UnitClass("player"))
	local Auras = CreateFrame("Frame", nil, self)
	Auras:SetPoint("TOPLEFT", self.Health, 2, -2)
	Auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
	Auras.presentAlpha = 1
	Auras.missingAlpha = 0
	Auras.icons = {}
	Auras.PostCreateIcon = K.CreateAuraWatchIcon
	Auras.strictMatching = true

	if (not C.Raidframe.AuraWatchTimers) then
		Auras.hideCooldown = true
	end

	local buffs = {}
	if (K.RaidBuffsTracking["ALL"]) then
		for key, value in pairs(K.RaidBuffsTracking["ALL"]) do
			tinsert(buffs, value)
		end
	end

	if (K.RaidBuffsTracking[Class]) then
		for key, value in pairs(K.RaidBuffsTracking[Class]) do
			tinsert(buffs, value)
		end
	end

	-- </ Cornerbuffs > --
	if buffs then
		for key, spell in pairs(buffs) do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon:SetWidth(6)
			Icon:SetHeight(6)
			Icon:SetPoint(spell[2], 0, 0)
			local Texture = Icon:CreateTexture(nil, "OVERLAY")
			Texture:SetAllPoints(Icon)
			Texture:SetTexture(C.Media.Blank)

			if (spell[3]) then
				Texture:SetVertexColor(unpack(spell[3]))
			else
				Texture:SetVertexColor(0.8, 0.8, 0.8)
			end

			local Count = Icon:CreateFontString(nil, "OVERLAY")
			Count:SetFont(C.Media.Font, 9, "THINOUTLINE")
			Count:SetPoint("CENTER", unpack(K.RaidBuffsTrackingPosition[spell[2]]))
			Icon.count = Count
			Auras.icons[spell[1]] = Icon
		end
	end

	self.AuraWatch = Auras
end

-- Castbar functions
function K:PostCastStart(unit, name, rank, castid)
	if unit == "vehicle" then unit = "player" end
	if unit == "focus" and UnitIsUnit("focus", "target") then
		self.duration = self.casting and self.max or 0
		return
	end

	if unit == "player" and C.Unitframe.CastbarLatency == true and self.Latency then
		local _, _, _, lag = GetNetStats()
		local latency = GetTime() - (self.castSent or 0)
		lag = lag / 1e3 > self.max and self.max or lag / 1e3
		latency = latency > self.max and lag or latency
		self.Latency:SetText(("%dms"):format(latency * 1e3))
		self.castSent = nil
	end

	local color
	if UnitIsUnit(unit, "player") then
		color = K.Colors.class[K.Class]
	elseif self.interrupt then
		color = K.Colors.uninterruptible
	elseif UnitIsFriend(unit, "player") then
		color = K.Colors.reaction[5]
	else
		color = K.Colors.reaction[1]
	end
	local r, g, b = color[1], color[2], color[3]
	self:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
	self.Background:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)

	local safezone = self.SafeZone
	if safezone then
		local width = safezone:GetWidth()
		if width and width > 0 and width <= self:GetWidth() then
			self:GetStatusBarTexture():SetDrawLayer("ARTWORK")
			safezone:SetDrawLayer("BORDER")
			safezone:SetWidth(width)
		else
			safezone:Hide()
		end
	end

	self.__castType = "CAST"
end

function K:PostChannelStart(unit, name, rank, text)
	if unit == "vehicle" then unit = "player" end

	if unit == "player" and C.Unitframe.CastbarLatency == true and self.Latency then
		local _, _, _, lag = GetNetStats()
		local latency = GetTime() - (self.castSent or 0)
		lag = lag / 1e3 > self.max and self.max or lag / 1e3
		latency = latency > self.max and lag or latency
		self.Latency:SetText(("%dms"):format(latency * 1e3))
		self.castSent = nil
	end

	local color
	if UnitIsUnit(unit, "player") then
		color = K.Colors.class[K.Class]
	elseif self.interrupt then
		color = K.Colors.reaction[4]
	elseif UnitIsFriend(unit, "player") then
		color = K.Colors.reaction[5]
	else
		color = K.Colors.reaction[1]
	end
	local r, g, b = color[1], color[2], color[3]
	self:SetStatusBarColor(r * 0.6, g * 0.6, b * 0.6)
	self.Background:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)

	local safezone = self.SafeZone
	if safezone then
		local width = safezone:GetWidth()
		if width and width > 0 and width <= self:GetWidth() then
			self:GetStatusBarTexture():SetDrawLayer("BORDER")
			safezone:SetDrawLayer("ARTWORK")
			safezone:SetWidth(width)
		else
			safezone:Hide()
		end
	end

	self.__castType = "CHANNEL"
end

function K:CustomDelayText(duration)
	self.Time:SetFormattedText("%.1f|cffff0000%.1f|r", self.max - duration, -self.delay)
end

function K:CustomTimeText(duration)
	self.Time:SetFormattedText("%.1f", self.max - duration)
end