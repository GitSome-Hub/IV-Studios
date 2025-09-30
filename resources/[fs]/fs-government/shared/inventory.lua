Inventory = {}

function Inventory.GetType()
    return Framework.GetInventory()
end

-- helper: convert {"police","ambulance"} → { police = 0, ambulance = 0 }
local function normalizeGroups(jobs)
    if not jobs then return nil end
    local groups = {}

    -- if already key-value (police = 0) then just return
    local isArray = jobs[1] ~= nil
    if not isArray then
        return jobs
    end

    for _, job in ipairs(jobs) do
        groups[job] = 0
    end
    return groups
end

if IsDuplicityVersion() then
    
    function Inventory.AddItem(source, item, count, metadata)
        local inventoryType = Inventory.GetType()
        
        if inventoryType == 'ox_inventory' then
            return exports.ox_inventory:AddItem(source, item, count, metadata)
        elseif inventoryType == 'qb-inventory' then
            local Player = Framework.GetPlayerData(source)
            if not Player then return false end
            
            local QBCore = exports['qb-core']:GetCoreObject()
            local QBPlayer = QBCore.Functions.GetPlayer(source)
            return QBPlayer.Functions.AddItem(item, count, false, metadata)
        elseif inventoryType == 'esx_inventory' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return false end
            
            xPlayer.addInventoryItem(item, count)
            return true
        end
        
        return false
    end
    
    function Inventory.RemoveItem(source, item, count)
        local inventoryType = Inventory.GetType()
        
        if inventoryType == 'ox_inventory' then
            return exports.ox_inventory:RemoveItem(source, item, count)
        elseif inventoryType == 'qb-inventory' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local QBPlayer = QBCore.Functions.GetPlayer(source)
            if not QBPlayer then return false end
            
            return QBPlayer.Functions.RemoveItem(item, count)
        elseif inventoryType == 'esx_inventory' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return false end
            
            xPlayer.removeInventoryItem(item, count)
            return true
        end
        
        return false
    end
    
    function Inventory.GetItem(source, item)
        local inventoryType = Inventory.GetType()
        
        if inventoryType == 'ox_inventory' then
            return exports.ox_inventory:GetItem(source, item)
        elseif inventoryType == 'qb-inventory' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local QBPlayer = QBCore.Functions.GetPlayer(source)
            if not QBPlayer then return nil end
            
            return QBPlayer.Functions.GetItemByName(item)
        elseif inventoryType == 'esx_inventory' then
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return nil end
            
            return xPlayer.getInventoryItem(item)
        end
        
        return nil
    end
    
    function Inventory.RegisterStash(id, label, slots, weight, owner, groups)
        local inventoryType = Inventory.GetType()
        
        if inventoryType == 'ox_inventory' then
            exports.ox_inventory:RegisterStash(id, label, slots, weight, owner, normalizeGroups(groups))
        elseif inventoryType == 'qb-inventory' then
            -- QBCore stash registration
            local QBCore = exports['qb-core']:GetCoreObject()
            if QBCore then
                -- Store stash data globally for access
                if not GlobalState.QBInventoryStashes then
                    GlobalState.QBInventoryStashes = {}
                end

                local currentStashes = GlobalState.QBInventoryStashes
                currentStashes[id] = {
                    stashid = id,
                    label = label,
                    slots = slots or 50,
                    weight = weight or 100000,
                    groups = groups or {}
                }
                GlobalState.QBInventoryStashes = currentStashes

                Utils.DebugSuccess('Registered QBCore stash: ' .. id .. ' (' .. label .. ') with ' .. (slots or 50) .. ' slots')
                Utils.DebugPrint('Groups: ' .. json.encode(groups or {}))
            end
        elseif inventoryType == 'esx_inventory' then
            -- ESX stash registration would go here if needed
        end
    end
    
    function Inventory.CreateShop(shopData)
        local inventoryType = Inventory.GetType()
        
        if inventoryType == 'ox_inventory' then
            exports.ox_inventory:RegisterShop(shopData.name, {
                name = shopData.name,
                groups = normalizeGroups(shopData.groups),
                inventory = shopData.items
            })
        elseif inventoryType == 'qb-inventory' then
            -- QBCore shop registration using proper qb-inventory CreateShop
            local QBCore = exports['qb-core']:GetCoreObject()
            if QBCore then
                local shopItems = {}

                -- Convert items to QBCore shop format (array format as per docs)
                for _, item in ipairs(shopData.inventory) do
                    shopItems[#shopItems + 1] = {
                        name = item.name,
                        price = item.price,
                        amount = item.amount or 50
                    }
                end

                -- Use proper qb-inventory CreateShop method
                if exports['qb-inventory'] then
                    local shopCoords = shopData.locations and shopData.locations[1]
                    local coords = shopCoords and vector3(shopCoords.x, shopCoords.y, shopCoords.z) or nil

                    local success, error = pcall(function()
                        exports['qb-inventory']:CreateShop({
                            name = shopData.name,
                            label = shopData.label or shopData.name,
                            coords = coords,
                            slots = #shopItems,
                            items = shopItems
                        })
                    end)

                    if success then
                        Utils.DebugSuccess('Created QBCore shop using qb-inventory: ' .. shopData.name .. ' with ' .. #shopItems .. ' items')
                        Utils.DebugPrint('Location: ' .. (coords and tostring(coords) or 'No coords'))
                    else
                        Utils.DebugError('Failed to create QBCore shop: ' .. tostring(error))
                    end
                else
                    Utils.DebugError('qb-inventory export not available for shop creation')
                end

                -- Store shop data globally for fallback access
                if not GlobalState.QBInventoryShops then
                    GlobalState.QBInventoryShops = {}
                end

                local currentShops = GlobalState.QBInventoryShops
                currentShops[shopData.name] = {
                    name = shopData.name,
                    inventory = shopItems,
                    groups = shopData.groups or {},
                    locations = shopData.locations or {}
                }
                GlobalState.QBInventoryShops = currentShops

                Utils.DebugPrint('Groups: ' .. json.encode(shopData.groups or {}))
            end
        elseif inventoryType == 'esx_inventory' then
            -- ESX shops are usually handled through esx_addoninventory
            Utils.DebugWarn('ESX shop registration not implemented - shops may need to be defined in esx_addoninventory')
        else
            Utils.DebugError('Cannot create shop for unknown inventory type: ' .. tostring(inventoryType))
        end
    end
    
else
    
    function Inventory.OpenStash(stashId)
        local inventoryType = Inventory.GetType()

        if not inventoryType then
            Utils.DebugError('No inventory system detected')
            if Framework and Framework.ShowNotification then
                Framework.ShowNotification('No inventory system found', 'error')
            end
            return
        end

        if inventoryType == 'ox_inventory' then
            if not exports.ox_inventory then
                Utils.DebugError('ox_inventory export not available')
                if Framework and Framework.ShowNotification then
                    Framework.ShowNotification('ox_inventory not available', 'error')
                end
                return
            end
            exports.ox_inventory:openInventory('stash', { id = stashId })
        elseif inventoryType == 'qb-inventory' then
            -- Use our custom server event for better permission handling
            TriggerServerEvent('fs-government:server:openQBStash', stashId)
        elseif inventoryType == 'esx_inventory' then
            TriggerServerEvent('esx_addoninventory:openInventory', 'stash', stashId)
        else
            Utils.DebugError('Unknown inventory type: ' .. tostring(inventoryType))
            if Framework and Framework.ShowNotification then
                Framework.ShowNotification('Inventory system not supported: ' .. tostring(inventoryType), 'error')
            end
        end
    end
    
    function Inventory.OpenShop(shopName)
        local inventoryType = Inventory.GetType()

        if not inventoryType then
            Utils.DebugError('No inventory system detected')
            if Framework and Framework.ShowNotification then
                Framework.ShowNotification('No inventory system found', 'error')
            end
            return
        end

        if inventoryType == 'ox_inventory' then
            if not exports.ox_inventory then
                Utils.DebugError('ox_inventory export not available')
                if Framework and Framework.ShowNotification then
                    Framework.ShowNotification('ox_inventory not available', 'error')
                end
                return
            end
            
            Utils.DebugPrint('Attempting ox_inventory:openInventory with:')
            Utils.DebugPrint('- Type: shop')
            Utils.DebugPrint('- Data: { type = "' .. shopName .. '", id = 1 }')
            
            local success, error = pcall(function()
                exports.ox_inventory:openInventory('shop', { type = shopName, id = 1 })
            end)
            
            if success then
                Utils.DebugSuccess('Shop opened successfully')
            else
                Utils.DebugError('Failed to open shop: ' .. tostring(error))
                
                -- Try legacy format as fallback
                Utils.DebugPrint('Trying legacy shop format...')
                local success2, error2 = pcall(function()
                    exports.ox_inventory:openInventory('shop', { id = shopName })
                end)
                
                if success2 then
                    Utils.DebugSuccess('Shop opened with legacy format')
                else
                    Utils.DebugError('Legacy format also failed: ' .. tostring(error2))
                    if Framework and Framework.ShowNotification then
                        Framework.ShowNotification('Failed to open shop: ' .. tostring(error), 'error')
                    end
                end
            end
        elseif inventoryType == 'qb-inventory' then
            -- Use our custom server event for better permission handling
            TriggerServerEvent('fs-government:server:openQBShop', shopName)
        elseif inventoryType == 'esx_inventory' then
            TriggerServerEvent('esx_addoninventory:openShop', shopName)
        else
            Utils.DebugError('Unknown inventory type: ' .. tostring(inventoryType))
            if Framework and Framework.ShowNotification then
                Framework.ShowNotification('Inventory system not supported: ' .. tostring(inventoryType), 'error')
            end
        end
    end
    
end

-- Server-side QBCore inventory event handlers
if IsDuplicityVersion() then
    -- Handle QBCore stash opening
    RegisterNetEvent('fs-government:server:openQBStash', function(stashId)
        local source = source
        local Player = Framework.GetPlayerData(source)
        if not Player then return end

        Utils.DebugPrint('Attempting to open stash: ' .. stashId)
        Utils.DebugPrint('Available stashes: ' .. json.encode(GlobalState.QBInventoryStashes or {}))

        local stashData = GlobalState.QBInventoryStashes and GlobalState.QBInventoryStashes[stashId]
        if not stashData then
            Utils.DebugError('Stash not found: ' .. stashId)
            Framework.ShowNotification(source, 'Stash not found: ' .. stashId, 'error')
            return
        end

        Utils.DebugPrint('Found stash data: ' .. json.encode(stashData))

        -- Check if player has permission to access this stash
        local hasPermission = false
        if not stashData.groups or #stashData.groups == 0 then
            hasPermission = true -- No group restrictions
        else
            for _, group in ipairs(stashData.groups) do
                if Player.job.name == group then
                    hasPermission = true
                    break
                end
            end
        end

        if not hasPermission then
            Framework.ShowNotification(source, 'You do not have access to this stash', 'error')
            return
        end

        -- Open the stash using qb-inventory - try multiple methods

        -- Method 1: Standard qb-inventory stash opening
        local success1 = pcall(function()
            TriggerClientEvent('inventory:client:SetCurrentStash', source, stashId)
            TriggerEvent('inventory:server:OpenInventory', source, 'stash', stashId, {
                maxweight = stashData.weight,
                slots = stashData.slots,
            })
        end)

        if success1 then
            Utils.DebugSuccess('Method 1: Standard stash events triggered for: ' .. stashId)
        else
            Utils.DebugError('Method 1 failed for stash: ' .. stashId)
        end

        -- Method 2: Try alternative qb-inventory method
        local success2 = pcall(function()
            TriggerClientEvent('qb-inventory:client:OpenInventory', source, {
                type = 'stash',
                id = stashId,
                maxweight = stashData.weight,
                slots = stashData.slots,
            })
        end)

        if success2 then
            Utils.DebugSuccess('Method 2: Alternative stash events triggered for: ' .. stashId)
        else
            Utils.DebugError('Method 2 failed for stash: ' .. stashId)
        end

        -- Method 3: Try direct qb-inventory export if available
        if exports['qb-inventory'] and exports['qb-inventory'].OpenInventory then
            local success3 = pcall(function()
                exports['qb-inventory']:OpenInventory(source, stashId)
            end)

            if success3 then
                Utils.DebugSuccess('Method 3: qb-inventory export succeeded for: ' .. stashId)
            else
                Utils.DebugError('Method 3: qb-inventory export failed for: ' .. stashId)
            end
        end
    end)

    -- Handle QBCore shop opening
    RegisterNetEvent('fs-government:server:openQBShop', function(shopName)
        local source = source
        local Player = Framework.GetPlayerData(source)
        if not Player then return end

        Utils.DebugPrint('Attempting to open shop: ' .. shopName)
        Utils.DebugPrint('Available shops: ' .. json.encode(GlobalState.QBInventoryShops or {}))

        local shopData = GlobalState.QBInventoryShops and GlobalState.QBInventoryShops[shopName]
        if not shopData then
            Utils.DebugError('Shop not found: ' .. shopName)
            Framework.ShowNotification(source, 'Shop not found: ' .. shopName, 'error')
            return
        end

        Utils.DebugPrint('Found shop data: ' .. json.encode(shopData))

        -- Check if player has permission to access this shop
        local hasPermission = false
        if not shopData.groups or #shopData.groups == 0 then
            hasPermission = true -- No group restrictions
        else
            for _, group in ipairs(shopData.groups) do
                if Player.job.name == group then
                    hasPermission = true
                    break
                end
            end
        end

        if not hasPermission then
            Framework.ShowNotification(source, 'You do not have access to this shop', 'error')
            return
        end

        -- Open the shop using qb-inventory - try multiple methods

        -- Method 1: Standard qb-inventory shop opening
        local success1 = pcall(function()
            TriggerEvent('inventory:server:OpenInventory', source, 'shop', shopName, shopData.inventory)
        end)

        if success1 then
            Utils.DebugSuccess('Method 1: Standard shop events triggered for: ' .. shopName)
        else
            Utils.DebugError('Method 1 failed for shop: ' .. shopName)
        end

        -- Method 2: Try alternative qb-inventory method
        local success2 = pcall(function()
            TriggerClientEvent('qb-inventory:client:OpenInventory', source, {
                type = 'shop',
                id = shopName,
                items = shopData.inventory
            })
        end)

        if success2 then
            Utils.DebugSuccess('Method 2: Alternative shop events triggered for: ' .. shopName)
        else
            Utils.DebugError('Method 2 failed for shop: ' .. shopName)
        end

        -- Method 3: Try qb-inventory export if available
        if exports['qb-inventory'] and exports['qb-inventory'].OpenShop then
            local success3 = pcall(function()
                exports['qb-inventory']:OpenShop(source, shopName)
            end)

            if success3 then
                Utils.DebugSuccess('Method 3: qb-inventory OpenShop export succeeded for: ' .. shopName)
            else
                Utils.DebugError('Method 3: qb-inventory OpenShop export failed for: ' .. shopName)
            end
        end
    end)
end

function Inventory.SetupArmoryStash()
    local inventoryType = Inventory.GetType()

    if inventoryType == 'ox_inventory' then
        Inventory.RegisterStash('government_armory', 'Government Armory', 50, 100000, false, Config.Government.jobs)
    elseif inventoryType == 'qb-inventory' then
        Inventory.RegisterStash('government_armory', 'Government Armory', 50, 100000, false, Config.Government.jobs)
    end
end

function Inventory.SetupSharedStash()
    local inventoryType = Inventory.GetType()

    if inventoryType == 'ox_inventory' then
        Inventory.RegisterStash('government_storage', 'Government Storage', 100, 500000, false, Config.Government.jobs)
    elseif inventoryType == 'qb-inventory' then
        Inventory.RegisterStash('government_storage', 'Government Storage', 100, 500000, false, Config.Government.jobs)
    end
end

-- server/shared/inventory.lua
function Inventory.SetupArmoryShop()
    local inventoryType = Inventory.GetType()
    
    if inventoryType == 'ox_inventory' then
        local shopItems = {}

        for _, weapon in ipairs(Config.Weapons) do
            shopItems[#shopItems+1] = { name = weapon.item, price = weapon.price }
        end

        for _, item in ipairs(Config.Items) do
            shopItems[#shopItems+1] = { name = item.item, price = item.price }
        end

        local shopData = {
            name = 'Government Armory',
            inventory = shopItems,
            locations = {
                Config.Locations.armory.coords
            },
            groups = normalizeGroups(Config.Government.jobs)
        }

        Utils.DebugPrint("Attempting to register shop with data:")
        Utils.DebugPrint("- Name: " .. shopData.name)
        Utils.DebugPrint("- Items count: " .. #shopItems)
        Utils.DebugPrint("- Groups: " .. json.encode(shopData.groups))
        Utils.DebugPrint("- Location: " .. tostring(shopData.locations[1]))
        
        local success, error = pcall(function()
            exports.ox_inventory:RegisterShop('government_armory_shop', shopData)
        end)
        
        if success then
            Utils.DebugSuccess("Successfully registered Armory Shop with "..#shopItems.." items")
        else
            Utils.DebugError("Failed to register Armory Shop: " .. tostring(error))
        end
    elseif inventoryType == 'qb-inventory' then
        local shopItems = {}

        for _, weapon in ipairs(Config.Weapons) do
            shopItems[#shopItems+1] = { name = weapon.item, price = weapon.price }
        end

        for _, item in ipairs(Config.Items) do
            shopItems[#shopItems+1] = { name = item.item, price = item.price }
        end

        local shopData = {
            name = 'government_armory_shop',
            inventory = shopItems,
            locations = {
                Config.Locations.armory.coords
            },
            groups = Config.Government.jobs
        }

        Utils.DebugPrint("Setting up QBCore armory shop with " .. #shopItems .. " items")
        Inventory.CreateShop(shopData)
    elseif inventoryType == 'esx_inventory' then
        Utils.DebugPrint("ESX armory shop setup - shop should be configured in esx_addoninventory")
        Utils.DebugPrint("Shop will use shop name: government_armory_shop")
    else
        Utils.DebugWarn("Unknown inventory type '" .. tostring(inventoryType) .. "' - armory shop not configured")
    end
end

