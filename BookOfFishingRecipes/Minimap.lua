-- Minimap.lua

-- Vytvoření tlačítka
local minimapButton = CreateFrame("Button", "BFR_MinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)

-- Ikonka (Základní ikonka profese Fishing)
local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\Trade_Fishing")
icon:SetSize(21, 21)
icon:SetPoint("CENTER", 0, 0)

-- Standardní obrys tlačítka
local border = minimapButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(54, 54)
border:SetPoint("TOPLEFT", 11, -12)

-- Zvýraznění při najetí myší
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Výchozí pozice
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -15, -15)

-- Kliknutí na tlačítko
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
    GameTooltip:AddLine("Click to open the book.", 1, 1, 1)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
