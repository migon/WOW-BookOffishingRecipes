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

-- Kruhová maska, aby byla ikonka kulatá a lícovala s rámečkem
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

-- Dynamický přepočet pozice podle skutečné velikosti minimapy
local function UpdatePosition(angleDeg)
    local angleRad = math.rad(angleDeg or 140)
    local w = (Minimap:GetWidth() / 2) + 7
    local h = (Minimap:GetHeight() / 2) + 7
    local x = math.cos(angleRad) * w
    local y = math.sin(angleRad) * h
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Aktualizace při tažení myší podél obvodu minimapy
local function OnDragUpdate()
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    if not mx or not my or not cx or not cy or not scale then return end
    cx, cy = cx / scale, cy / scale
    local angleDeg = math.deg(math.atan2(cy - my, cx - mx)) % 360
    if BFR_Settings then
        BFR_Settings.minimapPos = angleDeg
    end
    UpdatePosition(angleDeg)
end

minimapButton:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", OnDragUpdate)
end)

minimapButton:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

-- Načtení pozice při startu / po načtení addonu
minimapButton:RegisterEvent("PLAYER_LOGIN")
minimapButton:SetScript("OnEvent", function(self, event)
    if not BFR_Settings then BFR_Settings = {} end
    local pos = BFR_Settings.minimapPos or 140
    UpdatePosition(pos)
end)

-- Spustit i po malé prodlevě pro jistotu (kdyby Minimap ještě nebyl naplno inicializován)
C_Timer.After(0.1, function()
    local pos = (BFR_Settings and BFR_Settings.minimapPos) or 140
    UpdatePosition(pos)
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
