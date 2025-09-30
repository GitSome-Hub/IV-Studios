local QBCore = exports['qb-core']:GetCoreObject()

local registeredStashes = {}
local ox_inventory = exports.ox_inventory

local function GenerateText(num)
    local str
    repeat str = {}
        for i = 1, num do str[i] = string.char(math.random(65, 90)) end
        str = table.concat(str)
    until str ~= 'POL' and str ~= 'EMS'
    return str
end

local function GenerateSerial(text)
    if text and text:len() > 3 then
        return text
    end
    return ('%s%s%s'):format(math.random(100000,999999), text == nil and GenerateText(3) or text, math.random(100000,999999))
end

RegisterServerEvent('qb_vanguard_backpack:openBackpack')
AddEventHandler('qb_vanguard_backpack:openBackpack', function(identifier, backpackLevel)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return end

    if not registeredStashes[identifier] then
        local backpackConfig = Config.Backpacks[backpackLevel] or Config.Backpacks[1]
        ox_inventory:RegisterStash('bag_'..identifier, backpackConfig.label, backpackConfig.slots, backpackConfig.weight, false)
        registeredStashes[identifier] = true
    end

    if Config.UsePINSystem then
        MySQL.Async.fetchScalar('SELECT pin FROM user_backpacks WHERE backpackID = @backpackID', {
            ['@backpackID'] = identifier
        }, function(storedPin)
            if storedPin then
                TriggerClientEvent('qb_vanguard_backpack:requestPin', source, identifier, backpackLevel)
            end
        end)
    else
        TriggerClientEvent('ox_inventory:openInventory', source, 'stash', 'bag_'..identifier)
    end
end)

lib.callback.register('qb_vanguard_backpack:getNewIdentifier', function(source, slot, backpackLevel)
    local newId = GenerateSerial()
    local backpackConfig = Config.Backpacks[backpackLevel] or Config.Backpacks[1]
    ox_inventory:SetMetadata(source, slot, {identifier = newId, level = backpackLevel})
    ox_inventory:RegisterStash('bag_'..newId, backpackConfig.label, backpackConfig.slots, backpackConfig.weight, false)
    registeredStashes[newId] = true
    return newId
end)

lib.callback.register('qb_vanguard_backpack:checkOrInsertPin', function(source, backpackID, backpackLevel)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return false, 'Player not found' end

    if not registeredStashes[backpackID] then
        local backpackConfig = Config.Backpacks[backpackLevel] or Config.Backpacks[1]
        ox_inventory:RegisterStash('bag_'..backpackID, backpackConfig.label, backpackConfig.slots, backpackConfig.weight, false)
        registeredStashes[backpackID] = true
    end

    local result = MySQL.Sync.fetchScalar('SELECT pin FROM user_backpacks WHERE backpackID = @backpackID', {
        ['@backpackID'] = backpackID
    })

    return result ~= nil, result
end)

RegisterNetEvent('qb_vanguard_backpack:setNewPin')
AddEventHandler('qb_vanguard_backpack:setNewPin', function(backpackID, pin)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return end

    MySQL.Async.execute('INSERT INTO user_backpacks (backpackID, pin) VALUES (@backpackID, @pin)', {
        ['@backpackID'] = backpackID,
        ['@pin'] = pin
    })
end)

local backpackPrices = {}
for _, backpack in ipairs(Config.Backpacks) do
    backpackPrices[backpack.name] = backpack.price
end

exports.ox_inventory:RegisterShop('backpackshop', {
    name = 'Backpack Shop',
    inventory = {
        { name = 'backpack_level_1', price = backpackPrices['backpack_level_1'] or 10 },
        { name = 'backpack_level_2', price = backpackPrices['backpack_level_2'] or 10 },
        { name = 'backpack_level_3', price = backpackPrices['backpack_level_3'] or 10 },
    },
    locations = {
        vec3(399.8024, 96.92446, 101.48),
    },
})

CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do Wait(500) end
    local swapHook = ox_inventory:registerHook('swapItems', function(payload)
        local start, destination, move_type = payload.fromInventory, payload.toInventory, payload.toType
        local count_bagpacks = ox_inventory:GetItem(payload.source, 'backpack', nil, true)
    
        if string.find(destination, 'bag_') then
            TriggerClientEvent('vanguardnotification', payload.source, Config.Notificationbackpackinbackpack)
            return false
        end
        if Config.OneBagInInventory then
            if (count_bagpacks > 0 and move_type == 'player' and destination ~= start) then
                TriggerClientEvent('vanguardnotification', payload.source, Config.Notificationbackpack_only)
                return false
            end
        end
        
        return true
    end, {
        print = false,
        itemFilter = {
            backpack = true,
        },
    })
    
    if Config.OneBagInInventory then
        local createHook = ox_inventory:registerHook('createItem', function(payload)
            local count_bagpacks = ox_inventory:GetItem(payload.inventoryId, 'backpack', nil, true)
            local playerItems = ox_inventory:GetInventoryItems(payload.inventoryId)
    
            if count_bagpacks > 0 then
                local slot = nil
    
                for i,k in pairs(playerItems) do
                    if k.name == 'backpack' then
                        slot = k.slot
                        break
                    end
                end
    
                Citizen.CreateThread(function()
                    local inventoryId = payload.inventoryId
                    local dontRemove = slot
                    Citizen.Wait(1000)
    
                    for i,k in pairs(ox_inventory:GetInventoryItems(inventoryId)) do
                        if k.name == 'backpack' and dontRemove ~= nil and k.slot ~= dontRemove then
                            local success = ox_inventory:RemoveItem(inventoryId, 'backpack', 1, nil, k.slot)
                            if success then
                                TriggerClientEvent('vanguardnotification', inventoryId, Config.Notificationbackpack_only)
                            end
                            break
                        end
                    end
                end)
            end
        end, {
            print = false,
            itemFilter = {
                backpack = true
            }
        })
    end
end)
