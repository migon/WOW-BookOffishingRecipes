-- Minimap.lua

-- Vytvoření tlačítka
local minimapButton = CreateFrame("Button", "BFR_MinimapButton", Minimap)
minimapButton:SetSize(31, 31)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:RegisterForClicks("LeftButtonUp")
minimapButton:RegisterForDrag("LeftButton")

-- Ikonka (Ikonka profese Cooking)
local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\INV_Misc_Food_15")
icon:SetSize(20, 20)
icon:SetPoint("TOPLEFT", 6, -5)

-- Kruhová maska, aby ikonka byla kulatá a ladila s rámečkem
pcall(function()
    local mask = minimapButton:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(icon)
    icon:AddMaskTexture(mask)
end)

-- Standardní kruhový obrys tlačítka
local border = minimapButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(53, 53)
border:SetPoint("TOPLEFT", 0, 0)

-- Zvýraznění při najetí myší
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Výchozí pozice na obvodu minimapy (cca 10 hodin, kde je v UI volné místo)
local defaultAngle = math.rad(140)
local radius = 80
minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(defaultAngle) * radius, math.sin(defaultAngle) * radius)

-- Možnost přetahování tlačítka myší po obvodu minimapy
local function MoveButton()
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    if not mx or not my or not cx or not cy or not scale then return end
    cx, cy = cx / scale, cy / scale
    local angle = math.atan2(cy - my, cx - mx)
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

minimapButton:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", MoveButton)
end)

minimapButton:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

-- Kliknutí na tlačítko (otevření/zavření knihy)
minimapButton:SetScript("OnClick", function(self, button)
    if BFR_UIFrame then
        if BFR_UIFrame:IsShown() then
            BFR_UIFrame:Hide()
        else
            BFR_UIFrame:Show()
        end
    end
end)

-- Tooltip při najetí myší
minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Book of Fishing Recipes")
    GameTooltip:AddLine("Left-Click: Open/Close Book", 1, 1, 1)
    GameTooltip:AddLine("Drag: Move around Minimap", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
