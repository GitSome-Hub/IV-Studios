-- ============================================================
--  INTERACTIVE PROPS SERVER MODULE
-- ============================================================
-- Server-side handling for prop interactions, logging, and persistence

-- Module configuration
local ModuleEnabled = true

-- Don't run if module is disabled
if not ModuleEnabled then
    return
end

-- Configuration
local Config = {
    LogPropInteractions = true,  -- Log prop interactions to console
    MaxPropsPerPlayer = 10,      -- Maximum props a player can have moved at once
    PropCleanupTime = 300000,    -- Time in ms before moved props are cleaned up (5 minutes)
}

-- State tracking
local playerMovedProps = {}  -- Track props moved by each player
local propTimers = {}        -- Cleanup timers for moved props

-- Helper function to get player identifier
local function GetPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in pairs(identifiers) do
        if string.find(id, "license:") then
            return id
        end
    end
    return "unknown"
end

-- Function to log prop interactions
local function LogPropInteraction(source, action, propModel, coords)
    if not Config.LogPropInteractions then return end
    
    local playerName = GetPlayerName(source)
    local identifier = GetPlayerIdentifier(source)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    
    if Config.Debug then
        print(string.format("^3[Props Server]^7 [%s] %s (%s) %s prop %s at %s", 
            timestamp, playerName, identifier, action, propModel, coords))
    end
end

-- Function to clean up old moved props
local function CleanupMovedProps(playerId)
    if not playerMovedProps[playerId] then return end
    
    local cleaned = 0
    for i = #playerMovedProps[playerId], 1, -1 do
        local propData = playerMovedProps[playerId][i]
        if propData and propData.entity and DoesEntityExist(propData.entity) then
            -- Return prop to original position
            SetEntityCoords(propData.entity, propData.originalCoords.x, propData.originalCoords.y, propData.originalCoords.z)
            table.remove(playerMovedProps[playerId], i)
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        if Config.Debug then print(string.format("^2[Props Server]^7 Cleaned up %d props for player %s", cleaned, playerId)) end
    end
end

-- Event handlers for prop interactions
RegisterNetEvent('props:server:logInteraction', function(action, propModel, coords)
    local source = source
    LogPropInteraction(source, action, propModel, vector3(coords.x, coords.y, coords.z))
end)

RegisterNetEvent('props:server:trackMovedProp', function(propEntity, originalCoords)
    local source = source
    local playerId = GetPlayerIdentifier(source)
    
    if not playerMovedProps[playerId] then
        playerMovedProps[playerId] = {}
    end
    
    -- Check if player has reached max props limit
    if #playerMovedProps[playerId] >= Config.MaxPropsPerPlayer then
        -- Remove oldest prop tracking
        table.remove(playerMovedProps[playerId], 1)
    end
    
    -- Add new prop to tracking
    table.insert(playerMovedProps[playerId], {
        entity = propEntity,
        originalCoords = originalCoords,
        timestamp = GetGameTimer()
    })
    
    -- Set cleanup timer
    if propTimers[propEntity] then
        ClearTimeout(propTimers[propEntity])
    end
    
    propTimers[propEntity] = SetTimeout(Config.PropCleanupTime, function()
        -- Find and remove this prop from tracking
        for playerId, props in pairs(playerMovedProps) do
            for i, propData in ipairs(props) do
                if propData.entity == propEntity then
                    if DoesEntityExist(propEntity) then
                        SetEntityCoords(propEntity, propData.originalCoords.x, propData.originalCoords.y, propData.originalCoords.z)
                    end
                    table.remove(props, i)
                    break
                end
            end
        end
        propTimers[propEntity] = nil
    end)
end)

RegisterNetEvent('props:server:stopTrackingProp', function(propEntity)
    local source = source
    local playerId = GetPlayerIdentifier(source)
    
    if not playerMovedProps[playerId] then return end
    
    -- Remove prop from tracking
    for i, propData in ipairs(playerMovedProps[playerId]) do
        if propData.entity == propEntity then
            table.remove(playerMovedProps[playerId], i)
            break
        end
    end
    
    -- Clear cleanup timer
    if propTimers[propEntity] then
        ClearTimeout(propTimers[propEntity])
        propTimers[propEntity] = nil
    end
end)

-- Clean up props when player disconnects
AddEventHandler('playerDropped', function(reason)
    local source = source
    local playerId = GetPlayerIdentifier(source)
    
    if playerMovedProps[playerId] then
        CleanupMovedProps(playerId)
        playerMovedProps[playerId] = nil
    end
end)

-- Admin command to clean up all moved props
RegisterCommand('cleanupprops', function(source, args, rawCommand)
    if source == 0 then -- Console command
        local totalCleaned = 0
        for playerId, _ in pairs(playerMovedProps) do
            local beforeCount = playerMovedProps[playerId] and #playerMovedProps[playerId] or 0
            CleanupMovedProps(playerId)
            totalCleaned = totalCleaned + beforeCount
        end
        if Config.Debug then print(string.format("^2[Props Server]^7 Cleaned up %d total moved props", totalCleaned)) end
    else
        -- Check if player has admin permissions (implement your own permission check)
        local hasPermission = true -- Replace with your permission system
        
        if hasPermission then
            local totalCleaned = 0
            for playerId, _ in pairs(playerMovedProps) do
                local beforeCount = playerMovedProps[playerId] and #playerMovedProps[playerId] or 0
                CleanupMovedProps(playerId)
                totalCleaned = totalCleaned + beforeCount
            end
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Props System", string.format("Cleaned up %d moved props", totalCleaned)}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Props System", "You don't have permission to use this command"}
            })
        end
    end
end, false)

-- Command to check prop statistics
RegisterCommand('propstats', function(source, args, rawCommand)
    if source == 0 then -- Console command
        local totalProps = 0
        local totalPlayers = 0
        
        for playerId, props in pairs(playerMovedProps) do
            if props and #props > 0 then
                totalPlayers = totalPlayers + 1
                totalProps = totalProps + #props
                if Config.Debug then print(string.format("^3[Props Server]^7 Player %s has %d moved props", playerId, #props)) end
            end
        end
        
        if Config.Debug then print(string.format("^2[Props Server]^7 Total: %d players with %d moved props", totalPlayers, totalProps)) end
    else
        local hasPermission = true -- Replace with your permission system
        
        if hasPermission then
            local totalProps = 0
            local totalPlayers = 0
            
            for playerId, props in pairs(playerMovedProps) do
                if props and #props > 0 then
                    totalPlayers = totalPlayers + 1
                    totalProps = totalProps + #props
                end
            end
            
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 255},
                multiline = true,
                args = {"Props System", string.format("Stats: %d players with %d total moved props", totalPlayers, totalProps)}
            })
        end
    end
end, false)

-- Periodic cleanup check (every 5 minutes)
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        
        local currentTime = GetGameTimer()
        local cleaned = 0
        
        for playerId, props in pairs(playerMovedProps) do
            if props then
                for i = #props, 1, -1 do
                    local propData = props[i]
                    if propData and (currentTime - propData.timestamp) > Config.PropCleanupTime then
                        if DoesEntityExist(propData.entity) then
                            SetEntityCoords(propData.entity, propData.originalCoords.x, propData.originalCoords.y, propData.originalCoords.z)
                        end
                        table.remove(props, i)
                        cleaned = cleaned + 1
                    end
                end
            end
        end
        
        if cleaned > 0 then
            if Config.Debug then print(string.format("^2[Props Server]^7 Periodic cleanup: removed %d old moved props", cleaned)) end
        end
    end
end)

if Config.Debug then print("^2[Props Server]^7 Module " .. (ModuleEnabled and "Enabled" or "Disabled")) end