-- Tooltip.lua

local function AppendFishInfo(tooltip, link)
    if not link then return end
    
    local itemID = tonumber(string.match(link, "item:(%d+)"))
    if not itemID then return end
    
    local fishData = BFR_Database.Fish[itemID]
    
    if not fishData then
        local itemName = tooltip:GetItem()
        if itemName then
            for id, data in pairs(BFR_Database.Fish) do
                if data.name == itemName then
                    fishData = data
                    itemID = id
                    break
                end
            end
        end
    end

    if fishData then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cFF00FFFF[Book of Fishing Recipes]|r")
        
        if BFR_CaughtFish and BFR_CaughtFish[itemID] then
            tooltip:AddLine("|cFF00FF00(✓) You already catched this|r")
        end
        
        if fishData.fishingMin then
            tooltip:AddLine("Requires Fishing Lvl: |cFF00FFFF" .. fishData.fishingMin .. "|r")
        end
        
        local cat = fishData.category or "Cookable"
        tooltip:AddLine("Category: |cFFDDDDDD" .. cat .. "|r")
        
        if cat == "Cookable" and fishData.recipes then
            for _, recipe in ipairs(fishData.recipes) do
                local sourceStr = recipe.sourceType or "Unknown"
                if recipe.sourceType == "Vendor" and recipe.vendors and #recipe.vendors > 0 then
                    sourceStr = "Vendor (" .. recipe.vendors[1].name
                    if #recipe.vendors > 1 then sourceStr = sourceStr .. ", atd." end
                    sourceStr = sourceStr .. ")"
                elseif recipe.sourceType == "Drop" and recipe.drops and #recipe.drops > 0 then
                    sourceStr = "Drop (" .. recipe.drops[1].name
                    if #recipe.drops > 1 then sourceStr = sourceStr .. ", atd." end
                    sourceStr = sourceStr .. ")"
                end

                tooltip:AddLine("Recipe: |cFFFFFFFF" .. recipe.name .. "|r")
                tooltip:AddLine("Best for Cooking: |cFF00FF00" .. recipe.cookLvl .. "|r")
                tooltip:AddLine("Source: |cFFCCCCCC" .. sourceStr .. "|r")
            end
        elseif cat == "Crafting" and fishData.crafts then
            for _, craft in ipairs(fishData.crafts) do
                tooltip:AddLine("Used in: |cFFFFFFFF" .. craft.name .. "|r")
                tooltip:AddLine("Profession: |cFF00FF00" .. craft.profession .. " (" .. craft.profLvl .. ")|r")
            end
        elseif cat == "Consumable" and fishData.notes then
            tooltip:AddLine("Notes: |cFFCCCCCC" .. string.sub(fishData.notes, 1, 40) .. "...|r")
        end
    end
end

if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        if tooltip then
            local name, link = tooltip:GetItem()
            AppendFishInfo(tooltip, link)
        end
    end)
else
    local function LegacyHook(tooltip)
        local name, link = tooltip:GetItem()
        AppendFishInfo(tooltip, link)
        tooltip:Show()
    end
    if GameTooltip:HasScript("OnTooltipSetItem") then
        GameTooltip:HookScript("OnTooltipSetItem", LegacyHook)
    end
    if ItemRefTooltip:HasScript("OnTooltipSetItem") then
        ItemRefTooltip:HookScript("OnTooltipSetItem", LegacyHook)
    end
end
