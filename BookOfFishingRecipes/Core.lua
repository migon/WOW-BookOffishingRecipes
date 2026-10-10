-- Core.lua
-- Tento soubor se stará o základní běh addonu a zachytávání eventů

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "BookOfFishingRecipes" then
            print("|cFF00FF00Book of Fishing Recipes|r successfully loaded. Type /bfr for more info.")
        end
    end
end)
