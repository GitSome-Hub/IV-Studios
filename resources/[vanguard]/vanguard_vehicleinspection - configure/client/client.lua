Vanguard = exports["Vanguard_Bridge"]:Vanguard()

Menu = Vanguard.GetMenu()

if Menu == "lib" then
    Menu = lib
else
    Menu = Vanguard
end

local lastInspectedVehicle = nil
local lastInspectionResult = nil

function OpenSetWorkClothes()
    Menu.showContext('clothes_inspection_menu')
end

Menu.registerContext({
    id = 'clothes_inspection_menu',
    title = 'Clothing Menu',
    description = 'Choose your clothing type',
    canClose = true, 
    options = {
        {
            title = 'Normal Clothing',
            icon = 'fa-solid fa-shirt', 
            description = 'Access normal clothing',
            onSelect = function()
                uniformType = "civ_wear"
                configuniforms = Config.Uniforms
                Menu.Clothe(uniformType, male, female, configuniforms)
            end,
            canClose = true  
        },
        {
            title = 'Inspection Clothing',
            icon = 'fa-solid fa-hard-hat',  
            description = 'Access inspection clothing',
            onSelect = function()
                Menu.showContext('inspection_uniform')
            end,
            canClose = false
        }
    }
})

local uniformOptions = {}  -- Create a table to store uniform options.

for key, uniforms in pairs(Config.Uniforms) do
    table.insert(uniformOptions, {
        title = uniforms.name,
        icon = "fa-light fa-clothes",
        description = "Wear inspection uniform",
        onSelect = function()
            uniformType = "uniform"
            male = uniforms.male
            female = uniforms.female
            configuniforms = Config.Uniforms
            Menu.Clothe(uniformType, male, female, configuniforms)
        end,
        canClose = true,
    })
end

Menu.registerContext({
    id = 'inspection_uniform',
    title = 'Select a Uniform',
    options = uniformOptions,
    menu = 'clothes_inspection_menu',
   canClose = true,
})

local function createClothesInteractionZone()
    local location = Config.ClothesRoom
    local jobAllowed = Config.InspectionJob

    exports.ox_target:addSphereZone({
        coords = location,
        debug = false,
        options = {
            {
                name = "work_uniform",
                icon = "fa-solid fa-business-time",
                label = "Wear Work Uniform",
                canInteract = function(entity, distance, coords, name)
                    local playerData = Vanguard.GetPlayerData()
                    local jobName = playerData.job.name

                    if distance < 1.5 and jobName == jobAllowed then
                        return true
                    end
                    return false
                end,
                onSelect = function()
                    OpenSetWorkClothes()
                end
            }
        }
    })
end

Citizen.CreateThread(function()
    createClothesInteractionZone()
end)

function OpenInspectionMenu()
    Menu.showContext('inspection_menu')
end

Menu.registerContext({
    id = 'inspection_menu',
    title = Config.MenuLabels.InspectionCenterMenu.VehicleInspection,  
    description = 'Options for vehicle inspection',
    canClose = true,
    options = {
        {
            title = Config.MenuLabels.InspectionCenterMenu.InteractWithVehicle,  
            icon = 'fa-solid fa-car',
            description = 'Interact with the vehicle',
            onSelect = function()
                Menu.showContext('vehicle_menu')
            end,
            canClose = false
        },
        {
            title = Config.MenuLabels.InspectionCenterMenu.VehicleInspection,  
            icon = 'fa-solid fa-clipboard-check',
            description = 'Start vehicle inspection',
            onSelect = function()
                Menu.showContext('vehicle_inspection_menu')
            end,
            canClose = false
        }
    }
})

Menu.registerContext({
    id = 'vehicle_menu',
    title = Config.MenuLabels.InspectionCenterMenu.VehicleInspection,  
    description = 'Options for vehicle interaction',
    menu = 'inspection_menu',
    canClose = true,
    options = {
        {
            title = Config.MenuLabels.VehicleMenu.CheckVehicleCondition,
            icon = 'fa-solid fa-wrench',
            description = 'Check vehicle condition',
            onSelect = function()
                CheckVehicleCondition() 
            end,
            canClose = true
        },
        {
            title = Config.MenuLabels.VehicleMenu.CheckVehicleLights,
            icon = 'fa-solid fa-lightbulb',
            description = 'Check vehicle lights',
            onSelect = function()
                CheckVehicleLights() 
            end,
            canClose = true
        },
        {
            title = Config.MenuLabels.VehicleMenu.CheckEngineCondition,
            icon = 'fa-solid fa-cogs',  -- Substituído por 'fa-solid fa-cogs'
            description = 'Check engine condition',
            onSelect = function()
                CheckVehicleEngineStatus() 
            end,
            canClose = true
        },
        {
            title = Config.MenuLabels.VehicleMenu.CheckTireCondition,
            icon = 'fa-solid fa-circle-notch',  -- Substituído por 'fa-solid fa-circle-notch'
            description = 'Check tire condition',
            onSelect = function()
                CheckVehicleTireStatus() 
            end,
            canClose = true
        }
    }
})

function PlayTabletAnimation()
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CLIPBOARD_FACILITY", 0, false)
end

function StopTabletAnimation()
    local playerPed = PlayerPedId()
    DetachEntity(playerPed, true, true) 
    ClearPedTasksImmediately(playerPed)
end

function CheckVehicleCondition()
    local vehicle = GetVehicleInRange()

    Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.CheckingVehicleCondition.message, 5000, Config.Notifications.CheckingVehicleCondition.type)

    PlayTabletAnimation()
    Citizen.Wait(4000)

    if vehicle then
        local vehicleHealth = GetEntityHealth(vehicle)
        if vehicleHealth >= 999 then
            Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.VehicleInGoodCondition.message, 5000, Config.Notifications.VehicleInGoodCondition.type)
        else
            Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.VehicleDamaged.message, 5000, Config.Notifications.VehicleDamaged.type)
        end
    else
        Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.NeedToBeNearVehicle.message, 5000, Config.Notifications.NeedToBeNearVehicle.type)
    end

    StopTabletAnimation()
end

function CheckVehicleLights()
    local vehicle = GetVehicleInRange()

    Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.CheckingLights.message, 5000, Config.Notifications.CheckingLights.type)

    PlayTabletAnimation()
    Citizen.Wait(4000)

    if vehicle then
        local headlightsBroken = IsVehicleDamaged(vehicle, 0)
        local taillightsBroken = IsVehicleDamaged(vehicle, 1)

        if not headlightsBroken and not taillightsBroken then
            Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.AllLightsFunctioning.message, 5000, Config.Notifications.AllLightsFunctioning.type)
        else
            Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.LightsNotFunctioning.message, 5000, Config.Notifications.LightsNotFunctioning.type)
        end
    else
        Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.NeedToBeNearVehicle.message, 5000, Config.Notifications.NeedToBeNearVehicle.type)
    end

    StopTabletAnimation()
end

function CheckVehicleEngineStatus()
    local vehicle = GetVehicleInRange()

    Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.CheckingEngine.message, 5000, Config.Notifications.CheckingEngine.type)

    PlayTabletAnimation()
    Citizen.Wait(4000)

    if vehicle then
        local engineHealth = GetVehicleEngineHealth(vehicle)

        if engineHealth >= 900 then
            Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.EngineInGoodCondition.message, 5000, Config.Notifications.EngineInGoodCondition.type)
        else
            Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.EngineNeedsRepairs.message, 5000, Config.Notifications.EngineNeedsRepairs.type)
        end
    else
        Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.NeedToBeNearVehicle.message, 5000, Config.Notifications.NeedToBeNearVehicle.type)
    end

    StopTabletAnimation()
end

function CheckVehicleTireStatus()
    local vehicle = GetVehicleInRange()

    Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.CheckingTires.message, 5000, Config.Notifications.CheckingTires.type)

    PlayTabletAnimation()
    Citizen.Wait(4000)

    if vehicle then
        local numWheels = GetVehicleNumberOfWheels(vehicle)
        local numBurstTires = 0

        for i = 0, numWheels - 1 do
            if IsVehicleTyreBurst(vehicle, i, false) then
                numBurstTires = numBurstTires + 1
            end
        end

        if numBurstTires == 0 then
            Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.TiresInGoodCondition.message, 5000, Config.Notifications.TiresInGoodCondition.type)
        else
            local burstTireMsg = string.format(Config.Notifications.BurstTires.message, numBurstTires)
            Vanguard.notifyclient("INSPECTION CENTER", burstTireMsg, 5000, Config.Notifications.BurstTires.type)
        end
    else
        Vanguard.notifyclient("INSPECTION CENTER", Config.Notifications.NeedToBeNearVehicle.message, 5000, Config.Notifications.NeedToBeNearVehicle.type)
    end

    StopTabletAnimation()
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, Config.Keys.InspectionMenu) then 
            local playerData = Vanguard.GetPlayerData()
            local playerJob = playerData.job.name 
            if playerJob == Config.InspectionJob then
                OpenInspectionMenu()
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, Config.Keys.ContextMenu) then
            Menu.showContext('show_inspection_menu')
        end
    end
end)

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        if not vehicle or vehicle == 0 then
            EndFindVehicle(handle)
            return
        end

        repeat
            coroutine.yield(vehicle)
            local success
            success, vehicle = FindNextVehicle(handle)
        until not success

        EndFindVehicle(handle)
    end)
end

function GetVehicleInRange()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestVehicle = nil
    local closestDistance = 4.5 

    for vehicle in EnumerateVehicles() do
        local distance = #(playerCoords - GetEntityCoords(vehicle))
        if distance < closestDistance then
            closestDistance = distance
            closestVehicle = vehicle
        end
    end

    return closestVehicle
end

local function createPrinterZone()
    local location = Config.Printer
    local jobAllowed = Config.InspectionJob

    exports.ox_target:addSphereZone({
        coords = location,
        debug = false,
        options = {
            {
                name = "work_uniform",
                icon = "fa-solid fa-business-time",
                label = "Print Valid Inspection Document",
                canInteract = function(entity, distance, coords, name)
                    local playerData = Vanguard.GetPlayerData()
                    local jobName = playerData.job.name

                    if distance < 1.5 and jobName == jobAllowed then
                        return true
                    end
                    return false
                end,
                onSelect = function()
                    if lib.progressCircle({
                        duration = 5000, 
                        label = "Printing Valid Inspection Document...",
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                        },
                    }) then
                        TriggerServerEvent("Vanguard_addoninventory:addItem", "inspection_done", 1)
                    end
                end
            },
            {
                name = "remove_work_uniform",
                icon = "fa-solid fa-user",
                label = "Print Invalid Inspection Document",
                canInteract = function(entity, distance, coords, name)
                    local playerData = Vanguard.GetPlayerData()
                    local jobName = playerData.job.name

                    if distance < 1.5 and jobName == jobAllowed then
                        return true
                    end
                    return false
                end,
                onSelect = function()
                    if lib.progressCircle({
                        duration = 5000, 
                        label = "Printing Invalid Inspection Document...",
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                        },
                    }) then
                        TriggerServerEvent("Vanguard_addoninventory:addItem", "inspection_failed", 1)
                    end 
                end
            }
        }
    })
end

Citizen.CreateThread(function()
    createPrinterZone()
end)

Menu.registerContext({
    id = 'vehicle_inspection_menu',
    title = 'Vehicle Options',  -- Title for the menu
    description = 'Options for vehicle inspection',
    menu = 'inspection_menu',
    canClose = true,
    options = {
        {
            title = Config.MenuLabels.VehicleInspectionMenu.ActivateInspection,
            icon = 'fa-solid fa-check',
            description = 'Activate inspection on the vehicle',
            onSelect = function()
                ActivateInspection()
            end,
            canClose = true
        },
        {
            title = Config.MenuLabels.VehicleInspectionMenu.RemoveInspection,
            icon = 'fa-solid fa-times',
            description = 'Remove inspection from the vehicle',
            onSelect = function()
                RemoveInspection()
            end,
            canClose = true
        },
        {
            title = Config.MenuLabels.VehicleInspectionMenu.CheckInspection,
            icon = 'fa-solid fa-clipboard-check',
            description = 'Check the inspection status of the vehicle',
            onSelect = function()
                CheckInspectionStatus()
            end,
            canClose = true
        }
    }
})

Menu.registerContext({
    id = 'show_inspection_menu',
    title = 'Vehicle Inspection',  -- Title for the menu
    description = 'Show vehicle inspection to nearby player',
    canClose = true,
    options = {
        {
            title = Config.MenuLabels.ShowVehicleInspectionMenu.ShowInspection,
            icon = 'fa-solid fa-eye',
            description = 'Show inspection to nearby player',
            onSelect = function()
                ShowVehicleInspection()
            end,
            canClose = true
        }
    }
})

function ActivateInspection()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and DoesEntityExist(vehicle) then
        local playerData = Vanguard.GetPlayerData()
        local jobName = playerData.job.name
        if not playerData then
            Vanguard.notifyclient("INSPECTION", Config.Notifications.PlayerDataFailed.message, 5000, Config.Notifications.PlayerDataFailed.type)
            return
        end

        local plate = GetVehicleNumberPlateText(vehicle)
        local model = GetEntityModel(vehicle)
        local hasInspectionItem = Vanguard.HasItem(Config.InspectionItem)
        local hasFailedInspectionItem = Vanguard.HasItem(Config.FailedInspectionItem)

        if hasInspectionItem then
            TriggerServerEvent("Vanguard_addoninventory:tryActivateInspection", plate, model, "done")
        elseif hasFailedInspectionItem then
            TriggerServerEvent("Vanguard_addoninventory:tryActivateInspection", plate, model, "failed")
        else
            Vanguard.notifyclient("INSPECTION", Config.Notifications.InvalidInspectionItem.message, 5000, Config.Notifications.InvalidInspectionItem.type)
        end
    else
        Vanguard.notifyclient("INSPECTION", Config.Notifications.NeedToBeInVehicle.message, 5000, Config.Notifications.NeedToBeInVehicle.type)
    end
end

RegisterNetEvent("Vanguard_addoninventory:inspectionActivationResult")
AddEventHandler("Vanguard_addoninventory:inspectionActivationResult", function(success)
    if success then
        Vanguard.notifyclient("INSPECTION", Config.Notifications.InspectionActivated.message, 5000, Config.Notifications.InspectionActivated.type)
    else
        Vanguard.notifyclient("INSPECTION", Config.Notifications.AlreadyHasInspection.message, 5000, Config.Notifications.AlreadyHasInspection.type)
    end
end)

function RemoveInspection()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and DoesEntityExist(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)

        if plate then
            TriggerServerEvent("Vanguard_addoninventory:removeInspection", plate)
        else
            Vanguard.notifyclient("INSPECTION", Config.Notifications.UnableToRetrievePlate.message, 5000, Config.Notifications.UnableToRetrievePlate.type)
        end
    else
        Vanguard.notifyclient("INSPECTION", Config.Notifications.NeedToBeInVehicle.message, 5000, Config.Notifications.NeedToBeInVehicle.type)
    end
end

function CheckInspectionStatus()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and DoesEntityExist(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)

        if plate then
            TriggerServerEvent("Vanguard_addoninventory:checkInspection", plate)
        else
            Vanguard.notifyclient("INSPECTION", Config.Notifications.UnableToRetrievePlate.message, 5000, Config.Notifications.UnableToRetrievePlate.type)
        end
    else
        Vanguard.notifyclient("INSPECTION", Config.Notifications.NeedToBeInVehicle.message, 5000, Config.Notifications.NeedToBeInVehicle.type)
    end
end

function ShowVehicleInspection()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and DoesEntityExist(vehicle) then
        local vehicleMake = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        local vehicleModel = GetLabelText(vehicleMake)
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)

        -- Verifica o status atual da inspeção no banco de dados
        TriggerServerEvent("Vanguard_addoninventory:checkInspection", vehiclePlate)

        -- Aguarda a resposta do servidor
        local inspectionStatus = "pending"
        local failures = {}

        -- Registra o evento apenas uma vez
        if not inspectionEventHandlerRegistered then
            RegisterNetEvent("Vanguard_addoninventory:checkInspectionResult")
            AddEventHandler("Vanguard_addoninventory:checkInspectionResult", function(status, days)
                inspectionStatus = status
                if status == "valid" then
                    failures = {
                        ["brake-system"] = false,
                        ["steering-suspension"] = false,
                        ["lighting-equipment"] = false,
                        ["tires-wheels"] = false,
                        ["exhaust-system"] = false,
                        ["emissions-test"] = false
                    }
                elseif status == "invalid" then
                    failures = {
                        ["brake-system"] = true,
                        ["steering-suspension"] = true,
                        ["lighting-equipment"] = true,
                        ["tires-wheels"] = true,
                        ["exhaust-system"] = true,
                        ["emissions-test"] = true
                    }
                else
                    failures = {
                        ["brake-system"] = true,
                        ["steering-suspension"] = true,
                        ["lighting-equipment"] = true,
                        ["tires-wheels"] = true,
                        ["exhaust-system"] = true,
                        ["emissions-test"] = true
                    }
                end

                -- Encontra o jogador mais próximo
                local nearbyPlayer = GetClosestPlayer(GetEntityCoords(playerPed), 5.0)
                if nearbyPlayer then
                    -- Exibe o documento para o jogador mais próximo
                    ShowInspectionDocument(inspectionStatus, {
                        make = vehicleMake,
                        model = vehicleModel,
                        plate = vehiclePlate,
                        validDays = days
                    }, failures, GetPlayerServerId(nearbyPlayer))
                else
                    Vanguard.notifyclient("INSPECTION", Config.Notifications.NoNearbyPlayer.message, 5000, Config.Notifications.NoNearbyPlayer.type)
                end
            end)

            inspectionEventHandlerRegistered = true
        end
    else
        Vanguard.notifyclient("INSPECTION", Config.Notifications.NeedToBeInVehicle.message, 5000, Config.Notifications.NeedToBeInVehicle.type)
    end
end

function ShowInspectionDocument(inspectionStatus, vehicleData, failures, targetPlayerId)
    SendNUIMessage({
        type = "showInspection",
        status = inspectionStatus,
        vehicleMake = vehicleData.make,
        vehicleModel = vehicleData.model,
        vehiclePlate = vehicleData.plate,
        failures = failures,
        validDays = vehicleData.validDays,
        config = {
            DocumentText = Config.DocumentText,
            FailureReasons = Config.FailureReasons
        }
    })

    SetNuiFocus(true, true)

    if targetPlayerId then
        TriggerServerEvent("Vanguard_addoninventory:showInspectionToNearbyPlayer", targetPlayerId, inspectionStatus, vehicleData, failures)
    end
end

function GetClosestPlayer(coords, radius)
    local closestPlayer = nil
    local closestDistance = radius

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= PlayerPedId() then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)

            if distance < closestDistance and IsPedOnFoot(targetPed) then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end

    return closestPlayer
end

RegisterNetEvent("Vanguard_addoninventory:showInspection")
AddEventHandler("Vanguard_addoninventory:showInspection", function(inspectionStatus, vehicleData, failures, config)
    SendNUIMessage({
        type = "showInspection",
        status = inspectionStatus,
        vehicleMake = vehicleData.make,
        vehicleModel = vehicleData.model,
        vehiclePlate = vehicleData.plate,
        failures = failures,
        validDays = vehicleData.validDays,
        config = config
    })

    SetNuiFocus(true, true)
end)

RegisterNUICallback("setNuiFocus", function(data, cb)
    SetNuiFocus(data.hasFocus, data.hasCursor)
    cb('ok')
end)

RegisterNUICallback("closeDocument", function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent("Vanguard_addoninventory:checkInspectionResult")
AddEventHandler("Vanguard_addoninventory:checkInspectionResult", function(status, days)
    if status == "no inspection" then
       -- Vanguard.notifyclient("INSPECTION", Config.Notifications.NoRegisteredInspection.message, 5000, Config.Notifications.NoRegisteredInspection.type)
    elseif status == "valid" then
      --  local validInspectionMsg = string.format(Config.Notifications.InspectionValid.message, days)
       -- Vanguard.notifyclient("INSPECTION", validInspectionMsg, 5000, Config.Notifications.InspectionValid.type)
    else
      --  Vanguard.notifyclient("INSPECTION", Config.Notifications.InspectionInvalid.message, 5000, Config.Notifications.InspectionInvalid.type)
    end
end)

local function CreateBlip()
    local blip = AddBlipForCoord(Config.BlipLocation.x, Config.BlipLocation.y, Config.BlipLocation.z)

    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipScale(blip, Config.Blip.Scale)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.Name)
    EndTextCommandSetBlipName(blip)

    SetBlipDisplay(blip, Config.Blip.Display)
    SetBlipAsShortRange(blip, Config.Blip.ShortRange)

    return blip
end

CreateBlip()