---- Função de capacete, bateria e Luz.

-- Função para gerar coordenadas aleatórias dentro de um círculo
local function GetRandomPointInCircle(center, radius)
    local angle = math.random() * 2 * math.pi
    local distance = math.sqrt(math.random()) * radius
    local x = center.x + distance * math.cos(angle)
    local y = center.y + distance * math.sin(angle)
    return vector3(x, y, center.z)
end

-- Função para calcular a posição atrás do jogador
local function GetPositionBehindPlayer(playerCoords, heading, distance)
    local angle = heading * (math.pi / 180.0)
    local x = playerCoords.x - distance * math.sin(angle)
    local y = playerCoords.y + distance * math.cos(angle)
    local z = playerCoords.z -- Mantém a mesma altura do jogador
    return vector3(x, y, z)
end

local luzAtivada = false
local raioLuzInicial = 12.0 -- Raio inicial da luz
local intensidadeInicial = 3.5 -- Intensidade inicial da luz
local raioLuz = raioLuzInicial
local intensidadeLuz = intensidadeInicial
local corLuz = {255, 210, 170} -- Tom mais quente para simular uma lanterna
local bateria = 100
local bateriaEmUso = false
local teclaAtivacao = 74 -- Tecla "H"
local minerHelmetEquipped = false
local helmetProp = nil

-- Função para verificar se o jogador possui o item miner_helmet
function possuiMinerHelmet()
    local playerData = Vanguard.GetPlayerData()
    for _, item in pairs(playerData.inventory) do
        if item.name == Config.items.helmet and item.count > 0 then
            return true
        end
    end
    return false
end

-- Função para verificar se o jogador possui o item miner_battery
function possuiMinerBattery()
    local playerData = Vanguard.GetPlayerData()
    for _, item in pairs(playerData.inventory) do
        if item.name == Config.items.battery and item.count > 0 then
            return true
        end
    end
    return false
end

-- Função para remover uma miner_battery do inventário e recarregar a bateria
function consumirMinerBattery()
    TriggerServerEvent('vanguard_miningsystem:removerBattery') -- Evento para remover do inventário
    bateria = 100
    SendNUIMessage({ action = "updateBattery", level = bateria })
    Vanguard.notifyclient(Config.notifications.batteryRecharged.title, Config.notifications.batteryRecharged.message, 5000, Config.notifications.batteryRecharged.type)
end

-- Função para equipar o capacete de mineração
function equiparMinerHelmet()
    if not minerHelmetEquipped then
        local playerPed = PlayerPedId()
        local model = GetHashKey("prop_tool_hardhat") 

        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end

        helmetProp = CreateObject(model, 0.0, 0.5, 0.0, true, true, true)
        AttachEntityToEntity(helmetProp, playerPed, GetPedBoneIndex(playerPed, 12844), 0.08, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
        minerHelmetEquipped = true
    end
end

-- Função para remover o capacete de mineração
function removerMinerHelmet()
    if minerHelmetEquipped and DoesEntityExist(helmetProp) then
        DeleteEntity(helmetProp)
        helmetProp = nil
        minerHelmetEquipped = false
    end
end

-- Função para alternar a luz do capacete e mostrar/ocultar a UI de bateria
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Verifica se o jogador pressionou a tecla de ativação e possui o item miner_helmet
        if IsControlJustPressed(1, teclaAtivacao) then
            -- Só ativa/desativa a luz se o capacete estiver equipado e presente
            if possuiMinerHelmet() then
                if not luzAtivada then
                    if possuiMinerBattery() then
                        equiparMinerHelmet() -- Equipa o capacete de mineração quando a luz é ativada
                        consumirMinerBattery() -- Remove uma bateria ao ativar a luz
                        luzAtivada = true
                        bateriaEmUso = true
                        SendNUIMessage({ action = "showBattery" }) -- Mostra a barra de bateria
                        startBatteryDrain() -- Inicia o consumo de bateria
                        Vanguard.notifyclient(Config.notifications.lightOn.title, Config.notifications.lightOn.message, 5000, Config.notifications.lightOn.type)
                    else
                        Vanguard.notifyclient(Config.notifications.noBattery.title, Config.notifications.noBattery.message, 5000, Config.notifications.noBattery.type)
                    end
                else
                    luzAtivada = false
                    bateriaEmUso = false
                    removerMinerHelmet() -- Remove o capacete de mineração quando a luz é desativada
                    SendNUIMessage({ action = "hideBattery" }) -- Oculta a barra de bateria
                    stopBatteryDrain() -- Para o consumo de bateria
                    Vanguard.notifyclient(Config.notifications.lightOff.title, Config.notifications.lightOff.message, 5000, Config.notifications.lightOff.type)
                end
            end
        end
    end
end)

-- Função para verificar se o jogador ainda possui o item miner_helmet periodicamente
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Verifica a cada segundo

        if minerHelmetEquipped and not possuiMinerHelmet() then
            removerMinerHelmet() -- Remove o capacete se o item for perdido
            luzAtivada = false
            bateriaEmUso = false
            SendNUIMessage({ action = "hideBattery" }) -- Oculta a barra de bateria
        end
    end
end)

-- Função para gerar a luz no capacete
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if luzAtivada then
            local playerPed = PlayerPedId()
            local headCoords = GetPedBoneCoords(playerPed, 31086, 0.0, 0.0, 0.0)
            local forwardVector = GetEntityForwardVector(playerPed)
            
            local endCoords = vector3(
                headCoords.x + forwardVector.x * raioLuz,
                headCoords.y + forwardVector.y * raioLuz,
                headCoords.z + forwardVector.z * raioLuz
            )
            
            DrawSpotLight(
                headCoords.x, headCoords.y, headCoords.z + 0.1, -- Eleva ligeiramente para simular a luz no capacete
                forwardVector.x, forwardVector.y, forwardVector.z,
                corLuz[1], corLuz[2], corLuz[3],
                raioLuz,
                intensidadeLuz,
                0.4, -- Feixe um pouco mais estreito para dar foco
                30.0, -- Distância para dar uma boa iluminação no túnel
                1.0 -- Suavidade para transição suave da luz
            )
        end
    end
end)

function startBatteryDrain()
    Citizen.CreateThread(function()
        while bateriaEmUso and bateria > 0 do
            Citizen.Wait(5000)
            bateria = bateria - 1

            -- Envia o nível de bateria para a interface NUI
            SendNUIMessage({
                action = "updateBattery",
                level = bateria
            })

            if bateria <= 0 then
                bateria = 0
                luzAtivada = false
                bateriaEmUso = false
                SendNUIMessage({ action = "batteryEmpty" })
                SendNUIMessage({ action = "hideBattery" })
                removerMinerHelmet()

                -- Remover o recarregamento automático
                Vanguard.notifyclient(Config.notifications.batteryEmpty.title, Config.notifications.batteryEmpty.message, 5000, Config.notifications.batteryEmpty.type)
            end
        end
    end)
end

-- Função para parar o consumo da bateria
function stopBatteryDrain()
    bateriaEmUso = false
    SendNUIMessage({ action = "hideBattery" })
end

-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ################################### MINING PICKAXE  ########################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################

local mining = false -- Flag to manage mining state
local markerVisible = true -- Flag to manage marker visibility
local rocks = {} -- Array to store rock objects

-- Main thread to draw markers and check player input
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local waitTime = 100 -- Default wait time to reduce CPU usage

        for _, location in ipairs(Config.miningLocations) do
            local dist = #(playerCoords - location.coords)

            -- Draw marker if player is near a mining location and marker is visible
            if dist < 10.0 and markerVisible then
                waitTime = 0
                DrawMarker(2, location.coords.x, location.coords.y, location.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 114, 204, 114, 255, false, true, 2, false, nil, false)
                DrawMarker(6, location.coords.x, location.coords.y, location.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.2, 114, 204, 114, 255, false, true, 2, true, nil, true)

                -- Check if player presses E and is close enough
                if IsControlJustReleased(0, 38) and dist <= 2.0 then
                    TriggerServerEvent('vanguard_miningsystem:checkPickaxe')
                end
            end
        end

        -- Draw lights on rocks if player is near and not mining
        if not mining then
            for _, rock in ipairs(rocks) do
                local rockCoords = GetEntityCoords(rock)
                local dist = #(playerCoords - rockCoords)

                if dist < 10.0 then
                    DrawLightWithRange(rockCoords.x, rockCoords.y, rockCoords.z + 0.5, 255, 255, 255, 3.0, 0.5) -- Reduz a intensidade do glow
                end
            end
        end

        Citizen.Wait(waitTime)
    end
end)

-- Evento para iniciar a mineração
RegisterNetEvent('vanguard_miningsystem:startMining')
AddEventHandler('vanguard_miningsystem:startMining', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, location in ipairs(Config.miningLocations) do
        local dist = #(playerCoords - location.coords)

        if dist <= 2.0 then
            mining = true
            markerVisible = false -- Hide the marker while mining

            -- Set player heading to the specified direction
            SetEntityHeading(playerPed, location.heading)

            -- Load and attach the pickaxe model
            lib.requestModel(Config.pickaxeModel, 100)
            local axe = CreateObject(Config.pickaxeModel, GetEntityCoords(playerPed), true, false, false)
            AttachEntityToEntity(axe, playerPed, GetPedBoneIndex(playerPed, 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, true, true, true, 0, true)

            -- Load the animation dictionary and start looping the animation
            lib.requestAnimDict('melee@hatchet@streamed_core', 100)
            local startTime = GetGameTimer()

            -- Load the rock model
            lib.requestModel(Config.rockModel, 100)

            -- Spawn rocks
            local rockSpawnStartTime = GetGameTimer()
            local rocksSpawned = 0

            while mining and (GetGameTimer() - startTime < Config.miningDuration) do
                -- Replay the animation every time it completes
                if not IsEntityPlayingAnim(playerPed, 'melee@hatchet@streamed_core', 'plyr_rear_takedown_b', 3) then
                    TaskPlayAnim(playerPed, 'melee@hatchet@streamed_core', 'plyr_rear_takedown_b', 8.0, -8.0, -1, 1, 0, false, false, false)
                end

                -- Spawn rocks every rockSpawnInterval
                if rocksSpawned < Config.rocksToSpawn and GetGameTimer() - rockSpawnStartTime >= Config.rockSpawnInterval * rocksSpawned then
                    local rockCoords = GetPositionBehindPlayer(playerCoords, GetEntityHeading(playerPed), Config.rockSpawnRadius)
                    local rock = CreateObject(Config.rockModel, rockCoords.x, rockCoords.y, rockCoords.z, true, true, false)
                    PlaceObjectOnGroundProperly(rock) -- Coloca a pedra no chão
                    table.insert(rocks, rock)

                    -- Register the rock on the server
                    TriggerServerEvent('vanguard_miningsystem:registerRock', rock)

                    -- Add ox_target option to the rock
                    exports.ox_target:addLocalEntity(rock, {
                        {
                            name = 'collect_rock',
                            event = 'vanguard_miningsystem:collectRock',
                            icon = 'fas fa-gem',
                            label = 'Collect Stone',
                            canInteract = function(entity, distance, coords, name)
                                return true
                            end
                        }
                    })

                    rocksSpawned = rocksSpawned + 1
                end

                Citizen.Wait(100) -- Check every 100ms to ensure the animation keeps looping
            end

            -- Cleanup after mining duration
            ClearPedTasks(playerPed)

            -- Ensure the axe object is valid before attempting to delete it
            if DoesEntityExist(axe) then
                DeleteObject(axe)
            end

            SetModelAsNoLongerNeeded(Config.pickaxeModel)
            SetModelAsNoLongerNeeded(Config.rockModel)
            RemoveAnimDict('melee@hatchet@streamed_core')

            mining = false
            markerVisible = true -- Show the marker again after mining

            -- Verifica se o item deve ser removido com 50% de chance
            if math.random() < Config.pickaxeBreakChance then
                TriggerServerEvent('vanguard_miningsystem:removePickaxe')
                Vanguard.notifyclient(Config.notifications.pickaxeBroke.title, Config.notifications.pickaxeBroke.message, 5000, Config.notifications.pickaxeBroke.type)
            end
        end
    end
end)

-- Evento para recolher a pedra
RegisterNetEvent('vanguard_miningsystem:collectRock')
AddEventHandler('vanguard_miningsystem:collectRock', function(data)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local rockCoords = GetEntityCoords(data.entity)
    local dist = #(playerCoords - rockCoords)

    if dist <= 2.0 then
        TriggerServerEvent('vanguard_miningsystem:givePickaxeStone', data.entity)
        DeleteObject(data.entity)
        exports.ox_target:removeLocalEntity(data.entity, 'collect_rock')
    end
end)

-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ################################### MINING DRILL HAND  #####################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################

local drillingActive = false -- Flag para gerenciar o estado da perfuração
local markerVisible = true -- Flag to manage marker visibility
local drillRocks = {} -- Array to store drill rock objects

-- Função para deletar os props ligados ao jogador
function DeleteAttachedProps(playerPed)
    local handle, object = FindFirstObject()
    local success
    repeat
        if IsEntityAttachedToEntity(object, playerPed) then
            -- Verifica se o objeto é o prop da furadeira antes de deletá-lo
            if GetEntityModel(object) == Config.drillModel then
                DeleteObject(object)
            end
        end
        success, object = FindNextObject(handle)
    until not success
    EndFindObject(handle)
end

-- Main thread para desenhar marcadores e verificar a entrada do jogador
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local waitTime = 1000 -- Tempo de espera padrão para reduzir o uso da CPU

        for _, location in ipairs(Config.drillLocations) do
            local dist = #(playerCoords - location.coords)

            -- Desenha o marcador se o jogador estiver perto de um local de perfuração e o marcador estiver visível
            if dist < 10.0 and markerVisible then
                waitTime = 0
                DrawMarker(2, location.coords.x, location.coords.y, location.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 240, 200, 80, 255, false, true, 2, false, nil, false)
                DrawMarker(6, location.coords.x, location.coords.y, location.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.2, 240, 200, 80, 255, false, true, 2, true, nil, true)

                -- Verifica se o jogador pressionou E e está próximo o suficiente
                if IsControlJustReleased(0, 38) and dist <= 2.0 then
                    if not drillingActive then
                        TriggerServerEvent('vanguard_miningsystem:checkDrill')
                    else
                        Vanguard.notifyclient(Config.notifications.noDrill.title, Config.notifications.noDrill.message, 5000, Config.notifications.noDrill.type)
                    end
                end
            end
        end

        -- Draw lights on drill rocks if player is near and not drilling
        if not drillingActive then
            for _, rock in ipairs(drillRocks) do
                local rockCoords = GetEntityCoords(rock)
                local dist = #(playerCoords - rockCoords)

                if dist < 10.0 then
                    DrawLightWithRange(rockCoords.x, rockCoords.y, rockCoords.z + 0.5, 255, 255, 255, 3.0, 0.5) -- Reduz a intensidade do glow
                end
            end
        end

        Citizen.Wait(waitTime)
    end
end)

-- Evento para iniciar a perfuração
RegisterNetEvent('vanguard_miningsystem:startDrilling')
AddEventHandler('vanguard_miningsystem:startDrilling', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, location in ipairs(Config.drillLocations) do
        local dist = #(playerCoords - location.coords)

        if dist <= 2.0 then
            drillingActive = true
            markerVisible = false -- Hide the marker while drilling

            -- Carrega o dicionário de animações e começa a animação de perfuração
            local animDict = "anim@heists@fleeca_bank@drilling"
            local animLib = "drill_straight_idle"

            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(50)
            end

            TaskPlayAnim(playerPed, animDict, animLib, 1.0, -1.0, -1, 2, 0, 0, 0, 0)

            -- Carrega e anexa o modelo da furadeira
            local drillProp = GetHashKey('hei_prop_heist_drill')
            local boneIndex = GetPedBoneIndex(playerPed, 28422)

            RequestModel(drillProp)
            while not HasModelLoaded(drillProp) do
                Citizen.Wait(100)
            end

            local attachedDrill = CreateObject(drillProp, 1.0, 1.0, 1.0, 1, 1, 0)
            AttachEntityToEntity(attachedDrill, playerPed, boneIndex, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)

            SetEntityAsMissionEntity(attachedDrill, true, true)

            -- Carrega os sons da furadeira
            RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
            RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
            RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
            local drillSound = GetSoundId()

            Citizen.Wait(750)

            PlaySoundFromEntity(drillSound, "Drill", attachedDrill, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)

            Citizen.Wait(200)

            -- Carrega as partículas da furadeira
            local particleDictionary = "scr_fbi5a"
            local particleName = "scr_bio_grille_cutting"

            RequestNamedPtfxAsset(particleDictionary)
            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                Citizen.Wait(0)
            end

            UseParticleFxAssetNextCall(particleDictionary)
            local particleEffect = StartParticleFxLoopedOnEntityBone(particleName, attachedDrill, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(attachedDrill, "drill"), 1.0, false, false, false)

            -- Ajusta a posição da partícula para ficar um pouco mais à frente da prop
            local offsetX, offsetY, offsetZ = 0.0, -0.4, 0.0 -- Ajuste esses valores conforme necessário
            SetParticleFxLoopedOffsets(particleEffect, offsetX, offsetY, offsetZ, 0.0, 0.0, 0.0)

            -- Spawn rocks every rockSpawnInterval
            local rockSpawnStartTime = GetGameTimer()
            local rocksSpawned = 0
            local startTime = GetGameTimer() -- Inicializa startTime aqui

            while drillingActive and (GetGameTimer() - startTime < Config.drillingDuration) do
                -- Reproduz a animação sempre que ela completar
                if not IsEntityPlayingAnim(playerPed, animDict, animLib, 3) then
                    TaskPlayAnim(playerPed, animDict, animLib, 8.0, -8.0, -1, 1, 0, false, false, false)
                end

                -- Spawn rocks every rockSpawnInterval
                if rocksSpawned < Config.drillRocksToSpawn and GetGameTimer() - rockSpawnStartTime >= Config.drillRockSpawnInterval * rocksSpawned then
                    local rockCoords = GetPositionBehindPlayer(playerCoords, GetEntityHeading(playerPed), Config.drillRockSpawnRadius)
                    local rock = CreateObject(Config.drillRockModel, rockCoords.x, rockCoords.y, rockCoords.z, true, true, false)
                    PlaceObjectOnGroundProperly(rock) -- Coloca a pedra no chão
                    table.insert(drillRocks, rock)

                    -- Register the rock on the server
                    TriggerServerEvent('vanguard_miningsystem:registerDrillRock', rock)

                    -- Add ox_target option to the rock
                    exports.ox_target:addLocalEntity(rock, {
                        {
                            name = 'collect_drill_rock',
                            event = 'vanguard_miningsystem:collectDrillRock',
                            icon = 'fas fa-gem',
                            label = 'Collect Stone',
                            canInteract = function(entity, distance, coords, name)
                                return true
                            end
                        }
                    })

                    rocksSpawned = rocksSpawned + 1
                end

                Citizen.Wait(500) -- Verifica a cada 500ms para garantir que a animação continue
            end

            -- Para o som da furadeira após a perfuração terminar
            StopSound(drillSound)
            ReleaseSoundId(drillSound)

            -- Para as partículas da furadeira após a perfuração terminar
            StopParticleFxLooped(particleEffect, false)

            -- Limpeza após a duração da perfuração
            ClearPedTasks(playerPed)

            -- Verifica se o objeto da furadeira foi criado antes de tentar deletá-lo
            if DoesEntityExist(attachedDrill) then
                DeleteObject(attachedDrill) -- Remove o prop da furadeira
            end

            DeleteAttachedProps(playerPed) -- Remove qualquer prop anexado à mão do jogador
            SetModelAsNoLongerNeeded(Config.drillModel)
            RemoveAnimDict(animDict)

            drillingActive = false
            markerVisible = true -- Show the marker again after drilling

            -- Verifica se o item deve ser removido com 50% de chance
            if math.random() < Config.drillBreakChance then
                TriggerServerEvent('vanguard_miningsystem:removeDrill')
                Vanguard.notifyclient(Config.notifications.drillBroke.title, Config.notifications.drillBroke.message, 5000, Config.notifications.drillBroke.type)
            end
        end
    end
end)

-- Evento para recolher a pedra do drill
RegisterNetEvent('vanguard_miningsystem:collectDrillRock')
AddEventHandler('vanguard_miningsystem:collectDrillRock', function(data)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local rockCoords = GetEntityCoords(data.entity)
    local dist = #(playerCoords - rockCoords)

    if dist <= 2.0 then
        TriggerServerEvent('vanguard_miningsystem:giveDrillStone', data.entity)
        DeleteObject(data.entity)
        exports.ox_target:removeLocalEntity(data.entity, 'collect_drill_rock')
    end
end)

-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ################################### MINING DRILL   #########################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################


local drillHand2Locations = Config.drillHandRockLocations

local drillingHand2 = false -- Flag para gerenciar o estado da perfuração
local markerVisible = true -- Flag to manage marker visibility

-- Main thread to draw markers and check player input
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local waitTime = 100 -- Default wait time to reduce CPU usage

        for _, location in ipairs(drillHand2Locations) do
            local dist = #(playerCoords - location.coords)

            -- Draw marker if player is near a drilling location and marker is visible
            if dist < 10.0 and markerVisible then
                waitTime = 0
                DrawMarker(2, location.coords.x, location.coords.y, location.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 224, 50, 50, 255, false, true, 2, false, nil, false)
                DrawMarker(6, location.coords.x, location.coords.y, location.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.2, 224, 50, 50, 255, false, true, 2, true, nil, true)

                -- Check if player presses E and is close enough
                if IsControlJustReleased(0, 38) and dist <= 2.0 then
                    TriggerServerEvent('vanguard_miningsystem:checkDrillHand')
                end
            end
        end

        Citizen.Wait(waitTime)
    end
end)

RegisterNetEvent('vanguard_miningsystem:startDrillingHand')
AddEventHandler('vanguard_miningsystem:startDrillingHand', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, location in ipairs(drillHand2Locations) do
        local dist = #(playerCoords - location.coords)

        if dist <= 2.0 then
            drillingHand2 = true
            markerVisible = false -- Hide the marker while drilling

            -- Iniciar a animação de perfuração usando TaskStartScenarioInPlace
            TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CONST_DRILL", 0, false)
            local startTime = GetGameTimer()

            -- Spawn rocks every rockSpawnInterval
            local rockSpawnStartTime = GetGameTimer()
            local rocksSpawned = 0

            while drillingHand2 and (GetGameTimer() - startTime < Config.drillHandDuration) do
                Citizen.Wait(500) -- Verifica a cada 500ms para garantir que a animação continue

                -- Spawn rocks every rockSpawnInterval
                if rocksSpawned < Config.drillHandRocksToSpawn and GetGameTimer() - rockSpawnStartTime >= Config.drillHandRockSpawnInterval * rocksSpawned then
                    local rockCoords = GetPositionBehindPlayer(playerCoords, GetEntityHeading(playerPed), Config.drillHandRockSpawnRadius)
                    local rock = CreateObject(Config.drillHandRockModel, rockCoords.x, rockCoords.y, rockCoords.z, true, true, false)
                    PlaceObjectOnGroundProperly(rock) -- Coloca a pedra no chão

                    -- Register the rock on the server
                    TriggerServerEvent('vanguard_miningsystem:registerDrillHandRock', rock)

                    -- Add ox_target option to the rock
                    exports.ox_target:addLocalEntity(rock, {
                        {
                            name = 'collect_drill_rock',
                            event = 'vanguard_miningsystem:collectDrillHandRock',
                            icon = 'fas fa-gem',
                            label = 'Collect Stone',
                            canInteract = function(entity, distance, coords, name)
                                return true
                            end
                        }
                    })

                    rocksSpawned = rocksSpawned + 1
                end

                Citizen.Wait(500) -- Verifica a cada 500ms para garantir que a animação continue
            end

            -- Limpeza após a duração da perfuração
            ClearPedTasks(playerPed)
            drillingHand2 = false
            markerVisible = true -- Show the marker again after drilling

            -- Verifica se o item deve ser removido com a chance configurada
            if math.random() < Config.drillHandBreakChance then
                TriggerServerEvent('vanguard_miningsystem:removeDrillHand')
                Vanguard.notifyclient(Config.notifications.drillHandBroke.title, Config.notifications.drillHandBroke.message, 5000, Config.notifications.drillHandBroke.type)
            end
        end
    end
end)

-- Evento para recolher a pedra do drill
RegisterNetEvent('vanguard_miningsystem:collectDrillHandRock')
AddEventHandler('vanguard_miningsystem:collectDrillHandRock', function(data)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local rockCoords = GetEntityCoords(data.entity)
    local dist = #(playerCoords - rockCoords)

    if dist <= 2.0 then
        TriggerServerEvent('vanguard_miningsystem:giveDrillHandStone', data.entity)
        DeleteObject(data.entity)
        exports.ox_target:removeLocalEntity(data.entity, 'collect_drill_rock')
    end
end)

-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ################################### MINING LIGHT GENERATOR #################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################

local generatorLocations = Config.generatorLocations

local propModel2 = GetHashKey(Config.propModel2) -- Model of the prop to be created
local warningLightModel = GetHashKey(Config.warningLightModel) -- Model of the warning light prop
local mechanicAnimationDuration = Config.mechanicAnimationDuration -- Duration of the animation in milliseconds (5 seconds)
local lightPositions = Config.lightPositions -- Coordinates, heading, and rotation where the warning lights will be created

-- Load the models explicitly before creating the props
RequestModel(propModel2)
RequestModel(warningLightModel)
while not HasModelLoaded(propModel2) or not HasModelLoaded(warningLightModel) do
    Citizen.Wait(10)
end

local prop = nil -- Global variable to store the reference of the prop
local warningLights = {} -- Table to store the references of the warning lights
local spotLights = {} -- Table to store the references of the spot lights
local lastActivationTime = 0 -- Time of the last generator activation
local isFirstActivation = true -- Flag to check if it's the first activation

-- Function to remove existing props
local function removeExistingProps()
    for _, light in ipairs(warningLights) do
        if DoesEntityExist(light) then
            DeleteEntity(light)
        end
    end
    warningLights = {}
end

-- Function to remove all warning lights in the world
local function removeAllWarningLights()
    local objects = Vanguard.GetObjects()
    for _, object in ipairs(objects) do
        if GetEntityModel(object) == warningLightModel then
            SetEntityAsMissionEntity(object, true, true)
            DeleteEntity(object)
        end
    end
end

-- Function to remove existing spot lights
local function removeExistingSpotLights()
    spotLights = {}
end

Citizen.CreateThread(function()
    -- Remove all existing warning lights in the world when the script starts
    removeAllWarningLights()

    -- Remove existing warning lights when the script starts
    removeExistingProps()

    -- Remove existing spot lights when the script starts
    removeExistingSpotLights()

    -- Reset the last activation time when the script starts
    lastActivationTime = 0

    for _, location in ipairs(generatorLocations) do
        local objects = Vanguard.GetObjects()
        for _, object in ipairs(objects) do
            local objectPos = GetEntityCoords(object)
            local distanceObj = #(objectPos - location.coords)

            -- Check if the object is the desired prop and is within the distance
            if distanceObj <= 2.0 and GetEntityModel(object) == propModel2 then
                SetEntityAsMissionEntity(object, true, true)
                DeleteEntity(object)

                if not DoesEntityExist(object) then
                end
            end
        end

        -- Create the new prop at the specified coordinates with the desired heading
        prop = CreateObject(propModel2, location.coords.x, location.coords.y, location.coords.z, true, true, true)
        
        -- Set the orientation of the prop
        SetEntityHeading(prop, location.heading)
        
        -- Freeze the position of the prop so it doesn't move
        FreezeEntityPosition(prop, true)

        -- Add the ox_target for the prop
        exports.ox_target:addLocalEntity(prop, {
            {
                name = 'activate_generator',
                event = 'vanguard_miningsystem:activateGenerator',
                icon = 'fas fa-power-off',
                label = 'Activate Light Generator',
                canInteract = function(entity, distance, coords, name)
                    return true
                end
            }
        })
    end
end)

-- Event to activate the generator
RegisterNetEvent('vanguard_miningsystem:activateGenerator')
AddEventHandler('vanguard_miningsystem:activateGenerator', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local propCoords = GetEntityCoords(prop)
    local dist = #(playerCoords - propCoords)
    local currentTime = GetGameTimer()

    -- Check if it's the first activation or if 10 minutes have passed since the last activation
    if not isFirstActivation and currentTime - lastActivationTime < 600000 then -- 600000 milliseconds = 10 minutes
        Vanguard.notifyclient(Config.notifications.generatorCooldown.title, Config.notifications.generatorCooldown.message, 5000, Config.notifications.generatorCooldown.type)
        return
    end

    if dist <= 2.0 then
        -- Remove existing warning light props
        removeExistingProps()

        -- Remove existing spot lights
        removeExistingSpotLights()

        -- Start the mechanic animation
        RequestAnimDict('mini@repair')
        while not HasAnimDictLoaded('mini@repair') do
            Citizen.Wait(10)
        end
        TaskPlayAnim(playerPed, 'mini@repair', 'fixing_a_player', 8.0, -8.0, -1, 1, 0, false, false, false)

        -- Wait for the animation duration
        Citizen.Wait(mechanicAnimationDuration)

        -- Clear the animation
        ClearPedTasks(playerPed)

        -- Create the warning light props at the configured coordinates with rotation
        for _, lightPos in ipairs(lightPositions) do
            local light = CreateObject(warningLightModel, lightPos.coords.x, lightPos.coords.y, lightPos.coords.z, true, true, true)
            SetEntityHeading(light, lightPos.heading) -- Set the heading of the prop
            SetEntityRotation(light, 0.0, 0.0, lightPos.rotate) -- Set the rotation of the prop
            FreezeEntityPosition(light, true)
            table.insert(warningLights, light)
        end

        -- Create the spot lights
        for _, lightPos in ipairs(lightPositions) do
            local light = {
                pos = lightPos.coords,
                dir = vector3(0.0, 0.0, -1.0), -- Direction of the light (downwards)
                color = {255, 255, 200}, -- Color of the light (yellow-white)
                distance = 100.0, -- Distance the light reaches
                brightness = 0.4, -- Brightness of the light
                roundness = 5.0, -- Roundness of the light
                radius = 80.0, -- Radius of the light
                falloff = 5.0 -- Falloff of the light
            }
            table.insert(spotLights, light)
        end

        -- Update the last activation time
        lastActivationTime = currentTime

        -- Set the first activation flag to false
        isFirstActivation = false

        -- Notify the player
        Vanguard.notifyclient(Config.notifications.generatorActivated.title, Config.notifications.generatorActivated.message, 5000, Config.notifications.generatorActivated.type)
        Vanguard.notifyclient(Config.notifications.generatorTip.title, Config.notifications.generatorTip.message, 5000, Config.notifications.generatorTip.type)
    end
end)

-- Function to draw spot lights
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for _, light in ipairs(spotLights) do
            DrawSpotLight(light.pos.x, light.pos.y, light.pos.z, light.dir.x, light.dir.y, light.dir.z, light.color[1], light.color[2], light.color[3], light.distance, light.brightness, light.roundness, light.radius, light.falloff)
        end
    end
end)


-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ################################### MINING NPC 1 ########################################################################### 
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
-- ############################################################################################################################
Citizen.CreateThread(function()
    local minerConfig = Config.minerNPC

    -- Coordinates where the PED will be created
    local pedCoords = minerConfig.coords
    local pedHeading = minerConfig.heading

    -- PED model
    local pedModel = GetHashKey(minerConfig.model)

    -- Load the PED model
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(10)
    end

    -- Create the PED
    local ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, false, true)

    -- Set the PED as immovable and indestructible
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Helmet model
    local helmetModel = GetHashKey(minerConfig.helmetModel)

    -- Load the helmet model
    RequestModel(helmetModel)
    while not HasModelLoaded(helmetModel) do
        Citizen.Wait(10)
    end

    -- Create the helmet
    local helmetProp = CreateObject(helmetModel, 0.0, 0.0, 0.0, true, true, true)

    -- Attach the helmet to the PED's head
    AttachEntityToEntity(helmetProp, ped, GetPedBoneIndex(ped, 12844), 0.08, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)

    -- Release the PED and helmet models
    SetModelAsNoLongerNeeded(pedModel)
    SetModelAsNoLongerNeeded(helmetModel)

    -- Add ox_target to the PED
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'miner_menu',
            icon = 'fa-solid fa-hammer',  -- Menu icon (can be changed)
            label = 'Miner Menu',  -- Menu label
            onSelect = function()
                -- Here you can add the logic to open the miner menu
                OpenMiningMenu()
            end
        }
    })

    -- Function to remove all helmets in the NPC's area
    local function removeAllHelmets()
        local objects = GetGamePool('CObject')
        for _, object in pairs(objects) do
            if GetEntityModel(object) == helmetModel then
                DeleteObject(object)
            end
        end
    end

    -- Function to make the prop disappear, then the NPC, and then recreate them after 1 second
    local function toggleVisibility()
        -- Remove all helmets in the area
        removeAllHelmets()

        -- Wait 1 second
        Citizen.Wait(1000)

        -- Remove the PED
        DeleteEntity(ped)

        -- Wait 1 second
        Citizen.Wait(1000)

        -- Recreate the PED
        ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, false, true)

        -- Set the PED as immovable and indestructible
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        -- Recreate the helmet
        helmetProp = CreateObject(helmetModel, 0.0, 0.0, 0.0, true, true, true)

        -- Attach the helmet to the PED's head
        AttachEntityToEntity(helmetProp, ped, GetPedBoneIndex(ped, 12844), 0.08, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)

        -- Add ox_target to the PED again
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'miner_menu',
                icon = 'fa-solid fa-hammer',  -- Menu icon (can be changed)
                label = 'Miner Menu',  -- Menu label
                onSelect = function()
                    -- Here you can add the logic to open the miner menu
                    OpenMiningMenu()
                end
            }
        })
    end

    -- Call the function to toggle visibility
    toggleVisibility()
end)

Vanguard = exports["Vanguard_Bridge"]:Vanguard()

Menu = Vanguard.GetMenu()

if Menu == "lib" then
    Menu = lib
else
    Menu = Vanguard
end

function OpenMiningMenu()
    Menu.showContext('miner_menu')
end

-- Function to open the clothing menu
function OpenClothingMenu()
    Menu.showContext('clothing_menu')
end

-- Function to open the tool shop menu
function OpenToolShopMenu()
    Menu.showContext('tool_shop_menu')
end

-- Function to open the tool category menu
function OpenToolCategoryMenu()
    Menu.showContext('tool_category_menu')
end

-- Function to open the utensil category menu
function OpenUtensilCategoryMenu()
    Menu.showContext('utensil_category_menu')
end

Menu.registerContext({
    id = 'miner_menu',
    title = 'Miner Menu',
    description = 'Options for miners',
    canClose = true,  -- Adds the canClose option
    options = {
        {
            title = 'Clothing',
            icon = 'fa-solid fa-shirt',  -- Icon for clothing
            description = 'Access the miner clothing',
            onSelect = function()
                OpenClothingMenu()
            end,
            canClose = false  -- Adds the canClose option
        },
        {
            title = 'Tool Shop',
            icon = 'fa-solid fa-tools',  -- Icon for tool shop
            description = 'Access the tool shop',
            onSelect = function()
                OpenToolShopMenu()
            end,
            canClose = false  -- Adds the canClose option
        }
    }
})

Menu.registerContext({
    id = 'clothing_menu',
    title = 'Clothing Menu',
    description = 'Choose your clothing type',
    menu = "miner_menu",
    canClose = true,  -- Adds the canClose option
    options = {
        {
            title = 'Normal Clothing',
            icon = 'fa-solid fa-shirt',  -- Icon for normal clothing
            description = 'Access normal clothing',
            onSelect = function()
                uniformType = "civ_wear"
                configuniforms = Config.Uniforms
                Menu.Clothe(uniformType, male, female, configuniforms)
            end,
            canClose = true  -- Adds the canClose option
        },
        {
            title = 'Miner Clothing',
            icon = 'fa-solid fa-hard-hat',  -- Icon for miner clothing
            description = 'Access miner clothing',
            onSelect = function()
                Menu.showContext('inspection_uniform')
            end,
            canClose = false  -- Adds the canClose option
        }
    }
})

local uniformOptions = {}  -- Create a table to store uniform options.

for key, uniforms in pairs(Config.Uniforms) do
    table.insert(uniformOptions, {
        title = uniforms.name,
        icon = "shirt",
        description = "Wear miner uniform",
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
    menu = 'clothing_menu',
})

Menu.registerContext({
    id = 'tool_shop_menu',
    title = 'Tool Shop Menu',
    description = 'Choose your category',
    menu = "miner_menu",
    canClose = true,  -- Adds the canClose option
    options = {
        {
            title = 'Tools',
            icon = 'fa-solid fa-tools',  -- Icon for tools
            description = 'Access the tool category',
            onSelect = function()
                OpenToolCategoryMenu()
            end,
            canClose = false  -- Adds the canClose option
        },
        {
            title = 'Utensils',
            icon = 'fa-solid fa-toolbox',  -- Icon for utensils
            description = 'Access the utensil category',
            onSelect = function()
                OpenUtensilCategoryMenu()
            end,
            canClose = false  -- Adds the canClose option
        }
    }
})

local toolOptions = {}  -- Create a table to store tool options.

for _, tool in ipairs(Config.MiningTools.Tools) do
    table.insert(toolOptions, {
        title = tool.name,
        icon = tool.icon,
        description = string.format("Purchase %s for $%d", tool.name, tool.price),
        onSelect = function()
            TriggerServerEvent('buyTool', tool.item, tool.price)
        end,
        canClose = true,
    })
end

Menu.registerContext({
    id = 'tool_category_menu',
    title = 'Tool Menu',
    description = 'Choose your tool',
    menu = "tool_shop_menu",
    canClose = true,  -- Adds the canClose option
    options = toolOptions
})

local utensilOptions = {}  -- Create a table to store utensil options.

for _, utensil in ipairs(Config.MiningTools.Utensils) do
    table.insert(utensilOptions, {
        title = utensil.name,
        icon = utensil.icon,
        description = string.format("Purchase %s for $%d", utensil.name, utensil.price),
        onSelect = function()
            TriggerServerEvent('buyTool', utensil.item, utensil.price)
        end,
        canClose = true,
    })
end

Menu.registerContext({
    id = 'utensil_category_menu',
    title = 'Utensil Menu',
    description = 'Choose your utensil',
    menu = "tool_shop_menu",
    canClose = true,  -- Adds the canClose option
    options = utensilOptions
})

------------
---------------
-------------