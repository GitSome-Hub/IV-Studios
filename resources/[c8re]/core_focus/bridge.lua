-- ============================================================================
-- CORE FOCUS :: COMPATIBILITY BRIDGE
-- ============================================================================
-- This file handles compatibility for ox_target, qb-target, and qtarget.
-- It intercepts their export calls and translates them to core_focus calls.
-- Each target system has its own dedicated compatibility map.
-- ============================================================================

local currentResourceName = GetCurrentResourceName()
local CoreFocus = exports[currentResourceName]

-- Wait for the main resource's exports to be available before setting up the bridge
CreateThread(function()
    while CoreFocus == nil do
        Wait(1)
        CoreFocus = exports[currentResourceName]
    end
end)

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function registerBridgeExport(resourceName, exportName, handler)
    AddEventHandler(('__cfx_export_%s_%s'):format(resourceName, exportName), function(setCB)
        setCB(handler)
    end)
end

-- ============================================================================
-- Q-TARGET COMPATIBILITY LAYER 
-- ============================================================================
local function convertQTargetOptions(targetOptions)
    if not targetOptions or type(targetOptions) ~= 'table' then return {} end
    local distance = targetOptions.distance
    local options = targetOptions.options or {}
    local convertedOptions = {}
    for _, opt in pairs(options) do
        if type(opt) == 'table' then
            local newOpt = {}
            for k, v in pairs(opt) do newOpt[k] = v end
            newOpt.item = newOpt.item or newOpt.required_item
            newOpt.required_item = nil
            table.insert(convertedOptions, newOpt)
        end
    end
    return { options = convertedOptions, distance = distance }
end

local qtargetExportMap = {
    AddBoxZone = function(name, center, length, width, options, targetoptions)
        return CoreFocus:AddBoxZone(name, center, length, width, options, convertQTargetOptions(targetoptions))
    end,
    AddCircleZone = function(name, center, radius, options, targetoptions)
        return CoreFocus:AddCircleZone(name, center, radius, options, convertQTargetOptions(targetoptions))
    end,
    AddPolyZone = function(name, points, options, targetoptions)
        return CoreFocus:AddPolyZone(name, points, options, convertQTargetOptions(targetoptions))
    end,
    RemoveZone = function(id) return CoreFocus:RemoveZone(id) end,
    AddTargetBone = function(bones, options) CoreFocus:AddTargetBone(bones, convertQTargetOptions(options)) end,
    RemoveTargetBone = function(bones, labels) return CoreFocus:RemoveTargetBone(bones, labels) end,
    AddTargetEntity = function(entities, options) CoreFocus:AddTargetEntity(entities, convertQTargetOptions(options)) end,
    RemoveTargetEntity = function(entities, labels) return CoreFocus:RemoveTargetEntity(entities, labels) end,
    AddTargetModel = function(models, options) CoreFocus:AddTargetModel(models, convertQTargetOptions(options)) end,
    RemoveTargetModel = function(models, labels) return CoreFocus:RemoveTargetModel(models, labels) end,
    Ped = function(options) CoreFocus:AddGlobalPed(convertQTargetOptions(options)) end,
    Vehicle = function(options) CoreFocus:AddGlobalVehicle(convertQTargetOptions(options)) end,
    Object = function(options) CoreFocus:AddGlobalObject(convertQTargetOptions(options)) end,
    Player = function(options) CoreFocus:AddGlobalPlayer(convertQTargetOptions(options)) end,
    RemovePed = function(labels) return CoreFocus:RemoveGlobalPed(labels) end,
    RemoveVehicle = function(labels) return CoreFocus:RemoveGlobalVehicle(labels) end,
    RemoveObject = function(labels) return CoreFocus:RemoveGlobalObject(labels) end,
    RemovePlayer = function(labels) return CoreFocus:RemoveGlobalPlayer(labels) end,
    CheckGroups = function(groups) return CoreFocus:CheckGroups(groups) end,
    CheckItems = function(items, anyItem) return CoreFocus:CheckItems(items, anyItem) end
}

-- ============================================================================
-- QB-TARGET COMPATIBILITY LAYER
-- ============================================================================
local qbTargetExportMap = {
    AddBoxZone = function(name, center, length, width, options, targetoptions) return CoreFocus:AddBoxZone(name, center, length, width, options, targetoptions) end,
    AddCircleZone = function(name, center, radius, options, targetoptions) return CoreFocus:AddCircleZone(name, center, radius, options, targetoptions) end,
    AddPolyZone = function(name, points, options, targetoptions) return CoreFocus:AddPolyZone(name, points, options, targetoptions) end,
    RemoveZone = function(id) return CoreFocus:RemoveZone(id) end,
    AddTargetBone = function(bones, params) return CoreFocus:AddTargetBone(bones, params or {}) end,
    RemoveTargetBone = function(bones, labels) return CoreFocus:RemoveTargetBone(bones, labels) end,
    AddTargetEntity = function(entities, params) return CoreFocus:AddTargetEntity(entities, params or {}) end,
    RemoveTargetEntity = function(entities, labels) return CoreFocus:RemoveTargetEntity(entities, labels) end,
    AddTargetModel = function(models, params) return CoreFocus:AddTargetModel(models, params or {}) end,
    RemoveTargetModel = function(models, labels) return CoreFocus:RemoveTargetModel(models, labels) end,
    AddGlobalPed = function(params) return CoreFocus:AddGlobalPed(params or {}) end,
    AddGlobalVehicle = function(params) return CoreFocus:AddGlobalVehicle(params or {}) end,
    AddGlobalObject = function(params) return CoreFocus:AddGlobalObject(params or {}) end,
    AddGlobalPlayer = function(params) return CoreFocus:AddGlobalPlayer(params or {}) end,
    RemoveGlobalPed = function(labels) return CoreFocus:RemoveGlobalPed(labels) end,
    RemoveGlobalVehicle = function(labels) return CoreFocus:RemoveGlobalVehicle(labels) end,
    RemoveGlobalObject = function(labels) return CoreFocus:RemoveGlobalObject(labels) end,
    RemoveGlobalPlayer = function(labels) return CoreFocus:RemoveGlobalPlayer(labels) end,
    CheckGroups = function(groups) return CoreFocus:CheckGroups(groups) end,
    CheckItems = function(items, anyItem) return CoreFocus:CheckItems(items, anyItem) end
}

-- =================================================================================================
-- OX_TARGET COMPATIBILITY LAYER
-- =================================================================================================

-- Helper functions using integration exports
local function CheckGroups(groups) return CoreFocus:CheckGroups(groups) end
local function CheckItems(items, anyItem) return CoreFocus:CheckItems(items, anyItem) end

-- Enhanced option translation with full ox_target compatibility
local function CreateOxTranslatedOptions(options)
    local translated, params = {}, {}
    if not options or type(options) ~= 'table' then return translated, params end
    if not options[1] and options.label then options = { options } end

    for _, opt in ipairs(options) do
        local canShow = true
        if opt.groups and not CheckGroups(opt.groups) then canShow = false end
        if opt.items and not CheckItems(opt.items, opt.anyItem) then canShow = false end
        
        if canShow then
            table.insert(translated, {
                label = opt.label,
                icon = opt.icon,
                iconColor = opt.iconColor,
                name = opt.name,
                action = function(entity, data)
                    local callbackData = {
                        entity = entity,
                        coords = data and data.coords or (entity and GetEntityCoords(entity) or vector3(0,0,0)),
                        distance = data and data.distance or 0,
                        bone = data and data.boneName or nil,
                        zone = data and data.zoneId or nil
                    }
                    if opt.onSelect then opt.onSelect(callbackData)
                    elseif opt.export then exports[opt.export.resource or GetCurrentResourceName()][opt.export.name or opt.export](callbackData)
                    elseif opt.event then TriggerEvent(opt.event, callbackData)
                    elseif opt.serverEvent then
                        if callbackData.entity and DoesEntityExist(callbackData.entity) then
                            callbackData.entity = NetworkGetNetworkIdFromEntity(callbackData.entity)
                        end
                        TriggerServerEvent(opt.serverEvent, callbackData)
                    elseif opt.command then ExecuteCommand(opt.command) end
                end,
                canInteract = function(entity, distance, coords, name, bone)
                    if opt.groups and not CheckGroups(opt.groups) then return false end
                    if opt.items and not CheckItems(opt.items, opt.anyItem) then return false end
                    if opt.canInteract and not opt.canInteract(entity, distance, coords, name, bone) then return false end
                    return true
                end
            })
        end
        
        -- Extract parameters
        if opt.distance then params.distance = math.max(params.distance or 0, opt.distance) end
        if opt.iconColor then params.forceColor = opt.iconColor end
        if opt.bones then params.bones = opt.bones end
        if opt.offset then params.offset = opt.offset end
        if opt.offsetAbsolute then params.offsetAbsolute = opt.offsetAbsolute end
        if opt.offsetSize then params.offsetSize = opt.offsetSize end
    end
    
    return translated, params
end

local oxZoneIdCounter = 1
local oxZoneIds = {}
local oxTargetExportsMap = {
    ['disableTargeting'] = function(state) CoreFocus:AllowTargeting(not state) end,
    ['addGlobalOption'] = function(options)
        local translated, params = CreateOxTranslatedOptions(options); if #translated > 0 then
            local targetParams = { options = translated, distance = params.distance, forceColor = params.forceColor }; CoreFocus:AddGlobalPed(targetParams); CoreFocus:AddGlobalVehicle(targetParams); CoreFocus:AddGlobalObject(targetParams); CoreFocus:AddGlobalPlayer(targetParams)
        end
    end,
    ['removeGlobalOption'] = function(names) if type(names) == 'string' then names = { names } end; CoreFocus:RemoveGlobalPed(names); CoreFocus:RemoveGlobalVehicle(names); CoreFocus:RemoveGlobalObject(names); CoreFocus:RemoveGlobalPlayer(names) end,
    ['addGlobalObject'] = function(options) local translated, params = CreateOxTranslatedOptions(options); if #translated > 0 then CoreFocus:AddGlobalObject({ options = translated, distance = params.distance, forceColor = params.forceColor }) end end,
    ['removeGlobalObject'] = function(names) CoreFocus:RemoveGlobalObject(type(names) == 'string' and {names} or names) end,
    ['addGlobalPed'] = function(options) local translated, params = CreateOxTranslatedOptions(options); if #translated > 0 then CoreFocus:AddGlobalPed({ options = translated, distance = params.distance, forceColor = params.forceColor }) end end,
    ['removeGlobalPed'] = function(names) CoreFocus:RemoveGlobalPed(type(names) == 'string' and {names} or names) end,
    ['addGlobalPlayer'] = function(options) local translated, params = CreateOxTranslatedOptions(options); if #translated > 0 then CoreFocus:AddGlobalPlayer({ options = translated, distance = params.distance, forceColor = params.forceColor }) end end,
    ['removeGlobalPlayer'] = function(names) CoreFocus:RemoveGlobalPlayer(type(names) == 'string' and {names} or names) end,
    ['addGlobalVehicle'] = function(options) local translated, params = CreateOxTranslatedOptions(options); if #translated > 0 then CoreFocus:AddGlobalVehicle({ options = translated, distance = params.distance, forceColor = params.forceColor }) end end,
    ['removeGlobalVehicle'] = function(names) CoreFocus:RemoveGlobalVehicle(type(names) == 'string' and {names} or names) end,
    ['addModel'] = function(models, options) local translated, params = CreateOxTranslatedOptions(options); if #translated > 0 then CoreFocus:AddTargetModel(models, { options = translated, distance = params.distance, forceColor = params.forceColor, bones = params.bones }) end end,
    ['removeModel'] = function(models, names) CoreFocus:RemoveTargetModel(models, type(names) == 'string' and {names} or names) end,
    ['addEntity'] = function(netIds, options) local translated, params = CreateOxTranslatedOptions(options); if #translated > 0 then CoreFocus:AddTargetEntity(netIds, { options = translated, distance = params.distance, forceColor = params.forceColor, bones = params.bones }) end end,
    ['removeEntity'] = function(netIds, names) CoreFocus:RemoveTargetEntity(netIds, type(names) == 'string' and {names} or names) end,
    ['addLocalEntity'] = function(entities, options) local translated, params = CreateOxTranslatedOptions(options); if #translated > 0 then CoreFocus:AddTargetEntity(entities, { options = translated, distance = params.distance, forceColor = params.forceColor, bones = params.bones }) end end,
    ['removeLocalEntity'] = function(entities, names) CoreFocus:RemoveTargetEntity(entities, type(names) == 'string' and {names} or names) end,
    ['addSphereZone'] = function(p)
        local translated, params = CreateOxTranslatedOptions(p.options); if #translated > 0 then
            local zoneId = p.name or ('ox_sphere_' .. oxZoneIdCounter); oxZoneIdCounter = oxZoneIdCounter + 1; local zoneOpts = { name = zoneId, debugPoly = p.debug, useZ = true }; local targetOpts = { options = translated, distance = p.radius or params.distance or 3.0, forceColor = params.forceColor }; CoreFocus:AddCircleZone(zoneId, p.coords, p.radius or 3.0, zoneOpts, targetOpts); oxZoneIds[zoneId] = oxZoneIdCounter - 1; return oxZoneIdCounter - 1
        end
    end,
    ['addBoxZone'] = function(p)
        local translated, params = CreateOxTranslatedOptions(p.options); if #translated > 0 then
            local zoneId = p.name or ('ox_box_' .. oxZoneIdCounter); oxZoneIdCounter = oxZoneIdCounter + 1; local size = p.size or vec3(2.0, 2.0, 2.0); local zoneOpts = { name = zoneId, heading = p.rotation or 0.0, debugPoly = p.debug, minZ = p.coords.z - (size.z / 2), maxZ = p.coords.z + (size.z / 2) }; local targetOpts = { options = translated, distance = params.distance or 3.0, forceColor = params.forceColor }; CoreFocus:AddBoxZone(zoneId, p.coords, size.x, size.y, zoneOpts, targetOpts); oxZoneIds[zoneId] = oxZoneIdCounter - 1; return oxZoneIdCounter - 1
        end
    end,
    ['addPolyZone'] = function(p)
        local translated, params = CreateOxTranslatedOptions(p.options); if #translated > 0 then
            local zoneId = p.name or ('ox_poly_' .. oxZoneIdCounter); oxZoneIdCounter = oxZoneIdCounter + 1; local zoneOpts = { name = zoneId, debugPoly = p.debug, minZ = p.minZ, maxZ = p.maxZ }; local targetOpts = { options = translated, distance = params.distance or 3.0, forceColor = params.forceColor }; CoreFocus:AddPolyZone(zoneId, p.points, zoneOpts, targetOpts); oxZoneIds[zoneId] = oxZoneIdCounter - 1; return oxZoneIdCounter - 1
        end
    end,
    ['removeZone'] = function(id)
        local zoneId = type(id) == 'string' and id or nil; if type(id) == 'number' then for name, storedId in pairs(oxZoneIds) do if storedId == id then zoneId = name; break end end end; if zoneId then CoreFocus:RemoveZone(zoneId); oxZoneIds[zoneId] = nil end
    end,
    ['isActive'] = function() return CoreFocus:IsTargetActive() end,
    ['checkGroups'] = function(groups) return CoreFocus:CheckGroups(groups) end,
    ['checkItems'] = function(items, anyItem) return CoreFocus:CheckItems(items, anyItem) end
}

-- ============================================================================
-- REGISTER ALL BRIDGES
-- ============================================================================


    for exportName, handler in pairs(qtargetExportMap) do
        registerBridgeExport('qtarget', exportName, handler)
    end
    for exportName, handler in pairs(qbTargetExportMap) do
        registerBridgeExport('qb-target', exportName, handler)
    end
    for exportName, handler in pairs(oxTargetExportsMap) do
        registerBridgeExport('ox_target', exportName, handler)
    end
    
    if Config.Debug then
        print("^2[Bridge] All compatibility layers loaded with full support.^7")
    end
