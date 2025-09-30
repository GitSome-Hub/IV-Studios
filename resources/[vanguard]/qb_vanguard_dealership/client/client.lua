local QBCore = exports['qb-core']:GetCoreObject()
local display = false
local currentDealership = nil
local dealerPeds = {}
local dealerBlips = {}
local playerAvatar = nil
local isTestDriving = false
local testDriveVehicle = nil
local testDriveTimer = nil
local originalPosition = nil
local testDriveBlip = nil
local intervals = {}
local intervalCount = 0

function SetInterval(callback, msec)
    intervalCount = intervalCount + 1
    local count = intervalCount
    
    intervals[count] = true
    
    CreateThread(function()
        while intervals[count] do
            callback()
            Wait(msec)
        end
    end)
    
    return count
end

function ClearInterval(id)
    if intervals[id] then
        intervals[id] = nil
    end
end

-- Create dealer NPCs and blips
CreateThread(function()
    for k, dealership in pairs(Config.Dealerships) do
        -- Create NPC
        local model = GetHashKey(dealership.npcModel)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        
        local ped = CreatePed(4, model, dealership.location.x, dealership.location.y, dealership.location.z - 1.0, dealership.location.w, false, true)
        SetEntityHeading(ped, dealership.location.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        dealerPeds[k] = ped

        -- Create blip
        if dealership.blip then
            local blip = AddBlipForCoord(dealership.location.x, dealership.location.y, dealership.location.z)
            SetBlipSprite(blip, dealership.blip.sprite)
            SetBlipDisplay(blip, dealership.blip.display)
            SetBlipScale(blip, dealership.blip.scale)
            SetBlipColour(blip, dealership.blip.color)
            SetBlipAsShortRange(blip, dealership.blip.shortRange)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(dealership.blip.label)
            EndTextCommandSetBlipName(blip)
            
            dealerBlips[k] = blip
        end
    end
end)

-- Interaction loop
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local closestDealership = nil
        local closestDistance = Config.DrawDistance
        
        for k, dealership in pairs(Config.Dealerships) do
            local distance = #(playerCoords - vector3(dealership.location.x, dealership.location.y, dealership.location.z))
            
            if distance < closestDistance then
                closestDistance = distance
                closestDealership = dealership
            end
        end
        
        if closestDealership and closestDistance < Config.InteractionDistance then
            if Config.UseOxLib then
                lib.showTextUI(Config.UI.labels.pressToOpen)
            else
                Config.DrawText3D(
                    closestDealership.location.x, 
                    closestDealership.location.y, 
                    closestDealership.location.z + 1.0, 
                    Config.UI.labels.pressToOpen
                )
            end
            
            if IsControlJustReleased(0, Config.InteractionKey) then
                currentDealership = closestDealership
                TriggerServerEvent('dealership:getPlayerAvatar')
                SetDisplay(true)
            end
        else
            if Config.UseOxLib then
                lib.hideTextUI()
            end
        end
    end
end)

-- Money update thread
CreateThread(function()
    while true do
        Wait(1000) -- Update every second
        if display then
            TriggerServerEvent('dealership:updatePlayerMoney')
        end
    end
end)

-- Test Drive Functions
function StartTestDrive(vehicle, dealership)
    if isTestDriving then return end
    
    local testDriveConfig = dealership.testDrive
    if not testDriveConfig then return end
    
    -- Store original position
    originalPosition = GetEntityCoords(PlayerPedId())
    
    -- First teleport player to test drive location
    SetEntityCoords(PlayerPedId(), 
        testDriveConfig.location.x, 
        testDriveConfig.location.y, 
        testDriveConfig.location.z, 
        false, false, false, false)
    SetEntityHeading(PlayerPedId(), testDriveConfig.location.w)
    
    -- Create solo instance immediately after teleport
    SetupTestDriveInstance()
    
    -- Wait before spawning vehicle
    Citizen.Wait(1000)
    
    -- Create test drive vehicle
    QBCore.Functions.SpawnVehicle(vehicle.model, function(veh)
        if DoesEntityExist(veh) then
            testDriveVehicle = veh
            
            -- Set vehicle properties
            SetVehicleNumberPlateText(veh, "TESTDRIVE")
            SetVehicleDoorsLocked(veh, 4) -- Lock vehicle doors
            SetVehicleEngineOn(veh, true, true, false)
            SetEntityInvincible(veh, true)
            
            -- Apply selected color if available
            if vehicle.selectedColor then
                local hex = vehicle.selectedColor:gsub("#","")
                local r = tonumber("0x"..hex:sub(1,2))
                local g = tonumber("0x"..hex:sub(3,4))
                local b = tonumber("0x"..hex:sub(5,6))
                SetVehicleCustomPrimaryColour(veh, r, g, b)
                SetVehicleCustomSecondaryColour(veh, r, g, b)
            end
            
            -- Teleport player into vehicle
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            
            -- Set test drive state
            isTestDriving = true
            
            -- Start countdown
            StartTestDriveCountdown(testDriveConfig.duration or Config.TestDrive.defaultDuration)
            
            -- Notify test drive started
            QBCore.Functions.Notify(Config.UI.notifications.testDriveStarted, "success")
            
            -- Start thread to check if player leaves vehicle
            CreateThread(function()
                while isTestDriving do
                    Wait(0)
                    local playerPed = PlayerPedId()
                    
                    if not IsPedInVehicle(playerPed, testDriveVehicle, false) and Config.TestDrive.preventVehicleExit then
                        TaskWarpPedIntoVehicle(playerPed, testDriveVehicle, -1)
                    end
                end
            end)
        end
    end, testDriveConfig.location, true)
end

function SetupTestDriveInstance()
    if Config.TestDrive.hideOtherPlayers then
        -- Hide all other vehicles
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in ipairs(vehicles) do
            if vehicle ~= testDriveVehicle then
                SetEntityAlpha(vehicle, 0, false)
                SetEntityNoCollisionEntity(testDriveVehicle, vehicle, true)
            end
        end
        
        -- Hide all other players
        local players = GetActivePlayers()
        for _, player in ipairs(players) do
            local ped = GetPlayerPed(player)
            if ped ~= PlayerPedId() then
                SetEntityVisible(ped, false, false)
                SetEntityNoCollisionEntity(testDriveVehicle, ped, true)
            end
        end
    end
    
    NetworkFadeOutEntity(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(false)
    SetEveryoneIgnorePlayer(PlayerPedId(), true)
end

function StartTestDriveCountdown(duration)
    local timeLeft = duration
    
    SendNUIMessage({
        type = "testDriveCountdown",
        show = true,
        duration = duration
    })
    
    testDriveTimer = SetInterval(function()
        if timeLeft > 0 then
            timeLeft = timeLeft - 1
            SendNUIMessage({
                type = "updateCountdown",
                timeLeft = timeLeft
            })
        else
            EndTestDrive()
        end
    end, 1000)
end

function EndTestDrive()
    if not isTestDriving then return end
    
    if testDriveTimer then
        ClearInterval(testDriveTimer)
        testDriveTimer = nil
    end
    
    SendNUIMessage({
        type = "testDriveCountdown",
        show = false
    })
    
    if Config.TestDrive.hideOtherPlayers then
        -- Show other vehicles again
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in ipairs(vehicles) do
            if vehicle ~= testDriveVehicle then
                ResetEntityAlpha(vehicle)
            end
        end
        
        -- Show other players again
        local players = GetActivePlayers()
        for _, player in ipairs(players) do
            local ped = GetPlayerPed(player)
            if ped ~= PlayerPedId() then
                SetEntityVisible(ped, true, false)
            end
        end
    end
    
    NetworkFadeInEntity(PlayerPedId(), true)
    SetEveryoneIgnorePlayer(PlayerPedId(), false)
    NetworkSetFriendlyFireOption(true)
    
    if DoesEntityExist(testDriveVehicle) then
        DeleteEntity(testDriveVehicle)
    end
    
    if originalPosition then
        SetEntityCoords(PlayerPedId(), originalPosition.x, originalPosition.y, originalPosition.z, false, false, false, false)
    end
    
    -- Notify test drive ended
    QBCore.Functions.Notify(Config.UI.notifications.testDriveEnded, "success")
    
    isTestDriving = false
    testDriveVehicle = nil
    originalPosition = nil
end

-- Show/Hide UI
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    
    if bool and currentDealership then
        local Player = QBCore.Functions.GetPlayerData()
        local playerName = Player.charinfo.firstname .. ' ' .. Player.charinfo.lastname
        
        -- Filter categories based on dealership configuration
        local filteredCategories = {}
        if currentDealership.categories then
            for _, category in ipairs(Config.Categories) do
                if table.contains(currentDealership.categories, category.id) then
                    table.insert(filteredCategories, category)
                end
            end
        else
            filteredCategories = Config.Categories
        end
        
        -- Ensure vehicles is a table
        local dealershipVehicles = currentDealership.vehicles or {}
        
        SendNUIMessage({
            type = "ui",
            status = bool,
            dealership = currentDealership.name,
            vehicles = dealershipVehicles,
            categories = filteredCategories,
            config = {
                currency = Config.Currency,
                ui = Config.UI
            },
            player = {
                name = playerName,
                money = tostring(Player.money.cash or 0),
                avatar = playerAvatar or "https://i.imgur.com/xXKk4Et.png" -- Default avatar if none is set
            }
        })
    else
        SendNUIMessage({
            type = "ui",
            status = bool
        })
        SetNuiFocus(false, false)
    end
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Register NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNUICallback('testDrive', function(data, cb)
    if not data.vehicle then
        QBCore.Functions.Notify(Config.UI.notifications.selectVehicle, "error")
        return
    end
    
    if currentDealership and data.vehicle then
        StartTestDrive(data.vehicle, currentDealership)
    end
    cb('ok')
end)

RegisterNUICallback('purchaseVehicle', function(data, cb)
    if not data.vehicle.selectedColor then
        QBCore.Functions.Notify(Config.UI.notifications.selectColor, "error")
        return
    end
    
    if currentDealership and data.vehicle then
        TriggerServerEvent('dealership:purchaseVehicle', data.vehicle)
    end
    cb('ok')
end)

-- Handle vehicle purchase and spawn
RegisterNetEvent('dealership:purchaseResponse')
AddEventHandler('dealership:purchaseResponse', function(success, message, vehicleData)
    if success then
        QBCore.Functions.Notify(message, "success")
    else
        QBCore.Functions.Notify(message, "error")
    end
    
    if success and vehicleData and currentDealership then
        local coords = currentDealership.spawnLocation
        
        QBCore.Functions.SpawnVehicle(vehicleData.model, function(vehicle)
            if DoesEntityExist(vehicle) then
                local playerPed = PlayerPedId()
                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                
                SetVehicleNumberPlateText(vehicle, vehicleData.plate)
                
                if vehicleData.selectedColor then
                    local hex = vehicleData.selectedColor:gsub("#","")
                    local r = tonumber("0x"..hex:sub(1,2))
                    local g = tonumber("0x"..hex:sub(3,4))
                    local b = tonumber("0x"..hex:sub(5,6))
                    
                    SetVehicleCustomPrimaryColour(vehicle, r, g, b)
                    SetVehicleCustomSecondaryColour(vehicle, r, g, b)
                end
                
                local mods = QBCore.Functions.GetVehicleProperties(vehicle)
                mods.plate = vehicleData.plate
                
                TriggerServerEvent('dealership:setVehicleOwned', mods)
                
                SetDisplay(false)
            end
        end, coords, true)
    end
end)

-- Handle Steam avatar response
RegisterNetEvent('dealership:setPlayerAvatar')
AddEventHandler('dealership:setPlayerAvatar', function(avatarUrl)
    playerAvatar = avatarUrl
    if display then
        SetDisplay(true)
    end
end)

-- Handle money updates
RegisterNetEvent('dealership:setPlayerMoney')
AddEventHandler('dealership:setPlayerMoney', function(money)
    if display then
        SendNUIMessage({
            type = "updateMoney",
            money = money
        })
    end
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    for _, ped in pairs(dealerPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    
    for _, blip in pairs(dealerBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    
    if Config.UseOxLib then
        lib.hideTextUI()
    end
    
    if isTestDriving then
        EndTestDrive()
    end
    
    SetDisplay(false)
end)