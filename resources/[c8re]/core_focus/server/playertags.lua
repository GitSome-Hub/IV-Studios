-- ============================================================
--  PLAYER TAGS SERVER
-- ============================================================
-- Server-side player name management for player tags
-- Handles firstname/lastname retrieval and distribution

local PlayerNamesCache = {}

-- ============================================================
--  FRAMEWORK INTEGRATION
-- ============================================================

local function GetPlayerFirstLastName(source)
    if not Config.PlayerTags.UseFirstLastName then
        return nil
    end
    
    if Config.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and Player.PlayerData.charinfo then
            local firstname = Player.PlayerData.charinfo.firstname or ""
            local lastname = Player.PlayerData.charinfo.lastname or ""
            return firstname .. " " .. lastname
        end
    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local firstname = xPlayer.get('firstName') or ""
            local lastname = xPlayer.get('lastName') or ""
            return firstname .. " " .. lastname
        end
    end
    
    return nil
end

-- ============================================================
--  CACHE MANAGEMENT
-- ============================================================

local function UpdatePlayerNameCache(source)
    local playerName = GetPlayerName(source)
    local firstLastName = GetPlayerFirstLastName(source)
    
    PlayerNamesCache[source] = {
        playerName = playerName,
        firstLastName = firstLastName
    }
    
    -- Broadcast to all clients
    TriggerClientEvent('playertags:updatePlayerName', -1, source, playerName, firstLastName)
end

local function RemovePlayerFromCache(source)
    if PlayerNamesCache[source] then
        PlayerNamesCache[source] = nil
        TriggerClientEvent('playertags:removePlayer', -1, source)
    end
end

-- ============================================================
--  EVENT HANDLERS
-- ============================================================

-- When a client requests all player names (on join)
RegisterNetEvent('playertags:requestAllNames', function()
    local source = source
    TriggerClientEvent('playertags:receiveAllNames', source, PlayerNamesCache)
end)

-- ============================================================
--  PLAYER EVENTS
-- ============================================================

AddEventHandler('playerJoining', function()
    local source = source
    UpdatePlayerNameCache(source)
end)

AddEventHandler('playerDropped', function()
    local source = source
    RemovePlayerFromCache(source)
end)

-- Update cache when character data changes (QB-Core)
if Config.Framework == 'qb-core' then
    RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
        local source = source
        UpdatePlayerNameCache(source)
    end)
    
    RegisterNetEvent('qb-multicharacter:server:loadUserData', function()
        local source = source
        Wait(1000) -- Wait for character data to load
        UpdatePlayerNameCache(source)
    end)
end

-- Update cache when character data changes (ESX)
if Config.Framework == 'esx' then
    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        local source = source
        UpdatePlayerNameCache(source)
    end)
end

-- ============================================================
--  INITIALIZATION
-- ============================================================

CreateThread(function()
    -- Wait for framework to load
    Wait(2000)
    
    -- Initialize cache for existing players
    for _, playerId in ipairs(GetPlayers()) do
        UpdatePlayerNameCache(tonumber(playerId))
    end
end)