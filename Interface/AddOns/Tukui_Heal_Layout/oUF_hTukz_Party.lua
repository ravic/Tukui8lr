local mediaPath = [=[Interface\Addons\Tukui\media\]=]

local fontlol = [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=]
local normTex = mediaPath..[=[normTex]=]
local glowTex = mediaPath..[=[glowTex]=]
local bubbleTex = mediaPath..[=[bubbleTex]=]
local buttonTex = mediaPath..[=[buttonTex]=]
local highlightTex = mediaPath..[=[highlightTex]=]
local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -2, left = -2, bottom = -2, right = -2},
}


------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

local colors = setmetatable({
	power = setmetatable({
		["MANA"] = {0.31, 0.45, 0.63},
		["RAGE"] = {0.69, 0.31, 0.31},
		["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {0.65, 0.63, 0.35},
		["RUNES"] = {0.55, 0.57, 0.61},
		["RUNIC_POWER"] = {0, 0.82, 1},
		["AMMOSLOT"] = {0.8, 0.6, 0},
		["FUEL"] = {0, 0.55, 0.5},
		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	}, {__index = oUF.colors.power}),
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {__index = oUF.colors.happiness}),
	runes = setmetatable({
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.33, 0.59, 0.33},
		[3] = {0.31, 0.45, 0.63},
		[4] = {0.84, 0.75, 0.65},
	}, {__index = oUF.colors.runes}),
}, {__index = oUF.colors})

oUF.colors.tapped = {0.55, 0.57, 0.61}
oUF.colors.disconnected = {0.84, 0.75, 0.65}

oUF.colors.smooth = {0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.15, 0.15, 0.15}

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------


local function PostCreateAuraIcon(self, button, icons, index, debuff)
	button.backdrop = CreateFrame("Frame", nil, button)
	button.backdrop:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
	button.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)
	button.backdrop:SetFrameStrata("BACKGROUND")
	button.backdrop:SetBackdrop {
		edgeFile = glowTex, edgeSize = 5,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
	button.backdrop:SetBackdropColor(0, 0, 0, 0)
	button.backdrop:SetBackdropBorderColor(0, 0, 0)

    button.cd:SetReverse()
    button.overlay:SetTexture(buttonTex)
	button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
	button.overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
    button.overlay:SetTexCoord(0, 1, 0, 1)
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	icons.disableCooldown = true		
    button.overlay.Hide = function(self) self:SetVertexColor(1, 1, 1, 0) end
end

local timer = 0
local OnRangeUpdate = function(self, elapsed)
	timer = timer + elapsed

	if(timer >= 0.01) then
		local currentAlpha = self:GetAlpha()
		if (currentAlpha == 1) then
			self.Debuffs:Show()
		elseif (currentAlpha < 1) then
			self.Debuffs:Hide()
		end
		timer = 0
	end
end

-- ------------------------------------------------------------------------
-- local horror
-- ------------------------------------------------------------------------
local select = select
local UnitClass = UnitClass
local UnitIsDead = UnitIsDead
local UnitIsPVP = UnitIsPVP
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification
local UnitReactionColor = UnitReactionColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- ------------------------------------------------------------------------
-- reformat everything above 999 in raidframes
-- ------------------------------------------------------------------------
local numberize_raid = function(v)
	if v <= 999 then return v end
	if v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 1000 then
		local value = string.format("%.1fk", v/1000)
		return value
	end
end

-- ------------------------------------------------------------------------
-- health update
-- ------------------------------------------------------------------------
local updateHealth = function(self, event, unit, bar, min, max)  
    local cur, maxhp = min, max
    local missing = maxhp-cur
    
    local d = floor(cur/maxhp*100)
    
	if(UnitIsDead(unit)) then
		bar:SetValue(0)
		bar.value:SetText"DEAD"
	elseif(UnitIsGhost(unit)) then
		bar:SetValue(0)
		bar.value:SetText"GHOST"
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText"D/C"

	elseif(self:GetParent():GetName():match"oUF_Group") then
		if(d < 100) then
			bar.value:SetText("|cffFFFFFF".."-"..numberize_raid(missing))
		else
			bar.value:SetText(" ")
		end

    end
end

local colors = setmetatable({
	power = setmetatable({
		['MANA'] = {0, 144/255, 1},
	}, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

local function menu(self)
	if(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, 'cursor')
	end
end
oUF.Tags['[smarthp]'] = function(u)
	local min, max = UnitHealth(u), UnitHealthMax(u)
	return UnitIsDeadOrGhost(u) and oUF.Tags['[dead]'](u) or (min~=max) and format('|cffff8080%d|r|cff0090ff %.0f|r%%', min-max, min/max*100) or max
end

oUF.Tags['[smartpp]'] = function(u)
	local min, max = UnitPower(u), UnitPowerMax(u)
	return (UnitPowerType(u) == 0 and min > 0) and format('|cff%02x%02x%02x%.0f|r%%', 0, 144, 255, min/max*100)
end

oUF.Tags['[offline]'] = function(u)
	if not UnitIsConnected(u) then
		return ("|cffB1071E".."Offline".."|r")
	end
end

oUF.Tags['[dead]'] = function(u) return UnitIsDeadOrGhost(u) and 'DEAD' end
oUF.Tags['[afk]'] = function(u) return UnitIsAFK(u) and ' AFK' end

oUF.TagEvents['[smarthp]'] = 'UNIT_HEALTH'
oUF.TagEvents['[smartpp]'] = 'UNIT_MANA UNIT_DISPLAYPOWER'

oUF.TagEvents['[afk]'] = 'PLAYER_FLAGS_CHANGED'

local function CreateStyle(self, unit)

    self.Debuffs = CreateFrame('Frame', nil, self)
    self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', 5, 36)
    self.Debuffs:SetHeight(33 * 1)
    self.Debuffs:SetWidth(320)
    self.Debuffs.size = 33 * 1
    self.Debuffs.spacing = 3
    self.Debuffs.initialAnchor = 'LEFT'
    self.Debuffs.showDebuffType = true
	self.Debuffs.num = 5
	self.Debuffs.numBuffs = 5
	self.Debuffs.numDebuffs = 5
	
	self.menu = menu
	self.colors = colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	self:SetScript("OnUpdate", OnRangeUpdate)

	self:SetAttribute('*type2', 'menu')
	self:SetAttribute('initial-height', 40)
	self:SetAttribute('initial-width', 180)

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, left = -1, bottom = -1, right = -1}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetStatusBarTexture([=[Interface\AddOns\Tukui\media\normTex]=])
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetHeight(33)
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorClassPet = true
	self.Health.colorTapping = true
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture([=[Interface\AddOns\Tukui\media\normTex]=])
	self.Health.bg:SetAlpha(1)
	self.Health.bg.multiplier = 0.3
	
	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetPoint("RIGHT", self.Health, -3, 1)
	self.Health.value:SetFont(fontlol, 12, "THINOUTLINE")
	self.Health.value:SetTextColor(1,1,1)
	self.Health.value:SetShadowOffset(1, -1)

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(6)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
	self.Power:SetStatusBarTexture([=[Interface\AddOns\Tukui\media\normTex]=])

	self.Power.colorTapping = true
	self.Power.colorDisconnected = true
	self.Power.colorPower = true
	self.Power.colorClass = true
	self.Power.colorReaction = true

	self.Power.frequentUpdates = true
	self.Power.Smooth = true

	self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(normTex)
	self.Power.bg:SetAlpha(1)
	self.Power.bg.multiplier = 0.4
	

	local name = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
	name:SetFont(fontlol, 12, "THINOUTLINE")
	name:SetPoint('LEFT', 3, 1)
	self:Tag(name, '[name( )][leader( )]')


	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true

	if showrange == true then
		self.outsideRangeAlpha = 0.3
		self.inRangeAlpha = 1.0
		self.Range = true
	else
		self.Range = false
	end
	if showsmooth == true then
		self.Health.Smooth = true
	else
		self.Health.Smooth = false
	end
	
    self.PostCreateAuraIcon = PostCreateAuraIcon
	self.PostUpdateHealth = updateHealth


end

oUF:RegisterStyle('Party', CreateStyle)
oUF:SetActiveStyle('Party')

--[[
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
strictFiltering = [BOOLEAN] - if true, then characters must match both a group and a class from the groupFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinate (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the ammount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
--]]



local party = oUF:Spawn("header", "oUF_Group")
party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -300)
party:SetAttribute("showParty", true)
party:SetAttribute("showPlayer", true)
party:SetAttribute("yOffset", -8)


local pets = {} 
pets[1] = oUF:Spawn('partypet1', 'oUF_PartyPet1') 
pets[1]:SetPoint('TOPLEFT', party, 'TOPLEFT', 0, -240) 
for i =2, 4 do 
  pets[i] = oUF:Spawn('partypet'..i, 'oUF_PartyPet'..i) 
  pets[i]:SetPoint('TOP', pets[i-1], 'BOTTOM', 0, -8) 
end



local partyToggle = CreateFrame("Frame")
partyToggle:RegisterEvent("PLAYER_LOGIN")
partyToggle:RegisterEvent("RAID_ROSTER_UPDATE")
partyToggle:RegisterEvent("PARTY_LEADER_CHANGED")
partyToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
partyToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		local numraid = GetNumRaidMembers()
		if numraid > 0 and (numraid > 5 or numraid ~= GetNumPartyMembers() + 1) then
			party:Hide()
			for i,v in ipairs(pets) do v:Disable() end
			--for i, pet in ipairs(pets) do
			--pet:Hide()
			--end		
		else
			party:Show()
			for i,v in ipairs(pets) do v:Enable() end
			--for i, pet in ipairs(pets) do
			--pet:Show()
			--end
		end
	end
end)










