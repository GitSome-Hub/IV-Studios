QBCore = exports['qb-core']:GetCoreObject()

-- Function to check if a table contains a value
function table.contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

local k9Ped = nil
local k9Owner = nil
local selectedTarget = nil
local targetMarkerActive = false

-- Function to spawn the K9
local function spawnK9()
    local playerJob = QBCore.Functions.GetPlayerData().job.name
    if not k9Ped and table.contains(Config.AllowedJobs, playerJob) then -- Check if the job is allowed
        local model = GetHashKey("a_c_shepherd")
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        k9Ped = CreatePed(28, model, coords.x, coords.y, coords.z, heading, true, false)
        SetEntityAsMissionEntity(k9Ped, true, true)
        k9Owner = PlayerPedId()

        exports.ox_target:addLocalEntity({k9Ped}, {
            {
                name = "k9_stay",
                event = "k9:stay",
                icon = "fa-solid fa-stop",
                label = Config.Notifications.Eyek9StayInPlace,
            },
            {
                name = "k9_follow",
                event = "k9:follow",
                icon = "fa-solid fa-walking",
                label = Config.Notifications.Eyek9FollowMe,
            }
        })

        TaskFollowToOffsetOfEntity(k9Ped, k9Owner, 0.0, -1.0, 0.0, 2.0, -1, 5.0, true)
        ShowNotification(Config.Notifications.k9Spawned)  -- Notify player K9 has been spawned
    else
        ShowNotification(Config.Notifications.cannotSpawnK9)  -- Notify player can't spawn
    end
end

-- Function to remove the K9
local function returnK9()
    if k9Ped then
        DeleteEntity(k9Ped)
        k9Ped = nil
        k9Owner = nil
        ShowNotification(Config.Notifications.k9Returned)  -- Notify player K9 has been returned
    else
        print("The K9 has already been returned.")
    end
end

local function selectNearestPlayer()
    local ownerCoords = GetEntityCoords(k9Owner)
    local closestPlayer, closestDistance = nil, 10.0

    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped ~= k9Owner and not IsPedDeadOrDying(ped) then
            local playerCoords = GetEntityCoords(ped)
            local distance = #(ownerCoords - playerCoords)

            if distance < closestDistance then
                closestPlayer = ped
                closestDistance = distance
            end
        end
    end

    if closestPlayer then
        selectedTarget = closestPlayer
        targetMarkerActive = true
        ShowNotification(Config.Notifications.targetSelected)
    else
        ShowNotification(Config.Notifications.noNearbyPlayers)
    end
end

-- Function to change the target to the next player
local function changeTarget()
    selectNearestPlayer()
end

-- Function to attack the selected target
local function attackSelectedTarget()
    if k9Ped and selectedTarget then
        local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(selectedTarget))
        
        QBCore.Functions.TriggerCallback('qb-core:getOtherPlayerData', function(targetPlayerData)
            local targetJob = targetPlayerData.job.name

            if not table.contains(Config.ProtectedJobs, targetJob) then
                ShowNotification(Config.Notifications.k9AttackingTarget)
                ClearPedTasks(k9Ped)
                FreezeEntityPosition(k9Ped, false)
                TaskCombatPed(k9Ped, selectedTarget, 0, 16)
                targetMarkerActive = false -- Desativa o marcador quando o ataque começa
                selectedTarget = nil
            else
                ShowNotification(Config.Notifications.cannotAttackProtectedPlayer)
            end
        end, targetServerId)
    else
        ShowNotification(Config.Notifications.noTargetToAttack)
    end
end


-- Function to stop the attack and have the K9 follow the owner
local function stopAttack()
    if k9Ped then
        ClearPedTasksImmediately(k9Ped) -- Immediately stop any combat tasks
        TaskFollowToOffsetOfEntity(k9Ped, k9Owner, 0.0, -1.0, 0.0, 2.0, -1, 5.0, true)
        targetMarkerActive = false -- Disable marker if active
        selectedTarget = nil
        ShowNotification(Config.Notifications.k9StoppedAttacking)  -- Notify player K9 has stopped attacking
    else
        ShowNotification(Config.Notifications.noTargetToAttack)  -- Notify player if no target selected
    end
end



-- Function to ignore shots fired nearby
local function onWeaponFired(sourcePed, targetPed)
    if k9Ped and DoesEntityExist(k9Ped) and GetDistanceBetweenCoords(GetEntityCoords(k9Ped), GetEntityCoords(sourcePed), true) < 10.0 then
        -- Check if a player is shot (not the owner) and the k9 is not attacking
        if sourcePed ~= k9Owner then
            local targetCoords = GetEntityCoords(targetPed)
            local isPlayerShot = false
            
            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                if ped == targetPed and not IsPedDeadOrDying(ped) then
                    isPlayerShot = true
                    break
                end
            end

            if isPlayerShot then
                attackSelectedTarget()  -- Attack the target player if they were shot
            end
        end
    end
end

RegisterNetEvent("k9:stay", function()
    if k9Ped then
        ClearPedTasks(k9Ped)
        FreezeEntityPosition(k9Ped, true)
        ShowNotification(Config.Notifications.k9Waiting)  -- Notify K9 is waiting
    end
end)

RegisterNetEvent("k9:follow", function()
    if k9Ped and k9Owner then
        ClearPedTasks(k9Ped)
        FreezeEntityPosition(k9Ped, false)
        TaskFollowToOffsetOfEntity(k9Ped, k9Owner, 0.0, -1.0, 0.0, 2.0, -1, 5.0, true)
        ShowNotification(Config.Notifications.k9Following)  -- Notify K9 is following
    end
end)

for i, spawnPoint in ipairs(Config.K9Spawn) do
    exports.ox_target:addSphereZone({
        coords = spawnPoint.coords,
        radius = 1.5,
        debug = false,
        options = {
            {
                name = "deploy_k9",
                event = "k9:release",
                icon = "fa-solid fa-dog",
                label = Config.Notifications.Eyek9Deploy,
                distance = 2.0,
                onSelect = function()
                    spawnK9(spawnPoint.coords, spawnPoint.heading)
                end
            },
            {
                name = "return_k9",
                event = "k9:return",
                icon = "fa-solid fa-dog",
                label = Config.Notifications.Eyek9Return,
                distance = 2.0,
            }
        }
    })
end

RegisterNetEvent("k9:release", function()
    spawnK9()
end)

RegisterNetEvent("k9:return", function()
    returnK9()
end)

-- Function to show a marker over the selected target
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if targetMarkerActive and selectedTarget then
            local targetCoords = GetEntityCoords(selectedTarget)
            DrawMarker(2, targetCoords.x, targetCoords.y, targetCoords.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 0, 0, 255, true, true, 2, nil, nil, false)
        end
    end
end)

-- Função para cheirar o alvo selecionado
local function sniffTarget()
    if selectedTarget then
        -- Obter o ID do jogador alvo
        local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(selectedTarget))

        -- Fazer o K9 ir até o alvo
        TaskGoToEntity(k9Ped, selectedTarget, -1, 1.0, 2.0, 2.0, 0)

        -- Esperar até que o K9 chegue ao jogador alvo
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(500) -- Verifica a cada 0.5 segundos

                -- Obter a posição do K9 e do jogador alvo
                local k9Pos = GetEntityCoords(k9Ped)
                local targetPos = GetEntityCoords(selectedTarget)

                -- Calcular a distância entre o K9 e o jogador alvo
                local distance = Vdist(k9Pos.x, k9Pos.y, k9Pos.z, targetPos.x, targetPos.y, targetPos.z)

                -- Verificar se o K9 está próximo o suficiente do jogador alvo (ajustar o valor conforme necessário)
                if distance < 2.0 then
                    -- Iniciar a barra de progresso para cheirar
                    if lib.progressCircle({
                        duration = 5000, -- 5 segundos
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                        },
                    }) then
                        -- Enviar pedido para verificar o inventário do jogador alvo
                        TriggerServerEvent('k9:checkInventory', targetId, Config.SniffableItems)

                        -- Aguarde o retorno do evento
                        RegisterNetEvent('k9:inventoryChecked', function(itemsFound)
                            if #itemsFound > 0 then
                                local itemNames = {}
                                for _, item in ipairs(itemsFound) do
                                    table.insert(itemNames, item.name .. " (" .. item.count .. ")")
                                end
                                ShowNotification(Config.Notifications.sniffedItemNotification .. table.concat(itemNames, ", "))
                            else
                                ShowNotification(Config.Notifications.noSniffableItemsFound)
                            end

                            -- Remover o marcador se estava ativo
                            targetMarkerActive = false 

                            -- Fazer o K9 seguir o dono novamente
                            if k9Ped then
                                ClearPedTasksImmediately(k9Ped)
                                TaskFollowToOffsetOfEntity(k9Ped, k9Owner, 0.0, -1.0, 0.0, 2.0, -1, 5.0, true)
                            end
                        end)
                    else
                        ShowNotification(Config.Notifications.sniffingCancelled) -- Notificar se o sniffing for cancelado
                        -- Garantir que o K9 siga o dono se cancelado
                        if k9Ped then
                            ClearPedTasksImmediately(k9Ped)
                            TaskFollowToOffsetOfEntity(k9Ped, k9Owner, 0.0, -1.0, 0.0, 2.0, -1, 5.0, true)
                        end
                    end
                    break -- Sair do loop quando a progress bar for iniciada
                end

                -- Se o K9 se afastar do jogador ou se a interação for cancelada, saia do loop
                if not DoesEntityExist(selectedTarget) or IsEntityDead(selectedTarget) then
                    ShowNotification(Config.Notifications.noTargetSelectedToSniff)
                    ClearPedTasksImmediately(k9Ped)
                    TaskFollowToOffsetOfEntity(k9Ped, k9Owner, 0.0, -1.0, 0.0, 2.0, -1, 5.0, true)
                    break
                end
            end
        end)
    else
        ShowNotification(Config.Notifications.noTargetSelectedToSniff)
    end
end

-- Função para colocar o K9 dentro do veículo mais próximo
local function putK9InVehicle()
    if k9Ped and DoesEntityExist(k9Ped) then
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle == 0 then
            -- Procura o veículo mais próximo
            local playerCoords = GetEntityCoords(playerPed)
            local closestVehicle, closestDistance = nil, 5.0

            for vehicle in EnumerateVehicles() do
                local distance = #(playerCoords - GetEntityCoords(vehicle))
                if distance < closestDistance then
                    closestVehicle = vehicle
                    closestDistance = distance
                end
            end

            if closestVehicle then
                vehicle = closestVehicle
            else
                --ShowNotification("Nenhum veículo próximo encontrado.")  -- Notifica se não houver veículo próximo
                return
            end
        end

        -- Coloca o K9 dentro do veículo
        TaskWarpPedIntoVehicle(k9Ped, vehicle, 0)  -- 0 para o banco do motorista
        ShowNotification(Config.Notifications.k9PutInVehicle)
    else
       -- ShowNotification("O K9 não está disponível.")  -- Notifica se o K9 não está disponível
    end
end

-- Função para remover o K9 do veículo e teleportá-lo para próximo do jogador
local function takeK9OutOfVehicle()
    if k9Ped and DoesEntityExist(k9Ped) then
        local vehicle = GetVehiclePedIsIn(k9Ped, false)
        if vehicle and vehicle ~= 0 then
            -- Teleporta o K9 para a posição do jogador
            local playerCoords = GetEntityCoords(PlayerPedId())  -- Posição do jogador
            SetEntityCoords(k9Ped, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false, true)  -- Teleporta o K9 para a posição do jogador
            
            ShowNotification(Config.Notifications.k9OutVehicle)  -- Notifica que o K9 saiu do veículo
            ClearPedTasksImmediately(k9Ped)
            TaskFollowToOffsetOfEntity(k9Ped, k9Owner, 0.0, -1.0, 0.0, 2.0, -1, 5.0, true)
        else
            --ShowNotification("O K9 não está dentro de um veículo.")  -- Notifica se o K9 não está em um veículo
        end
    else
       -- ShowNotification("O K9 não está disponível.")  -- Notifica se o K9 não está disponível
    end
end


-- Função para enumerar veículos próximos
function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        local success
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(handle)
        until not success
        EndFindVehicle(handle)
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, Config.Controls.k9MenuKey) then  -- F5 key
            local playerJob = QBCore.Functions.GetPlayerData().job.name
            if table.contains(Config.AllowedJobs, playerJob) then
                lib.showContext('k9_menu')
            else
                ShowNotification(Config.Notifications.k9OnlyPolice)
            end
        end
    end
end)

-- Registro dos menus
lib.registerContext({
    id = 'k9_attack_menu',
    title = Config.Text.k9AttackMenuTitle,
    options = {
        {
            title = Config.Text.k9AttackSelectTarget,
            icon = 'fa-solid fa-crosshairs',
            onSelect = function()
                if k9Ped then
                    selectNearestPlayer()
                else
                    ShowNotification(Config.Notifications.k9MenuNotAvailable)
                end
            end
        },
        {
            title = Config.Text.k9AttackStopAttack,
            icon = 'fa-solid fa-stop',
            onSelect = function()
                stopAttack()
            end
        },
        {
            title = Config.Text.k9AttackAttackSelectedTarget,
            icon = 'fa-solid fa-person-rays',
            onSelect = function()
                attackSelectedTarget()
            end
        },
        {
            title = Config.Text.k9AttackChangeTarget,
            icon = 'fa-solid fa-sync-alt',
            onSelect = function()
                changeTarget()
            end
        },
        {
            title = Config.Text.k9AttackBackToMain,
            icon = 'fa-solid fa-arrow-left',
            onSelect = function()
                lib.showContext('k9_menu')
            end
        },
    }
})

lib.registerContext({
    id = 'k9_sniff_menu',
    title = Config.Text.k9SniffMenuTitle,
    options = {
        {
            title = Config.Text.k9SniffSelectTarget,
            icon = 'fa-solid fa-crosshairs',
            onSelect = function()
                if k9Ped then
                    selectNearestPlayer()
                else
                    ShowNotification(Config.Notifications.k9MenuNotAvailable)
                end
            end
        },
        {
            title = Config.Text.k9SniffChangeTarget,
            icon = 'fa-solid fa-sync-alt',
            onSelect = function()
                changeTarget()
            end
        },
        {
            title = Config.Text.k9SniffSniffTarget,
            icon = 'fa-solid fa-person-rays',
            onSelect = function()
                sniffTarget()
            end
        },
        {
            title = Config.Text.k9SniffBackToMain,
            icon = 'fa-solid fa-arrow-left',
            onSelect = function()
                lib.showContext('k9_menu')
            end
        },
    }
})

-- Adiciona opções ao menu de veículos
lib.registerContext({
    id = 'k9_vehicle_menu',
    title = Config.Text.k9VehicleMenuTitle,
    options = {
        {
            title = Config.Text.k9VehiclePlaceK9,
            icon = 'fa-solid fa-car',
            onSelect = function()
                putK9InVehicle()  -- Chama a função para colocar o K9 no veículo
            end
        },
        {
            title = Config.Text.k9VehicleRemoveK9,
            icon = 'fa-solid fa-car-side',
            onSelect = function()
                takeK9OutOfVehicle()  -- Chama a função para retirar o K9 do veículo
            end
        },
        {
            title = Config.Text.k9VehicleBackToMain,
            icon = 'fa-solid fa-arrow-left',
            onSelect = function()
                lib.showContext('k9_menu')
            end
        },
    }
})

lib.registerContext({
    id = 'k9_menu',
    title = Config.Text.k9MenuTitle,
    options = {
        {
            title = Config.Text.k9MenuVehicle,
            icon = 'fa-solid fa-car',
            onSelect = function()
                lib.showContext('k9_vehicle_menu')
            end
        },
        {
            title = Config.Text.k9MenuAttack,
            icon = 'fa-solid fa-fist-raised',
            onSelect = function()
                lib.showContext('k9_attack_menu')
            end
        },
        {
            title = Config.Text.k9MenuSniff,
            icon = 'fa-solid fa-person-circle-question',
            onSelect = function()
                lib.showContext('k9_sniff_menu')
            end
        },
    }
})

-- Configurable notification function
function ShowNotification(message)
    if Config.NotificationSystem == 'okokNotify' then
        exports['okokNotify']:Alert("K9", message, 7000, 'info') 
    elseif Config.NotificationSystem == 'QBCore' then
        -- Utilizando o sistema de notificação do QBCore corretamente
        QBCore.Functions.Notify(message, 'success', 7000)  -- Notificação de sucesso (ou 'error', 'info', etc. conforme necessário)
    elseif Config.NotificationSystem == 'wasabiNotify' then
        exports.wasabi_notify:notify("K9", message, 7000, 'info')  
    else
        print("Unknown notification system: " .. Config.NotificationSystem)
    end
end