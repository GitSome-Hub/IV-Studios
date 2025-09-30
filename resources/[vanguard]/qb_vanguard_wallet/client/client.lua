local QBCore = exports['qb-core']:GetCoreObject()
local ox_inventory = exports.ox_inventory
local isRobbing = false
local lastRobberyTime = 0
local lastNotificationTime = 0
local NOTIFICATION_COOLDOWN = 2000 -- 2 seconds between notifications

-- Function to check if player has required items
local function HasRequiredItems()
    if not Config.Robbery.RequireItems then
        return true
    end

    for _, weapon in ipairs(Config.Robbery.RequiredItems.weapons) do
        if HasPedGotWeapon(PlayerPedId(), GetHashKey(weapon), false) then
            return true
        end
    end
    return false
end

-- Function to show cooldown notification with spam prevention
local function ShowCooldownNotification()
    local currentTime = GetGameTimer()
    if currentTime - lastNotificationTime >= NOTIFICATION_COOLDOWN then
        lib.notify({
            type = 'error',
            description = Config.Robbery.Messages.CooldownActive
        })
        lastNotificationTime = currentTime
    end
end

-- Function to create temporary blip
local function CreateTemporaryBlip(coords)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, Config.Robbery.PoliceAlert.BlipSprite)
    SetBlipColour(blip, Config.Robbery.PoliceAlert.BlipColor)
    SetBlipScale(blip, Config.Robbery.PoliceAlert.BlipScale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Robbery.PoliceAlert.BlipText)
    EndTextCommandSetBlipName(blip)
    
    SetTimeout(Config.Robbery.PoliceAlert.BlipDuration * 1000, function()
        RemoveBlip(blip)
    end)
end

-- Function to make NPC flee in panic
local function MakeNPCFlee(npc, playerPed)
    if not DoesEntityExist(npc) then return end
    
    ClearPedTasks(npc)
    TaskReactAndFleePed(npc, playerPed)
    SetBlockingOfNonTemporaryEvents(npc, false)
    SetPedKeepTask(npc, true)
    SetPedMovementClipset(npc, "MOVE_M@QUICK", 3.0)
    
    SetTimeout(30000, function()
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end)
end

-- Function to start robbery animation
local function PlayRobberyAnimation(npc)
    if not DoesEntityExist(npc) then return end
    
    local playerPed = PlayerPedId()
    
    -- Make NPC put hands up
    TaskHandsUp(npc, -1, playerPed, -1, true)
    
    -- Make player aim weapon at NPC
    TaskAimGunAtEntity(playerPed, npc, -1, true)
    
    -- Start robbery progress circle
    local success = lib.progressCircle({
        duration = Config.Robbery.RobberyDuration * 1000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false
        }
    })
    
    if success then
        -- Get rewards after progress circle completes
        local robberySuccess = lib.callback.await('qb_vanguard_wallet:robNPC', false)
        
        if robberySuccess then
            lib.notify({
                type = 'success',
                description = Config.Robbery.Messages.RobberySuccess
            })
        end
    end
    
    -- Clear tasks and make NPC flee
    ClearPedTasks(playerPed)
    if DoesEntityExist(npc) then
        MakeNPCFlee(npc, playerPed)
    end
end

-- Register event for police blip
RegisterNetEvent('qb_vanguard_wallet:createRobberyBlip')
AddEventHandler('qb_vanguard_wallet:createRobberyBlip', function(coords)
    CreateTemporaryBlip(coords)
end)

-- Function to check if player has any wallet
local function HasAnyWallet()
    for _, wallet in ipairs(Config.Wallets) do
        local count = ox_inventory:Search('count', wallet.name)
        if count > 0 then
            return true
        end
    end
    return false
end

-- Create Blip
local function CreateBlip()
    if not Config.EnableBlip then return end
    
    local blip = AddBlipForCoord(Config.ShopLocation)
    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipScale(blip, Config.Blip.Scale)
    SetBlipAsShortRange(blip, Config.Blip.ShortRange)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.Name)
    EndTextCommandSetBlipName(blip)
end

-- Create NPC
local function CreateShopNPC()
    if not Config.EnableNPC then return end
    
    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
    
    local npc = CreatePed(4, model, 
        Config.NPC.position.x, 
        Config.NPC.position.y, 
        Config.NPC.position.z, 
        Config.NPC.heading, 
        false, true)
    
    SetEntityInvincible(npc, Config.NPC.invincible)
    FreezeEntityPosition(npc, Config.NPC.frozen)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedCanRagdoll(npc, Config.NPC.canRagdoll)
    
    SetModelAsNoLongerNeeded(model)
end

-- Initialize NPC robbery target
if Config.EnableNPCRobbery then
    exports.ox_target:addGlobalPed({
        {
            name = 'rob_npc_wallet',
            icon = 'fas fa-wallet',
            label = 'Rob Wallet',
            canInteract = function(entity)
                if not Config.EnableNPCRobbery then return false end
                
                -- Check if currently robbing
                if isRobbing then 
                    local currentTime = GetGameTimer()
                    if currentTime - lastNotificationTime >= NOTIFICATION_COOLDOWN then
                        lib.notify({
                            type = 'error',
                            description = Config.Robbery.Messages.RobberyInProgress
                        })
                        lastNotificationTime = currentTime
                    end
                    return false 
                end
                
                -- Check cooldown
                if (GetGameTimer() - lastRobberyTime) < (Config.Robbery.Cooldown * 1000) then 
                    ShowCooldownNotification()
                    return false 
                end
                
                return IsPedHuman(entity) and not IsPedAPlayer(entity) and not IsPedDeadOrDying(entity) and HasRequiredItems()
            end,
            onSelect = function(data)
                local npc = data.entity
                
                if Config.Robbery.RequireItems and not HasRequiredItems() then
                    lib.notify({
                        type = 'error',
                        description = Config.Robbery.Messages.NoRequiredItems
                    })
                    return
                end
                
                isRobbing = true
                lastRobberyTime = GetGameTimer()
                
                PlayRobberyAnimation(npc)
                
                isRobbing = false
            end
        }
    })
end

-- Initialize shop target
if Config.EnableShop then
    exports.ox_target:addSphereZone({
        coords = Config.ShopLocation,
        radius = 1,
        options = {
            {
                name = 'wallet_shop',
                event = 'qb_vanguard_wallet:openShop',
                icon = 'fas fa-wallet',
                label = 'Open Wallet Shop'
            }
        }
    })
end

-- Exports for opening wallets
exports('openWalletBasic', function(data, slot)
    if not slot?.metadata?.identifier then
        local identifier = lib.callback.await('qb_vanguard_wallet:getNewIdentifier', 100, data.slot, 1)
        if identifier then
            ox_inventory:openInventory('stash', 'wallet_'..identifier)
        end
    else
        ox_inventory:openInventory('stash', 'wallet_'..slot.metadata.identifier)
    end
end)

exports('openWalletPremium', function(data, slot)
    if not slot?.metadata?.identifier then
        local identifier = lib.callback.await('qb_vanguard_wallet:getNewIdentifier', 100, data.slot, 2)
        if identifier then
            ox_inventory:openInventory('stash', 'wallet_'..identifier)
        end
    else
        ox_inventory:openInventory('stash', 'wallet_'..slot.metadata.identifier)
    end
end)

-- Events
RegisterNetEvent('qb_vanguard_wallet:openShop')
AddEventHandler('qb_vanguard_wallet:openShop', function()
    exports.ox_inventory:openInventory('shop', { type = 'wallet_shop', id = 1 })
end)

-- Initialize
CreateThread(function()
    if Config.EnableBlip then CreateBlip() end
    if Config.EnableNPC then CreateShopNPC() end
end)