Utils = {}

function Utils.Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utils.FormatMoney(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return '$' .. formatted
end

function Utils.TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function Utils.GetDistance(pos1, pos2)
    return #(pos1 - pos2)
end

function Utils.DebugPrint(...)
    if Config.Debug then
        print('^3[FS-Government]^7', ...)
    end
end

function Utils.DebugError(...)
    if Config.Debug then
        print('^1[FS-Government ERROR]^7', ...)
    end
end

function Utils.DebugSuccess(...)
    if Config.Debug then
        print('^2[FS-Government SUCCESS]^7', ...)
    end
end

function Utils.DebugWarn(...)
    if Config.Debug then
        print('^3[FS-Government WARN]^7', ...)
    end
end

function Utils.HasPermission(job, grade, permission)
    Utils.DebugPrint('Permission check: job=' .. tostring(job) .. ', grade=' .. tostring(grade) .. ', permission=' .. tostring(permission))
    Utils.DebugPrint('Called from: ' .. (IsDuplicityVersion() and 'SERVER' or 'CLIENT'))

    -- Add stack trace to see where this is called from
    local info = debug.getinfo(2, 'Sl')
    if info then
        Utils.DebugPrint('Called from file: ' .. tostring(info.source) .. ':' .. tostring(info.currentline))
    end
    
    if not Config.Government.jobs or not Utils.TableContains(Config.Government.jobs, job) then
        Utils.DebugError('Permission denied: Job not in government jobs list')
        return false
    end
    
    local permissions = Config.Government.permissions[grade]
    if not permissions then 
        Utils.DebugError('Permission denied: No permissions found for grade ' .. tostring(grade))
        return false 
    end
    
    local hasPermission = Utils.TableContains(permissions, permission) or Utils.TableContains(permissions, 'all')
    
    Utils.DebugSuccess('Permission result: ' .. tostring(hasPermission))
    Utils.DebugPrint('Available permissions for grade ' .. tostring(grade) .. ': ' .. table.concat(permissions, ', '))
    
    return hasPermission
end

function Utils.GetPlayersByJob(job)
    local players = {}
    local framework = Framework.GetFramework()
    
    if framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        for _, playerId in pairs(ESX.GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer and xPlayer.job.name == job then
                table.insert(players, {
                    source = playerId,
                    name = xPlayer.getName(),
                    grade = xPlayer.job.grade,
                    gradeName = xPlayer.job.grade_name
                })
            end
        end
    elseif framework == 'qbcore' or framework == 'qbox' then
        local QBCore = exports['qb-core']:GetCoreObject()
        for _, Player in pairs(QBCore.Functions.GetPlayers()) do
            local PlayerData = QBCore.Functions.GetPlayer(Player)
            if PlayerData and PlayerData.PlayerData.job.name == job then
                table.insert(players, {
                    source = Player,
                    name = PlayerData.PlayerData.charinfo.firstname .. ' ' .. PlayerData.PlayerData.charinfo.lastname,
                    grade = PlayerData.PlayerData.job.grade.level,
                    gradeName = PlayerData.PlayerData.job.grade.name
                })
            end
        end
    end
    
    return players
end

function Utils.GenerateId()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local id = ''
    for i = 1, 8 do
        local rand = math.random(#chars)
        id = id .. string.sub(chars, rand, rand)
    end
    return id
end

-- Client-safe timestamp conversion (no os dependency)
function Utils.ConvertTimestamp(timestamp)
    if not timestamp or timestamp <= 0 then
        return nil
    end

    -- Unix timestamp starts from Jan 1, 1970 00:00:00 UTC
    local days = math.floor(timestamp / 86400)
    local seconds = timestamp % 86400

    -- Calculate hours, minutes, seconds
    local hour = math.floor(seconds / 3600)
    local min = math.floor((seconds % 3600) / 60)
    local sec = seconds % 60

    -- Calculate year (approximate, good enough for display)
    local year = 1970
    local daysInYear = 365

    -- Account for leap years (simplified)
    while days >= daysInYear do
        days = days - daysInYear
        year = year + 1
        -- Simple leap year calculation
        if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
            daysInYear = 366
        else
            daysInYear = 365
        end
    end

    -- Days in each month (non-leap year)
    local monthDays = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

    -- Adjust February for leap years
    if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
        monthDays[2] = 29
    end

    -- Calculate month and day
    local month = 1
    while days >= monthDays[month] and month <= 12 do
        days = days - monthDays[month]
        month = month + 1
    end

    local day = days + 1

    return {
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = min,
        sec = sec
    }
end

function Utils.FormatDate(dateInput)
    if not dateInput then return 'Unknown Date' end

    -- Handle different types of date inputs
    local dateString
    local dateTime

    if type(dateInput) == 'number' then
        -- Handle Unix timestamps (both seconds and milliseconds)
        local timestamp = dateInput

        -- If timestamp is in milliseconds (like 1757688974000), convert to seconds
        if timestamp > 9999999999 then
            timestamp = timestamp / 1000
        end

        -- FiveM client-safe timestamp handling
        -- Since os.date is not available client-side, we'll use a simplified approach
        if IsDuplicityVersion() and os and os.date then
            -- Server-side: use full os.date functionality
            dateTime = os.date('*t', timestamp)

            Utils.DebugPrint('Timestamp: ' .. tostring(dateInput) .. ' -> ' .. tostring(timestamp) .. ' -> ' .. os.date('%Y-%m-%d %H:%M:%S', timestamp))
        else
            -- Client-side: manual timestamp conversion (Unix timestamp to date)
            dateTime = Utils.ConvertTimestamp(timestamp)
        end
    elseif type(dateInput) == 'string' then
        dateString = dateInput

        -- Handle MySQL DATETIME format (YYYY-MM-DD HH:MM:SS)
        local year, month, day, hour, min, sec = dateString:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")

        if year and month and day and hour and min and sec then
            dateTime = {
                year = tonumber(year),
                month = tonumber(month),
                day = tonumber(day),
                hour = tonumber(hour),
                min = tonumber(min),
                sec = tonumber(sec)
            }
        else
            -- Handle MySQL DATE format (YYYY-MM-DD)
            local y, m, d = dateString:match("(%d+)-(%d+)-(%d+)")
            if y and m and d then
                dateTime = {
                    year = tonumber(y),
                    month = tonumber(m),
                    day = tonumber(d),
                    hour = 0,
                    min = 0,
                    sec = 0
                }
            else
                -- Try parsing as timestamp string
                local numericValue = tonumber(dateString)
                if numericValue then
                    return Utils.FormatDate(numericValue)
                else
                    -- Return cleaned string
                    return dateString:gsub('T', ' '):gsub('%.%d+Z?', ''):gsub('Z', ''):gsub('%+%d%d:%d%d', '')
                end
            end
        end
    else
        return tostring(dateInput)
    end

    -- Format the date if we have a dateTime table
    if dateTime then
        local months = {
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        }

        local monthName = months[dateTime.month] or tostring(dateTime.month)
        local hour12 = dateTime.hour
        local ampm = 'AM'

        if hour12 > 12 then
            hour12 = hour12 - 12
            ampm = 'PM'
        elseif hour12 == 0 then
            hour12 = 12
        elseif hour12 == 12 then
            ampm = 'PM'
        end

        return string.format('%s %d, %d at %d:%02d %s', monthName, dateTime.day, dateTime.year, hour12, dateTime.min, ampm)
    end

    return tostring(dateInput)
end