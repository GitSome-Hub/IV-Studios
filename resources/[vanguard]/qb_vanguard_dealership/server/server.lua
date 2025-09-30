local QBCore = exports['qb-core']:GetCoreObject()

-- Cache for Steam avatars
local steamAvatarCache = {}

-- Function to get Steam avatar URL
function GetSteamAvatarURL(steamId)
    if not steamId then return nil end
    
    if steamAvatarCache[steamId] then
        return steamAvatarCache[steamId]
    end
    
    local steamApiKey = GetConvar('steam_webApiKey', '')
    if steamApiKey == '' then return nil end
    
    local steam64 = tonumber(string.sub(steamId, 7), 16)
    if not steam64 then return nil end
    
    local apiUrl = string.format(
        'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s',
        steamApiKey,
        steam64
    )
    
    PerformHttpRequest(apiUrl, function(statusCode, responseText, headers)
        if statusCode == 200 then
            local response = json.decode(responseText)
            if response and response.response and response.response.players 
                and response.response.players[1] then
                local avatarUrl = response.response.players[1].avatarfull
                steamAvatarCache[steamId] = avatarUrl
            end
        end
    end, 'GET')
    
    return steamAvatarCache[steamId]
end

-- Handle vehicle purchase
RegisterServerEvent('dealership:purchaseVehicle')
AddEventHandler('dealership:purchaseVehicle', function(vehicleData)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    local price = vehicleData.price
    local cash = Player.PlayerData.money['cash']
    
    if cash >= price then
        Player.Functions.RemoveMoney('cash', price)
        
        local plate = 'PDM' .. math.random(100, 999)
        vehicleData.plate = plate
        
        -- Vanguard.notifyserver(source, "Success", Config.UI.notifications.purchaseSuccess, 3000, "info")
        TriggerClientEvent('dealership:purchaseResponse', source, true, Config.UI.notifications.purchaseSuccess, vehicleData)
        TriggerClientEvent('dealership:setPlayerMoney', source, Player.PlayerData.money['cash'])
    else
        -- Vanguard.notifyserver(source, "Error", Config.UI.notifications.purchaseFailed, 3000, "error")
        TriggerClientEvent('dealership:purchaseResponse', source, false, Config.UI.notifications.purchaseFailed)
    end
end)

-- Set vehicle as owned
RegisterServerEvent('dealership:setVehicleOwned')
AddEventHandler('dealership:setVehicleOwned', function(vehicleProps)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
    {
        Player.PlayerData.license,
        Player.PlayerData.citizenid,
        vehicleProps.model,
        GetHashKey(vehicleProps.model),
        json.encode(vehicleProps),
        vehicleProps.plate,
        1
    }, function(id)
        if id then
            print(('[dealership] Vehicle %s stored for %s'):format(vehicleProps.plate, Player.PlayerData.citizenid))
        end
    end)
end)

-- Get player Steam avatar
RegisterServerEvent('dealership:getPlayerAvatar')
AddEventHandler('dealership:getPlayerAvatar', function()
    local source = source
    local steamId = nil
    
    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, 'steam:') then
            steamId = identifier
            break
        end
    end
    
    if steamId then
        local avatarUrl = GetSteamAvatarURL(steamId)
        TriggerClientEvent('dealership:setPlayerAvatar', source, avatarUrl)
    end
end)

-- Event to update player money
RegisterServerEvent('dealership:updatePlayerMoney')
AddEventHandler('dealership:updatePlayerMoney', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    
    if Player then
        local cash = Player.PlayerData.money['cash']
        TriggerClientEvent('dealership:setPlayerMoney', source, cash)
    end
end)
