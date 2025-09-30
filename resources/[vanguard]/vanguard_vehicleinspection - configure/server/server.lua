Vanguard = exports["Vanguard_Bridge"]:Vanguard()

local function convertIntervalToMilliseconds(interval)
    local timeValue = tonumber(interval:sub(1, -2))
    local timeUnit = interval:sub(-1)

    if timeUnit == "s" then
        return timeValue * 1000  
    elseif timeUnit == "m" then
        return timeValue * 60000  
    elseif timeUnit == "h" then
        return timeValue * 3600000  
    else
        error("Invalid time format in Config.DayReductionInterval. Use 's' for seconds, 'm' for minutes, or 'h' for hours.")
    end
end

local DAY_REDUCTION_INTERVAL = convertIntervalToMilliseconds(Config.DayReductionInterval)

RegisterServerEvent("Vanguard_addoninventory:addItem")
AddEventHandler("Vanguard_addoninventory:addItem", function(itemName, quantity)
    local xPlayer = Vanguard.GetPlayerFromId(source)
    if xPlayer then
        Vanguard.GiveItem(source, itemName, quantity)
        local notificationMessage = Config.Notifications.ItemPrinted.message:gsub("{itemName}", itemName)
        Vanguard.notifyserver(source, "INVENTORY", notificationMessage, 3000, Config.Notifications.ItemPrinted.type)
    end
end)

RegisterServerEvent("Vanguard_addoninventory:tryActivateInspection")
AddEventHandler("Vanguard_addoninventory:tryActivateInspection", function(plate, model, inspectionType)
    local playerSource = source
    local hasInspectionItem = false
    
    local xPlayer = Vanguard.GetPlayerFromId(source)
    if xPlayer then
        if Vanguard.HasItem(source, Config.InspectionItem) then
            hasInspectionItem = true
        elseif Vanguard.HasItem(source, Config.FailedInspectionItem) then
            hasInspectionItem = true
        end
    end

    if hasInspectionItem then
        MySQL.Async.fetchAll('SELECT * FROM vehicle_inspections WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(result)
            if #result > 0 then
                -- Se já existe uma inspeção para esta placa, notifica o jogador
                TriggerClientEvent("Vanguard_addoninventory:inspectionActivationResult", playerSource, false)
            else
                -- Se não existe, insere a nova inspeção
                local days = inspectionType == "done" and Config.InitialInspectionDays or 0
                
                MySQL.Async.execute('INSERT INTO vehicle_inspections (plate, model, inspection_type, days) VALUES (@plate, @model, @inspection_type, @days)', {
                    ['@plate'] = plate,
                    ['@model'] = model,
                    ['@inspection_type'] = inspectionType,
                    ['@days'] = days
                }, function(rowsChanged)
                    TriggerClientEvent("Vanguard_addoninventory:inspectionActivationResult", playerSource, true)
                end)
            end
        end)
    else
        TriggerClientEvent("Vanguard_addoninventory:inspectionActivationResult", playerSource, false)
    end
end)

RegisterServerEvent("Vanguard_addoninventory:saveInspection")
AddEventHandler("Vanguard_addoninventory:saveInspection", function(plate, model, inspectionType)
    local playerSource = source
    
    MySQL.Async.fetchAll('SELECT * FROM vehicle_inspections WHERE plate = @plate AND inspection_type = "done"', {
        ['@plate'] = plate
    }, function(result)
        if #result > 0 then
            Vanguard.notifyserver(playerSource, "INSPECTION", "This vehicle already has an active inspection.", 3000, "error")
        else
            local days = inspectionType == "done" and Config.InitialInspectionDays or 0
            
            MySQL.Async.execute('INSERT INTO vehicle_inspections (plate, model, inspection_type, days) VALUES (@plate, @model, @inspection_type, @days)', {
                ['@plate'] = plate,
                ['@model'] = model,
                ['@inspection_type'] = inspectionType,
                ['@days'] = days
            })
        end
    end)
end)

RegisterServerEvent("Vanguard_addoninventory:removeInspection")
AddEventHandler("Vanguard_addoninventory:removeInspection", function(plate)
    if not plate or plate == "" then return end

    MySQL.Async.execute('DELETE FROM vehicle_inspections WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent("Vanguard_addoninventory:inspectionRemovalResult", source, true)
        else
            TriggerClientEvent("Vanguard_addoninventory:inspectionRemovalResult", source, false)
        end
    end)
end)

RegisterServerEvent("Vanguard_addoninventory:checkInspection")
AddEventHandler("Vanguard_addoninventory:checkInspection", function(plate)
    local playerSource = source
    if not plate or plate == "" then
        Vanguard.notifyserver(playerSource, "INSPECTION", "Error checking inspection: invalid plate.", 3000, "error")
        return
    end

    MySQL.Async.fetchAll('SELECT * FROM vehicle_inspections WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if not playerSource then return end

        if result and result[1] then
            local inspection = result[1]
            local inspectionStatus = inspection.inspection_type == "done" and "valid" or "invalid"
            TriggerClientEvent("Vanguard_addoninventory:checkInspectionResult", playerSource, inspectionStatus, inspection.days)
        else
            TriggerClientEvent("Vanguard_addoninventory:checkInspectionResult", playerSource, "no inspection")
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(DAY_REDUCTION_INTERVAL)

        MySQL.Async.fetchAll('SELECT * FROM vehicle_inspections WHERE inspection_type = "done" AND days > 0', {}, function(results)
            for _, inspection in ipairs(results) do
                local newDays = inspection.days - 1
                if newDays <= 0 then
                    MySQL.Async.execute('UPDATE vehicle_inspections SET days = 0, inspection_type = "failed" WHERE id = @id', {
                        ['@id'] = inspection.id
                    })
                else
                    MySQL.Async.execute('UPDATE vehicle_inspections SET days = @days WHERE id = @id', {
                        ['@days'] = newDays,
                        ['@id'] = inspection.id
                    })
                end
            end
        end)
    end
end)

RegisterServerEvent("Vanguard_addoninventory:showInspectionToNearbyPlayer")
AddEventHandler("Vanguard_addoninventory:showInspectionToNearbyPlayer", function(targetPlayerId, inspectionStatus, vehicleData, failures)
    local playerSource = source
    local targetPlayer = Vanguard.GetPlayerFromId(targetPlayerId)

    if targetPlayer then
        -- Envia as informações da inspeção e a configuração para o jogador alvo
        TriggerClientEvent("Vanguard_addoninventory:showInspection", targetPlayerId, inspectionStatus, vehicleData, failures, {
            DocumentText = Config.DocumentText,
            FailureReasons = Config.FailureReasons
        })
        
        Vanguard.notifyserver(playerSource, "INSPECTION", "Inspection information has been sent to the nearby player.", 3000, "success")
    end
end)

RegisterServerEvent("Vanguard_addoninventory:closeDocument")
AddEventHandler("Vanguard_addoninventory:closeDocument", function()
    local playerSource = source
    TriggerClientEvent("Vanguard_addoninventory:hideInspection", playerSource)
end)