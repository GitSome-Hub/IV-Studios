-- ============================================================
--  AUGMENTED WINDOW - VEHICLE INFORMATION MODULE
-- ============================================================
-- This module displays vehicle information using augmented windows
-- when you're near vehicles (within 3 meters)

-- Module configuration
local ModuleEnabled = true

-- Don't run if module is disabled
if not ModuleEnabled then
    return
end

-- Configuration
local Config = {
    UpdateInterval = 3000,  -- Update every 3 seconds
    MaxDistance = 3.0,      -- Maximum distance to show vehicle info (meters)
    WindowDistance = 10.0,  -- Distance at which windows are visible
    WindowLength = 2.5,    -- Window length
    WindowHeight = 1.0,     -- Window height
    WindowColor = "#00AAFF", -- Window color (blue)
    WindowStyle = "default" -- Window style
}

-- Helper function to get vehicle information
local function GetVehicleInfo(vehicle)
    if not DoesEntityExist(vehicle) then
        return nil
    end
    
    local engineHealth = GetVehicleEngineHealth(vehicle)
    local bodyHealth = GetVehicleBodyHealth(vehicle)
    local fuelLevel = GetVehicleFuelLevel(vehicle)
    local isLocked = GetVehicleDoorLockStatus(vehicle) ~= 0
    local model = GetEntityModel(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local engineOn = GetIsVehicleEngineRunning(vehicle)
    
    return {
        ["Plate"] = plate,
        ["Engine Health"] = math.floor(engineHealth / 10) .. "%",
        ["Body Health"] = math.floor(bodyHealth / 10) .. "%",
        ["Fuel Level"] = math.floor(fuelLevel) .. "%",
        ["Engine"] = engineOn and "Running" or "Off",
        ["Status"] = isLocked and "Locked" or "Unlocked"
    }
end

-- Main thread to handle vehicle detection and window creation
CreateThread(function()
    while ModuleEnabled do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        Wait(Config.UpdateInterval)

        
        -- Get all vehicles from game pool
        local vehicles = GetGamePool('CVehicle')
        
        -- Check each vehicle for proximity and create windows
        for _, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) then
                local vehicleCoords = GetEntityCoords(vehicle)
                local distance = #(playerCoords - vehicleCoords)
                
                if distance <= Config.MaxDistance then
                    local vehicleInfo = GetVehicleInfo(vehicle)
                    if vehicleInfo then
                        -- Just add the window - system will handle duplicates
                        exports[GetCurrentResourceName()]:AddAugmentedWindowEntity(
                            "Vehicle Information",
                            vehicle,
                            Config.WindowLength,
                            Config.WindowHeight,
                            Config.WindowColor,
                            Config.WindowStyle,
                            vehicleInfo,
                            Config.WindowDistance
                        )
                    end
                end
            end
        end


    end
end)

-- Command to toggle the module (for testing)
RegisterCommand('togglevehiclewindows', function()
    ModuleEnabled = not ModuleEnabled
    if _G.Config and _G.Config.Debug then
        print("Vehicle Augmented Windows: " .. (ModuleEnabled and "Enabled" or "Disabled"))
    end
end, false)

if _G.Config and _G.Config.Debug then
    print("^2[Augmented Windows]^7 Vehicle Information Module " .. (ModuleEnabled and "Enabled" or "Disabled"))
end