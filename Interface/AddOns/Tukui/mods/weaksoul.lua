BAR_TEXTURE				= "Interface\\AddOns\\Tukui\\media\\WHITE64X64"
FONT					= "Fonts\\ARIALN.ttf"

-------------------------------------------------
-- Code start here
-------------------------------------------------

function BarPanel(height, width, x, y, anchorPoint, anchorPointRel, anchor, level, parent, strata)
	local Panel = CreateFrame("Frame", _, parent)
	Panel:SetFrameLevel(level)
	Panel:SetFrameStrata(strata)
	Panel:SetHeight(height)
	Panel:SetWidth(width)
	Panel:SetPoint(anchorPoint, anchor, anchorPointRel, x, y)
	Panel:SetBackdrop( { 
	  bgFile = BAR_TEXTURE, 
	  insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	Panel:SetBackdropColor(0.1, 0.1, 0.1, 1)
	Panel:Show()
	return Panel
end 

-- Function to update each bar
local function UpdateBar(self)
	local duration = self.Duration
	local timeLeft = self.EndTime-GetTime()
	local roundedt = math.floor(timeLeft*10.5)/10
	self.Bar:SetValue(timeLeft/duration)
	if roundedt % 1 == 0 then 
	self.Time:SetText(roundedt .. ".0")
	else self.Time:SetText(roundedt) end
	
	if timeLeft < 0 then
		self.Panel:Hide()
		self:SetScript("OnUpdate", nil)
	end
end

-- Configures the Bar
local function ConfigureBar(f)
	f.Bar = CreateFrame("StatusBar", _, f.Panel)
	f.Bar:SetStatusBarTexture(BAR_TEXTURE)
	f.Bar:SetStatusBarColor(81/255, 13/255, 13/255)
	f.Bar:SetPoint("BOTTOMLEFT", 0, 0)
	f.Bar:SetPoint("TOPRIGHT", 0, 0)
	f.Bar:SetMinMaxValues(0, 1)

	f.Time = f.Bar:CreateFontString(nil, "OVERLAY")
	f.Time:SetPoint("LEFT", 2, 1)
	f.Time:SetShadowOffset(1, -1)
	f.Time:SetShadowColor(0.1, 0.1, 0.1, 1)
	f.Time:SetFont(FONT, 10)
	f.Time:SetJustifyH("LEFT")
	
	if ws_show_time == true then
		f.Time:Show()
	else
		f.Time:Hide()
	end
	
	f.Panel:Hide()
end

--------------------------------------------------------
--  Weakened Soul Bar codes
--------------------------------------------------------
local playerClass = select(2,UnitClass("player"))

local WeakenedTargetFrame = CreateFrame("Frame", _, UIParent)
if charportrait == true then
	WeakenedTargetFrame.Panel = BarPanel(8, 166, 0, 28, "TOPLEFT", "BOTTOMLEFT", oUF_Tukz_target, 1, WeakenedTargetFrame, "HIGH")
else
	WeakenedTargetFrame.Panel = BarPanel(8, 200, 0, 28, "TOPLEFT", "BOTTOMLEFT", oUF_Tukz_target, 1, WeakenedTargetFrame, "HIGH")
end
	WeakenedTargetFrame.Panel:SetFrameLevel(10)

ConfigureBar(WeakenedTargetFrame)

-- On Target Change or Weakened Soul check on the friendly target
local function WeakenedTargetCheck(self, event, unit, spell)
	if playerClass == "PRIEST" then
		if (event == "PLAYER_TARGET_CHANGED") or (unit == "target" and UnitIsFriend("player", "target") and UnitDebuff("target", wsdebuff)) then		
			local name, _, _, _, _, duration, expirationTime, unitCaster = UnitDebuff("target", wsdebuff)
			if (event == "PLAYER_TARGET_CHANGED" and (not name)) or not UnitIsFriend("player", "target") then
				self.Panel:Hide()
			elseif name then
				self.EndTime = expirationTime
				self.Duration = duration
				self.Panel:Show()
				self:SetScript("OnUpdate", UpdateBar)
			end
		end
	end
end

WeakenedTargetFrame:SetScript("OnEvent", WeakenedTargetCheck)
WeakenedTargetFrame:RegisterEvent("UNIT_AURA")
WeakenedTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

-- Weakened Soul bar on player when active.
local WeakenedPlayerFrame = CreateFrame("Frame", _, UIParent)
if charportrait == true then
	WeakenedPlayerFrame.Panel = BarPanel(8, 166, 34, 28, "TOPLEFT", "BOTTOMLEFT", oUF_Tukz_player, 1, WeakenedPlayerFrame, "HIGH")
else
	WeakenedPlayerFrame.Panel = BarPanel(8, 200, 0, 28, "TOPLEFT", "BOTTOMLEFT", oUF_Tukz_player, 1, WeakenedPlayerFrame, "HIGH")
end

ConfigureBar(WeakenedPlayerFrame)
-- Check for Weakened Soul on me and show bar if it is
local function WeakenedPlayerCheck(self, event, unit, spell)
	if playerClass == "PRIEST" then
		if (unit == "player" and UnitDebuff("player", wsdebuff) and ws_show_player == true) then
			local name, _, _, _, _, duration, expirationTime, unitCaster = UnitDebuff("player", wsdebuff)
			if name then
				self.EndTime = expirationTime
				self.Duration = duration
				self.Panel:Show()
				self:SetScript("OnUpdate", UpdateBar)
			end
		end
	end
end

WeakenedPlayerFrame:SetScript("OnEvent", WeakenedPlayerCheck)
WeakenedPlayerFrame:RegisterEvent("UNIT_AURA")





