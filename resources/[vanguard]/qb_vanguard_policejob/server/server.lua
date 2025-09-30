local QBCore = exports['qb-core']:GetCoreObject()

local cuffedPlayers = {}

CreateThread(function()
    -- If needed, register police job with QB-Core
    for i=1, #Config.policeJobs do
        print('[vanguard_policejob] Job registered: ' .. Config.policeJobs[i])
    end
end)

-- Clean up cuffed players when they disconnect
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    if cuffedPlayers[playerId] then
        cuffedPlayers[playerId] = nil
    end
end)

RegisterServerEvent('vanguard_policejob:attemptTackle')
AddEventHandler('vanguard_policejob:attemptTackle', function(targetId)
    TriggerClientEvent('vanguard_policejob:tackled', targetId, source)
    TriggerClientEvent('vanguard_policejob:tackle', source)
end)

RegisterServerEvent('vanguard_policejob:escortPlayer')
AddEventHandler('vanguard_policejob:escortPlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasJob
    for i=1, #Config.policeJobs do
        if Player.PlayerData.job.name == Config.policeJobs[i] then
            hasJob = Player.PlayerData.job.name
            break
        end
    end
    if hasJob then
        TriggerClientEvent('vanguard_policejob:setEscort', src, targetId)
        TriggerClientEvent('vanguard_policejob:escortedPlayer', targetId, src)
    end
end)

RegisterServerEvent('vanguard_policejob:inVehiclePlayer')
AddEventHandler('vanguard_policejob:inVehiclePlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasJob
    for i=1, #Config.policeJobs do
        if Player.PlayerData.job.name == Config.policeJobs[i] then
            hasJob = Player.PlayerData.job.name
            break
        end
    end
    if hasJob then
        TriggerClientEvent('vanguard_policejob:stopEscorting', src)
        TriggerClientEvent('vanguard_policejob:putInVehicle', targetId)
    end
end)

RegisterServerEvent('vanguard_policejob:outVehiclePlayer')
AddEventHandler('vanguard_policejob:outVehiclePlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasJob
    for i=1, #Config.policeJobs do
        if Player.PlayerData.job.name == Config.policeJobs[i] then
            hasJob = Player.PlayerData.job.name
            break
        end
    end
    if hasJob then
        TriggerClientEvent('vanguard_policejob:takeFromVehicle', targetId)
    end
end)

RegisterServerEvent('vanguard_policejob:setCuff')
AddEventHandler('vanguard_policejob:setCuff', function(isCuffed)
    cuffedPlayers[source] = isCuffed
end)

RegisterServerEvent('vanguard_policejob:handcuffPlayer')
AddEventHandler('vanguard_policejob:handcuffPlayer', function(target)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasJob
    for i=1, #Config.policeJobs do
        if Player.PlayerData.job.name == Config.policeJobs[i] then
            hasJob = Player.PlayerData.job.name
            break
        end
    end
    if hasJob then
        if cuffedPlayers[target] then
            TriggerClientEvent('vanguard_policejob:uncuffAnim', src, target)
            Wait(4000)
            TriggerClientEvent('vanguard_policejob:uncuff', target)
        else
            TriggerClientEvent('vanguard_policejob:arrested', target, src)
            TriggerClientEvent('vanguard_policejob:arrest', src)
        end
    end
end)

local function getPoliceOnline()
    local players = QBCore.Functions.GetPlayers()
    local count = 0
    for i = 1, #players do
        local Player = QBCore.Functions.GetPlayer(players[i])
        for j = 1, #Config.policeJobs do
            if Player.PlayerData.job.name == Config.policeJobs[j] and Player.PlayerData.job.onduty then
                count = count + 1
            end
        end
    end
    return count
end

exports('getPoliceOnline', getPoliceOnline)

QBCore.Functions.CreateCallback('vanguard_policejob:getJobLabel', function(source, cb, job)
    cb(QBCore.Shared.Jobs[job].label or Strings.police)
end)

QBCore.Functions.CreateCallback('vanguard_policejob:isCuffed', function(source, cb, target)
    cb(cuffedPlayers[target] or false)
end)

QBCore.Functions.CreateCallback('vanguard_policejob:getVehicleOwner', function(source, cb, plate)
    local result = MySQL.Sync.fetchAll('SELECT citizenid FROM player_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    })
    
    if result[1] then
        local citizenid = result[1].citizenid
        local result2 = MySQL.Sync.fetchAll('SELECT charinfo FROM players WHERE citizenid = @citizenid', {
            ['@citizenid'] = citizenid
        })
        
        if result2[1] then
            local charinfo = json.decode(result2[1].charinfo)
            cb(charinfo.firstname .. ' ' .. charinfo.lastname)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('vanguard_policejob:canPurchase', function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local itemData
    
    if data.grade > #Config.Locations[data.id].armoury.weapons then
        itemData = Config.Locations[data.id].armoury.weapons[#Config.Locations[data.id].armoury.weapons][data.itemId]
    elseif not Config.Locations[data.id].armoury.weapons[data.grade] then
        print('[vanguard_policejob] : Armory not set up properly for job grade: ' .. data.grade)
        return
    else
        itemData = Config.Locations[data.id].armoury.weapons[data.grade][data.itemId]
    end
    
    if not itemData.price then
        if string.sub(data.itemId, 1, 7) == 'WEAPON_' and not Config.weaponsAsItems then
            Player.Functions.AddItem(data.itemId, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.itemId], 'add')
        else
            Player.Functions.AddItem(data.itemId, data.quantity)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.itemId], 'add')
        end
        cb(true)
    else
        local bankBalance = Player.PlayerData.money["bank"]
        if bankBalance < itemData.price then
            cb(false)
        else
            Player.Functions.RemoveMoney('bank', itemData.price, "police-equipment-purchase")
            if string.sub(data.itemId, 1, 7) == 'WEAPON_' and not Config.weaponsAsItems then
                Player.Functions.AddItem(data.itemId, 1)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.itemId], 'add')
            else
                Player.Functions.AddItem(data.itemId, data.quantity)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.itemId], 'add')
            end
            cb(true)
        end
    end
end)

-- Player ID check callback
QBCore.Functions.CreateCallback('vanguard_policejob:checkPlayerId', function(source, cb, targetId)
    local Player = QBCore.Functions.GetPlayer(targetId)
    if not Player then return cb({}) end
    
    local PlayerData = Player.PlayerData
    local charInfo = PlayerData.charinfo
    
    local data = {
        name = charInfo.firstname .. ' ' .. charInfo.lastname,
        job = QBCore.Shared.Jobs[PlayerData.job.name].label,
        position = PlayerData.job.grade.name,
        dob = charInfo.birthdate,
        sex = charInfo.gender == 0 and 'Male' or 'Female'
    }
    
    -- Check for licenses
    local licenses = {}
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_licenses WHERE citizenid = @citizenid', {
        ['@citizenid'] = PlayerData.citizenid
    })
    
    if result and #result > 0 then
        for i=1, #result do
            table.insert(licenses, {
                type = result[i].type,
                label = QBCore.Shared.Licenses[result[i].type].label
            })
        end
    end
    
    data.licenses = licenses
    cb(data)
end)

RegisterServerEvent("QBCore:ToggleDuty", function(duty, jobConfig)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if duty then
        Player.Functions.SetJobDuty(true)
        Player.Functions.SetJob(jobConfig.ClockedInJob, Player.PlayerData.job.grade.level)
        TriggerClientEvent('QBCore:Notify', src, "You are now on duty!")
    else
        Player.Functions.SetJobDuty(false)
        Player.Functions.SetJob(jobConfig.ClockedOutJob, Player.PlayerData.job.grade.level)
        TriggerClientEvent('QBCore:Notify', src, "You are now off duty!")
    end
end)

syncedRopes = {}

RegisterNetEvent("obWeaponLanyard:createlanyard")
AddEventHandler("obWeaponLanyard:createlanyard", function()
    TriggerClientEvent("obWeaponLanyard:createlanyard", -1, source)
end)

RegisterNetEvent("obWeaponLanyard:removelanyard")
AddEventHandler("obWeaponLanyard:removelanyard", function()
    TriggerClientEvent("obWeaponLanyard:removelanyard", -1, source)
end)

RegisterServerEvent('VanguardLabsPeds:sendData')
AddEventHandler('VanguardLabsPeds:sendData', function(Nome, Telefone, Grau, Descricao)
    local webhookUrl = Config['VanguardPeds']['discord']['webhookUrl']
    local roleId = Config['VanguardPeds']['discord']['roleId']
    local playerId = source

    sendToDiscord(Nome, Telefone, Grau, Descricao, playerId, roleId, webhookUrl)
end)

function sendToDiscord(name, number, grade, description, playerId, roleId, webhookUrl)
    local discordData = {
        ["username"] = "Police Department",
        ["avatar_url"] = "https://i.imgur.com/BuKIMkc.png",
        ["content"] = "<@&" .. roleId .. ">",
        ["embeds"] = {{
            ["title"] = "Police Department",
            ["color"] = 3447003,
            ["thumbnail"] = {
                ["url"] = "https://i.imgur.com/BuKIMkc.png"
            },
            ["fields"] = {
                {
                    ["name"] = "Name:",
                    ["value"] = name or "N/A",
                    ["inline"] = false
                },
                {
                    ["name"] = "Phone Number:",
                    ["value"] = number or "N/A",
                    ["inline"] = false
                },
                {
                    ["name"] = "Service Level:",  
                    ["value"] = grade or "N/A",        
                    ["inline"] = false
                },
                {
                    ["name"] = "Description:",
                    ["value"] = description or "N/A",
                    ["inline"] = false
                },
                {
                    ["name"] = "Player ID:",
                    ["value"] = tostring(playerId),
                    ["inline"] = false
                }
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["footer"] = {
                ["text"] = "Vanguard Labs | Police Department",
                ["icon_url"] = "https://i.imgur.com/BuKIMkc.png"
            }
        }}
    }

    PerformHttpRequest(webhookUrl, function(statusCode, response, headers)
        if statusCode == 204 then
            print("Message sent successfully to Discord!")
        else
            print("Error sending message to Discord. Status code: " .. tostring(statusCode))
        end
    end, "POST", json.encode(discordData), {["Content-Type"] = "application/json"})
end