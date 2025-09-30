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
----                              VAMNGUARD LABS | DRUG SELLING NPC [QBCORE]
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

-- Timing settings for NPC behavior
Config.Timing = {
    actionWaitMin = 3000,  -- Minimum wait time between NPC actions
    actionWaitMax = 6000,  -- Maximum wait time between NPC actions
    spawnCheckInterval = 5000,  -- Interval to check for NPC spawning
    npcMovementCheckInterval = 1000  -- Interval to check NPC movement
}

-- Zones for drug selling
Config.Zones = {
    YellowZone = {
        centerCoord = vector3(-142.662, -1637.47, 32.597),  -- Center of the zone
        spawnRadius = 12.0,  -- Radius for NPC spawning
        maxNPCs = 8,  -- Maximum number of NPCs in this zone
        npcModels = { 'a_m_m_soucent_04', 'g_m_y_strpunk_01', 'ig_stretch' },  -- NPC models
        blip = { color = 5, sprite = 161, name = "Yellow Drug Zone" },  -- Blip settings
        name = "YellowZone"  -- Zone name
    },
    BallasZone = {
        centerCoord = vector3(104.7265, -1938.48, 20.795),
        spawnRadius = 30.0,
        maxNPCs = 12,
        npcModels = { 'g_m_y_ballaorig_01', 'ig_ballasog', 'g_m_y_ballasout_01' },
        blip = { color = 27, sprite = 161, name = "Ballas Drug Zone" },
        name = "BallasZone"
    }
    -- Add more zones here if needed
}

-- Police system settings
Config.AlertJobs = { 'police', 'sheriff' }  -- Jobs that receive police alerts
Config.NumberOfCops = 0  -- Minimum number of police required for drug sales
Config.PoliceAlertChance = 50  -- Chance to notify police (1-100)
Config.IncreasePercentage = 0  -- Percentage increase in price per police officer

-- Notification system
Config.NotificationSystem = 'okokNotify'  -- Options: 'QBCore', 'okokNotify', 'wasabiNotify'
Config.NotificationRobberyAlert = "A drug sale is being carried out, go to the location on the GPS."

-- Blip settings
Config.BlipSprite = 161  -- Blip type
Config.BlipColor = 1  -- Blip color
Config.BlipScale = 0.8  -- Blip scale
Config.BlipDuration = 10  -- Duration of blip in seconds
Config.BlipName = "Drug sales"  -- Blip name

-- Drug selling system
Config.SellingTime = 5  -- Time in seconds for the selling progress bar

-- BLACK MONEY ITEM NAME
Config.BlackMoneyItem = 'black_money'

-- Drug configuration
Config.Drugs = {
    Weed = {
        item = "weed",  -- Item name
        priceMin = 50,  -- Minimum price
        priceMax = 100,  -- Maximum price
        chance = 75,  -- Success chance (1-100)
        icon = "fa-solid fa-cannabis",  -- Icon for notifications
        label = "Sell weed",  -- Label for target interaction
        message = "You sold %s g of weed for $%s"  -- Notification message
    },
    Meth = {
        item = "meth",
        priceMin = 150,
        priceMax = 300,
        chance = 60,
        icon = "fa-solid fa-pills",
        label = "Sell methamphetamine",
        message = "You sold %s g of methamphetamine for $%s"
    },
    Coke = {
        item = "coke",
        priceMin = 200,
        priceMax = 400,
        chance = 50,
        icon = "fa-solid fa-prescription-bottle",
        label = "Sell cocaine",
        message = "You sold %s g of cocaine for $%s"
    }
    -- NewDrug = {
    --     item = "NewDrug",
    --     priceMin = 200,
    --     priceMax = 400,
    --     chance = 50,
    --     icon = "fa-solid fa-prescription-bottle",
    --     label = "Sell NewDrug",
    --     message = "You sold %s g of NewDrug for $%s"
    -- }
    -- Add new drugs here
}

-- Configurable messages (ox_lib)
Config.Messages = {
    yousold = 'You sold ',
    sold_for = ' for ', 
    currency = '$', 
    sellweed = 'Sell weed',
    sellmeth = 'Sell methamphetamine',
    sellcoke = 'Sell cocaine',
    toofar = 'You went too far',
    cancel = 'The pedestrian rejected your offer',
    sameguy = 'You have already spoken to this person',
    nopolice = 'Not enough police officers on duty',
}
