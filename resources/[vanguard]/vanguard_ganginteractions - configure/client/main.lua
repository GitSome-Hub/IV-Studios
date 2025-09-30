local isMenuOpen = false
local currentJob = nil
local jobUpdateInterval = 5000 -- 5 seconds
local framework = nil

-- Framework Detection and Initialization
local function DetectFramework()
    if GetResourceState('es_extended') == 'started' then
        framework = 'esx'
        RegisterNetEvent('esx:setJob')
        AddEventHandler('esx:setJob', function(job)
            if job then
                currentJob = job
                if isMenuOpen and not IsJobAuthorized() then
                    ToggleRadialMenu()
                end
            end
        end)
    elseif GetResourceState('qb-core') == 'started' then
        framework = 'qbcore'
        RegisterNetEvent('QBCore:Client:OnJobUpdate')
        AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
            if job then
                currentJob = job
                if isMenuOpen and not IsJobAuthorized() then
                    ToggleRadialMenu()
                end
            end
        end)
    end
end

-- Função auxiliar para verificar se um valor existe em uma tabela
function table.contains(table, element)
    if not table or not element then return false end
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Initialize and update job functions
local function InitializeJob()
    if framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        if ESX then
            local playerData = ESX.GetPlayerData()
            if playerData then
                currentJob = playerData.job
            end
        end
    elseif framework == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        if QBCore then
            local playerData = QBCore.Functions.GetPlayerData()
            if playerData then
                currentJob = playerData.job
            end
        end
    end
    -- Set a default job if none is found
    if not currentJob then
        currentJob = { name = 'unemployed', grade = 0 }
    end
end

local function UpdateJob()
    if framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        if ESX then
            local playerData = ESX.GetPlayerData()
            if playerData and playerData.job then
                if not currentJob or currentJob.name ~= playerData.job.name or currentJob.grade ~= playerData.job.grade then
                    currentJob = playerData.job
                    if isMenuOpen and not IsJobAuthorized() then
                        ToggleRadialMenu()
                    end
                end
            end
        end
    elseif framework == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        if QBCore then
            local playerData = QBCore.Functions.GetPlayerData()
            if playerData and playerData.job then
                if not currentJob or currentJob.name ~= playerData.job.name or currentJob.grade.level ~= playerData.job.grade.level then
                    currentJob = playerData.job
                    if isMenuOpen and not IsJobAuthorized() then
                        ToggleRadialMenu()
                    end
                end
            end
        end
    end
end

-- Check job authorization
local function IsJobAuthorized()
    if not Config.JobRequirement then return true end
    if not currentJob then 
        InitializeJob()
        if not currentJob then return false end
    end
    return currentJob and currentJob.name and table.contains(Config.AllowedJobs, currentJob.name)
end

-- Framework detection and initialization
Citizen.CreateThread(function()
    DetectFramework()
    Wait(1000) -- Wait for framework to fully initialize
    InitializeJob()
end)

-- Job update thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(jobUpdateInterval)
        UpdateJob()
    end
end)

-- Key handling
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Config.MenuActivationMode == "UseKey" or Config.MenuActivationMode == "Both" then
            if IsControlJustPressed(0, Config.OpenKey) then
                if not Config.JobRequirement or IsJobAuthorized() then
                    ToggleRadialMenu()
                end
            end
        end
    end
end)

-- Command handling
if Config.MenuActivationMode == "UseCommand" or Config.MenuActivationMode == "Both" then
    RegisterCommand(Config.MenuCommand, function()
        if not Config.JobRequirement or IsJobAuthorized() then
            ToggleRadialMenu()
        end
    end, false)
end

function ToggleRadialMenu()
    if not isMenuOpen and Config.JobRequirement and not IsJobAuthorized() then
        return
    end
    
    isMenuOpen = not isMenuOpen
    SetNuiFocus(isMenuOpen, isMenuOpen)
    SendNUIMessage({
        type = "toggleMenu",
        status = isMenuOpen,
        options = FilterMenuOptions()
    })
end

function FilterMenuOptions()
    local filteredOptions = {}
    for _, option in ipairs(Config.MenuOptions) do
        if Config.Systems[option.system] then
            table.insert(filteredOptions, option)
        end
    end
    return filteredOptions
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('openSecondaryMenu', function(data, cb)
    if not IsJobAuthorized() then
        cb('not_authorized')
        return
    end

    local secondaryOptions = {}
    for _, option in ipairs(Config.MenuOptions) do
        if option.id == data.id and option.secondaryOptions then
            secondaryOptions = option.secondaryOptions
            break
        end
    end

    SendNUIMessage({
        type = "toggleSecondaryMenu",
        status = true,
        options = secondaryOptions
    })

    cb('ok')
end)

RegisterNUICallback('selectOption', function(data, cb)
    if not IsJobAuthorized() then
        cb('not_authorized')
        return
    end

    local optionId = data.id
    
    if optionId == 'placeBag' or optionId == 'removeBag' then
        if Config.Systems.Bag then
            TriggerEvent('radial:handleBag', optionId)
        end
    elseif optionId == 'putInTrunk' or optionId == 'removeFromTrunk' then
        if Config.Systems.CarTrunk then
            TriggerEvent('radial:handleTrunk', optionId)
        end
    elseif optionId == 'cuffPlayer' or optionId == 'uncuffPlayer' then
        if Config.Systems.Cuff then
            TriggerEvent('radial:handleCuffs', optionId)
        end
    elseif optionId == 'carryPlayer' or optionId == 'dropPlayer' then
        if Config.Systems.Carry then
            TriggerEvent('radial:handleCarry', optionId)
        end
    elseif optionId == 'rob' then
        if Config.Systems.Robbery then
            TriggerEvent('radial:handleRob')
        end
    elseif optionId == 'flattire' then
        if Config.Systems.FlatTire then
            TriggerEvent('radial:handleFlatTire')
        end
    elseif optionId == 'makehostage' then
        if Config.Systems.Hostage then
            TriggerEvent('radial:handleHostage')
        end
    end

    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Command handling for fast actions
local function registerFastActionCommands()
    -- Robbery
    if Config.MenuOptions[1].fastAction and Config.MenuOptions[1].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[1].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.Robbery then
                TriggerEvent('radial:handleRob')
            end
        end, false)
    end

    -- Cuff (Cuff Player)
    if Config.MenuOptions[2].secondaryOptions[1].fastAction and Config.MenuOptions[2].secondaryOptions[1].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[2].secondaryOptions[1].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.Cuff then
                TriggerEvent('radial:handleCuffs', 'cuffPlayer')
            end
        end, false)
    end

    -- Cuff (Uncuff Player)
    if Config.MenuOptions[2].secondaryOptions[2].fastAction and Config.MenuOptions[2].secondaryOptions[2].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[2].secondaryOptions[2].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.Cuff then
                TriggerEvent('radial:handleCuffs', 'uncuffPlayer')
            end
        end, false)
    end

    -- Bag (Place Bag)
    if Config.MenuOptions[3].secondaryOptions[1].fastAction and Config.MenuOptions[3].secondaryOptions[1].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[3].secondaryOptions[1].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.Bag then
                TriggerEvent('radial:handleBag', 'placeBag')
            end
        end, false)
    end

    -- Bag (Remove Bag)
    if Config.MenuOptions[3].secondaryOptions[2].fastAction and Config.MenuOptions[3].secondaryOptions[2].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[3].secondaryOptions[2].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.Bag then
                TriggerEvent('radial:handleBag', 'removeBag')
            end
        end, false)
    end

    -- Car Trunk (Put in Trunk)
    if Config.MenuOptions[4].secondaryOptions[1].fastAction and Config.MenuOptions[4].secondaryOptions[1].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[4].secondaryOptions[1].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.CarTrunk then
                TriggerEvent('radial:handleTrunk', 'putInTrunk')
            end
        end, false)
    end

    -- Car Trunk (Remove from Trunk)
    if Config.MenuOptions[4].secondaryOptions[2].fastAction and Config.MenuOptions[4].secondaryOptions[2].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[4].secondaryOptions[2].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.CarTrunk then
                TriggerEvent('radial:handleTrunk', 'removeFromTrunk')
            end
        end, false)
    end

    -- Carry (Carry Player)
    if Config.MenuOptions[5].secondaryOptions[1].fastAction and Config.MenuOptions[5].secondaryOptions[1].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[5].secondaryOptions[1].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.Carry then
                TriggerEvent('radial:handleCarry', 'carryPlayer')
            end
        end, false)
    end

    -- Carry (Drop Player)
    if Config.MenuOptions[5].secondaryOptions[2].fastAction and Config.MenuOptions[5].secondaryOptions[2].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[5].secondaryOptions[2].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.Carry then
                TriggerEvent('radial:handleCarry', 'dropPlayer')
            end
        end, false)
    end

    -- Flat Tire
    if Config.MenuOptions[6].fastAction and Config.MenuOptions[6].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[6].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.FlatTire then
                TriggerEvent('radial:handleFlatTire')
            end
        end, false)
    end

    -- Hostage
    if Config.MenuOptions[7].fastAction and Config.MenuOptions[7].fastAction.enabled then
        RegisterCommand(Config.MenuOptions[7].fastAction.command, function()
            if not IsJobAuthorized() then return end
            if Config.Systems.Hostage then
                TriggerEvent('radial:handleHostage')
            end
        end, false)
    end
end

-- Register commands after framework detection
Citizen.CreateThread(function()
    Wait(2000) -- Wait for framework and job initialization
    registerFastActionCommands()
end)

local isRobbing = false

local function searchPlayer(player)
    if Config.inventory == 'ox' then
        exports.ox_inventory:openNearbyInventory()
    elseif Config.inventory == 'qs' then
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", GetPlayerServerId(player))
    elseif Config.inventory == 'mf' then
        local serverId = GetPlayerServerId(player)
        Vanguard.TriggerServerCallback("esx:getOtherPlayerData", function(data) 
            if type(data) ~= "table" or not data.identifier then
                return
            end
            exports["mf-inventory"]:openOtherInventory(data.identifier)
        end, serverId)
    elseif Config.inventory == 'cheeza' then
        TriggerEvent("inventory:openPlayerInventory", GetPlayerServerId(player), true)
    elseif Config.inventory == 'custom' then
        -- INSERT CUSTOM SEARCH PLAYER FOR YOUR INVENTORY
    end
end

RegisterNetEvent('radial:handleRob')
AddEventHandler('radial:handleRob', function()
    local playerPed = PlayerPedId()
    local closestPlayer, closestDistance = Vanguard.getClosestPlayer()
    
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local targetPed = GetPlayerPed(closestPlayer)
        
        if DoesEntityExist(targetPed) then
            if not IsPedDeadOrDying(targetPed) then
                TriggerServerEvent('radial:searchPlayer', GetPlayerServerId(closestPlayer))
            else
                Vanguard.notifyclient(Config.Notifications.DeadPlayerTitle, Config.Notifications.DeadPlayerMessage, 3000, "error")
            end
        end
    else
        Vanguard.notifyclient(Config.Notifications.NoPlayerNearbyTitle, Config.Notifications.NoPlayerNearbyMessage, 3000, "error")
    end
end)

RegisterNetEvent('radial:showInventory')
AddEventHandler('radial:showInventory', function(targetPlayer)
    searchPlayer(targetPlayer)
end)

-- Animation for the player being robbed
RegisterNetEvent('radial:beingRobbed')
AddEventHandler('radial:beingRobbed', function()
    local playerPed = PlayerPedId()
    loadAnimDict(robAnimDict)
    TaskPlayAnim(playerPed, robAnimDict, robAnim, 8.0, -8.0, -1, 49, 0, false, false, false)
    isRobbing = true
    
    Citizen.CreateThread(function()
        while isRobbing do
            Wait(0)
            if IsEntityPlayingAnim(playerPed, robAnimDict, robAnim, 3) then
                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 257, true) -- Attack 2
                DisableControlAction(0, 25, true) -- Aim
                DisableControlAction(0, 263, true) -- Melee Attack 1
                DisableControlAction(0, 45, true) -- Reload
                DisableControlAction(0, 22, true) -- Jump
                DisableControlAction(0, 44, true) -- Cover
                DisableControlAction(0, 37, true) -- Select Weapon
            end
        end
    end)
    
    Wait(10000) -- Duration of being robbed
    isRobbing = false
    ClearPedTasks(playerPed)
end)

-- Trunk functionality
local isInTrunk = false

local function GetClosestVehicle()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = Vanguard.GetObjects()
    local closestVehicle = nil
    local closestDistance = 5.0

    for k, vehicle in pairs(vehicles) do
        local distance = #(playerCoords - GetEntityCoords(vehicle))
        if distance < closestDistance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    return closestVehicle
end

local function IsVehicleTrunkOpen(vehicle)
    return GetVehicleDoorAngleRatio(vehicle, 5) > 0.0
end

local function OpenVehicleTrunk(vehicle)
    if not IsVehicleTrunkOpen(vehicle) then
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
end

local function CloseVehicleTrunk(vehicle)
    if IsVehicleTrunkOpen(vehicle) then
        SetVehicleDoorShut(vehicle, 5, false)
    end
end

RegisterNetEvent('radial:handleTrunk')
AddEventHandler('radial:handleTrunk', function(optionId)
    local closestPlayer, closestDistance = Vanguard.getClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('radial:' .. optionId, GetPlayerServerId(closestPlayer))
    else
        Vanguard.notifyclient(Config.Notifications.NoPlayerNearbyTitle, Config.Notifications.NoPlayerNearbyMessage, 3000, "error")
    end
end)

RegisterNetEvent('radial:putInTrunk')
AddEventHandler('radial:putInTrunk', function()
    local playerPed = PlayerPedId()
    local vehicle = GetClosestVehicle()

    if not vehicle then
        Vanguard.notifyclient(Config.Notifications.NoVehicleNearbyTitle, Config.Notifications.NoVehicleNearbyMessage, 3000, "error")
        return
    end

    if not IsVehicleTrunkOpen(vehicle) then
        OpenVehicleTrunk(vehicle)
        Wait(300)
    end

    local trunkCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "boot"))
    
    if not trunkCoords then
        Vanguard.notifyclient(Config.Notifications.NoAccessibleTrunkTitle, Config.Notifications.NoAccessibleTrunkMessage, 3000, "error")
        return
    end

    -- Load animation dictionary first
    RequestAnimDict("anim@mp_player_intmenu@key_fob@")
    while not HasAnimDictLoaded("anim@mp_player_intmenu@key_fob@") do
        Wait(100)
    end

    TaskPlayAnim(playerPed, "anim@mp_player_intmenu@key_fob@", "fob_click", 8.0, -8.0, -1, 48, 0, false, false, false)
    Wait(250)

    -- Attach player to trunk with proper position and rotation for lying down
    AttachEntityToEntity(playerPed, vehicle, 0, 0.0, -2.2, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 20, true)

    if not Config.PlayerVisibleInTrunk then
        SetEntityVisible(playerPed, false, false)
    else
        -- Play the crying on bed animation with proper flags
        TaskPlayAnim(playerPed, "timetable@floyd@cryingonbed@base", "base", 8.0, 1.0, -1, 1, 0, false, false, false)
        -- Force the animation to stay
        SetPedKeepTask(playerPed, true)
    end

    SetEntityInvincible(playerPed, true)
    isInTrunk = true
    
    Wait(500)
    CloseVehicleTrunk(vehicle)

    Vanguard.notifyclient(Config.Notifications.PlacedInTrunkTitle, Config.Notifications.PlacedInTrunkMessage, 3000, "info")
end)

RegisterNetEvent('radial:removeFromTrunk')
AddEventHandler('radial:removeFromTrunk', function()
    local playerPed = PlayerPedId()
    local vehicle = GetClosestVehicle()

    if not vehicle then
        Vanguard.notifyclient(Config.Notifications.NoVehicleNearbyTitle, Config.Notifications.NoVehicleNearbyMessage, 3000, "error")
        return
    end

    OpenVehicleTrunk(vehicle)
    Wait(300)

    DetachEntity(playerPed, true, true)
    
    if not Config.PlayerVisibleInTrunk then
        SetEntityVisible(playerPed, true, false)
    else
        ClearPedTasks(playerPed)
        SetPedKeepTask(playerPed, false)
    end
    
    SetEntityInvincible(playerPed, false)
    isInTrunk = false
    
    local spawnPoint = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -4.0, 0.0)
    SetEntityCoords(playerPed, spawnPoint.x, spawnPoint.y, spawnPoint.z)
    SetEntityHeading(playerPed, GetEntityHeading(vehicle))

    TaskPlayAnim(playerPed, "anim@mp_player_intmenu@key_fob@", "fob_click", 8.0, -8.0, -1, 48, 0, false, false, false)
    
    Wait(500)
    CloseVehicleTrunk(vehicle)

    Vanguard.notifyclient(Config.Notifications.RemovedFromTrunkTitle, Config.Notifications.RemovedFromTrunkMessage, 3000, "info")
end)

-- Thread to disable controls while in trunk
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInTrunk then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end
    end
end)

-- Check if player is in trunk (emergency situations)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        
        if isInTrunk and IsEntityAttached(playerPed) then
            local vehicle = GetEntityAttachedTo(playerPed)
            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                if IsEntityInWater(vehicle) or IsEntityUpsidedown(vehicle) then
                    TriggerEvent('radial:removeFromTrunk')
                    Vanguard.notifyclient(Config.Notifications.EmergencyTrunkReleaseTitle, Config.Notifications.EmergencyTrunkReleaseMessage, 3000, "info")
                end
            end
        end
    end
end)

-- Bag functionality
local hasBag = false
local bagObject = nil
local bagProp = 'prop_money_bag_01'

RegisterNetEvent('radial:handleBag')
AddEventHandler('radial:handleBag', function(action)
    local playerPed = PlayerPedId()
    local closestPlayer, closestDistance = Vanguard.getClosestPlayer()
    
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        if action == 'placeBag' then
            TriggerServerEvent('radial:placeBag', GetPlayerServerId(closestPlayer))
        elseif action == 'removeBag' then
            TriggerServerEvent('radial:removeBag', GetPlayerServerId(closestPlayer))
        end
    else
        Vanguard.notifyclient(Config.Notifications.NoPlayerNearbyTitle, Config.Notifications.NoPlayerNearbyMessage, 3000, "error")
    end
end)

RegisterNetEvent('radial:bagPlaced')
AddEventHandler('radial:bagPlaced', function()
    local playerPed = PlayerPedId()
    hasBag = true
    
    -- Create and attach bag prop
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    bagObject = CreateObject(GetHashKey(bagProp), x, y, z + 0.2, true, true, true)
    AttachEntityToEntity(bagObject, playerPed, GetPedBoneIndex(playerPed, 12844), 0.2, 0.04, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
    
    -- Start effect thread
    Citizen.CreateThread(function()
        while hasBag do
            Citizen.Wait(0)
            
            -- Blur screen effect
            SetTimecycleModifier("BlackOut")
            SetTimecycleModifierStrength(0.7)
            
            -- Disable controls
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 37, true) -- Weapon wheel
            DisableControlAction(0, 47, true) -- Weapon
            DisableControlAction(0, 58, true) -- Weapon
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 264, true) -- Melee Attack 2
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 140, true) -- Melee Attack Light
            DisableControlAction(0, 141, true) -- Melee Attack Heavy
            DisableControlAction(0, 142, true) -- Melee Attack Alternate
            DisableControlAction(0, 143, true) -- Melee Block
        end
        
        -- Reset effects when bag is removed
        ClearTimecycleModifier()
    end)
end)

RegisterNetEvent('radial:removeBag')
AddEventHandler('radial:removeBag', function()
    hasBag = false
    
    -- Delete bag prop
    if bagObject then
        DeleteEntity(bagObject)
        bagObject = nil
    end
    
    -- Clear effects
    ClearTimecycleModifier()
end)

-- Carry functionality
local carry = {
    InProgress = false,
    targetSrc = -1,
    type = "",
    personCarrying = {
        animDict = "missfinale_c2mcs_1",
        anim = "fin_c2_mcs_1_camman",
        flag = 49,
    },
    personCarried = {
        animDict = "nm",
        anim = "firemans_carry",
        attachX = 0.27,
        attachY = 0.15,
        attachZ = 0.63,
        flag = 33,
    }
}

-- Function to ensure animation dictionary is loaded
local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end

-- Function to get closest player
local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    if closestDistance ~= -1 and closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

-- Function to disable controls while being carried
local function DisableControlsWhileCarried()
    DisableControlAction(0, 24, true) -- Attack
    DisableControlAction(0, 257, true) -- Attack 2
    DisableControlAction(0, 25, true) -- Aim
    DisableControlAction(0, 263, true) -- Melee Attack 1
    DisableControlAction(0, 45, true) -- Reload
    DisableControlAction(0, 22, true) -- Jump
    DisableControlAction(0, 44, true) -- Cover
    DisableControlAction(0, 37, true) -- Select Weapon
    DisableControlAction(0, 23, true) -- Also 'enter'?
    DisableControlAction(0, 288, true) -- Disable phone
    DisableControlAction(0, 289, true) -- Inventory
    DisableControlAction(0, 170, true) -- Animations
    DisableControlAction(0, 167, true) -- Job
    DisableControlAction(0, 0, true) -- Disable changing view
    DisableControlAction(0, 26, true) -- Disable looking behind
    DisableControlAction(0, 73, true) -- Disable clearing animation
    DisableControlAction(0, 59, true) -- Disable steering in vehicle
    DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
    DisableControlAction(0, 72, true) -- Disable reversing in vehicle
    DisableControlAction(2, 36, true) -- Disable going stealth
    DisableControlAction(0, 47, true) -- Disable weapon
    DisableControlAction(0, 264, true) -- Disable melee
    DisableControlAction(0, 257, true) -- Disable melee
    DisableControlAction(0, 140, true) -- Disable melee
    DisableControlAction(0, 141, true) -- Disable melee
    DisableControlAction(0, 142, true) -- Disable melee
    DisableControlAction(0, 143, true) -- Disable melee
    DisableControlAction(0, Config.OpenKey, true) -- Disable Config.OpenKey
end

-- Function to carry player
local function CarryPlayer()
    if not carry.InProgress then
        local closestPlayer = GetClosestPlayer(3)
        if closestPlayer then
            local targetSrc = GetPlayerServerId(closestPlayer)
            if targetSrc ~= -1 then
                carry.InProgress = true
                carry.targetSrc = targetSrc
                TriggerServerEvent("radial:syncCarry", targetSrc)
                ensureAnimDict(carry.personCarrying.animDict)
                carry.type = "carrying"
            else
                Vanguard.notifyclient(Config.Notifications.NoPlayerNearbyTitle, Config.Notifications.NoPlayerNearbyMessage, 3000, "error")
            end
        else
            Vanguard.notifyclient(Config.Notifications.NoPlayerNearbyTitle, Config.Notifications.NoPlayerNearbyMessage, 3000, "error")
        end
    end
end

-- Function to drop carried player
local function DropPlayer()
    if carry.InProgress then
        carry.InProgress = false
        ClearPedSecondaryTask(PlayerPedId())
        DetachEntity(PlayerPedId(), true, false)
        TriggerServerEvent("radial:syncDrop", carry.targetSrc)
        carry.targetSrc = 0
    end
end

-- Event handlers
RegisterNetEvent("radial:beingCarried")
AddEventHandler("radial:beingCarried", function(carrierServerId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(carrierServerId))
    carry.InProgress = true
    ensureAnimDict(carry.personCarried.animDict)
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, 
        carry.personCarried.attachX, 
        carry.personCarried.attachY, 
        carry.personCarried.attachZ, 
        0.5, 0.5, 180, false, false, false, false, 2, false)
    carry.type = "beingcarried"
end)

RegisterNetEvent("radial:beingDropped")
AddEventHandler("radial:beingDropped", function()
    carry.InProgress = false
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
end)

-- Handle carry options from radial menu
RegisterNetEvent("radial:handleCarry")
AddEventHandler("radial:handleCarry", function(option)
    if option == "carryPlayer" then
        CarryPlayer()
    elseif option == "dropPlayer" then
        DropPlayer()
    end
end)

-- Animation and controls thread
Citizen.CreateThread(function()
    while true do
        if carry.InProgress then
            if carry.type == "beingcarried" then
                DisableControlsWhileCarried()
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000, carry.personCarried.flag, 0, false, false, false)
                end
            elseif carry.type == "carrying" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0, 100000, carry.personCarrying.flag, 0, false, false, false)
                end
            end
        end
        Wait(0)
    end
end)

-- Cuff functionality
local isCuffed = false
local cuffedAnimDict = "mp_arresting"
local cuffedAnim = "idle"
local cuffingAnimDict = "mp_arrest_paired"
local cuffingAnim = "cop_p2_back_right"
local uncuffingAnimDict = "mp_arresting"
local uncuffingAnim = "a_uncuff"
local cuffProp = nil

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function attachCuffProp(ped)
    if not cuffProp or not DoesEntityExist(cuffProp) then
        lib.requestModel('p_cs_cuffs_02_s', 100)
        local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.5))
        cuffProp = CreateObjectNoOffset(`p_cs_cuffs_02_s`, x, y, z, true, false)
        SetModelAsNoLongerNeeded(`p_cs_cuffs_02_s`)
        AttachEntityToEntity(cuffProp, ped, GetPedBoneIndex(ped, 57005), 0.04, 0.06, 0.0, -85.24, 4.2, -106.6, true, true, false, true, 1, true)
    end
end

local function removeCuffProp()
    if cuffProp and DoesEntityExist(cuffProp) then
        SetEntityAsMissionEntity(cuffProp, true, true)
        DetachEntity(cuffProp)
        DeleteObject(cuffProp)
        cuffProp = nil
    end
end

local function handcuffed()
    local playerPed = cache.ped
    isCuffed = true
    
    TriggerServerEvent('radial:setCuff', true)
    lib.requestAnimDict('mp_arresting', 100)
    TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8.0, -1, 49, 0.0, false, false, false)
    
    SetEnableHandcuffs(playerPed, true)
    DisablePlayerFiring(playerPed, true)
    SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
    SetPedCanPlayGestureAnims(playerPed, false)
    FreezeEntityPosition(playerPed, true)
    DisplayRadar(false)
    
    attachCuffProp(playerPed)
end

local function uncuffed()
    if not isCuffed then return end
    
    local playerPed = cache.ped
    isCuffed = false
    
    TriggerServerEvent('radial:setCuff', false)
    SetEnableHandcuffs(playerPed, false)
    DisablePlayerFiring(playerPed, false)
    SetPedCanPlayGestureAnims(playerPed, true)
    FreezeEntityPosition(playerPed, false)
    DisplayRadar(true)
    
    Wait(250)
    ClearPedTasks(playerPed)
    ClearPedSecondaryTask(playerPed)
    removeCuffProp()
end

RegisterNetEvent('radial:handleCuffs')
AddEventHandler('radial:handleCuffs', function(optionId)
    local playerPed = cache.ped
    local closestPlayer, closestDistance = Vanguard.getClosestPlayer()
    
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local targetPed = GetPlayerPed(closestPlayer)
        
        if DoesEntityExist(targetPed) then
            if optionId == 'cuffPlayer' then
                -- Cuff animation
                loadAnimDict(cuffingAnimDict)
                TaskPlayAnim(playerPed, cuffingAnimDict, cuffingAnim, 8.0, -8.0, 4000, 33, 0, false, false, false)
                Wait(3000)
            else
                -- Uncuff animation
                loadAnimDict(uncuffingAnimDict)
                TaskPlayAnim(playerPed, uncuffingAnimDict, uncuffingAnim, 8.0, -8.0, 2000, 33, 0, false, false, false)
                Wait(2000)
            end
            
            TriggerServerEvent('radial:' .. optionId, GetPlayerServerId(closestPlayer))
        end
    else
        Vanguard.notifyclient(Config.Notifications.NoPlayerNearbyTitle, Config.Notifications.NoPlayerNearbyMessage, 3000, "error")
    end
end)

RegisterNetEvent('radial:setCuffState')
AddEventHandler('radial:setCuffState', function(state)
    if state then
        handcuffed()
    else
        uncuffed()
    end
end)

-- Thread to handle cuffed player movement restrictions
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if isCuffed then
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 45, true) -- Reload
            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 44, true) -- Cover
            DisableControlAction(0, 37, true) -- Select Weapon
            DisableControlAction(0, 23, true) -- Also 'enter'?
            DisableControlAction(0, 288, true) -- Disable phone
            DisableControlAction(0, 289, true) -- Inventory
            DisableControlAction(0, 170, true) -- Animations
            DisableControlAction(0, 167, true) -- Job
            DisableControlAction(0, 0, true) -- Disable changing view
            DisableControlAction(0, 26, true) -- Disable looking behind
            DisableControlAction(0, 73, true) -- Disable clearing animation
            DisableControlAction(0, 59, true) -- Disable steering in vehicle
            DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
            DisableControlAction(0, 72, true) -- Disable reversing in vehicle
            DisableControlAction(2, 36, true) -- Disable going stealth
            DisableControlAction(0, 47, true) -- Disable weapon
            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
            DisableControlAction(0, Config.OpenKey, true) -- Disable Config.OpenKey
            
            -- Keep player in cuffed animation
            if not IsEntityPlayingAnim(cache.ped, 'mp_arresting', 'idle', 3) then
                lib.requestAnimDict('mp_arresting', 100)
                TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
            end
        end
    end
end)

-- Flat tire functionality
local function GetNearestVehicle()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    return vehicle
end

local function GetTargetTire(vehicle)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    local tireIndices = {
        {index = 0, name = "wheel_lf"},
        {index = 1, name = "wheel_rf"},
        {index = 2, name = "wheel_lr"},
        {index = 3, name = "wheel_rr"},
        {index = 4, name = "wheel_lm"},
        {index = 5, name = "wheel_rm"}
    }
    
    local closestTire = -1
    local minDistance = 2.0
    
    for _, tire in ipairs(tireIndices) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, tire.name)
        
        if boneIndex ~= -1 then
            local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
            local distance = #(coords - boneCoords)
            
            if distance < minDistance then
                minDistance = distance
                closestTire = tire.index
            end
        end
    end
    
    return closestTire
end

local function PlayPunctureTireAnimation(callback)
    local playerPed = PlayerPedId()
    
    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
        Citizen.Wait(100)
    end
    
    TaskPlayAnim(playerPed, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    Citizen.SetTimeout(6500, function()
        ClearPedTasks(playerPed)
        if callback then
            callback()
        end
    end)
end

local function RemoveTire(vehicle, tireIndex)
    if not DoesEntityExist(vehicle) then return end
    SetVehicleTyreBurst(vehicle, tireIndex, true, 100.0)
    local wheelCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_" .. tireIndex))
    AddExplosion(wheelCoords.x, wheelCoords.y, wheelCoords.z, 'EXPLOSION_TANKER', 0.0, false, true, 0.0)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleDoorsLocked(vehicle, 2)
    Wait(100)
    SetVehicleDoorsLocked(vehicle, 0)
end

local function HasTireRemoved(vehicle)
    for i = 0, 5 do
        if IsVehicleTyreBurst(vehicle, i, true) then
            return true
        end
    end
    return false
end

RegisterNetEvent('radial:handleFlatTire')
AddEventHandler('radial:handleFlatTire', function()
    local playerPed = PlayerPedId()
    
    if IsPedInAnyVehicle(playerPed, true) then
        Vanguard.notifyclient(Config.Notifications.InsideVehicleTitle, Config.Notifications.InsideVehicleMessage, 3000, "error")
        return
    end
    
    local vehicle = GetNearestVehicle()
    
    if vehicle and DoesEntityExist(vehicle) then
        if HasTireRemoved(vehicle) then
            Vanguard.notifyclient(Config.Notifications.TireAlreadyRemovedTitle, Config.Notifications.TireAlreadyRemovedMessage, 3000, "error")
            return
        end
        
        local tireIndex = GetTargetTire(vehicle)
        
        if tireIndex ~= -1 then
            PlayPunctureTireAnimation(function()
                RemoveTire(vehicle, tireIndex)
                Vanguard.notifyclient(Config.Notifications.TireRemovedTitle, Config.Notifications.TireRemovedMessage, 3000, "info")
            end)
        else
            Vanguard.notifyclient(Config.Notifications.NoTireFoundTitle, Config.Notifications.NoTireFoundMessage, 3000, "error")
        end
    else
        Vanguard.notifyclient(Config.Notifications.NoVehicleNearbyTitle, Config.Notifications.NoVehicleNearbyMessage, 3000, "error")
    end
end)

-- Hostage functionality
local takeHostage = {
    allowedWeapons =  Config.Hostage.AllowedWeapons, -- Usa a lista de armas da configuração
    InProgress = false,
    type = "",
    targetSrc = -1,
    agressor = {
        animDict = "anim@gangops@hostage@",
        anim = "perp_idle",
        flag = 49,
    },
    hostage = {
        animDict = "anim@gangops@hostage@",
        anim = "victim_idle",
        attachX = -0.24,
        attachY = 0.11,
        attachZ = 0.0,
        flag = 49,
    }
}

local function showNotification(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    if closestDistance ~= -1 and closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end

RegisterNetEvent('radial:handleHostage')
AddEventHandler('radial:handleHostage', function()
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)

    local canTakeHostage = false
    for i=1, #takeHostage.allowedWeapons do
        if HasPedGotWeapon(PlayerPedId(), takeHostage.allowedWeapons[i], false) then
            if GetAmmoInPedWeapon(PlayerPedId(), takeHostage.allowedWeapons[i]) > 0 then
                canTakeHostage = true 
                foundWeapon = takeHostage.allowedWeapons[i]
                break
            end 					
        end
    end

    if not canTakeHostage then 
        showNotification("You need a pistol with ammo to take a hostage at gunpoint!")
        return
    end

    if not takeHostage.InProgress then			
        local closestPlayer = GetClosestPlayer(3)
        if closestPlayer then
            local targetSrc = GetPlayerServerId(closestPlayer)
            if targetSrc ~= -1 then
                SetCurrentPedWeapon(PlayerPedId(), foundWeapon, true)
                takeHostage.InProgress = true
                takeHostage.targetSrc = targetSrc
                TriggerServerEvent("TakeHostage:sync",targetSrc)
                ensureAnimDict(takeHostage.agressor.animDict)
                takeHostage.type = "agressor"
                SendNUIMessage({
                    type = "showHostageControls"
                })
            else
                showNotification("~r~No one nearby to take as hostage!")
            end
        else
            showNotification("~r~No one nearby to take as hostage!")
        end
    end
end)

RegisterNetEvent("TakeHostage:syncTarget")
AddEventHandler("TakeHostage:syncTarget", function(target)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
    takeHostage.InProgress = true
    ensureAnimDict(takeHostage.hostage.animDict)
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
    takeHostage.type = "hostage" 
end)

RegisterNetEvent("TakeHostage:releaseHostage")
AddEventHandler("TakeHostage:releaseHostage", function()
    takeHostage.InProgress = false 
    takeHostage.type = ""
    DetachEntity(PlayerPedId(), true, false)
    ensureAnimDict("reaction@shove")
    TaskPlayAnim(PlayerPedId(), "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
    Wait(250)
    ClearPedSecondaryTask(PlayerPedId())
    SendNUIMessage({
        type = "hideHostageControls"
    })
end)

RegisterNetEvent("TakeHostage:killHostage")
AddEventHandler("TakeHostage:killHostage", function()
    takeHostage.InProgress = false 
    takeHostage.type = ""
    SetEntityHealth(PlayerPedId(),0)
    DetachEntity(PlayerPedId(), true, false)
    ensureAnimDict("anim@gangops@hostage@")
    TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
    SendNUIMessage({
        type = "hideHostageControls"
    })
end)

RegisterNetEvent("TakeHostage:cl_stop")
AddEventHandler("TakeHostage:cl_stop", function()
    takeHostage.InProgress = false
    takeHostage.type = "" 
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
    SendNUIMessage({
        type = "hideHostageControls"
    })
end)

Citizen.CreateThread(function()
    while true do
        if takeHostage.type == "agressor" then
            if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
                TaskPlayAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000, takeHostage.agressor.flag, 0, false, false, false)
            end
        elseif takeHostage.type == "hostage" then
            if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
                TaskPlayAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
            end
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do 
        if takeHostage.type == "agressor" then
            DisableControlAction(0,24,true)
            DisableControlAction(0,25,true)
            DisableControlAction(0,47,true)
            DisableControlAction(0,58,true)
            DisableControlAction(0,21,true)
            DisablePlayerFiring(PlayerPedId(),true)

            if IsEntityDead(PlayerPedId()) then	
                takeHostage.type = ""
                takeHostage.InProgress = false
                ensureAnimDict("reaction@shove")
                TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
                SendNUIMessage({
                    type = "hideHostageControls"
                })
            end 

            if IsDisabledControlJustPressed(0,47) then
                takeHostage.type = ""
                takeHostage.InProgress = false 
                ensureAnimDict("reaction@shove")
                TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
                SendNUIMessage({
                    type = "hideHostageControls"
                })
            elseif IsDisabledControlJustPressed(0,74) then		
                takeHostage.type = ""
                takeHostage.InProgress = false 		
                ensureAnimDict("anim@gangops@hostage@")
                TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
                TriggerServerEvent("TakeHostage:killHostage", takeHostage.targetSrc)
                TriggerServerEvent("TakeHostage:stop",takeHostage.targetSrc)
                SendNUIMessage({
                    type = "hideHostageControls"
                })
                Wait(100)
                SetPedShootsAtCoord(PlayerPedId(), 0.0, 0.0, 0.0, 0)
            end
        elseif takeHostage.type == "hostage" then 
            DisableControlAction(0,21,true)
            DisableControlAction(0,24,true)
            DisableControlAction(0,25,true)
            DisableControlAction(0,47,true)
            DisableControlAction(0,58,true)
            DisableControlAction(0,263,true)
            DisableControlAction(0,264,true)
            DisableControlAction(0,257,true)
            DisableControlAction(0,140,true)
            DisableControlAction(0,141,true)
            DisableControlAction(0,142,true)
            DisableControlAction(0,143,true)
            DisableControlAction(0,75,true)
            DisableControlAction(27,75,true)
            DisableControlAction(0,22,true)
            DisableControlAction(0,32,true)
            DisableControlAction(0,268,true)
            DisableControlAction(0,33,true)
            DisableControlAction(0,269,true)
            DisableControlAction(0,34,true)
            DisableControlAction(0,270,true)
            DisableControlAction(0,35,true)
            DisableControlAction(0,271,true)
        end
        Wait(0)
    end
end)