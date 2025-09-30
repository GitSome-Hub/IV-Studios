
local QBCore = exports['qb-core']:GetCoreObject()

local bagEquipped, bagObj 
local ox_inventory = exports.ox_inventory
local ped = cache.ped
local justConnect = true
local customProps = {}

-- Function to check if a prop name is a valid backpack prop
local function isValidBackpackProp(propName)
    if not Config.EnableCustomProps then return false end
    
    for _, prefix in ipairs(Config.ValidPropPrefixes) do
        if string.sub(string.lower(propName), 1, #prefix) == string.lower(prefix) then
            return true
        end
    end
    return false
end

-- Function to load custom props from the customBackpacks folder
local function loadCustomProps()
    if not Config.EnableCustomProps then return end
    
    local resourceName = GetCurrentResourceName()
    local numFiles = GetNumResourceMetadata(resourceName, 'data_file')
    
    for i = 0, numFiles - 1 do
        local fileName = GetResourceMetadata(resourceName, 'data_file', i)
        if fileName and fileName:match('^' .. Config.CustomPropsFolder .. '/.*%.ydr$') then
            local propName = fileName:match('([^/]+)%.ydr$')
            if isValidBackpackProp(propName) then
                customProps[propName] = true
            end
        end
    end
end

-- Function to get a valid custom prop
local function getCustomProp()
    if not Config.EnableCustomProps or not next(customProps) then return nil end
    
    -- Return the first valid custom prop found
    for propName in pairs(customProps) do
        return propName
    end
    return nil
end

-- Function to attach backpack to player
local function PutOnBag()
    if not DoesEntityExist(bagObj) then
        local playerPed = PlayerPedId()
        
        -- Find which backpack the player has equipped and get its prop
        local bagType = Config.DefaultBackpackProp
        local customProp = nil
        
        if Config.EnableCustomProps then
            customProp = getCustomProp()
        end
        
        for _, backpack in ipairs(Config.Backpacks) do
            local count = ox_inventory:Search('count', backpack.name)
            if count > 0 then
                bagType = customProp or backpack.prop or Config.DefaultBackpackProp
                break
            end
        end
        
        lib.requestModel(bagType, 100)

        if HasModelLoaded(bagType) then
            local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 3.0, 0.5))
            bagObj = CreateObjectNoOffset(bagType, x, y, z, true, false, false)
            
            -- Adjust attachment based on prop type
            local attachmentConfig = {
                ["p_ld_heist_bag_s"] = {
                    bone = 24818,
                    x = -0.050,
                    y = -0.09,
                    z = -0.01,
                    rotX = 0.0,
                    rotY = 90.0,
                    rotZ = 175.0
                },
                default = {
                    bone = 24818,
                    x = 0.07,
                    y = -0.11,
                    z = -0.05,
                    rotX = 0.0,
                    rotY = 90.0,
                    rotZ = 175.0
                }
            }
            
            local config = attachmentConfig[bagType] or attachmentConfig.default
            
            AttachEntityToEntity(bagObj, playerPed, GetPedBoneIndex(playerPed, config.bone),
                config.x, config.y, config.z,
                config.rotX, config.rotY, config.rotZ,
                true, true, false, true, 1, true)
            
            bagEquipped = true
            SetModelAsNoLongerNeeded(bagType)
        end
    end
end

local function RemoveBag()
    if DoesEntityExist(bagObj) then
        DeleteObject(bagObj)
        SetModelAsNoLongerNeeded(bagObj)
    end
    bagObj = nil
    bagEquipped = nil
end

local function HasAnyBackpack()
    for _, backpack in ipairs(Config.Backpacks) do
        local count = ox_inventory:Search('count', backpack.name)
        if count > 0 then
            return true
        end
    end
    return false
end

-- Load custom props when resource starts
CreateThread(function()
    loadCustomProps()
end)

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if justConnect then
        Wait(1000)
        justConnect = nil
    end

    for k, v in pairs(changes) do
        if type(v) == 'table' then
            if HasAnyBackpack() and (not bagEquipped or not DoesEntityExist(bagObj)) then
                PutOnBag()
            elseif not HasAnyBackpack() and bagEquipped then
                RemoveBag()
            end
        end
        if type(v) == 'boolean' then
            if not HasAnyBackpack() and bagEquipped then
                RemoveBag()
            end
        end
    end
end)

lib.onCache('ped', function(value)
    ped = value
end)

lib.onCache('vehicle', function(value)
    if GetResourceState('ox_inventory') ~= 'started' then return end
    if value then
        RemoveBag()
    else
        if HasAnyBackpack() then
            PutOnBag()
        end
    end
end)

local function OpenBackpackWithPinCheck(backpackID, level)
    local backpackConfig = Config.Backpacks[level]
    if backpackConfig and backpackConfig.pin and Config.UsePINSystem then
        RequestPin(backpackID, level)
    else
        ox_inventory:openInventory('stash', 'bag_'..backpackID)
    end
end

exports('openBackpack1', function(data, slot)
    if not slot?.metadata?.identifier then
        local identifier = lib.callback.await('qb_vanguard_backpack:getNewIdentifier', 100, data.slot, 1)
    else
        TriggerServerEvent('qb_vanguard_backpack:openBackpack', slot.metadata.identifier, 1)
        OpenBackpackWithPinCheck(slot.metadata.identifier, 1)
    end
end)

exports('openBackpack2', function(data, slot)
    if not slot?.metadata?.identifier then
        local identifier = lib.callback.await('qb_vanguard_backpack:getNewIdentifier', 100, data.slot, 2)
    else
        TriggerServerEvent('qb_vanguard_backpack:openBackpack', slot.metadata.identifier, 2)
        OpenBackpackWithPinCheck(slot.metadata.identifier, 2)
    end
end)

exports('openBackpack3', function(data, slot)
    if not slot?.metadata?.identifier then
        local identifier = lib.callback.await('qb_vanguard_backpack:getNewIdentifier', 100, data.slot, 3)
    else
        TriggerServerEvent('qb_vanguard_backpack:openBackpack', slot.metadata.identifier, 3)
        OpenBackpackWithPinCheck(slot.metadata.identifier, 3)
    end
end)

function RequestPin(backpackID, backpackLevel)
    if not Config.UsePINSystem then
        ox_inventory:openInventory('stash', 'bag_'..backpackID)
        return
    end
    
    lib.callback('qb_vanguard_backpack:checkOrInsertPin', false, function(exists, storedPin)
        if exists and storedPin then
            local pin = lib.inputDialog('Unlock Backpack', { 
                { type = 'input', label = 'PIN Code', password = true, required = true }
            })

            if pin then
                if pin[1] == storedPin then
                    ox_inventory:openInventory('stash', 'bag_'..backpackID)
                else
                    ShowNotification('Incorrect PIN')
                end
            end
        else
            local newPin = lib.inputDialog('Set Backpack Lock PIN', { 
                { type = 'input', label = 'New PIN Code', password = true, required = true }
            })

            if newPin and newPin[1] then
                TriggerServerEvent('qb_vanguard_backpack:setNewPin', backpackID, newPin[1])
                ox_inventory:openInventory('stash', 'bag_'..backpackID)
            end
        end
    end, backpackID, backpackLevel)
end

-- Only create target zone and shop if enabled in config
if Config.EnableShop then
    exports.ox_target:addSphereZone({
        coords = vec3(399.8024, 96.92446, 101.48),
        radius = 1,
        debug = drawZones,
        options = {
            {
                name = "sphere",
                event = "openshop",
                icon = "fa-solid fa-circle",
                label = "Backpack Shop",
            }
        }
    })

    RegisterNetEvent("openshop")
    AddEventHandler("openshop", function()
        if Config.EnableShop then
            exports.ox_inventory:openInventory('shop', { type = 'backpackshop', id = 1 })
        end
    end)
end

-- Create blip only if enabled in config
CreateThread(function()
    if Config.EnableBlip then
        local blip = AddBlipForCoord(Config.BlipLocation)
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipDisplay(blip, Config.Blip.Display)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipColour(blip, Config.Blip.Color)
        SetBlipAsShortRange(blip, Config.Blip.ShortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.Name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Create ped only if enabled in config
CreateThread(function()
    if Config.EnablePed then
        RequestModel(GetHashKey(Config.PedConfig.model))
        while not HasModelLoaded(GetHashKey(Config.PedConfig.model)) do
            Wait(1)
        end
        
        local ped = CreatePed(4, GetHashKey(Config.PedConfig.model), Config.PedConfig.position, Config.PedConfig.heading, false, true)
        SetEntityHeading(ped, Config.PedConfig.heading)
        FreezeEntityPosition(ped, Config.PedConfig.frozen)
        SetEntityInvincible(ped, Config.PedConfig.invincible)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        if Config.PedConfig.canRagdoll == false then
            SetPedCanRagdoll(ped, false)
        end
    end
end)