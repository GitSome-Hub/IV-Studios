-- ============================================================
--  ADMIN INTERACTIONS MODULE
-- ============================================================
-- This module provides admin-only interactions for player management
-- Includes ban, kick, freeze, and unfreeze functionality

-- Module configuration
local ModuleEnabled = true

-- Don't run if module is disabled
if not ModuleEnabled then
    return
end

-- Configuration
local Config = {
    MaxDistance = 5.0,      -- Maximum distance to show interactions (meters)
    ForceColor = "#FF0000", -- Force color for admin interactions (red)
    AdminGroups = {         -- Admin groups that can use these interactions
        "admin",
        "superadmin", 
        "owner",
        "god"
    }
}

-- Freeze state management
local isFrozen = false

-- Admin interactions configuration
local AdminInteractions = {
    {
        label = "Ban Player",
        icon = "fas fa-ban",
        action = function(data)
            local targetPed = data
            local targetPlayerId = NetworkGetPlayerIndexFromPed(targetPed)
            local targetServerId = GetPlayerServerId(targetPlayerId)
            
            -- Trigger server event for ban
            TriggerServerEvent('admin:banPlayer', targetServerId)
            if _G.Config and _G.Config.Debug then
                print("^1[Admin]^7 Banned player: " .. targetServerId)
            end
        end,
        canInteract = function(entity, distance, data)
            -- Check if targeting self
            if entity == PlayerPedId() then return false end
            -- Check if player has admin permissions
            return CheckOptions({ job = Config.AdminGroups }, entity, distance)
        end
    },
    {
        label = "Kick Player",
        icon = "fas fa-door-open",
        action = function(data)
            local targetPed = data
            local targetPlayerId = NetworkGetPlayerIndexFromPed(targetPed)
            local targetServerId = GetPlayerServerId(targetPlayerId)
            
            -- Trigger server event for kick
            TriggerServerEvent('admin:kickPlayer', targetServerId)
            if _G.Config and _G.Config.Debug then
                print("^3[Admin]^7 Kicked player: " .. targetServerId)
            end
        end,
        canInteract = function(entity, distance, data)
            -- Check if targeting self
            if entity == PlayerPedId() then return false end
            -- Check if player has admin permissions
            return CheckOptions({ job = Config.AdminGroups }, entity, distance)
        end
    },
    {
        label = "Freeze Player",
        icon = "fas fa-snowflake",
        action = function(data)
            local targetPed = data
            local targetPlayerId = NetworkGetPlayerIndexFromPed(targetPed)
            local targetServerId = GetPlayerServerId(targetPlayerId)
            
            -- Trigger server event for freeze
            TriggerServerEvent('admin:freezePlayer', targetServerId)
            if _G.Config and _G.Config.Debug then
                print("^4[Admin]^7 Froze player: " .. targetServerId)
            end
        end,
        canInteract = function(entity, distance, data)
            -- Check if targeting self
            if entity == PlayerPedId() then return false end
            -- Check if player has admin permissions
            return CheckOptions({ job = Config.AdminGroups }, entity, distance)
        end
    },
    {
        label = "Unfreeze Player",
        icon = "fas fa-fire",
        action = function(data)
            local targetPed = data
            local targetPlayerId = NetworkGetPlayerIndexFromPed(targetPed)
            local targetServerId = GetPlayerServerId(targetPlayerId)
            
            -- Trigger server event for unfreeze
            TriggerServerEvent('admin:unfreezePlayer', targetServerId)
            if _G.Config and _G.Config.Debug then
                print("^2[Admin]^7 Unfroze player: " .. targetServerId)
            end
        end,
        canInteract = function(entity, distance, data)
            -- Check if targeting self
            if entity == PlayerPedId() then return false end
            -- Check if player has admin permissions
            return CheckOptions({ job = Config.AdminGroups }, entity, distance)
        end
    }
}

-- Handle freeze/unfreeze from server
RegisterNetEvent('admin:freezePlayer', function(freeze)
    local playerPed = PlayerPedId()
    isFrozen = freeze
    
    if freeze then
        -- Freeze the player
        FreezeEntityPosition(playerPed, true)
        SetPlayerControl(PlayerId(), false, 0)
        if _G.Config and _G.Config.Debug then
            print("^4[Admin]^7 You have been frozen")
        end
    else
        -- Unfreeze the player
        FreezeEntityPosition(playerPed, false)
        SetPlayerControl(PlayerId(), true, 0)
        if _G.Config and _G.Config.Debug then
            print("^2[Admin]^7 You have been unfrozen")
        end
    end
end)

-- Create combined options table for admin actions
local function CreateAdminOptions()
    return AdminInteractions
end

-- Initialize admin interactions
CreateThread(function()
    Wait(1000) -- Wait for targeting system to load
    
    -- Create the admin options
    local adminOptions = CreateAdminOptions()
    
    -- Add global player targeting with admin interactions (force separate)
    exports[GetCurrentResourceName()]:AddGlobalPlayer({
        options = adminOptions,
        distance = Config.MaxDistance,
        forceColor = Config.ForceColor
    }, "admin_actions") -- Separate identifier for admin actions
    
    if _G.Config and _G.Config.Debug then
        print("^1[Admin Interactions]^7 Module loaded with " .. #adminOptions .. " admin interactions")
    end
end)

