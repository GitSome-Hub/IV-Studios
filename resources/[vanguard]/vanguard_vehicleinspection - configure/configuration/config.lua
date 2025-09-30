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
----                      VANGUARD LABS | VEHICLE INSURANCE JOB [ESX/QB/QBOX]
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
--    Inventory Settings
-- ===============================
Config.Inventory = "ox-inventory"  -- Supported inventorys  "qb-inventory" or "ox_inventory" | Note, using "qb-inventory", also support LJ-Inventory if using it.

-- ===============================
--    Job & Inspection Settings
-- ===============================
Config.InspectionJob = "inspection"  -- Job required for inspection
Config.InspectionItem = "inspection_done"  -- Item needed to activate a valid inspection
Config.FailedInspectionItem = "inspection_failed"  -- Item for failed inspection status
Config.InitialInspectionDays = 30  -- Initial days for inspection (in GTA HOURS)
Config.DayReductionInterval = "1h"  -- Interval to reduce 1 day (supports "s", "m", "h")

-- ===============================
--    Printer & Clothes Room Settings
-- ===============================
Config.Printer = vector3(-1430.18, -456.067, 35.909)  -- Printer coordinates
Config.ClothesRoom = vector3(-1428.36, -458.498, 35.908)  -- Clothes room coordinates

-- ===============================
--   Keys Settings
-- ===============================
Config.Keys = {
    InspectionMenu = 167, -- F6 - Open inspection menu
    ContextMenu = 166     -- F5 - Shows Inspection
}

-- ===============================
--    Notifications
-- ===============================
Config.Notifications = {
    WorkClothesEquipped = {title = "CLOTHES", message = "Work clothes equipped successfully.", type = "success"},
    WorkClothesRemoved = {title = "CLOTHES", message = "Work clothes removed. Original clothes restored.", type = "info"},
    CheckingVehicleCondition = {title = "INSPECTION CENTER", message = "Checking... vehicle condition", type = "info"},
    VehicleInGoodCondition = {title = "INSPECTION CENTER", message = "The vehicle is in good condition", type = "success"},
    VehicleDamaged = {title = "INSPECTION CENTER", message = "The vehicle has damage", type = "error"},
    NeedToBeNearVehicle = {title = "INSPECTION CENTER", message = "You need to be within 4.5 units of a vehicle to check its condition.", type = "info"},
    CheckingLights = {title = "INSPECTION CENTER", message = "Checking... vehicle lights", type = "info"},
    AllLightsFunctioning = {title = "INSPECTION CENTER", message = "All vehicle lights are functioning correctly.", type = "success"},
    LightsNotFunctioning = {title = "INSPECTION CENTER", message = "Some vehicle lights are not functioning.", type = "error"},
    CheckingEngine = {title = "INSPECTION CENTER", message = "Checking... engine condition", type = "info"},
    EngineInGoodCondition = {title = "INSPECTION CENTER", message = "The vehicle's engine is in good condition.", type = "success"},
    EngineNeedsRepairs = {title = "INSPECTION CENTER", message = "The vehicle's engine needs repairs.", type = "error"},
    CheckingTires = {title = "INSPECTION CENTER", message = "Checking... tire condition", type = "info"},
    TiresInGoodCondition = {title = "INSPECTION CENTER", message = "The vehicle's tires are in good condition.", type = "success"},
    BurstTires = {title = "INSPECTION CENTER", message = "The vehicle has %s burst tire(s).", type = "error"},
    PrintingValidDoc = {title = "INSPECTION CENTER", message = "Printing Valid Inspection Document...", type = "info"},
    PrintingInvalidDoc = {title = "INSPECTION CENTER", message = "Printing Invalid Inspection Document...", type = "info"},
    InspectionActivated = {title = "INSPECTION", message = "Inspection activated on the vehicle.", type = "success"},
    AlreadyHasInspection = {title = "INSPECTION", message = "This vehicle already has an active inspection.", type = "error"},
    ItemPrinted = {title = "INVENTORY", message = "You printed a {itemName} document.", type = "success"},
    InspectionRemoved = {title = "INSPECTION", message = "Inspection removed from the vehicle.", type = "success"},
    PlayerDataFailed = {title = "INSPECTION", message = "Failed to retrieve player data.", type = "error"},
    InvalidInspectionItem = {title = "INSPECTION", message = "You don't have a valid inspection item.", type = "error"},
    NoNearbyPlayer = {title = "INSPECTION", message = "No nearby player to show inspection.", type = "error"},
    InspectionValid = {title = "INSPECTION", message = "The vehicle inspection is valid! Days: %s", type = "success"},
    InspectionInvalid = {title = "INSPECTION", message = "The vehicle inspection is invalid.", type = "error"},
    NoRegisteredInspection = {title = "INSPECTION", message = "This vehicle has no registered inspection.", type = "error"},
    NeedToBeInVehicle = {title = "INSPECTION", message = "You need to be in a valid vehicle.", type = "error"},
    UnableToRetrieveModel = {title = "INSPECTION", message = "Unable to retrieve the vehicle model.", type = "error"}
}
-- ===============================
--    Menu Label Settings
-- ===============================
Config.MenuLabels = {
    -- Vehicle Inspection Menu Options
    VehicleInspectionMenu = {
        ActivateInspection = "Activate inspection",  -- Label for the activate inspection option
        RemoveInspection = "Remove inspection",  -- Label for the remove inspection option
        CheckInspection = "Check inspection"  -- Label for the check inspection option
    },

    -- Show Vehicle Inspection Menu
    ShowVehicleInspectionMenu = {
        ShowInspection = "Show Inspection"  -- Label for the show inspection option
    },

    -- Vehicle Menu Options
    VehicleMenu = {
        CheckVehicleCondition = "Check Vehicle Condition",  -- Label for checking vehicle condition
        CheckVehicleLights = "Check Vehicle Lights",  -- Label for checking vehicle lights
        CheckEngineCondition = "Check Engine Condition",  -- Label for checking engine condition
        CheckTireCondition = "Check Tire Condition"  -- Label for checking tire condition
    },

    -- Inspection Center Menu
    InspectionCenterMenu = {
        InteractWithVehicle = "Interact with Vehicle",  -- Label for interacting with the vehicle
        VehicleInspection = "Vehicle Inspection",  -- Label for starting the vehicle inspection
    }
}

-- ===============================
--    Blip Settings
-- ===============================
Config.BlipLocation = vector3(-1424.44, -453.888, 35.909)

-- You can find blips, colors and etc, here: https://docs.fivem.net/docs/game-references/blips/
Config.Blip = {
    Sprite = 225,    -- Blip icon
    Color = 42,     -- Blip color 
    Scale = 0.8,   -- Blip size
    Name = "Inspection Vehicle", -- Blip name
    Display = 4,   -- Blip display
    ShortRange = true -- minimap visible
}



-- ===============================
--    Inspection Uniforms
-- ===============================
Config.Uniforms = {

    [1] = { 
        name = "Inspection",
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
--    Document Text Settings
-- ===============================
Config.DocumentText = {
    Header = {
        State = "STATE OF SAN ANDREAS",
        Department = "DEPARTMENT OF MOTOR VEHICLES",
        Title = "OFFICIAL VEHICLE INSPECTION CERTIFICATE"
    },
    Location = {
        Station = "Los Santos Central"
    },
    Labels = {
        InspectionDate = "Inspection Date:",
        Time = "Time:",
        InspectorID = "Inspector ID:",
        Station = "Station:",
        VehicleMake = "Vehicle Make:",
        Model = "Model:",
        Plate = "Plate:",
        VIN = "VIN:"
    },
    ChecklistTitle = "INSPECTION CHECKLIST",
    ChecklistItems = {
        BrakingSystem = "Braking System",
        SteeringSuspension = "Steering & Suspension",
        LightingEquipment = "Lighting Equipment",
        TiresWheels = "Tires & Wheels",
        ExhaustSystem = "Exhaust System",
        EmissionsTest = "Emissions Test"
    },
    Results = {
        PassTitle = "INSPECTION PASSED",
        PassMessage = "This vehicle has been thoroughly inspected and meets or exceeds all required safety and emissions standards set forth by the San Andreas Department of Motor Vehicles.",
        PassStamp = "APPROVED",
        FailTitle = "INSPECTION FAILED",
        FailMessage = "This vehicle has failed to meet the minimum required standards for operation on public roads. Repairs must be completed and the vehicle must be re-inspected.",
        FailStamp = "REJECTED",
        DeficienciesTitle = "NOTED DEFICIENCIES:"
    },
    Footer = {
        ValidityMessage = "This document is official and valid for {days} days from the date of inspection when APPROVED.",
        Department = "State of San Andreas - Department of Motor Vehicles - Vehicle Safety Division"
    }
}

-- Failure Reasons
Config.FailureReasons = {
    BrakeSystem = "Brake system malfunction - insufficient stopping power",
    SteeringSuspension = "Steering system shows excessive play",
    LightingEquipment = "Multiple non-functioning exterior lights",
    TiresWheels = "Severe tire wear below legal tread depth",
    ExhaustSystem = "Excessive exhaust emissions exceeding state limits",
    EmissionsTest = "Emissions test failed"
}
