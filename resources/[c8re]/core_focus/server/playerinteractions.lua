-- ============================================================
--  PLAYER INTERACTIONS SERVER
-- ============================================================
-- Server-side handling for player interactions
-- Handles escort, carry, vehicle interactions

-- State management
local escortPairs = {} -- [escorter] = target
local carryPairs = {} -- [carrier] = target

-- Helper function to check if player has required job
local function HasRequiredJob(source, jobName)
    -- Add your job check logic here based on your framework
    
    -- Example for QB-Core
    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and Player.PlayerData.job.name == jobName then
            return true
        end
    end
    
    -- Example for ESX
    if GetResourceState('es_extended') == 'started' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.job.name == jobName then
            return true
        end
    end
    
    -- Fallback - return true for testing (CHANGE THIS IN PRODUCTION!)
    return true
end

-- Toggle Escort Event
RegisterNetEvent('playerinteractions:toggleEscort', function(targetId)
    local source = source
    
    -- Validate target player
    if not targetId or GetPlayerName(targetId) == nil then
        return
    end
    
    -- Check if already escorting this target
    if escortPairs[source] == targetId then
        -- Stop escorting
        escortPairs[source] = nil
        TriggerClientEvent('playerinteractions:stopEscort', source)
        TriggerClientEvent('playerinteractions:stopEscort', targetId)
        
        if Config.Debug then print('^2[Player Interactions]^7 ' .. GetPlayerName(source) .. ' stopped escorting ' .. GetPlayerName(targetId)) end
    else
        -- Start escorting
        escortPairs[source] = targetId
        TriggerClientEvent('playerinteractions:startEscort', source, targetId)
        
        if Config.Debug then print('^2[Player Interactions]^7 ' .. GetPlayerName(source) .. ' started escorting ' .. GetPlayerName(targetId)) end
    end
end)

-- Toggle Carry Event
RegisterNetEvent('playerinteractions:toggleCarry', function(targetId)
    local source = source
    
    -- Validate target player
    if not targetId or GetPlayerName(targetId) == nil then
        return
    end
    
    -- Check if already carrying this target
    if carryPairs[source] == targetId then
        -- Stop carrying
        carryPairs[source] = nil
        TriggerClientEvent('playerinteractions:stopCarry', source)
        TriggerClientEvent('playerinteractions:stopCarry', targetId)
        
        if Config.Debug then print('^2[Player Interactions]^7 ' .. GetPlayerName(source) .. ' stopped carrying ' .. GetPlayerName(targetId)) end
    else
        -- Start carrying
        carryPairs[source] = targetId
        TriggerClientEvent('playerinteractions:startCarry', source, targetId)
        
        if Config.Debug then print('^2[Player Interactions]^7 ' .. GetPlayerName(source) .. ' started carrying ' .. GetPlayerName(targetId)) end
    end
end)

-- Put in Vehicle Event
RegisterNetEvent('playerinteractions:putInVehicle', function(targetId)
    local source = source
    
    -- Validate target player
    if not targetId or GetPlayerName(targetId) == nil then
        return
    end
    
    -- Trigger client event to put target in nearest vehicle
    TriggerClientEvent('playerinteractions:putInNearestVehicle', targetId)
    
    if Config.Debug then print('^2[Player Interactions]^7 ' .. GetPlayerName(source) .. ' put ' .. GetPlayerName(targetId) .. ' in vehicle') end
end)

-- Take Out of Vehicle Event
RegisterNetEvent('playerinteractions:takeOutVehicle', function(targetId)
    local source = source
    
    -- Validate target player
    if not targetId or GetPlayerName(targetId) == nil then
        return
    end
    
    -- Trigger client event to take target out of vehicle
    TriggerClientEvent('playerinteractions:takeOutOfVehicle', targetId)
    
    if Config.Debug then print('^2[Player Interactions]^7 ' .. GetPlayerName(source) .. ' took ' .. GetPlayerName(targetId) .. ' out of vehicle') end
end)

-- Clean up when players disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    -- Clean up escort pairs
    if escortPairs[source] then
        local targetId = escortPairs[source]
        escortPairs[source] = nil
        if GetPlayerName(targetId) then
            TriggerClientEvent('playerinteractions:stopEscort', targetId)
        end
    end
    
    -- Clean up carry pairs
    if carryPairs[source] then
        local targetId = carryPairs[source]
        carryPairs[source] = nil
        if GetPlayerName(targetId) then
            TriggerClientEvent('playerinteractions:stopCarry', targetId)
        end
    end
    
    -- Check if this player was being escorted/carried by someone
    for escorter, target in pairs(escortPairs) do
        if target == source then
            escortPairs[escorter] = nil
            if GetPlayerName(escorter) then
                TriggerClientEvent('playerinteractions:stopEscort', escorter)
            end
        end
    end
    
    for carrier, target in pairs(carryPairs) do
        if target == source then
            carryPairs[carrier] = nil
            if GetPlayerName(carrier) then
                TriggerClientEvent('playerinteractions:stopCarry', carrier)
            end
        end
    end
end)

if Config.Debug then print('^2[Player Interactions]^7 Server module loaded') end