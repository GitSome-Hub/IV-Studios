local QBCore = nil
local ESX = nil

-- Framework Detection
if Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qbox' then
    QBCore = exports.qbx_core:GetCoreObject()
end

-- Get Player Data Function
function GetPlayerData(playerId)
    local playerData = {
        id = playerId,
        name = GetPlayerName(playerId),
        job = 'Civilian',
        rank = 'Citizen',
        ping = GetPlayerPing(playerId),
        type = 'player',
        icon = nil
    }

    if Config.Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData then
            local charinfo = Player.PlayerData.charinfo
            playerData.name = charinfo and (charinfo.firstname .. ' ' .. charinfo.lastname) or GetPlayerName(playerId)
            
            if Player.PlayerData.job then
                playerData.job = Player.PlayerData.job.label or 'Unemployed'
                playerData.rank = Player.PlayerData.job.grade and Player.PlayerData.job.grade.name or 'None'
            end
        end
    elseif Config.Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            playerData.name = xPlayer.getName and xPlayer.getName() or GetPlayerName(playerId)
            
            if xPlayer.job then
                playerData.job = xPlayer.job.label or 'Unemployed'
                playerData.rank = xPlayer.job.grade_label or 'None'
            end
        end
    end

    -- Check for admin privileges
    if Config.ShowAdminBadge then
        local playerGroup = GetPlayerGroup(playerId)
        if playerGroup then
            for _, admin in pairs(Config.Admins) do
                if admin.group == playerGroup or 
                   (admin.group == 'admin' and (playerGroup == 'superadmin' or playerGroup == 'admin')) or
                   (admin.group == 'mod' and (playerGroup == 'moderator' or playerGroup == 'mod')) then
                    playerData.type = admin.type
                    playerData.icon = admin.icon
                    break
                end
            end
        end
    end

    return playerData
end

-- Get Player Group Function (works with most admin systems)
function GetPlayerGroup(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    
    -- Try different methods to get player group
    if Config.Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(playerId)
        return Player and Player.PlayerData.metadata and Player.PlayerData.metadata.group or nil
    elseif Config.Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        return xPlayer and xPlayer.getGroup and xPlayer.getGroup() or nil
    end

    -- Fallback: Check common admin resources
    local adminResources = {
        'qb-admin', 'esx_adminmenu', 'admin', 'adminmenu', 'vMenu'
    }
    
    for _, resource in pairs(adminResources) do
        if GetResourceState(resource) == 'started' then
            local success, group = pcall(function()
                return exports[resource]:GetPlayerGroup(playerId)
            end)
            if success and group then
                return group
            end
        end
    end

    -- Try aces system
    for _, admin in pairs(Config.Admins) do
        if IsPlayerAceAllowed(playerId, 'command.' .. admin.group) then
            return admin.group
        end
    end

    return nil
end

-- Calculate Job Statistics
function CalculateJobStats()
    local jobStats = {}
    local players = GetPlayers()

    -- Initialize job counts
    for _, service in pairs(Config.Services) do
        jobStats[service.name] = {
            name = service.name,
            label = service.label,
            icon = service.icon,
            color = service.color,
            iconColor = service.iconColor,
            count = 0
        }
    end

    -- Count players in each job
    for _, playerId in pairs(players) do
        if Config.Framework == 'qb' and QBCore then
            local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
            if Player and Player.PlayerData.job then
                local jobName = Player.PlayerData.job.name
                if jobStats[jobName] then
                    jobStats[jobName].count = jobStats[jobName].count + 1
                end
            end
        elseif Config.Framework == 'esx' and ESX then
            local xPlayer = ESX.GetPlayerFromId(tonumber(playerId))
            if xPlayer and xPlayer.job then
                local jobName = xPlayer.job.name
                if jobStats[jobName] then
                    jobStats[jobName].count = jobStats[jobName].count + 1
                end
            end
        end
    end

    -- Convert to array for frontend
    local jobStatsArray = {}
    for _, job in pairs(jobStats) do
        table.insert(jobStatsArray, job)
    end

    return jobStatsArray
end

-- Generate Fake Players for Testing
function GenerateFakePlayers()
    if not Config.EnableFakePlayers then
        return {}
    end
    
    local fakePlayers = {}
    local fakeNames = {
        'John Smith', 'Maria Garcia', 'David Johnson', 'Sarah Wilson', 'Michael Brown',
        'Jessica Davis', 'Christopher Miller', 'Ashley Martinez', 'Matthew Anderson', 'Amanda Taylor',
        'Daniel Thomas', 'Jennifer Jackson', 'James White', 'Lisa Harris', 'Robert Martin',
        'Michelle Thompson', 'William Garcia', 'Karen Rodriguez', 'Richard Lewis', 'Nancy Lee',
        'Charles Walker', 'Betty Hall', 'Joseph Allen', 'Helen Young', 'Thomas King',
        'Sandra Wright', 'Christopher Lopez', 'Donna Hill', 'Mark Scott', 'Carol Green',
        'Steven Adams', 'Ruth Baker', 'Kenneth Gonzalez', 'Sharon Nelson', 'Paul Carter',
        'Cynthia Mitchell', 'Andrew Perez', 'Angela Roberts', 'Joshua Turner', 'Brenda Phillips',
        'Kevin Campbell', 'Emma Parker', 'Brian Evans', 'Stephanie Edwards', 'George Collins',
        'Rebecca Stewart', 'Edward Sanchez', 'Carolyn Morris', 'Ronald Rogers', 'Janet Reed'
    }
    
    local fakeJobs = {
        {name = 'Civilian', label = 'Civilian', rank = 'Citizen'},
        {name = 'Police', label = 'LSPD Officer', rank = 'Officer'},
        {name = 'Ambulance', label = 'Paramedic', rank = 'EMT'},
        {name = 'Mechanic', label = 'Mechanic', rank = 'Technician'},
        {name = 'Taxi', label = 'Taxi Driver', rank = 'Driver'},
        {name = 'Lawyer', label = 'Lawyer', rank = 'Attorney'},
        {name = 'Realestate', label = 'Real Estate', rank = 'Agent'},
        {name = 'Reporter', label = 'News Reporter', rank = 'Journalist'}
    }
    
    local adminTypes = {'player', 'admin', 'moderator', 'founder'}
    local adminIcons = {
        admin = 'fa-solid fa-shield-halved',
        moderator = 'fa-solid fa-user-secret',
        founder = 'fa-solid fa-crown'
    }
    
    local count = math.min(Config.FakePlayersCount or 25, 50)
    
    for i = 1, count do
        local job = fakeJobs[math.random(#fakeJobs)]
        local adminType = adminTypes[math.random(#adminTypes)]
        local ping = math.random(15, 200)
        
        local fakePlayer = {
            id = 1000 + i,
            name = fakeNames[math.random(#fakeNames)] .. ' #' .. i,
            job = job.label,
            rank = job.rank,
            ping = ping,
            type = adminType,
            icon = adminType ~= 'player' and adminIcons[adminType] or nil
        }
        
        table.insert(fakePlayers, fakePlayer)
    end
    
    return fakePlayers
end

-- Calculate Job Statistics with Fake Players
function CalculateJobStatsWithFakes(realJobStats, fakePlayers)
    if not Config.EnableFakePlayers or not fakePlayers then
        return realJobStats
    end
    
    -- Count fake players by job
    local fakeJobCounts = {}
    for _, fakePlayer in pairs(fakePlayers) do
        local jobName = string.lower(fakePlayer.job:gsub('%s+', ''))
        if jobName:find('lspd') or jobName:find('police') then
            jobName = 'police'
        elseif jobName:find('paramedic') or jobName:find('ambulance') then
            jobName = 'ambulance'
        elseif jobName:find('mechanic') then
            jobName = 'mechanic'
        elseif jobName:find('taxi') then
            jobName = 'taxi'
        end
        
        fakeJobCounts[jobName] = (fakeJobCounts[jobName] or 0) + 1
    end
    
    -- Add fake counts to real job stats
    for _, jobStat in pairs(realJobStats) do
        if fakeJobCounts[jobStat.name] then
            jobStat.count = jobStat.count + fakeJobCounts[jobStat.name]
        end
    end
    
    return realJobStats
end

-- Get All Players Data
function GetAllPlayersData()
    local players = GetPlayers()
    local playersData = {}

    for _, playerId in pairs(players) do
        local playerData = GetPlayerData(tonumber(playerId))
        table.insert(playersData, playerData)
    end

    -- Add fake players if enabled
    if Config.EnableFakePlayers then
        local fakePlayers = GenerateFakePlayers()
        for _, fakePlayer in pairs(fakePlayers) do
            table.insert(playersData, fakePlayer)
        end
    end

    return playersData
end

-- Server Events
RegisterServerEvent('vanguard_scoreboard:requestData')
AddEventHandler('vanguard_scoreboard:requestData', function()
    local src = source
    local players = GetAllPlayersData()
    local realJobStats = CalculateJobStats()
    local fakePlayers = Config.EnableFakePlayers and GenerateFakePlayers() or {}
    local jobStats = CalculateJobStatsWithFakes(realJobStats, fakePlayers)
    
    local maxPlayers = GetConvarInt('sv_maxclients', Config.MaxServerPlayers)
    local realPlayers = #GetPlayers()
    local currentPlayers = realPlayers + (Config.EnableFakePlayers and #fakePlayers or 0)

    local responseData = {
        players = players,
        jobStats = jobStats,
        serverInfo = {
            currentPlayers = currentPlayers,
            maxPlayers = maxPlayers
        }
    }

    TriggerClientEvent('vanguard_scoreboard:updateData', src, responseData)
end)

-- Admin Commands for Testing (remove in production)
if GetConvar('vanguard_debug', 'false') == 'true' then
    RegisterCommand('sb_test_admin', function(source, args, rawCommand)
        local playerId = source
        print('Testing admin detection for player: ' .. playerId)
        print('Player group: ' .. tostring(GetPlayerGroup(playerId)))
        print('Player data: ' .. json.encode(GetPlayerData(playerId)))
    end, false)

    RegisterCommand('sb_test_jobs', function(source, args, rawCommand)
        print('Job statistics: ' .. json.encode(CalculateJobStats()))
    end, false)
end