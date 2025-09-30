-- ============================================================
--  BONES MODULE
-- ============================================================
-- This module adds bone-based interactions to vehicles and peds
-- Players can interact with specific bones for doors, hood, trunk, etc.

-- Module configuration
local ModuleEnabled = true

-- Don't run if module is disabled
if not ModuleEnabled then
    return
end

-- Configuration
local Config = {
    MaxDistance = 3.0,      -- Maximum distance to interact with bones (meters)
    ForceColor = "#42f554", -- Force color for bone interactions (green)
    AdminGroups = {         -- Admin groups that can use admin interactions
        "admin",
        "superadmin", 
        "owner",
        "god"
    }
}

Bones = {
    -- Options will be populated below, ensuring the new merged/separate structure
    Options = {},
    Vehicle = {
        'chassis', 'windscreen', 'seat_pside_r', 'seat_dside_r', 'bodyshell', 'suspension_lm',
        'suspension_lr', 'platelight', 'attach_female', 'attach_male', 'bonnet', 'boot',
        'chassis_dummy', 'chassis_Control', 'door_dside_f', 'door_dside_r', 'door_pside_f',
        'door_pside_r', 'Gun_GripR', 'windscreen_f', 'VFX_Emitter', 'window_lf', -- Removed duplicate 'platelight'
        'window_lr', 'window_rf', 'window_rr', 'engine', 'gun_ammo', 'ROPE_ATTATCH',
        'wheel_lf', 'wheel_lr', 'wheel_rf', 'wheel_rr', 'exhaust', 'overheat',
        'seat_dside_f', 'seat_pside_f', 'Gun_Nuzzle', 'seat_r'
    },
    Ped = { -- Example standard ped bones you might want to list for easy reference
        'SKEL_Head', 'SKEL_Neck_1', 'SKEL_Pelvis', 'SKEL_L_Hand', 'SKEL_R_Hand', 'SKEL_L_Foot', 'SKEL_R_Foot'
    }
}

-- Initialize bone interactions if module is enabled
if ModuleEnabled then
    local BackEngineVehicles = {
        [`ninef`] = true, [`adder`] = true, [`vagner`] = true, [`t20`] = true, [`infernus`] = true,
        [`zentorno`] = true, [`reaper`] = true, [`comet2`] = true, [`comet3`] = true, [`jester`] = true,
        [`jester2`] = true, [`cheetah`] = true, [`cheetah2`] = true, [`prototipo`] = true, [`turismor`] = true,
        [`pfister811`] = true, [`ardent`] = true, [`nero`] = true, [`nero2`] = true, [`tempesta`] = true,
        [`vacca`] = true, [`bullet`] = true, [`osiris`] = true, [`entityxf`] = true, [`turismo2`] = true,
        [`fmj`] = true, [`re7b`] = true, [`tyrus`] = true, [`italigtb`] = true, [`penetrator`] = true,
        [`monroe`] = true, [`ninef2`] = true, [`stingergt`] = true, [`surfer`] = true, [`surfer2`] = true,
        [`gp1`] = true, [`autarch`] = true, [`tyrant`] = true
    }

    local function ToggleDoor(vehicle, door)
        if GetVehicleDoorLockStatus(vehicle) ~= 2 then -- 2 means locked/cannot be opened by player
            if GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
                SetVehicleDoorShut(vehicle, door, false)
            else
                -- Open door, non-violently, and don't let it auto-close immediately for player
                SetVehicleDoorOpen(vehicle, door, false, false)
            end
        end
    end

    -- Define default options for the 'windscreen' bone
    -- All these options will be part of a single "merged" dot for the 'windscreen'.
    Bones.Options['windscreen'] = {
        merged = {
            options = {
                -- Option keys should be unique within this 'options' table.
                ["Toggle Left Front Door"] = {
                    icon = "fas fa-door-open",
                    label = "Left Front Door",
                    canInteract = function(entity)
                        return GetEntityBoneIndexByName(entity, 'door_dside_f') ~= -1
                    end,
                    action = function(entity)
                        ToggleDoor(entity, 0) -- Door index 0: Front Left
                    end,
                    distance = 3.0 -- Option-specific distance (radial menu will appear if player is within group distance)
                },
                ["Toggle Right Front Door"] = {
                    icon = "fas fa-door-open",
                    label = "Right Front Door",
                    canInteract = function(entity)
                        return GetEntityBoneIndexByName(entity, 'door_pside_f') ~= -1
                    end,
                    action = function(entity)
                        ToggleDoor(entity, 1) -- Door index 1: Front Right
                    end,
                    distance = 3.0
                },
                ["Toggle Hood"] = {
                    icon = "fa-solid fa-car-side", -- Using a more common Font Awesome icon
                    label = "Toggle Hood",
                    action = function(entity)
                        local modelHash = GetEntityModel(entity)
                        local modelName = GetDisplayNameFromVehicleModel(modelHash) -- Get model name string
                        ToggleDoor(entity, BackEngineVehicles[modelName:lower()] and 5 or 4) -- Hood is 4, Trunk is 5. If engine at back, hood is 5.
                    end,
                    distance = 3.0
                },
                ["Toggle Trunk"] = {
                    icon = "fa-solid fa-suitcase", -- Using a more common Font Awesome icon
                    label = "Toggle Trunk",
                    action = function(entity)
                        local modelHash = GetEntityModel(entity)
                        local modelName = GetDisplayNameFromVehicleModel(modelHash) -- Get model name string
                        ToggleDoor(entity, BackEngineVehicles[modelName:lower()] and 4 or 5) -- Trunk is 5. If engine at back, trunk is 4.
                    end,
                    distance = 3.0
                },
                
            },
            -- The distance for the "merged" group. The dot will appear if the player is within this range.
            -- This should generally be the distance of the "closest" interaction you want to allow for this group.
            -- Or a general interaction distance for the bone. Let's use 3.0 as it covers hood/trunk.
            distance = Config.MaxDistance
        },
        separate = {

            ['admin'] = { -- Example of a separate option for admins
                options = {

                    ["AdminDelete"] = {
                        icon = "fas fa-trash",
                        label = "Delete Vehicle",
                        canInteract = function(entity, distance, data)
                            -- Check if player has admin permissions
                            return CheckOptions({ job = Config.AdminGroups }, entity, distance)
                        end,
                        action = function(entity)
                            if IsEntityAVehicle(entity) then
                                DeleteEntity(entity)
                                if _G.Config and _G.Config.Debug then
                                    print("^1[Bones Admin]^7 Deleted vehicle: " .. entity)
                                end
                            end
                        end,
                        distance = Config.MaxDistance
                    },
                    ["AdminRepair"] = {
                        icon = "fas fa-wrench",
                        label = "Repair Vehicle",
                        canInteract = function(entity, distance, data)
                            -- Check if player has admin permissions and entity is a vehicle
                            return IsEntityAVehicle(entity) and CheckOptions({ job = Config.AdminGroups }, entity, distance)
                        end,
                        action = function(entity)
                            if IsEntityAVehicle(entity) then
                                SetVehicleFixed(entity)
                                SetVehicleDeformationFixed(entity)
                                SetVehicleUndriveable(entity, false)
                                if _G.Config and _G.Config.Debug then
                                    print("^2[Bones Admin]^7 Repaired vehicle: " .. entity)
                                end
                            end
                        end,
                        distance = Config.MaxDistance
                    },
                    ["AdminFlip"] = {
                        icon = "fas fa-undo",
                        label = "Flip Vehicle",
                        canInteract = function(entity, distance, data)
                            -- Check if player has admin permissions and entity is a vehicle
                            return IsEntityAVehicle(entity) and CheckOptions({ job = Config.AdminGroups }, entity, distance)
                        end,
                        action = function(entity)
                            if IsEntityAVehicle(entity) then
                                local coords = GetEntityCoords(entity)
                                local heading = GetEntityHeading(entity)
                                SetEntityCoords(entity, coords.x, coords.y, coords.z + 1.0, false, false, false, true)
                                SetEntityRotation(entity, 0.0, 0.0, heading, 2, true)
                                if _G.Config and _G.Config.Debug then
                                    print("^2[Bones Admin]^7 Flipped vehicle: " .. entity)
                                end
                            end
                        end,
                        distance = Config.MaxDistance
                    }

                   
                },
                distance = Config.MaxDistance, -- Distance for admin options
                forceColor = '#ff0000', -- Example of a forced color for admin options
            }

        } -- Initialize separate options as empty for this bone by default
    }

    Bones.Options['SKEL_Pelvis'] = {
        merged = {
            options = {
                -- Option keys should be unique within this 'options' table.
                ["Toggle Left Front Door"] = {
                    icon = "fas fa-door-open",
                    label = "Left Front Door",
                    canInteract = function(entity)
                        return GetEntityBoneIndexByName(entity, 'door_dside_f') ~= -1
                    end,
                    action = function(entity)
                        ToggleDoor(entity, 0) -- Door index 0: Front Left
                    end,
                    distance = Config.MaxDistance -- Option-specific distance (radial menu will appear if player is within group distance)
                },
                ["Toggle Right Front Door"] = {
                    icon = "fas fa-door-open",
                    label = "Right Front Door",
                    canInteract = function(entity)
                        return GetEntityBoneIndexByName(entity, 'door_pside_f') ~= -1
                    end,
                    action = function(entity)
                        ToggleDoor(entity, 1) -- Door index 1: Front Right
                    end,
                    distance = Config.MaxDistance
                },
                ["Toggle Hood"] = {
                    icon = "fa-solid fa-car-side", -- Using a more common Font Awesome icon
                    label = "Toggle Hood",
                    action = function(entity)
                        local modelHash = GetEntityModel(entity)
                        local modelName = GetDisplayNameFromVehicleModel(modelHash) -- Get model name string
                        ToggleDoor(entity, BackEngineVehicles[modelName:lower()] and 5 or 4) -- Hood is 4, Trunk is 5. If engine at back, hood is 5.
                    end,
                    distance = Config.MaxDistance
                },
                ["Toggle Trunk"] = {
                    icon = "fa-solid fa-suitcase", -- Using a more common Font Awesome icon
                    label = "Toggle Trunk",
                    action = function(entity)
                        local modelHash = GetEntityModel(entity)
                        local modelName = GetDisplayNameFromVehicleModel(modelHash) -- Get model name string
                        ToggleDoor(entity, BackEngineVehicles[modelName:lower()] and 4 or 5) -- Trunk is 5. If engine at back, trunk is 4.
                    end,
                    distance = Config.MaxDistance
                },
                
            },
            -- The distance for the "merged" group. The dot will appear if the player is within this range.
            -- This should generally be the distance of the "closest" interaction you want to allow for this group.
            -- Or a general interaction distance for the bone. Let's use Config.MaxDistance as it covers hood/trunk.
            distance = Config.MaxDistance,
            forceColor = '#4287f5', -- Example of a forced color for admin options
        }
    }

    

    -- Example: If you wanted to add default options for another bone, say 'wheel_lf':
    -- Bones.Options['wheel_lf'] = {
    --     merged = {
    --         options = {
    --             ["Check Tire Pressure"] = {
    --                 icon = "fas fa-tire",
    --                 label = "Check Tire",
    --                 action = function(entity) print("Checking left front tire of " .. entity) end,
    --                 distance = Config.MaxDistance
    --             }
    --         },
    --         distance = Config.MaxDistance -- Group distance for this merged dot
    --     },
    --     separate = {}
    -- }

end

