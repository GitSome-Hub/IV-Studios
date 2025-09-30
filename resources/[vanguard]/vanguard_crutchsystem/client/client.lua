-- Initialize Vanguard Bridge
Vanguard = exports["Vanguard_Bridge"]:Vanguard()

-- Shared variables
local isUsingCrutch = false
local isInWheelchair = false
local crutchObject = nil
local wheelchairObj = nil
local walkStyle = nil
local endTime = 0
local activeTextUI = nil
local npcPed = nil
local zone = nil

-- Models and Animations
local crutchModel = `prop_mads_crutch01`
local clipSet = "move_lester_CaneUp"
local pickupAnim = {
    dict = "pickup_object",
    name = "pickup_low"
}

-- Time Conversion Function
local function parseTime(timeStr)
    local minutes = tonumber(timeStr)
    if not minutes then
        return nil
    end
    return minutes
end

-- Animation Loading Functions
local function LoadClipSet(set)
    RequestClipSet(set)
    while not HasClipSetLoaded(set) do
        Wait(10)
    end
end

local function LoadAnimDict(dict)
    Vanguard.LoadModel(dict)
end

-- TextUI Functions
local function updateTextUI(itemType)
    if activeTextUI then
        local timeLeft = endTime - GetGameTimer()
        if timeLeft > 0 then
            local timeString = itemType == Config.Items.Wheelchair.name and Config.UI.Timer.wheelchair or Config.UI.Timer.crutch
            lib.showTextUI(string.format(timeString, Config.Utils.formatTimeRemaining(timeLeft)))
        else
            lib.hideTextUI()
            activeTextUI = nil
            
            if itemType == Config.Items.Crutch.name and isUsingCrutch then
                UnequipCrutch()
            elseif itemType == Config.Items.Wheelchair.name and isInWheelchair then
                DeleteWheelchair()
            end
            
            local notif = itemType == Config.Items.Wheelchair.name and Config.Notifications.WheelchairRecovery or Config.Notifications.CrutchRecovery
            Vanguard.notifyclient(notif.title, notif.message, 5000, notif.type)
        end
    end
end

local function startTextUIThread()
    CreateThread(function()
        while activeTextUI do
            updateTextUI(activeTextUI)
            Wait(1000)
        end
    end)
end

-- Weapon Check Thread
local function startWeaponCheckThread()
    CreateThread(function()
        while isInWheelchair or isUsingCrutch do
            if Config.DisableWeapons then
                local ped = PlayerPedId()
                local _, currentWeapon = GetCurrentPedWeapon(ped, true)
                if currentWeapon ~= `WEAPON_UNARMED` then
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                    Vanguard.notifyclient(Config.Notifications.WeaponBlocked.title, 
                        Config.Notifications.WeaponBlocked.message, 
                        5000, Config.Notifications.WeaponBlocked.type)
                end
            end
            Wait(250)
        end
    end)
end

-- Movement Restriction Functions
local function DisableControls()
    CreateThread(function()
        while isInWheelchair or isUsingCrutch do
            local playerPed = PlayerPedId()
            
            if isInWheelchair then
                if not Config.Movement.Wheelchair.AllowExit then
                    DisableControlAction(0, 75, true)  -- Exit vehicle
                    DisableControlAction(0, 23, true)  -- Enter vehicle
                end
                if not Config.Movement.Wheelchair.AllowJumping then
                    DisableControlAction(0, 22, true)  -- Jump
                end
                if not Config.Movement.Wheelchair.AllowSprinting then
                    DisableControlAction(0, 21, true)  -- Sprint
                    SetPedMoveRateOverride(playerPed, 1.0)
                end
                if not Config.Movement.Wheelchair.AllowRagdoll then
                    SetPedCanRagdoll(playerPed, false)
                end
                if not Config.Movement.Wheelchair.AllowCombat then
                    DisableControlAction(0, 24, true)   -- Attack
                    DisableControlAction(0, 25, true)   -- Aim
                    DisableControlAction(0, 47, true)   -- Weapon
                    DisableControlAction(0, 58, true)   -- Weapon
                    DisableControlAction(0, 140, true)  -- Melee Attack Light
                    DisableControlAction(0, 141, true)  -- Melee Attack Heavy
                    DisableControlAction(0, 142, true)  -- Melee Attack Alternate
                    DisableControlAction(0, 143, true)  -- Melee Block
                    DisableControlAction(0, 263, true)  -- Melee Attack 1
                    DisableControlAction(0, 264, true)  -- Melee Attack 2
                    -- Disable weapon wheel
                    DisableControlAction(0, 37, true)   -- Weapon wheel
                    DisableControlAction(0, 157, true)  -- Weapon 1
                    DisableControlAction(0, 158, true)  -- Weapon 2
                    DisableControlAction(0, 160, true)  -- Weapon 3
                    DisableControlAction(0, 164, true)  -- Weapon 4
                end
            elseif isUsingCrutch then
                -- Core movement restrictions for crutch
                DisableControlAction(0, 21, true)  -- Sprint
                DisableControlAction(0, 22, true)  -- Jump
                DisableControlAction(0, 24, true)  -- Attack
                DisableControlAction(0, 25, true)  -- Aim
                DisableControlAction(0, 37, true)  -- Weapon wheel
                DisableControlAction(0, 44, true)  -- Cover
                DisableControlAction(0, 47, true)  -- Weapon
                DisableControlAction(0, 58, true)  -- Weapon
                DisableControlAction(0, 140, true) -- Melee Attack Light
                DisableControlAction(0, 141, true) -- Melee Attack Heavy
                DisableControlAction(0, 142, true) -- Melee Attack Alternate
                DisableControlAction(0, 143, true) -- Melee Block
                DisableControlAction(0, 263, true) -- Melee Attack 1
                DisableControlAction(0, 264, true) -- Melee Attack 2
                DisableControlAction(0, 157, true) -- Weapon 1
                DisableControlAction(0, 158, true) -- Weapon 2
                DisableControlAction(0, 160, true) -- Weapon 3
                DisableControlAction(0, 164, true) -- Weapon 4
                
                -- Force walking speed
                SetPedMoveRateOverride(playerPed, Config.Movement.Crutch.MovementSpeed)
                
                -- Prevent ragdoll
                SetPedCanRagdoll(playerPed, false)
                
                -- Remove all weapons
                RemoveAllPedWeapons(playerPed, true)
                
                -- Additional movement restrictions
                if IsPedJumping(playerPed) or IsPedSprinting(playerPed) or IsPedRunning(playerPed) then
                    ClearPedTasksImmediately(playerPed)
                end
                
                -- Reset stance if trying to enter combat
                if GetPedCombatMovement(playerPed) ~= 0 then
                    SetPedCombatMovement(playerPed, 0)
                end
            end
            
            -- Notification handling
            if IsDisabledControlJustPressed(0, 22) then
                Vanguard.notifyclient(Config.Notifications.MovementRestricted.title, 
                    Config.Notifications.MovementRestricted.messages.jump, 
                    5000, Config.Notifications.MovementRestricted.type)
            elseif IsDisabledControlJustPressed(0, 21) then
                Vanguard.notifyclient(Config.Notifications.MovementRestricted.title, 
                    Config.Notifications.MovementRestricted.messages.sprint, 
                    5000, Config.Notifications.MovementRestricted.type)
            elseif isInWheelchair and IsDisabledControlJustPressed(0, 75) then
                Vanguard.notifyclient(Config.Notifications.MovementRestricted.title, 
                    Config.Notifications.MovementRestricted.messages.exit, 
                    5000, Config.Notifications.MovementRestricted.type)
            elseif (IsDisabledControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 140) or IsDisabledControlJustPressed(0, 141)) then
                Vanguard.notifyclient(Config.Notifications.MovementRestricted.title, 
                    Config.Notifications.MovementRestricted.messages.fight, 
                    5000, Config.Notifications.MovementRestricted.type)
            end
            
            Wait(0)
        end
        
        -- Reset player state when exiting wheelchair/crutch
        local playerPed = PlayerPedId()
        SetPedCanRagdoll(playerPed, true)
        SetPedMoveRateOverride(playerPed, 1.0)
        -- Re-enable combat movement
        SetPedCombatMovement(playerPed, 3)
    end)
end



-- Check Functions
local function CanPlayerEquipCrutch()
    local playerPed = PlayerPedId()
    
    if IsPedInAnyVehicle(playerPed, false) then
        return false, Config.Notifications.NoPermission.message
    elseif IsEntityDead(playerPed) then
        return false, Config.Notifications.NoPermission.message
    elseif IsPedInMeleeCombat(playerPed) then
        return false, Config.Notifications.NoPermission.message
    elseif IsPedFalling(playerPed) then
        return false, Config.Notifications.NoPermission.message
    elseif IsPedRagdoll(playerPed) then
        return false, Config.Notifications.NoPermission.message
    end
    return true
end

-- Crutch Object Functions
local function CreateCrutch()
    Vanguard.LoadObject(crutchModel)
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    crutchObject = CreateObject(crutchModel, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(crutchObject, playerPed, 70, 1.18, -0.36, -0.20, -20.0, -87.0, -20.0, true, true, false, true, 1, true)
end

local function DeleteCrutchObject()
    if DoesEntityExist(crutchObject) then
        DeleteEntity(crutchObject)
        crutchObject = nil
    end
end

-- Main Functions
local function UnequipCrutch()
    if not isUsingCrutch then return end
    
    DeleteCrutchObject()
    isUsingCrutch = false
    
    local playerPed = PlayerPedId()
    if walkStyle then
        LoadClipSet(walkStyle)
        SetPedMovementClipset(playerPed, walkStyle, 1.0)
        RemoveClipSet(walkStyle)
    else
        ResetPedMovementClipset(playerPed, 1.0)
    end
    
    SetPlayerSprint(PlayerId(), true)
    
    if activeTextUI then
        lib.hideTextUI()
        activeTextUI = nil
    end
end

local function EquipCrutch(time)
    if isUsingCrutch then return end
    
    local canEquip, msg = CanPlayerEquipCrutch()
    if not canEquip then
        Vanguard.notifyclient(Config.Notifications.NoPermission.title, msg, 5000, Config.Notifications.NoPermission.type)
        return
    end
    
    local playerPed = PlayerPedId()
    LoadClipSet(clipSet)
    SetPedMovementClipset(playerPed, clipSet, 1.0)
    RemoveClipSet(clipSet)
    
    CreateCrutch()
    isUsingCrutch = true
    SetPlayerSprint(PlayerId(), false)
    
    if time then
        endTime = GetGameTimer() + time
        activeTextUI = Config.Items.Crutch.name
        startTextUIThread()
        
        -- Add timeout to automatically remove crutch when time expires
        Citizen.SetTimeout(time, function()
            if isUsingCrutch then
                UnequipCrutch()
            end
        end)
    end
    
    startWeaponCheckThread()
    DisableControls()
end

-- Wheelchair Functions
local function CreateWheelchair()
    local model = `iak_wheelchair`
    Vanguard.LoadModel(model)
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    wheelchairObj = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
    SetEntityAsMissionEntity(wheelchairObj, true, true)
    SetVehicleDoorsLocked(wheelchairObj, 2)
    
    SetPedIntoVehicle(playerPed, wheelchairObj, -1)
end

local function DeleteWheelchair()
    if DoesEntityExist(wheelchairObj) then
        DeleteEntity(wheelchairObj)
        wheelchairObj = nil
    end
    isInWheelchair = false
    
    if activeTextUI == Config.Items.Wheelchair.name then
        Vanguard.notifyclient(Config.Notifications.WheelchairRecovery.title, 
            Config.Notifications.WheelchairRecovery.message, 
            5000, Config.Notifications.WheelchairRecovery.type)
        lib.hideTextUI()
        activeTextUI = nil
    end
end

-- Shop Functions
local function hasShopAccess()
    local PlayerData = Vanguard.GetPlayerData()
    
    for group, grade in pairs(Config.Shop.Groups) do
        if PlayerData.job.name == group and PlayerData.job.grade >= grade then
            return true
        end
    end
    return false
end

local function CreateShopNPC()
    if not Config.Shop.Enabled then return end
    
    local model = Config.Shop.NPC.model
    Vanguard.LoadModel(GetHashKey(model))
    
    npcPed = CreatePed(4, GetHashKey(model), Config.Shop.Location.x, Config.Shop.Location.y, Config.Shop.Location.z - 1.0, Config.Shop.NPC.heading, false, true)
    SetEntityHeading(npcPed, Config.Shop.NPC.heading)
    FreezeEntityPosition(npcPed, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    
    if Config.Shop.NPC.scenario then
        TaskStartScenarioInPlace(npcPed, Config.Shop.NPC.scenario, 0, true)
    end
end

local function CreateShopZone()
    zone = lib.zones.box({
        coords = Config.Shop.Location,
        size = vec3(4, 4, 4),
        rotation = 0.0,
        debug = false,
        inside = function()
            lib.showTextUI(Config.UI.Shop.prompt)
        end,
        onExit = function()
            lib.hideTextUI()
        end
    })
end

local function OpenShop()
    if not hasShopAccess() then
        Vanguard.notifyclient(Config.Notifications.NoAccess.title, 
            Config.Notifications.NoAccess.message, 
            5000, Config.Notifications.NoAccess.type)
        return
    end
    
    exports.ox_inventory:openInventory('shop', { type = 'medical_shop', id = 1 })
end

local function OpenPlayerMenu(itemName, players)
    local selfOption = {
        label = Config.UI.Menu.selfOption,
        value = GetPlayerServerId(PlayerId())
    }
    table.insert(players, 1, selfOption)
    
    local options = {}
    for _, player in ipairs(players) do
        table.insert(options, {
            label = player.name,
            value = player.id
        })
    end
    
    local playerInput = lib.inputDialog(Config.UI.Menu.title, {
        {
            type = 'select',
            label = Config.UI.Menu.title,
            options = options,
            required = true
        },
        {
            type = 'input',
            label = Config.UI.Menu.timeLabel,
            description = Config.UI.Menu.timeHelp,
            required = true
        }
    })
    
    if playerInput then
        local targetId = playerInput[1]
        local timeStr = playerInput[2]
        
        local time = parseTime(timeStr)
        if not time then
            Vanguard.notifyclient(Config.Notifications.InvalidTime.title, 
                Config.Notifications.InvalidTime.message, 
                5000, Config.Notifications.InvalidTime.type)
            return
        end
        
        local itemType = itemName == Config.Items.Wheelchair.name and "Wheelchair" or "Crutch"
        local minTime = Config.Time[itemType].min
        local maxTime = Config.Time[itemType].max
        
        if time < minTime or time > maxTime then
            Vanguard.notifyclient(Config.Notifications.TimeRange.title,
                string.format(Config.Notifications.TimeRange.message, minTime, maxTime),
                5000, Config.Notifications.TimeRange.type)
            return
        end
        
        TriggerServerEvent('medical:applyItem', itemName, targetId, time)
    end
end

-- Initialize Shop
CreateThread(function()
    Wait(1000)
    
    if Config.Shop.Enabled then
        CreateShopNPC()
        CreateShopZone()
        
        RegisterCommand('openmedicalshop', function()
            if zone and zone:contains(GetEntityCoords(PlayerPedId())) then
                OpenShop()
            end
        end)
        
        RegisterKeyMapping('openmedicalshop', 'Open Medical Shop', 'keyboard', 'E')
    end
end)

-- Events
RegisterNetEvent('crutches:forceEquip')
AddEventHandler('crutches:forceEquip', function(state, time)
    if state then
        EquipCrutch(time * 1000)
    else
        UnequipCrutch()
    end
end)

RegisterNetEvent('wheelchair:setPlayerState')
AddEventHandler('wheelchair:setPlayerState', function(state, time)
    if state then
        isInWheelchair = true
        CreateWheelchair()
        
        endTime = GetGameTimer() + time
        activeTextUI = Config.Items.Wheelchair.name
        startTextUIThread()
        startWeaponCheckThread()
        DisableControls()
        
        Citizen.SetTimeout(time, function()
            if isInWheelchair then
                DeleteWheelchair()
            end
        end)
    else
        DeleteWheelchair()
    end
end)

RegisterNetEvent('medical:notify')
AddEventHandler('medical:notify', function(title, message, type)
    Vanguard.notifyclient(title, message, 5000, type)
end)

RegisterNetEvent('medical:openSelectionMenu')
AddEventHandler('medical:openSelectionMenu', function(itemName, players)
    OpenPlayerMenu(itemName, players)
end)

-- Exports
exports('EquipCrutch', EquipCrutch)
exports('UnequipCrutch', UnequipCrutch)
exports('SetWalkStyle', function(walk)
    walkStyle = walk
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if isInWheelchair then
            DeleteWheelchair()
        end
        if isUsingCrutch then
            UnequipCrutch()
        end
        if npcPed then
            DeleteEntity(npcPed)
        end
        if zone then
            zone:remove()
        end
        if activeTextUI then
            lib.hideTextUI()
        end
        
        local playerPed = PlayerPedId()
        SetPedCanRagdoll(playerPed, true)
        SetPedMoveRateOverride(playerPed, 1.0)
    end
end)