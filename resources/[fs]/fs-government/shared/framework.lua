Framework = {}

function Framework.GetFramework()
    if Config.Framework == 'auto' then
        if GetResourceState('es_extended') == 'started' then
            return 'esx'
        elseif GetResourceState('qb-core') == 'started' then
            return 'qbcore'
        elseif GetResourceState('qbox') == 'started' then
            return 'qbox'
        else
            return nil
        end
    else
        return Config.Framework
    end
end

function Framework.GetInventory()
    if Config.Inventory == 'auto' then
        if GetResourceState('ox_inventory') == 'started' then
            return 'ox_inventory'
        elseif GetResourceState('qb-inventory') == 'started' then
            return 'qb-inventory'
        elseif GetResourceState('esx_inventory') == 'started' then
            return 'esx_inventory'
        else
            local fw = Framework.GetFramework()
            if fw == 'esx' then
                return 'esx_inventory'
            elseif fw == 'qbcore' or fw == 'qbox' then
                return 'qb-inventory'
            end
        end
    else
        return Config.Inventory
    end
end

if IsDuplicityVersion() then
    function Framework.GetPlayerData(source)
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return nil end
            
            return {
                source = source,
                identifier = xPlayer.identifier,
                name = xPlayer.getName(),
                job = {
                    name = xPlayer.job.name,
                    label = xPlayer.job.label,
                    grade = xPlayer.job.grade
                },
                money = xPlayer.getMoney(),
                bank = (xPlayer.getAccount('bank') and xPlayer.getAccount('bank').money) or 0,
                group = xPlayer.getGroup()
            }
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return nil end
            
            return {
                source = source,
                identifier = Player.PlayerData.citizenid,
                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                job = {
                    name = Player.PlayerData.job.name,
                    label = Player.PlayerData.job.label,
                    grade = Player.PlayerData.job.grade.level
                },
                money = Player.PlayerData.money.cash,
                bank = Player.PlayerData.money.bank,
                group = Player.PlayerData.metadata.group or 'user'
            }
        end
        
        return nil
    end
    
    function Framework.GetPlayerJob(source)
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return nil end
            return xPlayer.job
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return nil end
            return Player.PlayerData.job
        end
        
        return nil
    end
    
    function Framework.GetPlayers()
        return GetPlayers()
    end
    
    function Framework.GetPlayerByIdentifier(identifier)
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local players = ESX.GetPlayers()
            for _, playerId in ipairs(players) do
                local xPlayer = ESX.GetPlayerFromId(playerId)
                if xPlayer and xPlayer.identifier == identifier then
                    return playerId
                end
            end
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local players = QBCore.Functions.GetPlayers()
            for _, playerId in pairs(players) do
                local Player = QBCore.Functions.GetPlayer(playerId)
                if Player and Player.PlayerData.citizenid == identifier then
                    return playerId
                end
            end
        end
        
        return nil
    end
    
    function Framework.AddMoney(source, amount, account)
        local framework = Framework.GetFramework()

        -- Ensure amount is a number
        amount = tonumber(amount) or 0
        account = account or 'cash'
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return false end
            
            if account == 'cash' then
                xPlayer.addMoney(amount)
                return true
            else
                -- Check if account exists before adding money
                local accountData = xPlayer.getAccount(account)
                if not accountData then
                    if Config.Debug then
                        Utils.DebugError('ESX account "' .. tostring(account) .. '" does not exist for player ' .. source)
                    end
                    return false
                end
                
                xPlayer.addAccountMoney(account, amount)
                return true
            end
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return false end
            
            Player.Functions.AddMoney(account, amount)
            return true
        end
        
        return false
    end
    
    function Framework.RemoveMoney(source, amount, account)
        local framework = Framework.GetFramework()
        account = account or 'cash'

        -- Ensure amount is a number
        amount = tonumber(amount) or 0

        if Config.Debug then
            Utils.DebugPrint('RemoveMoney called - Source: ' .. source .. ', Amount: $' .. amount .. ', Account: ' .. account .. ', Framework: ' .. tostring(framework))
        end
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then
                if Config.Debug then
                    Utils.DebugError('RemoveMoney failed - ESX player not found')
                end
                return false 
            end
            
            local success = false
            if account == 'cash' then
                -- Get balance before removing money
                local beforeBalance = xPlayer.getMoney()
                local removeResult = xPlayer.removeMoney(amount)
                local afterBalance = xPlayer.getMoney()
                
                -- Check if money was actually removed regardless of what removeMoney returns
                success = (beforeBalance - afterBalance) == amount
                
                if Config.Debug then
                    Utils.DebugPrint('ESX cash removal - Before: $' .. beforeBalance .. ', After: $' .. afterBalance .. ', Removed: $' .. (beforeBalance - afterBalance) .. ', Expected: $' .. amount)
                end
            else
                -- ESX removeAccountMoney often doesn't return a boolean, so we need to check balance manually
                local accountData = xPlayer.getAccount(account)
                if not accountData then
                    if Config.Debug then
                        Utils.DebugError('ESX account "' .. tostring(account) .. '" does not exist for player ' .. source)
                    end
                    return false
                end
                
                local beforeBalance = accountData.money
                xPlayer.removeAccountMoney(account, amount)
                local afterAccountData = xPlayer.getAccount(account)
                if not afterAccountData then
                    return false
                end
                local afterBalance = afterAccountData.money
                success = (beforeBalance - afterBalance) == amount
            end
            
            if Config.Debug then
                Utils.DebugPrint('RemoveMoney ESX result: ' .. tostring(success))
            end
            return success
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then
                if Config.Debug then
                    Utils.DebugError('RemoveMoney failed - QBCore player not found')
                end
                return false 
            end
            
            local success = Player.Functions.RemoveMoney(account, amount)
            if Config.Debug then
                Utils.DebugPrint('RemoveMoney QBCore result: ' .. tostring(success))
            end
            return success
        end
        
        if Config.Debug then
            Utils.DebugError('RemoveMoney failed - Unknown framework')
        end
        return false
    end
    
    function Framework.GetPlayerNameFromIdentifier(identifier)
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            -- Try to find online player first
            local xPlayers = ESX.GetPlayers()
            for _, playerId in ipairs(xPlayers) do
                local xPlayer = ESX.GetPlayerFromId(playerId)
                if xPlayer and xPlayer.identifier == identifier then
                    return xPlayer.getName()
                end
            end
            
            -- If not online, query database for character name
            local result = MySQL.query.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier})
            if result and result[1] then
                return (result[1].firstname or '') .. ' ' .. (result[1].lastname or '')
            end
            
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            -- Try to find online player first
            local onlinePlayers = QBCore.Functions.GetPlayers()
            for _, playerId in ipairs(onlinePlayers) do
                local Player = QBCore.Functions.GetPlayer(playerId)
                if Player and Player.PlayerData.citizenid == identifier then
                    local charData = Player.PlayerData.charinfo
                    if charData then
                        return (charData.firstname or '') .. ' ' .. (charData.lastname or '')
                    end
                end
            end
            
            -- If not online, query database for character name
            local result = MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ?', {identifier})
            if result and result[1] and result[1].charinfo then
                local charinfo = json.decode(result[1].charinfo)
                if charinfo then
                    return (charinfo.firstname or '') .. ' ' .. (charinfo.lastname or '')
                end
            end
        end
        
        return nil
    end
    
    function Framework.GetPlayerMoney(source, account)
        local framework = Framework.GetFramework()
        account = account or 'cash'
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return 0 end
            
            if account == 'cash' then
                return xPlayer.getMoney()
            else
                local accountData = xPlayer.getAccount(account)
                return accountData and accountData.money or 0
            end
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return 0 end
            
            return Player.Functions.GetMoney(account) or 0
        end
        
        return 0
    end
    
    function Framework.ShowNotification(source, message, type, duration)
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message, type, duration or 5000)
        elseif framework == 'qbcore' or framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', source, message, type or 'primary', duration or 5000)
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Government',
                description = message,
                type = type or 'primary',
                duration = duration or 5000
            })
        end
    end
    
    function Framework.ShowAdvancedNotification(source, title, message, icon, iconType, duration)
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            TriggerClientEvent('esx:showAdvancedNotification', source, title, message, icon, iconType, duration or 5000)
        elseif framework == 'qbcore' or framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', source, message, iconType or 'primary', duration or 5000)
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = title,
                description = message,
                type = iconType or 'primary',
                duration = duration or 5000
            })
        end
    end
    
    function Framework.ShowUINotify(source, message, type, duration)
        -- This function is no longer used since we use the same system as DEFCON
        -- Keeping it for compatibility but it's not needed anymore
        if Config.Debug then
            Utils.DebugPrint('ShowUINotify called but not used - using DEFCON system instead')
        end
    end
    
else
    
    function Framework.GetPlayerData()
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local playerData = ESX.GetPlayerData()
            if Config.Debug and playerData then
                Utils.DebugPrint('ESX Player Data: ' .. json.encode(playerData.job or {}))
            end
            return playerData
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local playerData = QBCore.Functions.GetPlayerData()
            if Config.Debug and playerData then
                Utils.DebugPrint('QBCore Player Data: ' .. json.encode(playerData.job or {}))
            end
            return playerData
        end
        
        if Config.Debug then
            Utils.DebugError('No framework detected: ' .. tostring(framework))
        end
        return nil
    end
    
    function Framework.ShowNotification(message, type, duration)
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.ShowNotification(message, type, duration or 5000)
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.Notify(message, type or 'primary', duration or 5000)
        else
            lib.notify({
                title = 'Government',
                description = message,
                type = type or 'primary',
                duration = duration or 5000
            })
        end
    end
    
    function Framework.GetClosestPlayer()
        local framework = Framework.GetFramework()
        
        if framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            return closestPlayer, closestDistance
        elseif framework == 'qbcore' or framework == 'qbox' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
            return closestPlayer, closestDistance
        end
        
        return nil, nil
    end
    
    function Framework.ShowUINotify(message, type, duration)
        -- This function is no longer used since we use the same system as DEFCON
        -- Keeping it for compatibility but it's not needed anymore
        if Config.Debug then
            Utils.DebugPrint('Client ShowUINotify called but not used - using DEFCON system instead')
        end
    end
    
end