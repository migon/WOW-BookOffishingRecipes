-- UI.lua

local function CreateDivider(parent, yOffset)
    local tex = parent:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-OnlineDivider")
    tex:SetSize(350, 8)
    tex:SetPoint("TOP", 0, yOffset)
    return tex
end

local function CreateCardBox(parent, width, height)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetSize(width, height)
    
    local bg = box:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.45)
    box.bg = bg
    
    local borderT = box:CreateTexture(nil, "BORDER")
    borderT:SetHeight(1)
    borderT:SetPoint("TOPLEFT", 0, 0)
    borderT:SetPoint("TOPRIGHT", 0, 0)
    borderT:SetColorTexture(1, 0.82, 0, 0.25)
    
    local borderB = box:CreateTexture(nil, "BORDER")
    borderB:SetHeight(1)
    borderB:SetPoint("BOTTOMLEFT", 0, 0)
    borderB:SetPoint("BOTTOMRIGHT", 0, 0)
    borderB:SetColorTexture(1, 0.82, 0, 0.25)
    
    local borderL = box:CreateTexture(nil, "BORDER")
    borderL:SetWidth(1)
    borderL:SetPoint("TOPLEFT", 0, 0)
    borderL:SetPoint("BOTTOMLEFT", 0, 0)
    borderL:SetColorTexture(1, 0.82, 0, 0.25)
    
    local borderR = box:CreateTexture(nil, "BORDER")
    borderR:SetWidth(1)
    borderR:SetPoint("TOPRIGHT", 0, 0)
    borderR:SetPoint("BOTTOMRIGHT", 0, 0)
    borderR:SetColorTexture(1, 0.82, 0, 0.25)
    
    return box
end

local function SetMapMarker(mapID, x, y, name)
    if not mapID or not x or not y then
        print("|cFFFF0000[BFR]|r Chybí data pro mapu u: " .. (name or "Unknown"))
        return
    end

    -- 1. Pokud hráč má TomTom, je to nejspolehlivější řešení.
    -- Zkusíme z názvu vendora vypreparovat jméno zóny (např. "Durotar" z "Zansoa (Durotar)")
    local zoneName = string.match(name, "%((.+)%)")
    if SlashCmdList["TOMTOM_WAY"] and zoneName then
        -- Pošleme přímo jméno zóny do TomTomu, ten si MapID najde sám
        SlashCmdList["TOMTOM_WAY"](string.format("%s %f %f %s", zoneName, x, y, name))
        return
    end

    -- 2. Smart MapID Detekce pro C_Map
    -- Zkusíme, zda klient bere Era MapID (např. 1411), jinak přepneme na Retail (1)
    if C_Map and C_Map.CanSetUserWaypointOnMap then
        if not C_Map.CanSetUserWaypointOnMap(mapID) then
            local legacyMapIDs = {
                [1429] = 37, [1411] = 1, [1412] = 15, [1454] = 85, [1458] = 68,
                [1453] = 84, [1413] = 17, [1434] = 210, [1446] = 71, [1426] = 69,
                [1443] = 66, [1424] = 25, [1432] = 22, [1455] = 87,
            }
            if legacyMapIDs[mapID] and C_Map.CanSetUserWaypointOnMap(legacyMapIDs[mapID]) then
                mapID = legacyMapIDs[mapID]
            end
        end
    end

    -- 3. Nativní Dragonflight / Moderní Waypoint API
    if C_Map and C_Map.SetUserWaypoint then
        local mapPoint = UiMapPoint.CreateFromCoordinates(mapID, x/100, y/100)
        C_Map.SetUserWaypoint(mapPoint)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        
        print("|cFF00FFFF[BFR]|r Značka: " .. name .. " (Pokus o mapID: " .. mapID .. ")")
        
        -- Agresivní přepnutí okna mapy (s mírným zpožděním, pokud se mapa teprve otevírá)
        if WorldMapFrame then
            if not WorldMapFrame:IsShown() then ToggleWorldMap() end
            
            C_Timer.After(0.05, function()
                if WorldMapFrame.SetMapID then 
                    WorldMapFrame:SetMapID(mapID) 
                elseif OpenWorldMap then
                    OpenWorldMap(mapID)
                end
            end)
        end
    elseif SlashCmdList["TOMTOM_WAY"] then
        SlashCmdList["TOMTOM_WAY"](string.format("%d %f %f %s", mapID, x, y, name))
    end
end

BFR_SelectedFish = nil

local function FormatMoney(copper)
    if not copper or copper == 0 then return "" end
    local g = math.floor(copper / 10000)
    local s = math.floor((copper % 10000) / 100)
    local c = copper % 100
    local str = " - "
    if g > 0 then str = str .. g .. " |TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t " end
    if s > 0 then str = str .. s .. " |TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t " end
    if c > 0 then str = str .. c .. " |TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t" end
    return str
end

local function SafeHasItem(itemID)
    if not itemID then return false end
    
    -- 1. Standardní kontrola počtu v inventáři přes API
    local ok, count = pcall(function()
        if C_Item and C_Item.GetItemCount then
            return C_Item.GetItemCount(itemID)
        elseif GetItemCount then
            return GetItemCount(itemID)
        end
        return 0
    end)
    if ok and type(count) == "number" and count > 0 then
        return true
    end
    
    -- 2. Přímé fyzické prohledání všech slotů v batozích 0 až 5 (včetně Reagent Bagu)
    -- Hledáme podle ID i podle přesného jména ryby pro 100% spolehlivost!
    local targetName = BFR_Database and BFR_Database.Fish and BFR_Database.Fish[itemID] and BFR_Database.Fish[itemID].name
    
    for bag = 0, 5 do
        local numSlots = 0
        if C_Container and C_Container.GetContainerNumSlots then
            numSlots = C_Container.GetContainerNumSlots(bag) or 0
        elseif GetContainerNumSlots then
            numSlots = GetContainerNumSlots(bag) or 0
        end
        
        for slot = 1, numSlots do
            local slotID = nil
            if C_Container and C_Container.GetContainerItemID then
                slotID = C_Container.GetContainerItemID(bag, slot)
            elseif GetContainerItemID then
                slotID = GetContainerItemID(bag, slot)
            end
            
            if slotID and slotID == itemID then
                return true
            end
            
            if targetName then
                local link = nil
                if C_Container and C_Container.GetContainerItemLink then
                    link = C_Container.GetContainerItemLink(bag, slot)
                elseif GetContainerItemLink then
                    link = GetContainerItemLink(bag, slot)
                end
                if link and string.find(link, targetName, 1, true) then
                    return true
                end
            end
        end
    end
    
    return false
end

local function GetPlayerSkills()
    local fLvl, fMax, cLvl, cMax = 0, 0, 0, 0
    if GetProfessions then
        local prof1, prof2, arch, fish, cook = GetProfessions()
        if fish then
            local _, _, lvl, maxLvl = GetProfessionInfo(fish)
            fLvl, fMax = lvl or 0, maxLvl or 0
        end
        if cook then
            local _, _, lvl, maxLvl = GetProfessionInfo(cook)
            cLvl, cMax = lvl or 0, maxLvl or 0
        end
    end
    return fLvl, fMax, cLvl, cMax
end

BFR_UIFrame = CreateFrame("Frame", "BFR_BookFrame", UIParent, "BasicFrameTemplateWithInset")
BFR_UIFrame:SetSize(780, 540)
BFR_UIFrame:SetPoint("CENTER")
BFR_UIFrame:Hide() 
BFR_UIFrame:SetMovable(true)
BFR_UIFrame:EnableMouse(true)
BFR_UIFrame:RegisterForDrag("LeftButton")
BFR_UIFrame:SetScript("OnDragStart", BFR_UIFrame.StartMoving)
BFR_UIFrame:SetScript("OnDragStop", BFR_UIFrame.StopMovingOrSizing)

BFR_UIFrame.title = BFR_UIFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
BFR_UIFrame.title:SetPoint("TOP", 0, -5)
BFR_UIFrame.title:SetText("Book of Fishing Recipes")

-- === SKILL HEADER ===
BFR_UIFrame.SkillHeader = CreateFrame("Frame", nil, BFR_UIFrame, "BackdropTemplate")
BFR_UIFrame.SkillHeader:SetSize(760, 30)
BFR_UIFrame.SkillHeader:SetPoint("TOP", 0, -25)

BFR_UIFrame.SkillHeader.bg = BFR_UIFrame.SkillHeader:CreateTexture(nil, "BACKGROUND")
BFR_UIFrame.SkillHeader.bg:SetAllPoints()
BFR_UIFrame.SkillHeader.bg:SetColorTexture(0, 0, 0, 0.4)

BFR_UIFrame.SkillHeader.topBorder = BFR_UIFrame.SkillHeader:CreateTexture(nil, "BORDER")
BFR_UIFrame.SkillHeader.topBorder:SetSize(760, 1)
BFR_UIFrame.SkillHeader.topBorder:SetPoint("TOP", 0, 0)
BFR_UIFrame.SkillHeader.topBorder:SetColorTexture(1, 0.82, 0, 0.3)

BFR_UIFrame.SkillHeader.botBorder = BFR_UIFrame.SkillHeader:CreateTexture(nil, "BORDER")
BFR_UIFrame.SkillHeader.botBorder:SetSize(760, 1)
BFR_UIFrame.SkillHeader.botBorder:SetPoint("BOTTOM", 0, 0)
BFR_UIFrame.SkillHeader.botBorder:SetColorTexture(1, 0.82, 0, 0.3)

BFR_UIFrame.SkillText = BFR_UIFrame.SkillHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
BFR_UIFrame.SkillText:SetPoint("CENTER")
BFR_UIFrame.SkillText:SetText("Fishing: 0/0      Cooking: 0/0")
-- ====================

BFR_UIFrame.Legend = BFR_UIFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
BFR_UIFrame.Legend:SetPoint("BOTTOMLEFT", 15, 12)
BFR_UIFrame.Legend:SetText("|TInterface\\Buttons\\Button-Backpack-Up:14:14:0:-1|t = In Bag  |TInterface\\Icons\\Trade_Fishing:14:14:0:-1|t = Can Catch  |TInterface\\Icons\\INV_Misc_Food_15:14:14:0:-1|t = Can Cook")

-- ================= LEVÝ PANEL =================
local leftPanel = CreateFrame("Frame", nil, BFR_UIFrame)
leftPanel:SetSize(300, 440)
leftPanel:SetPoint("TOPLEFT", 10, -65)

local scrollFrame = CreateFrame("ScrollFrame", "BFR_ScrollFrame", leftPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 5, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 5)

local scrollChild = CreateFrame("Frame")
scrollChild:SetSize(260, 420)
scrollFrame:SetScrollChild(scrollChild)

-- ================= PRAVÝ PANEL =================
local rightPanel = CreateFrame("Frame", nil, BFR_UIFrame)
rightPanel:SetSize(430, 440)
rightPanel:SetPoint("TOPRIGHT", -15, -65)

local rightBg = rightPanel:CreateTexture(nil, "BACKGROUND")
rightBg:SetAllPoints()
rightBg:SetTexture("Interface\\QuestFrame\\QuestBG")
rightBg:SetTexCoord(0, 0.58, 0, 0.65)
rightBg:SetAlpha(0.6)

rightPanel.FishName = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
rightPanel.FishName:SetPoint("TOP", 0, -15)
rightPanel.FishName:SetText("Select a fish from the list")

CreateDivider(rightPanel, -50)

-- CARD 1: Info Box (pro rybu nebo Leveling Advisor)
rightPanel.InfoBox = CreateCardBox(rightPanel, 400, 115)
rightPanel.InfoBox:SetPoint("TOP", 0, -56)

rightPanel.SourceType = rightPanel.InfoBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
rightPanel.SourceType:SetPoint("TOPLEFT", 12, -8)
rightPanel.SourceType:SetWidth(376)
rightPanel.SourceType:SetJustifyH("LEFT")

rightPanel.BasicInfo = rightPanel.InfoBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
rightPanel.BasicInfo:SetPoint("TOPLEFT", rightPanel.SourceType, "BOTTOMLEFT", 0, -6)
rightPanel.BasicInfo:SetWidth(376)
rightPanel.BasicInfo:SetJustifyH("LEFT")
rightPanel.BasicInfo:SetSpacing(3)

-- CARD 2: Recipe Box
rightPanel.RecipeBox = CreateCardBox(rightPanel, 400, 56)
rightPanel.RecipeBox:SetPoint("TOP", rightPanel.InfoBox, "BOTTOM", 0, -8)

rightPanel.RecipeButton = CreateFrame("Button", nil, rightPanel.RecipeBox)
rightPanel.RecipeButton:SetSize(376, 18)
rightPanel.RecipeButton:SetPoint("TOPLEFT", 12, -8)
local rbText = rightPanel.RecipeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rbText:SetPoint("LEFT", 0, 0)
rightPanel.RecipeButton:SetFontString(rbText)

rightPanel.RecipeButton:SetScript("OnEnter", function(self)
    rbText:SetTextColor(1, 1, 1)
    if self.itemLink then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:Show()
    end
end)
rightPanel.RecipeButton:SetScript("OnLeave", function() 
    rbText:SetTextColor(1, 0.82, 0)
    GameTooltip:Hide() 
end)
rightPanel.RecipeButton:SetScript("OnClick", function(self)
    if self.itemLink and IsModifiedClick() then
        HandleModifiedItemClick(self.itemLink)
    end
end)

rightPanel.CookInfo = rightPanel.RecipeBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
rightPanel.CookInfo:SetPoint("TOPLEFT", rightPanel.RecipeButton, "BOTTOMLEFT", 0, -4)
rightPanel.CookInfo:SetWidth(376)
rightPanel.CookInfo:SetJustifyH("LEFT")

-- CARD 3: Vendors Box
rightPanel.VendorsBox = CreateCardBox(rightPanel, 400, 115)
rightPanel.VendorsBox:SetPoint("TOP", rightPanel.RecipeBox, "BOTTOM", 0, -8)

rightPanel.VendorsTitle = rightPanel.VendorsBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rightPanel.VendorsTitle:SetPoint("TOPLEFT", 12, -8)
rightPanel.VendorsTitle:SetJustifyH("LEFT")

rightPanel.VendorHint = rightPanel.VendorsBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
rightPanel.VendorHint:SetPoint("BOTTOMLEFT", 12, 6)
rightPanel.VendorHint:SetText("|cFF888888• Left-Click: Set Map Waypoint   |   Shift-Click: /tar macro|r")

rightPanel.vendorBtns = {}

-- Spodní status boxy (Fishing a Cooking)
rightPanel.CatchBox = CreateFrame("Frame", nil, rightPanel, "BackdropTemplate")
rightPanel.CatchBox:SetSize(195, 26)
rightPanel.CatchBox:SetPoint("BOTTOMLEFT", 15, 12)
rightPanel.CatchBox.bg = rightPanel.CatchBox:CreateTexture(nil, "BACKGROUND")
rightPanel.CatchBox.bg:SetAllPoints()
rightPanel.CatchBox.Text = rightPanel.CatchBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
rightPanel.CatchBox.Text:SetPoint("CENTER")
rightPanel.CatchBox:Hide()

rightPanel.CookBox = CreateFrame("Frame", nil, rightPanel, "BackdropTemplate")
rightPanel.CookBox:SetSize(195, 26)
rightPanel.CookBox:SetPoint("BOTTOMRIGHT", -15, 12)
rightPanel.CookBox.bg = rightPanel.CookBox:CreateTexture(nil, "BACKGROUND")
rightPanel.CookBox.bg:SetAllPoints()
rightPanel.CookBox.Text = rightPanel.CookBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
rightPanel.CookBox.Text:SetPoint("CENTER")
rightPanel.CookBox:Hide()

local function ShowFishDetails(itemID)
    local data = BFR_Database.Fish[itemID]
    if not data then return end
    
    rightPanel.FishName:SetText(data.name)
    
    local cat = data.category or "Cookable"
    local sourceText = ""
    if cat == "Cookable" and data.recipes and data.recipes[1] then
        sourceText = "   |cFFFFD100Source:|r " .. (data.recipes[1].sourceType or "Unknown")
    end
    
    -- Card 1: Info Box
    rightPanel.InfoBox.bg:SetColorTexture(0, 0, 0, 0.45)
    rightPanel.SourceType:SetText("|TInterface\\Icons\\INV_Misc_Fish_02:14:14:0:0|t |cFFFFD100Category:|r " .. cat .. sourceText)
    
    local basicText = "|cFFFFD100• Required Fishing Lvl:|r " .. (data.fishingMin or "1") .. "\n"
    basicText = basicText .. "|cFFFFD100• Catch Locations:|r " .. (data.catchLocations or "Unknown")
    rightPanel.BasicInfo:SetText(basicText)
    
    for _, vBtn in ipairs(rightPanel.vendorBtns) do vBtn:Hide() end
    rightPanel.RecipeButton:SetText("")
    rightPanel.RecipeButton.itemLink = nil
    rightPanel.CookInfo:SetText("")
    rightPanel.VendorsTitle:SetText("")
    
    local fLvl, fMax, cLvl, cMax = GetPlayerSkills()
    
    rightPanel.CatchBox:Show()
    if fLvl >= (data.fishingMin or 1) then
        rightPanel.CatchBox.bg:SetColorTexture(0, 0.4, 0, 0.6)
        rightPanel.CatchBox.Text:SetText("|TInterface\\Icons\\Trade_Fishing:14:14:0:0|t You can catch this")
    else
        rightPanel.CatchBox.bg:SetColorTexture(0.5, 0, 0, 0.6)
        rightPanel.CatchBox.Text:SetText("|TInterface\\Icons\\Trade_Fishing:14:14:0:0|t You cannot catch this")
    end
    
    if cat == "Cookable" and data.recipes and data.recipes[1] then
        rightPanel.CookBox:Show()
        if cLvl >= (data.recipes[1].minCook or 1) then
            rightPanel.CookBox.bg:SetColorTexture(0, 0.4, 0, 0.6)
            rightPanel.CookBox.Text:SetText("|TInterface\\Icons\\INV_Misc_Food_15:14:14:0:0|t You can cook this")
        else
            rightPanel.CookBox.bg:SetColorTexture(0.5, 0, 0, 0.6)
            rightPanel.CookBox.Text:SetText("|TInterface\\Icons\\INV_Misc_Food_15:14:14:0:0|t You cannot cook this")
        end
    else
        rightPanel.CookBox:Hide()
    end
    
    if cat == "Cookable" then
        rightPanel.RecipeBox:Show()
        rightPanel.RecipeButton:Show()
        rightPanel.CookInfo:Show()
        rightPanel.VendorsBox:Show()
        
        local recipe = data.recipes and data.recipes[1]
        if recipe then
            local itemName = recipe.name or "Recipe"
            local itemLink = "|cff1eff00|Hitem:" .. recipe.itemID .. ":0:0:0:0:0:0:0|h[" .. itemName .. "]|h|r"
            local priceStr = FormatMoney(recipe.price)
            
            rightPanel.RecipeButton.itemLink = itemLink
            rightPanel.RecipeButton:SetText("Recipe: " .. itemLink .. priceStr)
            rbText:SetTextColor(1, 0.82, 0)
            
            rightPanel.CookInfo:SetText("|cFF00FF00Optimal for Cooking Lvl:|r " .. recipe.cookLvl)
            
            local listData = recipe.sourceType == "Drop" and recipe.drops or recipe.vendors
            if listData then
                local playerFaction = UnitFactionGroup("player")
                local filteredList = {}
                for _, info in ipairs(listData) do
                    if not info.faction or info.faction == "Neutral" or info.faction == playerFaction then
                        table.insert(filteredList, info)
                    end
                end
                
                if #filteredList > 0 then
                    rightPanel.VendorsTitle:SetText(recipe.sourceType == "Drop" and "|TInterface\\Icons\\INV_Misc_Bag_08:14:14:0:0|t |cFFFFD100Recipe Drops From:|r" or "|TInterface\\Icons\\INV_Misc_Coin_01:14:14:0:0|t |cFFFFD100Recipe Vendors:|r")
                    rightPanel.VendorHint:Show()
                    for i, info in ipairs(filteredList) do
                        if not rightPanel.vendorBtns[i] then
                            local vBtn = CreateFrame("Button", nil, rightPanel.VendorsBox)
                            vBtn:SetSize(370, 16)
                            local vText = vBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                            vText:SetPoint("LEFT", 0, 0)
                            vBtn:SetFontString(vText)
                            vBtn.textObject = vText 
                            vBtn:SetScript("OnEnter", function(self) self.textObject:SetTextColor(1, 0.82, 0) end)
                            vBtn:SetScript("OnLeave", function(self) self.textObject:SetTextColor(1, 1, 1) end)
                            rightPanel.vendorBtns[i] = vBtn
                        end
                        
                        local vBtn = rightPanel.vendorBtns[i]
                        vBtn:ClearAllPoints()
                        vBtn:SetPoint("TOPLEFT", rightPanel.VendorsTitle, "BOTTOMLEFT", 6, -4 - (i-1)*16)
                        vBtn.textObject:SetTextColor(1, 1, 1) 
                        vBtn:SetText("• " .. info.name)
                        vBtn:Show()
                        
                        vBtn:SetScript("OnClick", function()
                            if IsShiftKeyDown() then
                                local npcName = string.match(info.name, "^(.-)%s*%(") or info.name
                                npcName = string.match(npcName, "^%s*(.-)%s*$") or npcName
                                local editBox = ChatEdit_GetActiveWindow()
                                if editBox then editBox:Insert("/tar " .. npcName) end
                            else
                                SetMapMarker(info.mapID, info.x, info.y, info.name)
                            end
                        end)
                    end
                else
                    rightPanel.VendorsTitle:SetText("|cFF999999(No vendors available for your faction)|r")
                    rightPanel.VendorHint:Hide()
                end
            end
        end
    elseif cat == "Crafting" then
        rightPanel.RecipeBox:Show()
        rightPanel.RecipeButton:Show()
        rightPanel.CookInfo:Show()
        rightPanel.VendorsBox:Hide()
        rightPanel.VendorHint:Hide()
        
        local craft = data.crafts and data.crafts[1]
        if craft then
            local itemLink = "|cff1eff00|Hitem:" .. craft.itemID .. ":0:0:0:0:0:0:0|h[" .. craft.name .. "]|h|r"
            rightPanel.RecipeButton.itemLink = itemLink
            rightPanel.RecipeButton:SetText("Used in: " .. itemLink)
            rbText:SetTextColor(1, 0.82, 0)
            rightPanel.CookInfo:SetText("|cFF00FF00Profession:|r " .. craft.profession .. " (" .. craft.profLvl .. ")")
        end
    elseif cat == "Consumable" then
        rightPanel.RecipeBox:Show()
        rightPanel.RecipeButton:Hide()
        rightPanel.CookInfo:Show()
        rightPanel.CookInfo:SetText("|cFFFFD100• Notes:|r " .. (data.notes or "None"))
        rightPanel.VendorsBox:Hide()
        rightPanel.VendorHint:Hide()
    end
end

local function ShowLevelingAdvisor()
    local fLvl, fMax, cLvl, cMax = GetPlayerSkills()
    
    rightPanel.FishName:SetText("|TInterface\\Icons\\INV_Misc_Book_09:20:20:0:0|t Leveling Advisor")
    
    for _, vBtn in ipairs(rightPanel.vendorBtns) do vBtn:Hide() end
    rightPanel.RecipeButton:SetText("")
    rightPanel.RecipeButton.itemLink = nil
    rightPanel.CookInfo:SetText("")
    rightPanel.VendorsTitle:SetText("")
    
    if cLvl >= 300 then
        rightPanel.InfoBox.bg:SetColorTexture(0, 0.28, 0, 0.45)
        rightPanel.SourceType:SetText("|cFF00FF00Congratulations!|r")
        rightPanel.BasicInfo:SetText("Your Cooking skill is at maximum level (300/300)!\nYou can now prepare any fish feast in the realm.")
        rightPanel.RecipeBox:Hide()
        rightPanel.VendorsBox:Hide()
        rightPanel.CatchBox:Hide()
        rightPanel.CookBox:Hide()
        return
    end
    
    -- Najdeme všechny vařitelné ryby seřazené podle minCook
    local candidates = {}
    for id, data in pairs(BFR_Database.Fish) do
        if data.category == "Cookable" and data.recipes and data.recipes[1] then
            local r = data.recipes[1]
            table.insert(candidates, {
                id = id,
                data = data,
                recipe = r,
                minCook = r.minCook or 1,
                fishingMin = data.fishingMin or 1
            })
        end
    end
    table.sort(candidates, function(a, b) return a.minCook < b.minCook end)
    
    -- Hledáme optimální rybu: takovou, která je v tréninkovém dosahu (minCook <= cLvl < minCook + 45)
    local target = nil
    for _, item in ipairs(candidates) do
        if cLvl >= item.minCook and cLvl < (item.minCook + 45) then
            target = item
            break
        end
    end
    if not target then
        for _, item in ipairs(candidates) do
            if item.minCook >= cLvl then
                target = item
                break
            end
        end
    end
    if not target and #candidates > 0 then
        target = candidates[#candidates]
    end
    
    if not target then
        rightPanel.InfoBox.bg:SetColorTexture(0, 0, 0, 0.45)
        rightPanel.SourceType:SetText("No advice available")
        rightPanel.BasicInfo:SetText("No leveling advice available.")
        rightPanel.RecipeBox:Hide()
        rightPanel.VendorsBox:Hide()
        rightPanel.CatchBox:Hide()
        rightPanel.CookBox:Hide()
        return
    end
    
    local isFishLagging = fLvl < target.fishingMin
    local adviceText = ""
    
    if isFishLagging then
        rightPanel.InfoBox.bg:SetColorTexture(0.35, 0.05, 0.05, 0.5)
        rightPanel.SourceType:SetText("|TInterface\\Icons\\Trade_Fishing:14:14:0:0|t |cFFFF3030[ Fishing Level Too Low! ]|r   |cFFCCCCCC(Fishing: " .. fLvl .. "/" .. fMax .. "  |  Cooking: " .. cLvl .. "/" .. cMax .. ")|r")
        adviceText = "|cFFFFD100• Target Fish:|r " .. target.data.name .. "\n"
        adviceText = adviceText .. "|cFFFFD100• Req. Fishing:|r |cFFFF3030" .. target.fishingMin .. "|r (your current skill is |cFFFFFF00" .. fLvl .. "|r)\n"
        adviceText = adviceText .. "|cFFFFD100• Priority Step:|r Level up Fishing to |cFF00FF00" .. target.fishingMin .. "+|r in: " .. target.data.catchLocations .. "\n"
        adviceText = adviceText .. "|cFFFFD100• Next Goal:|r Catch " .. target.data.name .. " to continue Cooking."
    else
        rightPanel.InfoBox.bg:SetColorTexture(0, 0.28, 0, 0.45)
        rightPanel.SourceType:SetText("|TInterface\\Icons\\Trade_Fishing:14:14:0:0|t |cFF00FF00[ Ready to Level Up ]|r   |cFFCCCCCC(Fishing: " .. fLvl .. "/" .. fMax .. "  |  Cooking: " .. cLvl .. "/" .. cMax .. ")|r")
        adviceText = "|cFFFFD100• Target Fish:|r " .. target.data.name .. "\n"
        adviceText = adviceText .. "|cFFFFD100• Where to Catch:|r " .. target.data.catchLocations .. "\n"
        adviceText = adviceText .. "|cFFFFD100• Req. Fishing:|r " .. target.fishingMin .. "  |cFF00FF00(You have " .. fLvl .. " - Ready)|r\n"
        adviceText = adviceText .. "|cFFFFD100• Training Goal:|r Cook this fish to Cooking level |cFF00FF00" .. (target.minCook + 40) .. "|r!"
    end
    rightPanel.BasicInfo:SetText(adviceText)
    
    -- Spodní boxy
    rightPanel.CatchBox:Show()
    if not isFishLagging then
        rightPanel.CatchBox.bg:SetColorTexture(0, 0.4, 0, 0.6)
        rightPanel.CatchBox.Text:SetText("|TInterface\\Icons\\Trade_Fishing:14:14:0:0|t Fishing Ready (" .. fLvl .. "/" .. target.fishingMin .. ")")
    else
        rightPanel.CatchBox.bg:SetColorTexture(0.5, 0, 0, 0.6)
        rightPanel.CatchBox.Text:SetText("|TInterface\\Icons\\Trade_Fishing:14:14:0:0|t Need Fishing " .. target.fishingMin .. " (" .. fLvl .. ")")
    end
    
    rightPanel.CookBox:Show()
    if cLvl >= target.minCook then
        rightPanel.CookBox.bg:SetColorTexture(0, 0.4, 0, 0.6)
        rightPanel.CookBox.Text:SetText("|TInterface\\Icons\\INV_Misc_Food_15:14:14:0:0|t Cooking Ready (" .. cLvl .. "/" .. target.minCook .. ")")
    else
        rightPanel.CookBox.bg:SetColorTexture(0.5, 0, 0, 0.6)
        rightPanel.CookBox.Text:SetText("|TInterface\\Icons\\INV_Misc_Food_15:14:14:0:0|t Need Cooking " .. target.minCook .. " (" .. cLvl .. ")")
    end
    
    -- Recept
    rightPanel.RecipeBox:Show()
    rightPanel.RecipeButton:Show()
    rightPanel.CookInfo:Show()
    rightPanel.VendorsBox:Show()
    
    local recipe = target.recipe
    if recipe then
        local itemName = recipe.name or "Recipe"
        local itemLink = "|cff1eff00|Hitem:" .. recipe.itemID .. ":0:0:0:0:0:0:0|h[" .. itemName .. "]|h|r"
        local priceStr = FormatMoney(recipe.price)
        rightPanel.RecipeButton.itemLink = itemLink
        rightPanel.RecipeButton:SetText("Recipe: " .. itemLink .. priceStr)
        rbText:SetTextColor(1, 0.82, 0)
        rightPanel.CookInfo:SetText("|cFF00FF00Optimal for Cooking Lvl:|r " .. recipe.cookLvl)
        
        local listData = recipe.sourceType == "Drop" and recipe.drops or recipe.vendors
        if listData then
            local playerFaction = UnitFactionGroup("player")
            local filteredList = {}
            for _, info in ipairs(listData) do
                if not info.faction or info.faction == "Neutral" or info.faction == playerFaction then
                    table.insert(filteredList, info)
                end
            end
            if #filteredList > 0 then
                rightPanel.VendorsTitle:SetText(recipe.sourceType == "Drop" and "|TInterface\\Icons\\INV_Misc_Bag_08:14:14:0:0|t |cFFFFD100Recipe Drops From:|r" or "|TInterface\\Icons\\INV_Misc_Coin_01:14:14:0:0|t |cFFFFD100Recipe Vendors:|r")
                rightPanel.VendorHint:Show()
                for i, info in ipairs(filteredList) do
                    if not rightPanel.vendorBtns[i] then
                        local vBtn = CreateFrame("Button", nil, rightPanel.VendorsBox)
                        vBtn:SetSize(370, 16)
                        local vText = vBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        vText:SetPoint("LEFT", 0, 0)
                        vBtn:SetFontString(vText)
                        vBtn.textObject = vText
                        vBtn:SetScript("OnEnter", function(self) self.textObject:SetTextColor(1, 0.82, 0) end)
                        vBtn:SetScript("OnLeave", function(self) self.textObject:SetTextColor(1, 1, 1) end)
                        rightPanel.vendorBtns[i] = vBtn
                    end
                    local vBtn = rightPanel.vendorBtns[i]
                    vBtn:ClearAllPoints()
                    vBtn:SetPoint("TOPLEFT", rightPanel.VendorsTitle, "BOTTOMLEFT", 6, -4 - (i-1)*16)
                    vBtn.textObject:SetTextColor(1, 1, 1)
                    vBtn:SetText("• " .. info.name)
                    vBtn:Show()
                    vBtn:SetScript("OnClick", function()
                        if IsShiftKeyDown() then
                            local npcName = string.match(info.name, "^(.-)%s*%(") or info.name
                            npcName = string.match(npcName, "^%s*(.-)%s*$") or npcName
                            local editBox = ChatEdit_GetActiveWindow()
                            if editBox then editBox:Insert("/tar " .. npcName) end
                        else
                            SetMapMarker(info.mapID, info.x, info.y, info.name)
                        end
                    end)
                end
            else
                rightPanel.VendorsTitle:SetText("|cFF999999(No vendors available for your faction)|r")
                rightPanel.VendorHint:Hide()
            end
        end
    end
end

if not BFR_CollapsedCats then BFR_CollapsedCats = {} end

function BFR_RefreshUI()
    if scrollChild.buttons then
        for _, btn in ipairs(scrollChild.buttons) do btn:Hide() end
    end
    scrollChild.buttons = {}
    
    local categoryData = { Cookable = {}, Crafting = {}, Consumable = {} }
    for itemID, data in pairs(BFR_Database.Fish) do
        local cat = data.category or "Cookable"
        if not categoryData[cat] then categoryData[cat] = {} end
        table.insert(categoryData[cat], {id = itemID, data = data})
    end
    
    local catColors = {
        Cookable = {1, 0.82, 0}, 
        Crafting = {0.4, 0.8, 1}, 
        Consumable = {0.7, 0.7, 0.7}
    }
    local categories = { "Cookable", "Crafting", "Consumable" }
    
    for _, cat in ipairs(categories) do
        table.sort(categoryData[cat], function(a, b)
            local fa = a.data.recipes and a.data.recipes[1] and a.data.recipes[1].minCook or (a.data.crafts and a.data.crafts[1] and a.data.crafts[1].minCook) or 9999
            local fb = b.data.recipes and b.data.recipes[1] and b.data.recipes[1].minCook or (b.data.crafts and b.data.crafts[1] and b.data.crafts[1].minCook) or 9999
            if fa == fb then return a.data.name < b.data.name end
            return fa < fb
        end)
    end
    
    local yOffset = -5
    
    -- Tlačítko Leveling Advisor nad kategoriemi
    local advisorBtn = CreateFrame("Button", nil, scrollChild)
    advisorBtn:SetSize(240, 20)
    advisorBtn:SetPoint("TOPLEFT", 10, yOffset)
    
    local advBg = advisorBtn:CreateTexture(nil, "BACKGROUND")
    advBg:SetAllPoints()
    advBg:SetColorTexture(0.25, 0.2, 0.05, 0.7)
    
    local advText = advisorBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    advText:SetPoint("LEFT", 6, 0)
    advText:SetText("|TInterface\\Icons\\INV_Misc_Book_09:14:14:0:0|t |cFFFFD100Leveling Advisor|r")
    advisorBtn:SetFontString(advText)
    advisorBtn.textObject = advText
    
    local advHighlight = advisorBtn:CreateTexture(nil, "ARTWORK")
    advHighlight:SetAllPoints()
    advHighlight:SetColorTexture(1, 0.82, 0, 0.25)
    advHighlight:Hide()
    advisorBtn.highlightBg = advHighlight
    advisorBtn.baseColor = {1, 0.82, 0}
    advisorBtn.itemID = "ADVISOR"
    
    if BFR_SelectedFish == "ADVISOR" then
        advHighlight:Show()
        advText:SetTextColor(1, 1, 1)
    end
    
    advisorBtn:SetScript("OnEnter", function(self)
        self.textObject:SetTextColor(1, 1, 1)
        self.highlightBg:Show()
    end)
    advisorBtn:SetScript("OnLeave", function(self)
        if BFR_SelectedFish ~= "ADVISOR" then
            self.textObject:SetTextColor(1, 0.82, 0)
            self.highlightBg:Hide()
        end
    end)
    advisorBtn:SetScript("OnClick", function(self)
        BFR_SelectedFish = "ADVISOR"
        ShowLevelingAdvisor()
        if scrollChild.buttons then
            for _, b in ipairs(scrollChild.buttons) do
                if b.itemID then
                    if b.itemID == "ADVISOR" then
                        b.highlightBg:Show()
                        b.textObject:SetTextColor(1, 1, 1)
                    else
                        b.highlightBg:Hide()
                        b.textObject:SetTextColor(b.baseColor[1], b.baseColor[2], b.baseColor[3])
                    end
                end
            end
        end
    end)
    table.insert(scrollChild.buttons, advisorBtn)
    yOffset = yOffset - 27
    
    for _, cat in ipairs(categories) do
        local list = categoryData[cat]
        if list and #list > 0 then
            -- Tlačítko pro nadpis (skládání sekce)
            local headerBtn = CreateFrame("Button", nil, scrollChild)
            headerBtn:SetSize(250, 18)
            headerBtn:SetPoint("TOPLEFT", 5, yOffset)
            
            -- Pozadí pro nadpis, aby to vypadalo jako sekce
            local tex = headerBtn:CreateTexture(nil, "BACKGROUND")
            tex:SetAllPoints()
            tex:SetColorTexture(0.15, 0.15, 0.15, 0.7)
            
            local ht = headerBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            ht:SetPoint("LEFT", 5, 0)
            
            local c = catColors[cat]
            ht:SetTextColor(c[1], c[2], c[3])
            
            local isCollapsed = BFR_CollapsedCats[cat]
            ht:SetText((isCollapsed and "[+] " or "[-] ") .. string.upper(cat))
            headerBtn:SetFontString(ht)
            
            headerBtn:SetScript("OnClick", function()
                BFR_CollapsedCats[cat] = not BFR_CollapsedCats[cat]
                BFR_RefreshUI()
            end)
            
            table.insert(scrollChild.buttons, headerBtn)
            yOffset = yOffset - 20
            
            -- Vykreslení ryb uvnitř sekce (pokud není sbalená)
            if not isCollapsed then
                for _, fish in ipairs(list) do
                    local itemID = fish.id
                    local data = fish.data
                    
                    local btn = CreateFrame("Button", nil, scrollChild)
                    btn:SetSize(240, 16) 
                    btn:SetPoint("TOPLEFT", 15, yOffset)
                    
                    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    btnText:SetPoint("LEFT", 0, 0)
                    btn:SetFontString(btnText)
                    btn.textObject = btnText
                    
                    local highlightBg = btn:CreateTexture(nil, "ARTWORK")
                    highlightBg:SetAllPoints()
                    highlightBg:SetColorTexture(1, 1, 1, 0.25)
                    
                    btn.itemID = itemID
                    btn.highlightBg = highlightBg
                    btn.baseColor = c
                    
                    if BFR_SelectedFish == itemID then
                        highlightBg:Show()
                        btnText:SetTextColor(1, 1, 1)
                    else
                        highlightBg:Hide()
                        btnText:SetTextColor(c[1], c[2], c[3])
                    end
                    
                    btn:SetScript("OnEnter", function(self) 
                        self.textObject:SetTextColor(1, 1, 1) 
                        self.highlightBg:Show()
                    end)
                    btn:SetScript("OnLeave", function(self) 
                        if BFR_SelectedFish ~= self.itemID then
                            self.textObject:SetTextColor(self.baseColor[1], self.baseColor[2], self.baseColor[3])
                            self.highlightBg:Hide()
                        end
                    end)
                    
                    local prefix = ""
                    if SafeHasItem(itemID) then
                        prefix = prefix .. "|TInterface\\Buttons\\Button-Backpack-Up:14:14:0:-1|t "
                    end
                    
                    btn:SetText(prefix .. data.name)
                    btn:SetScript("OnClick", function(self) 
                        BFR_SelectedFish = self.itemID
                        ShowFishDetails(self.itemID) 
                        
                        -- Zvýraznění aktivní ryby bez smazání tlačítek
                        if scrollChild.buttons then
                            for _, b in ipairs(scrollChild.buttons) do
                                if b.itemID then
                                    if b.itemID == BFR_SelectedFish then
                                        b.highlightBg:Show()
                                        b.textObject:SetTextColor(1, 1, 1)
                                    else
                                        b.highlightBg:Hide()
                                        b.textObject:SetTextColor(b.baseColor[1], b.baseColor[2], b.baseColor[3])
                                    end
                                end
                            end
                        end
                    end)
                    
                    table.insert(scrollChild.buttons, btn)
                    yOffset = yOffset - 18 
                end
            end
            yOffset = yOffset - 5 
        end
    end
    
    -- Dynamické přepočítání výšky seznamu, aby scrollbar fungoval správně
    scrollChild:SetHeight(math.abs(yOffset))
end

local function UpdateListVisuals()
    local fLvl, fMax, cLvl, cMax = GetPlayerSkills()
    if BFR_UIFrame.SkillText then
        BFR_UIFrame.SkillText:SetText(string.format("|TInterface\\Icons\\Trade_Fishing:18:18:0:0|t Fishing: %d/%d      |TInterface\\Icons\\INV_Misc_Food_15:18:18:0:0|t Cooking: %d/%d", fLvl, fMax, cLvl, cMax))
    end
    
    if not scrollChild.buttons then return end
    for _, btn in ipairs(scrollChild.buttons) do
        if btn.itemID then
            local data = BFR_Database.Fish[btn.itemID]
            if data then
                local prefix = ""
                if SafeHasItem(btn.itemID) then
                    prefix = prefix .. "|TInterface\\Buttons\\Button-Backpack-Up:14:14:0:-1|t "
                end
                
                local suffix = ""
                if fLvl >= (data.fishingMin or 1) then
                    suffix = suffix .. " |TInterface\\Icons\\Trade_Fishing:14:14:0:-1|t"
                end
                if data.category == "Cookable" and data.recipes and data.recipes[1] then
                    if cLvl >= (data.recipes[1].minCook or 1) then
                        suffix = suffix .. " |TInterface\\Icons\\INV_Misc_Food_15:14:14:0:-1|t"
                    end
                end
                
                btn:SetText(prefix .. data.name .. suffix)
            end
        end
    end
    
    if BFR_SelectedFish == "ADVISOR" then
        ShowLevelingAdvisor()
    elseif BFR_SelectedFish then
        local data = BFR_Database.Fish[BFR_SelectedFish]
        if data then
            if fLvl >= (data.fishingMin or 1) then
                rightPanel.CatchBox.bg:SetColorTexture(0, 0.4, 0, 0.6)
                rightPanel.CatchBox.Text:SetText("|TInterface\\Icons\\Trade_Fishing:14:14:0:0|t You can catch this")
            else
                rightPanel.CatchBox.bg:SetColorTexture(0.5, 0, 0, 0.6)
                rightPanel.CatchBox.Text:SetText("|TInterface\\Icons\\Trade_Fishing:14:14:0:0|t You cannot catch this")
            end
            
            if data.category == "Cookable" and data.recipes and data.recipes[1] then
                if cLvl >= (data.recipes[1].minCook or 1) then
                    rightPanel.CookBox.bg:SetColorTexture(0, 0.4, 0, 0.6)
                    rightPanel.CookBox.Text:SetText("|TInterface\\Icons\\INV_Misc_Food_15:14:14:0:0|t You can cook this")
                else
                    rightPanel.CookBox.bg:SetColorTexture(0.5, 0, 0, 0.6)
                    rightPanel.CookBox.Text:SetText("|TInterface\\Icons\\INV_Misc_Food_15:14:14:0:0|t You cannot cook this")
                end
            end
        end
    end
end

BFR_UIFrame:RegisterEvent("BAG_UPDATE")
BFR_UIFrame:RegisterEvent("SKILL_LINES_CHANGED")
BFR_UIFrame:SetScript("OnEvent", function(self, event, ...)
    if self:IsShown() then
        UpdateListVisuals()
    end
end)

BFR_UIFrame:SetScript("OnShow", function()
    if not BFR_SelectedFish then
        BFR_SelectedFish = "ADVISOR"
    end
    BFR_RefreshUI()
    UpdateListVisuals()
    if BFR_SelectedFish == "ADVISOR" then
        ShowLevelingAdvisor()
    end
end)
