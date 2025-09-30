--[[
    ================================================================
    == CORE FOCUS :: FRAMEWORK INTEGRATION LAYER
    ================================================================
    Clean, consistent framework abstraction layer
    Supports: QB-Core, ESX, and Standalone modes
    
    Architecture:
    - FrameworkManager: Handles initialization and state
    - PermissionManager: Handles all permission checks
    - DataManager: Handles player data access
    - EventManager: Handles framework events
]]

-- ============================================================
--  CORE STATE MANAGEMENT
-- ============================================================

local FrameworkState = {
    framework = nil,
    playerData = {},
    isReady = false,
    type = Config.Framework or 'standalone'
}

-- ============================================================
--  EVENT MANAGER
-- ============================================================

local EventManager = {}

function EventManager.RegisterQBCoreEvents()
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        FrameworkState.playerData = FrameworkState.framework.Functions.GetPlayerData()
        FrameworkState.isReady = true
        if SpawnPeds then SpawnPeds() end
    end)
    
    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        FrameworkState.playerData = {}
        FrameworkState.isReady = false
        if DeletePeds then DeletePeds() end
    end)
    
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
        FrameworkState.playerData.job = jobInfo
        if _G.Config and _G.Config.Debug then print(("^2[FOCUS] Job updated: %s^7"):format(jobInfo.name or "unknown")) end
    end)
    
    RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gangInfo)
        FrameworkState.playerData.gang = gangInfo
        if _G.Config and _G.Config.Debug then print(("^2[FOCUS] Gang updated: %s^7"):format(gangInfo.name or "unknown")) end
    end)
    
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
        FrameworkState.playerData = playerData
    end)
end

function EventManager.RegisterESXEvents()
    RegisterNetEvent('esx:playerLoaded', function(playerData)
        FrameworkState.playerData = playerData
        FrameworkState.isReady = true
        if SpawnPeds then SpawnPeds() end
    end)
    
    RegisterNetEvent('esx:onPlayerLogout', function()
        FrameworkState.playerData = {}
        FrameworkState.isReady = false
        if DeletePeds then DeletePeds() end
    end)
    
    RegisterNetEvent('esx:setJob', function(job)
        FrameworkState.playerData.job = job
        if _G.Config and _G.Config.Debug then print(("^2[FOCUS] Job updated: %s^7"):format(job.name or "unknown")) end
    end)
end

-- ============================================================
--  FRAMEWORK MANAGER
-- ============================================================

local FrameworkManager = {}

function FrameworkManager.Initialize()
    if _G.Config and _G.Config.Debug then print(("^3[FOCUS] Initializing framework: %s^7"):format(FrameworkState.type)) end
    
    if FrameworkState.type == 'qb-core' then
        FrameworkManager.InitializeQBCore()
    elseif FrameworkState.type == 'esx' then
        FrameworkManager.InitializeESX()
    else
        FrameworkManager.InitializeStandalone()
    end
end

function FrameworkManager.InitializeQBCore()
    local resourceState = GetResourceState(Config.FrameworkResource)
    
    if resourceState == 'missing' then
        print("^1[FOCUS] QB-Core resource not found, falling back to standalone^7")
        return FrameworkManager.InitializeStandalone()
    end
    
    -- Wait for resource to start
    local timeout = 0
    while resourceState ~= 'started' and timeout < 100 do
        timeout = timeout + 1
        resourceState = GetResourceState(Config.FrameworkResource)
        Wait(100)
    end
    
    if resourceState ~= 'started' then
        print("^1[FOCUS] QB-Core failed to start, falling back to standalone^7")
        return FrameworkManager.InitializeStandalone()
    end
    
    -- Initialize QB-Core
    FrameworkState.framework = exports[Config.FrameworkResource]:GetCoreObject()
    FrameworkState.playerData = FrameworkState.framework.Functions.GetPlayerData()
    
    -- Register events
    EventManager.RegisterQBCoreEvents()
    
    FrameworkState.isReady = true
    if _G.Config and _G.Config.Debug then print("^2[FOCUS] QB-Core framework initialized successfully^7") end
end

function FrameworkManager.InitializeESX()
    local resourceState = GetResourceState(Config.FrameworkResource)
    
    if resourceState == 'missing' then
        print("^1[FOCUS] ESX resource not found, falling back to standalone^7")
        return FrameworkManager.InitializeStandalone()
    end
    
    -- Wait for resource to start
    local timeout = 0
    while resourceState ~= 'started' and timeout < 100 do
        timeout = timeout + 1
        resourceState = GetResourceState(Config.FrameworkResource)
        Wait(100)
    end
    
    if resourceState ~= 'started' then
        print("^1[FOCUS] ESX failed to start, falling back to standalone^7")
        return FrameworkManager.InitializeStandalone()
    end
    
    -- Initialize ESX
    if Config.NewFrameworkVersion then
        FrameworkState.framework = exports[Config.FrameworkResource]:getSharedObject()
    else
        TriggerEvent(Config.SharedObject, function(obj) FrameworkState.framework = obj end)
        while FrameworkState.framework == nil do Wait(100) end
    end
    
    -- Wait for player data
    while FrameworkState.framework.GetPlayerData().job == nil do Wait(100) end
    FrameworkState.playerData = FrameworkState.framework.GetPlayerData()
    
    -- Register events
    EventManager.RegisterESXEvents()
    
    FrameworkState.isReady = true
    if _G.Config and _G.Config.Debug then print("^2[FOCUS] ESX framework initialized successfully^7") end
end

function FrameworkManager.InitializeStandalone()
    FrameworkState.type = 'standalone'
    
    -- Handle first spawn
    local firstSpawn = false
    local spawnHandler = AddEventHandler('playerSpawned', function()
        if not firstSpawn then
            firstSpawn = true
            FrameworkState.isReady = true
            if SpawnPeds then SpawnPeds() end
            if _G.Config and _G.Config.Debug then print("^2[FOCUS] Standalone mode initialized^7") end
            RemoveEventHandler(spawnHandler)
        end
    end)
end



-- ============================================================
--  DATA MANAGER
-- ============================================================

local DataManager = {}

function DataManager.GetFramework()
    return FrameworkState.framework
end

function DataManager.GetPlayerData()
    return FrameworkState.playerData
end

function DataManager.IsReady()
    return FrameworkState.isReady
end

function DataManager.GetFrameworkType()
    return FrameworkState.type
end

-- ============================================================
--  PERMISSION MANAGER
-- ============================================================

local PermissionManager = {}

function PermissionManager.CheckJob(jobRequirement)
    if not jobRequirement then return true end
    if FrameworkState.type == 'standalone' then return true end
    
    local playerJob = FrameworkState.playerData.job
    if not playerJob then return false end
    
    if type(jobRequirement) == 'string' then
        return jobRequirement == 'all' or jobRequirement == playerJob.name
    elseif type(jobRequirement) == 'table' then
        local requiredGrade = jobRequirement[playerJob.name]
        if not requiredGrade then return false end
        
        local playerGrade = FrameworkState.type == 'qb-core' and playerJob.grade.level or playerJob.grade
        return playerGrade >= requiredGrade
    end
    
    return false
end

function PermissionManager.CheckGang(gangRequirement)
    if not gangRequirement then return true end
    if FrameworkState.type ~= 'qb-core' then return gangRequirement == 'all' end
    
    local playerGang = FrameworkState.playerData.gang
    if not playerGang then return false end
    
    if type(gangRequirement) == 'string' then
        return gangRequirement == 'all' or gangRequirement == playerGang.name
    elseif type(gangRequirement) == 'table' then
        local requiredGrade = gangRequirement[playerGang.name]
        if not requiredGrade then return false end
        
        return playerGang.grade.level >= requiredGrade
    end
    
    return false
end

function PermissionManager.CheckItem(itemRequirement)
    if not itemRequirement then return true end
    if FrameworkState.type == 'standalone' then return true end
    
    if FrameworkState.type == 'qb-core' then
        if type(itemRequirement) == 'string' then
            return FrameworkState.framework.Functions.HasItem(itemRequirement)
        elseif type(itemRequirement) == 'table' then
            for _, item in pairs(itemRequirement) do
                if FrameworkState.framework.Functions.HasItem(item) then
                    return true
                end
            end
        end
    elseif FrameworkState.type == 'esx' then
        if type(itemRequirement) == 'string' then
            local count = FrameworkState.framework.SearchInventory(itemRequirement, 1)
            return count and count >= 1
        elseif type(itemRequirement) == 'table' then
            for _, item in pairs(itemRequirement) do
                local count = FrameworkState.framework.SearchInventory(item, 1)
                if count and count >= 1 then
                    return true
                end
            end
        end
    end
    
    return false
end

function PermissionManager.CheckCitizenId(citizenRequirement)
    if not citizenRequirement then return true end
    if FrameworkState.type == 'standalone' then return true end
    
    local citizenId = FrameworkState.type == 'qb-core' and FrameworkState.playerData.citizenid or FrameworkState.playerData.identifier
    if not citizenId then return false end
    
    if type(citizenRequirement) == 'string' then
        return citizenRequirement == citizenId
    elseif type(citizenRequirement) == 'table' then
        return citizenRequirement[citizenId] ~= nil
    end
    
    return false
end

-- Enhanced ox_target compatibility functions
function PermissionManager.CheckGroups(groups)
    if not groups then return true end
    if type(groups) == 'string' then groups = { groups } end
    
    for group, grade in pairs(groups) do
        if PermissionManager.CheckJob({ [group] = grade }) or PermissionManager.CheckGang({ [group] = grade }) then
            return true
        end
    end
    
    return false
end

function PermissionManager.CheckItems(items, anyItem)
    if not items then return true end
    if FrameworkState.type == 'standalone' then return true end

    if type(items) == 'string' then
        items = {[items] = 1}
    end

    local hasItems = 0
    local totalItems = 0

    for key, value in pairs(items) do
        totalItems = totalItems + 1
        local hasItem = false

        local itemName
        local requiredCount

        if type(key) == 'number' and type(value) == 'string' then
            itemName = value
            requiredCount = 1 
        else
            itemName = key
            requiredCount = value
        end

        if FrameworkState.type == 'qb-core' then
            local checkCount = (type(requiredCount) == 'number' and requiredCount or 1)
            hasItem = FrameworkState.framework.Functions.HasItem(itemName, checkCount)

        elseif FrameworkState.type == 'esx' then
            local checkCount = (type(requiredCount) == 'number' and requiredCount or 1)
            if GetResourceState('ox_inventory') == 'started' then
                local count = exports.ox_inventory:Search('count', itemName)
                hasItem = count and count >= 1
            elseif GetResourceState('core_inventory') == 'started' then
                hasItem = exports.core_inventory:hasItem(itemName, checkCount)
            end
            -- Add different inventory checks
        end

        if hasItem then hasItems = hasItems + 1 end
    end

    return anyItem and hasItems > 0 or hasItems == totalItems
end

exports('CheckGroups', function(groups)
  return PermissionManager.CheckGroups(groups)
end)

exports('CheckItems', function(items, anyItem)
    return PermissionManager.CheckItems(items, anyItem)
end)

-- ============================================================
--  MAIN OPTION CHECKER
-- ============================================================

function CheckOptions(data, entity, distance)
    -- Distance check
    if distance and data.distance and distance > data.distance then return false end
    
    -- Job checks
    if data.job and not PermissionManager.CheckJob(data.job) then return false end
    if data.excludejob and PermissionManager.CheckJob(data.excludejob) then return false end
    
    -- Gang checks
    if data.gang and not PermissionManager.CheckGang(data.gang) then return false end
    if data.excludegang and PermissionManager.CheckGang(data.excludegang) then return false end
    
    -- Item checks
    if data.item and not PermissionManager.CheckItem(data.item) then return false end
    
    -- Citizen ID checks
    if data.citizenid and not PermissionManager.CheckCitizenId(data.citizenid) then return false end
    
    -- Custom interaction check
    if data.canInteract and not data.canInteract(entity, distance, data) then return false end
    
    return true
end

-- ============================================================
--  UTILITY FUNCTIONS
-- ============================================================

function Load(name)
    local resourceName = GetCurrentResourceName()
    local chunk = LoadResourceFile(resourceName, ('data/%s.lua'):format(name))
    if chunk then
        local err
        chunk, err = load(chunk, ('@@%s/data/%s.lua'):format(resourceName, name), 't')
        if err then
            error(('\n^1 %s'):format(err), 0)
        end
        return chunk()
    end
end

-- ============================================================
--  INITIALIZATION
-- ============================================================

CreateThread(function()
    FrameworkManager.Initialize()
end)

