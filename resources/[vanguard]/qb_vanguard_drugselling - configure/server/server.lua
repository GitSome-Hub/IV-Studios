QBCore = exports['qb-core']:GetCoreObject()

-- In your server script
RegisterNetEvent('vanguard_drugselling:sellDrug')
AddEventHandler('vanguard_drugselling:sellDrug', function(drugName, finalPrice)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return end
    
    local drugData = Config.Drugs[drugName]
    if not drugData then return end
    
    local drugItem = drugData.item
    local drugCount = xPlayer.Functions.GetItemByName(drugItem).amount
    local amountSold = 0

    if drugCount >= 1 then
        amountSold = math.min(drugCount, math.random(1, 5))
    end

    if amountSold > 0 then
        xPlayer.Functions.RemoveItem(drugItem, amountSold)
        
        -- Multiplica o preço final pela quantidade vendida
        local totalPrice = finalPrice * amountSold
        
        -- Usa o item de dinheiro sujo configurável
        xPlayer.Functions.AddItem(Config.BlackMoneyItem, totalPrice)

        local message = string.format(drugData.message, amountSold, totalPrice)
        TriggerClientEvent('ox_lib:notify', source, {
            title = message,
            position = "top",
            type = "success",
            icon = drugData.icon,
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Not enough " .. drugData.label,
            position = "top",
            type = "error",
            icon = drugData.icon,
        })
    end
end)

-- Event to check the number of police officers
RegisterNetEvent('checkC')
AddEventHandler('checkC', function()
    local xPlayers = QBCore.Functions.GetPlayers()
    local cops = 0
    for _, playerId in pairs(xPlayers) do
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
        for _, job in ipairs(Config.AlertJobs) do
            if xPlayer.PlayerData.job.name == job then
                cops = cops + 1
                break
            end
        end
    end
    TriggerClientEvent("checkC", source, cops)
end)

-- Event to notify police
RegisterNetEvent('drug:notifyPolice')
AddEventHandler('drug:notifyPolice', function(location)
    TriggerClientEvent('drug:notifyPolice', -1, location)
end)