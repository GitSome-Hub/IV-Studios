local seconds, minutes = 1000, 60000

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
----                                 VAMNGUARD LABS | POLICE JOB [QBCore]
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

Config = {}

Config.Framework = 'Legacy' -- Use 'Legacy' for most recent QB Framework Versions.

Config.AcceptedWeapons = {
    `WEAPON_COMBATPISTOL`,
    `WEAPON_STUNGUN`
}

Config.CustomBones = {
    -- `SPAWN_CODE` = 'Custom Bone'
}

--------------------------------------------------------------------------------------------------------
-------------------------- DUTY CONFIG  ----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

Config.Jobs = { -- Config Duty Jobs!
    Police = {
        ClockedInJob = "police",
        ClockedOutJob = "offpolice",
        Locations = {
            vec3(448.1580, -973.271, 30.689)
        },
        Webhook = 'https://discord.com/api/webhooks/1292592091595280478/U-dJl28AXJ5jiglhAp9DSCzNsxVWyjIj3nzctvXrlsYkwS70_I9Z6RV8H9kliT1xbsIo',
        Avatar = 'https://i.imgur.com/BuKIMkc.png'
    },

    -- Ambulance = {
    --     ClockedInJob = "ambulance",
    --     ClockedOutJob = "offambulance",
    --     Locations = {
    --         vec3(1139.25, -1544.98, 35.38)
    --     },
    --     Webhook = 'WEBHOOK HERE',
    --     Avatar = 'URL_AVATAR_HERE'
    -- },
    
}

--------------------------------------------------------------------------------------------------------
-------------------------- POLICE OPTIONS  -------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

-- Job Menu
Config.jobMenu = 'F6' -- Key to open the job menu

-- Car Lock System
Config.customCarlock = false -- Enable if using custom car lock system (set up in client/cl_customize.lua)

-- Billing System
Config.billingSystem = true  -- Options: true / false (Customize in client/cl_customize.lua)

-- Skin Script
Config.skinScript = true     -- Set to true if using qb-clothing

-- Jail Option
Config.customJail = true     -- Add jail option to menu (requires event modification in client/cl_customize.lua)

-- Inventory System
Config.inventory = 'qb'      -- Options: 'ox' / 'qb' / 'qs' / 'custom'
Config.searchPlayers = true  -- Allow police to search players (ensure correct inventory system is selected)

-- Weapons as Items
Config.weaponsAsItems = true -- Set to true if using weapons as items in your QBCore setup

-- QB Identity & License
Config.esxIdentity = false   -- Set to false since we're using QBCore's built-in identity system
Config.esxLicense = true     -- Set to true if using QBCore license system

-- Spike Strips
Config.spikeStripsEnabled = true -- Enable spike strips functionality

-- Tackle
Config.tackle = {
    enabled = true, -- Enable tackle?
    policeOnly = true, -- Police jobs only use tackle?
    hotkey = 'G' -- What key to press while sprinting to start tackle of target
}

Config.handcuff = { -- Config for handcuffing
    timer = 20 * 60000, -- Time before player is automatically unrestrained (20 minutes) (Set to false if not desired)
    hotkey = 'J', -- What key to press to handcuff people (Set to false for no hotkey)
    skilledEscape = {
        enabled = false, -- Allow criminal to simulate resisting by giving them a chance to break free from cuffs via skill check
        difficulty = {'easy', 'easy', 'easy'} -- Options: 'easy' / 'medium' / 'hard' (Can be stringed along as they are in config)
    }
}

Config.policeJobs = { -- Police jobs
    'police'
    --'sheriff'
}


--------------------------------------------------------------------------------------------------------
-------------------------- PED CONFIG  -----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------


Config['VanguardPeds'] = {

    ['VanguardPed'] = { 
        ['name'] = 's_m_y_cop_01', -- ped name
        ['heading'] = 181.59, -- ped heading
        ['coords'] = vector3(441.0968, -978.928, 29.689), -- ped coords
        ['pedName'] = "Sargent Jhon",
        ['reportText'] = "Press ~g~[E]~w~ to report",
    },
    ['discord'] = {
        ['webhookUrl'] = "https://discord.com/api/webhooks/1292592091595280478/U-dJl28AXJ5jiglhAp9DSCzNsxVWyjIj3nzctvXrlsYkwS70_I9Z6RV8H9kliT1xbsIo", -- webhook discord
        ['roleId'] = "1292591992437473402", -- ID Mention Group
    }
}

--------------------------------------------------------------------------------------------------------
-------------------------- PROPS CONFIG  ---------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

Config.Props = { -- What props are available in the "Place Objects" section of the job menu

    {
        title = 'Barrier', -- Label
        description = '', -- Description (optional)
        model = `prop_barrier_work05`, -- Prop name within `
        groups = { -- ['job_name'] = min_rank
            ['police'] = 0,
            ['sheriff'] = 0,
        }
    },
    {
        title = 'Barricade',
        description = '',
        model = `prop_mp_barrier_01`,
        groups = {
            ['police'] = 0,
            ['sheriff'] = 0,
        }
    },
    {
        title = 'Traffic Cones',
        description = '',
        model = `prop_roadcone02a`,
        groups = {
            ['police'] = 0,
            ['sheriff'] = 0,
        }
    },
    {
        title = 'Spike Strip',
        description = '',
        model = `p_ld_stinger_s`,
        groups = {
            ['police'] = 0,
            ['sheriff'] = 0,
        }
    },

}

--------------------------------------------------------------------------------------------------------
-------------------------- BLIPS AND MENUS CONFIG  -----------------------------------------------------
--------------------------------------------------------------------------------------------------------


Config.Locations = {
    LSPD = {
        blip = {
            enabled = true,
            coords = vec3(464.57, -992.0, 30.69),
            sprite = 60,
            color = 29,
            scale = 1.0,
            string = 'Mission Row PD'
        },

        bossMenu = {
            enabled = true, -- Enable boss menu?
            jobLock = 'police', -- Lock to specific police job? Set to false if not desired
            coords = vec3(437.1053, -994.464, 30.689), -- Location of boss menu (If not using target)
            label = '[E] - Access Boss Menu', -- Text UI label string (If not using target)
            distance = 3.0, -- Distance to allow access/prompt with text UI (If not using target)
            target = {
                enabled = false, -- If enabled, the location and distance above will be obsolete
                label = 'Access Boss Menu',
                coords = vec3(437.1053, -994.464, 30.689),
                heading = 269.85,
                width = 2.0,
                length = 1.0,
                minZ = 30.73-0.9,
                maxZ = 30.73+0.9
            }
        },

        armoury = {
            enabled = true, -- Set to false if you don't want to use
            coords = vec3(454.0439, -980.055, 29.689), -- Coords of armoury
            heading = 86.95, -- Heading of armoury NPC
            ped = 's_f_y_cop_01',
            label = '[E] - Access Armoury', -- String of text ui
            jobLock = 'police', -- Allow only one of Config.policeJob listings / Set to false if allow all Config.policeJobs
            weapons = {
                [0] = { -- Grade number will be the name of each table(this would be grade 0)
                ['WEAPON_COMBATPISTOL'] = { label = 'Combat Pistol', multiple = false, price = 0 },
                ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 0 },
                ['WEAPON_STUNGUN'] = { label = 'Taser', multiple = false, price = 0 }, 
                ['ammo-9'] = { label = '9mm Ammo', multiple = true, price = 0 }, 
                ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 0 }, 

                },
                [1] = { -- This would be grade 1
                    ['WEAPON_COMBATPISTOL'] = { label = 'Combat Pistol', multiple = false, price = 0 },
                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 0 },
                    ['WEAPON_STUNGUN'] = { label = 'Taser', multiple = false, price = 0 }, 
                    ['ammo-9'] = { label = '9mm Ammo', multiple = true, price = 0 }, 
                    ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 0 }, 
                },
                [2] = { -- This would be grade 2
                    ['WEAPON_COMBATPISTOL'] = { label = 'Combat Pistol', multiple = false, price = 0 },
                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 0 },
                    ['WEAPON_STUNGUN'] = { label = 'Taser', multiple = false, price = 0 }, 
                    ['ammo-9'] = { label = '9mm Ammo', multiple = true, price = 0 }, 
                    ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 0 }, 
                },
                [3] = { -- This would be grade 3
                    ['WEAPON_COMBATPISTOL'] = { label = 'Combat Pistol', multiple = false, price = 0 },
                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 0 },
                    ['WEAPON_STUNGUN'] = { label = 'Taser', multiple = false, price = 0 }, 
                    ['ammo-9'] = { label = '9mm Ammo', multiple = true, price = 0 }, 
                    ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 0 }, 
                },
            }
        },

        cloakroom = {
            enabled = true, -- Set to false if you don't want to use
            jobLock = 'police', -- Allow only one of Config.policeJob listings / Set to false if allow all Config.policeJobs
            coords = vec3(452.2905, -992.885, 30.689), -- Coords of cloakroom
            label = '[E] - Cloak Room', -- String of text ui of cloakroom
            range = 2.0, -- Range away from coords you can use.
            uniforms = { -- Uniform choices

                [1] = {
                    label = 'Patrol',
                    male = {
                        ['tshirt_1'] = 58,  ['tshirt_2'] = 0,
                        ['torso_1'] = 55,   ['torso_2'] = 0,
                        ['arms'] = 30,
                        ['pants_1'] = 24,   ['pants_2'] = 0,
                        ['shoes_1'] = 10,   ['shoes_2'] = 0,
                        ['helmet_1'] = 3,  ['helmet_2'] = 0,
                        ['bproof_1'] = 1,   ['bproof_2'] = 2,
                    },
                    female = {
                        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
                        ['torso_1'] = 4,   ['torso_2'] = 14,
                        ['arms'] = 4,
                        ['pants_1'] = 25,   ['pants_2'] = 1,
                        ['shoes_1'] = 16,   ['shoes_2'] = 4,
                        ['bproof_1'] = 1,   ['bproof_2'] = 2, 
                    }
                },

                -- [2] = {
                --     label = 'Chief',
                --     male = {
                --         ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
                --         ['torso_1'] = 5,   ['torso_2'] = 2,
                --         ['arms'] = 5,
                --         ['pants_1'] = 6,   ['pants_2'] = 1,
                --         ['shoes_1'] = 16,   ['shoes_2'] = 7,
                --         ['helmet_1'] = 44,  ['helmet_2'] = 7,
                --     },
                --     female = {
                --         ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
                --         ['torso_1'] = 4,   ['torso_2'] = 14,
                --         ['arms'] = 4,
                --         ['pants_1'] = 25,   ['pants_2'] = 1,
                --         ['shoes_1'] = 16,   ['shoes_2'] = 4,
                --     }
                -- },
                
            }

        },

--------------------------------------------------------------------------------------------------------
-------------------------- GARAGE CONFIG  --------------------------------------------------------------
--------------------------------------------------------------------------------------------------------


        vehicles = { -- Vehicle Garage
            enabled = true, -- Enable? False if you have you're own way for medics to obtain vehicles.
            jobLock = 'police', -- Job lock? or access to all police jobs by using false
            zone = {
                coords = vec3(463.69, -1019.72, 28.1), -- Area to prompt vehicle garage
                range = 5.5, -- Range it will prompt from coords above
                label = '[E] - Access Garage',
                return_label = '[E] - Return Vehicle'
            },
            spawn = {
                land = {
                    coords = vec3(449.37, -1025.46, 28.59), -- Coords of where land vehicle spawn/return
                    heading = 3.68
                },
                air = {
                    coords = vec3(449.29, -981.76, 43.69), -- Coords of where air vehicles spawn/return
                    heading =  0.01
                }
            },
            options = {

                [0] = { -- Job grade as table name
                    ['police'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['police2'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser #2',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['polmav'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Maverick',
                        category = 'air', -- Options are 'land' and 'air'
                    },
                },

                [1] = { -- Job grade as table name
                    ['police'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['police2'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser #2',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['polmav'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Maverick',
                        category = 'air', -- Options are 'land' and 'air'
                    },
                },

                [2] = { -- Job grade as table name
                    ['police'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['police2'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser #2',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['polmav'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Maverick',
                        category = 'air', -- Options are 'land' and 'air'
                    },
                },

                [3] = { -- Job grade as table name
                    ['police'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['police2'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser #2',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['polmav'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Maverick',
                        category = 'air', -- Options are 'land' and 'air'
                    },
                },

            }
        }

    },

}
