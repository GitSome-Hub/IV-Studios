local QBCore = exports['qb-core']:GetCoreObject()
local registeredStashes = {}
local ox_inventory = exports.ox_inventory

-- Block wallets inside wallets
if Config.BlockWalletsInWallets then
    CreateThread(function()
        while GetResourceState('ox_inventory') ~= 'started' do Wait(100) end
        
        local moveHook = ox_inventory:registerHook('moveItems', function(payload)
            if not payload or not payload.source then return true end
            
            -- Check if moving item is a wallet
            local isMovingWallet = false
            for _, wallet in ipairs(Config.Wallets) do
                if payload.fromInventory == 'player' and payload.fromSlot.name == wallet.name then
                    isMovingWallet = true
                    break
                end
            end
            
            -- Check if trying to move to a wallet
            if isMovingWallet and payload.toInventory:find('wallet_') then
                TriggerClientEvent('ox_lib:notify', payload.source, {
                    type = 'error',
                    description = Config.Robbery.Messages.WalletInWallet
                })
                return false
            end
            
            return true
        end, {
            print = false
        })

        AddEventHandler('onResourceStop', function(resourceName)
            if resourceName == GetCurrentResourceName() then
                ox_inventory:removeHooks(moveHook)
            end
        end)
    end)
end

-- Generate unique identifier
local function GenerateSerial()
    local str = ''
    for i = 1, 3 do str = str .. string.char(math.random(65, 90)) end
    return string.format('%s%s', str, math.random(100000,999999))
end

-- Helper function to check if value exists in table
local function IsJobAllowed(job, allowedJobs)
    for _, allowedJob in ipairs(allowedJobs) do
        if job == allowedJob then
            return true
        end
    end
    return false
end

-- Function to handle robbery rewards
local function GiveRobberyRewards(source)
    local rewards = Config.Robbery.Rewards
    local totalReward = 0
    
    -- Handle money reward
    if rewards.Money.Enabled then
        local moneyAmount = 0
        if rewards.Money.Type == 'fixed' then
            moneyAmount = rewards.Money.Fixed.Amount
        else
            -- Check random chance
            if math.random(1, 100) <= rewards.Money.Random.Chance then
                moneyAmount = math.random(
                    rewards.Money.Random.MinAmount,
                    rewards.Money.Random.MaxAmount
                )
            end
        end
        
        if moneyAmount > 0 then
            ox_inventory:AddItem(source, 'money', moneyAmount)
            totalReward = totalReward + moneyAmount
        end
    end
    
    -- Handle item rewards
    if rewards.Items.Enabled then
        for _, itemReward in ipairs(rewards.Items.List) do
            if math.random(1, 100) <= itemReward.chance then
                local quantity = math.random(itemReward.min, itemReward.max)
                ox_inventory:AddItem(source, itemReward.item, quantity)
            end
        end
    end
    
    return totalReward > 0 or (rewards.Items.Enabled and #rewards.Items.List > 0)
end

-- Wallet prices
local walletPrices = {}
for _, wallet in ipairs(Config.Wallets) do
    walletPrices[wallet.name] = wallet.price
end

-- Register shop
if Config.EnableShop then
    exports.ox_inventory:RegisterShop('wallet_shop', {
        name = 'Wallet Shop',
        inventory = {
            { name = 'wallet_basic', price = walletPrices['wallet_basic'] or 10 },
            { name = 'wallet_premium', price = walletPrices['wallet_premium'] or 10 },
        },
        locations = {
            Config.ShopLocation,
        },
    })
end

-- Register new wallet identifiers
lib.callback.register('qb_vanguard_wallet:getNewIdentifier', function(source, slot, walletType)
    local newId = GenerateSerial()
    local walletConfig = Config.Wallets[walletType]
    
    if walletConfig then
        ox_inventory:SetMetadata(source, slot, {identifier = newId, type = walletType})
        ox_inventory:RegisterStash('wallet_'..newId, walletConfig.label, walletConfig.slots, walletConfig.weight, false)
        registeredStashes[newId] = true
        return newId
    end
    return nil
end)

-- NPC Robbery callback
lib.callback.register('qb_vanguard_wallet:robNPC', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    
    -- Give rewards to player
    local success = GiveRobberyRewards(src)
    
    -- Alert police if enabled
    if Config.Robbery.PoliceAlert.Enable then
        local players = QBCore.Functions.GetQBPlayers()
        for _, player in pairs(players) do
            if IsJobAllowed(player.PlayerData.job.name, Config.Robbery.PoliceAlert.Jobs) then
                TriggerClientEvent('qb_vanguard_wallet:createRobberyBlip', player.PlayerData.source, coords)
                TriggerClientEvent('ox_lib:notify', player.PlayerData.source, {
                    type = 'inform',
                    description = string.format(Config.Robbery.Messages.PoliceNotification, 
                        string.format('%.2f, %.2f', coords.x, coords.y))
                })
            end
        end
    end
    
    return success
end)

-- One wallet restriction
if Config.OneWalletOnly then
    CreateThread(function()
        while GetResourceState('ox_inventory') ~= 'started' do Wait(100) end
        
        local swapHook = ox_inventory:registerHook('swapItems', function(payload)
            if not payload or not payload.source then return false end
            
            local count_wallets = 0
            for _, wallet in ipairs(Config.Wallets) do
                count_wallets = count_wallets + ox_inventory:GetItem(payload.source, wallet.name, nil, true)
            end
            
            if count_wallets > 1 then
                TriggerClientEvent('ox_lib:notify', payload.source, {
                    type = 'error',
                    description = Config.Robbery.Messages.WalletLimit
                })
                return false
            end
            
            return true
        end, {
            print = false
        })
        
        AddEventHandler('onResourceStop', function(resourceName)
            if resourceName == GetCurrentResourceName() then
                ox_inventory:removeHooks(swapHook)
            end
        end)
    end)
end