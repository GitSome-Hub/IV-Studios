local coordenada = vector3(-595.958, 2089.034, 131.41) -- Coordenadas exatas
local distancia = 100.0 -- Aumenta a distância para capturar a prop, mesmo se estiver longe
local propModel = GetHashKey("prop_mineshaft_door") -- Hash do modelo da porta
local portaRemovida = false -- Variável para rastrear o status da porta

-- Carregar o modelo explicitamente
RequestModel(propModel)
while not HasModelLoaded(propModel) do
    Citizen.Wait(10)
end

-- Função para remover a prop automaticamente ao iniciar o script
Citizen.CreateThread(function()
    local objetos = Vanguard.GetObjects() -- Obtém todos os objetos

    for _, objeto in ipairs(objetos) do
        local objetoPos = GetEntityCoords(objeto)
        local distanciaObj = #(objetoPos - coordenada)

        -- Verifica se o objeto é a prop desejada e está dentro da distância
        if distanciaObj <= distancia and GetEntityModel(objeto) == propModel then
            SetEntityAsMissionEntity(objeto, true, true)
            DeleteEntity(objeto)

            if not DoesEntityExist(objeto) then
               -- print("Objeto 'prop_mineshaft_door' removido ao iniciar o script.")
                portaRemovida = true
            end
        end
    end
end)

-- Loop contínuo para garantir que a prop permaneça removida se reaparecer
Citizen.CreateThread(function()
    while not portaRemovida do
        Citizen.Wait(5000) -- Tenta a cada 5 segundos

        -- Obtém todos os objetos próximos às coordenadas especificadas
        local objetos = Vanguard.GetObjects()

        for _, objeto in ipairs(objetos) do
            local objetoPos = GetEntityCoords(objeto)
            local distanciaObj = #(objetoPos - coordenada)

            -- Checa se o objeto está dentro da distância e é o prop desejado
            if distanciaObj <= distancia and GetEntityModel(objeto) == propModel then
                -- Remove a prop 'prop_mineshaft_door'
                SetEntityAsMissionEntity(objeto, true, true)
                DeleteEntity(objeto)

                if not DoesEntityExist(objeto) then
                  --  print("Objeto 'prop_mineshaft_door' removido com sucesso.")
                    portaRemovida = true
                    break
                end
            end
        end
    end
end)

