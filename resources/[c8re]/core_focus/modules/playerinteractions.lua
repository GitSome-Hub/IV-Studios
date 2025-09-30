-- ============================================================
--  PLAYER INTERACTIONS MODULE
-- ============================================================
-- This module provides qb-target style interactions for EMS, Police, and Mechanic jobs
-- to escort, carry, take out of car, and other movement actions

-- Module configuration
local ModuleEnabled = true

-- Don't run if module is disabled
if not ModuleEnabled then
    return
end

-- Configuration
local Config = {
    MaxDistance = 3.0,      -- Maximum distance to show interactions (meters)
    ForceColor = "#FF6B35", -- Force color for all player interactions (orange)
}

-- State management for interactions
local isEscorting = false
local escortTarget = nil

-- Helper function to get framework-specific EMS interactions
local function GetEMSInteractions()
    if Config.Framework == 'qb-core' then
        return {
            {
                label = "Check Health Status",
                icon = "fas fa-heart-pulse",
                job = "ambulance",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('hospital:client:CheckStatus', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Revive",
                icon = "fas fa-user-doctor",
                job = "ambulance",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('hospital:client:RevivePlayer', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Heal Wounds",
                icon = "fas fa-bandage",
                job = "ambulance",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('hospital:client:TreatWounds', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Escort",
                icon = "fas fa-user-group",
                job = "ambulance",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('police:client:EscortPlayer', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return not IsPedInAnyVehicle(entity, false)
                end
            }
        }
    elseif Config.Framework == 'esx' then
        return {
            {
                label = "Revive Player",
                icon = "fas fa-user-doctor",
                job = "ambulance",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerServerEvent('esx_ambulancejob:revive', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Heal Player",
                icon = "fas fa-bandage",
                job = "ambulance",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerServerEvent('esx_ambulancejob:heal', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Put in Vehicle",
                icon = "fas fa-car",
                job = "ambulance",
                action = function(data)
                    local targetPed = data
                    TriggerServerEvent('playerinteractions:putInVehicle', GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed)))
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return not IsPedInAnyVehicle(entity, false)
                end
            },
            {
                label = "Take Out of Vehicle",
                icon = "fas fa-car-side",
                job = "ambulance",
                action = function(data)
                    local targetPed = data
                    TriggerServerEvent('playerinteractions:takeOutVehicle', GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed)))
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return IsPedInAnyVehicle(entity, false)
                end
            }
        }
    else
        -- Standalone or unknown framework - return empty table
        return {}
    end
end

-- Helper function to get framework-specific police interactions
local function GetPoliceInteractions()
    if Config.Framework == 'qb-core' then
        return {
            {
                label = "Check Health Status",
                icon = "fas fa-heart-pulse",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('hospital:client:CheckStatus', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Check Status",
                icon = "fas fa-question",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('police:client:CheckStatus', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Escort",
                icon = "fas fa-user-group",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('police:client:EscortPlayer', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return not IsPedInAnyVehicle(entity, false)
                end
            },
            {
                label = "Search",
                icon = "fas fa-magnifying-glass",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerServerEvent('police:server:SearchPlayer', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return not IsPedInAnyVehicle(entity, false)
                end
            },
            {
                label = "Jail",
                icon = "fas fa-user-lock",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('police:client:JailPlayer', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            }
        }
    elseif Config.Framework == 'esx' then
        return {
            {
                label = "ID Card",
                icon = "fas fa-id-card",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    -- ESX police job function for identity card
                    TriggerEvent('esx_policejob:OpenIdentityCardMenu', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Search",
                icon = "fas fa-magnifying-glass",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    -- ESX police job function for body search
                    TriggerEvent('esx_policejob:OpenBodySearchMenu', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return not IsPedInAnyVehicle(entity, false)
                end
            },
            {
                label = "Handcuff",
                icon = "fas fa-handcuffs",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerServerEvent('esx_policejob:handcuff', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return not IsPedInAnyVehicle(entity, false)
                end
            },
            {
                label = "Drag",
                icon = "fas fa-user-group",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerServerEvent('esx_policejob:drag', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return not IsPedInAnyVehicle(entity, false)
                end
            },
            {
                label = "Put in Vehicle",
                icon = "fas fa-car",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerServerEvent('esx_policejob:putInVehicle', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return not IsPedInAnyVehicle(entity, false)
                end
            },
            {
                label = "Take Out of Vehicle",
                icon = "fas fa-car-side",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerServerEvent('esx_policejob:OutVehicle', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return IsPedInAnyVehicle(entity, false)
                end
            },
            {
                label = "Fine",
                icon = "fas fa-file-invoice-dollar",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('esx_policejob:OpenFineMenu', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "License Check",
                icon = "fas fa-id-badge",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('esx_policejob:ShowPlayerLicense', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            },
            {
                label = "Unpaid Bills",
                icon = "fas fa-receipt",
                job = "police",
                action = function(data)
                    local targetPed = data
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
                    TriggerEvent('esx_policejob:OpenUnpaidBillsMenu', targetId)
                end,
                canInteract = function(entity, distance, data)
                    if entity == PlayerPedId() then return false end
                    return true
                end
            }
        }
    else
        -- Standalone or unknown framework - return empty table
        return {}
    end
end

-- Job-specific interactions configuration
local JobInteractions = {
    -- EMS Interactions (Framework-specific)
    ems = GetEMSInteractions(),
    
    -- Police Interactions (Framework-specific)
    police = GetPoliceInteractions(),
    
    -- Mechanic Interactions
    mechanic = {
        {
            label = "Escort Player",
            icon = "fas fa-hand-holding",
            job = "mechanic",
            action = function(data)
                local targetPed = data
                TriggerServerEvent('playerinteractions:toggleEscort', GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed)))
            end,
            canInteract = function(entity, distance, data)
                if entity == PlayerPedId() then return false end
                return not IsPedInAnyVehicle(entity, false)
            end
        },
        {
            label = "Help Out of Vehicle",
            icon = "fas fa-car-side",
            job = "mechanic",
            action = function(data)
                local targetPed = data
                TriggerServerEvent('playerinteractions:takeOutVehicle', GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed)))
            end,
            canInteract = function(entity, distance, data)
                if entity == PlayerPedId() then return false end
                return IsPedInAnyVehicle(entity, false)
            end
        },
        {
            label = "Vehicle Assistance",
            icon = "fas fa-wrench",
            job = "mechanic",
            action = function(data)
                -- FILLER: Replace with your mechanic system
                local messages = {
                    "Checking vehicle diagnostics...",
                    "Engine appears to be damaged",
                    "Vehicle needs professional repair",
                    "Minor mechanical issues detected",
                    "Vehicle is in good condition"
                }
                local randomMessage = messages[math.random(#messages)]
                

                print("^6[Mechanic]^7 " .. randomMessage)

                -- Example: QBCore.Functions.Notify(randomMessage, "primary")
                -- Example: ESX.ShowNotification(randomMessage)
            end,
            canInteract = function(entity, distance, data)
                if entity == PlayerPedId() then return false end
                return true
            end
        }
    }
}

-- Client-side event handlers for escort/carry functionality
RegisterNetEvent('playerinteractions:startEscort', function(targetId)
    if isEscorting then return end
    
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    if not targetPed or targetPed == 0 then return end
    
    isEscorting = true
    escortTarget = targetPed
    
    -- Attach the target to the player
    AttachEntityToEntity(targetPed, PlayerPedId(), 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    if _G.Config and _G.Config.Debug then
        print("^2[Player Interactions]^7 Started escorting player")
    end
end)

RegisterNetEvent('playerinteractions:stopEscort', function()
    if not isEscorting or not escortTarget then return end
    
    -- Detach the target
    DetachEntity(escortTarget, true, false)
    
    isEscorting = false
    escortTarget = nil
    
    if _G.Config and _G.Config.Debug then
        print("^2[Player Interactions]^7 Stopped escorting player")
    end
end)

RegisterNetEvent('playerinteractions:startCarry', function(targetId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    if not targetPed or targetPed == 0 then return end
    
    -- Carry animation and attachment
    local playerPed = PlayerPedId()
    
    -- Load carry animation
    RequestAnimDict("missfinale_c2mcs_1")
    while not HasAnimDictLoaded("missfinale_c2mcs_1") do
        Wait(10)
    end
    
    -- Play carry animation on both players
    TaskPlayAnim(playerPed, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 8.0, -8.0, -1, 49, 0, false, false, false)
    AttachEntityToEntity(targetPed, playerPed, 0, 0.27, 0.15, 0.63, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
    
    if _G.Config and _G.Config.Debug then
        print("^2[Player Interactions]^7 Started carrying player")
    end
end)

RegisterNetEvent('playerinteractions:stopCarry', function()
    local playerPed = PlayerPedId()
    
    -- Stop animation and detach
    ClearPedTasks(playerPed)
    DetachEntity(playerPed, true, false)
    
    if _G.Config and _G.Config.Debug then
        print("^2[Player Interactions]^7 Stopped carrying player")
    end
end)

RegisterNetEvent('playerinteractions:putInNearestVehicle', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Find nearest vehicle
    local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 10.0, 0, 71)
    
    if vehicle and vehicle ~= 0 then
        -- Find empty seat
        for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
            if IsVehicleSeatFree(vehicle, i) then
                TaskWarpPedIntoVehicle(playerPed, vehicle, i)
                if _G.Config and _G.Config.Debug then
                    print("^2[Player Interactions]^7 Put in vehicle")
                end
                return
            end
        end
        if _G.Config and _G.Config.Debug then
            print("^3[Player Interactions]^7 No empty seats in nearest vehicle")
        end
    else
        if _G.Config and _G.Config.Debug then
            print("^3[Player Interactions]^7 No vehicle nearby")
        end
    end
end)

RegisterNetEvent('playerinteractions:takeOutOfVehicle', function()
    local playerPed = PlayerPedId()
    
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local coords = GetEntityCoords(vehicle)
        
        TaskLeaveVehicle(playerPed, vehicle, 1)
        
        -- Wait a bit then set coords to avoid getting stuck
        Wait(1000)
        SetEntityCoords(playerPed, coords.x + 2.0, coords.y, coords.z, false, false, false, true)
        
        if _G.Config and _G.Config.Debug then
            print("^2[Player Interactions]^7 Taken out of vehicle")
        end
    end
end)

local function CreatePlayerOptions()
    local options = {}
    
    -- Add framework-specific EMS interactions
    local emsInteractions = GetEMSInteractions()
    for _, interaction in ipairs(emsInteractions) do
        table.insert(options, interaction)
    end
    
    -- Add framework-specific police interactions
    local policeInteractions = GetPoliceInteractions()
    for _, interaction in ipairs(policeInteractions) do
        table.insert(options, interaction)
    end
    
    -- Add mechanic interactions
    if JobInteractions.mechanic then
        for _, interaction in ipairs(JobInteractions.mechanic) do
            table.insert(options, interaction)
        end
    end
    
    return options
end

-- Initialize player interactions
CreateThread(function()
    Wait(1000) -- Wait for targeting system to load
    
    -- Create the player options
    local playerOptions = CreatePlayerOptions()
    
    -- Add global player targeting with all job interactions
    exports[GetCurrentResourceName()]:AddGlobalPlayer({
        options = playerOptions,
        distance = 3.0,
        forceColor = Config.ForceColor
    })
    
    if _G.Config and _G.Config.Debug then
        print("^2[Player Interactions]^7 Module loaded with " .. #playerOptions .. " interactions")
    end
end)

if _G.Config and _G.Config.Debug then
    print("^2[Player Interactions]^7 Module " .. (ModuleEnabled and "Enabled" or "Disabled"))
end