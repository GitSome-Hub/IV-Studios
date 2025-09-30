QBCore = exports['qb-core']:GetCoreObject()

-- Animation dictionaries
local Dictspokojnie = "gestures@m@standing@casual"
local Animspokojnie = "gesture_easy_now"
local Dictsuper = "mp_action"
local Animsuper = "thanks_male_06"
local Dictzastanowienie = "amb@world_human_prostitute@cokehead@base"
local Animzastanowienie = "base"
local modezastanowienie = 49

-- Global variables
local numberofcops = 0
local oldped = nil
local npcs = {}

-- Function to load animation dictionaries
function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

-- Function to handle sale cancellation
function handleSaleCancel(ped, drugData, message)
    SetEntityAsMissionEntity(ped)
    SetPedAsNoLongerNeeded(ped)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    exports['ox_lib']:notify({
        position = 'top',
        title = message,
        icon = drugData.icon,
        type = 'error'
    })
end

-- Replace your current ox_target configuration with this:
for drugName, drugData in pairs(Config.Drugs) do
    exports.ox_target:addGlobalPed({
        {
            label = drugData.label,
            icon = drugData.icon,
            distance = 4,
            items = drugData.item,
            onSelect = function(data)
                TriggerEvent("vanguardwanie:sellDrug", {
                    drugName = drugName,
                    entity = data.entity
                })
            end
        }
    })
end

-- Event to handle drug sales
RegisterNetEvent('vanguardwanie:sellDrug')
AddEventHandler('vanguardwanie:sellDrug', function(args)
    -- Ensure args is not nil and contains drugName
    if not args or not args.drugName then
        print("Error: Invalid arguments passed to vanguardwanie:sellDrug")
        return
    end

    local drugName = args.drugName  -- Extract drugName from args
    local drugData = Config.Drugs[drugName]  -- Get drug data from Config.Drugs

    -- Check if drugData is valid
    if not drugData then
        print("Error: Invalid drug name - " .. drugName)
        return
    end

    local playerPed = PlayerPedId()
    local npcPed = args.entity  -- Extract NPC entity from args
    local playerCoords = GetEntityCoords(playerPed)

    if Config.NumberOfCops > 0 then
        TriggerServerEvent('checkC')
    end

    if numberofcops >= Config.NumberOfCops then
        if npcPed ~= oldped then
            oldped = npcPed
            if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
                if DoesEntityExist(npcPed) and not IsPedDeadOrDying(npcPed) and not IsPedInAnyVehicle(npcPed) then
                    TaskTurnPedToFaceCoord(npcPed, playerCoords.x, playerCoords.y, playerCoords.z)
                    loadAnimDict(Dictspokojnie)
                    TaskPlayAnim(playerPed, Dictspokojnie, Animspokojnie, 8.0, -8.0, -1, 0, 0, false, false, false)
                    Citizen.Wait(2000)

                    FreezeEntityPosition(npcPed, true)
                    loadAnimDict(Dictzastanowienie)
                    TaskPlayAnim(npcPed, Dictzastanowienie, Animzastanowienie, 8.0, -8.0, -1, modezastanowienie, 0, false, false, false)

                    if lib.progressCircle({
                        duration = Config.SellingTime * 1000,
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = { car = true },
                        anim = { dict = 'amb@world_human_prostitute@cokehead@base', clip = 'base' },
                        prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
                    }) then
                        local playerCoords = GetEntityCoords(playerPed)
                        local npcCoords = GetEntityCoords(npcPed)
                        local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, npcCoords.x, npcCoords.y, npcCoords.z)
                        if distance < 4.0 then
                            local chance = math.random(1, 100)
                            if chance <= drugData.chance then
                                local basePrice = math.random(drugData.priceMin, drugData.priceMax)
                                local finalPrice = basePrice * (1 + (Config.IncreasePercentage / 100))

                                loadAnimDict(Dictsuper)
                                TaskPlayAnim(playerPed, Dictsuper, Animsuper, 8.0, -8.0, -1, 0, 0, false, false, false)
                                loadAnimDict('mp_common')
                                TaskPlayAnim(npcPed, "mp_common", "givetake1_a", 8.0, 8.0, 2000, 50, 0, false, false, false)
                                TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, 8.0, 2000, 50, 0, false, false, false)

                                Citizen.Wait(1000)
                                SetEntityAsMissionEntity(oldped)
                                SetPedAsNoLongerNeeded(oldped)
                                FreezeEntityPosition(oldped, false)
                                ClearPedTasks(oldped)
                                TriggerServerEvent("vanguard_drugselling:sellDrug", drugName, finalPrice)
                                TriggerServerEvent('drug:notifyPolice', playerCoords)
                            else
                                handleSaleCancel(oldped, drugData, Config.Messages.cancel)
                            end
                        else
                            handleSaleCancel(oldped, drugData, Config.Messages.toofar)
                        end
                    else
                        handleSaleCancel(oldped, drugData, Config.Messages.cancel)
                    end
                end
            else
                handleSaleCancel(oldped, drugData, Config.Messages.sameguy)
            end
        else
            handleSaleCancel(oldped, drugData, Config.Messages.sameguy)
        end
    else
        handleSaleCancel(oldped, drugData, Config.Messages.nopolice)
    end
end)

-- Event to update the number of cops
RegisterNetEvent('checkC')
AddEventHandler('checkC', function(cops)
    numberofcops = cops
end)

-- Event to notify police
RegisterNetEvent('drug:notifyPolice')
AddEventHandler('drug:notifyPolice', function(location)
    local playerJob = QBCore.Functions.GetPlayerData().job.name 
    local isJobAuthorized = false

    for _, job in ipairs(Config.AlertJobs) do
        if playerJob == job then
            isJobAuthorized = true
            break
        end
    end

    if isJobAuthorized then
        local notifyChance = math.random(1, 100)
        if notifyChance <= Config.PoliceAlertChance then
            if Config.NotificationSystem == 'okokNotify' then
                exports['okokNotify']:Alert("Police Alert", Config.NotificationRobberyAlert, 7000, 'info')
            elseif Config.NotificationSystem == 'QBCore' then
                QBCore.Functions.Notify(Config.NotificationRobberyAlert, 'info', 5000)
            elseif Config.NotificationSystem == 'wasabiNotify' then
                exports.wasabi_notify:notify("Police Alert", Config.NotificationRobberyAlert, 7000, 'info')
            else
                print("We do not support this notify: " .. Config.NotificationSystem)
            end

            local blip = AddBlipForCoord(location.x, location.y, location.z)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipColour(blip, Config.BlipColor)
            SetBlipScale(blip, Config.BlipScale)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Config.BlipName)
            EndTextCommandSetBlipName(blip)

            Citizen.SetTimeout(Config.BlipDuration * 1000, function()
                RemoveBlip(blip)
            end)
        end
    end
end)

-- NPC CREATOR --

-- Function to load a model
function LoadModel(model)
    if not IsModelInCdimage(model) or not IsModelValid(model) then
        print("Modelo inválido: " .. model)
        return false
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    return true
end

-- Function to get a random ground position within a zone
function GetRandomGroundPosition(zone)
    local maxAttempts = 10
    for _ = 1, maxAttempts do
        local angle = math.random() * 2 * math.pi
        local distance = math.random(zone.spawnRadius / 2, zone.spawnRadius)
        local spawnX = zone.centerCoord.x + distance * math.cos(angle)
        local spawnY = zone.centerCoord.y + distance * math.sin(angle)
        
        local foundGround, spawnZ = GetGroundZFor_3dCoord(spawnX, spawnY, zone.centerCoord.z + 100.0, false)
        
        if foundGround then
            return vector3(spawnX, spawnY, spawnZ)
        end
    end

    return vector3(zone.centerCoord.x, zone.centerCoord.y, zone.centerCoord.z)
end

-- Function to check if a player is nearby a zone
function IsPlayerNearby(zone)
    local players = GetActivePlayers()
    for _, playerId in ipairs(players) do
        local playerPed = GetPlayerPed(playerId)
        local playerPos = GetEntityCoords(playerPed)
        local distance = #(playerPos - zone.centerCoord)
        
        if distance <= 100 then
            return true
        end
    end
    return false
end

-- Function to spawn an NPC in a zone
function SpawnNPCInZone(zone)
    local zoneNPCCount = 0

    for _, npc in ipairs(npcs) do
        if npc.zone == zone then
            zoneNPCCount = zoneNPCCount + 1
        end
    end

    if zoneNPCCount >= zone.maxNPCs then return end

    local spawnPos = GetRandomGroundPosition(zone)
    if spawnPos then
        local randomModel = zone.npcModels[math.random(#zone.npcModels)]

        if LoadModel(randomModel) then
            local npc = CreatePed(4, GetHashKey(randomModel), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
            SetEntityAsMissionEntity(npc, true, true)
            SetPedCanRagdoll(npc, false)
            SetBlockingOfNonTemporaryEvents(npc, true)

            if math.random() <= 0.25 then
                TaskStartScenarioInPlace(npc, "WORLD_HUMAN_SMOKING", 0, true)
            else
                StartNPCBehavior(npc, zone)
            end

            table.insert(npcs, { ped = npc, zone = zone, model = randomModel })
        end
    end
end

-- Function to start NPC behavior
function StartNPCBehavior(npc, zone)
    Citizen.CreateThread(function()
        while DoesEntityExist(npc) do
            Wait(math.random(Config.Timing.actionWaitMin, Config.Timing.actionWaitMax))
            local movePos = GetRandomGroundPosition(zone)
            if movePos then
                TaskGoToCoordAnyMeans(npc, movePos.x, movePos.y, movePos.z, 1.0, 0, 0, 786603, 0xbf800000)

                Citizen.CreateThread(function()
                    while DoesEntityExist(npc) do
                        Wait(Config.Timing.npcMovementCheckInterval)
                        local npcPos = GetEntityCoords(npc)
                        local distance = #(npcPos - zone.centerCoord)

                        if distance >= zone.spawnRadius then
                            DeleteEntity(npc)
                            SpawnNPCInZone(zone)
                            break
                        end
                    end
                end)
            end
        end
    end)
end

-- Function to setup zone blips
function SetupZoneBlips()
    for zoneName, zone in pairs(Config.Zones) do
        local blip = AddBlipForCoord(zone.centerCoord.x, zone.centerCoord.y, zone.centerCoord.z)
        SetBlipSprite(blip, zone.blip.sprite)
        SetBlipColour(blip, zone.blip.color)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true) 
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.blip.name)
        EndTextCommandSetBlipName(blip)
    end
end

-- Main thread for NPC spawning
Citizen.CreateThread(function()
    SetupZoneBlips()

    while true do
        Wait(Config.Timing.spawnCheckInterval)

        for zoneName, zone in pairs(Config.Zones) do
            if IsPlayerNearby(zone) then
                for _ = 1, (zone.maxNPCs - #npcs) do
                    SpawnNPCInZone(zone)
                    Wait(500)
                end
            end
        end
    end
end)

-- Function to check and remove non-existent NPCs
function CheckNPCPositions()
    for i = #npcs, 1, -1 do
        if not DoesEntityExist(npcs[i].ped) then
            table.remove(npcs, i)
        end
    end
end