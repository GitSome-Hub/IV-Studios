-- Server-side carry synchronization
RegisterNetEvent('radial:syncCarry')
AddEventHandler('radial:syncCarry', function(targetId)
    TriggerClientEvent('radial:beingCarried', targetId, source)
end)

RegisterNetEvent('radial:syncDrop')
AddEventHandler('radial:syncDrop', function(targetId)
    TriggerClientEvent('radial:beingDropped', targetId)
end)

RegisterServerEvent('radial:putInTrunk')
AddEventHandler('radial:putInTrunk', function(targetPlayerId)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local targetPlayer = Vanguard.GetPlayerFromId(targetPlayerId)
    
    if xPlayer and targetPlayer then
        TriggerClientEvent('radial:putInTrunk', targetPlayerId)
    end
end)

RegisterServerEvent('radial:removeFromTrunk')
AddEventHandler('radial:removeFromTrunk', function(targetPlayerId)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local targetPlayer = Vanguard.GetPlayerFromId(targetPlayerId)
    
    if xPlayer and targetPlayer then
        TriggerClientEvent('radial:removeFromTrunk', targetPlayerId)
    end
end)

--------------- Bag System ----------------

RegisterServerEvent('radial:placeBag')
AddEventHandler('radial:placeBag', function(target)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local tPlayer = Vanguard.GetPlayerFromId(target)
    
    if xPlayer and tPlayer then
        local bagItem = Config.Items.Bag.Item
        local required = Config.Items.Bag.Required
        
        if required then
            -- Verifica se o jogador tem o item necessário
            if Vanguard.HasItem(source, bagItem) then
                -- Remove o item do inventário do jogador
                Vanguard.RemoveItem(source, bagItem, 1)
                -- Notifica o jogador que colocou a bolsa
                Vanguard.notifyserver(source, Config.Notifications.BagPlacedTitle, Config.Notifications.BagPlacedMessage, 3000, "info")
                -- Notifica o alvo que recebeu a bolsa
                Vanguard.notifyserver(target, Config.Notifications.BagPlacedTargetTitle, Config.Notifications.BagPlacedTargetMessage, 3000, "info")
                -- Envia o evento para o cliente colocar a bolsa
                TriggerClientEvent('radial:bagPlaced', target)
            else
                -- Notifica o jogador que não tem o item necessário
                Vanguard.notifyserver(source, Config.Notifications.NoRequiredItemTitle, Config.Notifications.NoRequiredItemMessage, 3000, "error")
            end
        else
            -- Notifica o jogador e o alvo que a bolsa foi colocada
            Vanguard.notifyserver(source, Config.Notifications.BagPlacedTitle, Config.Notifications.BagPlacedMessage, 3000, "info")
            Vanguard.notifyserver(target, Config.Notifications.BagPlacedTargetTitle, Config.Notifications.BagPlacedTargetMessage, 3000, "info")
            -- Envia o evento para o cliente colocar a bolsa
            TriggerClientEvent('radial:bagPlaced', target)
        end
    end
end)

RegisterServerEvent('radial:removeBag')
AddEventHandler('radial:removeBag', function(target)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local tPlayer = Vanguard.GetPlayerFromId(target)
    
    if xPlayer and tPlayer then
        -- Notifica o jogador e o alvo que a bolsa foi removida
        Vanguard.notifyserver(source, Config.Notifications.BagRemovedTitle, Config.Notifications.BagRemovedMessage, 3000, "info")
        Vanguard.notifyserver(target, Config.Notifications.BagRemovedTargetTitle, Config.Notifications.BagRemovedTargetMessage, 3000, "info")
        -- Envia o evento para o cliente remover a bolsa
        TriggerClientEvent('radial:removeBag', target)
    end
end)

--------------------------

RegisterServerEvent('radial:cuffPlayer')
AddEventHandler('radial:cuffPlayer', function(target)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local tPlayer = Vanguard.GetPlayerFromId(target)
    
    if xPlayer and tPlayer then
        local cuffItem = Config.Items.Cuff.Item
        local required = Config.Items.Cuff.Required
        
        if required then
            -- Verifica se o jogador tem o item necessário
            if Vanguard.HasItem(source, cuffItem) then
                -- Remove o item do inventário do jogador
                Vanguard.RemoveItem(source, cuffItem, 1)
                -- Notifica o jogador e o alvo que o jogador foi algemado
                Vanguard.notifyserver(source, Config.Notifications.CuffedTitle, Config.Notifications.CuffedMessage, 3000, "info")
                Vanguard.notifyserver(target, Config.Notifications.CuffedTargetTitle, Config.Notifications.CuffedTargetMessage, 3000, "info")
                -- Envia o evento para o cliente algemar o jogador
                TriggerClientEvent('radial:setCuffState', target, true)
            else
                -- Notifica o jogador que não tem o item necessário
                Vanguard.notifyserver(source, Config.Notifications.NoRequiredItemTitle, Config.Notifications.NoRequiredItemMessage, 3000, "error")
            end
        else
            -- Notifica o jogador e o alvo que o jogador foi algemado
            Vanguard.notifyserver(source, Config.Notifications.CuffedTitle, Config.Notifications.CuffedMessage, 3000, "info")
            Vanguard.notifyserver(target, Config.Notifications.CuffedTargetTitle, Config.Notifications.CuffedTargetMessage, 3000, "info")
            -- Envia o evento para o cliente algemar o jogador
            TriggerClientEvent('radial:setCuffState', target, true)
        end
    end
end)

RegisterServerEvent('radial:uncuffPlayer')
AddEventHandler('radial:uncuffPlayer', function(target)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local tPlayer = Vanguard.GetPlayerFromId(target)
    
    if xPlayer and tPlayer then
        -- Notifica o jogador e o alvo que o jogador foi desalgemado
        Vanguard.notifyserver(source, Config.Notifications.UncuffedTitle, Config.Notifications.UncuffedMessage, 3000, "info")
        Vanguard.notifyserver(target, Config.Notifications.UncuffedTargetTitle, Config.Notifications.UncuffedTargetMessage, 3000, "info")
        -- Envia o evento para o cliente desalgemar o jogador
        TriggerClientEvent('radial:setCuffState', target, false)
    end
end)

RegisterNetEvent('radial:searchPlayer')
AddEventHandler('radial:searchPlayer', function(targetPlayer)
    local source = source
    TriggerClientEvent('radial:showInventory', source, targetPlayer)
end)

RegisterServerEvent('radial:flattire')
AddEventHandler('radial:flattire', function()
    local xPlayer = Vanguard.GetPlayerFromId(source)
    
    if xPlayer then
        local flatTireItem = Config.Items.FlatTire.Item
        local required = Config.Items.FlatTire.Required
        
        if required then
            -- Verifica se o jogador tem o item necessário
            if Vanguard.HasItem(source, flatTireItem) then
                -- Remove o item do inventário do jogador
                Vanguard.RemoveItem(source, flatTireItem, 1)
                -- Envia o evento para o cliente furar o pneu
                TriggerClientEvent('radial:flattire', source)
            else
                -- Notifica o jogador que não tem o item necessário
                Vanguard.notifyserver(source, Config.Notifications.NoRequiredItemTitle, Config.Notifications.NoRequiredItemMessage, 3000, "error")
            end
        else
            -- Envia o evento para o cliente furar o pneu
            TriggerClientEvent('radial:flattire', source)
        end
    end
end)

---- HOSTAGE SYSTEM ----

local takingHostage = {}
local takenHostage = {}

RegisterServerEvent("TakeHostage:sync")
AddEventHandler("TakeHostage:sync", function(targetSrc)
    local source = source

    TriggerClientEvent("TakeHostage:syncTarget", targetSrc, source)
    takingHostage[source] = targetSrc
    takenHostage[targetSrc] = source
end)

RegisterServerEvent("TakeHostage:releaseHostage")
AddEventHandler("TakeHostage:releaseHostage", function(targetSrc)
    local source = source
    if takenHostage[targetSrc] then 
        TriggerClientEvent("TakeHostage:releaseHostage", targetSrc, source)
        takingHostage[source] = nil
        takenHostage[targetSrc] = nil
    end
end)

RegisterServerEvent("TakeHostage:killHostage")
AddEventHandler("TakeHostage:killHostage", function(targetSrc)
    local source = source
    if takenHostage[targetSrc] then 
        TriggerClientEvent("TakeHostage:killHostage", targetSrc, source)
        takingHostage[source] = nil
        takenHostage[targetSrc] = nil
    end
end)

RegisterServerEvent("TakeHostage:stop")
AddEventHandler("TakeHostage:stop", function(targetSrc)
    local source = source

    if takingHostage[source] then
        TriggerClientEvent("TakeHostage:cl_stop", targetSrc)
        takingHostage[source] = nil
        takenHostage[targetSrc] = nil
    elseif takenHostage[source] then
        TriggerClientEvent("TakeHostage:cl_stop", targetSrc)
        takenHostage[source] = nil
        takingHostage[targetSrc] = nil
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    
    if takingHostage[source] then
        TriggerClientEvent("TakeHostage:cl_stop", takingHostage[source])
        takenHostage[takingHostage[source]] = nil
        takingHostage[source] = nil
    end

    if takenHostage[source] then
        TriggerClientEvent("TakeHostage:cl_stop", takenHostage[source])
        takingHostage[takenHostage[source]] = nil
        takenHostage[source] = nil
    end
end)