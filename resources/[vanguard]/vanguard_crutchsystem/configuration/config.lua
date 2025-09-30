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
----                      VANGUARD LABS | CRUTCH SYSTEM [ESX/QB/QBOX]
----
----               Thank you for purchasing our script; we greatly appreciate your preference.
----        If you have any questions or any modifications in mind, please contact us via Discord.
----
----                           Support and More: https://discord.gg/rq5yVBACTf
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
--    Item Names Configuration  | This items will appear on shop, do not change wheelchair or crutch if not using shop.
-- ===============================
Config.Items = {
    Wheelchair = {
        name = "wheelchair",  -- Item name in inventory
        label = "Wheelchair", -- Display name
        price = 5000         -- Price in shop
    },
    Crutch = {
        name = "crutch",     -- Item name in inventory
        label = "Crutch",    -- Display name
        price = 2500         -- Price in shop
    }
    -- -- Add new items here
    -- Bandage = {
    --     name = "bandage",
    --     label = "Bandage",
    --     price = 100
    -- }
}

-- ===============================
--    Shop Configuration
-- ===============================
Config.Shop = {
    Enabled = true, -- Set to false to disable the shop system, Recommend ox_inventory for this shop system.
    Location =  vector3(311.43, -594.06, 43.28),
    NPC = {
        model = "s_m_m_doctor_01",
        heading = 339.49,
        scenario = "WORLD_HUMAN_CLIPBOARD"
    },
    Groups = {
        ['ambulance'] = 0,  -- Job name and minimum grade required
        ['doctor'] = 1
    }
}

-- ===============================
--    Command Configuration
-- ===============================
Config.Commands = {
    RemoveMedical = {
        Enabled = true,           -- Set to false to disable the command
        Command = "removecrutch", -- Command name
        Jobs = {                  -- Jobs that can use the command
            ['ambulance'] = 0,    -- Job name and minimum grade required
            ['doctor'] = 1
        }
    }
}

-- ===============================
--    Time Configuration
-- ===============================
Config.Time = {
    Wheelchair = {
        min = 1,    -- Minimum time in minutes
        max = 60    -- Maximum time in minutes
    },
    Crutch = {
        min = 1,    -- Minimum time in minutes
        max = 60    -- Maximum time in minutes
    }
}

-- ===============================
--    Movement Configuration
-- ===============================
Config.Movement = {
    Wheelchair = {
        AllowExit = false,
        AllowJumping = false,
        AllowSprinting = false,
        AllowRagdoll = false,
        AllowCombat = false
    },
    Crutch = {
        AllowJumping = false,
        AllowSprinting = false,
        AllowRagdoll = false,
        AllowCombat = false,
        MovementSpeed = 0.6
    }
}

-- ===============================
--    Other Configuration
-- ===============================
Config.MaxDistance = 3.0  -- Maximum distance for player interaction
Config.AllowedJobs = {'ambulance', 'doctor'}
Config.DisableWeapons = true -- Disable weapons while using wheelchair/crutch

-- ===============================
--    Notifications Configuration
-- ===============================
Config.Notifications = {
    NoAccess = {
        title = "ACCESS DENIED",
        message = "You don't have access to this shop",
        type = "error"
    },
    NoPermission = {
        title = "NO PERMISSION",
        message = "You don't have permission to do this",
        type = "error"
    },
    NoItem = {
        title = "ITEM NOT FOUND",
        message = "You don't have this item",
        type = "error"
    },
    InvalidTime = {
        title = "INVALID TIME",
        message = "Invalid time format",
        type = "error"
    },
    TimeRange = {
        title = "INVALID TIME",
        message = "Time must be between %d and %d minutes",
        type = "error"
    },
    GaveWheelchair = {
        title = "WHEELCHAIR",
        message = "You gave a wheelchair to %s for %d minutes",
        type = "success"
    },
    ReceivedWheelchair = {
        title = "WHEELCHAIR",
        message = "You received a wheelchair for %d minutes",
        type = "inform"
    },
    GaveCrutch = {
        title = "CRUTCH",
        message = "You gave a crutch to %s for %d minutes",
        type = "success"
    },
    ReceivedCrutch = {
        title = "CRUTCH",
        message = "You received a crutch for %d minutes",
        type = "inform"
    },
    WheelchairRecovery = {
        title = "RECOVERY COMPLETE",
        message = "You no longer need the wheelchair",
        type = "success"
    },
    CrutchRecovery = {
        title = "RECOVERY COMPLETE",
        message = "You no longer need the crutch",
        type = "success"
    },
    MovementRestricted = {
        title = "MOVEMENT RESTRICTED",
        messages = {
            jump = "You can't jump right now",
            sprint = "You can't sprint right now",
            exit = "You can't exit the wheelchair",
            fight = "You can't fight right now"
        },
        type = "error"
    },
    WeaponBlocked = {
        title = "ACTION BLOCKED",
        message = "You can't use weapons right now",
        type = "error"
    },
    InvalidTarget = {
        title = "INVALID TARGET",
        message = "Please specify a target player ID",
        type = "error"
    },
    PlayerNotFound = {
        title = "INVALID TARGET",
        message = "Player not found",
        type = "error"
    },
    RemovedEquipment = {
        title = "MEDICAL EQUIPMENT",
        message = "Removed medical equipment from %s",
        type = "success"
    },
    EquipmentRemoved = {
        title = "MEDICAL EQUIPMENT",
        message = "Your medical equipment has been removed by medical staff",
        type = "inform"
    }
}

-- ===============================
--    UI Configuration
-- ===============================
Config.UI = {
    Shop = {
        name = "Medical Equipment Shop",
        prompt = "[E] Open Medical Shop"
    },
    Menu = {
        title = "Select Player",
        selfOption = "Self",
        timeLabel = "Enter time (minutes)",
        timeHelp = "Enter time in minutes (e.g., 30)"
    },
    Timer = {
        wheelchair = "Wheelchair needed for: %s",
        crutch = "Crutch needed for: %s"
    }
}

-- ===============================
--    Utility Functions
-- ===============================
Config.Utils = {
    formatTimeRemaining = function(ms)
        local seconds = math.floor(ms / 1000)
        local minutes = math.floor(seconds / 60)
        seconds = seconds % 60
        return string.format("%02d:%02d", minutes, seconds)
    end
}