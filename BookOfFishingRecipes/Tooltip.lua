-- Tooltip.lua

local function AppendFishInfo(tooltip, link, itemID)
    if not tooltip or not tooltip.AddLine then return end
    
    if not itemID and link then
        itemID = tonumber(string.match(link, "item:(%d+)"))
    end
    
    local fishData
    if itemID then
        fishData = BFR_Database.Fish[itemID]
    end
    
    if not fishData and tooltip.GetItem then
        local ok, itemName = pcall(tooltip.GetItem, tooltip)
        if ok and itemName and type(itemName) == "string" then
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
        if not tooltip then return end
        local itemID = data and data.id
        local link = data and (data.hyperlink or (itemID and ("item:" .. itemID)))
        if not link and tooltip.GetItem then
            local ok, _, itemLink = pcall(tooltip.GetItem, tooltip)
            if ok then link = itemLink end
        end
        AppendFishInfo(tooltip, link, itemID)
    end)
else
    local function LegacyHook(tooltip)
        if not tooltip or not tooltip.GetItem then return end
        local ok, name, link = pcall(tooltip.GetItem, tooltip)
        if ok and link then
            AppendFishInfo(tooltip, link)
        end
    end
    if GameTooltip and GameTooltip.HookScript and GameTooltip:HasScript("OnTooltipSetItem") then
        GameTooltip:HookScript("OnTooltipSetItem", LegacyHook)
    end
    if ItemRefTooltip and ItemRefTooltip.HookScript and ItemRefTooltip:HasScript("OnTooltipSetItem") then
        ItemRefTooltip:HookScript("OnTooltipSetItem", LegacyHook)
    end
end
