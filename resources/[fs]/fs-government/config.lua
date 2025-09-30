Config = {}

Config.Framework = 'auto' -- 'esx', 'qbcore', 'qbox', 'auto'
Config.Inventory = 'auto' -- 'ox_inventory', 'qb-inventory', 'esx_inventory', 'auto'

Config.Debug = false

Config.Government = {
    jobs = {
        'police',
    },

    permissions = {
        [0] = {'basic_access'},
        [1] = {'basic_access', 'search_players'},
        [2] = {'basic_access', 'search_players', 'handcuff', 'armory_access'},
        [3] = {'basic_access', 'search_players', 'handcuff', 'armory_access', 'license_management'},
        [4] = {'all', 'basic_access', 'search_players', 'handcuff', 'armory_access', 'license_management', 'billing', 'garage_access'},
        [5] = {'basic_access', 'search_players', 'handcuff', 'armory_access', 'license_management', 'billing', 'garage_access', 'employee_management', 'announcements', 'surveillance'},
        [6] = {'basic_access', 'search_players', 'handcuff', 'armory_access', 'license_management', 'billing', 'garage_access', 'employee_management', 'announcements', 'surveillance', 'taxation', 'elections', 'defcon', 'subsidy_management', 'budget_management', 'business_audit', 'financial_reporting', 'seizure', 'warrant_issue'},
        [7] = {'all'}
    },

    -- Job rank mappings for professional display
    ranks = {
        police = {
            [0] = 'Recruit',
            [1] = 'Cadet',
            [2] = 'Officer',
            [3] = 'Senior Officer',
            [4] = 'Corporal',
            [5] = 'Sergeant',
            [6] = 'Lieutenant',
            [7] = 'Captain',
            [8] = 'Major',
            [9] = 'Colonel',
            [10] = 'Chief of Police'
        },
        ambulance = {
            [0] = 'Trainee',
            [1] = 'EMT',
            [2] = 'Paramedic',
            [3] = 'Senior Paramedic',
            [4] = 'Supervisor',
            [5] = 'Lieutenant',
            [6] = 'Captain',
            [7] = 'Chief Medical Officer'
        },
        mechanic = {
            [0] = 'Trainee',
            [1] = 'Mechanic',
            [2] = 'Senior Mechanic',
            [3] = 'Supervisor',
            [4] = 'Manager',
            [5] = 'Owner'
        }
    }
}

-- Available departments for budget management and allocations
Config.Departments = {
    police = 'Police Department',
    ambulance = 'Medical Services',
    fire = 'Fire Department',
    government = 'Government',
    public_works = 'Public Works',
    education = 'Education Department'
}

Config.Locations = {
    government = {
        coords = vector3(-541.7782, -596.2922, 35.6031),
        blip = {
            sprite = 419,
            color = 0,
            scale = 0.8,
            label = 'Government Building'
        }
    },
    
    armory = {
        coords = vector3(-543.6528, -591.5476, 35.6031),
        heading = 180.0
    },
    
    garage = {
        coords = vector3(-495.3517, -602.6877, 33.9006),
        heading = 268.3438,
        vehicles = {
            {model = 'police', label = 'Police Cruiser', price = 0},
            {model = 'police2', label = 'Police SUV', price = 0},
            {model = 'fbi', label = 'Government Sedan', price = 0}
        }
    },
    
    stash = {
        coords = vector3(-561.4659, -614.6958, 35.6030)
    },
    
    boss_actions = {
        coords = vector3(-541.6984, -596.2003, 35.6031)
    },
    
    surveillance = {
        coords = vector3(-524.0764, -614.7822, 35.6112),
        cameras = {
            {id = 1, label = 'City Hall Entrance', coords = vector3(-544.51, -204.88, 38.22)},
            {id = 2, label = 'Main Street', coords = vector3(-200.0, -300.0, 30.0)},
            {id = 3, label = 'Bank Area', coords = vector3(150.0, -1040.0, 29.0)},
            {id = 4, label = 'Hospital', coords = vector3(300.0, -580.0, 43.0)}
        }
    }
}

Config.Taxation = {
    enabled = true,
    rates = {
        salary = 0.15, -- 15% tax on salaries
        business = 0.12, -- 12% tax on business transactions
        vehicle = 0.08, -- 8% tax on vehicle purchases
        property = 0.10 -- 10% tax on property purchases
    },
    intervals = {
        salary = 600000, -- 10 minutes
        business = 3600000 -- 1 hour
    }
}

Config.Elections = {
    enabled = true,
    duration = 7 * 24 * 60 * 60 * 1000, -- 7 days in milliseconds
    candidate_requirements = {
        min_level = 5,
        min_playtime = 168, -- hours
        registration_fee = 10000
    },
    registration_locations = {
        {
            coords = vector3(-545.0820, -612.5640, 35.6438),
            heading = 180.0,
            label = 'Election Registration Desk',
            blip = {
                enabled = true,
                sprite = 408,
                color = 46,
                scale = 0.7,
                label = 'Election Registration'
            }
        }
    },
    voting_locations = {
        {
            coords = vector3(-510.3301, -621.4949, 35.6030),
            heading = 180.0,
            label = 'Voting Booth',
            blip = {
                enabled = true,
                sprite = 408,
                color = 2,
                scale = 0.7,
                label = 'Voting Booth'
            }
        }
    }
}

Config.DEFCON = {
    levels = {
        [1] = {
            label = 'DEFCON 1 - Maximum Readiness',
            color = {255, 0, 0},
            effects = {
                curfew = true,
                martial_law = true,
                lockdown = true
            }
        },
        [2] = {
            label = 'DEFCON 2 - High Alert',
            color = {255, 165, 0},
            effects = {
                curfew = true,
                martial_law = false,
                lockdown = false
            }
        },
        [3] = {
            label = 'DEFCON 3 - Elevated',
            color = {255, 255, 0},
            effects = {
                curfew = false,
                martial_law = false,
                lockdown = false
            }
        },
        [4] = {
            label = 'DEFCON 4 - Guarded',
            color = {0, 255, 0},
            effects = {
                curfew = false,
                martial_law = false,
                lockdown = false
            }
        },
        [5] = {
            label = 'DEFCON 5 - Normal',
            color = {0, 0, 255},
            effects = {
                curfew = false,
                martial_law = false,
                lockdown = false
            }
        }
    },
    current_level = 5
}

Config.Weapons = {
    {item = 'weapon_pistol', label = 'Pistol', price = 0},
    {item = 'weapon_stungun', label = 'Taser', price = 0},
    {item = 'weapon_nightstick', label = 'Nightstick', price = 0},
    {item = 'weapon_flashlight', label = 'Flashlight', price = 0}
}

Config.Items = {
    {item = 'handcuffs', label = 'Handcuffs', price = 0},
    {item = 'radio', label = 'Radio', price = 0},
    {item = 'armor', label = 'Body Armor', price = 0},
    {item = 'bandage', label = 'Bandage', price = 0}
}