Config = {}

Config.Framework = "qbcore" -- Set to "esx" or "qbcore"

Config.JobCenter = {
    PedModel = "a_m_m_business_01", -- Ped model
    PedCoords = vector4(-234.8400, -922.1964, 32.3122, 338.9445), -- Ped location and heading
    InteractionDistance = 2.0, -- Distance for interaction
    JobText = "Press [E] to open the Job Center" -- Draw text message
}

Config.Jobs = {
    { 
        name = "fisherman", 
        label = "Fishing",
        image = "img/fishingbg.png" 
    },
    { 
        name = "fueler", 
        label = "Fueler", 
        image = "img/fuelerbg.png" 
    },
    { 
        name = "lumberjack", 
        label = "Lumberjack", 
        image = "img/lumberjackbg.png" 
    },
    { 
        name = "miner", 
        label = "Mining", 
        image = "img/minerbg.png" 
    },
    { 
        name = "tailor", 
        label = "Tailor", 
        image = "img/tailorbg.png" 
    },
    { 
        name = "taxi", 
        label = "Taxi Driver", 
        image = "img/taxibg.png" 
    },
    -- 
    { 
        name = "unemployed", 
        label = "Unemployed",
        image = "img/unemployedbg.png" 
    },
}