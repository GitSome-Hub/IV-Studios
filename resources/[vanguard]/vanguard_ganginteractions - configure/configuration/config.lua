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
----                         VANGUARD LABS | GANG ACTIONS [ESX/QBCORE]
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
Config = {
    -- ===============================
    --    General Settings
    -- ===============================
    OpenKey = 74, -- Key 'H' to open the radial menu.
    MenuCommand = "gangmenu", -- Command to open the menu
    MenuActivationMode = "Both", -- Options: "UseKey" = Just key, "UseCommand" = Just command, "Both" = Key and Command.

    -- ===============================
    --    Player Visibility in Trunk
    -- ===============================
    PlayerVisibleInTrunk = false, -- Whether or not the player is visible when placed in the trunk (true = visible) (some vehicles maybe will bug the view.)

    -- ===============================
    --    Inventory Integration
    -- ===============================
    inventory = 'ox', -- You can use 'ox', 'qs', 'mf', 'cheeza', 

    -- ===============================
    --    Job Requirement
    -- ===============================
    JobRequirement = true, -- Enable/Disable job requirement (if set to true, only players with certain jobs can use the menu)
    AllowedJobs = {'police', 'mafia', 'yakuza', 'cartel'}, -- List of jobs allowed to access the gang actions menu (only these jobs can interact with the menu and actions)

    -- ===============================
    --    Systems Configuration
    -- ===============================
    Systems = {
        Robbery = true, -- Enable/Disable the robbery system (true = enabled)
        Cuff = true, -- Enable/Disable the handcuff system (true = enabled)
        Bag = true, -- Enable/Disable the bag system (true = enabled)
        CarTrunk = true, -- Enable/Disable the car trunk system (true = enabled)
        Carry = true, -- Enable/Disable the carry system (true = enabled)
        FlatTire = true, -- Enable/Disable the flat tire system (true = enabled)
        Hostage = true, -- Enable/Disable the hostage system (true = enabled)
    },

    -- ===============================
    --    Items Configuration
    -- ===============================
    Items = {
        Bag = {
            Item = 'paper_bag', -- Item required for the 'Bag' system (here, a 'paper_bag')
            Required = true, -- If the item is required to perform the action (false means it's not required)
        },
        Cuff = {
            Item = 'handcuffs', -- Item required for the 'Cuff' system (here, 'handcuffs')
            Required = true, -- If the item is required to perform the action (false means it's not required)
        },
        FlatTire = {
            Item = 'weapon_knife', -- Item required for the 'Flat Tire' system (here, a 'weapon_knife')
            Required = true, -- If the item is required to perform the action (false means it's not required)
        },
    },

    -- ===============================
    --    Hostage System Configuration
    -- ===============================
    Hostage = {
        AllowedWeapons = {
            `WEAPON_PISTOL`,
            `WEAPON_COMBATPISTOL`,
            -- Add other permitted weapons here if necessary
        },
    },

    -- ===============================
    --    Menu Options Configuration
    -- ===============================
    MenuOptions = {
        {
            id = 'rob',
            icon = 'icons/rob.png', -- Icon for the 'Robbery' option
            label = 'Robbery', -- Label displayed for the option
            description = 'Rob a player.', -- Description displayed when hovering over the option
            system = 'Robbery', -- The system this option refers to
            fastAction = { -- Fast action for this option
                enabled = true,
                command = "rob" -- Command to use for this action
            }
        },
        {
            id = 'cuff',
            icon = 'icons/handstied.png', -- Icon for the 'Handcuff' option
            label = 'Handcuff', -- Label displayed for the option
            description = 'Handcuff nearest player', -- Description for the option
            system = 'Cuff', -- The system this option refers to
            secondaryOptions = { -- Secondary options for cuffing (e.g., cuff or uncuff the player)
                {
                    id = 'cuffPlayer',
                    icon = 'icons/handstied.png',
                    label = 'Cuff',
                    description = 'Cuff the player',
                    fastAction = { -- Fast action for this option
                        enabled = true,
                        command = "cuff" -- Command to use for this action
                    }
                },
                {
                    id = 'uncuffPlayer',
                    icon = 'icons/handstied.png',
                    label = 'Uncuff',
                    description = 'Uncuff the player',
                    fastAction = { -- Fast action for this option
                        enabled = true,
                        command = "uncuff" -- Command to use for this action
                    }
                }
            }
        },
        {
            id = 'bag',
            icon = 'icons/bag.png', -- Icon for the 'Bag' option
            label = 'Bag', -- Label for the option
            description = 'Place bag on player head', -- Description of the action
            system = 'Bag', -- The system this option refers to
            secondaryOptions = { -- Secondary options for bagging (placing or removing a bag)
                {
                    id = 'placeBag',
                    icon = 'icons/bag.png',
                    label = 'Place Bag',
                    description = 'Place a bag on the player\'s head',
                    fastAction = { -- Fast action for this option
                        enabled = true,
                        command = "placebag" -- Command to use for this action
                    }
                },
                {
                    id = 'removeBag',
                    icon = 'icons/bag.png',
                    label = 'Remove Bag',
                    description = 'Remove the bag from the player\'s head',
                    fastAction = { -- Fast action for this option
                        enabled = true,
                        command = "removebag" -- Command to use for this action
                    }
                }
            }
        },
        {
            id = 'cartrunk',
            icon = 'icons/cartrunk.png', -- Icon for the 'Car Trunk' option
            label = 'Car Trunk', -- Label for the option
            description = 'Place a player in car trunk', -- Description of the action
            system = 'CarTrunk', -- The system this option refers to
            secondaryOptions = { -- Secondary options for handling the car trunk (placing/removing the player)
                {
                    id = 'putInTrunk',
                    icon = 'icons/cartrunk.png',
                    label = 'Put in Trunk',
                    description = 'Place the player in the trunk',
                    fastAction = { -- Fast action for this option
                        enabled = true,
                        command = "putintruck" -- Command to use for this action
                    }
                },
                {
                    id = 'removeFromTrunk',
                    icon = 'icons/cartrunk.png',
                    label = 'Remove from Trunk',
                    description = 'Remove the player from the trunk',
                    fastAction = { -- Fast action for this option
                        enabled = true,
                        command = "removefromtruck" -- Command to use for this action
                    }
                }
            }
        },
        {
            id = 'carry',
            icon = 'icons/carry.png', -- Icon for the 'Carry' option
            label = 'Carry', -- Label for the option
            description = 'Carry/Drop player', -- Description of the action
            system = 'Carry', -- The system this option refers to
            secondaryOptions = { -- Secondary options for carrying (carry or drop a player)
                {
                    id = 'carryPlayer',
                    icon = 'icons/carry.png',
                    label = 'Carry',
                    description = 'Carry the nearest player',
                    fastAction = { -- Fast action for this option
                        enabled = true,
                        command = "carry" -- Command to use for this action
                    }
                },
                {
                    id = 'dropPlayer',
                    icon = 'icons/carry.png',
                    label = 'Drop',
                    description = 'Drop the carried player',
                    fastAction = { -- Fast action for this option
                        enabled = true,
                        command = "drop" -- Command to use for this action
                    }
                }
            }
        },
        {
            id = 'flattire',
            icon = 'icons/flattire.png', -- Icon for the 'Flat Tire' option
            label = 'Flat Tire', -- Label for the option
            description = 'Tire puncture', -- Description of the action
            system = 'FlatTire', -- The system this option refers to
            fastAction = { -- Fast action for this option
                enabled = true,
                command = "flattire" -- Command to use for this action
            }
        },
        {
            id = 'makehostage',
            icon = 'icons/hostage.png', -- Icon for the 'Hostage' option
            label = 'Hostage', -- Label for the option
            description = 'Make a hostage', -- Description of the action
            system = 'Hostage', -- The system this option refers to
            fastAction = { -- Fast action for this option
                enabled = true,
                command = "makehostage" -- Command to use for this action
            }
        }
    },

    -- ===============================
    --    Notifications Configuration
    -- ===============================
    Notifications = { -- (Change notify system on bridge configuration)
        DeadPlayerTitle = "Gang System",
        DeadPlayerMessage = "Cannot rob a dead player",

        NoPlayerNearbyTitle = "Gang System",
        NoPlayerNearbyMessage = "No player nearby",

        NoVehicleNearbyTitle = "Gang System",
        NoVehicleNearbyMessage = "No vehicle nearby",

        NoAccessibleTrunkTitle = "Trunk",
        NoAccessibleTrunkMessage = "This vehicle does not have an accessible trunk",

        PlacedInTrunkTitle = "Trunk",
        PlacedInTrunkMessage = "You have been placed in the trunk",

        RemovedFromTrunkTitle = "Trunk",
        RemovedFromTrunkMessage = "You have been removed from the trunk",

        EmergencyTrunkReleaseTitle = "Trunk",
        EmergencyTrunkReleaseMessage = "Emergency trunk release activated!",

        BagPlacedTitle = "Bag",
        BagPlacedMessage = "You placed a bag on the player's head",

        BagPlacedTargetTitle = "Bag",
        BagPlacedTargetMessage = "Someone placed a bag on your head",

        BagRemovedTitle = "Bag",
        BagRemovedMessage = "You removed the bag from the player's head",

        BagRemovedTargetTitle = "Bag",
        BagRemovedTargetMessage = "Your bag has been removed",

        NoRequiredItemTitle = "Gang System",
        NoRequiredItemMessage = "You don't have the required item",

        CuffedTitle = "Handcuff",
        CuffedMessage = "You handcuffed the player",

        CuffedTargetTitle = "Handcuff",
        CuffedTargetMessage = "You've been handcuffed",

        UncuffedTitle = "Handcuff",
        UncuffedMessage = "You uncuffed the player",

        UncuffedTargetTitle = "Handcuff",
        UncuffedTargetMessage = "You've been uncuffed",

        InsideVehicleTitle = "Flat Tire",
        InsideVehicleMessage = "You cannot remove tires while inside a vehicle!",

        TireAlreadyRemovedTitle = "Flat Tire",
        TireAlreadyRemovedMessage = "This vehicle already has a tire removed!",

        NoTireFoundTitle = "Flat Tire",
        NoTireFoundMessage = "No tire found in this direction!",

        TireRemovedTitle = "Flat Tire",
        TireRemovedMessage = "Tire successfully removed!"
    }
}