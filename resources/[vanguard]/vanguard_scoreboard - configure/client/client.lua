local QBCore, ESX = nil, nil
local isScoreboardOpen = false
local refreshThread = nil

-- Framework detection
Citizen.CreateThread(function()
    if Config.Framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    elseif Config.Framework == 'qbox' then
        QBCore = exports.qbx_core:GetCoreObject()
    end
end)

-- Command & Keymapping
RegisterCommand(Config.ScoreboardCommand, function() ToggleScoreboard() end, false)
if Config.RegisterKeyMapping then
    RegisterKeyMapping(Config.ScoreboardCommand, 'Open Scoreboard', 'keyboard', Config.OpenScoreboardKey)
end

-- Toggle scoreboard
function ToggleScoreboard()
    if isScoreboardOpen then CloseScoreboard() else OpenScoreboard() end
end

-- Open scoreboard
function OpenScoreboard()
    if isScoreboardOpen then return end
    isScoreboardOpen = true

    TriggerServerEvent('vanguard_scoreboard:requestData')
    Citizen.Wait(100)

    SendNUIMessage({
        action = 'show',
        config = {
            scoreboardType = Config.ScoreboardType,
            scoreboardTitle = Config.ScoreboardTitle or GetLocale('scoreboard_title'),
            scoreboardSubtitle = Config.ScoreboardSubtitle or 'Vanguard Labs',
            showPlayerIds = Config.ShowPlayerIds,
            showPlayerPing = Config.ShowPlayerPing,
            showPlayerJob = Config.ShowPlayerJob,
            maxPlayers = Config.MaxServerPlayers
        },
        locales = {
            exit = GetLocale('exit'),
            players_online = GetLocale('players_online'),
            player_name = GetLocale('player_name'),
            job = GetLocale('job'),
            rank = GetLocale('rank'),
            ping = GetLocale('ping')
        }
    })

    -- Removido SetNuiFocus para ambos os modos - sem cursor
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    StartRefreshTimer()
end

-- Close scoreboard
function CloseScoreboard()
    if not isScoreboardOpen then return end
    isScoreboardOpen = false

    SendNUIMessage({ action = 'hide' })
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    StopRefreshTimer()
end

-- Refresh Timer
function StartRefreshTimer()
    if refreshThread then return end
    refreshThread = true
    Citizen.CreateThread(function()
        while refreshThread and isScoreboardOpen do
            Citizen.Wait(Config.RefreshInterval or 10000)
            if isScoreboardOpen then TriggerServerEvent('vanguard_scoreboard:requestData') end
        end
        refreshThread = nil
    end)
end

function StopRefreshTimer()
    refreshThread = false
end

-- Update scoreboard data
function UpdateScoreboardData(data)
    if isScoreboardOpen then
        SendNUIMessage({ action = 'updateData', data = data })
    end
end

RegisterNUICallback('requestData', function(data, cb)
    TriggerServerEvent('vanguard_scoreboard:requestData')
    cb('ok')
end)

RegisterNUICallback('requestConfig', function(data, cb)
    SendNUIMessage({
        action = 'setConfig',
        config = {
            scoreboardType = Config.ScoreboardType,
            scoreboardTitle = Config.ScoreboardTitle or GetLocale('scoreboard_title'),
            scoreboardSubtitle = Config.ScoreboardSubtitle or 'Vanguard Labs',
            showPlayerIds = Config.ShowPlayerIds,
            showPlayerPing = Config.ShowPlayerPing,
            showPlayerJob = Config.ShowPlayerJob,
            maxPlayers = Config.MaxServerPlayers
        },
        locales = {
            exit = GetLocale('exit'),
            players_online = GetLocale('players_online'),
            player_name = GetLocale('player_name'),
            job = GetLocale('job'),
            rank = GetLocale('rank'),
            ping = GetLocale('ping')
        }
    })
    cb('ok')
end)

-- Server updates
RegisterNetEvent('vanguard_scoreboard:updateData', function(data)
    UpdateScoreboardData(data)
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        isScoreboardOpen = false
        StopRefreshTimer()
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        isScoreboardOpen = false
    end
end)

-- Exports
exports('OpenScoreboard', OpenScoreboard)
exports('CloseScoreboard', CloseScoreboard)
exports('ToggleScoreboard', ToggleScoreboard)
exports('IsScoreboardOpen', function() return isScoreboardOpen end)