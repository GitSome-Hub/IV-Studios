-- ============================================================
--  BENCHES MODULE
-- ============================================================
-- This module adds sitting interactions to all bench props
-- Players can sit on benches and play sitting animations

-- Module configuration
local ModuleEnabled = true

-- Don't run if module is disabled
if not ModuleEnabled then
    return
end

-- Configuration
local Config = {
    MaxDistance = 2.0,      -- Maximum distance to interact with benches (meters)
    ForceColor = "#f5ef42", -- Force color for bench interactions (yellow)
    SitOffset = vector3(0.0, -0.3, -0.5), -- Offset for sitting position (X=left/right, Y=forward/back, Z=up/down)
    SitHeading = 180.0,       -- Heading adjustment when sitting (0=same as bench, 90=perpendicular)
}

-- Sitting animation data
local SittingAnimations = {

    {
        dict = "amb@world_human_seat_wall@male@hands_by_sides@idle_a",
        anim = "idle_a",
        flag = 1,
        label = "Sit Normal"
    },
    {
        dict = "amb@world_human_seat_wall@female@hands_by_sides@idle_a",
        anim = "idle_a",
        flag = 1,
        label = "Sit Relaxed"
    }
}

-- Bench prop models
local BenchModels = {
    -- Standard benches
    `prop_bench_01a`,
    `prop_bench_01b`,
    `prop_bench_01c`,
    `prop_bench_02`,
    `prop_bench_03`,
    `prop_bench_04`,
    `prop_bench_05`,
    `prop_bench_06`,
    `prop_bench_07`,
    `prop_bench_08`,
    `prop_bench_09`,
    `prop_bench_10`,
    `prop_bench_11`,
    
    -- Park benches
    `prop_park_bench_01`,
    `prop_park_bench_02`,
    `prop_park_bench_03`,
    `prop_park_bench_04`,
    `prop_park_bench_05`,
    
    -- Wooden benches
    `prop_wood_bench_01`,
    `prop_wood_bench_02`,
    
    -- Metal benches
    `prop_metal_bench_01`,
    `prop_metal_bench_02`,
    
    -- Bus stop benches
    `prop_busstop_01`,
    `prop_busstop_02`,
    `prop_busstop_03`,
    `prop_busstop_04`,
    `prop_busstop_05`,
    
    -- Picnic tables (can sit on benches)
    `prop_picnictable_01`,
    `prop_picnictable_02`,
    
    -- Additional bench variants
    `hei_prop_heist_bench_01`,
    `v_res_tre_bench`,
    `v_serv_ct_chair02`,
    `prop_wait_bench_01`,
}
local isSitting = false
local currentBench = nil
local currentSitCoords = nil

-- Helper function to load animation dictionary
local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

-- Helper function to get sitting position on bench
local function GetSittingPosition(benchEntity)
    local benchHeading = GetEntityHeading(benchEntity)
    
    -- Use GetOffsetFromEntityInWorldCoords for proper positioning
    local sitCoords = GetOffsetFromEntityInWorldCoords(benchEntity, Config.SitOffset.x, Config.SitOffset.y, Config.SitOffset.z)
    
    -- Face the correct direction (same as bench + config adjustment)
    local sitHeading = benchHeading + Config.SitHeading
    
    return sitCoords, sitHeading
end

-- Function to start sitting animation
local function StartSitting(benchEntity, animData)
    if isSitting then return end
    
    local playerPed = PlayerPedId()
    local sitCoords, sitHeading = GetSittingPosition(benchEntity)
    
    if _G.Config and _G.Config.Debug then
        print("^3[Benches]^7 Attempting to sit at coords: " .. tostring(sitCoords))
    end
    
    -- Load animation dictionary
    LoadAnimDict(animData.dict)
    
    -- Clear any existing tasks
    ClearPedTasks(playerPed)
    
    -- Disable collision temporarily to allow proper positioning
    SetEntityCollision(playerPed, false, false)
    FreezeEntityPosition(playerPed, true)
    
    Wait(100)
    
    -- Set player position
    SetEntityCoords(playerPed, sitCoords.x, sitCoords.y, sitCoords.z, false, false, false, true)
    SetEntityHeading(playerPed, sitHeading)
    
    Wait(200)
    
    
    -- Play sitting animation with proper flags
    TaskPlayAnim(playerPed, animData.dict, animData.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Update state
    isSitting = true
    currentBench = benchEntity
    currentSitCoords = sitCoords
    
    if _G.Config and _G.Config.Debug then
        print("^2[Benches]^7 Started sitting on bench with animation: " .. animData.anim)
    end
end

-- Function to stop sitting
local function StopSitting()
    if not isSitting then return end
    
    local playerPed = PlayerPedId()
    
    -- Clear animation
    ClearPedTasks(playerPed)
    
    -- Ensure collision is enabled when standing up
    SetEntityCollision(playerPed, true, true)
    FreezeEntityPosition(playerPed, false)
    
    -- Reset state
    isSitting = false
    currentBench = nil
    currentSitCoords = nil
    
    if _G.Config and _G.Config.Debug then
        print("^2[Benches]^7 Stopped sitting")
    end
end

-- Create bench interactions
local function CreateBenchOptions()
    local options = {}
    
    -- Add sitting options for each animation
    for i, animData in ipairs(SittingAnimations) do
        table.insert(options, {
            label = animData.label,
            icon = "fas fa-chair",
            action = function(data)
                -- data is the entity directly, not a table
                local benchEntity = data
                StartSitting(benchEntity, animData)
            end,
            canInteract = function(entity, distance, data)
                -- Can only sit if not already sitting
                return not isSitting
            end
        })
    end
    
    -- Add stand up option
    table.insert(options, {
        label = "Stand Up",
        icon = "fas fa-walking",
        action = function(data)
            StopSitting()
        end,
        canInteract = function(entity, distance, data)
            -- Can only stand up if currently sitting on this bench
            return isSitting and currentBench == entity
        end
    })
    
   
    
    return options
end

-- Monitor sitting state
CreateThread(function()
    while true do
        Wait(1000)
        
        if isSitting and currentBench and currentSitCoords then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Check if player moved too far from sitting position
            local distance = #(playerCoords - currentSitCoords)
            if distance > 2.0 then
                StopSitting()
            end
            
            -- Check if bench still exists
            if not DoesEntityExist(currentBench) then
                StopSitting()
            end
        end
    end
end)

-- Handle player death/logout
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isSitting then
            StopSitting()
        end
    end
end)

-- Initialize bench interactions
CreateThread(function()
    Wait(1000) -- Wait for targeting system to load
    
    -- Create the bench options
    local benchOptions = CreateBenchOptions()
    
    -- Add targeting for each bench model
    for _, modelHash in ipairs(BenchModels) do
        exports[GetCurrentResourceName()]:AddTargetModel(modelHash, {
            options = benchOptions,
            distance = Config.MaxDistance,
            forceColor = Config.ForceColor
        })
    end
    
    if _G.Config and _G.Config.Debug then
        print("^2[Benches]^7 Module loaded with " .. #BenchModels .. " bench models and " .. #benchOptions .. " interactions")
    end
end)

-- Command to force stop sitting (for debugging)
RegisterCommand('stopsitting', function()
    if isSitting then
        StopSitting()
        if _G.Config and _G.Config.Debug then
            print("^2[Benches]^7 Force stopped sitting")
        end
    else
        if _G.Config and _G.Config.Debug then
            print("^3[Benches]^7 You are not sitting")
        end
    end
end, false)

if _G.Config and _G.Config.Debug then
    print("^2[Benches]^7 Module " .. (ModuleEnabled and "Enabled" or "Disabled"))
end