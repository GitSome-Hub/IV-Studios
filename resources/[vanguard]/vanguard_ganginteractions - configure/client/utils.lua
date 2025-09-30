-- Utility functions shared across modules
local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function playAnimation(ped, dict, anim, flag)
    loadAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, flag, 0, false, false, false)
end

local function getClosestPlayer(radius)
    local players = ESX.Game.GetPlayers()
    local closestDistance = radius or -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

-- Export the utility functions
exports('loadAnimDict', loadAnimDict)
exports('playAnimation', playAnimation)
exports('getClosestPlayer', getClosestPlayer)

-- Utility functions for animations
local function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function PlayAnimation(ped, dict, anim, flag)
    LoadAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, flag, 0, false, false, false)
end

-- Utility function to disable specific controls
local function DisableActions(controls)
    for _, control in ipairs(controls) do
        DisableControlAction(0, control, true)
    end
end

-- Export the functions
exports('LoadAnimDict', LoadAnimDict)
exports('PlayAnimation', PlayAnimation)
exports('DisableActions', DisableActions)

return {
    LoadAnimDict = LoadAnimDict,
    PlayAnimation = PlayAnimation,
    DisableActions = DisableActions
}