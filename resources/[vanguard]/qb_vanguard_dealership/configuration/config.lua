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
----                                 VANGUARD LABS | DEALERSHIP [ESX]
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

-- ===============================
--    Currency Configuration
-- ===============================
Config.Currency = {
    symbol = '$', -- exemple: $, €, £, ¥
    position = 'before',
    thousandSeparator = ',',
    decimalSeparator = '.',
    decimals = 0
}

-- ===============================
--    UI Text Configuration
-- ===============================
Config.UI = {
    -- ===============================
    --    Button Texts
    -- ===============================
    buttons = {
        testDrive = "Test Drive",
        purchase = "Purchase",
        selectColor = "Select a Color",
        close = "Close",
        details = "Details"
    },
    
    -- ===============================
    --    Labels and Titles
    -- ===============================
    labels = {
        welcomeText = "Welcome,", 
        searchPlaceholder = "Search vehicles1...",
        allVehicles = "All Vehicles",
        availableColors = "Available Colors",
        vehicleCustomization = "Vehicle Customization",
        testDriveDuration = "TEST DRIVE DURATION",
        pressToOpen = "Press E to open"
    },
    
    -- ===============================
    --    Filter Options
    -- ===============================
    filters = {
        allCategories = "All Categories",
        sortByPrice = "Sort by Price",
        priceLowToHigh = "Price: Low to High",
        priceHighToLow = "Price: High to Low"
    },
    
    -- ===============================
    --    Vehicle Specs Labels
    -- ===============================
    specs = {
        power = "Power",
        topSpeed = "Top Speed",
        acceleration = "0-60 mph"
    },
    
    -- ===============================
    --    Notifications
    -- ===============================
    notifications = {
        purchaseSuccess = "Vehicle purchased successfully!",
        purchaseFailed = "Not enough money to purchase this vehicle!",
        selectColor = "Please select a color first!",
        selectVehicle = "Please select a vehicle first!",
        testDriveStarted = "Test drive started",
        testDriveEnded = "Test drive ended"
    }
}

-- ===============================
--    Interaction Settings
-- ===============================
Config.UseOxLib = true -- Set to false to use DrawText3D
Config.InteractionKey = 38 -- E key
Config.DrawDistance = 10.0
Config.InteractionDistance = 3.0

-- ===============================
--    Test Drive Configuration
-- ===============================
Config.TestDrive = {
    defaultDuration = 60, -- Default duration in seconds if not specified in dealership config
    preventVehicleExit = true, -- Prevent player from exiting vehicle during test drive
    hideOtherPlayers = true, -- Hide other players during test drive
    countdown = {
        position = 'right', -- Position of the countdown timer (left, right, center)
        offsetX = -20, -- X offset from the position
        offsetY = 20   -- Y offset from the top
    }
}

-- ===============================
--    Dealership Locations
--    ADD tags, below category, like this: tag = 'POPULAR', (Types: POPULAR, VIP, NEW, CUSTOM)

-- For vehicle images, you can use https://www.imghippo.com/ 
-- example image link: https://i.imghippo.com/files/JAFM8207su.png

-- ===============================
Config.Dealerships = {
    -- ===============================
    --    PDM Dealership 1
    -- ===============================
    {
        name = "PDM Dealership",
        location = vector4(-56.65, -1098.66, 26.42, 16.28),
        spawnLocation = vector4(-30.57, -1081.04, 26.64, 64.56),
        testDrive = {
            duration = 30, -- Duration in seconds (overrides default)
            location = vector4(-2004.32, 2856.23, 32.87, 56.57), -- Test drive spawn location
            returnLocation = vector4(-56.64, -1096.97, 26.42, 202.63) -- Where to teleport after test drive
        },
        npcModel = "a_m_y_business_03",
        categories = {"Luxury", "Super", "Sports", "SUV", "VIP"},
        blip = {
            sprite = 225,
            color = 4,
            scale = 0.8,
            display = 4,
            shortRange = true,
            label = "PDM Dealership"
        },
        vehicles = {
            {
                name = 'Adder',
                model = 'adder',
                category = 'Sports',
                price = 15000,
                image = 'https://i.imghippo.com/files/ky1599dA.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '1,020 hp',
                    topSpeed = '200 mph',
                    acceleration = '1.99s'
                }
            },
            {
                name = 'Baller 6',
                model = 'baller6',
                category = 'SUV',
                tag = 'NEW',
                price = 24000,
                image = 'https://i.imghippo.com/files/bUK2944bVo.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '1,020 hp',
                    topSpeed = '200 mph',
                    acceleration = '1.99s'
                }
            },
            {
                name = 'Furia',
                model = 'furia',
                category = 'Sports',
                price = 113000,
                image = 'https://i.imghippo.com/files/Seq4649gJM.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '1,020 hp',
                    topSpeed = '200 mph',
                    acceleration = '1.99s'
                }
            },
            {
                name = 'Itali RSX',
                model = 'italirsx',
                category = 'Luxury',
                tag = 'POPULAR',
                price = 349000,
                image = 'https://i.imghippo.com/files/MQJj2764BkY.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '1,020 hp',
                    topSpeed = '200 mph',
                    acceleration = '1.99s'
                }
            },
            {
                name = 'Massacro',
                model = 'massacro',
                category = 'Super',
                price = 179000,
                image = 'https://i.imghippo.com/files/oL4305ZhA.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '1,020 hp',
                    topSpeed = '200 mph',
                    acceleration = '1.99s'
                }
            },
            {
                name = 'NineF',
                model = 'ninef',
                category = 'Super',
                price = 149000,
                image = 'https://i.imghippo.com/files/aKSt9849JMw.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '1,020 hp',
                    topSpeed = '200 mph',
                    acceleration = '1.99s'
                }
            },
            {
                name = 'Visione',
                model = 'visione',
                category = 'VIP',
                tag = 'VIP',
                price = 1220000,
                image = 'https://i.imghippo.com/files/nIiD8945C.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '986 hp',
                    topSpeed = '211 mph',
                    acceleration = '2.5s'
                }
            },
            {
                name = 'Turismo R',
                model = 'turismor',
                category = 'VIP',
                tag = 'VIP',
                price = 450000,
                image = 'https://i.imghippo.com/files/qrsA6877UE.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '986 hp',
                    topSpeed = '211 mph',
                    acceleration = '2.5s'
                }
            },
            {
                name = 'THRax',
                model = 'thrax',
                category = 'VIP',
                tag = 'VIP',
                price = 10000000,
                image = 'https://i.imghippo.com/files/pbY9130ijs.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Sunset Orange', hex = '#FF6B00' },
                    { name = 'Forest Green', hex = '#228B22' },
                    { name = 'Royal Purple', hex = '#4B0082' },
                    { name = 'Midnight Blue', hex = '#191970' },
                    { name = 'Silver', hex = '#C0C0C0' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '986 hp',
                    topSpeed = '211 mph',
                    acceleration = '2.5s'
                }
            }
        }
    },
    
    -- ===============================
    --    Luxury Air DEALERSHIP 2
    -- ===============================
    {
        name = "Luxury Air",
        location =  vector4(-1026.56, -3017.06, 13.95, 354.49),
        spawnLocation = vector4(-1112.68, -2883.78, 13.95, 146.34),
        testDrive = {
            duration = 30,
            location = vector4(-1464.44, -3069.56, 13.98, 237.95),
            returnLocation = vector4(-1027.50, -3014.60, 13.95, 190.38) 
        },
        npcModel = "s_m_y_pilot_01",
        categories = {"Helicopter", "VIPHelicopter"},
        blip = {
            sprite = 64,
            color = 3,
            scale = 0.8,
            display = 4,
            shortRange = true,
            label = "Luxury Air"
        },
        vehicles = {
            {
                name = 'Swift Deluxe',
                model = 'swift2',
                category = 'Helicopter',
                price = 5500000,
                image = 'https://i.imghippo.com/files/xGt2088quE.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '850 hp',
                    topSpeed = '160 mph',
                    acceleration = '4.5s'
                }
            },
            {
                name = 'Maverick',
                model = 'maverick',
                category = 'Helicopter',
                price = 4250000,
                image = 'https://i.imghippo.com/files/wiFV1557qM.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '800 hp',
                    topSpeed = '150 mph',
                    acceleration = '5.0s'
                }
            },
            {
                name = 'Volatus',
                model = 'volatus',
                category = 'VIPHelicopter',
                tag = 'VIP',
                price = 3990000,
                image = 'https://i.imghippo.com/files/rGa2819TA.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '750 hp',
                    topSpeed = '145 mph',
                    acceleration = '5.2s'
                }
            }
        }
    },
    
    -- ===============================
    --    Boat Luxury DEALERSHIP 3
    -- ===============================
    {
        name = "Boat",
        location =   vector4(-787.83, -1490.10, 1.60, 290.63),
        spawnLocation =  vector4(-802.35, -1489.99, 1.40, 110.97),
        testDrive = {
            duration = 30,
            location =  vector4(-1892.96, -1754.81, 4.18, 61.80),
            returnLocation =  vector4(-787.83, -1490.10, 1.60, 290.63) 
        },
        npcModel = "s_m_y_pilot_01",
        categories = {"Boats", "VIPBoat"},
        blip = {
            sprite = 427,
            color = 3,
            scale = 0.8,
            display = 4,
            shortRange = true,
            label = "Boat Luxury"
        },
        vehicles = {
            {
                name = 'Marquis',
                model = 'marquis',
                category = 'Boats',
                price = 5500000,
                image = 'https://i.imghippo.com/files/Oz7110tQ.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '850 hp',
                    topSpeed = '160 mph',
                    acceleration = '4.5s'
                }
            },
            {
                name = 'Jet Max',
                model = 'jetmax',
                category = 'Boats',
                price = 4250000,
                image = 'https://i.imghippo.com/files/TxY3679FU.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '800 hp',
                    topSpeed = '150 mph',
                    acceleration = '5.0s'
                }
            },
            {
                name = 'Tropic',
                model = 'tropic',
                category = 'VIPBoat',
                tag = 'VIP',
                price = 3990000,
                image = 'https://i.imghippo.com/files/DCZ1500qe.png',
                colors = {
                    { name = 'Pearl White', hex = '#FFFFFF' },
                    { name = 'Solid Black', hex = '#000000' },
                    { name = 'Deep Blue', hex = '#0B3C80' },
                    { name = 'Racing Red', hex = '#FF0000' },
                    { name = 'Gold', hex = '#FFD700' }
                },
                specs = {
                    power = '750 hp',
                    topSpeed = '145 mph',
                    acceleration = '5.2s'
                }
            }
        }
    }
}

-- ===============================
--    Categories Configuration
-- ===============================
Config.Categories = {
    -- ===============================
    --    PDM Dealership Categories
    -- ===============================
    {
        id = 'all',
        label = 'All Vehicles',
        icon = 'border-all'
    },
    {
        id = 'Luxury',
        label = 'Luxury',
        icon = 'gem'
    },
    {
        id = 'Sports',
        label = 'Sports',
        icon = 'tachometer-alt'
    },
    {
        id = 'Super',
        label = 'Super',
        icon = 'rocket'
    },
    {
        id = 'SUV',
        label = 'SUV',
        icon = 'car-side'
    },
    {
        id = 'VIP',
        label = 'VIP',
        icon = 'star'
    },
    
    -- ===============================
    --    Luxury Air Categories
    -- ===============================
    {
        id = 'Helicopter',
        label = 'Helicopter',
        icon = 'helicopter'
    },
    {
        id = 'VIPHelicopter',
        label = 'VIP',
        icon = 'star'
    },
    
    -- ===============================
    --    Boat Categories
    -- ===============================
    {
        id = 'Boats',
        label = 'Boat',
        icon = 'ship'
    },
    {
        id = 'VIPBoat',
        label = 'VIP',
        icon = 'star'
    }
}

-- ===============================
--    DrawText3D Function
-- ===============================
function Config.DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end