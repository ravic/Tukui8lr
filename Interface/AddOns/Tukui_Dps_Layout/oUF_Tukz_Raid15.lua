local fontlol = [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=]

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


local function CreateStyle(self, unit)
	self.menu = menu
	self.colors = colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self:SetAttribute('*type2', 'menu')
	self:SetAttribute('initial-height', 12)
	self:SetAttribute('initial-width', 100)

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, left = -1, bottom = -1, right = -1}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture([=[Interface\AddOns\Tukui\media\normTex]=])
	self.Health.colorDisconnected = true
	self.Health.colorClass = true

	self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	self.Health.bg:SetTexture(0.3, 0.3, 0.3)
	self.Health.bg.multiplier = (0.3)
	

	local health = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallRight')
	health:SetPoint('CENTER', 0, 1)
	self:Tag(health, '[dead][offline( )][afk( )]')

	--local power = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
	--power:SetPoint('LEFT', 3, 0)
	--self:Tag(power, '[smartpp]')

	local name = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
	name:SetFont(fontlol, 13, "THINOUTLINE")
	name:SetPoint('LEFT', self, 'RIGHT', 5, 1)
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
end

oUF:RegisterStyle('Raid15', CreateStyle)
oUF:SetActiveStyle('Raid15')

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
local raid = {}
for i = 1, 3 do
	local raidgroup = oUF:Spawn('header', 'oUF_Group'..i)
	raidgroup:SetManyAttributes('groupFilter', tostring(i), 'showRaid', true, 'yOffset', -4)
	raidgroup:SetFrameStrata('BACKGROUND')	
	table.insert(raid, raidgroup)
	if(i == 1) then
		raidgroup:SetPoint('TOPLEFT', UIParent, 15, -180)
	else
		raidgroup:SetPoint('TOP', raid[i-1], 'BOTTOM', 0, -15)
	end
	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_LOGIN")
	raidToggle:RegisterEvent("RAID_ROSTER_UPDATE")
	raidToggle:RegisterEvent("PARTY_LEADER_CHANGED")
	raidToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
	raidToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		local numraid = GetNumRaidMembers()
		if numraid < 11 or numraid > 15 then --15
			raidgroup:Hide()
		else
			raidgroup:Show()
		end
	end
end)
end










