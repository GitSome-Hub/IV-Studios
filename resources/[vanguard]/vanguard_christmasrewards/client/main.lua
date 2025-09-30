Vanguard = exports["Vanguard_Bridge"]:Vanguard()

local playTime = 0

Citizen.CreateThread(function()
    if Config.PlayTime then 
        playTime = GetGameTimer() + Config.Time
    else
        playTime = 0
    end
    
    Wait(5000)
    PlayerData = Vanguard.GetPlayerData()
    SendNUIMessage({
        action = 'setJS', 
        translate = Config.Language,
    })	
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterCommand(Config.OpenCommand, function()
    local myTime = getNeededPlayTime()
    Vanguard.TriggerServerCallback('vanguard_christmasrewards:getPlayerDetails', function(result)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'show', 
            rewards = Config.Rewards,
            playerDetails = result.playerData,
            today = result.today,
            tomorrow = result.tomorrowDate,
            myTime = myTime,
        })	
    end)
end)

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
end)

local rewardSpamProtect = 0
RegisterNUICallback('getReward', function(data, cb)
    if rewardSpamProtect <= GetGameTimer() then 
        rewardSpamProtect = GetGameTimer() + 1000
        Vanguard.TriggerServerCallback('vanguard_christmasrewards:getReward', function(result)
            if result then
                playTime = GetGameTimer() + 1 * 60000
            end
            cb(result)
        end, data)
    else
        cb(false)
    end
end)

getNeededPlayTime = function()
    return math.round((playTime - GetGameTimer()) / 60000, 2)
end

function math.round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

if Config.AFKCheck then 
    local secondsUntilReset = 10 * 60000
    Citizen.CreateThread(function()
        while true do
            Wait(5000)
            playerPed = PlayerPedId()
            if playerPed then
                currentPos = GetEntityCoords(playerPed, true)
                if currentPos == prevPos then
                    if time > 0 then
                        if time == math.ceil(secondsUntilReset / 4) then
                            Vanguard.notifyclient("AFK Warning", "You are AFK. Stay active to avoid losing your rewards.", 5000, "info")
                        end
                        time = time - 5
                    else
                        time = secondsUntilReset
                        Vanguard.notifyclient("AFK Detected", "You have been AFK for too long. Your playtime has been reset.", 5000, "error")
                        playTime = GetGameTimer() + Config.Time
                    end
                else
                    time = secondsUntilReset
                end
                prevPos = currentPos
            end
        end
    end)
end

RegisterNetEvent('seu_recurso:respostaDadosVeiculo')
AddEventHandler('seu_recurso:respostaDadosVeiculo', function(vehicle, plate)
    local vehicleModel = GetHashKey(vehicle)
    local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(vehicleModel))
    local self = {}
    self.PurchasedCarPos = {
        xyz = vector3(231.8645, -790.529, 30.616),  -- Substitua as coordenadas XYZ pelos valores desejados
        w = 200.0  -- Substitua pelo valor do heading (rotação) desejado
    }
	
    Vanguard.LoadModel(vehicleModel)
    Vanguard.Game.SpawnVehicle(vehicleModel, self.PurchasedCarPos.xyz, self.PurchasedCarPos.w, function(cbVeh)
        Citizen.Wait(10)
        SetEntityCoords(cbVeh, self.PurchasedCarPos.xyz, 0.0, 0.0, 0.0, true)
        SetEntityHeading(cbVeh, self.PurchasedCarPos.w)
        SetVehicleOnGroundProperly(cbVeh)
        Citizen.Wait(10)
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), cbVeh, -1)
        local vehProps = Vanguard.Game.GetVehicleProperties(cbVeh)
        TriggerServerEvent('seu_recurso:enviarDadosVeiculo', vehProps, plate) -- Envia vehProps para o servidor
    end)
end)