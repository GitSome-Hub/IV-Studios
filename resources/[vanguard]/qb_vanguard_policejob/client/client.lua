local QBCore = exports['qb-core']:GetCoreObject()

playerLoaded, isDead, isBusy, disableKeys, hasJob, cuffProp, isCuffed, inMenu, isRagdoll, cuffTimer, escorting, escorted = nil, nil, nil, nil, nil, nil, nil, nil, nil, {}, {}, {}

-- Player Loaded Event
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        playerLoaded = true
        Wait(4500)
        for i=1, #Config.policeJobs do
            if Config.policeJobs[i] == PlayerData.job.name then
                hasJob = PlayerData.job.name
                break
            end
        end
    end)
end)

-- Job Update Event
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    for i=1, #Config.policeJobs do
        if Config.policeJobs[i] == JobInfo.name then
            hasJob = JobInfo.name
            break
        else
            hasJob = nil
        end
    end
end)

RegisterNetEvent('vanguard_policejob:tackled', function(targetId)
    getTackled(targetId)
end)

RegisterNetEvent('vanguard_policejob:tackle', function()
    tacklePlayer()
end)

-- Player Spawn Event
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    playerLoaded = false
    if isCuffed then
        uncuffed()
    end
    if escorting and escorting.active then
        escorting.active = nil
        escorting.target = nil
    end
end)

-- Death Events
RegisterNetEvent('hospital:client:Revive', function()
    isDead = false
end)

RegisterNetEvent('hospital:client:SetDeathStatus', function(status)
    isDead = status
    if isCuffed and isDead then
        uncuffed()
    end
    if escorting and escorting.active then
        escorting.active = nil
        escorting.target = nil
    end
end)

AddEventHandler('vanguard_policejob:searchPlayer', function()
    if not hasJob then return end
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player == -1 or dist > 2.0 then
        TriggerEvent('vanguard_policejob:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        searchPlayer(player)
    end
end)

AddEventHandler('vanguard_policejob:jailPlayer', function()
    if not hasJob then return end
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player == -1 or dist > 2.0 then
        TriggerEvent('vanguard_policejob:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        local input = lib.inputDialog(Strings.minutes_dialog, {Strings.minutes_dialog_field})
        if not input then return end
        local quantity = math.floor(tonumber(input[1]))
        if quantity < 1 then
            TriggerEvent('vanguard_policejob:notify', Strings.invalid_amount, Strings.invalid_amount_desc, 'error')
        else
            TriggerEvent('vanguard_policejob:sendToJail', GetPlayerServerId(player), quantity)
        end
    end
end)

AddEventHandler('vanguard_policejob:spawnVehicle', function(data)
    inMenu = false
    local model = data.model
    local category = Config.Locations[data.station].vehicles.options[data.grade][data.model].category
    local spawnLoc = Config.Locations[data.station].vehicles.spawn[category]
    if not IsModelInCdimage(GetHashKey(model)) then
        print('Vehicle model not found: '..model)
    else
        DoScreenFadeOut(800)
        while not IsScreenFadedOut() do
            Wait(100)
        end
        lib.requestModel(model, 100)
        local vehicle = CreateVehicle(GetHashKey(model), spawnLoc.coords.x, spawnLoc.coords.y, spawnLoc.coords.z, spawnLoc.heading, 1, 0)
        TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
        if Config.customCarlock then
            local plate = GetVehicleNumberPlateText(vehicle)
            addCarKeys(plate)
        end
        SetModelAsNoLongerNeeded(model)
        DoScreenFadeIn(800)
    end
end)

AddEventHandler('vanguard_policejob:handcuffPlayer', function()
    if not hasJob then return end
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player == -1 or dist > 2.0 then
        TriggerEvent('vanguard_policejob:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        handcuffPlayer(GetPlayerServerId(player))
    end
end)

RegisterNetEvent('vanguard_policejob:arrested', function(pdId)
    isBusy = true
    local escaped
    local pdPed = GetPlayerPed(GetPlayerFromServerId(pdId))
    lib.requestAnimDict('mp_arrest_paired', 100)
    AttachEntityToEntity(cache.ped, pdPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
    TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
    if Config.handcuff.skilledEscape.enabled then
        if lib.skillCheck(Config.handcuff.skilledEscape.difficulty) then
            escaped = true
        end
    end
    FreezeEntityPosition(pdPed, true)
    Wait(2000)
    DetachEntity(cache.ped, true, false)
    FreezeEntityPosition(pdPed, false)
    RemoveAnimDict('mp_arrest_paired')
    if not escaped then
        handcuffed()
    end
    isBusy = false
end)

RegisterNetEvent('vanguard_policejob:arrest', function()
    isBusy = true
    lib.requestAnimDict('mp_arrest_paired', 100)
    TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'cop_p2_back_left', 8.0, -8.0, 3400, 33, 0, false, false, false)
    Wait(3000)
    isBusy = false
end)

RegisterNetEvent('vanguard_policejob:uncuffAnim', function(target)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
    local targetCoords = GetEntityCoords(targetPed)
    TaskTurnPedToFaceCoord(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, 2000)
    Wait(2000)
    TaskStartScenarioInPlace(cache.ped, 'PROP_HUMAN_PARKING_METER', 0, true)
    Wait(2000)
    ClearPedTasks(cache.ped)
end)

RegisterNetEvent('vanguard_policejob:uncuff', function()
    uncuffed()
end)

RegisterNetEvent('vanguard_policejob:stopEscorting', function()
    if escorting and escorting.active then
        escorting.active = nil
        escorting.target = nil
    end
end)

AddEventHandler('vanguard_policejob:escortPlayer', function()
    if not hasJob then return end
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player == -1 or dist > 2.0 then
        TriggerEvent('vanguard_policejob:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        escortPlayer(GetPlayerServerId(player))
    end
end)

AddEventHandler('vanguard_policejob:lockpickVehicle', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if not DoesEntityExist(vehicle) then
        TriggerEvent('vanguard_policejob:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local pedCoords = GetEntityCoords(cache.ped)
        local vehCoords = GetEntityCoords(vehicle)
        local dist = #(pedCoords - vehCoords)
        if dist < 2.5 then
            lockpickVehicle(vehicle)
        else
            TriggerEvent('vanguard_policejob:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end)

AddEventHandler('vanguard_policejob:impoundVehicle', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if not DoesEntityExist(vehicle) then
        TriggerEvent('vanguard_policejob:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local pedCoords = GetEntityCoords(cache.ped)
        local vehCoords = GetEntityCoords(vehicle)
        local dist = #(pedCoords - vehCoords)
        if dist < 2.5 then
            impoundVehicle(vehicle)
        else
            TriggerEvent('vanguard_policejob:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end)

AddEventHandler('vanguard_policejob:vehicleInfo', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if not DoesEntityExist(vehicle) then
        TriggerEvent('vanguard_policejob:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local pedCoords = GetEntityCoords(cache.ped)
        local vehCoords = GetEntityCoords(vehicle)
        local dist = #(pedCoords - vehCoords)
        if dist < 3.5 then
            vehicleInfoMenu(vehicle)
        else
            TriggerEvent('vanguard_policejob:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end)

AddEventHandler('vanguard_policejob:openBossMenu', function()
    if not hasJob then return end
    TriggerEvent('qb-bossmenu:client:openMenu')
end)

RegisterNetEvent('vanguard_policejob:escortedPlayer', function(pdId)
    if isCuffed then
        escorted.active = not escorted.active
        escorted.pdId = pdId
    end
end)

RegisterNetEvent('vanguard_policejob:setEscort', function(targetId)
    if not hasJob then return end
    escorting.active = not escorting.active
    escorting.target = targetId
end)

RegisterNetEvent('vanguard_policejob:putInVehicle', function()
    if isCuffed then
        if escorted and escorted.active then
            escorted.active = nil
            escorted.pdId = nil
            Wait(1000)
        end
        local coords = GetEntityCoords(cache.ped)
        if IsAnyVehicleNearPoint(coords, 5.0) then
            local vehicle = QBCore.Functions.GetClosestVehicle()
            if DoesEntityExist(vehicle) then
                local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
                for i=maxSeats - 1, 0, -1 do
                    if IsVehicleSeatFree(vehicle, i) then
                        freeSeat = i
                        break
                    end
                end
                if freeSeat then
                    FreezeEntityPosition(cache.ped, false)
                    TaskWarpPedIntoVehicle(cache.ped, vehicle, freeSeat)
                    FreezeEntityPosition(cache.ped, true)
                end
            end
        end
    end
end)

RegisterNetEvent('vanguard_policejob:takeFromVehicle', function()
    if IsPedSittingInAnyVehicle(cache.ped) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        TaskLeaveVehicle(cache.ped, vehicle, 64)
    end
end)

AddEventHandler('vanguard_policejob:inVehiclePlayer', function()
    if not hasJob then return end
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player == -1 or dist > 4.0 then
        TriggerEvent('vanguard_policejob:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        TriggerServerEvent('vanguard_policejob:inVehiclePlayer', GetPlayerServerId(player))
    end
end)

AddEventHandler('vanguard_policejob:outVehiclePlayer', function()
    if not hasJob then return end
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player == -1 or dist > 4.0 then
        TriggerEvent('vanguard_policejob:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        TriggerServerEvent('vanguard_policejob:outVehiclePlayer', GetPlayerServerId(player))
    end
end)

AddEventHandler('vanguard_policejob:vehicleInteractions', function()
    vehicleInteractionMenu()
end)

AddEventHandler('vanguard_policejob:placeObjects', function()
    placeObjectsMenu()
end)

AddEventHandler('vanguard_policejob:spawnProp', function(index)
    local prop = Config.Props[index]
    local playerPed = PlayerPedId()
    local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
    local objectCoords = (coords + forward * 1.0)
    print(prop.model)
    QBCore.Functions.SpawnObject(prop.model, objectCoords, function(obj)
        SetEntityHeading(obj, GetEntityHeading(playerPed))
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
    end)
end)

AddEventHandler('vanguard_policejob:licenseMenu', function(data)
    if not hasJob then return end
    openLicenseMenu(data)
end)

AddEventHandler('vanguard_policejob:purchaseArmoury', function(data)
    if not hasJob then return end
    local data = data
    data.quantity = 1
    if data.multiple then
        local input = lib.inputDialog(Strings.armoury_quantity_dialog, {Strings.quantity})
        if not input then return end
        local quantity = math.floor(tonumber(input[1]))
        if quantity < 1 then
            TriggerEvent('vanguard_policejob:notify', Strings.invalid_amount, Strings.invalid_amount_desc, 'error')
        else
            data.quantity = quantity
        end
    end
    local canPurchase = lib.callback.await('vanguard_policejob:canPurchase', 100, data)
    if canPurchase then
        TriggerEvent('vanguard_policejob:notify', Strings.success, Strings.successful_purchase_desc, 'success')
    else
        TriggerEvent('vanguard_policejob:notify', Strings.lacking_funds, Strings.lacking_funds_desc, 'error')
    end
end)

AddEventHandler('vanguard_policejob:checkId', function(targetId)
    if not hasJob then return end
    if not targetId then
        local player, dist = QBCore.Functions.GetClosestPlayer()
        if player == -1 or dist > 4.0 then
            TriggerEvent('vanguard_policejob:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
        else
            checkPlayerId(GetPlayerServerId(player))
        end
    else
        checkPlayerId(targetId)
    end
end)

AddEventHandler('vanguard_policejob:revokeLicense', function(data)
    TriggerServerEvent('qb-licenses:server:removeLicense', data.targetId, data.license)
    TriggerEvent('vanguard_policejob:notify', Strings.license_revoked, Strings.license_revoked_desc, 'success')
    Wait(420) -- lul
    checkPlayerId(data.targetId)
end)

AddEventHandler('vanguard_policejob:manageId', function(data)
    manageId(data)
end)

CreateThread(function()
    while true do
        local sleep = 1500
        if isCuffed then
            sleep = 0
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true) -- Pan
            EnableControlAction(0, 2, true) -- Tilt
            EnableControlAction(0, 245, true) -- OOC "t"
            EnableControlAction(0, 236, true) -- Change Cam "V"
            EnableControlAction(0, 249, true) -- Push to talk "N"
            if not IsEntityPlayingAnim(cache.ped, 'mp_arresting', 'idle', 3) then
                lib.requestAnimDict('mp_arresting', 100)
                TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
            end
            if not cuffProp or not DoesEntityExist(cuffProp) then
                lib.requestModel('p_cs_cuffs_02_s', 100)
                local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(cache.ped,0.0,3.0,0.5))
                cuffProp = CreateObjectNoOffset(`p_cs_cuffs_02_s`, x, y, z, true, false)
                SetModelAsNoLongerNeeded(`p_cs_cuffs_02_s`)
                AttachEntityToEntity(cuffProp, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.04, 0.06, 0.0, -85.24, 4.2, -106.6, true, true, false, true, 1, true)
            end
        end
        if isRagdoll then
            sleep = 0
            SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
        end
        Wait(sleep)
    end
end)

-- Escorting loop
CreateThread(function()
    local alrEscorting
    while true do
        local sleep = 1500
        if escorting and escorting.active then
            sleep = 0
            local targetPed = GetPlayerPed(GetPlayerFromServerId(escorting.target))
            if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                if not alrEscorting then
                    lib.requestAnimDict('amb@code_human_wander_drinking_fat@beer@male@base', 100)
                    TaskPlayAnim(cache.ped, 'amb@code_human_wander_drinking_fat@beer@male@base', 'static', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                    alrEscorting = true
                    RemoveAnimDict('amb@code_human_wander_drinking_fat@beer@male@base')
                elseif alrEscorting and not IsEntityPlayingAnim(cache.ped, 'amb@code_human_wander_drinking_fat@beer@male@base', 'static', 3) then
                    lib.requestAnimDict('amb@code_human_wander_drinking_fat@beer@male@base', 100)
                    TaskPlayAnim(cache.ped, 'amb@code_human_wander_drinking_fat@beer@male@base', 'static', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                    RemoveAnimDict('amb@code_human_wander_drinking_fat@beer@male@base')
                else
                    sleep = 1500
                end
            else
                alrEscorting = nil
                escorting.active = nil
                ClearPedTasks(cache.ped)
            end
        elseif alrEscorting then
            alrEscorting = nil
            escorting.active = nil
            ClearPedTasks(cache.ped)
        else
            sleep = 1500
        end
        Wait(sleep)
    end
end)

-- Being escorted loop
CreateThread(function()
    local alrEscorted
    while true do
        local sleep = 1500
        if isCuffed and escorted and escorted.active then
            sleep = 0
            local pdPed = GetPlayerPed(GetPlayerFromServerId(escorted.pdId))
            if DoesEntityExist(pdPed) and IsPedOnFoot(pdPed) and not IsPedDeadOrDying(pdPed, true) then
                if not alrEscorted then
                    AttachEntityToEntity(cache.ped, pdPed, 11816, 0.26, 0.48, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                    alrEscorted = true
                    isBusy = true
                else
                    sleep = 1000
                end
            else
                alrEscorted = false
                escorted.active = nil
                isBusy = nil
                DetachEntity(cache.ped, true, false)
            end
        elseif alrEscorted then
            alrEscorted = nil
            isBusy = nil
            DetachEntity(cache.ped, true, false)
        else
            sleep = 1500
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while QBCore.Functions.GetPlayerData().job == nil do
        Wait(1000) -- Necessary for some of the loops that use job check in these threads within threads.
    end
    
    for i=1, #Config.policeJobs do
        if Config.policeJobs[i] == QBCore.Functions.GetPlayerData().job.name then
            hasJob = QBCore.Functions.GetPlayerData().job.name
            break
        else
            hasJob = nil
        end
    end
    
    for k,v in pairs(Config.Locations) do
        if v.blip.enabled then
            createBlip(v.blip.coords, v.blip.sprite, v.blip.color, v.blip.string, v.blip.scale, false)
        end
        
        if v.bossMenu.enabled then
            if v.bossMenu.target and v.bossMenu.target.enabled then
                local data = {
                    targetType = 'AddBoxZone',
                    identifier = k..'_pdboss',
                    coords = v.bossMenu.target.coords,
                    heading = v.bossMenu.target.heading,
                    width = v.bossMenu.target.width,
                    length = v.bossMenu.target.length,
                    minZ = v.bossMenu.target.minZ,
                    maxZ = v.bossMenu.target.maxZ,
                    job = Config.policeJobs,
                    distance = 2.0,
                    options = {
                        {
                            event = 'vanguard_policejob:openBossMenu',
                            icon = 'fa-solid fa-suitcase-medical',
                            label = v.bossMenu.target.label
                        }
                    }
                }
                TriggerEvent('vanguard_policejob:addTarget', data)
            else
                CreateThread(function()
                    local textUI
                    while true do
                        local sleep = 1500
                        if hasJob then
                            if v.bossMenu.jobLock then
                                if hasJob == v.bossMenu.jobLock then
                                    local coords = GetEntityCoords(cache.ped)
                                    local dist = #(coords - v.bossMenu.coords)
                                    if dist <= v.bossMenu.distance then
                                        if not textUI then
                                            lib.showTextUI(v.bossMenu.label)
                                            textUI = true
                                        end
                                        sleep = 0
                                        if IsControlJustReleased(0, 38) then
                                            TriggerEvent('qb-bossmenu:client:openMenu')
                                        end
                                    else
                                        if textUI then
                                            lib.hideTextUI()
                                            textUI = nil
                                        end
                                    end
                                end
                            else
                                local coords = GetEntityCoords(cache.ped)
                                local dist = #(coords - v.bossMenu.coords)
                                if dist <= v.bossMenu.distance then
                                    if not textUI then
                                        lib.showTextUI(v.bossMenu.label)
                                        textUI = true
                                    end
                                    sleep = 0
                                    if IsControlJustReleased(0, 38) then
                                        TriggerEvent('qb-bossmenu:client:openMenu')
                                    end
                                else
                                    if textUI then
                                        lib.hideTextUI()
                                        textUI = nil
                                    end
                                end
                            end
                        end
                        Wait(sleep)
                    end
                end)
            end
        end
        
        if v.cloakroom.enabled then
            CreateThread(function()
                local textUI 
                while true do
                    local sleep = 1500
                    if hasJob and v.cloakroom.jobLock then
                        if hasJob == v.cloakroom.jobLock then
                            local coords = GetEntityCoords(cache.ped)
                            local dist = #(coords - v.cloakroom.coords)
                            if dist <= v.cloakroom.range then
                                if not textUI then
                                    lib.showTextUI(v.cloakroom.label)
                                    textUI = true
                                end
                                sleep = 0
                                if IsControlJustReleased(0, 38) then
                                    openOutfits(k)
                                end
                            else
                                if textUI then
                                    lib.hideTextUI()
                                    textUI = nil
                                end
                            end
                        end
                    elseif hasJob and not v.cloakroom.jobLock then
                        local coords = GetEntityCoords(cache.ped)
                        local dist = #(coords - v.cloakroom.coords)
                        if dist <= v.cloakroom.range then
                            if not textUI then
                                lib.showTextUI(v.cloakroom.label)
                                textUI = true
                            end
                            sleep = 0
                            if IsControlJustReleased(0, 38) then
                                openOutfits(k)
                            end
                        else
                            if textUI then
                                lib.hideTextUI()
                                textUI = nil
                            end
                        end
                    end
                    Wait(sleep)
                end
            end)
        end
        
        if v.armoury.enabled then
            CreateThread(function()
                local ped, pedSpawned
                local textUI
                while true do
                    local sleep = 1500
                    local playerPed = cache.ped
                    local coords = GetEntityCoords(playerPed)
                    local dist = #(coords - v.armoury.coords)
                    if dist <= 30 and not pedSpawned then
                        lib.requestAnimDict('mini@strip_club@idles@bouncer@base', 100)
                        lib.requestModel(v.armoury.ped, 100)
                        ped = CreatePed(28, v.armoury.ped, v.armoury.coords.x, v.armoury.coords.y, v.armoury.coords.z, v.armoury.heading, false, false)
                        FreezeEntityPosition(ped, true)
                        SetEntityInvincible(ped, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        TaskPlayAnim(ped, 'mini@strip_club@idles@bouncer@base', 'base', 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                        pedSpawned = true
                    elseif dist <= 2 and pedSpawned then
                        sleep = 0
                        if not textUI and hasJob then
                            lib.showTextUI(v.armoury.label)
                            textUI = true
                        end
                        if IsControlJustReleased(0, 38) and hasJob then
                            textUI = nil
                            lib.hideTextUI()
                            armouryMenu(k)
                        end
                    elseif dist >= 2.2 and textUI then
                        sleep = 0
                        lib.hideTextUI()
                        textUI = nil
                    elseif dist >= 31 and pedSpawned then
                        local model = GetEntityModel(ped)
                        SetModelAsNoLongerNeeded(model)
                        DeletePed(ped)
                        SetPedAsNoLongerNeeded(ped)
                        RemoveAnimDict('mini@strip_club@idles@bouncer@base')
                        pedSpawned = nil
                    end
                    Wait(sleep)
                end
            end)
        end
        
        if v.vehicles.enabled then
            CreateThread(function()
                local zone = v.vehicles.zone
                local textUI
                while true do
                    local sleep = 1500
                    if hasJob then
                        if v.jobLock then
                            if hasJob == v.jobLock then
                                local coords = GetEntityCoords(cache.ped)
                                local dist = #(coords - zone.coords)
                                local dist2 = #(coords - v.vehicles.spawn.air.coords)
                                if dist < zone.range + 1 and not inMenu and not IsPedInAnyVehicle(cache.ped, false) then
                                    sleep = 0
                                    if not textUI then
                                        lib.showTextUI(zone.label)
                                        textUI = true
                                    end
                                    if IsControlJustReleased(0, 38) then
                                        textUI = nil
                                        lib.hideTextUI()
                                        openVehicleMenu(k)
                                        sleep = 1500
                                    end
                                elseif dist < zone.range + 1 and not inMenu and IsPedInAnyVehicle(cache.ped, false) then
                                    sleep = 0
                                    if not textUI then
                                        textUI = true
                                        lib.showTextUI(zone.return_label)
                                    end
                                    if IsControlJustReleased(0, 38) then
                                        textUI = nil
                                        lib.hideTextUI()
                                        if DoesEntityExist(cache.vehicle) then
                                            DoScreenFadeOut(800)
                                            while not IsScreenFadedOut() do Wait(100) end
                                            SetEntityAsMissionEntity(cache.vehicle, false, false)
                                            DeleteVehicle(cache.vehicle)
                                            DoScreenFadeIn(800)
                                        end
                                    end
                                elseif dist2 < 10 and IsPedInAnyVehicle(cache.ped, false) then
                                    sleep = 0
                                    if not textUI then
                                        textUI = true
                                        lib.showTextUI(zone.return_label)
                                    end
                                    if IsControlJustReleased(0, 38) then
                                        textUI = nil
                                        lib.hideTextUI()
                                        if DoesEntityExist(cache.vehicle) then
                                            DoScreenFadeOut(800)
                                            while not IsScreenFadedOut() do Wait(100) end
                                            SetEntityAsMissionEntity(cache.vehicle)
                                            DeleteVehicle(cache.vehicle)
                                            SetEntityCoordsNoOffset(cache.ped, zone.coords.x, zone.coords.y, zone.coords.z, false, false, false, true)
                                            DoScreenFadeIn(800)
                                        end
                                    end
                                else
                                    if textUI then
                                        textUI = nil
                                        lib.hideTextUI()
                                    end
                                end
                            end
                        else
                            local coords = GetEntityCoords(cache.ped)
                            local dist = #(coords - zone.coords)
                            local dist2 = #(coords - v.vehicles.spawn.air.coords)
                            if dist < zone.range + 1 and not inMenu and not IsPedInAnyVehicle(cache.ped, false) then
                                sleep = 0
                                if not textUI then
                                    lib.showTextUI(zone.label)
                                    textUI = true
                                end
                                if IsControlJustReleased(0, 38) then
                                    textUI = nil
                                    lib.hideTextUI()
                                    openVehicleMenu(k)
                                    sleep = 1500
                                end
                            elseif dist < zone.range + 1 and not inMenu and IsPedInAnyVehicle(cache.ped, false) then
                                sleep = 0
                                if not textUI then
                                    textUI = true
                                    lib.showTextUI(zone.return_label)
                                end
                                if IsControlJustReleased(0, 38) then
                                    textUI = nil
                                    lib.hideTextUI()
                                    if DoesEntityExist(cache.vehicle) then
                                        DoScreenFadeOut(800)
                                        while not IsScreenFadedOut() do Wait(100) end
                                        SetEntityAsMissionEntity(cache.vehicle, false, false)
                                        DeleteVehicle(cache.vehicle)
                                        DoScreenFadeIn(800)
                                    end
                                end
                            elseif dist2 < 10 and IsPedInAnyVehicle(cache.ped, false) then
                                sleep = 0
                                if not textUI then
                                    textUI = true
                                    lib.showTextUI(zone.return_label)
                                end
                                if IsControlJustReleased(0, 38) then
                                    textUI = nil
                                    lib.hideTextUI()
                                    if DoesEntityExist(cache.vehicle) then
                                        DoScreenFadeOut(800)
                                        while not IsScreenFadedOut() do Wait(100) end
                                        SetEntityAsMissionEntity(cache.vehicle)
                                        DeleteVehicle(cache.vehicle)
                                        SetEntityCoordsNoOffset(cache.ped, zone.coords.x, zone.coords.y, zone.coords.z, false, false, false, true)
                                        DoScreenFadeIn(800)
                                    end
                                end
                            else
                                if textUI then
                                    textUI = nil
                                    lib.hideTextUI()
                                end
                            end
                        end
                    end
                    Wait(sleep)
                end
            end)
        end
    end
end)

-- Prop placement loop
CreateThread(function()
    local movingProp = false
    function isEntityProp(ent)
        local model = GetEntityModel(ent)
        for i=1, #Config.Props do 
            if model == Config.Props[i].model then 
                return true, i
            end
        end
    end
    function RequestNetworkControl(entity)
        NetworkRequestControlOfEntity(entity)
        local timeout = 2000
        while timeout > 0 and not NetworkHasControlOfEntity(entity) do
            Wait(100)
            timeout = timeout - 100
        end
        SetEntityAsMissionEntity(entity, true, true)
        local timeout = 2000
        while timeout > 0 and not IsEntityAMissionEntity(entity) do
            Wait(100)
            timeout = timeout - 100
        end
        return NetworkHasControlOfEntity(entity)
    end
    while true do 
        local wait = 2500
        local ped = cache.ped
        local pcoords = GetEntityCoords(ped)
        if hasJob then
            if (not movingProp) then 
                local objPool = GetGamePool('CObject')
                for i = 1, #objPool do
                    local ent = objPool[i]
                    local prop, index = isEntityProp(ent)
                    if (prop) then 
                        local dist = #(GetEntityCoords(ent) - pcoords)
                        if dist < 1.75 and not IsPedInAnyVehicle(ped, false) then 
                            wait = 0
                            QBCore.Functions.HelpNotify(Strings.prop_help_text)
                            if IsControlJustPressed(1, 51) then 
                                RequestNetworkControl(ent)
                                movingProp = ent
                                local c, r = vec3(0.0, 1.0, -1.0), vec3(0.0, 0.0, 0.0)
                                AttachEntityToEntity(movingProp, ped, ped, c.x, c.y, c.z, r.x, r.y, r.z, false, false, false, false, 2, true)
                                break
                            elseif IsControlJustPressed(1, 47) then
                                RequestNetworkControl(ent)
                                DeleteObject(ent)
                                break
                            end
                        end
                    end
                end
            else
                wait = 0
                QBCore.Functions.HelpNotify(Strings.prop_help_text2)
                if IsControlJustPressed(1, 51) then 
                    RequestNetworkControl(movingProp)
                    DetachEntity(movingProp)
                    PlaceObjectOnGroundProperly(movingProp)
                    FreezeEntityPosition(movingProp, true)
                    movingProp = nil
                end
            end
        end
        Wait(wait)
    end
end)

-- Spike strip functionality
if Config.spikeStripsEnabled then
    CreateThread(function()
        local spikes = `p_ld_stinger_s`
        while true do
            local sleep = 1500
            local coords = GetEntityCoords(cache.ped)
            local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 100.0, spikes, false, false, false)
            if DoesEntityExist(obj) and IsPedInAnyVehicle(cache.ped, false)  then
                sleep = 0
                local vehicle = GetVehiclePedIsIn(cache.ped)
                local objCoords = GetEntityCoords(obj)
                local dist = #(vec3(coords.x, coords.y, coords.z) - vec3(objCoords.x, objCoords.y, objCoords.z))
                if dist < 3.0 then
                    for i=0, 7 do
                        if not IsVehicleTyreBurst(vehicle, i, false) then
                            SetVehicleTyreBurst(vehicle, i, true, 1000)
                        end
                    end
                    sleep = 1500
                end
            end
            Wait(sleep)
        end
    end)
end

if Config.tackle.enabled then
    RegisterCommand('tacklePlayer', function()
        attemptTackle()
    end)
    TriggerEvent('chat:removeSuggestion', '/tacklePlayer')
    RegisterKeyMapping('tacklePlayer', Strings.key_map_tackle, 'keyboard', Config.tackle.hotkey)
end

if Config.handcuff.hotkey then
    RegisterCommand('cuffPlayer', function()
        TriggerEvent('vanguard_policejob:handcuffPlayer')
    end)
    TriggerEvent('chat:removeSuggestion', '/cuffPlayer')
    RegisterKeyMapping('cuffPlayer', Strings.key_map_cuff, 'keyboard', Config.handcuff.hotkey)
end 

RegisterCommand('pdJobMenu', function()
    openJobMenu()
end)

AddEventHandler('vanguard_policejob:pdJobMenu', function()
    openJobMenu()
end)

TriggerEvent('chat:removeSuggestion', '/pdJobMenu')

RegisterKeyMapping('pdJobMenu', Strings.key_map_job, 'keyboard', Config.jobMenu)

--Customize notifications
RegisterNetEvent('vanguard_policejob:notify', function(title, desc, style)
    lib.notify({
        title = title,
        description = desc,
        duration = 3500,
        type = style
    })
end)

--Custom Car lock
addCarKeys = function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', plate) -- Adjust to your car key system
end

--Impound Vehicle
impoundSuccessful = function(vehicle)
    if not DoesEntityExist(vehicle) then return end
    SetEntityAsMissionEntity(vehicle, false, false)
    DeleteEntity(vehicle)
    if not DoesEntityExist(vehicle) then
        TriggerEvent('vanguard_policejob:notify', Strings.success, Strings.car_impounded_desc, 'success')
    end
end

--Death check
deathCheck = function(serverId)
    local ped = GetPlayerPed(GetPlayerFromServerId(serverId))
    return IsPedFatallyInjured(ped)
    or IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3)
    or IsEntityPlayingAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 3)
end

--Search player
searchPlayer = function(player)
    if Config.inventory == 'ox' then
        exports.ox_inventory:openNearbyInventory()
    elseif Config.inventory == 'qs' then
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", GetPlayerServerId(player))
    elseif Config.inventory == 'qb' then
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", GetPlayerServerId(player))
    elseif Config.inventory == 'custom' then
        -- INSERT CUSTOM SEARCH PLAYER FOR YOUR INVENTORY
    end
end

exports('searchPlayer', searchPlayer)

-- Customize target
AddEventHandler('vanguard_policejob:addTarget', function(d)
    if d.targetType == 'AddBoxZone' then
        exports['qb-target']:AddBoxZone(d.identifier, d.coords, d.width, d.length, {
            name=d.identifier,
            heading=d.heading,
            debugPoly=false,
            minZ=d.minZ,
            maxZ=d.maxZ
        }, {
            options = d.options,
            job = d.job,
            distance = d.distance
        })
    elseif d.targetType == 'Player' then
        exports['qb-target']:Player({
            options = d.options,
            distance = d.distance
        })
    elseif d.targetType == 'Vehicle' then
        exports['qb-target']:Vehicle({
            options = d.options,
            distance = d.distance
        })
    end
end)

--Change clothes(Cloakroom)
AddEventHandler('vanguard_policejob:changeClothes', function(data) 
    if data == 'civ_wear' then
        QBCore.Functions.TriggerCallback('qb-clothing:server:getPlayerSkin', function(skinData)
            TriggerEvent('qb-clothing:client:loadPlayerClothing', skinData)
        end)
    else
        local gender = QBCore.Functions.GetPlayerData().charinfo.gender
        if gender == 0 then  -- Male
            TriggerEvent('qb-clothing:client:loadOutfit', data.male)
        else  -- Female
            TriggerEvent('qb-clothing:client:loadOutfit', data.female)
        end
    end
end)

-- Billing event
AddEventHandler('vanguard_policejob:finePlayer', function()
    if not hasJob then return end
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player == -1 or dist > 3.5 then
        TriggerEvent('vanguard_policejob:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        local targetId = GetPlayerServerId(player)
        local jobInfo = QBCore.Shared.Jobs[hasJob]
        local input = lib.inputDialog('Bill Citizen', {'Amount'})
        if not input then return end
        local amount = math.floor(tonumber(input[1]))
        if amount < 1 then
            TriggerEvent('vanguard_policejob:notify', Strings.invalid_entry, Strings.invalid_entry_desc, 'error')
        else
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender = jobInfo.label,
                subject = Strings.fines,
                message = "You received a fine of $" .. amount,
                button = {
                    enabled = true,
                    buttonEvent = "qb-phone:client:AcceptFine",
                    buttonData = {
                        amount = amount,
                        sender = hasJob
                    }
                }
            })
        end
    end
end)

-- Function to create menu options
local function createOption(title, description, icon, arrow, event, args, onSelect)
    return {
        title = title,
        description = description,
        icon = icon,
        arrow = arrow,
        event = event,
        args = args,
        onSelect = onSelect
    }
end

-- Job menu
openJobMenu = function()
    if not hasJob then return end
    local jobInfo = QBCore.Shared.Jobs[hasJob]

    -- Citizen Actions
    local citizenActions = {
        createOption(Strings.check_id, Strings.check_id_desc, 'id-card', true, 'vanguard_policejob:checkId')
    }

    if Config.searchPlayers then
        citizenActions[#citizenActions + 1] = createOption(Strings.search_player, Strings.search_player_desc, 'magnifying-glass', false, 'vanguard_policejob:searchPlayer')
    end

    citizenActions[#citizenActions + 1] = createOption(Strings.handcuff_player, Strings.handcuff_player_desc, 'hands-bound', false, 'vanguard_policejob:handcuffPlayer')
    citizenActions[#citizenActions + 1] = createOption(Strings.escort_player, Strings.escort_player_desc, 'hand-holding-hand', false, 'vanguard_policejob:escortPlayer')

    if Config.customJail then
        citizenActions[#citizenActions + 1] = createOption(Strings.jail_player, Strings.jail_player_desc, 'lock', false, 'vanguard_policejob:jailPlayer')
    end

    if Config.billingSystem then
        citizenActions[#citizenActions + 1] = createOption(Strings.fines, Strings.fines_desc, 'file-invoice', false, 'vanguard_policejob:finePlayer')
    end

    -- Add "Return" option to Citizen Actions
    citizenActions[#citizenActions + 1] = createOption(Strings.go_back, '', 'arrow-left', false, nil, nil, function()
        lib.showContext('pd_job_menu') -- Return to main menu
    end)

    -- Vehicle Actions
    local vehicleActions = {
        createOption(Strings.put_in_vehicle, Strings.put_in_vehicle_desc, 'arrow-right-to-bracket', false, 'vanguard_policejob:inVehiclePlayer'),
        createOption(Strings.take_out_vehicle, Strings.take_out_vehicle_desc, 'arrow-right-from-bracket', false, 'vanguard_policejob:outVehiclePlayer'),
        createOption(Strings.vehicle_interactions, Strings.vehicle_interactions_desc, 'car', true, 'vanguard_policejob:vehicleInteractions')
    }
    
    -- Add "Return" option to Vehicle Actions
    vehicleActions[#vehicleActions + 1] = createOption(Strings.go_back, '', 'arrow-left', false, nil, nil, function()
        lib.showContext('pd_job_menu') -- Return to main menu
    end)

    -- Main menu
    local Options = {
        createOption("Citizen Actions", "Actions related to citizens", 'user', true, nil, nil, function()
            lib.registerContext({
                id = 'pd_citizen_actions',
                title = "Citizen Actions",
                options = citizenActions
            })
            lib.showContext('pd_citizen_actions')
        end),
        createOption("Vehicle Actions", "Actions related to vehicles", 'car', true, nil, nil, function()
            lib.registerContext({
                id = 'pd_vehicle_actions',
                title = "Vehicle Actions",
                options = vehicleActions
            })
            lib.showContext('pd_vehicle_actions')
        end),
        createOption(Strings.place_object, Strings.place_object_desc, 'box', true, 'vanguard_policejob:placeObjects')
    }

    -- Register and show main menu
    lib.registerContext({
        id = 'pd_job_menu',
        title = jobInfo.label,
        options = Options
    })
    lib.showContext('pd_job_menu')
end

CreateThread(function()
    for i, jobConfig in pairs(Config.Jobs) do
        for _, location in pairs(jobConfig.Locations) do
            -- Check if 'qb-target' resource is available
            if GetResourceState("qb-target") ~= "missing" then
                exports['qb-target']:AddCircleZone(i.."_dutytoggle", location, 1.0, {
                    name = i.."_dutytoggle",
                    debugPoly = false,
                    useZ = true,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "qb-policejob:client:ToggleDuty",
                            icon = "fas fa-sign-in-alt",
                            label = "Toggle Duty",
                            job = {
                                [jobConfig.ClockedInJob] = 0,
                                [jobConfig.ClockedOutJob] = 0
                            }
                        },
                    },
                    distance = 1.5
                })
            end
        end
    end
end)

RegisterNetEvent('qb-policejob:client:ToggleDuty', function()
    local playerData = QBCore.Functions.GetPlayerData()
    local jobName = playerData.job.name
    
    for i, jobConfig in pairs(Config.Jobs) do
        if jobName == jobConfig.ClockedInJob then
            -- Clocking out
            TriggerServerEvent("QBCore:ToggleDuty", false, jobConfig)
            return
        elseif jobName == jobConfig.ClockedOutJob then
            -- Clocking in
            TriggerServerEvent("QBCore:ToggleDuty", true, jobConfig)
            return
        end
    end
end)

currentWeapon = `WEAPON_UNARMED`
syncedRopes = {} -- playerServerId = ropeid
hasLanyard = false

Citizen.CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        playerWeapon = GetSelectedPedWeapon(playerPed)

        if currentWeapon ~= playerWeapon then
            if hasLanyard then
                TriggerServerEvent("obWeaponLanyard:removelanyard")
                hasLanyard = false
            end

            if isWeaponAllowed(playerWeapon) and not hasLanyard then
                TriggerServerEvent("obWeaponLanyard:createlanyard")
                hasLanyard = true
            end

            currentWeapon = playerWeapon
        end

        Citizen.Wait(100)
    end
end)

function isWeaponAllowed(weapon)
    for _, configWeapon in ipairs(Config.AcceptedWeapons) do
        if weapon == configWeapon then
            return true
        end
    end

    return false
end

RegisterNetEvent("obWeaponLanyard:createlanyard")
AddEventHandler("obWeaponLanyard:createlanyard", function(playerServerId)
    RopeLoadTextures()
    Citizen.Wait(250)

    player = GetPlayerPed(GetPlayerFromServerId(playerServerId))
    playerWeapon = GetCurrentPedWeaponEntityIndex(player)
    playerCoords = GetEntityCoords(player)
    playerBone = GetEntityBoneIndexByName(player, 'SKEL_Pelvis')
    playerBoneCoords = GetPedBoneCoords(player, playerBone, vector3(0, 0, 0))
    playerBoneCoords = playerBoneCoords - playerCoords

    weaponBone = 'gun_gripr'

    if Config.CustomBones[playerWeapon] then
        weaponBone = Config.CustomBones[playerWeapon]
    end

    rope = AddRope(playerCoords, 0.0, 0.0, 0.0, 0.1, 5, 4.0, 0.001, 1.0, true, false, true, 1.0, false)
    AttachEntitiesToRope(rope, player, playerWeapon, playerBoneCoords, vector3(0,0,0), 3.0, 0, 0, 'SKEL_Pelvis', weaponBone)

    syncedRopes[playerServerId] = rope
end)

RegisterNetEvent("obWeaponLanyard:removelanyard")
AddEventHandler("obWeaponLanyard:removelanyard", function(playerServerId)
    if syncedRopes[playerServerId] then
        DeleteRope(rope)
        syncedRopes[playerServerId] = nil
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y = World3dToScreen2d(x, y, z)
    local px,py,pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 155)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local lastReportTime = 0
local cooldownTime = 5000 
local pspPed = nil 
local heading = Config['VanguardPeds']['VanguardPed']['heading']
local pspPedCoords = Config['VanguardPeds']['VanguardPed']['coords']

-- Load the NPC model
Citizen.CreateThread(function()
    local model = GetHashKey(Config['VanguardPeds']['VanguardPed']['name'])
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    pspPed = CreatePed(5, model, pspPedCoords, heading, false, false)
    SetEntityAsMissionEntity(pspPed, true, true)
    SetBlockingOfNonTemporaryEvents(pspPed, true)
    FreezeEntityPosition(pspPed, true)
    SetEntityInvincible(pspPed, true)
end)

local function openMenu()
    local player = PlayerPedId()
    local dict = 'amb@code_human_wander_clipboard@male@base' 
    local name = 'static'
    local boneIndex = GetPedBoneIndex(player, 0x49D9)
    lib.requestAnimDict(dict, false)
    TaskPlayAnim(player, dict, name, 8.0, 8.0, -1, 32, 0, true, true, true)
    local input = lib.inputDialog('Police Department', {'Name', 'Phone Number', 'Service Level (not urgent, urgent)', 'Description'})
    if not input then ClearPedTasksImmediately(player) return end
    
    local currentTime = GetGameTimer()
    if currentTime < lastReportTime + cooldownTime then
        local timeRemaining = math.ceil((lastReportTime + cooldownTime - currentTime) / 1000)
        lib.notify({title = 'Police Department', description = 'You must wait '..timeRemaining..' seconds before sending another report.', type = 'error'})
        ClearPedTasksImmediately(player)
        return
    end
    
    TriggerServerEvent('VanguardLabsPeds:sendData', input[1], input[2], input[3], input[4])    
    lib.notify({title = 'Police Department', description = 'Your report has been successfully sent.', type = 'success'})
    ClearPedTasksImmediately(player)
    
    lastReportTime = currentTime
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local pspPedCoords = GetEntityCoords(pspPed)
        local distance = Vdist(playerCoords, pspPedCoords)
        if distance <= 6.0 then
            DrawText3D(pspPedCoords.x, pspPedCoords.y, pspPedCoords.z + 1.1, "~d~" .. Config['VanguardPeds']['VanguardPed']['pedName'])
            DrawText3D(pspPedCoords.x, pspPedCoords.y, pspPedCoords.z + 1.0, Config['VanguardPeds']['VanguardPed']['reportText'])      
            if IsControlJustPressed(0, 38) and DoesEntityExist(pspPed) and distance < 2.5 then
                openMenu()
            end
        end
    end
end)

createBlip = function(coords, sprite, color, text, scale, flash)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName(text.blip)
    EndTextCommandSetBlipName(text.blip)
    if flash then
        SetBlipFlashes(blip, true)
    end
end

local firstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

local addCommas = function(n)
    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,")
                                  :gsub(",(%-?)$","%1"):reverse()
end

openOutfits = function(station)
    local data = Config.Locations[station].cloakroom.uniforms
    local Options = {
        {
            title = Strings.civilian_wear,
            description = '',
            arrow = false,
            event = 'vanguard_policejob:changeClothes',
            args = 'civ_wear'
        }
    }
    for i=1, #data do
        Options[#Options + 1] = {
            title = data[i].label,
            description = '',
            arrow = false,
            event = 'vanguard_policejob:changeClothes',
            args = {male = data[i].male, female = data[i].female}
        }
    end
    lib.registerContext({
        id = 'pd_cloakroom',
        title = Strings.cloakroom,
        options = Options
    })
    lib.showContext('pd_cloakroom')
end

exports('openOutfits', openOutfits)

escortPlayer = function(targetId)
    local targetCuffed = lib.callback.await('vanguard_policejob:isCuffed', 100, targetId)
    if targetCuffed then
        TriggerServerEvent('vanguard_policejob:escortPlayer', targetId)
    else
        TriggerEvent('vanguard_policejob:notify', Strings.not_restrained, Strings.not_restrained_desc, 'error')
    end
end

exports('escortPlayer', escortPlayer)

handcuffPlayer = function(targetId)
    if not hasJob then return end
    if deathCheck(targetId) then
        TriggerEvent('vanguard_policejob:notify', Strings.unconcious, Strings.unconcious_desc, 'error')
    else
        TriggerServerEvent('vanguard_policejob:handcuffPlayer', targetId)
    end
end

local startCuffTimer = function()
    if Config.handcuff.timer and cuffTimer.active then
        QBCore.Functions.Notify('Clearing cuff timer...')
    end
    cuffTimer.active = true
    cuffTimer.timer = SetTimeout(Config.handcuff.timer, function()
        TriggerEvent('vanguard_policejob:uncuff')
    end)
end

handcuffed = function()
    isCuffed = true
    TriggerServerEvent('vanguard_policejob:setCuff', true)
    lib.requestAnimDict('mp_arresting', 100)
    TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
    SetEnableHandcuffs(cache.ped, true)
    DisablePlayerFiring(cache.ped, true)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    SetPedCanPlayGestureAnims(cache.ped, false)
    FreezeEntityPosition(cache.ped, true)
    DisplayRadar(false)
    if Config.handcuff.timer then
        if cuffTimer.active then
            QBCore.Functions.Notify('Clearing cuff timer...')
        end
        startCuffTimer()
    end
end

uncuffed = function()
    if not isCuffed then return end
    isCuffed = false
    TriggerServerEvent('vanguard_policejob:setCuff', false)
    SetEnableHandcuffs(cache.ped, false)
    DisablePlayerFiring(cache.ped, false)
    SetPedCanPlayGestureAnims(cache.ped, true)
    FreezeEntityPosition(cache.ped, false)
    DisplayRadar(true)
    if Config.handcuff.timer and cuffTimer.active then
        QBCore.Functions.Notify('Clearing cuff timer...')
    end
    Wait(250) -- Only in fivem ;)
    ClearPedTasks(cache.ped)
    ClearPedSecondaryTask(cache.ped)
    if cuffProp and DoesEntityExist(cuffProp) then
        SetEntityAsMissionEntity(cuffProp, true, true)
        DetachEntity(cuffProp)
        DeleteObject(cuffProp)
        cuffProp = nil
    end
end

-- Manage ID
manageId = function(data)
    local targetId, license = data.targetId, data.license
    local Options = {
        createOption(Strings.go_back, '', '', false, 'vanguard_policejob:checkId', targetId),
        createOption(Strings.revoke_license, '', '', false, 'vanguard_policejob:revokeLicense', {targetId = targetId, license = license.type})
    }

    lib.registerContext({
        id = 'pd_manage_id',
        title = (license.label or firstToUpper(tostring(license.type))),
        options = Options
    })
    lib.showContext('pd_manage_id')
end

-- Open License Menu
openLicenseMenu = function(data)
    local targetId, licenses = data.targetId, data.licenses
    local Options = {
        createOption(Strings.go_back, '', '', false, 'vanguard_policejob:checkId', targetId)
    }

    for i = 1, #licenses do
        Options[#Options + 1] = createOption((licenses[i].label or firstToUpper(tostring(licenses[i].type))), '', '', true, 'vanguard_policejob:manageId', {targetId = targetId, license = licenses[i]})
    end

    -- Add "Return" option to License Menu
    Options[#Options + 1] = createOption(Strings.go_back, '', 'arrow-left', false, nil, nil, function()
        lib.showContext('pd_job_menu') -- Return to main menu
    end)

    lib.registerContext({
        id = 'pd_license_check',
        title = Strings.licenses,
        options = Options
    })
    lib.showContext('pd_license_check')
end

-- Check Player ID
checkPlayerId = function(targetId)
    QBCore.Functions.TriggerCallback('vanguard_policejob:checkPlayerId', function(data)
        local Options = {
            createOption(Strings.go_back, '', '', false, 'vanguard_policejob:pdJobMenu'),
            createOption(Strings.name, data.name, 'id-badge', false, 'vanguard_policejob:pdJobMenu'),
            createOption(Strings.job, data.job, 'briefcase', false, 'vanguard_policejob:pdJobMenu'),
            createOption(Strings.job_position, data.position, 'briefcase', false, 'vanguard_policejob:pdJobMenu')
        }

        if data.dob then
            Options[#Options + 1] = createOption(Strings.dob, data.dob, 'cake-candles', false, 'vanguard_policejob:pdJobMenu')
        end
        
        if data.sex then
            Options[#Options + 1] = createOption(Strings.sex, data.sex, 'venus-mars', false, 'vanguard_policejob:pdJobMenu')
        end

        if data.drunk then
            Options[#Options + 1] = createOption(Strings.bac, data.drunk, 'champagne-glasses', false, 'vanguard_policejob:pdJobMenu')
        end

        if not data.licenses or #data.licenses < 1 then
            Options[#Options + 1] = createOption(Strings.licenses, Strings.no_licenses, 'id-card', true, 'vanguard_policejob:pdJobMenu')
        else
            Options[#Options + 1] = createOption(Strings.licenses, Strings.total_licenses..' '..#data.licenses, 'id-card', true, 'vanguard_policejob:licenseMenu', {licenses = data.licenses, targetId = targetId})
        end

        -- Add "Return" option to Check Player ID
        Options[#Options + 1] = createOption(Strings.go_back, '', 'arrow-left', false, nil, nil, function()
            lib.showContext('pd_job_menu') -- Return to main menu
        end)

        lib.registerContext({
            id = 'pd_id_check',
            title = Strings.id_result_menu,
            options = Options
        })
        lib.showContext('pd_id_check')
    end, targetId)
end

-- Vehicle Info Menu
vehicleInfoMenu = function(vehicle)
    if not DoesEntityExist(vehicle) then
        TriggerEvent('vanguard_policejob:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local plate = GetVehicleNumberPlateText(vehicle)
        local ownerData = lib.callback.await('vanguard_policejob:getVehicleOwner', 100, plate)
        local Options = {
            createOption(Strings.go_back, '', '', false, 'vanguard_policejob:vehicleInteractions'),
            createOption(Strings.plate, plate, '', false, 'vanguard_policejob:pdJobMenu')
        }

        if ownerData then
            Options[#Options + 1] = createOption(Strings.owner, ownerData, '', false, 'vanguard_policejob:pdJobMenu')
        else
            Options[#Options + 1] = createOption(Strings.possibly_stolen, Strings.possibly_stolen_desc, '', false, 'vanguard_policejob:pdJobMenu')
        end

        -- Add "Return" option to Vehicle Info Menu
        Options[#Options + 1] = createOption(Strings.go_back, '', 'arrow-left', false, nil, nil, function()
            lib.showContext('pd_job_menu') -- Return to main menu
        end)

        lib.registerContext({
            id = 'pd_veh_info_menu',
            title = Strings.vehicle_interactions,
            options = Options
        })
        lib.showContext('pd_veh_info_menu')
    end
end

lockpickVehicle = function(vehicle)
    if not DoesEntityExist(vehicle) then
        TriggerEvent('vanguard_policejob:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local playerCoords = GetEntityCoords(cache.ped)
        local targetCoords = GetEntityCoords(vehicle)
        local dist = #(playerCoords - targetCoords)
        if dist < 2.5 then
            TaskTurnPedToFaceCoord(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, 2000)
            Wait(2000)
            if lib.progressCircle({
                duration = 7500,
                position = 'bottom',
                label = Strings.lockpick_progress,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    scenario = 'PROP_HUMAN_PARKING_METER',
                },
            }) then
                SetVehicleDoorsLocked(vehicle, 1)
                SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                TriggerEvent('vanguard_policejob:notify', Strings.lockpicked, Strings.lockpicked_desc, 'success')
            else
                TriggerEvent('vanguard_policejob:notify', Strings.cancelled, Strings.cancelled_desc, 'error')
            end
        else
            TriggerEvent('vanguard_policejob:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end

impoundVehicle = function(vehicle)
    if not DoesEntityExist(vehicle) then
        TriggerEvent('vanguard_policejob:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local playerCoords = GetEntityCoords(cache.ped)
        local targetCoords = GetEntityCoords(vehicle)
        local dist = #(playerCoords - targetCoords)
        if dist < 2.5 then
            local driver = GetPedInVehicleSeat(vehicle, -1)
            if driver == 0 then
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                TaskTurnPedToFaceCoord(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, 2000)
                Wait(2000)
                if lib.progressCircle({
                    duration = 7500,
                    position = 'bottom',
                    label = Strings.impounding_progress,
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                    anim = {
                        scenario = 'PROP_HUMAN_PARKING_METER',
                    },
                }) then
                    impoundSuccessful(vehicle)
                else
                    TriggerEvent('vanguard_policejob:notify', Strings.cancelled, Strings.cancelled_desc, 'error')
                end
            else
                TriggerEvent('vanguard_policejob:notify', Strings.driver_in_car, Strings.driver_in_car_desc, 'error')
            end
        else
            TriggerEvent('vanguard_policejob:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end

vehicleInteractionMenu = function()
    lib.registerContext({
        id = 'pd_veh_menu',
        title = Strings.vehicle_interactions,
        options = {
            {
                title = Strings.go_back,
                description = '',
                arrow = false,
                event = 'vanguard_policejob:pdJobMenu',
            },
            {
                title = Strings.vehicle_information,
                description = Strings.vehicle_information_desc,
                icon = 'magnifying-glass',
                arrow = false,
                event = 'vanguard_policejob:vehicleInfo',
            },
            {
                title = Strings.lockpick_vehicle,
                description = Strings.locakpick_vehicle_desc,
                icon = 'lock-open',
                arrow = false,
                event = 'vanguard_policejob:lockpickVehicle',
            },
            {
                title = Strings.impound_vehicle,
                description = Strings.impound_vehicle_desc,
                icon = 'reply',
                arrow = false,
                event = 'vanguard_policejob:impoundVehicle',
            },
        }
    })
    lib.showContext('pd_veh_menu')
end

placeObjectsMenu = function()
    local options = {
        {
            title = Strings.go_back,
            description = '',
            arrow = false,
            event = 'vanguard_policejob:pdJobMenu',
        },
    }
    for i=1, #Config.Props do 
        local data = Config.Props[i]
        local add = true
        if (data.groups) then 
            local rank = data.groups[QBCore.Functions.GetPlayerData().job.name]
            if not (rank and QBCore.Functions.GetPlayerData().job.grade.level >= rank) then 
                add = false
            end
        end
        if (add) then 
            data.arrow = false
            data.event = "vanguard_policejob:spawnProp"
            data.args = i

            options[#options + 1] = data
        end
    end
    lib.registerContext({
        id = 'pd_object_menu',
        title = Strings.vehicle_interactions,
        options = options
    })
    lib.showContext('pd_object_menu')
end

armouryMenu = function(station)
    local data = Config.Locations[station].armoury
    local allow = false
    local aData
    if data.jobLock then
        if data.jobLock == QBCore.Functions.GetPlayerData().job.name then
            allow = true
        end
    else
        allow = true
    end
    if allow then
        local jobGrade = QBCore.Functions.GetPlayerData().job.grade.level
        if jobGrade > #data.weapons then
            aData = data.weapons[#data.weapons]
        elseif not data.weapons[jobGrade] then
            print('[vanguard_policejob] : ARMORY NOT SET UP PROPERLY FOR GRADE: '..jobGrade)
        else
            aData = data.weapons[jobGrade]
        end
        local Options = {}
        for k,v in pairs(aData) do
            Options[#Options + 1] = {
                title = v.label,
                description = '',
                arrow = false,
                event = 'vanguard_policejob:purchaseArmoury',
                args = { id = station, grade = jobGrade, itemId = k, multiple = false }
            }
            if v.price then
                Options[#Options].description = Strings.currency..addCommas(v.price)
            end
            if v.multiple then
                Options[#Options].args.multiple = true
            end
        end
        lib.registerContext({
            id = 'pd_armoury',
            title = Strings.armoury_menu,
            options = Options
        })
        lib.showContext('pd_armoury')
    else
        TriggerEvent('vanguard_policejob:notify', Strings.no_permission, Strings.no_access_desc, 'error')
    end
end

openVehicleMenu = function(station)
    if not hasJob then return end
    local data
    local jobGrade = QBCore.Functions.GetPlayerData().job.grade.level
    if jobGrade > #Config.Locations[station].vehicles.options then
        data = Config.Locations[station].vehicles.options[#Config.Locations[station].vehicles.options]
    elseif not Config.Locations[station].vehicles.options[jobGrade] then
        print('[vanguard_policejob] : Police garage not set up properly for job grade: '..jobGrade)
        return
    else
        data = Config.Locations[station].vehicles.options[jobGrade]
    end
    local Options = {}
    for k,v in pairs(data) do
        if v.category == 'land' then
            Options[#Options + 1] = {
                title = v.label,
                description = '',
                icon = 'car',
                arrow = true,
                event = 'vanguard_policejob:spawnVehicle',
                args = { station = station, model = k, grade = jobGrade }
            }
        elseif v.category == 'air' then
            Options[#Options + 1] = {
                title = v.label,
                description = '',
                icon = 'helicopter',
                arrow = true,
                event = 'vanguard_policejob:spawnVehicle',
                args = { station = station, model = k, grade = jobGrade, category = v.category }
            }
        end
    end
    lib.registerContext({
        id = 'pd_garage_menu',
        title = Strings.police_garage,
        onExit = function()
            inMenu = false
        end,
        options = Options
    })
    lib.showContext('pd_garage_menu')
end

local lastTackle = 0
attemptTackle = function()
    if not IsPedSprinting(cache.ped) then return end
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if dist ~= -1 and dist < 2.01 and not isBusy and not IsPedInAnyVehicle(cache.ped) and not IsPedInAnyVehicle(GetPlayerPed(player)) and GetGameTimer() - lastTackle > 7 * 1000 then
        if Config.tackle.policeOnly then
            if hasJob then
                lastTackle = GetGameTimer()
                TriggerServerEvent('vanguard_policejob:attemptTackle', GetPlayerServerId(player))
            end
        else
            lastTackle = GetGameTimer()
            TriggerServerEvent('vanguard_policejob:attemptTackle', GetPlayerServerId(player))
        end
    end
end

getTackled = function(targetId)
    isBusy = true
    local target = GetPlayerPed(GetPlayerFromServerId(targetId))
    lib.requestAnimDict('missmic2ig_11', 100)
    AttachEntityToEntity(cache.ped, target, 11816, 0.25, 0.5, 0.0, 0.5, 0.5, 180.0, false, false, false, false, 2, false)
    TaskPlayAnim(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_p_one', 8.0, -8.0, 3000, 0, 0, false, false, false)
    Wait(3000)
    DetachEntity(cache.ped, true, false)
    SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
    isRagdoll = true
    Wait(3000)
    isRagdoll = false
    isBusy = false
    RemoveAnimDict('missmic2ig_11')
end

tacklePlayer = function()
    isBusy = true
    lib.requestAnimDict('missmic2ig_11', 100)
    TaskPlayAnim(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_goon', 8.0, -8.0, 3000, 0, 0, false, false, false)
    Wait(3000)
    isBusy = false
    RemoveAnimDict('missmic2ig_11')
end