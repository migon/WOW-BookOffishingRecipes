-- Database.lua
-- Kompletní databáze ryb a receptů z klasického WoW (S přesnými souřadnicemi WoWHead a cenami receptů)

BFR_Database = {}
BFR_Database.Fish = {
    [6291] = {
        category = "Cookable",
        name = "Raw Brilliant Smallfish",
        catchLocations = "Elwynn Forest, Durotar, Mulgore, Teldrassil, Dun Morogh",
        fishingMin = 1,
        recipes = {
            { name = "Recipe: Brilliant Smallfish", itemID = 6325, price = 100, minCook = 1, cookLvl = "1 - 45", sourceType = "Vendor",
                vendors = {
                    { name = "Tharynn Bouden (Elwynn Forest)", mapID = 1429, x = 41.8, y = 67.2, faction = "Alliance" },
                    { name = "Zansoa (Durotar)", mapID = 1411, x = 56.1, y = 73.4, faction = "Horde" }
                }
            }
        }
    },
    [6303] = {
        category = "Cookable",
        name = "Raw Slitherskin Mackerel",
        catchLocations = "Durotar, Westfall, Teldrassil, Tirisfal Glades",
        fishingMin = 1,
        recipes = {
            { name = "Recipe: Slitherskin Mackerel", itemID = 2697, price = 100, minCook = 1, cookLvl = "1 - 45", sourceType = "Vendor",
                vendors = {
                    { name = "Zansoa (Durotar)", mapID = 1411, x = 56.1, y = 73.4, faction = "Horde" },
                    { name = "Tansy Puddlefizz (Ironforge)", mapID = 1455, x = 48.1, y = 6.4, faction = "Alliance" },
                    { name = "Armand Cromwell (Undercity)", mapID = 1458, x = 80.7, y = 31.3, faction = "Horde" }
                }
            }
        }
    },
    [6289] = {
        category = "Cookable",
        name = "Raw Longjaw Mud Snapper",
        catchLocations = "Elwynn Forest, Durotar, Mulgore, Darkshore",
        fishingMin = 50,
        recipes = {
            { name = "Recipe: Longjaw Mud Snapper", itemID = 6329, price = 500, minCook = 50, cookLvl = "50 - 90", sourceType = "Vendor",
                vendors = {
                    { name = "Tharynn Bouden (Elwynn Forest)", mapID = 1429, x = 41.8, y = 67.2, faction = "Alliance" },
                    { name = "Zansoa (Durotar)", mapID = 1411, x = 56.1, y = 73.4, faction = "Horde" }
                }
            }
        }
    },
    [6317] = {
        category = "Cookable",
        name = "Loch Frenzy",
        catchLocations = "Loch Modan",
        fishingMin = 50,
        recipes = {
            { name = "Recipe: Loch Frenzy Delight", itemID = 6330, price = 500, minCook = 50, cookLvl = "50 - 90", sourceType = "Vendor",
                vendors = {
                    { name = "Khara Deepwater (Loch Modan)", mapID = 1432, x = 40.3, y = 39.3, faction = "Alliance" }
                }
            }
        }
    },
    [6361] = {
        category = "Cookable",
        name = "Raw Rainbow Fin Albacore",
        catchLocations = "The Barrens, Loch Modan, Westfall, Darkshore",
        fishingMin = 50,
        recipes = {
            { name = "Recipe: Rainbow Fin Albacore", itemID = 6369, price = 500, minCook = 50, cookLvl = "50 - 90", sourceType = "Vendor",
                vendors = {
                    { name = "Wunna Darkmane (Mulgore)", mapID = 1412, x = 46.2, y = 58.2, faction = "Horde" },
                    { name = "Suja (Orgrimmar)", mapID = 1454, x = 56.6, y = 61.2, faction = "Horde" },
                    { name = "Kelsey Yance (Stranglethorn Vale)", mapID = 1434, x = 42.8, y = 69.0, faction = "Neutral" },
                    { name = "Grimtak (Durotar)", mapID = 1411, x = 50.8, y = 42.8, faction = "Horde" }
                }
            }
        }
    },
    [6522] = {
        category = "Cookable",
        name = "Deviate Fish",
        catchLocations = "The Barrens (Oasis), Wailing Caverns",
        fishingMin = 50,
        recipes = {
            { name = "Recipe: Savory Deviate Delight", itemID = 6661, price = 0, minCook = 85, cookLvl = "85 - 125", sourceType = "Drop",
                drops = {
                    { name = "Oasis Snapjaw (The Barrens)", mapID = 1413, x = 48.0, y = 33.0, faction = "Neutral" },
                    { name = "Deviate Ravager (Wailing Caverns)", mapID = 1413, x = 46.1, y = 36.3, faction = "Neutral" }
                }
            }
        }
    },
    [21071] = {
        category = "Cookable",
        name = "Raw Sagefish",
        catchLocations = "Hillsbrad Foothills, Ashenvale, Alterac Mountains",
        fishingMin = 80,
        recipes = {
            { name = "Recipe: Smoked Sagefish", itemID = 21099, price = 1000, minCook = 80, cookLvl = "80 - 120", sourceType = "Vendor",
                vendors = {
                    { name = "Wulan (Desolace)", mapID = 1443, x = 26.2, y = 69.4, faction = "Horde" },
                    { name = "Lindea Rabonne (Hillsbrad Foothills)", mapID = 1424, x = 50.6, y = 61.1, faction = "Alliance" }
                }
            }
        }
    },
    [6308] = {
        category = "Cookable",
        name = "Raw Bristle Whisker Catfish",
        catchLocations = "Hillsbrad Foothills, Ashenvale, Wetlands, Redridge Mountains",
        fishingMin = 100,
        recipes = {
            { name = "Recipe: Bristle Whisker Catfish", itemID = 6328, price = 1000, minCook = 100, cookLvl = "100 - 140", sourceType = "Vendor",
                vendors = {
                    { name = "Derak Nightfall (Hillsbrad Foothills)", mapID = 1424, x = 63.3, y = 58.1, faction = "Horde" },
                    { name = "Catherine Leland (Stormwind)", mapID = 1453, x = 46.4, y = 58.1, faction = "Alliance" }
                }
            }
        }
    },
    [21153] = {
        category = "Cookable",
        name = "Raw Greater Sagefish",
        catchLocations = "Stranglethorn Vale, Dustwallow Marsh",
        fishingMin = 150,
        recipes = {
            { name = "Recipe: Sagefish Delight", itemID = 21100, price = 2200, minCook = 175, cookLvl = "175 - 215", sourceType = "Vendor",
                vendors = {
                    { name = "Wulan (Desolace)", mapID = 1443, x = 26.2, y = 69.4, faction = "Horde" },
                    { name = "Lindea Rabonne (Hillsbrad Foothills)", mapID = 1424, x = 50.6, y = 61.1, faction = "Alliance" }
                }
            }
        }
    },
    [8365] = {
        category = "Cookable",
        name = "Raw Mithril Head Trout",
        catchLocations = "Stranglethorn Vale, Dustwallow Marsh, Alterac Mountains",
        fishingMin = 175,
        recipes = {
            { name = "Recipe: Mithril Head Trout", itemID = 16971, price = 2200, minCook = 175, cookLvl = "175 - 215", sourceType = "Vendor",
                vendors = {
                    { name = "Kelsey Yance (Stranglethorn Vale)", mapID = 1434, x = 42.8, y = 69.0, faction = "Neutral" },
                    { name = "Wulan (Desolace)", mapID = 1443, x = 26.2, y = 69.4, faction = "Horde" },
                    { name = "Khara Deepwater (Loch Modan)", mapID = 1432, x = 40.3, y = 39.3, faction = "Alliance" }
                }
            }
        }
    },
    [13758] = {
        category = "Cookable",
        name = "Raw Redgill",
        catchLocations = "Feralas, Un'Goro Crater, Felwood",
        fishingMin = 225,
        recipes = {
            { name = "Recipe: Filet of Redgill", itemID = 13939, price = 4500, minCook = 225, cookLvl = "225 - 265", sourceType = "Vendor",
                vendors = {
                    { name = "Kelsey Yance (Stranglethorn Vale)", mapID = 1434, x = 42.8, y = 69.0, faction = "Neutral" }
                }
            }
        }
    },
    [13756] = {
        category = "Cookable",
        name = "Raw Spotted Yellowtail",
        catchLocations = "Tanaris, Azshara, Feralas",
        fishingMin = 225,
        recipes = {
            { name = "Recipe: Spotted Yellowtail", itemID = 13943, price = 4500, minCook = 225, cookLvl = "225 - 265", sourceType = "Vendor",
                vendors = {
                    { name = "Gikkix (Tanaris)", mapID = 1446, x = 66.6, y = 22.1, faction = "Neutral" }
                }
            }
        }
    },
    [13754] = {
        category = "Cookable",
        name = "Raw Glossy Mightfish",
        catchLocations = "Azshara, Feralas, Tanaris",
        fishingMin = 225,
        recipes = {
            { name = "Recipe: Cooked Glossy Mightfish", itemID = 13940, price = 4500, minCook = 225, cookLvl = "225 - 265", sourceType = "Vendor",
                vendors = {
                    { name = "Kelsey Yance (Stranglethorn Vale)", mapID = 1434, x = 42.8, y = 69.0, faction = "Neutral" }
                }
            }
        }
    },
    [13755] = {
        category = "Cookable",
        name = "Winter Squid",
        catchLocations = "Azshara, Feralas, Tanaris, Stranglethorn (Winter Only)",
        fishingMin = 240,
        recipes = {
            { name = "Recipe: Grilled Squid", itemID = 13942, price = 4500, minCook = 240, cookLvl = "240 - 280", sourceType = "Vendor",
                vendors = {
                    { name = "Gikkix (Tanaris)", mapID = 1446, x = 66.6, y = 22.1, faction = "Neutral" }
                }
            }
        }
    },
    [13759] = {
        category = "Cookable",
        name = "Raw Nightfin Snapper",
        catchLocations = "Feralas, Un'Goro Crater, Felwood (Night Only)",
        fishingMin = 250,
        recipes = {
            { name = "Recipe: Nightfin Soup", itemID = 13941, price = 4500, minCook = 250, cookLvl = "250 - 290", sourceType = "Vendor",
                vendors = {
                    { name = "Gikkix (Tanaris)", mapID = 1446, x = 66.6, y = 22.1, faction = "Neutral" }
                }
            }
        }
    },
    [13760] = {
        category = "Cookable",
        name = "Raw Sunscale Salmon",
        catchLocations = "Feralas, Un'Goro Crater, Felwood (Day Only)",
        fishingMin = 250,
        recipes = {
            { name = "Recipe: Poached Sunscale Salmon", itemID = 13945, price = 4500, minCook = 250, cookLvl = "250 - 290", sourceType = "Vendor",
                vendors = {
                    { name = "Gikkix (Tanaris)", mapID = 1446, x = 66.6, y = 22.1, faction = "Neutral" }
                }
            }
        }
    },
    [13761] = {
        category = "Cookable",
        name = "Raw Whitescale Salmon",
        catchLocations = "Winterspring, Eastern Plaguelands",
        fishingMin = 330,
        recipes = {
            { name = "Recipe: Baked Salmon", itemID = 13947, price = 15000, minCook = 275, cookLvl = "275 - 315", sourceType = "Vendor",
                vendors = {
                    { name = "Vivianna (Feralas)", mapID = 1426, x = 31.3, y = 43.0, faction = "Alliance" },
                    { name = "Sheendra Tallgrass (Feralas)", mapID = 1426, x = 74.6, y = 42.7, faction = "Horde" }
                }
            }
        }
    },
    [13762] = {
        category = "Cookable",
        name = "Darkclaw Lobster",
        catchLocations = "Azshara, Feralas, Winterspring",
        fishingMin = 330,
        recipes = {
            { name = "Recipe: Lobster Stew", itemID = 13948, price = 15000, minCook = 275, cookLvl = "275 - 315", sourceType = "Vendor",
                vendors = {
                    { name = "Vivianna (Feralas)", mapID = 1426, x = 31.3, y = 43.0, faction = "Alliance" },
                    { name = "Sheendra Tallgrass (Feralas)", mapID = 1426, x = 74.6, y = 42.7, faction = "Horde" }
                }
            }
        }
    },
    [13757] = {
        category = "Cookable",
        name = "Large Raw Mightfish",
        catchLocations = "Azshara, Feralas",
        fishingMin = 330,
        recipes = {
            { name = "Recipe: Mightfish Steak", itemID = 13946, price = 15000, minCook = 275, cookLvl = "275 - 315", sourceType = "Vendor",
                vendors = {
                    { name = "Vivianna (Feralas)", mapID = 1426, x = 31.3, y = 43.0, faction = "Alliance" },
                    { name = "Sheendra Tallgrass (Feralas)", mapID = 1426, x = 74.6, y = 42.7, faction = "Horde" }
                }
            }
        }
    },
    -- =================== ALCHYMIE / CRAFTING ===================
    [6358] = {
        category = "Crafting",
        name = "Oily Blackmouth",
        catchLocations = "The Barrens, Darkshore, Westfall, Silverpine Forest",
        fishingMin = 1,
        crafts = {
            { name = "Blackmouth Oil", itemID = 6370, minCook = 50, profession = "Alchemy", profLvl = 50 }
        }
    },
    [6359] = {
        category = "Crafting",
        name = "Firefin Snapper",
        catchLocations = "Stranglethorn Vale, Hillsbrad Foothills, Arathi Highlands",
        fishingMin = 100,
        crafts = {
            { name = "Fire Oil", itemID = 6371, minCook = 130, profession = "Alchemy", profLvl = 130 }
        }
    },
    [13753] = {
        category = "Crafting",
        name = "Stonescale Eel",
        catchLocations = "Feralas, Azshara, Tanaris",
        fishingMin = 205,
        crafts = {
            { name = "Stonescale Oil", itemID = 13423, minCook = 250, profession = "Alchemy", profLvl = 250 }
        }
    },
    -- =================== CONSUMABLE ONLY ===================
    [4592] = {
        category = "Consumable",
        name = "Raw Spotted Sunfish",
        catchLocations = "Elwynn Forest, Durotar, Mulgore",
        fishingMin = 1,
        notes = "Can be eaten raw to restore health. Also an excellent food for Hunter pets (Cats, Bears, Crocolisks, Turtles, Crab)."
    },
    [8956] = {
        category = "Consumable",
        name = "Darkshore Grouper",
        catchLocations = "Darkshore",
        fishingMin = 50,
        notes = "Often fed to Hunter pets (Cats, Bears) leveling up in Darkshore or eaten raw."
    },
    [12238] = {
        category = "Consumable",
        name = "Sickly Looking Fish",
        catchLocations = "Alterac Mountains, Western Plaguelands",
        fishingMin = 200,
        notes = "Poor quality fish. Not recommended for consumption, but pets will eat it."
    }
}
