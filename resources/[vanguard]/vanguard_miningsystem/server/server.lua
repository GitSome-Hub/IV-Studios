Vanguard = exports["Vanguard_Bridge"]:Vanguard()

RegisterServerEvent('vanguard_miningsystem:removerBattery')
AddEventHandler('vanguard_miningsystem:removerBattery', function()
    local source = source
    print("Evento vanguard_miningsystem:removerBattery chamado para o jogador:", source)
    
    local xPlayer = Vanguard.GetPlayerFromId(source)
    
    if xPlayer then
        print("Jogador encontrado:", xPlayer)
        
        -- Verifica se o jogador tem o item miner_battery
        local hasBattery = Vanguard.HasItem(source, Config.items.battery)  -- Isso deve retornar um booleano
        print("Jogador tem bateria:", hasBattery)
        
        if hasBattery then
            -- Chama o evento para remover a bateria
            TriggerEvent('vanguard_miningsystem:removeBattery2', source)  -- Passa o source para o evento
            
            -- Envia a notificação de que a bateria foi usada
            Vanguard.notifyserver(source, Config.notifications.batteryUsed.title, Config.notifications.batteryUsed.message, 5000, Config.notifications.batteryUsed.type)
        else
            -- Se o jogador não tiver o item, envia uma mensagem de erro
            Vanguard.notifyserver(source, Config.notifications.noBattery.title, Config.notifications.noBattery.message, 5000, Config.notifications.noBattery.type)
        end
    else
        print("Jogador não encontrado para o source:", source)
    end
end)

RegisterServerEvent('vanguard_miningsystem:removeBattery2')
AddEventHandler('vanguard_miningsystem:removeBattery2', function(playerSource)
    local source = playerSource
    print("Evento vanguard_miningsystem:removeBattery2 chamado para o jogador:", source)
    
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local battery = Config.items.battery

    if xPlayer then
        print("Jogador encontrado:", xPlayer)
        
        -- Função auxiliar para obter a quantidade de itens
        local function GetItemCount(playerSource, itemName)
            local itemCount = 1
            local hasItem = Vanguard.HasItem(playerSource, itemName)
            if hasItem then
                -- Supondo que exista uma função para obter a quantidade de itens
                --itemCount = xPlayer.getInventoryItem(itemName).count
            end
            return itemCount
        end

        local batteryCount = GetItemCount(source, battery)
        print("Quantidade de baterias:", batteryCount)
        
        if batteryCount and batteryCount > 0 then
            -- Remover 1 unidade
            Vanguard.RemoveItem(source, battery, 1)
            print("Bateria removida com sucesso.")
        else
            print("Jogador não tem baterias para remover.")
        end        
    else
        print("Jogador não encontrado para o source:", source)
    end
end)


local pickaxeRocks = {} -- Array to store pickaxe rock objects
local pickaxeRockTimers = {} -- Array to store timers for each pickaxe rock

RegisterServerEvent('vanguard_miningsystem:checkPickaxe')
AddEventHandler('vanguard_miningsystem:checkPickaxe', function()
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local pickaxeItem = Config.items.pickaxe

    if xPlayer and Vanguard.HasItem(source, pickaxeItem) then
        TriggerClientEvent('vanguard_miningsystem:startMining', source)
    else
        Vanguard.notifyserver(source, Config.notifications.noPickaxe.title, Config.notifications.noPickaxe.message, 5000, Config.notifications.noPickaxe.type)
    end
end)

RegisterServerEvent('vanguard_miningsystem:removePickaxe')
AddEventHandler('vanguard_miningsystem:removePickaxe', function()
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local pickaxeItem = Config.items.pickaxe

    if xPlayer and Vanguard.HasItem(source, pickaxeItem) then
        Vanguard.RemoveItem(source, pickaxeItem, 1)
    end
end)

RegisterServerEvent('vanguard_miningsystem:givePickaxeStone')
AddEventHandler('vanguard_miningsystem:givePickaxeStone', function(rockEntity)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local stoneItem = Config.items.stone
    -- Adiciona a pedra ao inventário do jogador
    local success = Vanguard.GiveItem(source, stoneItem, 1)
    -- Remove a pedra da lista de pedras spawnadas e do timer
    pickaxeRocks[rockEntity] = nil
    pickaxeRockTimers[rockEntity] = nil
end)

RegisterServerEvent('vanguard_miningsystem:registerPickaxeRock')
AddEventHandler('vanguard_miningsystem:registerPickaxeRock', function(rockEntity)
    pickaxeRocks[rockEntity] = source
    pickaxeRockTimers[rockEntity] = GetGameTimer() -- Registra o tempo de spawn da pedra
end)

-- Função para verificar e remover pedras da picareta que não foram coletadas após 1 minuto
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Verifica a cada segundo

        for rockEntity, spawnTime in pairs(pickaxeRockTimers) do
            if GetGameTimer() - spawnTime >= 60000 then -- 60000ms = 1 minuto
                if DoesEntityExist(rockEntity) then
                    DeleteEntity(rockEntity)
                end
                pickaxeRocks[rockEntity] = nil
                pickaxeRockTimers[rockEntity] = nil
            end
        end
    end
end)

--- mining drill normal

local drillRocks = {} -- Array to store drill rock objects
local drillRockTimers = {} -- Array to store timers for each drill rock

RegisterServerEvent('vanguard_miningsystem:checkDrill')
AddEventHandler('vanguard_miningsystem:checkDrill', function()
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local drillItem = Config.items.drill

    if xPlayer and Vanguard.HasItem(source, drillItem) then
        TriggerClientEvent('vanguard_miningsystem:startDrilling', source)
    else
        Vanguard.notifyserver(source, Config.notifications.noDrill.title, Config.notifications.noDrill.message, 3000, Config.notifications.noDrill.type)
    end
end)

RegisterServerEvent('vanguard_miningsystem:removeDrill')
AddEventHandler('vanguard_miningsystem:removeDrill', function()
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local drillItem = Config.items.drill

    if xPlayer and Vanguard.HasItem(source, drillItem) then
        Vanguard.RemoveItem(source, drillItem, 1)
    end
end)

RegisterServerEvent('vanguard_miningsystem:giveDrillStone')
AddEventHandler('vanguard_miningsystem:giveDrillStone', function(rockEntity)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local stoneItem = Config.items.stone

    -- Verifica se o jogador que está tentando recolher a pedra é o mesmo que a spawnou
    if drillRocks[rockEntity] == source then
        Vanguard.GiveItem(source, stoneItem, 1)
        drillRocks[rockEntity] = nil -- Remove a pedra da lista de pedras spawnadas
        drillRockTimers[rockEntity] = nil -- Remove o timer da pedra
    end
end)

RegisterServerEvent('vanguard_miningsystem:registerDrillRock')
AddEventHandler('vanguard_miningsystem:registerDrillRock', function(rockEntity)
    drillRocks[rockEntity] = source
    drillRockTimers[rockEntity] = GetGameTimer() -- Registra o tempo de spawn da pedra
end)

-- Função para verificar e remover pedras da furadeira que não foram coletadas após 1 minuto
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Verifica a cada segundo

        for rockEntity, spawnTime in pairs(drillRockTimers) do
            if GetGameTimer() - spawnTime >= 60000 then -- 60000ms = 1 minuto
                if DoesEntityExist(rockEntity) then
                    DeleteEntity(rockEntity)
                end
                drillRocks[rockEntity] = nil
                drillRockTimers[rockEntity] = nil
            end
        end
    end
end)

--- mining drillhand 1

local drillHandRocks = {} -- Array to store drill hand rock objects
local drillHandRockTimers = {} -- Array to store timers for each drill hand rock

RegisterServerEvent('vanguard_miningsystem:checkDrillHand')
AddEventHandler('vanguard_miningsystem:checkDrillHand', function()
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local drillHandItem = Config.items.drillHand

    if xPlayer and Vanguard.HasItem(source, drillHandItem) then
        TriggerClientEvent('vanguard_miningsystem:startDrillingHand', source)
    else
        Vanguard.notifyserver(source, Config.notifications.noDrillHand.title, Config.notifications.noDrillHand.message, 3000, Config.notifications.noDrillHand.type)
    end
end)

RegisterServerEvent('vanguard_miningsystem:removeDrillHand')
AddEventHandler('vanguard_miningsystem:removeDrillHand', function()
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local drillHandItem = Config.items.drillHand

    if xPlayer and Vanguard.HasItem(source, drillHandItem) then
        Vanguard.RemoveItem(source, drillHandItem, 1)
    end
end)

RegisterServerEvent('vanguard_miningsystem:registerDrillHandRock')
AddEventHandler('vanguard_miningsystem:registerDrillHandRock', function(rockEntity)
    drillHandRocks[rockEntity] = source
    drillHandRockTimers[rockEntity] = GetGameTimer() -- Registra o tempo de spawn da pedra
end)

RegisterServerEvent('vanguard_miningsystem:giveDrillHandStone')
AddEventHandler('vanguard_miningsystem:giveDrillHandStone', function(rockEntity)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local stoneItem = Config.items.stone

    -- Verifica se o jogador que está tentando recolher a pedra é o mesmo que a spawnou
    if drillHandRocks[rockEntity] == source then
        Vanguard.GiveItem(source, stoneItem, 1)
        drillHandRocks[rockEntity] = nil -- Remove a pedra da lista de pedras spawnadas
        drillHandRockTimers[rockEntity] = nil -- Remove o timer da pedra
    end
end)

-- Função para verificar e remover pedras da furadeira que não foram coletadas após 1 minuto
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Verifica a cada segundo

        for rockEntity, spawnTime in pairs(drillHandRockTimers) do
            if GetGameTimer() - spawnTime >= 60000 then -- 60000ms = 1 minuto
                if DoesEntityExist(rockEntity) then
                    DeleteEntity(rockEntity)
                end
                drillHandRocks[rockEntity] = nil
                drillHandRockTimers[rockEntity] = nil
            end
        end
    end
end)
---

-- Server-side event to handle tool purchase
RegisterServerEvent('buyTool')
AddEventHandler('buyTool', function(tool, price)
    local xPlayer = Vanguard.GetPlayerFromId(source)

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        Vanguard.GiveItem(source, tool, 1)
        Vanguard.notifyserver(source, Config.notifications.toolPurchased.title, string.format(Config.notifications.toolPurchased.message, tool, price), 5000, Config.notifications.toolPurchased.type)
    else
        Vanguard.notifyserver(source, Config.notifications.notEnoughMoney.title, Config.notifications.notEnoughMoney.message, 5000, Config.notifications.notEnoughMoney.type)
    end
end)

RegisterServerEvent('place_stones:removeItem')
AddEventHandler('place_stones:removeItem', function()
    local xPlayer = Vanguard.GetPlayerFromId(source)
    -- Fix: Using GetItemCount instead of GetInventoryItemCount
    local itemCount = xPlayer.getInventoryItem(Config.items.stone).count
    
    if itemCount > 0 then
        Vanguard.RemoveItem(source, Config.items.stone, itemCount)
        TriggerClientEvent('place_stones:spawnStones', source, itemCount)
        Vanguard.notifyserver(source, Config.notifications.stonePlaced.title, string.format(Config.notifications.stonePlaced.message, itemCount), 5000, Config.notifications.stonePlaced.type)
    else
        Vanguard.notifyserver(source, Config.notifications.noStone.title, Config.notifications.noStone.message, 5000, Config.notifications.noStone.type)
    end
end)

-- Evento do servidor para recolher o minério e distribuir recompensas
RegisterServerEvent('place_stones:collectOre')
AddEventHandler('place_stones:collectOre', function(playerId, stoneProp, stoneCount)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    
    -- Função para distribuir recompensas com base nas chances
    local function distributeRewards(rewards, count)
        local collectedItems = {}
        local totalChance = 0
        for _, reward in ipairs(rewards) do
            totalChance = totalChance + reward.chance
        end

        for i = 1, count do
            local rand = math.random() * totalChance
            local cumulativeChance = 0
            for _, reward in ipairs(rewards) do
                cumulativeChance = cumulativeChance + reward.chance
                if rand <= cumulativeChance then
                    collectedItems[reward.item] = (collectedItems[reward.item] or 0) + 1
                    break
                end
            end
        end

        -- Garantir que o jogador receba pelo menos um item para cada 500 pedras
        local guaranteedItems = math.floor(count / 500)
        for _, reward in ipairs(rewards) do
            if guaranteedItems > 0 then
                collectedItems[reward.item] = (collectedItems[reward.item] or 0) + guaranteedItems
            end
        end

        return collectedItems
    end

    -- Distribuir recompensas
    local collectedItems = distributeRewards(Config.miningRewards, stoneCount)

    -- Adicionar itens ao inventário do jogador
    for item, amount in pairs(collectedItems) do
        Vanguard.GiveItem(source, item, amount)
    end

    -- Remover todas as pedras de uma vez
    TriggerClientEvent('place_stones:removeAllStones', playerId)

    Vanguard.notifyserver(playerId, Config.notifications.stonePlaced.title, string.format("You collected %d ores.", stoneCount), 5000, Config.notifications.stonePlaced.type)
end)

---- npc seller

RegisterServerEvent('sellOre')
AddEventHandler('sellOre', function(item)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    local itemConfig = nil

    -- Encontrar o item na configuração
    for _, ore in ipairs(Config.oreSellingNPC.sellableOres) do
        if ore.item == item then
            itemConfig = ore
            break
        end
    end

    if itemConfig then
        -- Fix: Using the correct method to get item count
        local itemCount = xPlayer.getInventoryItem(item).count
        if itemCount > 0 then
            local totalPrice = itemConfig.price * itemCount
            Vanguard.RemoveItem(source, item, itemCount)
            xPlayer.addMoney(totalPrice)
            Vanguard.notifyserver(source, Config.notifications.oreSold.title, string.format(Config.notifications.oreSold.message, itemCount, itemConfig.displayName, totalPrice), 5000, Config.notifications.oreSold.type)
        else
            Vanguard.notifyserver(source, Config.notifications.noOre.title, string.format(Config.notifications.noOre.message, itemConfig.displayName), 5000, Config.notifications.noOre.type)
        end
    else
        Vanguard.notifyserver(source, Config.notifications.noOre.title, "Item not found in sellable ores.", 5000, Config.notifications.noOre.type)
    end
end)