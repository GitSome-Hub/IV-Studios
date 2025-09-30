----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----
----
----             __     __                              _   _          _         
----             \ \   / /_ _ _ __   __ _  __ _ _ __ __| | | |    __ _| |__  ___ 
----              \ \ / / _` | '_ \ / _` |/ _` | '__/ _` | | |   / _` | '_ \/ __|
----               \ V / (_| | | | | (_| | (_| | | | (_| | | |__| (_| | |_) \__ \
----                \_/ \__,_|_| |_|\__, |\__,_|_|  \__,_| |_____\__,_|_.__/|___/
----                                |___/                                        
---- 
----                                 VANGUARD LABS | WALLET [QBCORE]
----
----               Thank you for purchasing our script; we greatly appreciate your preference.
----        If you have any questions or any modifications in mind, please contact us via Discord.
----
----                           Support and More: https://discord.gg/G5r3Qq2j4v
----
----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----
----
Config = {}

-- ===========================================
--        INVENTORY RESTRICTIONS
-- ===========================================
Config.BlockWalletsInWallets = true  -- Prevents wallets from being stored inside other wallets
Config.OneWalletOnly = true          -- Restricts players to carrying only one wallet at a time

-- ===========================================
--        WALLET TYPES CONFIGURATION
-- ===========================================
Config.Wallets = {
    {
        name = 'wallet_basic',       -- Unique item name
        label = 'Basic Wallet',      -- Display name
        slots = 8,                   -- Inventory slots
        weight = 1000,               -- Carry weight (grams)
        export = 'qb_vanguard_wallet.openWalletBasic',  -- Export function
        price = 100                  -- Shop price
    },
    {
        name = 'wallet_premium',
        label = 'Premium Wallet',
        slots = 12,
        weight = 1500,
        export = 'qb_vanguard_wallet.openWalletPremium',
        price = 250
    }
}

-- ===========================================
--        NPC ROBBERY CONFIGURATION
-- ===========================================
Config.EnableNPCRobbery = true  -- Enable/disable NPC robbery feature

Config.Robbery = {
    RequireItems = true,  -- Whether weapons are required to rob
    RequiredItems = {
        weapons = {       -- List of weapon hashes that can be used for robbery
            'WEAPON_PISTOL',
            'WEAPON_KNIFE'
        }
    },
    RobberyDuration = 5,  -- Progress circle duration in seconds
    
    -- Reward system configuration
    Rewards = {
        Money = {
            Enabled = true,
            Type = 'random',  -- 'random' or 'fixed'
            Fixed = {
                Amount = 100  -- Used if Type = 'fixed'
            },
            Random = {
                MinAmount = 50,   -- Minimum cash reward
                MaxAmount = 1000, -- Maximum cash reward
                Chance = 75       -- Percentage chance to receive money
            }
        },
        Items = {
            Enabled = true,
            List = {
                {
                    item = 'idcard',  -- Reward item
                    chance = 100,            -- Drop chance percentage
                    min = 1,                -- Minimum quantity
                    max = 1                 -- Maximum quantity
                },
                {
                    item = 'american_express',  -- Reward item
                    chance = 100,            -- Drop chance percentage
                    min = 1,                -- Minimum quantity
                    max = 1                 -- Maximum quantity
                }
            }
        }
    },
    
    -- Police alert system
    PoliceAlert = {
        Enable = true,             -- Enable police notifications
        AlwaysNotify = false,      -- Bypass chance check if true
        NotifyChance = 75,         -- Percentage chance to alert police
        Jobs = {'police', 'sheriff'},  -- Jobs that receive alerts
        BlipDuration = 60,         -- Blip display time (seconds)
        BlipSprite = 161,          -- Blip icon ID
        BlipColor = 1,             -- Blip color ID
        BlipScale = 1.0,           -- Blip size
        BlipText = "Robbery in Progress"  -- Blip label
    },
    
    Cooldown = 60,  -- Cooldown between robberies (seconds)
    
    -- System messages
    Messages = {
        NoRequiredItems = "You need a weapon to rob NPCs!",
        RobberySuccess = "Robbery successful!",
        RobberyInProgress = "You're already robbing someone!",
        CooldownActive = "You need to wait before robbing again!",
        PoliceNotification = "Robbery reported at %s",
        WalletLimit = "You can only carry one wallet!",
        WalletInWallet = "You cannot put wallets inside other wallets!"
    }
}

-- ===========================================
--        SHOP CONFIGURATION
-- ===========================================
Config.EnableShop = false  -- Enable/disable wallet shop
Config.ShopLocation = vector3(413.53, -985.04, 29.43)  -- Shop coordinates (x,y,z)

-- ===========================================
--        BLIP CONFIGURATION
-- ===========================================
Config.EnableBlip = false -- Enable/disable map blip

Config.Blip = {
    Sprite = 108,       -- Blip sprite ID (108 = wallet icon)
    Color = 2,          -- Blip color ID (2 = red)
    Scale = 0.8,        -- Blip size multiplier
    Name = "Wallet Shop",  -- Blip label
    Display = 4,        -- Blip display mode
    ShortRange = true   -- Only visible when nearby
}

-- ===========================================
--        SHOP NPC CONFIGURATION
-- ===========================================
Config.EnableNPC = false  -- Enable/disable shop NPC

Config.NPC = {
    model = 'a_m_y_business_02',  -- Ped model name
    position = vector3(413.53, -985.04, 29.43),  -- Spawn coordinates
    heading = 67.46,     -- Facing direction (degrees)
    invincible = true,   -- Cannot be damaged
    frozen = true,       -- Cannot move
    canRagdoll = false   -- Cannot fall over
}