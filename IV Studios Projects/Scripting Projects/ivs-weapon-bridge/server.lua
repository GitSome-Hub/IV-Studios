local weaponItems = {}  -- map: 'weapon_xxx' -> {label=..., key=...}

local function uc_first(s)
    s = s or ''
    return (s:gsub("^%l", string.upper))
end

local function labelize(name) -- 'AKM_74U' -> 'AKM 74U'
    name = name:gsub("^WEAPON_", "")
    name = name:gsub("_", " ")
    return name
end

local function buildWeaponItems()
    weaponItems = {}

    for _, res in ipairs(Config.MetaResources) do
        -- read weapons.meta (some packs use different filenames; add more tries if needed)
        local xml = LoadResourceFile(res, 'weapons.meta')
                or LoadResourceFile(res, 'weaponweapons.meta')
                or LoadResourceFile(res, 'meta/weapons.meta')

        if xml and #xml > 0 then
            -- find every <Name>WEAPON_XXXX</Name>
            for wep in xml:gmatch("<Name>%s*(WEAPON_[A-Z0-9_]+)%s*</Name>") do
                local key = wep:lower()               -- weapon_akm
                local label = labelize(wep)           -- AKM
                weaponItems[key] = { label = label, key = key }
            end
        else
            print(('[ivs-weapon-bridge] WARNING: could not read weapons.meta in resource "%s"'):format(res))
        end
    end

    print(('[ivs-weapon-bridge] detected %d weapon(s)'):format((function(t) local c=0 for _ in pairs(t) do c=c+1 end return c end)(weaponItems)))
end

-- add ox_inventory item on demand (no need to edit items.lua)
-- ox_inventory will accept unknown items if they follow weapon_ naming; if your build requires definition,
-- we fall back to registering a basic runtime item via metadata handler.
local function addWeaponItem(source, item)
    local xItem = exports.ox_inventory:Items(item)
    if not xItem then
        -- register a minimal runtime item so ox knows it (safe on modern ox)
        exports.ox_inventory:RegisterItems({
            [item] = {
                label = (weaponItems[item] and weaponItems[item].label) or item,
                weight = Config.DefaultWeight,
                stack = false,
                close = true,
                -- you can add image later in web/images
            }
        })
    end
    return exports.ox_inventory:AddItem(source, item, 1)
end

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        buildWeaponItems()
    end
end)

RegisterCommand(Config.GiveCommand, function(src, args)
    if src == 0 then
        print(('[ivs-weapon-bridge] usage: /%s <shortname> (in-game)'):format(Config.GiveCommand))
        return
    end
    if Config.AdminOnly and not IsPlayerAceAllowed(src, 'group.admin') then
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='Not authorized' })
        return
    end

    local short = (args[1] or ''):upper()                       -- AKM
    local wep = ('weapon_%s'):format(short:lower())             -- weapon_akm

    if not weaponItems[wep] then
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='Unknown weapon: '..short })
        return
    end

    local ok = addWeaponItem(src, wep)
    if ok then
        TriggerClientEvent('ox_lib:notify', src, { type='success', description=('Gave %s'):format(weaponItems[wep].label) })
    else
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='Failed to add item' })
    end
end, true)

-- server target for buying from the dev menu
RegisterNetEvent('ivs-weapon-bridge:buy', function(wep)
    local src = source
    if not weaponItems[wep] then
        return TriggerClientEvent('ox_lib:notify', src, { type='error', description='Unknown weapon' })
    end
    -- price logic (dev: zero). You can integrate with your money system later.
    addWeaponItem(src, wep)
    TriggerClientEvent('ox_lib:notify', src, { type='success', description=('Received %s'):format(weaponItems[wep].label) })
end)

-- optional helper: print items.lua chunk (one-time copy/paste if you ever want permanence)
RegisterCommand('genweaponitems', function(src)
    if src ~= 0 then return end
    print('--- BEGIN items.lua snippet ---')
    for key, info in pairs(weaponItems) do
        print(("[\'%s\'] = { label = '%s', weight = %d, stack = false, close = true },")
            :format(key, info.label, Config.DefaultWeight))
    end
    print('--- END items.lua snippet ---')
end, true)

lib.callback.register('ivs-weapon-bridge:getItems', function(src)
    return weaponItems
end)
