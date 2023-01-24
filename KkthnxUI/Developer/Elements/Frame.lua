local K, C = unpack(KkthnxUI)

local _G = _G
local math_ceil = _G.math.ceil
local math_floor = _G.math.floor
local print = _G.print
local string_find = _G.string.find
local string_format = _G.string.format
local string_split = _G.string.split
local table_wipe = _G.table.wipe
local tostring = _G.tostring

local C_ChatInfo_RegisterAddonMessagePrefix = _G.C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = _G.C_ChatInfo.SendAddonMessage
local DESCRIPTION = _G.DESCRIPTION
local EJ_GetCurrentTier = _G.EJ_GetCurrentTier
local EJ_GetEncounterInfoByIndex = _G.EJ_GetEncounterInfoByIndex
local EJ_GetInstanceInfo = _G.EJ_GetInstanceInfo
local EJ_SelectInstance = _G.EJ_SelectInstance
local EnumerateFrames = _G.EnumerateFrames
local GetInstanceInfo = _G.GetInstanceInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetSpellDescription = _G.GetSpellDescription
local GetSpellInfo = _G.GetSpellInfo
local GetSpellTexture = _G.GetSpellTexture
local IsInGuild = _G.IsInGuild
local IsInRaid = _G.IsInRaid
local MouseIsOver = _G.MouseIsOver
local NAME = _G.NAME
local SlashCmdList = _G.SlashCmdList
local UNKNOWN = _G.UNKNOWN
local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName

-- KkthnxUI DevTools:
-- /getenc, get selected encounters info
-- /getid, get instance id
-- /getnpc, get npc name and id
-- /kf, get frame names
-- /kg, show grid on WorldFrame
-- /ks, get spell name and description
-- /kt, get gametooltip names

-- Commands
SlashCmdList["KKTHNXUI_ENUMTIP"] = function()
	-- Enumerate all frames on the screen
	local enumf = EnumerateFrames()
	while enumf do
		-- Check if the frame is a GameTooltip or has "tip" in its name (case-insensitive)
		-- and if it is visible and has a defined position
		if (enumf:GetObjectType() == "GameTooltip" or string.find((enumf:GetName() or ""):lower(), "tip")) and enumf:IsVisible() and enumf:GetPoint() then
			-- Print the name of the frame
			print(enumf:GetName())
		end

		-- Get the next frame
		enumf = EnumerateFrames(enumf)
	end
end
_G.SLASH_KKTHNXUI_ENUMTIP1 = "/gettip"
_G.SLASH_KKTHNXUI_ENUMTIP2 = "/gettooltip"

SlashCmdList["KKTHNXUI_ENUMFRAME"] = function()
	local frame = EnumerateFrames()
	local chatModule = K:GetModule("Chat")
	while frame do
		if frame:IsVisible() and MouseIsOver(frame) then
			print(frame:GetName() or string_format(UNKNOWN .. ": [%s]", tostring(frame)))
			chatModule:ChatCopy_OnClick("LeftButton")
		end

		frame = EnumerateFrames(frame)
	end
end
_G.SLASH_KKTHNXUI_ENUMFRAME1 = "/getframe"

SlashCmdList["KKTHNXUI_DUMPSPELL"] = function(arg)
	local name = GetSpellInfo(arg)
	if not name then
		print("Please enter a spell name --> /getspell SPELLNAME")
		return
	end

	local des = GetSpellDescription(arg)
	print(K.InfoColor .. "------------------------")
	print(" \124T" .. GetSpellTexture(arg) .. ":16:16:::64:64:5:59:5:59\124t", K.InfoColor .. arg)
	print(NAME, K.InfoColor .. (name or "nil"))
	print(DESCRIPTION, K.InfoColor .. (des or "nil"))
	print(K.InfoColor .. "------------------------")
end
_G.SLASH_KKTHNXUI_DUMPSPELL1 = "/getspell"

SlashCmdList["INSTANCEID"] = function()
	local name, _, _, _, _, _, _, id = GetInstanceInfo()
	print(name, id)
end
_G.SLASH_INSTANCEID1 = "/getinstance"

SlashCmdList["KKTHNXUI_NPCID"] = function()
	local name = UnitName("target")
	local guid = UnitGUID("target")
	if name and guid then
		local npcID = K.GetNPCID(guid)
		print(name, K.InfoColor .. (npcID or "nil"))
	end
end
_G.SLASH_KKTHNXUI_NPCID1 = "/getnpc"

SlashCmdList["KKTHNXUI_GETFONT"] = function(msg)
	-- Get the global variable stored in the variable msg
	local font = _G[msg]

	-- Check if the font variable is not defined
	if not font then
		-- If it's not defined, print an error message and exit the function
		print(msg, "not found.")
		return
	end

	-- Get the font, size, and flags of the font object
	local a, b, c = font:GetFont()

	-- Print the font name, size, and flags
	print(msg, a, b, c)
end
_G.SLASH_KKTHNXUI_GETFONT1 = "/getfont"

do
	-- Create a table to store the version information
	local versionList = {}

	-- Register the addon message prefix
	C_ChatInfo_RegisterAddonMessagePrefix("KKUI_VersonCheck")

	-- Define a function to print the version check results
	local function PrintVerCheck()
		print("------------------------")
		for name, version in pairs(versionList) do
			print(name .. " " .. version)
		end
	end

	-- Define a function to send the version check request and call the print function after a delay
	local function SendVerCheck(channel)
		-- Clear the versionList table
		table.wipe(versionList)
		-- Send the version check request
		C_ChatInfo_SendAddonMessage("KKUI_VersonCheck", "VersionCheck", channel)
		-- Schedule the print function to run after 3 seconds
		C_Timer.After(3, PrintVerCheck)
	end

	-- Define a function to listen for version check responses
	local function VerCheckListen(_, ...)
		local prefix, msg, distType, sender = ...

		if prefix == "KKUI_VersonCheck" then
			if msg == "VersionCheck" then
				-- Send the version of the addon
				C_ChatInfo_SendAddonMessage("KKUI_VersonCheck", "MyVer-" .. K.Version, distType)
			elseif string.find(msg, "MyVer") then
				-- Extract the version from the message and store it in the versionList table
				local _, version = string.split("-", msg)
				versionList[sender] = version .. " - " .. distType
			end
		end
	end
	K:RegisterEvent("CHAT_MSG_ADDON", VerCheckListen)

	SlashCmdList["KKTHNXUI_VER_CHECK"] = function(msg)
		local channel
		if IsInRaid() then
			channel = "RAID"
		elseif IsInGuild() and not IsInGroup() then
			channel = "GUILD"
		elseif IsInGroup() then
			channel = "PARTY"
		end

		if msg ~= "" then
			channel = msg
		end

		if channel then
			SendVerCheck(channel)
		end
	end

	_G.SLASH_KKTHNXUI_VER_CHECK1 = "/kkver"
end

SlashCmdList["KKTHNXUI_GET_ENCOUNTERS"] = function()
	if not _G.EncounterJournal then
		return
	end

	local tierID = EJ_GetCurrentTier()
	local instID = _G.EncounterJournal.instanceID
	EJ_SelectInstance(instID)
	local instName = EJ_GetInstanceInfo()
	print(" ")
	print("TIER = " .. tierID)
	print("INSTANCE = " .. instID .. " -- " .. instName)
	print("BOSS")
	print(" ")

	local i = 0
	while true do
		i = i + 1
		local name, _, boss = EJ_GetEncounterInfoByIndex(i)
		if not name then
			return
		end

		print("BOSS = " .. boss .. " -- " .. name)
	end
end
_G.SLASH_KKTHNXUI_GET_ENCOUNTERS1 = "/getencounter"

-- Inform us of the patch info we play on.
SlashCmdList["WOWVERSION"] = function()
	print(K.InfoColor .. "------------------------")
	K.Print("Build: ", K.WowBuild)
	K.Print("Released: ", K.WowRelease)
	K.Print("Interface: ", K.TocVersion)
	print(K.InfoColor .. "------------------------")
end
_G.SLASH_WOWVERSION1 = "/getpatch"
_G.SLASH_WOWVERSION2 = "/getbuild"
_G.SLASH_WOWVERSION3 = "/getinterface"

-- Grids
local grid
local boxSize = 32
local function Grid_Create()
	grid = CreateFrame("Frame", nil, UIParent)
	grid.boxSize = boxSize
	grid:SetAllPoints(UIParent)

	local size = 2
	local width = GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / boxSize
	local hStep = height / boxSize

	for i = 0, boxSize do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		if i == boxSize / 2 then
			tx:SetColorTexture(1, 0, 0, 0.5)
		else
			tx:SetColorTexture(0, 0, 0, 0.5)
		end
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i * wStep - (size / 2), 0)
		tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i * wStep + (size / 2), 0)
	end
	height = GetScreenHeight()

	do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(1, 0, 0, 0.5)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + size / 2))
	end

	for i = 1, math_floor((height / 2) / hStep) do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(0, 0, 0, 0.5)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 + i * hStep) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + i * hStep + size / 2))

		tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(0, 0, 0, 0.5)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 - i * hStep) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 - i * hStep + size / 2))
	end
end

local function Grid_Show()
	if not grid then
		Grid_Create()
	elseif grid.boxSize ~= boxSize then
		grid:Hide()
		Grid_Create()
	else
		grid:Show()
	end
end

local isAligning = false
SlashCmdList["KKUI_TOGGLEGRID"] = function(arg)
	if isAligning or arg == "1" then
		if grid then
			grid:Hide()
		end
		isAligning = false
	else
		boxSize = (math_ceil((tonumber(arg) or boxSize) / 32) * 32)
		if boxSize > 256 then
			boxSize = 256
		end
		Grid_Show()
		isAligning = true
	end
end
_G.SLASH_KKUI_TOGGLEGRID1 = "/showgrid"
_G.SLASH_KKUI_TOGGLEGRID2 = "/align"
_G.SLASH_KKUI_TOGGLEGRID3 = "/grid"
