-- Initialize Vanguard Bridge
Vanguard = exports["Vanguard_Bridge"]:Vanguard()

-- Check if player has allowed job
local function hasAllowedJob(playerId)
    local PlayerData = Vanguard.GetPlayerData(playerId)
    if not PlayerData then return false end
    
    for _, job in ipairs(Config.AllowedJobs) do
        if PlayerData.job.name == job then
            return true
        end
    end
    return false
end

-- Check if player has command permission
local function hasCommandPermission(playerId)
    if not Config.Commands.RemoveMedical.Enabled then
        return false
    end
    
    local PlayerData = Vanguard.GetPlayerData(playerId)
    if not PlayerData then return false end
    
    for job, grade in pairs(Config.Commands.RemoveMedical.Jobs) do
        if PlayerData.job.name == job and PlayerData.job.grade >= grade then
            return true
        end
    end
    return false
end

-- Get nearby players
local function getNearbyPlayers(source, maxDistance)
    local players = GetPlayers()
    local nearby = {}
    
    -- Add self option first
    local sourceData = Vanguard.GetPlayerData(source)
    table.insert(nearby, {
        id = source,
        name = sourceData.name
    })
    
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    
    for _, playerId in ipairs(players) do
        if tonumber(playerId) ~= tonumber(source) then
            local targetCoords = GetEntityCoords(GetPlayerPed(playerId))
            local distance = #(playerCoords - targetCoords)
            
            if distance <= maxDistance then
                local targetData = Vanguard.GetPlayerData(playerId)
                table.insert(nearby, {
                    id = playerId,
                    name = targetData.name
                })
            end
        end
    end
    
    return nearby
end

-- Time conversion function
local function parseTime(timeStr)
    local minutes = tonumber(timeStr)
    if not minutes then
        return nil
    end
    return minutes
end

-- Handle wheelchair/crutch usage
local function handleMedicalItem(source, itemName, targetId, timeStr)
    if not hasAllowedJob(source) then
        Vanguard.notifyserver(source, Config.Notifications.NoPermission.title, 
            Config.Notifications.NoPermission.message, 
            5000, Config.Notifications.NoPermission.type)
        return
    end

    -- Check if player has the item
    if not Vanguard.HasItem(source, itemName) then
        Vanguard.notifyserver(source, Config.Notifications.NoItem.title, 
            Config.Notifications.NoItem.message, 
            5000, Config.Notifications.NoItem.type)
        return
    end
    
    -- Parse and validate time
    local time = parseTime(timeStr)
    if not time then
        Vanguard.notifyserver(source, Config.Notifications.InvalidTime.title, 
            Config.Notifications.InvalidTime.message, 
            5000, Config.Notifications.InvalidTime.type)
        return
    end
    
    -- Remove item from inventory
    Vanguard.RemoveItem(source, itemName, 1)
    
    local timeInMs = time * 60 * 1000 -- Convert minutes to milliseconds
    local targetData = Vanguard.GetPlayerData(targetId)
    local sourceData = Vanguard.GetPlayerData(source)
    
    if itemName == Config.Items.Wheelchair.name then
        TriggerClientEvent('wheelchair:setPlayerState', targetId, true, timeInMs)
        Vanguard.notifyserver(source, Config.Notifications.GaveWheelchair.title,
            string.format(Config.Notifications.GaveWheelchair.message, targetData.name, time),
            5000, Config.Notifications.GaveWheelchair.type)
        Vanguard.notifyserver(targetId, Config.Notifications.ReceivedWheelchair.title,
            string.format(Config.Notifications.ReceivedWheelchair.message, time),
            5000, Config.Notifications.ReceivedWheelchair.type)
    elseif itemName == Config.Items.Crutch.name then
        TriggerClientEvent('crutches:forceEquip', targetId, true, timeInMs/1000)
        Vanguard.notifyserver(source, Config.Notifications.GaveCrutch.title,
            string.format(Config.Notifications.GaveCrutch.message, targetData.name, time),
            5000, Config.Notifications.GaveCrutch.type)
        Vanguard.notifyserver(targetId, Config.Notifications.ReceivedCrutch.title,
            string.format(Config.Notifications.ReceivedCrutch.message, time),
            5000, Config.Notifications.ReceivedCrutch.type)
    end
end

if Config.Shop.Enabled then
    -- Convert Config.Items to the format ox_inventory expects
    local inventory = {}
    for _, item in pairs(Config.Items) do
        table.insert(inventory, {
            name = item.name,
            price = item.price
        })
    end

    exports.ox_inventory:RegisterShop('medical_shop', {
        name = Config.UI.Shop.name,
        inventory = inventory,
        locations = {
            Config.Shop.Location,
        },
        groups = Config.Shop.Groups
    })
end

-- Register usable items
Vanguard.RegisterUsableItem(Config.Items.Wheelchair.name, function(source)
    local nearby = getNearbyPlayers(source, Config.MaxDistance)
    TriggerClientEvent('medical:openSelectionMenu', source, Config.Items.Wheelchair.name, nearby)
end)

Vanguard.RegisterUsableItem(Config.Items.Crutch.name, function(source)
    local nearby = getNearbyPlayers(source, Config.MaxDistance)
    TriggerClientEvent('medical:openSelectionMenu', source, Config.Items.Crutch.name, nearby)
end)

-- Handle menu selection
RegisterNetEvent('medical:applyItem')
AddEventHandler('medical:applyItem', function(itemName, targetId, timeStr)
    handleMedicalItem(source, itemName, targetId, timeStr)
end)

-- Register remove medical equipment command
if Config.Commands.RemoveMedical.Enabled then
    RegisterCommand(Config.Commands.RemoveMedical.Command, function(source, args)
        if not hasCommandPermission(source) then
            Vanguard.notifyserver(source, Config.Notifications.NoPermission.title, 
                Config.Notifications.NoPermission.message, 
                5000, Config.Notifications.NoPermission.type)
            return
        end
        
        if not args[1] then
            Vanguard.notifyserver(source, Config.Notifications.InvalidTarget.title, 
                Config.Notifications.InvalidTarget.message, 
                5000, Config.Notifications.InvalidTarget.type)
            return
        end
        
        local targetId = tonumber(args[1])
        local targetData = Vanguard.GetPlayerData(targetId)
        
        if not targetData then
            Vanguard.notifyserver(source, Config.Notifications.PlayerNotFound.title, 
                Config.Notifications.PlayerNotFound.message, 
                5000, Config.Notifications.PlayerNotFound.type)
            return
        end
        
        -- Remove both crutch and wheelchair
        TriggerClientEvent('crutches:forceEquip', targetId, false)
        TriggerClientEvent('wheelchair:setPlayerState', targetId, false)
        
        -- Notify both players
        Vanguard.notifyserver(source, Config.Notifications.RemovedEquipment.title,
            string.format(Config.Notifications.RemovedEquipment.message, targetData.name),
            5000, Config.Notifications.RemovedEquipment.type)
        Vanguard.notifyserver(targetId, Config.Notifications.EquipmentRemoved.title,
            Config.Notifications.EquipmentRemoved.message,
            5000, Config.Notifications.EquipmentRemoved.type)
    end)
end