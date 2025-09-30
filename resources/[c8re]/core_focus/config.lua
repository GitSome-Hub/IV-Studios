----------------------------------------------------------------
--  MAIN CONFIGURATION TABLE
----------------------------------------------------------------
Config = {
    -- ============================================================
    --  [0] FRAMEWORK SETTINGS
    -- ============================================================
    -- Framework use - you can choose between:
    -- 'qb-core' for QB-Core framework
    -- 'esx' for ESX framework
    -- 'standalone' for no framework (all checks return true)
    Framework = 'qb-core',
    
    -- Framework resource name is the name of the resource folder
    -- by default it's:
    -- 'qb-core' for qb-core framework
    -- 'es_extended' for esx framework
    FrameworkResource = 'qb-core',
    
    -- ============================================================
    --  ESX ONLY SETTINGS (ignore if using QB-Core)
    -- ============================================================
    -- Framework version (ESX ONLY)
    -- Set to true if you use ESX 1.8+ (new version)
    -- Set to false if you use ESX legacy (pre-1.8) or use getSharedObject event
    NewFrameworkVersion = true,
    
    -- Framework event (ESX ONLY) - to retrieve esx framework (on old version)
    -- Common values: 'esx:getSharedObject', 'esx:getSharedObject', etc.
    SharedObject = 'esx:getSharedObject',
    
    -- ============================================================
    --  [1] CORE BEHAVIOR
    -- ============================================================
    RadialTargetingKey = 19,
    MaxDistance = 20.0,
    BoneDotCheckRadius = 15.0,
    HoverToOpen = true, -- If true, dots open on hover. If false, dots open on click
    AllowToggleMode = false, -- If true, quick Alt press locks menu open without holding key

    -- ============================================================
    --  [2] VISUALS & EFFECTS
    -- ============================================================
    EnableFocusEffect = true,
    FocusTimecycleModifier = "prologue",
    FocusEaseInDuration = 500,
    FocusEaseOutDuration = 1000,
    HiDofTargetNearPlane      = 0.1,
    HiDofTargetNearFalloff    = 0.5,
    HiDofTargetFarPlane       = 5.0,
    HiDofTargetFarFalloff     = 15.0,
    PlayerTags = {
        Enabled = true,
        UseFirstLastName = false,
        ShowID = true,
        MaxDistance = 25.0
    },
    EnableOutline = false,
    OutlineColor = { 255, 255, 255, 255 },

    -- ============================================================
    --  [3] AUGMENTED REALITY BORDERS
    -- ============================================================
    -- Ground parameter options:
    -- - 'auto' or nil: Auto-detect ground level using collision detection
    -- - number: Fixed Z coordinate for all border points
    -- Coordinate types supported:
    -- - vector3(x, y, z): Full 3D coordinates
    -- - vector2(x, y): 2D coordinates, Z determined by ground parameter
    AugmentedLocations = {
        {
            name = "FLEECA BANK",
            coords = {
                vector3(155.85688781738,-1038.5275878906,29.253580093384),
                vector3(144.31730651855,-1033.8725585938,29.346872329712),
                vector3(136.50717163086,-1057.0159912109,28.978748321533),
                vector3(147.26733398438,-1060.9973144531,28.452899932861),
            },
            height = 5.0,
            color = "#00FF00", -- Green
            distance = 50.0,
            ground = 28.0
        },
        {
            name = "SUPERMARKET",
            coords = {
                vector3(1960.1650390625,3734.5629882812,32.201713562012),
                vector3(1972.3433837891,3741.7900390625,32.207412719727),
                vector3(1962.4736328125,3759.1389160156,32.215923309326),
                vector3(1950.2872314453,3751.8129882812,32.18968963623),
            },
            height = 5.0,
            color = "#1ea843", -- Green
            distance = 100.0,
            ground = 31.0
        },
        {
            name = "GAS STATION",
            coords = {
                vector3(2027.2366943359,3768.9274902344,32.19881439209),
                vector3(2006.4477539062,3807.3811035156,32.13111114502),
                vector3(1968.7346191406,3786.8549804688,31.965503692627),
                vector3(1988.974609375,3748.9729003906,32.260639190674),
            },
            height = 5.0,
            color = "#f511f1", -- Green
            distance = 100.0,
            ground = 31.0
        },
        {
            name = "SANDY EMERGENCY SERVICES",
            coords = {
                vector3(1876.666015625,3683.7438964844,33.387050628662),
                vector3(1854.5733642578,3719.8596191406,33.363162994385),
                vector3(1794.1391601562,3684.017578125,34.795055389404),
                vector3(1816.5825195312,3648.0227050781,33.839508056641),
            },
            height = 8.0,
            color = "#11def5", -- Green
            distance = 100.0,
            ground = 32.0
        }
    },

    -- ============================================================
    --  [4] AUGMENTED REALITY WINDOWS
    -- ============================================================
    -- Window system displays single "walls" above entities or coordinates
    -- Each window shows a title and data hashmap in a customizable UI style
    -- 
    -- COORDINATE FORMATS SUPPORTED:
    -- 1. Single coordinate + length: coords = vector3(x, y, z), length = 15.0
    -- 2. Legacy dual coordinates: coords = {vector3(x1,y1,z1), vector3(x2,y2,z2)}
    -- 
    -- DATA SUPPORTED
    -- IMAGES USE IMAGE URL FOR THE VARIABLE ["IMAGE1"] = "https://linkimage.com/image2.png"
    -- PROGRESS USE NUMBER AS PERCENT FOR THE VARIABLE ["PROGRESS"] = 23
    --
    -- ENTITY SUPPORT:
    -- - Set entity = entityHandle instead of coords
    -- - Wall will be created above the entity with specified length
    AugmentedWindows = {
        {
            title = "SERVER INFORMATION",
            coords = vector3(162.69403076172,-1005.3817749023,29.390630722046),  -- Single coordinate
            length = 6.0,  -- Length extends on both sides (10.0 left, 10.0 right)
            heading = nil, -- Optional: wall direction in degrees (default: 0.0)
            height = 3,
            color = "#00FFFF", -- Cyan
            style = "list", -- Available: list, basiclist, basic, image, progress, cards, compact
            distance = 100.0,
            data = {
                ["CHECK OUT OUR RULES"] = "/rules",
                ["JOIN OUR DISCORD"] = "/discord",
                ["SERVER UPTIME"] = "72 HOURS",
                
            }
        },
        {
            title = "PALETO HOSPITAL",
            coords = vector3(-236.99021911621,6320.763671875,32.065116882324),  -- Single coordinate
            length = 3.5,  -- Length extends on both sides (10.0 left, 10.0 right)
            heading = nil, -- Optional: wall direction in degrees (default: 0.0)
            height = 2.0,
            color = "#FF0000", -- Cyan
            style = "basiclist", -- Available: list, basiclist, basic, image, progress, cards, compact
            distance = 30.0,
            data = {
                ["Medics Online"] = "3",
                ["Today Injured"] = "15",
                ["Call A Taxi"] = "/taxi",
                ["Report"] = "/report"
            }
        },
        
    },

    -- ============================================================
    --  [5] CONTEXT MENU
    -- ============================================================
    ContextMenu = {
        
        general = {
            enabled = true, -- Enable/disable this context menu
            label = 'General Actions', icon = 'fas fa-globe-americas', color = '#3498db',
            canShow = function() return not IsPedInAnyVehicle(PlayerPedId(), false) end,
            options = {
                { label = 'Check ID', icon = 'fas fa-id-card', action = function() print("Checking ID") end },
                { label = 'Give Item', icon = 'fas fa-gift', action = function() print("Giving Item") end },
                { label = 'Give Money', icon = 'fas fa-money-bill-wave', action = function() print("Giving Money") end },
                { label = 'Rob Player', icon = 'fas fa-mask', action = function() print("Robbing Player") end },
            }
        },
        vehicle = {
            enabled = true, -- Enable/disable this context menu
            label = 'Vehicle Options', icon = 'fas fa-car-on', color = '#e74c3c',
            canShow = function() return IsPedInAnyVehicle(PlayerPedId(), false) end,
            options = {
                {
                    label = 'Engine', icon = 'fas fa-power-off',
                    action = function() local veh = GetVehiclePedIsIn(PlayerPedId(), false); if veh ~= 0 then SetVehicleEngineOn(veh, not GetIsVehicleEngineOn(veh), false, true) end end
                },
                {
                    label = "Doors", icon = "fas fa-door-open",
                    options = {
                        { label = "Front Left", icon = "fas fa-car-side", action = function() print("Toggling Front Left Door") end },
                        { label = "Front Right", icon = "fas fa-car-side", action = function() print("Toggling Front Right Door") end },
                        { label = "All Doors", icon = "fas fa-car", action = function() print("Toggling All Doors") end },
                    }
                },
                { label = 'Trunk', icon = 'fas fa-suitcase-rolling', action = function() print("Opening Trunk") end },
                { label = 'Glovebox', icon = 'fas fa-box-archive', action = function() print("Opening Glovebox") end },
            }
        },
        police = {
            enabled = true, -- Enable/disable this context menu
            label = 'Police Actions', icon = 'fas fa-shield-halved', color = '#11f52c',
            canShow = function()
                -- Only show for QB-Core framework
                if Config.Framework == 'qb-core' and exports['qb-core'] then
                    local QBCore = exports['qb-core']:GetCoreObject()
                    if QBCore and QBCore.Functions.GetPlayerData().job.name == 'police' then
                        return true
                    end
                end
                return false
            end,
            options = {
                { label = 'Emergency Button', icon = 'fas fa-bell', action = function() TriggerEvent('police:client:SendPoliceEmergencyAlert') end },
                { label = 'Check Tune Status', icon = 'fas fa-circle-info', action = function() TriggerEvent('qb-tunerchip:client:TuneStatus') end },
                { label = 'Reset House Lock', icon = 'fas fa-key', action = function() TriggerEvent('qb-houses:client:ResetHouse') end },
                { label = 'Revoke Drivers License', icon = 'fas fa-id-card', action = function() TriggerEvent('police:client:SeizeDriverLicense') end },
                {
                    label = "Police Objects",
                    icon = "fas fa-road",
                    options = {
                        { label = "Cone", icon = "fas fa-triangle-exclamation", action = function() TriggerEvent('police:client:spawnCone') end },
                        { label = "Gate", icon = "fas fa-torii-gate", action = function() TriggerEvent('police:client:spawnBarrier') end },
                        { label = "Speed Limit Sign", icon = "fas fa-sign-hanging", action = function() TriggerEvent('police:client:spawnRoadSign') end },
                        { label = "Tent", icon = "fas fa-campground", action = function() TriggerEvent('police:client:spawnTent') end },
                        { label = "Lighting", icon = "fas fa-lightbulb", action = function() TriggerEvent('police:client:spawnLight') end },
                        { label = "Spike Strips", icon = "fas fa-caret-up", action = function() TriggerEvent('police:client:SpawnSpikeStrip') end },
                        { label = "Remove Object", icon = "fas fa-trash", action = function() TriggerEvent('police:client:deleteObject') end },
                    }
                }
            }
        },
        ambulance = {
            enabled = true, -- Enable/disable this context menu
            label = 'EMS Actions', icon = 'fas fa-user-doctor', color = '#e74c3c',
            canShow = function()
                -- Only show for QB-Core framework
                if Config.Framework == 'qb-core' and exports['qb-core'] then
                    local QBCore = exports['qb-core']:GetCoreObject()
                    if QBCore and QBCore.Functions.GetPlayerData().job.name == 'ambulance' then
                        return true
                    end
                end
                return false
            end,
            options = {
                { label = 'Emergency Button', icon = 'fas fa-bell', action = function() TriggerEvent('police:client:SendPoliceEmergencyAlert') end },
                {
                    label = "Stretcher Options",
                    icon = "fas fa-bed-pulse",
                    options = {
                        { label = "Spawn Stretcher", icon = "fas fa-plus", action = function() TriggerEvent('qb-radialmenu:client:TakeStretcher') end },
                        { label = "Remove Stretcher", icon = "fas fa-minus", action = function() TriggerEvent('qb-radialmenu:client:RemoveStretcher') end },
                    }
                }
            }
        },
        animations = {
            enabled = true, -- Enable/disable this context menu
            label = 'Animations', icon = 'fas fa-person-walking-luggage', color = '#f1c40f',
            options = {
                {
                    label = "Cancel Animation",
                    icon = "fas fa-stop-circle",
                    action = function()
                        ExecuteCommand("emote cancel")
                    end
                },
                {
                    label = "Walk Styles",
                    icon = "fas fa-walking",
                    options = {
                        { label = "Alien", icon = "fab fa-reddit-alien", action = function() ExecuteCommand("walk Alien") end },
                        { label = "Armored", icon = "fas fa-user-shield", action = function() ExecuteCommand("walk Armored") end },
                        { label = "Arrogant", icon = "fas fa-hand-middle-finger", action = function() ExecuteCommand("walk Arrogant") end },
                        { label = "Brave", icon = "fas fa-shield-alt", action = function() ExecuteCommand("walk Brave") end },
                        { label = "Casual", icon = "fas fa-walking", action = function() ExecuteCommand("walk Casual") end },
                        { label = "Casual2", icon = "fas fa-walking", action = function() ExecuteCommand("walk Casual2") end },
                        { label = "Casual3", icon = "fas fa-walking", action = function() ExecuteCommand("walk Casual3") end },
                        { label = "Casual4", icon = "fas fa-walking", action = function() ExecuteCommand("walk Casual4") end },
                        { label = "Casual5", icon = "fas fa-walking", action = function() ExecuteCommand("walk Casual5") end },
                        { label = "Casual6", icon = "fas fa-walking", action = function() ExecuteCommand("walk Casual6") end },
                        { label = "Chichi", icon = "fas fa-glass-cheers", action = function() ExecuteCommand("walk Chichi") end },
                        { label = "Confident", icon = "fas fa-user-check", action = function() ExecuteCommand("walk Confident") end },
                        { label = "Cop", icon = "fas fa-user-secret", action = function() ExecuteCommand("walk Cop") end },
                        { label = "Cop2", icon = "fas fa-user-secret", action = function() ExecuteCommand("walk Cop2") end },
                        { label = "Cop3", icon = "fas fa-user-secret", action = function() ExecuteCommand("walk Cop3") end },
                        { label = "Default Female", icon = "fas fa-female", action = function() ExecuteCommand("walk 'Default Female'") end },
                        { label = "Default Male", icon = "fas fa-male", action = function() ExecuteCommand("walk 'Default Male'") end },
                        { label = "Drunk", icon = "fas fa-wine-glass-alt", action = function() ExecuteCommand("walk Drunk") end },
                        { label = "Drunk2", icon = "fas fa-wine-glass-alt", action = function() ExecuteCommand("walk Drunk2") end },
                        { label = "Drunk3", icon = "fas fa-wine-glass-alt", action = function() ExecuteCommand("walk Drunk3") end },
                        { label = "Femme", icon = "fas fa-venus", action = function() ExecuteCommand("walk Femme") end },
                        { label = "Fire", icon = "fas fa-fire-alt", action = function() ExecuteCommand("walk Fire") end },
                        { label = "Fire2", icon = "fas fa-fire-alt", action = function() ExecuteCommand("walk Fire2") end },
                        { label = "Fire3", icon = "fas fa-fire-alt", action = function() ExecuteCommand("walk Fire3") end },
                        { label = "Flee", icon = "fas fa-running", action = function() ExecuteCommand("walk Flee") end },
                        { label = "Franklin", icon = "fas fa-user-friends", action = function() ExecuteCommand("walk Franklin") end },
                        { label = "Gangster", icon = "fas fa-user-ninja", action = function() ExecuteCommand("walk Gangster") end },
                        { label = "Gangster2", icon = "fas fa-user-ninja", action = function() ExecuteCommand("walk Gangster2") end },
                        { label = "Gangster3", icon = "fas fa-user-ninja", action = function() ExecuteCommand("walk Gangster3") end },
                        { label = "Gangster4", icon = "fas fa-user-ninja", action = function() ExecuteCommand("walk Gangster4") end },
                        { label = "Gangster5", icon = "fas fa-user-ninja", action = function() ExecuteCommand("walk Gangster5") end },
                        { label = "Grooving", icon = "fas fa-music", action = function() ExecuteCommand("walk Grooving") end },
                        { label = "Guard", icon = "fas fa-user-shield", action = function() ExecuteCommand("walk Guard") end },
                        { label = "Handcuffs", icon = "fas fa-handcuffs", action = function() ExecuteCommand("walk Handcuffs") end },
                        { label = "Heels", icon = "fas fa-shoe-prints", action = function() ExecuteCommand("walk Heels") end },
                        { label = "Heels2", icon = "fas fa-shoe-prints", action = function() ExecuteCommand("walk Heels2") end },
                        { label = "Hiking", icon = "fas fa-hiking", action = function() ExecuteCommand("walk Hiking") end },
                        { label = "Hipster", icon = "fab fa-redhat", action = function() ExecuteCommand("walk Hipster") end },
                        { label = "Hobo", icon = "fas fa-trash-alt", action = function() ExecuteCommand("walk Hobo") end },
                        { label = "Hurry", icon = "fas fa-shipping-fast", action = function() ExecuteCommand("walk Hurry") end },
                        { label = "Janitor", icon = "fas fa-broom", action = function() ExecuteCommand("walk Janitor") end },
                        { label = "Janitor2", icon = "fas fa-broom", action = function() ExecuteCommand("walk Janitor2") end },
                        { label = "Jog", icon = "fas fa-running", action = function() ExecuteCommand("walk Jog") end },
                        { label = "Lemar", icon = "fas fa-user-friends", action = function() ExecuteCommand("walk Lemar") end },
                        { label = "Lester", icon = "fas fa-user-secret", action = function() ExecuteCommand("walk Lester") end },
                        { label = "Lester2", icon = "fas fa-user-secret", action = function() ExecuteCommand("walk Lester2") end },
                        { label = "Maneater", icon = "fas fa-venus", action = function() ExecuteCommand("walk Maneater") end },
                        { label = "Michael", icon = "fas fa-user-friends", action = function() ExecuteCommand("walk Michael") end },
                        { label = "Money", icon = "fas fa-money-bill-wave", action = function() ExecuteCommand("walk Money") end },
                        { label = "Muscle", icon = "fas fa-dumbbell", action = function() ExecuteCommand("walk Muscle") end },
                        { label = "Posh", icon = "fas fa-user-tie", action = function() ExecuteCommand("walk Posh") end },
                        { label = "Posh2", icon = "fas fa-user-tie", action = function() ExecuteCommand("walk Posh2") end },
                        { label = "Quick", icon = "fas fa-running", action = function() ExecuteCommand("walk Quick") end },
                        { label = "Runner", icon = "fas fa-running", action = function() ExecuteCommand("walk Runner") end },
                        { label = "Sad", icon = "fas fa-sad-tear", action = function() ExecuteCommand("walk Sad") end },
                        { label = "Sassy", icon = "fas fa-hand-peace", action = function() ExecuteCommand("walk Sassy") end },
                        { label = "Sassy2", icon = "fas fa-hand-peace", action = function() ExecuteCommand("walk Sassy2") end },
                        { label = "Scared", icon = "fas fa-scream", action = function() ExecuteCommand("walk Scared") end },
                        { label = "Sexy", icon = "fas fa-heart", action = function() ExecuteCommand("walk Sexy") end },
                        { label = "Shady", icon = "fas fa-user-secret", action = function() ExecuteCommand("walk Shady") end },
                        { label = "Slow", icon = "fas fa-walking", action = function() ExecuteCommand("walk Slow") end },
                        { label = "Swagger", icon = "fas fa-user-ninja", action = function() ExecuteCommand("walk Swagger") end },
                        { label = "Tough", icon = "fas fa-fist-raised", action = function() ExecuteCommand("walk Tough") end },
                        { label = "Tough2", icon = "fas fa-fist-raised", action = function() ExecuteCommand("walk Tough2") end },
                        { label = "Trash", icon = "fas fa-trash", action = function() ExecuteCommand("walk Trash") end },
                        { label = "Trash2", icon = "fas fa-trash", action = function() ExecuteCommand("walk Trash2") end },
                        { label = "Trevor", icon = "fas fa-user-friends", action = function() ExecuteCommand("walk Trevor") end },
                        { label = "Wide", icon = "fas fa-arrows-alt-h", action = function() ExecuteCommand("walk Wide") end },
                    }
                },
                {
                    label = "Dances",
                    icon = "fas fa-music",
                    options = {
                        { label = "Dance F", icon = "fas fa-female", action = function() ExecuteCommand("emote dancef") end },
                        { label = "Dance F2", icon = "fas fa-female", action = function() ExecuteCommand("emote dancef2") end },
                        { label = "Dance F3", icon = "fas fa-female", action = function() ExecuteCommand("emote dancef3") end },
                        { label = "Dance F4", icon = "fas fa-female", action = function() ExecuteCommand("emote dancef4") end },
                        { label = "Dance F5", icon = "fas fa-female", action = function() ExecuteCommand("emote dancef5") end },
                        { label = "Dance F6", icon = "fas fa-female", action = function() ExecuteCommand("emote dancef6") end },
                        { label = "Dance Slow 2", icon = "fas fa-child", action = function() ExecuteCommand("emote danceslow2") end },
                        { label = "Dance Slow 3", icon = "fas fa-child", action = function() ExecuteCommand("emote danceslow3") end },
                        { label = "Dance Slow 4", icon = "fas fa-child", action = function() ExecuteCommand("emote danceslow4") end },
                        { label = "Dance", icon = "fas fa-male", action = function() ExecuteCommand("emote dance") end },
                        { label = "Dance 2", icon = "fas fa-male", action = function() ExecuteCommand("emote dance2") end },
                        { label = "Dance 3", icon = "fas fa-male", action = function() ExecuteCommand("emote dance3") end },
                        { label = "Dance 4", icon = "fas fa-male", action = function() ExecuteCommand("emote dance4") end },
                        { label = "Dance Upper", icon = "fas fa-street-view", action = function() ExecuteCommand("emote danceupper") end },
                        { label = "Dance Upper 2", icon = "fas fa-street-view", action = function() ExecuteCommand("emote danceupper2") end },
                        { label = "Dance Shy", icon = "fas fa-user-secret", action = function() ExecuteCommand("emote danceshy") end },
                        { label = "Dance Shy 2", icon = "fas fa-user-secret", action = function() ExecuteCommand("emote danceshy2") end },
                        { label = "Dance Slow", icon = "fas fa-child", action = function() ExecuteCommand("emote danceslow") end },
                        { label = "Dance Silly 9", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly9") end },
                        { label = "Dance 6", icon = "fas fa-music", action = function() ExecuteCommand("emote dance6") end },
                        { label = "Dance 7", icon = "fas fa-music", action = function() ExecuteCommand("emote dance7") end },
                        { label = "Dance 8", icon = "fas fa-music", action = function() ExecuteCommand("emote dance8") end },
                        { label = "Dance Silly", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly") end },
                        { label = "Dance Silly 2", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly2") end },
                        { label = "Dance Silly 3", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly3") end },
                        { label = "Dance Silly 4", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly4") end },
                        { label = "Dance Silly 5", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly5") end },
                        { label = "Dance Silly 6", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly6") end },
                        { label = "Dance 9", icon = "fas fa-music", action = function() ExecuteCommand("emote dance9") end },
                        { label = "Dance Silly 8", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly8") end },
                        { label = "Dance Silly 7", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote dancesilly7") end },
                        { label = "Dance 5", icon = "fas fa-music", action = function() ExecuteCommand("emote dance5") end },
                        { label = "Dance Glowsticks", icon = "fas fa-lightbulb", action = function() ExecuteCommand("emote danceglowstick") end },
                        { label = "Dance Glowsticks 2", icon = "fas fa-lightbulb", action = function() ExecuteCommand("emote danceglowstick2") end },
                        { label = "Dance Glowsticks 3", icon = "fas fa-lightbulb", action = function() ExecuteCommand("emote danceglowstick3") end },
                        { label = "Dance Horse", icon = "fas fa-horse", action = function() ExecuteCommand("emote dancehorse") end },
                        { label = "Dance Horse 2", icon = "fas fa-horse", action = function() ExecuteCommand("emote dancehorse2") end },
                        { label = "Dance Horse 3", icon = "fas fa-horse", action = function() ExecuteCommand("emote dancehorse3") end },
                    }
                },
                {
                    label = "General Emotes",
                    icon = "fas fa-smile-beam",
                    options = {
                        { label = "Drink", icon = "fas fa-glass-martini", action = function() ExecuteCommand("emote drink") end },
                        { label = "Beast", icon = "fas fa-pastafarianism", action = function() ExecuteCommand("emote beast") end },
                        { label = "Chill", icon = "fas fa-snowflake", action = function() ExecuteCommand("emote chill") end },
                        { label = "Cloudgaze", icon = "fas fa-cloud", action = function() ExecuteCommand("emote cloudgaze") end },
                        { label = "Cloudgaze 2", icon = "fas fa-cloud", action = function() ExecuteCommand("emote cloudgaze2") end },
                        { label = "Prone", icon = "fas fa-user-injured", action = function() ExecuteCommand("emote prone") end },
                        { label = "Pullover", icon = "fas fa-car-side", action = function() ExecuteCommand("emote pullover") end },
                        { label = "Idle", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle") end },
                        { label = "Idle 8", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle8") end },
                        { label = "Idle 9", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle9") end },
                        { label = "Idle 10", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle10") end },
                        { label = "Idle 11", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle11") end },
                        { label = "Idle 2", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle2") end },
                        { label = "Idle 3", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle3") end },
                        { label = "Idle 4", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle4") end },
                        { label = "Idle 5", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle5") end },
                        { label = "Idle 6", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle6") end },
                        { label = "Idle 7", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote idle7") end },
                        { label = "Wait 3", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait3") end },
                        { label = "Idle Drunk", icon = "fas fa-wine-glass-alt", action = function() ExecuteCommand("emote idledrunk") end },
                        { label = "Idle Drunk 2", icon = "fas fa-wine-glass-alt", action = function() ExecuteCommand("emote idledrunk2") end },
                        { label = "Idle Drunk 3", icon = "fas fa-wine-glass-alt", action = function() ExecuteCommand("emote idledrunk3") end },
                        { label = "Air Guitar", icon = "fas fa-guitar", action = function() ExecuteCommand("emote airguitar") end },
                        { label = "Air Synth", icon = "fas fa-music", action = function() ExecuteCommand("emote airsynth") end },
                        { label = "Argue", icon = "fas fa-angry", action = function() ExecuteCommand("emote argue") end },
                        { label = "Argue 2", icon = "fas fa-angry", action = function() ExecuteCommand("emote argue2") end },
                        { label = "Bartender", icon = "fas fa-user-tie", action = function() ExecuteCommand("emote bartender") end },
                        { label = "Blow Kiss", icon = "fas fa-kiss-wink-heart", action = function() ExecuteCommand("emote blowkiss") end },
                        { label = "Blow Kiss 2", icon = "fas fa-kiss-wink-heart", action = function() ExecuteCommand("emote blowkiss2") end },
                        { label = "Curtsy", icon = "fas fa-female", action = function() ExecuteCommand("emote curtsy") end },
                        { label = "Bring It On", icon = "fas fa-hand-rock", action = function() ExecuteCommand("emote bringiton") end },
                        { label = "Come at me bro", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote comeatmebro") end },
                        { label = "Cop 2", icon = "fas fa-user-secret", action = function() ExecuteCommand("emote cop2") end },
                        { label = "Cop 3", icon = "fas fa-user-secret", action = function() ExecuteCommand("emote cop3") end },
                        { label = "Crossarms", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote crossarms") end },
                        { label = "Crossarms 2", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote crossarms2") end },
                        { label = "Crossarms 3", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote crossarms3") end },
                        { label = "Crossarms 4", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote crossarms4") end },
                        { label = "Crossarms 5", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote crossarms5") end },
                        { label = "Fold Arms 2", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote foldarms2") end },
                        { label = "Crossarms 6", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote crossarms6") end },
                        { label = "Fold Arms", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote foldarms") end },
                        { label = "Crossarms Side", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote crossarmsside") end },
                        { label = "Damn", icon = "fas fa-exclamation-triangle", action = function() ExecuteCommand("emote damn") end },
                        { label = "Damn 2", icon = "fas fa-exclamation-triangle", action = function() ExecuteCommand("emote damn2") end },
                        { label = "Point Down", icon = "fas fa-hand-point-down", action = function() ExecuteCommand("emote pointdown") end },
                        { label = "Surrender", icon = "fas fa-hands", action = function() ExecuteCommand("emote surrender") end },
                        { label = "Facepalm 2", icon = "fas fa-face-frown-open", action = function() ExecuteCommand("emote facepalm2") end },
                        { label = "Facepalm", icon = "fas fa-face-frown-open", action = function() ExecuteCommand("emote facepalm") end },
                        { label = "Facepalm 3", icon = "fas fa-face-frown-open", action = function() ExecuteCommand("emote facepalm3") end },
                        { label = "Facepalm 4", icon = "fas fa-face-frown-open", action = function() ExecuteCommand("emote facepalm4") end },
                        { label = "Fall Over", icon = "fas fa-user-injured", action = function() ExecuteCommand("emote fallover") end },
                        { label = "Fall Over 2", icon = "fas fa-user-injured", action = function() ExecuteCommand("emote fallover2") end },
                        { label = "Fall Over 3", icon = "fas fa-user-injured", action = function() ExecuteCommand("emote fallover3") end },
                        { label = "Fall Over 4", icon = "fas fa-user-injured", action = function() ExecuteCommand("emote fallover4") end },
                        { label = "Fall Over 5", icon = "fas fa-user-injured", action = function() ExecuteCommand("emote fallover5") end },
                        { label = "Fall Asleep", icon = "fas fa-bed", action = function() ExecuteCommand("emote fallasleep") end },
                        { label = "Fight Me", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote fightme") end },
                        { label = "Fight Me 2", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote fightme2") end },
                        { label = "Finger", icon = "fas fa-hand-middle-finger", action = function() ExecuteCommand("emote finger") end },
                        { label = "Finger 2", icon = "fas fa-hand-middle-finger", action = function() ExecuteCommand("emote finger2") end },
                        { label = "Handshake", icon = "fas fa-handshake", action = function() ExecuteCommand("emote handshake") end },
                        { label = "Handshake 2", icon = "fas fa-handshake", action = function() ExecuteCommand("emote handshake2") end },
                        { label = "Wait 4", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait4") end },
                        { label = "Wait 5", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait5") end },
                        { label = "Wait 6", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait6") end },
                        { label = "Wait 7", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait7") end },
                        { label = "Wait 8", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait8") end },
                        { label = "Wait 9", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait9") end },
                        { label = "Wait 10", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait10") end },
                        { label = "Wait 11", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait11") end },
                        { label = "Hiking", icon = "fas fa-hiking", action = function() ExecuteCommand("emote hiking") end },
                        { label = "Hug", icon = "fas fa-user-friends", action = function() ExecuteCommand("emote hug") end },
                        { label = "Hug 2", icon = "fas fa-user-friends", action = function() ExecuteCommand("emote hug2") end },
                        { label = "Hug 3", icon = "fas fa-user-friends", action = function() ExecuteCommand("emote hug3") end },
                        { label = "Inspect", icon = "fas fa-search", action = function() ExecuteCommand("emote inspect") end },
                        { label = "Jazzhands", icon = "fas fa-hands-sparkles", action = function() ExecuteCommand("emote jazzhands") end },
                        { label = "Jog 2", icon = "fas fa-running", action = function() ExecuteCommand("emote jog2") end },
                        { label = "Jog 3", icon = "fas fa-running", action = function() ExecuteCommand("emote jog3") end },
                        { label = "Jog 4", icon = "fas fa-running", action = function() ExecuteCommand("emote jog4") end },
                        { label = "Jog 5", icon = "fas fa-running", action = function() ExecuteCommand("emote jog5") end },
                        { label = "Jumping Jacks", icon = "fas fa-running", action = function() ExecuteCommand("emote jumpingjacks") end },
                        { label = "Kneel 2", icon = "fas fa-pray", action = function() ExecuteCommand("emote kneel2") end },
                        { label = "Kneel 3", icon = "fas fa-pray", action = function() ExecuteCommand("emote kneel3") end },
                        { label = "Knock", icon = "fas fa-hand-point-up", action = function() ExecuteCommand("emote knock") end },
                        { label = "Knock 2", icon = "fas fa-hand-point-up", action = function() ExecuteCommand("emote knock2") end },
                        { label = "Knuckle Crunch", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote knucklecrunch") end },
                        { label = "Lapdance", icon = "fas fa-chair", action = function() ExecuteCommand("emote lapdance") end },
                        { label = "Lean 2", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote lean2") end },
                        { label = "Lean 3", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote lean3") end },
                        { label = "Lean 4", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote lean4") end },
                        { label = "Lean 5", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote lean5") end },
                        { label = "Lean Flirt", icon = "fas fa-flushed", action = function() ExecuteCommand("emote leanflirt") end },
                        { label = "Lean Bar 2", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanbar2") end },
                        { label = "Lean Bar 3", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanbar3") end },
                        { label = "Lean Bar 4", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanbar4") end },
                        { label = "Lean High", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanhigh") end },
                        { label = "Lean High 2", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanhigh2") end },
                        { label = "Leanside", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanside") end },
                        { label = "Leanside 2", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanside2") end },
                        { label = "Leanside 3", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanside3") end },
                        { label = "Leanside 4", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanside4") end },
                        { label = "Leanside 5", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanside5") end },
                        { label = "Me", icon = "fas fa-user", action = function() ExecuteCommand("emote me") end },
                        { label = "Mechanic", icon = "fas fa-wrench", action = function() ExecuteCommand("emote mechanic") end },
                        { label = "Mechanic 2", icon = "fas fa-wrench", action = function() ExecuteCommand("emote mechanic2") end },
                        { label = "Mechanic 3", icon = "fas fa-wrench", action = function() ExecuteCommand("emote mechanic3") end },
                        { label = "Mechanic 4", icon = "fas fa-wrench", action = function() ExecuteCommand("emote mechanic4") end },
                        { label = "Medic 2", icon = "fas fa-briefcase-medical", action = function() ExecuteCommand("emote medic2") end },
                        { label = "Meditiate", icon = "fas fa-om", action = function() ExecuteCommand("emote meditate") end },
                        { label = "Meditiate 2", icon = "fas fa-om", action = function() ExecuteCommand("emote meditate2") end },
                        { label = "Meditiate 3", icon = "fas fa-om", action = function() ExecuteCommand("emote meditate3") end },
                        { label = "Metal", icon = "fas fa-hand-rock", action = function() ExecuteCommand("emote metal") end },
                        { label = "No", icon = "fas fa-times-circle", action = function() ExecuteCommand("emote no") end },
                        { label = "No 2", icon = "fas fa-times-circle", action = function() ExecuteCommand("emote no2") end },
                        { label = "Nose Pick", icon = "fas fa-hand-point-up", action = function() ExecuteCommand("emote nosepick") end },
                        { label = "No Way", icon = "fas fa-ban", action = function() ExecuteCommand("emote noway") end },
                        { label = "OK", icon = "fas fa-check-circle", action = function() ExecuteCommand("emote ok") end },
                        { label = "Out of Breath", icon = "fas fa-lungs-virus", action = function() ExecuteCommand("emote outofbreath") end },
                        { label = "Pickup", icon = "fas fa-hand-holding-usd", action = function() ExecuteCommand("emote pickup") end },
                        { label = "Push", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote push") end },
                        { label = "Push 2", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote push2") end },
                        { label = "Point", icon = "fas fa-hand-point-up", action = function() ExecuteCommand("emote point") end },
                        { label = "Pushup", icon = "fas fa-dumbbell", action = function() ExecuteCommand("emote pushup") end },
                        { label = "Countdown", icon = "fas fa-sort-numeric-down", action = function() ExecuteCommand("emote countdown") end },
                        { label = "Point Right", icon = "fas fa-hand-point-right", action = function() ExecuteCommand("emote pointright") end },
                        { label = "Salute", icon = "fas fa-hand-point-right", action = function() ExecuteCommand("emote salute") end },
                        { label = "Salute 2", icon = "fas fa-hand-point-right", action = function() ExecuteCommand("emote salute2") end },
                        { label = "Salute 3", icon = "fas fa-hand-point-right", action = function() ExecuteCommand("emote salute3") end },
                        { label = "Scared", icon = "fas fa-scream", action = function() ExecuteCommand("emote scared") end },
                        { label = "Scared 2", icon = "fas fa-scream", action = function() ExecuteCommand("emote scared2") end },
                        { label = "Screw You", icon = "fas fa-hand-middle-finger", action = function() ExecuteCommand("emote screwyou") end },
                        { label = "Shake Off", icon = "fas fa-hand-sparkles", action = function() ExecuteCommand("emote shakeoff") end },
                        { label = "Shot", icon = "fas fa-skull-crossbones", action = function() ExecuteCommand("emote shot") end },
                        { label = "Sleep", icon = "fas fa-bed", action = function() ExecuteCommand("emote sleep") end },
                        { label = "Shrug", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote shrug") end },
                        { label = "Shrug 2", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote shrug2") end },
                        { label = "Sit", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit") end },
                        { label = "Sit 2", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit2") end },
                        { label = "Sit 3", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit3") end },
                        { label = "Sit 4", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit4") end },
                        { label = "Sit 5", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit5") end },
                        { label = "Sit 6", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit6") end },
                        { label = "Sit 7", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit7") end },
                        { label = "Sit 8", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit8") end },
                        { label = "Sit 9", icon = "fas fa-chair", action = function() ExecuteCommand("emote sit9") end },
                        { label = "Sit Lean", icon = "fas fa-chair", action = function() ExecuteCommand("emote sitlean") end },
                        { label = "Sit Sad", icon = "fas fa-sad-tear", action = function() ExecuteCommand("emote sitsad") end },
                        { label = "Sit Scared", icon = "fas fa-scream", action = function() ExecuteCommand("emote sitscared") end },
                        { label = "Sit Scared 2", icon = "fas fa-scream", action = function() ExecuteCommand("emote sitscared2") end },
                        { label = "Sit Scared 3", icon = "fas fa-scream", action = function() ExecuteCommand("emote sitscared3") end },
                        { label = "Sit Drunk", icon = "fas fa-wine-glass-alt", action = function() ExecuteCommand("emote sitdrunk") end },
                        { label = "Sit Chair 2", icon = "fas fa-chair", action = function() ExecuteCommand("emote sitchair2") end },
                        { label = "Sit Chair 3", icon = "fas fa-chair", action = function() ExecuteCommand("emote sitchair3") end },
                        { label = "Sit Chair 4", icon = "fas fa-chair", action = function() ExecuteCommand("emote sitchair4") end },
                        { label = "Sit Chair 5", icon = "fas fa-chair", action = function() ExecuteCommand("emote sitchair5") end },
                        { label = "Sit Chair 6", icon = "fas fa-chair", action = function() ExecuteCommand("emote sitchair6") end },
                        { label = "Sit Chair Side", icon = "fas fa-chair", action = function() ExecuteCommand("emote sitchairside") end },
                        { label = "Sit Up", icon = "fas fa-dumbbell", action = function() ExecuteCommand("emote situp") end },
                        { label = "Clap Angry", icon = "fas fa-angry", action = function() ExecuteCommand("emote clapangry") end },
                        { label = "Slow Clap 3", icon = "fas fa-hands-clapping", action = function() ExecuteCommand("emote slowclap3") end },
                        { label = "Clap", icon = "fas fa-hands-clapping", action = function() ExecuteCommand("emote clap") end },
                        { label = "Slow Clap", icon = "fas fa-hands-clapping", action = function() ExecuteCommand("emote slowclap") end },
                        { label = "Slow Clap 2", icon = "fas fa-hands-clapping", action = function() ExecuteCommand("emote slowclap2") end },
                        { label = "Smell", icon = "fas fa-wind", action = function() ExecuteCommand("emote smell") end },
                        { label = "Stick Up", icon = "fas fa-hands-up", action = function() ExecuteCommand("emote stickup") end },
                        { label = "Stumble", icon = "fas fa-user-injured", action = function() ExecuteCommand("emote stumble") end },
                        { label = "Stunned", icon = "fas fa-dizzy", action = function() ExecuteCommand("emote stunned") end },
                        { label = "Sunbathe", icon = "fas fa-sun", action = function() ExecuteCommand("emote sunbathe") end },
                        { label = "Sunbathe 2", icon = "fas fa-sun", action = function() ExecuteCommand("emote sunbathe2") end },
                        { label = "T", icon = "fas fa-user", action = function() ExecuteCommand("emote t") end },
                        { label = "T 2", icon = "fas fa-user", action = function() ExecuteCommand("emote t2") end },
                        { label = "Think 5", icon = "fas fa-brain", action = function() ExecuteCommand("emote think5") end },
                        { label = "Think", icon = "fas fa-brain", action = function() ExecuteCommand("emote think") end },
                        { label = "Think 3", icon = "fas fa-brain", action = function() ExecuteCommand("emote think3") end },
                        { label = "Think 2", icon = "fas fa-brain", action = function() ExecuteCommand("emote think2") end },
                        { label = "Thumbs Up 3", icon = "fas fa-thumbs-up", action = function() ExecuteCommand("emote thumbsup3") end },
                        { label = "Thumbs Up 2", icon = "fas fa-thumbs-up", action = function() ExecuteCommand("emote thumbsup2") end },
                        { label = "Thumbs Up", icon = "fas fa-thumbs-up", action = function() ExecuteCommand("emote thumbsup") end },
                        { label = "Type", icon = "fas fa-keyboard", action = function() ExecuteCommand("emote type") end },
                        { label = "Type 2", icon = "fas fa-keyboard", action = function() ExecuteCommand("emote type2") end },
                        { label = "Type 3", icon = "fas fa-keyboard", action = function() ExecuteCommand("emote type3") end },
                        { label = "Type 4", icon = "fas fa-keyboard", action = function() ExecuteCommand("emote type4") end },
                        { label = "Warmth", icon = "fas fa-fire", action = function() ExecuteCommand("emote warmth") end },
                        { label = "Wave 4", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave4") end },
                        { label = "Wave 2", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave2") end },
                        { label = "Wave 3", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave3") end },
                        { label = "Wave", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave") end },
                        { label = "Wave 5", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave5") end },
                        { label = "Wave 6", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave6") end },
                        { label = "Wave 7", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave7") end },
                        { label = "Wave 8", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave8") end },
                        { label = "Wave 9", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote wave9") end },
                        { label = "Whistle", icon = "fas fa-bullhorn", action = function() ExecuteCommand("emote whistle") end },
                        { label = "Whistle 2", icon = "fas fa-bullhorn", action = function() ExecuteCommand("emote whistle2") end },
                        { label = "Yeah", icon = "fas fa-thumbs-up", action = function() ExecuteCommand("emote yeah") end },
                        { label = "Lift", icon = "fas fa-dumbbell", action = function() ExecuteCommand("emote lift") end },
                        { label = "LOL", icon = "fas fa-laugh-beam", action = function() ExecuteCommand("emote lol") end },
                        { label = "LOL 2", icon = "fas fa-laugh-beam", action = function() ExecuteCommand("emote lol2") end },
                        { label = "Statue 2", icon = "fas fa-user-ninja", action = function() ExecuteCommand("emote statue2") end },
                        { label = "Statue 3", icon = "fas fa-user-ninja", action = function() ExecuteCommand("emote statue3") end },
                        { label = "Gang Sign", icon = "fas fa-hand-spock", action = function() ExecuteCommand("emote gangsign") end },
                        { label = "Gang Sign 2", icon = "fas fa-hand-spock", action = function() ExecuteCommand("emote gangsign2") end },
                        { label = "Passout", icon = "fas fa-bed", action = function() ExecuteCommand("emote passout") end },
                        { label = "Passout 2", icon = "fas fa-bed", action = function() ExecuteCommand("emote passout2") end },
                        { label = "Passout 3", icon = "fas fa-bed", action = function() ExecuteCommand("emote passout3") end },
                        { label = "Passout 4", icon = "fas fa-bed", action = function() ExecuteCommand("emote passout4") end },
                        { label = "Passout 5", icon = "fas fa-bed", action = function() ExecuteCommand("emote passout5") end },
                        { label = "Petting", icon = "fas fa-dog", action = function() ExecuteCommand("emote petting") end },
                        { label = "Crawl", icon = "fas fa-child", action = function() ExecuteCommand("emote crawl") end },
                        { label = "Flip 2", icon = "fas fa-running", action = function() ExecuteCommand("emote flip2") end },
                        { label = "Flip", icon = "fas fa-running", action = function() ExecuteCommand("emote flip") end },
                        { label = "Slide", icon = "fas fa-running", action = function() ExecuteCommand("emote slide") end },
                        { label = "Slide 2", icon = "fas fa-running", action = function() ExecuteCommand("emote slide2") end },
                        { label = "Slide 3", icon = "fas fa-running", action = function() ExecuteCommand("emote slide3") end },
                        { label = "Slugger", icon = "fas fa-baseball-ball", action = function() ExecuteCommand("emote slugger") end },
                        { label = "Flip Off", icon = "fas fa-hand-middle-finger", action = function() ExecuteCommand("emote flipoff") end },
                        { label = "Flip Off 2", icon = "fas fa-hand-middle-finger", action = function() ExecuteCommand("emote flipoff2") end },
                        { label = "Bow", icon = "fas fa-pray", action = function() ExecuteCommand("emote bow") end },
                        { label = "Bow 2", icon = "fas fa-pray", action = function() ExecuteCommand("emote bow2") end },
                        { label = "Key Fob", icon = "fas fa-key", action = function() ExecuteCommand("emote keyfob") end },
                        { label = "Golf Swing", icon = "fas fa-golf-ball", action = function() ExecuteCommand("emote golfswing") end },
                        { label = "Eat", icon = "fas fa-utensils", action = function() ExecuteCommand("emote eat") end },
                        { label = "Reaching", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote reaching") end },
                        { label = "Wait", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait") end },
                        { label = "Wait 2", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait2") end },
                        { label = "Wait 12", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait12") end },
                        { label = "Wait 13", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote wait13") end },
                        { label = "Lapdance 2", icon = "fas fa-chair", action = function() ExecuteCommand("emote lapdance2") end },
                        { label = "Lapdance 3", icon = "fas fa-chair", action = function() ExecuteCommand("emote lapdance3") end },
                        { label = "Twerk", icon = "fas fa-female", action = function() ExecuteCommand("emote twerk") end },
                        { label = "Slap", icon = "fas fa-hand-paper", action = function() ExecuteCommand("emote slap") end },
                        { label = "Headbutt", icon = "fas fa-user-injured", action = function() ExecuteCommand("emote headbutt") end },
                        { label = "Fish Dance", icon = "fas fa-fish", action = function() ExecuteCommand("emote fishdance") end },
                        { label = "Peace", icon = "fas fa-hand-peace", action = function() ExecuteCommand("emote peace") end },
                        { label = "Peace 2", icon = "fas fa-hand-peace", action = function() ExecuteCommand("emote peace2") end },
                        { label = "CPR", icon = "fas fa-heartbeat", action = function() ExecuteCommand("emote cpr") end },
                        { label = "CPR 2", icon = "fas fa-heartbeat", action = function() ExecuteCommand("emote cpr2") end },
                        { label = "Ledge", icon = "fas fa-user-ninja", action = function() ExecuteCommand("emote ledge") end },
                        { label = "Air Plane", icon = "fas fa-plane", action = function() ExecuteCommand("emote airplane") end },
                        { label = "Peek", icon = "fas fa-eye", action = function() ExecuteCommand("emote peek") end },
                        { label = "Cough", icon = "fas fa-head-side-cough", action = function() ExecuteCommand("emote cough") end },
                        { label = "Stretch", icon = "fas fa-running", action = function() ExecuteCommand("emote stretch") end },
                        { label = "Stretch 2", icon = "fas fa-running", action = function() ExecuteCommand("emote stretch2") end },
                        { label = "Stretch 3", icon = "fas fa-running", action = function() ExecuteCommand("emote stretch3") end },
                        { label = "Stretch 4", icon = "fas fa-running", action = function() ExecuteCommand("emote stretch4") end },
                        { label = "Celebrate", icon = "fas fa-glass-cheers", action = function() ExecuteCommand("emote celebrate") end },
                        { label = "Punching", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote punching") end },
                        { label = "Superhero", icon = "fas fa-user-ninja", action = function() ExecuteCommand("emote superhero") end },
                        { label = "Superhero 2", icon = "fas fa-user-ninja", action = function() ExecuteCommand("emote superhero2") end },
                        { label = "Mind Control", icon = "fas fa-brain", action = function() ExecuteCommand("emote mindcontrol") end },
                        { label = "Mind Control 2", icon = "fas fa-brain", action = function() ExecuteCommand("emote mindcontrol2") end },
                        { label = "Clown", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote clown") end },
                        { label = "Clown 2", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote clown2") end },
                        { label = "Clown 3", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote clown3") end },
                        { label = "Clown 4", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote clown4") end },
                        { label = "Clown 5", icon = "fas fa-grin-squint-tears", action = function() ExecuteCommand("emote clown5") end },
                        { label = "Try Clothes", icon = "fas fa-tshirt", action = function() ExecuteCommand("emote tryclothes") end },
                        { label = "Try Clothes 2", icon = "fas fa-tshirt", action = function() ExecuteCommand("emote tryclothes2") end },
                        { label = "Try Clothes 3", icon = "fas fa-tshirt", action = function() ExecuteCommand("emote tryclothes3") end },
                        { label = "Nervous 2", icon = "fas fa-flushed", action = function() ExecuteCommand("emote nervous2") end },
                        { label = "Nervous", icon = "fas fa-flushed", action = function() ExecuteCommand("emote nervous") end },
                        { label = "Nervous 3", icon = "fas fa-flushed", action = function() ExecuteCommand("emote nervous3") end },
                        { label = "Uncuff", icon = "fas fa-handcuffs", action = function() ExecuteCommand("emote uncuff") end },
                        { label = "Namaste", icon = "fas fa-pray", action = function() ExecuteCommand("emote namaste") end },
                        { label = "DJ", icon = "fas fa-music", action = function() ExecuteCommand("emote dj") end },
                        { label = "Threaten", icon = "fas fa-angry", action = function() ExecuteCommand("emote threaten") end },
                        { label = "Radio", icon = "fas fa-broadcast-tower", action = function() ExecuteCommand("emote radio") end },
                        { label = "Pull", icon = "fas fa-hand-rock", action = function() ExecuteCommand("emote pull") end },
                        { label = "Bird", icon = "fas fa-dove", action = function() ExecuteCommand("emote bird") end },
                        { label = "Chicken", icon = "fas fa-drumstick-bite", action = function() ExecuteCommand("emote chicken") end },
                        { label = "Bark", icon = "fas fa-dog", action = function() ExecuteCommand("emote bark") end },
                        { label = "Rabbit", icon = "fas fa-carrot", action = function() ExecuteCommand("emote rabbit") end },
                        { label = "Spider-Man", icon = "fab fa-spider", action = function() ExecuteCommand("emote spiderman") end },
                        { label = "BOI", icon = "fas fa-child", action = function() ExecuteCommand("emote boi") end },
                        { label = "Adjust", icon = "fas fa-user-tie", action = function() ExecuteCommand("emote adjust") end },
                        { label = "Hands Up", icon = "fas fa-hands", action = function() ExecuteCommand("emote handsup") end },
                        { label = "Pee", icon = "fas fa-toilet", action = function() ExecuteCommand("emote pee") end },
                        { label = "Karate", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote karate") end },
                        { label = "Karate 2", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote karate2") end },
                        { label = "Cut Throat", icon = "fas fa-hand-middle-finger", action = function() ExecuteCommand("emote cutthroat") end },
                        { label = "Cut Throat 2", icon = "fas fa-hand-middle-finger", action = function() ExecuteCommand("emote cutthroat2") end },
                        { label = "Mind Blown", icon = "fas fa-brain", action = function() ExecuteCommand("emote mindblown") end },
                        { label = "Mind Blown 2", icon = "fas fa-brain", action = function() ExecuteCommand("emote mindblown2") end },
                        { label = "Boxing", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote boxing") end },
                        { label = "Boxing 2", icon = "fas fa-fist-raised", action = function() ExecuteCommand("emote boxing2") end },
                        { label = "Stink", icon = "fas fa-poo", action = function() ExecuteCommand("emote stink") end },
                        { label = "Think 4", icon = "fas fa-brain", action = function() ExecuteCommand("emote think4") end },
                        { label = "Adjust Tie", icon = "fas fa-user-tie", action = function() ExecuteCommand("emote adjusttie") end },
                    }
                },
                {
                    label = "Prop Emotes",
                    icon = "fas fa-couch",
                    options = {
                        { label = "Umbrella", icon = "fas fa-umbrella", action = function() ExecuteCommand("emote umbrella") end },
                        { label = "Notepad", icon = "fas fa-clipboard", action = function() ExecuteCommand("emote notepad") end },
                        { label = "Box", icon = "fas fa-box", action = function() ExecuteCommand("emote box") end },
                        { label = "Rose", icon = "fas fa-fan", action = function() ExecuteCommand("emote rose") end },
                        { label = "Smoke 2", icon = "fas fa-smoking", action = function() ExecuteCommand("emote smoke2") end },
                        { label = "Smoke 3", icon = "fas fa-smoking", action = function() ExecuteCommand("emote smoke3") end },
                        { label = "Smoke 4", icon = "fas fa-smoking", action = function() ExecuteCommand("emote smoke4") end },
                        { label = "Bong", icon = "fas fa-bong", action = function() ExecuteCommand("emote bong") end },
                        { label = "Suitcase", icon = "fas fa-suitcase", action = function() ExecuteCommand("emote suitcase") end },
                        { label = "Suitcase 2", icon = "fas fa-suitcase", action = function() ExecuteCommand("emote suitcase2") end },
                        { label = "Mugshot", icon = "fas fa-id-card", action = function() ExecuteCommand("emote mugshot") end },
                        { label = "Coffee", icon = "fas fa-coffee", action = function() ExecuteCommand("emote coffee") end },
                        { label = "Whiskey", icon = "fas fa-glass-whiskey", action = function() ExecuteCommand("emote whiskey") end },
                        { label = "Beer", icon = "fas fa-beer", action = function() ExecuteCommand("emote beer") end },
                        { label = "Cup", icon = "fas fa-mug-hot", action = function() ExecuteCommand("emote cup") end },
                        { label = "Donut", icon = "fas fa-doughnut", action = function() ExecuteCommand("emote donut") end },
                        { label = "Burger", icon = "fas fa-hamburger", action = function() ExecuteCommand("emote burger") end },
                        { label = "Sandwich", icon = "fas fa-bread-slice", action = function() ExecuteCommand("emote sandwich") end },
                        { label = "Soda", icon = "fas fa-cocktail", action = function() ExecuteCommand("emote soda") end },
                        { label = "Ego Bar", icon = "fas fa-candy-cane", action = function() ExecuteCommand("emote egobar") end },
                        { label = "Wine", icon = "fas fa-wine-glass", action = function() ExecuteCommand("emote wine") end },
                        { label = "Flute", icon = "fas fa-music", action = function() ExecuteCommand("emote flute") end },
                        { label = "Champagne", icon = "fas fa-wine-bottle", action = function() ExecuteCommand("emote champagne") end },
                        { label = "Cigar", icon = "fas fa-smoking", action = function() ExecuteCommand("emote cigar") end },
                        { label = "Cigar 2", icon = "fas fa-smoking", action = function() ExecuteCommand("emote cigar2") end },
                        { label = "Guitar", icon = "fas fa-guitar", action = function() ExecuteCommand("emote guitar") end },
                        { label = "Guitar 2", icon = "fas fa-guitar", action = function() ExecuteCommand("emote guitar2") end },
                        { label = "Guitar Electric", icon = "fas fa-guitar", action = function() ExecuteCommand("emote guitarelectric") end },
                        { label = "Guitar Electric 2", icon = "fas fa-guitar", action = function() ExecuteCommand("emote guitarelectric2") end },
                        { label = "Book", icon = "fas fa-book", action = function() ExecuteCommand("emote book") end },
                        { label = "Bouquet", icon = "fas fa-fan", action = function() ExecuteCommand("emote bouquet") end },
                        { label = "Teddy", icon = "fas fa-teddy-bear", action = function() ExecuteCommand("emote teddy") end },
                        { label = "Backpack", icon = "fas fa-suitcase-rolling", action = function() ExecuteCommand("emote backpack") end },
                        { label = "Clipboard", icon = "fas fa-clipboard", action = function() ExecuteCommand("emote clipboard") end },
                        { label = "Map", icon = "fas fa-map", action = function() ExecuteCommand("emote map") end },
                        { label = "Beg", icon = "fas fa-hand-holding-usd", action = function() ExecuteCommand("emote beg") end },
                        { label = "Make It Rain", icon = "fas fa-money-bill-wave", action = function() ExecuteCommand("emote makeitrain") end },
                        { label = "Camera", icon = "fas fa-camera", action = function() ExecuteCommand("emote camera") end },
                        { label = "Champagne Spray", icon = "fas fa-wine-bottle", action = function() ExecuteCommand("emote champagnespray") end },
                        { label = "Joint", icon = "fas fa-joint", action = function() ExecuteCommand("emote joint") end },
                        { label = "Cig", icon = "fas fa-smoking", action = function() ExecuteCommand("emote cig") end },
                        { label = "Brief 3", icon = "fas fa-briefcase", action = function() ExecuteCommand("emote brief3") end },
                    }
                },
                {
                    label = "Scenarios",
                    icon = "fas fa-street-view",
                    options = {
                        { label = "ATM", icon = "fas fa-credit-card", action = function() ExecuteCommand("emote atm") end },
                        { label = "BBQ", icon = "fas fa-drumstick-bite", action = function() ExecuteCommand("emote bbq") end },
                        { label = "Bum Bin", icon = "fas fa-trash-alt", action = function() ExecuteCommand("emote bumbin") end },
                        { label = "Bum Sleep", icon = "fas fa-bed", action = function() ExecuteCommand("emote bumsleep") end },
                        { label = "Cheer", icon = "fas fa-bullhorn", action = function() ExecuteCommand("emote cheer") end },
                        { label = "Chinup", icon = "fas fa-dumbbell", action = function() ExecuteCommand("emote chinup") end },
                        { label = "Clipboard 2", icon = "fas fa-clipboard", action = function() ExecuteCommand("emote clipboard2") end },
                        { label = "Cop", icon = "fas fa-user-secret", action = function() ExecuteCommand("emote cop") end },
                        { label = "Cop Beacon", icon = "fas fa-broadcast-tower", action = function() ExecuteCommand("emote copbeacon") end },
                        { label = "Film Shocking", icon = "fas fa-film", action = function() ExecuteCommand("emote filmshocking") end },
                        { label = "Flex", icon = "fas fa-dumbbell", action = function() ExecuteCommand("emote flex") end },
                        { label = "Guard", icon = "fas fa-user-shield", action = function() ExecuteCommand("emote guard") end },
                        { label = "Hammer", icon = "fas fa-hammer", action = function() ExecuteCommand("emote hammer") end },
                        { label = "Hangout", icon = "fas fa-user-friends", action = function() ExecuteCommand("emote hangout") end },
                        { label = "Impatient", icon = "fas fa-user-clock", action = function() ExecuteCommand("emote impatient") end },
                        { label = "Janitor", icon = "fas fa-broom", action = function() ExecuteCommand("emote janitor") end },
                        { label = "Jog", icon = "fas fa-running", action = function() ExecuteCommand("emote jog") end },
                        { label = "Kneel", icon = "fas fa-pray", action = function() ExecuteCommand("emote kneel") end },
                        { label = "Leafblower", icon = "fas fa-leaf", action = function() ExecuteCommand("emote leafblower") end },
                        { label = "Lean", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote lean") end },
                        { label = "Lean Bar", icon = "fas fa-user-alt-slash", action = function() ExecuteCommand("emote leanbar") end },
                        { label = "Lookout", icon = "fas fa-binoculars", action = function() ExecuteCommand("emote lookout") end },
                        { label = "Maid", icon = "fas fa-female", action = function() ExecuteCommand("emote maid") end },
                        { label = "Medic", icon = "fas fa-briefcase-medical", action = function() ExecuteCommand("emote medic") end },
                        { label = "Musician", icon = "fas fa-music", action = function() ExecuteCommand("emote musician") end },
                        { label = "Notepad 2", icon = "fas fa-clipboard", action = function() ExecuteCommand("emote notepad2") end },
                        { label = "Parking Meter", icon = "fas fa-parking", action = function() ExecuteCommand("emote parkingmeter") end },
                        { label = "Party", icon = "fas fa-glass-cheers", action = function() ExecuteCommand("emote party") end },
                        { label = "Texting", icon = "fas fa-mobile-alt", action = function() ExecuteCommand("emote texting") end },
                        { label = "Prostitue High", icon = "fas fa-female", action = function() ExecuteCommand("emote prosthigh") end },
                        { label = "Prostitue Low", icon = "fas fa-female", action = function() ExecuteCommand("emote prostlow") end },
                        { label = "Puddle", icon = "fas fa-tint", action = function() ExecuteCommand("emote puddle") end },
                        { label = "Record", icon = "fas fa-video", action = function() ExecuteCommand("emote record") end },
                        { label = "Sit Chair", icon = "fas fa-chair", action = function() ExecuteCommand("emote sitchair") end },
                        { label = "Smoke", icon = "fas fa-smoking", action = function() ExecuteCommand("emote smoke") end },
                        { label = "Smoke Weed", icon = "fas fa-joint", action = function() ExecuteCommand("emote smokeweed") end },
                        { label = "Statue", icon = "fas fa-user-ninja", action = function() ExecuteCommand("emote statue") end },
                        { label = "Sunbathe 3", icon = "fas fa-sun", action = "sunbathe3" },
                        { label = "Sunbathe Back", icon = "fas fa-sun", action = function() ExecuteCommand("emote sunbatheback") end },
                        { label = "Weld", icon = "fas fa-burn", action = function() ExecuteCommand("emote weld") end },
                        { label = "Window Shop", icon = "fas fa-store", action = function() ExecuteCommand("emote windowshop") end },
                        { label = "Yoga", icon = "fas fa-om", action = function() ExecuteCommand("emote yoga") end },
                    }
                }
            }
        },
        clothing = {
            enabled = true, -- Enable/disable this context menu
            label = 'Clothing Options', icon = 'fas fa-tshirt', color = '#9b59b6',
            canShow = function() return not IsPedInAnyVehicle(PlayerPedId(), false) end,
            options = {
                { label = 'Shirt', icon = 'fas fa-tshirt', action = function() ToggleClothing('shirt') end },
                { label = 'Pants', icon = 'fas fa-user-alt', action = function() ToggleClothing('pants') end },
                { label = 'Shoes', icon = 'fas fa-shoe-prints', action = function() ToggleClothing('shoes') end },
                { label = 'Gloves', icon = 'fas fa-mitten', action = function() ToggleClothing('gloves') end },
                { label = 'Bag', icon = 'fas fa-backpack', action = function() ToggleClothing('bag') end },
                { label = 'Vest', icon = 'fas fa-vest', action = function() ToggleClothing('vest') end },
                { label = 'Jewelry', icon = 'fas fa-gem', action = function() ToggleClothing('jewelry') end },
                { label = 'Mask', icon = 'fas fa-mask', action = function() ToggleClothing('mask') end },
                { label = 'Hat', icon = 'fas fa-hat-cowboy', action = function() ToggleProps('hat') end },
                { label = 'Glasses', icon = 'fas fa-glasses', action = function() ToggleProps('glasses') end },
                { label = 'Watch', icon = 'fas fa-clock', action = function() ToggleProps('watch') end },
                { label = 'Ear', icon = 'fas fa-ear-deaf', action = function() ToggleProps('ear') end },
            }
        }
    },

    -- ============================================================
    --  [4] ADVANCED & DEBUG
    -- ============================================================
    Debug = false,

    -- ============================================================
    --  [5] DATA TABLES (Populated by exports)
    -- ============================================================
    Peds = {},
    CircleZones = {},
    BoxZones = {},
    PolyZones = {},
    TargetBones = {},
    TargetModels = {},
    GlobalPedOptions = {},
    GlobalVehicleOptions = {},
    GlobalObjectOptions = {},
    GlobalPlayerOptions = {},
}
