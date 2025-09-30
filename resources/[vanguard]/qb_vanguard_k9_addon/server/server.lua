QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('k9:checkInventory', function(targetId, sniffableItems)
    local itemsFound = {}
    for _, item in ipairs(sniffableItems) do
        local itemCount = exports.ox_inventory:GetItemCount(targetId, item)
        if itemCount > 0 then
            table.insert(itemsFound, {
                name = item,
                count = itemCount
            })
        end
    end

    -- Retornar os itens encontrados para o cliente
    TriggerClientEvent('k9:inventoryChecked', source, itemsFound)
end)
