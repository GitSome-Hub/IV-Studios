local function openDevShop(weaponItems)
    local options = {}
    for key, info in pairs(weaponItems) do
        options[#options+1] = {
            title = info.label,
            description = key,
            onSelect = function()
                TriggerServerEvent('ivs-weapon-bridge:buy', key)
            end
        }
    end

    lib.registerContext({
        id = 'ivs_wepshop',
        title = 'Dev Weapon Shop',
        options = options
    })
    lib.showContext('ivs_wepshop')
end

RegisterNetEvent('ivs-weapon-bridge:openShop', function(items)
    openDevShop(items)
end)

-- simple command to open the dev shop
RegisterCommand((' %s'):format(Config and Config.DevShopCommand or 'wepshop'), function()
    if not (Config and Config.EnableDevShop) then return end
    -- pull server-side list (so it matches parsed metas)
    lib.callback('ivs-weapon-bridge:getItems', false, function(items)
        TriggerEvent('ivs-weapon-bridge:openShop', items)
    end)
end)

-- fetch list from server
lib.callback.register('ivs-weapon-bridge:getItems', function()
    return nil -- placeholder; handled server-side
end)
