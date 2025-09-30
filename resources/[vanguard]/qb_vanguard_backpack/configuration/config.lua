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
----                                 VAMNGUARD LABS | BACKPACK V2 QBCore
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
-- TO GET MLO, GO ON THIS LINK: https://mega.nz/file/0ed0iawZ#q4-cN1OVysf4AsNCVBrE608dahVpWUFCs-dj2WfyBTQ (If link dont work, contact support on discord.)
-- TO GET MLO, GO ON THIS LINK: https://mega.nz/file/0ed0iawZ#q4-cN1OVysf4AsNCVBrE608dahVpWUFCs-dj2WfyBTQ (If link dont work, contact support on discord.)
-- TO GET MLO, GO ON THIS LINK: https://mega.nz/file/0ed0iawZ#q4-cN1OVysf4AsNCVBrE608dahVpWUFCs-dj2WfyBTQ (If link dont work, contact support on discord.)

Config = {}

-- Shop Configuration
Config.EnableShop = false -- Set to false to disable the backpack shop
Config.EnableBlip = false -- Set to false to disable the shop blip
Config.EnablePed = false -- Set to false to disable the shop ped

-- Custom Backpack Props Configuration (Supports .ydr .ytyp, and others stream formats)
Config.EnableCustomProps = false -- Set to true to enable custom backpack props from customBackpacks folder
Config.CustomPropsFolder = 'customBackpacks' -- Folder name where custom backpack props are stored
Config.ValidPropPrefixes = { -- Prefixes that identify valid backpack props  
    'bp_',  -- Example: bp_tactical_bag
    'bag_', -- Example: bag_military
    'backpack_' -- Example: backpack_hiking
}

-- Default backpack prop (used if no specific prop is set for a backpack level)
Config.DefaultBackpackProp = 'p_michael_backpack_s' -- Backpack examples models:  p_ld_heist_bag_s / p_michael_backpack_s , you can find more in gta 5 prop wiki.

-- Backpack Configuration (Three different levels)
Config.Backpacks = {
    {
        name = 'backpack_level_1',
        label = 'Backpack [Nv.I]',
        slots = 16,
        weight = 10000,
        export = 'qb_vanguard_backpack.openBackpack1',
        pin = true,
        price = 10,
        prop = 'p_michael_backpack_s' -- Specific prop for level 1 backpack
    },
    {
        name = 'backpack_level_2',
        label = 'Backpack [Nv.II]',
        slots = 24,
        weight = 15000,
        export = 'qb_vanguard_backpack.openBackpack2',
        pin = true,
        price = 20,
        prop = 'p_ld_heist_bag_s' -- Specific prop for level 2 backpack
    },
    {
        name = 'backpack_level_3',
        label = 'Backpack [Nv.III]',
        slots = 32,
        weight = 20000,
        export = 'qb_vanguard_backpack.openBackpack3',
        pin = true,
        price = 30,
        prop = 'p_michael_backpack_s' -- Specific prop for level 3 backpack
    }
}

-- PIN configuration options
Config.UsePINSystem = false -- Global switch to enable or disable PIN system for all backpacks

-- Ox_lib integration for PIN entry
Config.OxLibUseFormForPin = false -- Use ox_lib form to enter PIN when PIN protection is enabled

-- Ped configuration 
Config.PedConfig = {
    model = 'u_m_m_streetart_01',
    position = vector3(399.8024, 96.92446, 100.48),
    heading = 67.46,
    invincible = true,
    frozen = true,
    canRagdoll = false,
}

-- Shop Blip coords
Config.BlipLocation = vector3(397.8310, 95.88112, 101.48)

Config.Blip = {
    Sprite = 850,
    Color = 18,
    Scale = 0.8,
    Name = "Backpack Shop",
    Display = 4,
    ShortRange = true
}

