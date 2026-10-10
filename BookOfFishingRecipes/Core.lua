-- Core.lua
-- Tento soubor se stará o základní běh addonu a zachytávání eventů

if type(BFR_CaughtFish) ~= "table" then
    BFR_CaughtFish = {}
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_LOOT") -- Zachytí zprávy v chatu o lootu

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "BookOfFishingRecipes" then
            if type(BFR_CaughtFish) ~= "table" then
                BFR_CaughtFish = {}
            end
            print("|cFF00FF00Book of Fishing Recipes|r successfully loaded. Type /bfr for more info.")
        end
    elseif event == "CHAT_MSG_LOOT" then
        local lootMsg = ...
        
        -- Jednoduchý regex pro vytažení ID předmětu ze zprávy o lootu
        -- lootMsg obvykle vypadá takto: "You receive loot: |cff1eff00|Hitem:6291:0:0:0...|h[Brilliant Smallfish]|h|r"
        local itemID = string.match(lootMsg, "item:(%d+)")
        
        if itemID then
            itemID = tonumber(itemID)
            -- Pokud je to ryba z naší databáze a ještě ji hráč nechytil
            if BFR_Database.Fish[itemID] and not BFR_CaughtFish[itemID] then
                BFR_CaughtFish[itemID] = true
                print("|cFF00FFFF[Book of Fishing Recipes]|r First time catch: |cFFFFFF00" .. BFR_Database.Fish[itemID].name .. "|r! Added to book.")
            end
        end
    end
end)
