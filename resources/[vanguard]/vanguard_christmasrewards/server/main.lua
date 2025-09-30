Vanguard = exports["Vanguard_Bridge"]:Vanguard()

local BATTLE = Config

local rewards = {}
local todayReward = nil
local tomorrowReward = nil
local onActive = {}

Citizen.CreateThread(function()
    BATTLE.StartDay.hour = 0
    local startDate = os.time(BATTLE.StartDay)
    for k, v in pairs(BATTLE.Rewards) do 
        rewards[k] = {}
        rewards[k].day = v.day
        rewards[k].itemName = v.itemName
        rewards[k].itemCount = v.itemCount
        rewards[k].taken = false
        onActive[k] = {}
        onActive[k].day = v.day
        onActive[k].onActive = startDate + ((k) * 86400)
    end

    for k, v in pairs(onActive) do
        local time = v.onActive
    end
end)

Citizen.CreateThread(function()
    while true do
        local nowDate = os.time()
        for k, v in pairs(onActive) do 
            local resetDate = os.time(os.date("*t", v.onActive))
            local difference = os.difftime(resetDate, nowDate) / (24*60*60)
            local reelDate = math.floor(difference)
            if reelDate <= 0 then 
                todayReward = v.day
                if onActive[k] ~= nil then
                    tomorrowReward = onActive[k].onActive
                end
            end
        end
        tomorrowReward = disp_time(tomorrowReward - nowDate)
        Citizen.Wait(1 * 30000)
    end
end)

function disp_time(time)
    local days = math.floor(time/86400)
    local remaining = time % 86400
    local hours = math.floor(remaining/3600)
    remaining = remaining % 3600
    local minutes = math.floor(remaining/60)
    remaining = remaining % 60
    local seconds = remaining
    if (hours < 10) then
        hours = "0" .. tostring(hours)
    end
    if (minutes < 10) then
        minutes = "0" .. tostring(minutes)
    end
    if (seconds < 10) then
        seconds = "0" .. tostring(seconds)
    end
    if days > 0 then 
        answer = tostring(days)..'d '..hours..'h '..minutes..'m '..seconds..'s'
    else
        answer = hours..'h '..minutes..'m '..seconds..'s'
    end
    return answer
end

Vanguard.RegisterServerCallback('vanguard_christmasrewards:getPlayerDetails', function(source, cb)
    local Player = Vanguard.GetPlayerFromId(source)
    if not Player then
        Player = ESX.GetPlayerFromId(source)
    end

    if not Player then
        cb({error = "Player not found"})
        return
    end

    local citizenId = Player.PlayerData and Player.PlayerData.citizenid or Player.getIdentifier()
    local todayRewardDay = todayReward
    local callbackData = {}
    local result = MySQL.Sync.fetchAll("SELECT * FROM vanguard_christmasrewards WHERE citizenid = @citizenId", {
        ['@citizenId'] = citizenId
    })
    if result[1] == nil then    
        MySQL.Async.execute("INSERT INTO vanguard_christmasrewards (citizenid, rewards) VALUES (@citizenId, @rewards)", {
            ['@citizenId'] = citizenId,
            ['@rewards'] = json.encode(rewards)
        }, function()
            callbackData = {
                playerData = json.encode(rewards),
                today = todayReward,
                tomorrowDate = tomorrowReward
            }
            cb(callbackData)
        end)
    else
        callbackData = {
            playerData = result[1].rewards, 
            today = todayReward,
            tomorrowDate = tomorrowReward
        }
        cb(callbackData)
    end
end)

Vanguard.RegisterServerCallback('vanguard_christmasrewards:getReward', function(source, cb, data)
    local Player = Vanguard.GetPlayerFromId(source)
    if not Player then
        Player = ESX.GetPlayerFromId(source)
    end

    if not Player then
        cb({error = "Player not found"})
        return
    end

    local citizenId = Player.PlayerData and Player.PlayerData.citizenid or Player.getIdentifier()
    local selectedReward = data.itemDetails
    local result = MySQL.Sync.fetchAll("SELECT rewards FROM vanguard_christmasrewards WHERE citizenid = @citizenId", {
        ['@citizenId'] = citizenId
    })
    if result[1] then 
        local jsonParse = json.decode(result[1].rewards)
        local kayit = false
        local taskID = nil
        local itemInfo = nil
        for k, v in pairs(BATTLE.Rewards) do
            if tonumber(v.day) == tonumber(selectedReward.day) then
                if jsonParse[k].taken == false then
                    if jsonParse[k].day == todayReward then 
                        kayit = true
                        itemInfo = v
                        taskID = k
                    end
                end
                break
            end
        end
        if kayit then
            if itemInfo.itemType == "item" then 
                if itemInfo.unique then 
                    for i = 1, itemInfo.itemCount, 1 do 
                        Vanguard.GiveItem(source, itemInfo.itemName, 1)
                    end
                else
                    Vanguard.GiveItem(source, itemInfo.itemName, itemInfo.itemCount)
                end
            elseif itemInfo.itemType == "money" then 
                Vanguard.GiveMoney(source, itemInfo.itemCount)         
            elseif itemInfo.itemType == "vehicle" then 
                local plate = GeneratePlate()
                local vehicle = itemInfo.itemName
                MySQL.insert('INSERT INTO owned_vehicles (owner, vehicle, plate, type, stored, job) VALUES (?, ?, ?, ?, ?, ?)', {
                    citizenId,
                    vehicle,
                    plate,
                    'car',
                    '1',
                    'civ'
                })
                TriggerClientEvent('seu_recurso:respostaDadosVeiculo', source, vehicle, plate)
            end
            jsonParse[taskID].taken = true
            MySQL.Async.execute("UPDATE vanguard_christmasrewards SET rewards = @rewards WHERE citizenid = @citizenId", {
                ['@rewards'] = json.encode(jsonParse),
                ['@citizenId'] = citizenId
            })
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

function GeneratePlate()
    local plate = ""
    local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    for i = 1, 6 do
        local randomIndex = math.random(1, #characters)
        local randomChar = characters:sub(randomIndex, randomIndex)
        plate = plate .. randomChar
    end
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate = @plate', {['@plate'] = plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

function ExecuteSql(query)
    local IsBusy = true
    local result = nil
    if BATTLE.Mysql == "oxmysql" then
        if MySQL == nil then
            exports.oxmysql:execute(query, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.query(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif BATTLE.Mysql == "ghmattimysql" then
        exports.ghmattimysql:execute(query, {}, function(data)
            result = data
            IsBusy = false
        end)
    elseif BATTLE.Mysql == "mysql-async" then   
        MySQL.Async.fetchAll(query, {}, function(data)
            result = data
            IsBusy = false
        end)
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

RegisterServerEvent('seu_recurso:enviarDadosVeiculo')
AddEventHandler('seu_recurso:enviarDadosVeiculo', function(vehProps, plate)
    local vehiclesinfo = json.encode(vehProps)
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    })
    if result ~= nil then
        MySQL.Sync.execute('UPDATE owned_vehicles SET vehicle = @vehiclesinfo WHERE plate = @plate', {
            ['@vehiclesinfo'] = vehiclesinfo,
            ['@plate'] = plate
        })
        print("Veículo atualizado na tabela owned_vehicles.")
    else
        print("Plate não encontrada na tabela owned_vehicles.")
    end
    if result ~= nil then
        MySQL.Sync.execute('UPDATE owned_vehicles SET plate = @vehiclesinfo2 WHERE plate = @plate', {
            ['@plate'] = plate,
            ['@vehiclesinfo2'] = vehProps.plate,
        })
    end
end)