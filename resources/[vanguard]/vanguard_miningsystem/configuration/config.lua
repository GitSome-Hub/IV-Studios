----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----
---
----             __     __                              _   _          _         
----             \ \   / /_ _ _ __   __ _  __ _ _ __ __| | | |    __ _| |__  ___ 
----              \ \ / / _` | '_ \ / _` |/ _` | '__/ _` | | |   / _` | '_ \/ __|
----               \ V / (_| | | | | (_| | (_| | | | (_| | | |__| (_| | |_) \__ \
----                \_/ \__,_|_| |_|\__, |\__,_|_|  \__,_| |_____\__,_|_.__/|___/
----                                |___/                                        
---- 
----                         VANGUARD LABS | MINING SYSTEM [ESX/QBCORE]
----
----               Thank you for purchasing our script; we greatly appreciate your preference.
----        If you have any questions or any modifications in mind, please contact us via Discord.
----
----                           Support and More: https://discord.gg/rq5yVBACTf
----                            if link is not working, add me: james_vanguard
----
----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----
----

-- Configuration settings
Config = {}

-- ===============================
--    Pickaxe Mining System
-- ===============================
Config.pickaxeModel = `prop_tool_pickaxe`
Config.miningDuration = 10000 -- Duration of the mining activity (10 seconds)
Config.pickaxeBreakChance = 0.50 -- 50% chance of the pickaxe breaking
Config.rockModel = `prop_rock_5_e` -- Rock model
Config.rockSpawnRadius = 0.2 -- Rock spawn radius
Config.rocksToSpawn = 2 -- Number of rocks to spawn
Config.rockSpawnInterval = 3500 -- Rock spawn interval (3500ms = 3.5 seconds)

Config.miningLocations = {
    {coords = vector3(-590.694, 2074.687, 132.30), heading = 277.78},
    {coords = vector3(-591.760, 2067.876, 132.15), heading = 115.95},
    {coords = vector3(-588.775, 2066.266, 132.03), heading = 258.61},
    -- Add more locations as needed
}

-- ===============================
--    Drill Mining System
-- ===============================
Config.drillModel = `hei_prop_heist_drill`
Config.drillingDuration = 10000 -- Duration of the drilling activity (10 seconds)
Config.drillBreakChance = 0.50 -- 50% chance of the drill breaking
Config.drillRockModel = `prop_rock_5_e` -- Rock model for drill
Config.drillRockSpawnRadius = 0.2 -- Rock spawn radius for drill
Config.drillRocksToSpawn = 4 -- Number of rocks to spawn for drill
Config.drillRockSpawnInterval = 2000 -- Rock spawn interval for drill (2000ms = 2 seconds)

Config.drillLocations = {
    {coords = vector3(-584.697, 2045.444, 130.51), heading = 295.0},
    {coords = vector3(-586.687, 2043.325, 130.59), heading = 123.61},
    {coords = vector3(-582.351, 2040.160, 130.08), heading = 294.11},
    {coords = vector3(-582.521, 2035.613, 129.95), heading = 127.22},
    -- Add more locations as needed
}

-- ===============================
--    Hand Drill Mining System
-- ===============================
Config.drillHandDuration = 12000 -- Duration of the drilling activity (12 seconds)
Config.drillHandBreakChance = 0.50 -- 50% chance of the hand drill breaking
Config.drillHandRockModel = `prop_rock_5_e` -- Rock model for hand drill
Config.drillHandRockSpawnRadius = 0.2 -- Rock spawn radius for hand drill
Config.drillHandRocksToSpawn = 3 -- Number of rocks to spawn for hand drill
Config.drillHandRockSpawnInterval = 2000 -- Rock spawn interval for hand drill (2000ms = 2 seconds)

Config.drillHandRockLocations = {
    {coords = vector3(-589.740, 2059.172, 131.67), heading = 90.91},
    {coords = vector3(-588.290, 2061.558, 131.98), heading = 275.17},
    {coords = vector3(-587.290, 2054.577, 131.33), heading = 258.56},
    {coords = vector3(-586.358, 2049.951, 130.90), heading = 283.94},
    -- Add more locations as needed
}

-- ===============================
--    Light Generator System
-- ===============================
Config.propModel2 = "prop_elecbox_23" -- Model of the prop to be created
Config.generatorLocations = {
    {coords = vector3(-593.468, 2085.103, 130.38), heading = 291.75}
    -- Add more locations as needed
}

Config.warningLightModel = "prop_wall_light_19a" -- Model of the light prop
Config.mechanicAnimationDuration = 5000 -- Duration of the animation in milliseconds (5 seconds)
Config.lightPositions = {
    {coords = vector3(-592.404, 2076.405, 133.15), heading = 0.0, rotate = 45.0},
    {coords = vector3(-590.986, 2070.058, 133.15), heading = 0.0, rotate = 45.0},
    {coords = vector3(-589.408, 2062.710, 132.70), heading = 0.0, rotate = 45.0},
    {coords = vector3(-588.427, 2054.950, 132.00), heading = 0.0, rotate = 45.0},
    {coords = vector3(-586.723, 2047.057, 132.00), heading = 0.0, rotate = 45.0},
    {coords = vector3(-583.679, 2040.239, 131.00), heading = 0.0, rotate = 45.0},
    {coords = vector3(-579.546, 2033.703, 131.00), heading = 0.0, rotate = 45.0}
} -- Coordinates, heading, and rotation where the warning lights will be created

-- ===============================
--    Inventory Items
-- ===============================
Config.items = {
    battery = "miner_battery",
    pickaxe = "miner_pickaxe",
    drill = "miner_drill",
    drillHand = "miner_drillhand",
    stone = "miner_stone",
    helmet = "miner_helmet",
}

-- ===============================
--    Mining Tools and Accessories
-- ===============================
Config.MiningTools = {
    Tools = {
        {
            name = "Pickaxe",
            item = "miner_pickaxe",
            price = 50,
            icon = "fa-solid fa-hammer"
        },
        {
            name = "Advanced Drill",
            item = "miner_drill",
            price = 200,
            icon = "fa-solid fa-cogs"
        },
        {
            name = "Normal Drill",
            item = "miner_drillhand",
            price = 100,
            icon = "fa-solid fa-wrench"
        }
    },
    Utensils = {
        {
            name = "Helmet",
            item = "miner_helmet",
            price = 100,
            icon = "fa-solid fa-hard-hat"
        },
        {
            name = "Battery",
            item = "miner_battery",
            price = 20,
            icon = "fa-solid fa-battery-full"
        }
    }
}

-- ===============================
--    Conveyor System
-- ===============================
Config.stonePropCoords = vector3(2961.197, 2751.379, 43.376) -- Replace x, y, z with the desired coordinates for the stone prop
Config.depositCoords = vector3(2954.350, 2790.444, 41.321) -- Replace x, y, z with the desired coordinates for the stone deposit

-- ===============================
--    Mining Rewards
-- ===============================
Config.miningRewards = {
    {item = "miner_ore", chance = 0.50},  -- 50% chance to obtain miner_ore
    {item = "miner_gold", chance = 0.30},  -- 30% chance to obtain miner_gold
    {item = "miner_diamond", chance = 0.15}, -- 15% chance to obtain miner_diamond
    {item = "miner_rare", chance = 0.05}   -- 5% chance to obtain miner_rare
}

-- ===============================
--    Miner NPC 
-- ===============================
Config.minerNPC = {
    coords = vector3(-595.389, 2092.873, 130.47),  -- Coordinates where the NPC will be created
    heading = 75.17,  -- NPC heading
    model = 's_m_y_dockwork_01',  -- NPC model
    helmetModel = 'prop_tool_hardhat',  -- Helmet model
}

-- ===============================
--    Ore Selling NPC
-- ===============================
Config.oreSellingNPC = {
    coords = vector3(2946.688, 2744.385, 42.286),  -- Coordinates where the NPC will spawn
    heading = 318.96,  -- NPC heading
    model = 's_m_y_dockwork_01',  -- NPC model
    helmetModel = 'prop_tool_hardhat',  -- Helmet model
    sellableOres = {
        {item = "miner_ore", price = 10, displayName = "Miner Ore"},  -- Price per unit of miner_ore
        {item = "miner_gold", price = 50, displayName = "Miner Gold"},  -- Price per unit of miner_gold
        {item = "miner_diamond", price = 100, displayName = "Miner Diamond"},  -- Price per unit of miner_diamond
        {item = "miner_rare", price = 200, displayName = "Miner Rare"}  -- Price per unit of miner_rare
    }
}

-- ===============================
--    Blips System
-- ===============================
Config.Blips = {
    {
        name = "Mining Area",
        coords = vector3(-597.111, 2092.707, 131.41),
        sprite = 801, -- Blip type (e.g., 318 for a mine)
        color = 16, -- Blip color (e.g., 5 for green)
        scale = 0.8, -- Blip size
    },
    {
        name = "Conveyor Area",
        coords = vector3(2954.704, 2791.080, 41.132),
        sprite = 728, -- Blip type (e.g., 318 for a mine)
        color = 16, -- Blip color (e.g., 4 for red)
        scale = 0.8, -- Blip size
    },
}



-- ===============================
--    Miner Uniforms
-- ===============================
Config.Uniforms = {

    [1] = { 
        name = "Miner",
        male = { 
            ['tshirt_1'] = 59, ['tshirt_2'] = 1, 
            ['torso_1'] = 56, ['torso_2'] = 0, 
            ['arms'] = 0, 
            ['pants_1'] = 9, ['pants_2'] = 4, 
            ['shoes_1'] = 12, ['shoes_2'] = 0, 
            ['helmet_1'] = 0, ['helmet_2'] = 0 },
        female = { 
            ['tshirt_1'] = 15, ['tshirt_2'] = 0, 
            ['torso_1'] = 4, ['torso_2'] = 14, 
            ['arms'] = 4, 
            ['pants_1'] = 25, ['pants_2'] = 1, 
            ['shoes_1'] = 16, ['shoes_2'] = 4 },
    
    },

}

-- ===============================
--    Notifications
-- ===============================
-- Note: type = "mining" - only works with vanguard_notify on bridge.
Config.notifications = {
    noBattery = {title = "HELMET", message = "You don't have any batteries.", type = "error"},
    batteryUsed = {title = "HELMET", message = "One battery was used.", type = "info"},
    noPickaxe = {title = "MINING", message = "You don't have a pickaxe.", type = "mining"},
    noDrill = {title = "MINING", message = "You don't have a drill.", type = "mining"},
    noDrillHand = {title = "MINING", message = "You don't have a hand drill.", type = "mining"},
    lightOn = {title = "HELMET", message = "Light turned on.", type = "success"},
    lightOff = {title = "HELMET", message = "Light turned off.", type = "info"},
    batteryRecharged = {title = "HELMET", message = "Battery recharged to 100%.", type = "success"},
    batteryEmpty = {title = "HELMET", message = "Battery is zero.", type = "error"},
    pickaxeBroke = {title = "MINING", message = "Your pickaxe broke!", type = "mining"},
    drillBroke = {title = "MINING", message = "Your drill broke!", type = "mining"},
    drillHandBroke = {title = "MINING", message = "Your hand drill broke!", type = "mining"},
    generatorActivated = {title = "GENERATOR", message = "The light generator has been activated.", type = "success"},
    generatorTip = {title = "TIP", message = "Some lights are not working, wear a helmet with a flashlight.", type = "info"},
    generatorCooldown = {title = "GENERATOR", message = "The generator is on cooldown. Please wait.", type = "error"},
    toolPurchased = {title = "Tool Purchased", message = "You have successfully purchased a %s for $%d.", type = "success"},
    notEnoughMoney = {title = "Not Enough Money", message = "You do not have enough money to purchase this item.", type = "error"},
    noStone = {title = "MINING", message = "You don't have any stones.", type = "error"},
    stonePlaced = {title = "MINING", message = "You placed %d stones.", type = "mining"},
    oreSold = {title = "SELLING", message = "You sold %d %s for $%d.", type = "mining"},
    noOre = {title = "SELLING", message = "You don't have any %s to sell.", type = "error"}
}
