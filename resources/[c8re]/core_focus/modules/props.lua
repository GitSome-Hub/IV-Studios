-- ============================================================
--  INTERACTIVE PROPS MODULE
-- ============================================================
-- This module adds physics interactions to various props
-- Players can push, pick up, relocate, and flip tables for cover

-- Module configuration
local ModuleEnabled = true

-- Don't run if module is disabled
if not ModuleEnabled then
    return
end

-- Configuration
local Config = {
    MaxDistance = 2.5,      -- Maximum distance to interact with props (meters)
    ForceColor = "#ff6b35", -- Force color for prop interactions (orange)
    PickupOffset = vector3(0.0, 0.2, 0.0), -- Offset for carrying position
    FlipForce = 8.0,        -- Force applied when flipping tables (reduced from 15.0)
    PushForce = 8.0,        -- Force applied when pushing props
    ThrowForce = 35.0,      -- Force applied when throwing objects
    StackDistance = 1.0,    -- Maximum distance for stacking objects
    MaxStackHeight = 5,     -- Maximum number of objects that can be stacked
}

-- Animation data for different interactions
local PropAnimations = {
    pickup = {
        dict = "random@domestic",
        anim = "pickup_low",
        flag = 0,
        label = "Pickup"
    },
    push = {
        dict = "switch@trevor@pushes_bodybuilder",
        anim = "p001426_03_trvs_5_pushes_bodybuilder_exit_trv",
        flag = 0,
        label = "Push"
    },
    flip_table = {
        dict = "anim@mp_player_intupperair_shagging",
        anim = "idle_a",
        flag = 0,
        label = "Flip Table"
    },
    place = {
        dict = "random@domestic",
        anim = "pickup_low",
        flag = 0,
        label = "Place Down"
    },
    throw = {
        dict = "veh@driveby@first_person@driver@throw",
        anim = "throw_0",
        flag = 0,
        label = "Throw"
    },
    stack = {
        dict = "random@domestic",
        anim = "pickup_low",
        flag = 0,
        label = "Stack"
    }
}

-- Interactive prop models with their specific properties
local InteractiveProps = {
    -- Small objects that can be picked up and moved
    small_props = {
        [`prop_chair_01a`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_01b`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_02`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_03`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_04`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_05`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_06`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_07`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_08`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_09`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_chair_10`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_office_chair_01`] = { type = "pickup", weight = "medium", stackable = false },
        [`prop_office_chair_02`] = { type = "pickup", weight = "medium", stackable = false },
        [`v_club_stool`] = { type = "pickup", weight = "light", stackable = true },
        [`v_res_tre_stool`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_bar_stool_01`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_stool_01`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_stool_02`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_box_cardboard_01`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_box_cardboard_02`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_box_cardboard_03`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_box_cardboard_04`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_box_cardboard_05`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_box_wood01a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_box_wood02a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_box_wood03a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_box_wood04a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_box_wood05a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_crate_01a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_crate_02a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_crate_03a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_crate_04a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_crate_05a`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_bucket_01a`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_bucket_02a`] = { type = "pickup", weight = "light", stackable = true },
        [`prop_toolbox_01`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_toolbox_02`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_toolbox_03`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_toolbox_04`] = { type = "pickup", weight = "medium", stackable = true },
        [`prop_plant_01a`] = { type = "pickup", weight = "medium", stackable = false },
        [`prop_plant_01b`] = { type = "pickup", weight = "medium", stackable = false },
        [`prop_plant_02a`] = { type = "pickup", weight = "medium", stackable = false },
        [`prop_plant_02b`] = { type = "pickup", weight = "medium", stackable = false },
        [`prop_plant_03a`] = { type = "pickup", weight = "medium", stackable = false },
        [`prop_plant_03b`] = { type = "pickup", weight = "medium", stackable = false },
    },
    
    -- Throwable objects (small, light items that can be thrown)
    throwable_props = {
        [`prop_cs_beer_bot_02`] = { type = "throw", weight = "light", breakable = true },
        [`prop_cs_beer_bot_03`] = { type = "throw", weight = "light", breakable = true },
        [`prop_cs_beer_bot_04`] = { type = "throw", weight = "light", breakable = true },
        [`prop_wine_bot_01`] = { type = "throw", weight = "light", breakable = true },
        [`prop_wine_bot_02`] = { type = "throw", weight = "light", breakable = true },
        [`prop_cs_bottle_01`] = { type = "throw", weight = "light", breakable = true },
        [`prop_cs_bottle_02`] = { type = "throw", weight = "light", breakable = true },
        [`prop_rock_1_a`] = { type = "throw", weight = "medium", breakable = false },
        [`prop_rock_1_b`] = { type = "throw", weight = "medium", breakable = false },
        [`prop_rock_1_c`] = { type = "throw", weight = "medium", breakable = false },
        [`prop_rock_1_d`] = { type = "throw", weight = "medium", breakable = false },
        [`prop_rock_1_e`] = { type = "throw", weight = "medium", breakable = false },
        [`prop_rock_1_f`] = { type = "throw", weight = "medium", breakable = false },
        [`prop_rock_1_g`] = { type = "throw", weight = "medium", breakable = false },
        [`prop_rock_1_h`] = { type = "throw", weight = "medium", breakable = false },
        [`prop_cs_can_01`] = { type = "throw", weight = "light", breakable = false },
        [`prop_cs_can_02`] = { type = "throw", weight = "light", breakable = false },
        [`prop_cs_can_03`] = { type = "throw", weight = "light", breakable = false },
        [`prop_cs_can_04`] = { type = "throw", weight = "light", breakable = false },
        [`prop_cs_can_05`] = { type = "throw", weight = "light", breakable = false },
        [`prop_apple_core_01`] = { type = "throw", weight = "light", breakable = false },
        [`prop_banana_01`] = { type = "throw", weight = "light", breakable = false },
        [`prop_orange_01`] = { type = "throw", weight = "light", breakable = false },
        [`prop_bskball_01`] = { type = "throw", weight = "medium", breakable = false },
    },
    
    -- Tables that can be flipped for cover
    tables = {
        [`prop_table_01`] = { type = "flip", weight = "heavy" },
        [`prop_table_02`] = { type = "flip", weight = "heavy" },
        [`prop_table_03`] = { type = "flip", weight = "medium" },
        [`prop_table_04`] = { type = "flip", weight = "medium" },
        [`prop_table_05`] = { type = "flip", weight = "medium" },
        [`prop_table_06`] = { type = "flip", weight = "heavy" },
        [`prop_picnictable_01`] = { type = "flip", weight = "heavy" },
        [`prop_picnictable_02`] = { type = "flip", weight = "heavy" },
        [`prop_table_para_comb_02`] = { type = "flip", weight = "medium" },
        [`prop_table_tennis`] = { type = "flip", weight = "heavy" },
        [`prop_pool_table_01`] = { type = "flip", weight = "heavy" },
        [`prop_pool_table_02`] = { type = "flip", weight = "heavy" },
        [`v_res_tre_table`] = { type = "flip", weight = "medium" },
        [`v_res_tt_table`] = { type = "flip", weight = "medium" },
        [`v_club_table_01`] = { type = "flip", weight = "medium" },
        [`v_club_table_02`] = { type = "flip", weight = "medium" },
    },
    
    -- Large objects that can only be pushed
    pushable_props = {
        [`prop_dumpster_01a`] = { type = "push", weight = "heavy" },
        [`prop_dumpster_02a`] = { type = "push", weight = "heavy" },
        [`prop_dumpster_02b`] = { type = "push", weight = "heavy" },
        [`prop_dumpster_3a`] = { type = "push", weight = "heavy" },
        [`prop_dumpster_4a`] = { type = "push", weight = "heavy" },
        [`prop_dumpster_4b`] = { type = "push", weight = "heavy" },
        [`prop_skip_01a`] = { type = "push", weight = "heavy" },
        [`prop_skip_02a`] = { type = "push", weight = "heavy" },
        [`prop_skip_03`] = { type = "push", weight = "heavy" },
        [`prop_skip_04`] = { type = "push", weight = "heavy" },
        [`prop_skip_05a`] = { type = "push", weight = "heavy" },
        [`prop_skip_06a`] = { type = "push", weight = "heavy" },
        [`prop_roadcone01a`] = { type = "push", weight = "light" },
        [`prop_roadcone01b`] = { type = "push", weight = "light" },
        [`prop_roadcone01c`] = { type = "push", weight = "light" },
        [`prop_roadcone02a`] = { type = "push", weight = "light" },
        [`prop_roadcone02b`] = { type = "push", weight = "light" },
        [`prop_roadcone02c`] = { type = "push", weight = "light" },
        [`prop_barrier_work01a`] = { type = "push", weight = "medium" },
        [`prop_barrier_work01b`] = { type = "push", weight = "medium" },
        [`prop_barrier_work05`] = { type = "push", weight = "medium" },
        [`prop_barrier_work06a`] = { type = "push", weight = "medium" },
        [`prop_toolchest_01`] = { type = "push", weight = "heavy" },
        [`prop_toolchest_02`] = { type = "push", weight = "heavy" },
        [`prop_toolchest_03`] = { type = "push", weight = "heavy" },
        [`prop_toolchest_04`] = { type = "push", weight = "heavy" },
        [`prop_toolchest_05`] = { type = "push", weight = "heavy" },
        [`prop_barrel_01a`] = { type = "push", weight = "medium" },
        [`prop_barrel_02a`] = { type = "push", weight = "medium" },
        [`prop_barrel_02b`] = { type = "push", weight = "medium" },
        [`prop_barrel_03a`] = { type = "push", weight = "medium" },
        [`prop_barrel_03d`] = { type = "push", weight = "medium" },
        [`prop_gas_cylinder_01`] = { type = "push", weight = "heavy" },
        [`prop_gas_cylinder_02`] = { type = "push", weight = "heavy" },
        [`prop_gas_cylinder_03`] = { type = "push", weight = "heavy" },
    }
}

-- State tracking
local isCarrying = false
local carriedProp = nil
local originalPropCoords = nil
local isAnimating = false

-- Helper function to load animation dictionary
local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

-- Helper function to get prop info
local function GetPropInfo(propModel)
    for category, props in pairs(InteractiveProps) do
        if props[propModel] then
            local propData = props[propModel]
            return propData.type, propData.weight, propData.stackable, propData.breakable
        end
    end
    return nil, nil, nil, nil
end

-- Helper function to apply force based on weight
local function GetForceMultiplier(weight)
    if weight == "light" then
        return 1.5
    elseif weight == "medium" then
        return 1.0
    elseif weight == "heavy" then
        return 0.7
    end
    return 1.0
end

-- Function to push a prop
local function PushProp(propEntity, weight)
    if isAnimating then return end
    isAnimating = true
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local propCoords = GetEntityCoords(propEntity)
    local propModel = GetEntityModel(propEntity)
    
    -- Log interaction to server
    TriggerServerEvent('props:server:logInteraction', 'pushed', propModel, propCoords)
    
    -- Calculate push direction (away from player)
    local direction = vector3(
        propCoords.x - playerCoords.x,
        propCoords.y - playerCoords.y,
        0.0
    )
    direction = direction / #direction -- Normalize
    
    -- Load and play push animation
    LoadAnimDict(PropAnimations.push.dict)
    TaskPlayAnim(playerPed, PropAnimations.push.dict, PropAnimations.push.anim, 8.0, -8.0, 2000, PropAnimations.push.flag, 0, false, false, false)
    
    Wait(500) -- Wait for animation to start
    
    -- Apply force to the prop
    local forceMultiplier = GetForceMultiplier(weight)
    local force = vector3(
        direction.x * Config.PushForce * forceMultiplier,
        direction.y * Config.PushForce * forceMultiplier,
        0.0
    )
    
    ApplyForceToEntity(propEntity, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
    
    -- Track moved prop on server
    TriggerServerEvent('props:server:trackMovedProp', propEntity, propCoords)
    
    Wait(500)
    isAnimating = false
    
    if _G.Config and _G.Config.Debug then
        print("^2[Props]^7 Pushed prop with force: " .. tostring(force))
    end
end

-- Function to flip a table
local function FlipTable(propEntity, weight)
    if isAnimating then return end
    isAnimating = true
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local propCoords = GetEntityCoords(propEntity)
    local propModel = GetEntityModel(propEntity)
    
    -- Log interaction to server
    TriggerServerEvent('props:server:logInteraction', 'flipped', propModel, propCoords)
    
    -- Calculate flip direction
    local direction = vector3(
        propCoords.x - playerCoords.x,
        propCoords.y - playerCoords.y,
        0.0
    )
    direction = direction / #direction
    
    -- Load and play flip animation (shorter duration)
    LoadAnimDict(PropAnimations.flip_table.dict)
    TaskPlayAnim(playerPed, PropAnimations.flip_table.dict, PropAnimations.flip_table.anim, 8.0, -8.0, 500, PropAnimations.flip_table.flag, 0, false, false, false)
    
    Wait(300)
    
    -- Apply upward and forward force to flip the table
    local forceMultiplier = GetForceMultiplier(weight)
    local flipForce = vector3(
        direction.x * Config.FlipForce * forceMultiplier,
        direction.y * Config.FlipForce * forceMultiplier,
        Config.FlipForce * forceMultiplier * 0.8 -- Upward force
    )
    
    -- Apply force at the top of the table to create flipping motion
    ApplyForceToEntity(propEntity, 1, flipForce.x, flipForce.y, flipForce.z, 0.0, 0.0, 1.0, 0, false, true, true, false, true)
    
    -- Track moved prop on server
    TriggerServerEvent('props:server:trackMovedProp', propEntity, propCoords)
    
    Wait(2200)
    isAnimating = false
    
    if _G.Config and _G.Config.Debug then
        print("^2[Props]^7 Flipped table for cover!")
    end
end

-- Function to pick up a prop
local function PickupProp(propEntity, weight)
    if isCarrying or isAnimating then return end
    isAnimating = true
    
    local playerPed = PlayerPedId()
    local propCoords = GetEntityCoords(propEntity)
    local propModel = GetEntityModel(propEntity)
    originalPropCoords = propCoords
    
    -- Log interaction to server
    TriggerServerEvent('props:server:logInteraction', 'picked up', propModel, propCoords)
    
    -- Load and play pickup animation
    LoadAnimDict(PropAnimations.pickup.dict)
    TaskPlayAnim(playerPed, PropAnimations.pickup.dict, PropAnimations.pickup.anim, 8.0, -8.0, 1500, PropAnimations.pickup.flag, 0, false, false, false)
    
    Wait(800) -- Wait for pickup animation to mostly complete
    
    -- Attach prop to player
    AttachEntityToEntity(propEntity, playerPed, GetPedBoneIndex(playerPed, 28422), 
        Config.PickupOffset.x, Config.PickupOffset.y, Config.PickupOffset.z, 
        0.0, 0.0, 0.0, false, false, false, false, 2, true)
    
    Wait(700) -- Wait for pickup animation to finish
    
    -- Clear any tasks so player returns to normal stance with object attached
    ClearPedTasks(playerPed)
    
    -- Track moved prop on server
    TriggerServerEvent('props:server:trackMovedProp', propEntity, originalPropCoords)
    
    isCarrying = true
    carriedProp = propEntity
    isAnimating = false
    
    if _G.Config and _G.Config.Debug then
        print("^2[Props]^7 Picked up prop")
    end
end

-- Function to place down a carried prop
local function PlaceProp()
    if not isCarrying or not carriedProp then return end
    
    local playerPed = PlayerPedId()
    local propModel = GetEntityModel(carriedProp)
    
    -- Detach the prop
    DetachEntity(carriedProp, true, true)
    
    -- Load and play place animation
    LoadAnimDict(PropAnimations.place.dict)
    ClearPedTasks(playerPed)
    TaskPlayAnim(playerPed, PropAnimations.place.dict, PropAnimations.place.anim, 8.0, -8.0, 2000, PropAnimations.place.flag, 0, false, false, false)
    
    -- Place prop in front of player
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local forwardVector = vector3(
        math.sin(math.rad(-playerHeading)),
        math.cos(math.rad(-playerHeading)),
        0.0
    )
    
    local placeCoords = playerCoords + forwardVector * 1.5
    SetEntityCoords(carriedProp, placeCoords.x, placeCoords.y, placeCoords.z, false, false, false, true)
    
    -- Log interaction to server
    TriggerServerEvent('props:server:logInteraction', 'placed down', propModel, placeCoords)
    
    -- Reset state
    isCarrying = false
    carriedProp = nil
    originalPropCoords = nil
    
    if _G.Config and _G.Config.Debug then
        print("^2[Props]^7 Placed prop down")
    end
end

-- Function to return prop to original position
local function ReturnProp(propEntity)
    if not originalPropCoords then return end
    
    local propModel = GetEntityModel(propEntity)
    
    if isCarrying and carriedProp == propEntity then
        -- If carrying, detach first
        DetachEntity(carriedProp, true, true)
        ClearPedTasks(PlayerPedId())
        isCarrying = false
        carriedProp = nil
    end
    
    -- Return to original position
    SetEntityCoords(propEntity, originalPropCoords.x, originalPropCoords.y, originalPropCoords.z, false, false, false, true)
    
    -- Log interaction to server
    TriggerServerEvent('props:server:logInteraction', 'returned to original position', propModel, originalPropCoords)
    
    -- Stop tracking this prop on server
    TriggerServerEvent('props:server:stopTrackingProp', propEntity)
    
    originalPropCoords = nil
    
    if _G.Config and _G.Config.Debug then
        print("^2[Props]^7 Returned prop to original position")
    end
end

-- Function to throw a carried prop with aiming
local function ThrowProp()
    if not isCarrying or not carriedProp then return end
    
    local playerPed = PlayerPedId()
    local propModel = GetEntityModel(carriedProp)
    local propType, weight, stackable, breakable = GetPropInfo(propModel)
    
    -- Show aiming notification
    if _G.Config and _G.Config.Debug then
        print("^3[Props]^7 Aim where you want to throw and wait...")
    end
    
    -- Aiming phase - give player time to aim
    CreateThread(function()
        local aimStartTime = GetGameTimer()
        local aimDuration = 400 -- 400ms to aim
        
        while (GetGameTimer() - aimStartTime) < aimDuration do
            -- Show aiming help text
            SetTextComponentFormat("STRING")
            AddTextComponentString("~y~Aiming...~w~ Point where you want to throw!")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            Wait(0)
        end
        
        -- Detach the prop
        DetachEntity(carriedProp, true, true)
        
        -- Load and play throw animation
        LoadAnimDict(PropAnimations.throw.dict)
        ClearPedTasks(playerPed)
        TaskPlayAnim(playerPed, PropAnimations.throw.dict, PropAnimations.throw.anim, 8.0, -8.0, 1500, PropAnimations.throw.flag, 0, false, false, false)
        
        Wait(300) -- Wait for throw animation to start
        
        -- Calculate throw direction using camera/crosshair direction
        local playerCoords = GetEntityCoords(playerPed)
        local camCoords = GetFinalRenderedCamCoord()
        local camRot = GetFinalRenderedCamRot(2)
        
        -- Convert camera rotation to direction vector
        local camX = camRot.x * math.pi / 180.0
        local camZ = camRot.z * math.pi / 180.0
        
        local throwDirection = vector3(
            -math.sin(camZ) * math.cos(camX),
            math.cos(camZ) * math.cos(camX),
            math.sin(camX)
        )
        
        -- Apply throw force in the aimed direction
        local forceMultiplier = GetForceMultiplier(weight)
        local throwForce = vector3(
            throwDirection.x * Config.ThrowForce * forceMultiplier,
            throwDirection.y * Config.ThrowForce * forceMultiplier,
            throwDirection.z * Config.ThrowForce * forceMultiplier + (Config.ThrowForce * forceMultiplier * 0.2) -- Add slight upward arc
        )
        
        ApplyForceToEntity(carriedProp, 1, throwForce.x, throwForce.y, throwForce.z, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
        
        -- Log interaction to server
        TriggerServerEvent('props:server:logInteraction', 'threw', propModel, playerCoords)
        
        -- If breakable, set up break detection
        if breakable then
            CreateThread(function()
                local thrownProp = carriedProp
                Wait(1000) -- Wait a bit for the object to land
                
                -- Check if object hit something hard (simplified)
                local propCoords = GetEntityCoords(thrownProp)
                local propVelocity = GetEntityVelocity(thrownProp)
                local speed = #propVelocity
                
                if speed < 1.0 then -- Object has stopped moving
                    -- Simple break chance based on impact
                    if math.random(1, 100) <= 30 then -- 30% chance to break
                        -- Create break effect (you could add particle effects here)
                        PlaySoundFromCoord(-1, "GLASS_SMASH", propCoords.x, propCoords.y, propCoords.z, "", 0, 0, 0)
                        
                        -- Delete the object after a short delay
                        Wait(2000)
                        if DoesEntityExist(thrownProp) then
                            DeleteEntity(thrownProp)
                            if _G.Config and _G.Config.Debug then
                                print("^2[Props]^7 Breakable object shattered!")
                            end
                        end
                    end
                end
            end)
        end
        
        -- Reset state
        isCarrying = false
        carriedProp = nil
        originalPropCoords = nil
        
        if _G.Config and _G.Config.Debug then
            print("^2[Props]^7 Threw prop in aimed direction!")
        end
    end)
end

-- Function to stack a prop on top of another
local function StackProp(targetProp)
    if not isCarrying or not carriedProp then return end
    
    local playerPed = PlayerPedId()
    local propModel = GetEntityModel(carriedProp)
    local targetModel = GetEntityModel(targetProp)
    local propType, weight, stackable, breakable = GetPropInfo(propModel)
    local targetType, targetWeight, targetStackable = GetPropInfo(targetModel)
    
    -- Check if both objects are stackable
    if not stackable or not targetStackable then
        if _G.Config and _G.Config.Debug then
            print("^3[Props]^7 These objects cannot be stacked")
        end
        return
    end
    
    -- Get target prop dimensions and position
    local targetCoords = GetEntityCoords(targetProp)
    local targetMin, targetMax = GetModelDimensions(targetModel)
    local stackHeight = targetMax.z - targetMin.z
    
    -- Check how many objects are already stacked here
    local nearbyObjects = 0
    for prop in EnumerateObjects() do
        if DoesEntityExist(prop) and prop ~= carriedProp then
            local propCoords = GetEntityCoords(prop)
            if #(vector2(propCoords.x, propCoords.y) - vector2(targetCoords.x, targetCoords.y)) < Config.StackDistance then
                nearbyObjects = nearbyObjects + 1
            end
        end
    end
    
    if nearbyObjects >= Config.MaxStackHeight then
        if _G.Config and _G.Config.Debug then
            print("^3[Props]^7 Cannot stack higher - maximum height reached")
        end
        return
    end
    
    -- Detach the prop
    DetachEntity(carriedProp, true, true)
    
    -- Load and play stack animation
    LoadAnimDict(PropAnimations.stack.dict)
    ClearPedTasks(playerPed)
    TaskPlayAnim(playerPed, PropAnimations.stack.dict, PropAnimations.stack.anim, 8.0, -8.0, 2000, PropAnimations.stack.flag, 0, false, false, false)
    
    -- Calculate stack position
    local stackCoords = vector3(
        targetCoords.x,
        targetCoords.y,
        targetCoords.z + stackHeight + 0.1 + (nearbyObjects * stackHeight)
    )
    
    -- Place prop on top
    SetEntityCoords(carriedProp, stackCoords.x, stackCoords.y, stackCoords.z, false, false, false, true)
    
    -- Log interaction to server
    TriggerServerEvent('props:server:logInteraction', 'stacked', propModel, stackCoords)
    
    -- Reset state
    isCarrying = false
    carriedProp = nil
    originalPropCoords = nil
    
    if _G.Config and _G.Config.Debug then
        print("^2[Props]^7 Stacked prop")
    end
end

-- Create prop interaction options
local function CreatePropOptions()
    local options = {}
    
    -- Push option (for pushable props)
    table.insert(options, {
        label = "Push",
        icon = "fas fa-hand-paper",
        action = function(data)
            local propEntity = data
            local propModel = GetEntityModel(propEntity)
            local propType, weight = GetPropInfo(propModel)
            
            if propType == "push" then
                PushProp(propEntity, weight)
            end
        end,
        canInteract = function(entity, distance, data)
            local propModel = GetEntityModel(entity)
            local propType, weight = GetPropInfo(propModel)
            return propType == "push" and not isAnimating
        end
    })
    
    -- Flip table option (for tables)
    table.insert(options, {
        label = "Flip for Cover",
        icon = "fas fa-shield-alt",
        action = function(data)
            local propEntity = data
            local propModel = GetEntityModel(propEntity)
            local propType, weight = GetPropInfo(propModel)
            
            if propType == "flip" then
                FlipTable(propEntity, weight)
            end
        end,
        canInteract = function(entity, distance, data)
            local propModel = GetEntityModel(entity)
            local propType, weight = GetPropInfo(propModel)
            -- Check if table is upright (not flipped)
            local entityRot = GetEntityRotation(entity, 2)
            local isUpright = math.abs(entityRot.x) < 45 and math.abs(entityRot.y) < 45
            return propType == "flip" and not isAnimating and isUpright
        end
    })
    
    -- Unflip table option (for flipped tables)
    table.insert(options, {
        label = "Unflip Table",
        icon = "fas fa-undo",
        action = function(data)
            local propEntity = data
            local propModel = GetEntityModel(propEntity)
            local propType, weight = GetPropInfo(propModel)
            
            if propType == "flip" then
                -- Set table back to upright position
                local propCoords = GetEntityCoords(propEntity)
                local propHeading = GetEntityHeading(propEntity)
                SetEntityRotation(propEntity, 0.0, 0.0, propHeading, 2, true)
                
                -- Log interaction
                TriggerServerEvent('props:server:logInteraction', 'unflipped', propModel, propCoords)
                
                if _G.Config and _G.Config.Debug then
                    print("^2[Props]^7 Unflipped table")
                end
            end
        end,
        canInteract = function(entity, distance, data)
            local propModel = GetEntityModel(entity)
            local propType, weight = GetPropInfo(propModel)
            -- Check if table is flipped (not upright)
            local entityRot = GetEntityRotation(entity, 2)
            local isFlipped = math.abs(entityRot.x) > 45 or math.abs(entityRot.y) > 45
            return propType == "flip" and not isAnimating and isFlipped
        end
    })
    
    -- Pickup option (for small props and throwable items)
    table.insert(options, {
        label = "Pick Up",
        icon = "fas fa-hand-holding",
        action = function(data)
            local propEntity = data
            local propModel = GetEntityModel(propEntity)
            local propType, weight = GetPropInfo(propModel)
            
            if propType == "pickup" or propType == "throw" then
                PickupProp(propEntity, weight)
            end
        end,
        canInteract = function(entity, distance, data)
            local propModel = GetEntityModel(entity)
            local propType, weight = GetPropInfo(propModel)
            return (propType == "pickup" or propType == "throw") and not isCarrying and not isAnimating
        end
    })
    
    -- Place down option (when carrying)
    table.insert(options, {
        label = "Place Down",
        icon = "fas fa-hand-holding-down",
        action = function(data)
            PlaceProp()
        end,
        canInteract = function(entity, distance, data)
            return isCarrying and carriedProp == entity
        end
    })
    
    -- Throw option (when carrying)
    table.insert(options, {
        label = "Throw",
        icon = "fas fa-baseball-ball",
        action = function(data)
            ThrowProp()
        end,
        canInteract = function(entity, distance, data)
            return isCarrying and carriedProp == entity
        end
    })
    
    -- Stack option (when carrying and near stackable object)
    table.insert(options, {
        label = "Stack On Top",
        icon = "fas fa-layer-group",
        action = function(data)
            local targetEntity = data
            StackProp(targetEntity)
        end,
        canInteract = function(entity, distance, data)
            if not isCarrying or carriedProp == entity then return false end
            
            local propModel = GetEntityModel(carriedProp)
            local targetModel = GetEntityModel(entity)
            local propType, weight, stackable = GetPropInfo(propModel)
            local targetType, targetWeight, targetStackable = GetPropInfo(targetModel)
            
            return stackable and targetStackable and distance <= Config.StackDistance
        end
    })
    
    -- Return to original position option
    table.insert(options, {
        label = "Return to Original Position",
        icon = "fas fa-undo",
        action = function(data)
            local propEntity = data
            ReturnProp(propEntity)
        end,
        canInteract = function(entity, distance, data)
            return originalPropCoords ~= nil and not isAnimating
        end
    })
    
    return options
end

-- Monitor carrying state
CreateThread(function()
    while true do
        Wait(100)
        
        if isCarrying and carriedProp then
            -- Check if carried prop still exists
            if not DoesEntityExist(carriedProp) then
                isCarrying = false
                carriedProp = nil
                originalPropCoords = nil
                ClearPedTasks(PlayerPedId())
            end
        else
            Wait(1000)
        end
    end
end)

-- Handle player death/logout
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isCarrying and carriedProp then
            DetachEntity(carriedProp, true, true)
            ClearPedTasks(PlayerPedId())
        end
    end
end)

-- Initialize prop interactions
CreateThread(function()
    Wait(1000) -- Wait for targeting system to load
    
    local propOptions = CreatePropOptions()
    local totalProps = 0
    
    -- Add targeting for each prop category
    for category, props in pairs(InteractiveProps) do
        for modelHash, propData in pairs(props) do
            exports[GetCurrentResourceName()]:AddTargetModel(modelHash, {
                options = propOptions,
                distance = Config.MaxDistance,
                forceColor = Config.ForceColor
            })
            totalProps = totalProps + 1
        end
    end
    
    if _G.Config and _G.Config.Debug then
        print("^2[Props]^7 Module loaded with " .. totalProps .. " interactive props and " .. #propOptions .. " interactions")
    end
end)

-- Testing command to spawn props for testing
RegisterCommand('spawnprops', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    
    -- Calculate forward direction
    local forwardVector = vector3(
        math.sin(math.rad(-playerHeading)),
        math.cos(math.rad(-playerHeading)),
        0.0
    )
    
    -- Props to spawn for testing
    local testProps = {
        -- Table (flippable)
        { model = `prop_table_01`, pos = playerCoords + forwardVector * 2.0, type = "table" },
        
        -- Chairs (stackable)
        { model = `prop_chair_01a`, pos = playerCoords + forwardVector * 1.0 + vector3(-1.0, 0, 0), type = "chair" },
        { model = `prop_chair_01b`, pos = playerCoords + forwardVector * 1.0 + vector3(1.0, 0, 0), type = "chair" },
        
        -- Throwable bottles
        { model = `prop_cs_beer_bot_02`, pos = playerCoords + forwardVector * 2.5 + vector3(-0.5, 0, 1.0), type = "bottle" },
        { model = `prop_wine_bot_01`, pos = playerCoords + forwardVector * 2.5 + vector3(0.0, 0, 1.0), type = "bottle" },
        { model = `prop_cs_bottle_01`, pos = playerCoords + forwardVector * 2.5 + vector3(0.5, 0, 1.0), type = "bottle" },
        
        -- Stackable boxes
        { model = `prop_box_cardboard_01`, pos = playerCoords + forwardVector * 3.5 + vector3(-1.0, 0, 0), type = "box" },
        { model = `prop_box_cardboard_02`, pos = playerCoords + forwardVector * 3.5 + vector3(0.0, 0, 0), type = "box" },
        { model = `prop_box_cardboard_03`, pos = playerCoords + forwardVector * 3.5 + vector3(1.0, 0, 0), type = "box" },
        
        
        -- Basketball
        { model = `prop_bskball_01`, pos = playerCoords + forwardVector * 2.0 + vector3(0.0, 0, 1.0), type = "basketball" },
        
        -- Pushable barrel
        { model = `prop_barrel_01a`, pos = playerCoords + forwardVector * 4.0, type = "barrel" },
        
        -- More chairs for stacking
        { model = `prop_chair_02`, pos = playerCoords + forwardVector * 0.5 + vector3(-1.5, 0, 0), type = "chair" },
        { model = `prop_chair_03`, pos = playerCoords + forwardVector * 0.5 + vector3(1.5, 0, 0), type = "chair" },
    }
    
    local spawnedCount = 0
    
    for _, propData in ipairs(testProps) do
        -- Request model
        RequestModel(propData.model)
        local timeout = 0
        while not HasModelLoaded(propData.model) and timeout < 5000 do
            Wait(10)
            timeout = timeout + 10
        end
        
        if HasModelLoaded(propData.model) then
            -- Spawn the prop
            local prop = CreateObject(propData.model, propData.pos.x, propData.pos.y, propData.pos.z, true, true, true)
            
            if DoesEntityExist(prop) then
                -- Set proper physics
                SetEntityDynamic(prop, true)
                ActivatePhysics(prop)
                SetEntityCollision(prop, true, true)
                FreezeEntityPosition(prop, false)
                
                spawnedCount = spawnedCount + 1
                print(string.format("^2[Props]^7 Spawned %s (%s)", propData.type, propData.model))
            else
                print(string.format("^1[Props]^7 Failed to spawn %s", propData.type))
            end
            
            -- Clean up model
            SetModelAsNoLongerNeeded(propData.model)
        else
            print(string.format("^1[Props]^7 Failed to load model for %s", propData.type))
        end
    end
    
    if _G.Config and _G.Config.Debug then
        print(string.format("^2[Props]^7 Spawned %d test props around you!", spawnedCount))
        print("^3[Props]^7 Try the following:")
        print("^3[Props]^7 - Flip the table for cover")
        print("^3[Props]^7 - Stack the chairs and boxes")
        print("^3[Props]^7 - Throw the bottles and rocks")
        print("^3[Props]^7 - Push the barrel around")
    end
    
end, false)

if _G.Config and _G.Config.Debug then
    print("^2[Props]^7 Module " .. (ModuleEnabled and "Enabled" or "Disabled"))
end