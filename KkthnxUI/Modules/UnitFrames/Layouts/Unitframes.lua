local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Unitframes.lua code!")
	return
end

local _G = _G
local unpack = unpack
local select = select
local UnitClass = UnitClass

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local UnitFrame_OnEnter = UnitFrame_OnEnter
local UnitFrame_OnLeave = UnitFrame_OnLeave
local UnitIsPlayer = _G.UnitIsPlayer
local UnitThreatSituation = _G.UnitThreatSituation

local UnitframeFont = K.GetFont(C["Unitframe"].Font)
local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

local function UpdateThreat(self, event, unit)
	if (unit ~= self.unit) then
		return
	end

	local situation = UnitThreatSituation(unit)
	if (situation and situation > 0) then
		local r, g, b = GetThreatStatusColor(situation)
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(r, g, b, 1)
		else
			self.Portrait.Background:SetBackdropBorderColor(r, g, b, 1)
		end
		self.Health:SetBackdropBorderColor(r, g, b, 1)
	elseif C["General"].ColorTextures then
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3], 1)
		else
			self.Portrait.Background:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		end
		self.Health:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
	else
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 1)
		else
			self.Portrait.Background:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end
		self.Health:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
	end
end

local function UpdateClassPortraits(self, unit)
	local _, unitClass = UnitClass(unit)
	if (unitClass and UnitIsPlayer(unit)) and C["Unitframe"].PortraitStyle.Value == "ClassPortraits" then
		self:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
		self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
	elseif (unitClass and UnitIsPlayer(unit)) and C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
		self:SetTexture(C["Media"].NewClassPortraits)
		self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
	else
		self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	end
end

local function oUF_KkthnxUnitframes(self, unit)
	unit = unit:match("^(.-)%d+") or unit

	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", UnitFrame_OnEnter)
	self:HookScript("OnLeave", UnitFrame_OnLeave)

	-- Health bar
	self.Health = CreateFrame("StatusBar", "$parent.Healthbar", self)
	self.Health:SetTemplate("Transparent")
	self.Health:SetFrameStrata("LOW")
	self.Health:SetFrameLevel(1)
	self.Health:SetStatusBarTexture(UnitframeTexture)

	if C["General"].ColorTextures and self then
		self.Health:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
	end

	self.Health.Smooth = C["Unitframe"].Smooth
	self.Health.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true
	self.Health.PreUpdate = K.PreUpdateHealth
	self.Health.PostUpdate = K.PostUpdateHealth

	if (unit == "player") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent]")
	elseif (unit == "pet") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", 15, 7)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetTextColor(1.0, 1.0, 1.0)
		self.Health.Value:SetJustifyH("LEFT")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	elseif (unit == "target") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", -26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "focus") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "targettarget") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", -15, 7)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	elseif (unit == "focustarget") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", 15, 7)
	elseif (unit == "party") then
		self.Health:SetSize(96, 16)
		self.Health:SetPoint("CENTER", self, "CENTER", 18, 8)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "boss" or unit == "arena") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	end

	-- Power Bar
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetTemplate("Transparent")
	self.Power:SetFrameStrata("LOW")
	self.Power:SetFrameLevel(1)
	self.Power:SetStatusBarTexture(UnitframeTexture)

	if C["General"].ColorTextures and self then
		self.Power:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
	end

	self.Power.Smooth = C["Unitframe"].Smooth
	self.Power.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Power.colorPower = true
	self.Power.frequentUpdates = true
	self.Power.PostUpdate = K.PostUpdatePower

	if C["Unitframe"].PowerClass then
		self.Power.colorClass = true
		self.Power.colorReaction = true
	else
		self.Power.colorPower = true
	end

	-- Power StatusBar
	if unit == "player" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power Value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif unit == "pet" then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power Value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 10, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 2, 0)
	elseif unit == "target" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", -2, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif unit == "focus" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", -2, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif (unit == "targettarget") then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "focustarget") then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "party") then
		self.Power:SetSize(96, 10)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "boss" or unit == "arena") then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	end

	-- Name Text
	if (unit == "target") then
		self.Name = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 18)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameAbbreviateMedium]")
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 16, C["Unitframe"].Outline and "OUTLINE" or "", "LEFT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")
	elseif unit == "focus" then
		self.Name = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 18)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 16, C["Unitframe"].Outline and "OUTLINE" or "", "RIGHT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:Level]")
	elseif (unit == "targettarget" or unit == "focustarget") then
		self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("BOTTOM", self.Power, "BOTTOM", 0, -17)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameShort]")
	elseif (unit == "party") then
		self.Name = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 18)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
	elseif (unit == "boss" or unit == "arena") then
		self.Name = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 18)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
	end

	-- 3D and such models. We provide 3 choices here.
	if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
		-- Create the portrait globally
		self.Portrait = CreateFrame("PlayerModel", self:GetName().."_3DPortrait", self)
		self.Portrait:SetTemplate("Transparent")
		self.Portrait:SetFrameStrata("BACKGROUND")
		self.Portrait:SetFrameLevel(1)

		if C["General"].ColorTextures and self then
			self.Portrait:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		end

		if (unit == "player" or unit == "focus" or unit == "boss" or unit == "arena") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "pet") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "target") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "targettarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "focustarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "party") then
			self.Portrait:SetSize(32, 32)
			self.Portrait:SetPoint("LEFT", self, 2, 0)
		end
	elseif C["Unitframe"].PortraitStyle.Value == "DefaultPortraits" or C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
		self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 7)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)

		-- We need to create this for non 3D Ports
		self.Portrait.Background = CreateFrame("Frame", self:GetName().."_2DPortrait", self)
		self.Portrait.Background:SetTemplate("Transparent")
		self.Portrait.Background:SetFrameStrata("LOW")
		self.Portrait.Background:SetFrameLevel(1)

		if (unit == "player" or unit == "focus" or unit == "boss" or unit == "arena") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(46, 46)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "pet") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "target") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
			self.Portrait.Background:SetSize(46, 46)
			self.Portrait.Background:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "targettarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "focustarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "party") then
			self.Portrait:SetSize(32, 32)
			self.Portrait:SetPoint("LEFT", self, 2, 0)
			self.Portrait.Background:SetSize(32, 32)
			self.Portrait.Background:SetPoint("LEFT", self, 2, 0)
		end

		if C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
			self.Portrait.PostUpdate = UpdateClassPortraits
		end
	end

	self.HealthPrediction = K.CreateHealthPrediction(self)

	-- Castbars
	if C["Unitframe"].Castbars == true then
		K.CreateCastBar(self, unit)
	end

	-- Auras
	if unit ~= "player" then
		K.CreateAuras(self, unit)
	end

	-- Create our class resource bars, combo and such.
	if (unit == "player") then
		K.CreateClassModules(self, 194, 12, 6)
		if K.Class == "DEATHKNIGHT" then
			K.CreateClassRunes(self, 194, 12, 6)
		end
		K.CreateAlternatePowerBar(self, unit)
	end

	if (unit ~= "arena") then
		self.ThreatIndicator = CreateFrame("Frame")
		self.ThreatIndicator:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 0) -- so that oUF does not try to replace it
		self.ThreatIndicator.Override = UpdateThreat
	end

	-- Status Icons
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.LeaderIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PvPIndicator = self:CreateTexture(nil, "ARTWORK", nil, 1)
	self.PvPIndicator:SetSize(30, 30)
	if (unit == "player" or unit == "focus") then
		self.LeaderIndicator:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPLEFT", 13, -6)
		self.LeaderIndicator:SetSize(16, 16)
		-- Master Looter / Group Role / Combat Icon
		self.MasterLooterIndicator = self:CreateTexture(nil, "OVERLAY")
		self.MasterLooterIndicator:SetSize(16, 16)
		self.MasterLooterIndicator:SetPoint("TOP", self, "TOP" , 18, -20)

		self.GroupRoleIndicator = self:CreateTexture(nil, "OVERLAY")
		self.GroupRoleIndicator:SetSize(16, 16)
		self.GroupRoleIndicator:SetPoint("BOTTOMLEFT", self.Portrait, "TOPRIGHT" , -4, -8)

		self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY", 1)
		self.CombatIndicator:SetSize(24, 24)
		self.CombatIndicator:SetPoint("LEFT", 0, 0)
		self.CombatIndicator:SetVertexColor(0.69, 0.31, 0.31)
		-- RaidTarget Indicator
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 16)
		-- PvP Indicator
		self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", 0, 0)
	elseif (unit == "target") then
		self.LeaderIndicator:SetPoint("BOTTOMLEFT", self.Portrait, "TOPRIGHT", -12, -6)
		self.LeaderIndicator:SetSize(16, 16)
		-- Master Looter / Group Role / Combat Icon
		self.MasterLooterIndicator = self:CreateTexture(nil, "OVERLAY")
		self.MasterLooterIndicator:SetSize(16, 16)
		self.MasterLooterIndicator:SetPoint("TOP", self, "TOP" , -18, -20)

		self.GroupRoleIndicator = self:CreateTexture(nil, "OVERLAY")
		self.GroupRoleIndicator:SetSize(16, 16)
		self.GroupRoleIndicator:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPLEFT" , 4, -8)
		-- Phase Indicator
		self.PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PhaseIndicator:SetSize(16, 16)
		self.PhaseIndicator:SetPoint("BOTTOMRIGHT", self.Health, "TOPLEFT", 9, -9)
		-- RaidTarget Indicator
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 14)
		-- PvP Indicator
		self.PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 0, 0)
		-- Questmob Icon
		self.QuestIndicator = self:CreateTexture(nil, "OVERLAY")
		self.QuestIndicator:SetSize(22, 22)
		self.QuestIndicator:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPLEFT" , 9, -12)
	elseif (unit == "focustarget" or unit == "targettarget") then
		self.LeaderIndicator:SetPoint("BOTTOMLEFT", self.Portrait, "TOPRIGHT", -10, -6)
		self.LeaderIndicator:SetSize(14, 14)
		-- RaidTarget Indicator
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 14)
		-- PvP Indicator
		self.PvPIndicator:SetSize(20, 20)
		self.PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 0, 0)
	elseif (unit == "party") then
		self.LeaderIndicator:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPLEFT", 10, -4)
		self.LeaderIndicator:SetSize(12, 12)
		-- Group Role Indicator
		self.GroupRoleIndicatorText = self:CreateFontString(nil, "ARTWORK")
		self.GroupRoleIndicatorText:SetPoint("TOP", self.Portrait, "BOTTOM", 0, -2)
		self.GroupRoleIndicatorText:SetFont(C["Media"].Font, 10, C["Raidframe"].Outline and "OUTLINE" or "")
		self.GroupRoleIndicatorText:SetShadowOffset(C["Raidframe"].Outline and 0 or K.Mult, C["Raidframe"].Outline and -0 or -K.Mult)
		self:Tag(self.GroupRoleIndicatorText, "[KkthnxUI:PartyRole]")
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 14)
	end

	self.ReadyCheckIndicator = self:CreateTexture()
	self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait, "CENTER", 0, 0)
	self.ReadyCheckIndicator:SetSize(self.Portrait:GetWidth() - 2, self.Portrait:GetHeight() - 2)

	-- Resting Icon for player frame
	if unit == "player" then
		-- Resting icon
		self.RestingIndicator = self:CreateTexture(nil, "OVERLAY")
		self.RestingIndicator:SetPoint("TOPRIGHT", self, 6, 6)
		self.RestingIndicator:SetSize(22, 22)

		-- PvP Timer
		if (self.PvPIndicator) then
			self.PvPTimer = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
			self.PvPTimer:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			self.PvPTimer:SetTextColor(1, 0.819, 0)
			self.PvPTimer:SetPoint("BOTTOM", self.PvPIndicator, "TOP", 0, 2)
			self:Tag(self.PvPTimer, "[KkthnxUI:PvPTimer]")
		end

		-- GlobalCooldown spark
		if (C["Unitframe"].GlobalCooldown) then
			self.GCD = CreateFrame("Frame", self:GetName().."_GCD", self.Health)
			self.GCD:SetWidth(self.Health:GetWidth())
			self.GCD:SetHeight(self.Health:GetHeight() * 1.4)
			self.GCD:SetFrameStrata("HIGH")
			self.GCD:SetPoint("LEFT", self.Health, "LEFT", 0, 0)
			self.GCD.Smooth = C["Unitframe"].Smooth
			self.GCD.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
			self.GCD.Color = {1, 1, 1}
			self.GCD.Height = (self.Health:GetHeight() * 1.4)
			self.GCD.Width = (10)
		end

		-- Power Prediction Bar (Display estimated cost of spells when casting)
		if (C["Unitframe"].PowerPredictionBar) then
			local PowerPrediction = CreateFrame("StatusBar", nil, self.Power)
			PowerPrediction:SetPoint("RIGHT", self.Power:GetStatusBarTexture())
			PowerPrediction:SetPoint("BOTTOM")
			PowerPrediction:SetPoint("TOP")
			PowerPrediction:SetWidth(self.Power:GetWidth())
			PowerPrediction:SetHeight(self.Power:GetHeight())
			PowerPrediction:SetStatusBarTexture(UnitframeTexture, "BORDER")
			PowerPrediction:GetStatusBarTexture():SetBlendMode("ADD")
			PowerPrediction:SetStatusBarColor(0.55, 0.75, 0.95, 0.5)
			PowerPrediction:SetReverseFill(true)
			PowerPrediction.Smooth = C["Unitframe"].Smooth
			PowerPrediction.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
			self.PowerPrediction = {
				mainBar = PowerPrediction
			}
		end
	end

	if (unit == "player" or unit == "target") then
		-- Combat CombatFeedbackText
		if (C["Unitframe"].CombatText) then
			local CombatFeedbackText = self:CreateFontString(nil, "OVERLAY", 7)
			CombatFeedbackText:SetFont(C["Media"].Font, 14, "OUTLINE")
			CombatFeedbackText:SetShadowOffset(0, -0)
			CombatFeedbackText:SetPoint("CENTER", self.Portrait)
			CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}

			self.CombatFeedbackText = CombatFeedbackText
		end
	end

	-- Portrait Timer
	if (C["Unitframe"].PortraitTimer == true and self.Portrait) then
		self.PortraitTimer = CreateFrame("Frame", nil, self.Health)
		self.PortraitTimer.Icon = self.PortraitTimer:CreateTexture(nil, "BACKGROUND")
		self.PortraitTimer.Icon:SetAllPoints(self.Portrait)
		self.PortraitTimer.Remaining = K.SetFontString(self.PortraitTimer, C["Media"].Font, self.Portrait:GetSize() / 2, C["Media"].FontStyle, "CENTER")
		self.PortraitTimer.Remaining:SetShadowOffset(0, 0)
		self.PortraitTimer.Remaining:SetPoint("CENTER", self.PortraitTimer.Icon)
	end

	self.Range = {
		insideAlpha = 1,
		outsideAlpha = C["Unitframe"].OORAlpha,
	}

	return self
end

oUF:RegisterStyle("oUF_KkthnxUnitframes", oUF_KkthnxUnitframes)
oUF:SetActiveStyle("oUF_KkthnxUnitframes")

local player = oUF:Spawn("player", "oUF_KkthnxPlayer")
player:SetSize(190, 52)
player:SetScale(C["Unitframe"].Scale)
player:SetPoint(unpack(C.Position.UnitFrames.Player))
K.Movers:RegisterFrame(player)

local pet = oUF:Spawn("pet", "oUF_KkthnxPet")
pet:SetSize(116, 36)
pet:SetScale(C["Unitframe"].Scale)
pet:SetPoint(unpack(C.Position.UnitFrames.Pet))
K.Movers:RegisterFrame(pet)

local target = oUF:Spawn("target", "oUF_KkthnxTarget")
target:SetSize(190, 52)
target:SetScale(C["Unitframe"].Scale)
target:SetPoint(unpack(C.Position.UnitFrames.Target))
K.Movers:RegisterFrame(target)

local targettarget = oUF:Spawn("targettarget", "oUF_KkthnxTargetTarget")
targettarget:SetSize(116, 36)
targettarget:SetScale(C["Unitframe"].Scale)
targettarget:SetPoint(unpack(C.Position.UnitFrames.TargetTarget))
K.Movers:RegisterFrame(targettarget)

local focus = oUF:Spawn("focus", "oUF_KkthnxFocus")
focus:SetSize(190, 52)
focus:SetScale(C["Unitframe"].Scale)
focus:SetPoint(unpack(C.Position.UnitFrames.Focus))
K.Movers:RegisterFrame(focus)

local focustarget = oUF:Spawn("focustarget", "oUF_KkthnxFocusTarget")
focustarget:SetSize(116, 36)
focustarget:SetScale(C["Unitframe"].Scale)
focustarget:SetPoint(unpack(C.Position.UnitFrames.FocusTarget))
K.Movers:RegisterFrame(focustarget)

if (C["Unitframe"].Party) then
	local party = oUF:SpawnHeader("oUF_KkthnxParty", nil, (C["Raidframe"].RaidAsParty and "custom [group:party][group:raid] hide;show") or "custom [@raid6, exists] hide; show",
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"initial-width", 140,
	"initial-height", 38,
	"showSolo", false,
	"showParty", true,
	"showRaid", false,
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", "GROUP",
	"showPlayer", C["Unitframe"].ShowPlayer, -- Need to add this as an option.
	"yOffset", -40
	)
	party:SetPoint(unpack(C.Position.UnitFrames.Party))
	party:SetScale(C["Unitframe"].Scale)
	K.Movers:RegisterFrame(party)
end

if (C["Unitframe"].ShowBoss) then
	local Boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		Boss[i] = oUF:Spawn("boss"..i, "oUF_KkthnxBossFrame"..i)
		Boss[i]:SetParent(K.PetBattleHider)

		Boss[i]:SetSize(190, 52)
		Boss[i]:SetScale(C["Unitframe"].Scale)
		if (i == 1) then
			Boss[i]:SetPoint(unpack(C.Position.UnitFrames.Boss))
		else
			Boss[i]:SetPoint("TOPLEFT", Boss[i-1], "BOTTOMLEFT", 0, -45)
		end
		K.Movers:RegisterFrame(Boss[i])
	end
end

if (C["Unitframe"].ShowArena) then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "oUF_KkthnxArenaFrame"..i)
		arena[i]:SetSize(190, 52)
		arena[i]:SetScale(C["Unitframe"].Scale)
		if (i == 1) then
			arena[i]:SetPoint(unpack(C.Position.UnitFrames.Arena))
		else
			arena[i]:SetPoint("TOPLEFT", arena[i-1], "BOTTOMLEFT", 0, -45)
		end
		K.Movers:RegisterFrame(arena[i])
	end
end

-- Test UnitFrames(by community)
local moving = false
SlashCmdList.TEST_UF = function(msg)
	if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
	if not moving then
		for _, frames in pairs({"oUF_KkthnxTarget", "oUF_KkthnxTargetTarget", "oUF_KkthnxPet", "oUF_KkthnxFocus"}) do
			_G[frames].oldunit = _G[frames].unit
			_G[frames]:SetAttribute("unit", "player")
		end

		if C["Unitframe"].ShowArena == true then
			for i = 1, 5 do
				_G["oUF_KkthnxArenaFrame"..i].oldunit = _G["oUF_KkthnxArenaFrame"..i].unit
				_G["oUF_KkthnxArenaFrame"..i]:SetAttribute("unit", "player")
			end
		end

		if C["Unitframe"].ShowBoss == true then
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_KkthnxBossFrame"..i].oldunit = _G["oUF_KkthnxBossFrame"..i].unit
				_G["oUF_KkthnxBossFrame"..i]:SetAttribute("unit", "player")
			end
		end
		moving = true
	else
		for _, frames in pairs({"oUF_KkthnxTarget", "oUF_KkthnxTargetTarget", "oUF_KkthnxPet", "oUF_KkthnxFocus"}) do
			_G[frames]:SetAttribute("unit", _G[frames].oldunit)
		end

		if C["Unitframe"].ShowArena == true then
			for i = 1, 5 do
				_G["oUF_KkthnxArenaFrame"..i]:SetAttribute("unit", _G["oUF_KkthnxArenaFrame"..i].oldunit)
			end
		end

		if C["Unitframe"].ShowBoss == true then
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_KkthnxBossFrame"..i]:SetAttribute("unit", _G["oUF_KkthnxBossFrame"..i].oldunit)
			end
		end
		moving = false
	end
end