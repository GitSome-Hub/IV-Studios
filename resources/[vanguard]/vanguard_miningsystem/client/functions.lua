-- Função para remover props dentro de um raio específico
function RemovePropsInRadius(coords, radius)
    local handle, object = FindFirstObject()
    local success
    repeat
        if IsEntityAPed(object) == false and IsEntityAnObject(object) then
            local objCoords = GetEntityCoords(object)
            local distance = #(coords - objCoords)
            if distance <= radius then
                DeleteObject(object)
            end
        end
        success, object = FindNextObject(handle)
    until not success
    EndFindObject(handle)
end

-- Função para remover todas as props dentro de um raio específico, independentemente da posição do jogador
function RemoveAllPropsInRadius(radius)
    local handle, object = FindFirstObject()
    local success
    repeat
        if IsEntityAPed(object) == false and IsEntityAnObject(object) then
            local objCoords = GetEntityCoords(object)
            local distance = #(vector3(0, 0, 0) - objCoords)
            if distance <= radius then
                DeleteObject(object)
            end
        end
        success, object = FindNextObject(handle)
    until not success
    EndFindObject(handle)
end

-- Remover props ao reiniciar o script
Citizen.CreateThread(function()
    -- Aguardar um pouco para garantir que o script esteja totalmente carregado
    Citizen.Wait(1000)

    local radius = 50.0
    RemoveAllPropsInRadius(radius)
end)

-- Função para criar props
function CreateProp(modelHash, coords, heading, rotation)
    RequestModel(modelHash)  -- Solicita o carregamento do modelo
    while not HasModelLoaded(modelHash) do
        Wait(1)  -- Espera um frame para que o modelo carregue
    end

    local prop = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, true)
    SetEntityHeading(prop, heading)
    SetEntityRotation(prop, 0.0, 0.0, rotation, 2, true)
    FreezeEntityPosition(prop, true) -- Opcional: Congela o prop no lugar
    return prop
end

-- Lista de props com suas coordenadas, headings e rotações adicionais
local props = {
    { model = `prop_ind_conveyor_04`, coords = vector3(2954.700, 2787.206, 39.731), heading = 185.86, rotation = 10.0 }, -- 1 conveyor
    { model = `cs5_4_q_convb001`, coords = vector3(2956.242, 2778.556, 43.700), heading = 180.92, rotation = 130.0 }, -- 1 prop conveyor
    { model = `prop_ind_conveyor_01`, coords = vector3(2956.242, 2778.556, 42.981), heading = 180.92, rotation = 10.0 }, -- 1 prop conveyor

    { model = `cs5_4_q_convb001`, coords = vector3(2957.523, 2771.916, 43.700), heading = 180.92, rotation = 130.0 }, -- 2 prop conveyor
    { model = `prop_ind_conveyor_01`, coords = vector3(2957.523, 2771.916, 42.981), heading = 180.92, rotation = 10.0 }, -- 2 prop conveyor 

    { model = `cs5_4_q_convb001`, coords = vector3(2958.306, 2766.945, 43.700), heading = 180.92, rotation = 130.0 }, -- 3 prop conveyor 
    { model = `prop_ind_conveyor_01`, coords = vector3(2959.052, 2762.888, 43.000), heading = 180.92, rotation = 10.0 }, -- 3 prop conveyor
    { model = `cs5_4_q_convb001`, coords = vector3(2959.589, 2760.316, 43.700), heading = 180.92, rotation = 130.0 }, -- 3 prop conveyor
    -- Adicione mais props conforme necessário
    { model = `prop_skip_08b`, coords = vector3(2960.735, 2754.000, 41.900), heading = 9.23, rotation = 190.0 }, -- 3 prop conveyor
    { model = `prop_ind_conveyor_04`, coords = vector3(2960.735, 2754.000, 39.800), heading = 9.23, rotation = 190.0 }, -- 3 prop conveyor
}

-- Thread para verificar a distância dos jogadores e spawnar/remover props
Citizen.CreateThread(function()
    local propHandles = {}
    local radius = 500.0

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerNear = false

        -- Verifica se algum jogador está próximo das coordenadas das props
        for _, propData in ipairs(props) do
            local distance = #(playerCoords - propData.coords)
            if distance <= radius then
                playerNear = true
                break
            end
        end

        -- Se houver jogador próximo, cria as props
        if playerNear then
            for _, propData in ipairs(props) do
                if not propHandles[propData.coords] then
                    propHandles[propData.coords] = CreateProp(propData.model, propData.coords, propData.heading, propData.rotation)
                end
            end
        else
            -- Se não houver jogador próximo, remove as props
            for coords, propHandle in pairs(propHandles) do
                DeleteObject(propHandle)
                propHandles[coords] = nil
            end
        end

        Citizen.Wait(10000) -- Aguarda 1 segundo antes de verificar novamente
    end
end)


------
------ CONVEYOR SYSTEM
------ CONVEYOR SYSTEM
-----


local placeCoords = Config.depositCoords  -- Coordenadas para colocar as pedras
local spawnCoords = Config.stonePropCoords  -- Coordenada para spawnar a segunda pedra
local radius = 1.0  -- Raio da zona de interação
local stoneProps = {}  -- Armazenará as propriedades das pedras spawnadas
local stonesCollected = false  -- Flag para rastrear se as pedras foram recolhidas

-- Função para remover todas as pedras do jogador
local function removeAllStones(playerId)
    if stoneProps[playerId] then
        for _, prop in ipairs(stoneProps[playerId]) do
            exports.ox_target:removeLocalEntity(prop, "prop_rock_5_e")

            SetEntityAsMissionEntity(prop, true, true)
            DeleteEntity(prop)
            DeleteObject(prop)
        end
        stoneProps[playerId] = nil
        stonesCollected = true  -- Marcar que as pedras foram recolhidas
    end
end

-- Função para permitir que o jogador deposite pedras novamente
local function resetStoneDeposit()
    stonesCollected = false  -- Resetar a flag para permitir o depósito novamente
end

-- Função para remover o item "miner_stone" do inventário
local function removeMinerStone()
    if not stonesCollected then
        TriggerServerEvent('place_stones:removeItem')
    else
        -- Vanguard.notifyserver(source, Config.notifications.stonesAlreadyCollected.title, Config.notifications.stonesAlreadyCollected.message, 5000, Config.notifications.stonesAlreadyCollected.type)
    end
end

-- Função para spawnar as pedras na coordenada especificada
local function spawnStones(playerId, stoneCount)
    for i = 1, stoneCount do
        local stoneProp = CreateObject(GetHashKey("prop_rock_5_e"), spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
        PlaceObjectOnGroundProperly(stoneProp)
        stoneProps[playerId] = stoneProps[playerId] or {}
        table.insert(stoneProps[playerId], stoneProp)

        -- Adiciona o ox_target para recolher o minério
        exports.ox_target:addLocalEntity(stoneProp, {
            {
                name = "collect_ore",
                icon = "fas fa-hammer",
                label = "Collect Ore",
                onSelect = function()
                    TriggerServerEvent('place_stones:collectOre', playerId, stoneProp, stoneCount)
                    removeAllStones(playerId)  -- Remove todas as pedras após a coleta
                    resetStoneDeposit()  -- Permite o depósito novamente
                end
            }
        })
    end
    stonesCollected = false  -- Resetar a flag ao spawnar novas pedras
end

RegisterNetEvent('place_stones:spawnStones')
AddEventHandler('place_stones:spawnStones', function(stoneCount)
    spawnStones(source, stoneCount)
end)

RegisterNetEvent('place_stones:removeAllStones')
AddEventHandler('place_stones:removeAllStones', function()
    removeAllStones(source)
end)

-- Definindo a zona de interação para o jogador
local zoneId = exports.ox_target:addSphereZone({
    coords = placeCoords,
    radius = radius,
    options = {
        {
            name = "place_stones",
            icon = "fas fa-hammer",
            label = "Place Stones",
            onSelect = removeMinerStone
        }
    }
})

------
------ NPC SELLER
-----

Citizen.CreateThread(function()
    -- Coordenadas onde o PED será criado
    local pedCoords = Config.oreSellingNPC.coords
    local pedHeading = Config.oreSellingNPC.heading

    -- Modelo do PED
    local pedModel = GetHashKey(Config.oreSellingNPC.model)

    -- Carrega o modelo do PED
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(10)
    end

    -- Cria o PED
    local ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, false, true)

    -- Define o PED como imóvel e indestrutível
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Modelo do capacete
    local helmetModel = GetHashKey(Config.oreSellingNPC.helmetModel)

    -- Carrega o modelo do capacete
    RequestModel(helmetModel)
    while not HasModelLoaded(helmetModel) do
        Citizen.Wait(10)
    end

    -- Cria o capacete
    local helmetProp = CreateObject(helmetModel, 0.0, 0.0, 0.0, true, true, true)

    -- Anexa o capacete à cabeça do PED
    AttachEntityToEntity(helmetProp, ped, GetPedBoneIndex(ped, 12844), 0.08, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)

    -- Libera o modelo do PED e do capacete
    SetModelAsNoLongerNeeded(pedModel)
    SetModelAsNoLongerNeeded(helmetModel)

    -- Adiciona o ox_target ao PED
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'sell_ores',
            icon = 'fa-solid fa-coins',  -- Ícone do menu (pode ser alterado)
            label = "Sell Ores",  -- Label do menu
            onSelect = function()
                OpenOreSellingMenu()
            end
        }
    })
end)

Vanguard = exports["Vanguard_Bridge"]:Vanguard()

Menu = Vanguard.GetMenu()

if Menu == "lib" then
    Menu = lib
else
    Menu = Vanguard
end

function OpenOreSellingMenu()
    Menu.showContext('ore_selling_menu')
end

Menu.registerContext({
    id = 'ore_selling_menu',
    title = "Sell Ores",
    description = "Sell your mined ores",
    canClose = true,  -- Adds the canClose option
    options = {}
})

local oreOptions = {}  -- Create a table to store ore selling options.

for _, ore in ipairs(Config.oreSellingNPC.sellableOres) do
    table.insert(oreOptions, {
        title = ore.displayName,
        icon = 'fa-solid fa-coins',
        description = string.format("Sell %s for $%d each", ore.displayName, ore.price),
        onSelect = function()
            TriggerServerEvent('sellOre', ore.item)
        end,
        canClose = true,
    })
end

Menu.registerContext({
    id = 'ore_selling_menu',
    title = "Sell Ores",
    description = "Sell your mined ores",
    canClose = true,  -- Adds the canClose option
    options = oreOptions
})


---- blip creator 

-- Function to create the blips
function CreateBlips()
    for _, blipData in pairs(Config.Blips) do
        local blip = AddBlipForCoord(blipData.coords)
        SetBlipSprite(blip, blipData.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, blipData.scale)
        SetBlipColour(blip, blipData.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.name)
        EndTextCommandSetBlipName(blip)
    end
end

-- Call the function to create the blips when the script starts
CreateBlips()