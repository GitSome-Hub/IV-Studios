local QBCore = exports['qb-core']:GetCoreObject()

-- Duty status tracking
local dutyStatuses = {}

-- Register callbacks for each job
CreateThread(function()
    for jobName, _ in pairs(Config.Jobs) do
        -- Get society money
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':getSocietyMoney', function(source, cb)
            local Player = QBCore.Functions.GetPlayer(source)
            
            if Player.PlayerData.job.name ~= jobName then
                cb(0)
                return
            end
            
            local result = MySQL.query.await('SELECT money FROM management_funds WHERE job_name = ?', { jobName })
            if result[1] then
                cb(result[1].money)
            else
                -- Create entry if doesn't exist
                MySQL.insert('INSERT INTO management_funds (job_name, money) VALUES (?, ?)', { jobName, 0 })
                cb(0)
            end
        end)

        -- Get online employees
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':getOnlineEmployees', function(source, cb)
            local Player = QBCore.Functions.GetPlayer(source)
            local onlineEmployees = {}
            
            if Player.PlayerData.job.name ~= jobName then
                cb({})
                return
            end
            
            local Players = QBCore.Functions.GetQBPlayers()
            
            for _, xPlayer in pairs(Players) do
                if xPlayer.PlayerData.job.name == jobName then
                    table.insert(onlineEmployees, {
                        source = xPlayer.PlayerData.source,
                        identifier = xPlayer.PlayerData.citizenid,
                        name = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname,
                        grade = xPlayer.PlayerData.job.grade.level
                    })
                end
            end
            
            cb(onlineEmployees)
        end)
        
        -- Get duty statuses for this job
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':getDutyStatuses', function(source, cb)
            local Player = QBCore.Functions.GetPlayer(source)
            
            if Player.PlayerData.job.name ~= jobName then
                cb({})
                return
            end
            
            -- Get duty statuses for this job only
            local jobDutyStatuses = {}
            for identifier, data in pairs(dutyStatuses) do
                if data.job == jobName then
                    jobDutyStatuses[identifier] = data.status
                end
            end
            
            cb(jobDutyStatuses)
        end)

        -- Get employees
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':getEmployees', function(source, cb)
            local Player = QBCore.Functions.GetPlayer(source)
            local employees = {}
            
            if Player.PlayerData.job.name ~= jobName then
                cb({})
                return
            end
            
            print('[BOSSMENU SERVER] Getting employees for job:', jobName)
            
            local result = MySQL.query.await('SELECT citizenid, charinfo, job FROM players WHERE JSON_EXTRACT(job, "$.name") = ? ORDER BY JSON_EXTRACT(job, "$.grade.level") DESC', { jobName })
            
            print('[BOSSMENU SERVER] Found', #result, 'employees in database for job:', jobName)
            
            -- Get online players for this job
            local Players = QBCore.Functions.GetQBPlayers()
            local onlineIdentifiers = {}
            for _, xPlayer in pairs(Players) do
                if xPlayer.PlayerData.job.name == jobName then
                    onlineIdentifiers[xPlayer.PlayerData.citizenid] = {
                        source = xPlayer.PlayerData.source,
                        name = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
                    }
                end
            end
            
            for i=1, #result, 1 do
                local charinfo = json.decode(result[i].charinfo)
                local jobData = json.decode(result[i].job)
                local isOnline = onlineIdentifiers[result[i].citizenid] ~= nil
                
                local employeeData = {
                    identifier = result[i].citizenid,
                    name = charinfo.firstname .. ' ' .. charinfo.lastname,
                    grade = jobData.grade.level,
                    isOnline = isOnline
                }
                
                -- Add server ID if online
                if isOnline then
                    employeeData.source = onlineIdentifiers[result[i].citizenid].source
                end
                
                table.insert(employees, employeeData)
            end
            
            print('[BOSSMENU SERVER] Returning', #employees, 'employees to client')
            cb(employees)
        end)

        -- Get candidate info
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':getCandidateInfo', function(source, cb, targetId)
            local Player = QBCore.Functions.GetPlayer(source)
            local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
            
            if not TargetPlayer then
                cb(nil)
                return
            end
            
            local candidateData = {
                source = targetId,
                name = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname,
                job = TargetPlayer.PlayerData.job.label,
                identifier = TargetPlayer.PlayerData.citizenid
            }
            
            cb(candidateData)
        end)

        -- Get transactions
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':getTransactions', function(source, cb)
            local Player = QBCore.Functions.GetPlayer(source)
            
            if Player.PlayerData.job.name ~= jobName then
                cb({})
                return
            end
            
            local result = MySQL.query.await('SELECT * FROM society_transactions WHERE society = ? ORDER BY date DESC LIMIT 20', { 'society_' .. jobName })
            cb(result)
        end)

        -- Update grade
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':updateGrade', function(source, cb, gradeId, newData)
            local Player = QBCore.Functions.GetPlayer(source)
            
            if Player.PlayerData.job.name ~= jobName then
                cb(false, Config.Texts.InvalidJob)
                return
            end
            
            local jobConfig = Config.Jobs[jobName]
            if not jobConfig then
                cb(false, Config.Texts.InvalidJob)
                return
            end
            
            if Player.PlayerData.job.grade.level < jobConfig.managePermission then
                cb(false, Config.Texts.NoManagePermission)
                return
            end
            
            local affectedRows = MySQL.update.await('UPDATE jobs SET label = ?, min_salary = ? WHERE name = ? AND grade = ?', {
                newData.label, newData.salary, jobName, gradeId
            })
            
            if affectedRows > 0 then
                cb(true, 'Grade updated successfully')
            else
                cb(false, 'Failed to update grade')
            end
        end)

        -- Hire employee
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':hireEmployee', function(source, cb, target, grade)
            local Player = QBCore.Functions.GetPlayer(source)
            local TargetPlayer = QBCore.Functions.GetPlayer(target)
            local jobConfig = Config.Jobs[jobName]
            
            print('[BOSSMENU SERVER] Hire request - Source:', source, 'Target:', target, 'Grade:', grade, 'Job:', jobName)
            
            if not jobConfig then
                cb(false, Config.Texts.InvalidJob)
                return
            end
            
            if Player.PlayerData.job.name ~= jobName or Player.PlayerData.job.grade.level < jobConfig.hirePermission then
                cb(false, Config.Texts.NoHirePermission)
                return
            end
            
            if not TargetPlayer then
                cb(false, Config.Texts.PlayerNotFound)
                return
            end
            
            if TargetPlayer.PlayerData.job.name == jobName then
                cb(false, Config.Texts.AlreadyEmployed)
                return
            end
            
            if grade >= Player.PlayerData.job.grade.level then
                cb(false, Config.Texts.CannotHireHigherRank)
                return
            end
            
            print('[BOSSMENU SERVER] Setting job for player:', TargetPlayer.PlayerData.charinfo.firstname, 'to job:', jobName, 'grade:', grade)
            
            -- Set the job
            TargetPlayer.Functions.SetJob(jobName, grade)
            
            -- Wait to ensure job is set
            Wait(500)
            
            -- Set default duty status for new employee
            dutyStatuses[TargetPlayer.PlayerData.citizenid] = {
                job = jobName,
                status = "off-duty"
            }
            
            -- Save duty status to database
            SaveDutyStatus(TargetPlayer.PlayerData.citizenid, jobName, "off-duty")
            
            -- Log transaction
            LogTransaction(Player.PlayerData.citizenid, 'society_' .. jobName, 'hire', string.format('Hired %s', TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname), 0)
            
            -- Send notifications
            TriggerClientEvent('bossmenu:notify', source, {
                type = 'success',
                title = 'Officer Recruited',
                message = string.format('Successfully hired %s', TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname)
            })
            
            TriggerClientEvent('bossmenu:notify', target, {
                type = 'info',
                title = 'Job Assigned',
                message = string.format('You have been hired by %s', jobConfig.label)
            })
            
            print('[BOSSMENU SERVER] Hire successful, broadcasting update...')
            
            cb(true, string.format('Successfully hired %s', TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname))
            
            -- Broadcast update to all job members
            SetTimeout(1000, function()
                print('[BOSSMENU SERVER] Broadcasting employees list update after hire')
                BroadcastEmployeesListUpdate(jobName)
            end)
        end)

        -- Fire employee
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':fireEmployee', function(source, cb, identifier)
            local Player = QBCore.Functions.GetPlayer(source)
            local jobConfig = Config.Jobs[jobName]
            local society = 'society_' .. jobName
            
            print('[BOSSMENU SERVER] Fire request - Source:', source, 'Identifier:', identifier, 'Job:', jobName)
            
            if not jobConfig then
                cb(false, Config.Texts.InvalidJob)
                return
            end
            
            if Player.PlayerData.job.name ~= jobName or Player.PlayerData.job.grade.level < jobConfig.firePermission then
                cb(false, Config.Texts.NoFirePermission)
                return
            end
            
            local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
            
            if TargetPlayer then
                -- Player is online
                print('[BOSSMENU SERVER] Target player is online:', TargetPlayer.PlayerData.charinfo.firstname)
                
                if TargetPlayer.PlayerData.job.name ~= jobName then
                    cb(false, Config.Texts.NotAnEmployee)
                    return
                end
                
                if TargetPlayer.PlayerData.job.grade.level >= Player.PlayerData.job.grade.level then
                    cb(false, Config.Texts.CannotFireHigherRank)
                    return
                end
                
                local playerName = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname
                
                -- Set job to unemployed
                TargetPlayer.Functions.SetJob('unemployed', 0)
                
                -- Wait to ensure job is changed
                Wait(500)
                
                -- Remove duty status for fired employee
                dutyStatuses[identifier] = nil
                
                -- Remove from database
                MySQL.execute('DELETE FROM duty_statuses WHERE identifier = ?', { identifier })
                
                -- Log transaction
                LogTransaction(Player.PlayerData.citizenid, society, 'fire', string.format('Fired %s', playerName), 0)
                
                -- Send notifications
                TriggerClientEvent('bossmenu:notify', source, {
                    type = 'success',
                    title = 'Officer Terminated',
                    message = string.format('Successfully fired %s', playerName)
                })
                
                TriggerClientEvent('bossmenu:notify', TargetPlayer.PlayerData.source, {
                    type = 'warning',
                    title = 'Job Termination',
                    message = 'You have been terminated from your job'
                })
                
                print('[BOSSMENU SERVER] Fire successful, broadcasting update...')
                
                cb(true, string.format('Successfully fired %s', playerName))
            else
                -- Player is offline
                print('[BOSSMENU SERVER] Target player is offline, updating database directly')
                
                local result = MySQL.query.await('SELECT charinfo, job FROM players WHERE citizenid = ?', { identifier })
                
                if result[1] then
                    local charinfo = json.decode(result[1].charinfo)
                    local jobData = json.decode(result[1].job)
                    
                    if jobData.name ~= jobName then
                        cb(false, Config.Texts.NotAnEmployee)
                        return
                    end
                    
                    if tonumber(jobData.grade.level) >= Player.PlayerData.job.grade.level then
                        cb(false, Config.Texts.CannotFireHigherRank)
                        return
                    end
                    
                    -- Create unemployed job data
                    local unemployedJob = {
                        name = 'unemployed',
                        label = 'Unemployed',
                        grade = {
                            level = 0,
                            name = 'unemployed'
                        },
                        type = 'none',
                        onduty = false,
                        isboss = false,
                        payment = 0
                    }
                    
                    local affectedRows = MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', {
                        json.encode(unemployedJob), identifier
                    })
                    
                    if affectedRows > 0 then
                        -- Remove duty status for fired employee
                        dutyStatuses[identifier] = nil
                        
                        -- Remove from database
                        MySQL.execute('DELETE FROM duty_statuses WHERE identifier = ?', { identifier })
                        
                        -- Log transaction
                        local empName = charinfo.firstname .. ' ' .. charinfo.lastname
                        LogTransaction(Player.PlayerData.citizenid, society, 'fire', string.format('Fired %s', empName), 0)
                        
                        -- Send notification
                        TriggerClientEvent('bossmenu:notify', source, {
                            type = 'success',
                            title = 'Officer Terminated',
                            message = string.format('Successfully fired %s', empName)
                        })
                        
                        print('[BOSSMENU SERVER] Fire successful (offline player), broadcasting update...')
                        
                        cb(true, string.format('Successfully fired %s', empName))
                    else
                        cb(false, 'Failed to fire employee')
                    end
                else
                    cb(false, 'Employee not found')
                end
            end
            
            -- Broadcast update to all job members
            SetTimeout(1000, function()
                print('[BOSSMENU SERVER] Broadcasting employees list update after fire')
                BroadcastEmployeesListUpdate(jobName)
            end)
        end)

        -- Promote employee
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':promoteEmployee', function(source, cb, identifier, newGrade)
            local Player = QBCore.Functions.GetPlayer(source)
            local jobConfig = Config.Jobs[jobName]
            local society = 'society_' .. jobName
            
            print('[BOSSMENU SERVER] Promote request - Source:', source, 'Identifier:', identifier, 'New Grade:', newGrade, 'Job:', jobName)
            
            if not jobConfig then
                cb(false, Config.Texts.InvalidJob)
                return
            end
            
            if Player.PlayerData.job.name ~= jobName or Player.PlayerData.job.grade.level < jobConfig.promotePermission then
                cb(false, Config.Texts.NoPromotePermission)
                return
            end
            
            -- Check if new grade is valid
            local gradeExists = false
            local gradeLabel = ""
            
            for _, grade in ipairs(jobConfig.grades) do
                if grade.grade == newGrade then
                    gradeExists = true
                    gradeLabel = grade.label
                    break
                end
            end
            
            if not gradeExists then
                cb(false, Config.Texts.InvalidGrade)
                return
            end
            
            -- Check if new grade is higher than source player's grade
            if newGrade >= Player.PlayerData.job.grade.level then
                cb(false, Config.Texts.CannotPromoteHigherRank)
                return
            end
            
            local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
            
            if TargetPlayer then
                -- Player is online
                if TargetPlayer.PlayerData.job.name ~= jobName then
                    cb(false, Config.Texts.NotAnEmployee)
                    return
                end
                
                if TargetPlayer.PlayerData.job.grade.level >= Player.PlayerData.job.grade.level then
                    cb(false, Config.Texts.CannotPromoteHigherRank)
                    return
                end
                
                if TargetPlayer.PlayerData.job.grade.level >= newGrade then
                    cb(false, Config.Texts.AlreadyHigherGrade)
                    return
                end
                
                local playerName = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname
                TargetPlayer.Functions.SetJob(jobName, newGrade)
                
                -- Wait to ensure job is updated
                Wait(500)
                
                -- Log transaction
                LogTransaction(Player.PlayerData.citizenid, society, 'promote', string.format('Promoted %s to %s', playerName, gradeLabel), 0)
                
                -- Send notifications
                TriggerClientEvent('bossmenu:notify', source, {
                    type = 'success',
                    title = 'Officer Promoted',
                    message = string.format('Successfully promoted %s to %s', playerName, gradeLabel)
                })
                
                TriggerClientEvent('bossmenu:notify', TargetPlayer.PlayerData.source, {
                    type = 'success',
                    title = 'Promotion',
                    message = string.format('You have been promoted to %s', gradeLabel)
                })
                
                print('[BOSSMENU SERVER] Promote successful, broadcasting update...')
                
                cb(true, string.format('Successfully promoted %s to %s', playerName, gradeLabel))
            else
                -- Player is offline
                local result = MySQL.query.await('SELECT charinfo, job FROM players WHERE citizenid = ?', { identifier })
                
                if result[1] then
                    local charinfo = json.decode(result[1].charinfo)
                    local jobData = json.decode(result[1].job)
                    
                    if jobData.name ~= jobName then
                        cb(false, Config.Texts.NotAnEmployee)
                        return
                    end
                    
                    if tonumber(jobData.grade.level) >= Player.PlayerData.job.grade.level then
                        cb(false, Config.Texts.CannotPromoteHigherRank)
                        return
                    end
                    
                    if tonumber(jobData.grade.level) >= newGrade then
                        cb(false, Config.Texts.AlreadyHigherGrade)
                        return
                    end
                    
                    -- Update job data
                    jobData.grade.level = newGrade
                    jobData.grade.name = gradeLabel
                    
                    local affectedRows = MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', {
                        json.encode(jobData), identifier
                    })
                    
                    if affectedRows > 0 then
                        -- Log transaction
                        local empName = charinfo.firstname .. ' ' .. charinfo.lastname
                        LogTransaction(Player.PlayerData.citizenid, society, 'promote', string.format('Promoted %s to %s', empName, gradeLabel), 0)
                        
                        -- Send notification
                        TriggerClientEvent('bossmenu:notify', source, {
                            type = 'success',
                            title = 'Officer Promoted',
                            message = string.format('Successfully promoted %s to %s', empName, gradeLabel)
                        })
                        
                        print('[BOSSMENU SERVER] Promote successful (offline player), broadcasting update...')
                        
                        cb(true, string.format('Successfully promoted %s to %s', empName, gradeLabel))
                    else
                        cb(false, 'Failed to promote employee')
                    end
                else
                    cb(false, 'Employee not found')
                end
            end
            
            -- Broadcast update to all job members
            SetTimeout(1000, function()
                print('[BOSSMENU SERVER] Broadcasting employees list update after promote')
                BroadcastEmployeesListUpdate(jobName)
            end)
        end)

        -- Demote employee
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':demoteEmployee', function(source, cb, identifier, newGrade)
            local Player = QBCore.Functions.GetPlayer(source)
            local jobConfig = Config.Jobs[jobName]
            local society = 'society_' .. jobName
            
            print('[BOSSMENU SERVER] Demote request - Source:', source, 'Identifier:', identifier, 'New Grade:', newGrade, 'Job:', jobName)
            
            if not jobConfig then
                cb(false, Config.Texts.InvalidJob)
                return
            end
            
            if Player.PlayerData.job.name ~= jobName or Player.PlayerData.job.grade.level < jobConfig.demotePermission then
                cb(false, Config.Texts.NoDemotePermission)
                return
            end
            
            -- Check if new grade is valid
            local gradeExists = false
            local gradeLabel = ""
            
            for _, grade in ipairs(jobConfig.grades) do
                if grade.grade == newGrade then
                    gradeExists = true
                    gradeLabel = grade.label
                    break
                end
            end
            
            if not gradeExists then
                cb(false, Config.Texts.InvalidGrade)
                return
            end
            
            local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
            
            if TargetPlayer then
                -- Player is online
                if TargetPlayer.PlayerData.job.name ~= jobName then
                    cb(false, Config.Texts.NotAnEmployee)
                    return
                end
                
                if TargetPlayer.PlayerData.job.grade.level >= Player.PlayerData.job.grade.level then
                    cb(false, Config.Texts.CannotDemoteHigherRank)
                    return
                end
                
                if TargetPlayer.PlayerData.job.grade.level <= newGrade then
                    cb(false, Config.Texts.AlreadyLowerGrade)
                    return
                end
                
                local playerName = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname
                TargetPlayer.Functions.SetJob(jobName, newGrade)
                
                -- Wait to ensure job is updated
                Wait(500)
                
                -- Log transaction
                LogTransaction(Player.PlayerData.citizenid, society, 'demote', string.format('Demoted %s to %s', playerName, gradeLabel), 0)
                
                -- Send notifications
                TriggerClientEvent('bossmenu:notify', source, {
                    type = 'warning',
                    title = 'Officer Demoted',
                    message = string.format('Successfully demoted %s to %s', playerName, gradeLabel)
                })
                
                TriggerClientEvent('bossmenu:notify', TargetPlayer.PlayerData.source, {
                    type = 'warning',
                    title = 'Demotion',
                    message = string.format('You have been demoted to %s', gradeLabel)
                })
                
                print('[BOSSMENU SERVER] Demote successful, broadcasting update...')
                
                cb(true, string.format('Successfully demoted %s to %s', playerName, gradeLabel))
            else
                -- Player is offline
                local result = MySQL.query.await('SELECT charinfo, job FROM players WHERE citizenid = ?', { identifier })
                
                if result[1] then
                    local charinfo = json.decode(result[1].charinfo)
                    local jobData = json.decode(result[1].job)
                    
                    if jobData.name ~= jobName then
                        cb(false, Config.Texts.NotAnEmployee)
                        return
                    end
                    
                    if tonumber(jobData.grade.level) >= Player.PlayerData.job.grade.level then
                        cb(false, Config.Texts.CannotDemoteHigherRank)
                        return
                    end
                    
                    if tonumber(jobData.grade.level) <= newGrade then
                        cb(false, Config.Texts.AlreadyLowerGrade)
                        return
                    end
                    
                    -- Update job data
                    jobData.grade.level = newGrade
                    jobData.grade.name = gradeLabel
                    
                    local affectedRows = MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', {
                        json.encode(jobData), identifier
                    })
                    
                    if affectedRows > 0 then
                        -- Log transaction
                        local empName = charinfo.firstname .. ' ' .. charinfo.lastname
                        LogTransaction(Player.PlayerData.citizenid, society, 'demote', string.format('Demoted %s to %s', empName, gradeLabel), 0)
                        
                        -- Send notification
                        TriggerClientEvent('bossmenu:notify', source, {
                            type = 'warning',
                            title = 'Officer Demoted',
                            message = string.format('Successfully demoted %s to %s', empName, gradeLabel)
                        })
                        
                        print('[BOSSMENU SERVER] Demote successful (offline player), broadcasting update...')
                        
                        cb(true, string.format('Successfully demoted %s to %s', empName, gradeLabel))
                    else
                        cb(false, 'Failed to demote employee')
                    end
                else
                    cb(false, 'Employee not found')
                end
            end
            
            -- Broadcast update to all job members
            SetTimeout(1000, function()
                print('[BOSSMENU SERVER] Broadcasting employees list update after demote')
                BroadcastEmployeesListUpdate(jobName)
            end)
        end)

        -- Withdraw money
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':withdrawMoney', function(source, cb, amount)
            local Player = QBCore.Functions.GetPlayer(source)
            local jobConfig = Config.Jobs[jobName]
            
            amount = tonumber(amount)
            
            if not jobConfig then
                cb(false, Config.Texts.InvalidJob)
                return
            end
            
            if Player.PlayerData.job.name ~= jobName or Player.PlayerData.job.grade.level < jobConfig.withdrawPermission then
                cb(false, Config.Texts.NoWithdrawPermission)
                return
            end
            
            if amount == nil or amount <= 0 then
                cb(false, Config.Texts.InvalidAmount)
                return
            end
            
            if amount > Config.MaxWithdrawal then
                cb(false, string.format(Config.Texts.MaxWithdrawal, Config.MaxWithdrawal))
                return
            end
            
            local result = MySQL.query.await('SELECT money FROM management_funds WHERE job_name = ?', { jobName })
            
            if result[1] then
                local currentMoney = result[1].money
                
                if amount > currentMoney then
                    cb(false, Config.Texts.NotEnoughMoney)
                    return
                end
                
                local newBalance = currentMoney - amount
                MySQL.update('UPDATE management_funds SET money = ? WHERE job_name = ?', { newBalance, jobName })
                Player.Functions.AddMoney('cash', amount)
                
                -- Log transaction
                LogTransaction(Player.PlayerData.citizenid, 'society_' .. jobName, 'withdraw', string.format('Withdrew $%d', amount), -amount)
                
                cb(true, string.format('Successfully withdrew $%d', amount), newBalance)
            else
                cb(false, Config.Texts.NotEnoughMoney)
            end
        end)

        -- Deposit money
        QBCore.Functions.CreateCallback('bossmenu_' .. jobName .. ':depositMoney', function(source, cb, amount)
            local Player = QBCore.Functions.GetPlayer(source)
            local jobConfig = Config.Jobs[jobName]
            
            amount = tonumber(amount)
            
            if not jobConfig then
                cb(false, Config.Texts.InvalidJob)
                return
            end
            
            if Player.PlayerData.job.name ~= jobName or Player.PlayerData.job.grade.level < jobConfig.depositPermission then
                cb(false, Config.Texts.NoDepositPermission)
                return
            end
            
            if amount == nil or amount <= 0 then
                cb(false, Config.Texts.InvalidAmount)
                return
            end
            
            if amount > Config.MaxDeposit then
                cb(false, string.format(Config.Texts.MaxDeposit, Config.MaxDeposit))
                return
            end
            
            if Player.PlayerData.money.cash < amount then
                cb(false, Config.Texts.NotEnoughCash)
                return
            end
            
            local result = MySQL.query.await('SELECT money FROM management_funds WHERE job_name = ?', { jobName })
            
            if result[1] then
                local currentMoney = result[1].money
                local newBalance = currentMoney + amount
                
                MySQL.update('UPDATE management_funds SET money = ? WHERE job_name = ?', { newBalance, jobName })
                Player.Functions.RemoveMoney('cash', amount)
                
                -- Log transaction
                LogTransaction(Player.PlayerData.citizenid, 'society_' .. jobName, 'deposit', string.format('Deposited $%d', amount), amount)
                
                cb(true, string.format('Successfully deposited $%d', amount), newBalance)
            else
                -- Create entry if doesn't exist
                MySQL.insert('INSERT INTO management_funds (job_name, money) VALUES (?, ?)', { jobName, amount })
                Player.Functions.RemoveMoney('cash', amount)
                
                -- Log transaction
                LogTransaction(Player.PlayerData.citizenid, 'society_' .. jobName, 'deposit', string.format('Deposited $%d', amount), amount)
                
                cb(true, string.format('Successfully deposited $%d', amount), amount)
            end
        end)
    end
end)

-- Helper functions

-- Get job configuration
function GetJobConfig(jobName)
    return Config.Jobs[jobName]
end

-- Log transaction
function LogTransaction(identifier, society, type, description, amount)
    MySQL.insert('INSERT INTO society_transactions (society, identifier, type, description, amount, date) VALUES (?, ?, ?, ?, ?, ?)', {
        society, identifier, type, description, amount, os.date('%Y-%m-%d %H:%M:%S')
    })
end

-- Broadcast employees list update to all job members with boss menu access
function BroadcastEmployeesListUpdate(jobName)
    local jobConfig = Config.Jobs[jobName]
    if not jobConfig then return end
    
    print(string.format('[BOSSMENU SERVER] Broadcasting employee list update for job: %s', jobName))
    
    local Players = QBCore.Functions.GetQBPlayers()
    
    for _, Player in pairs(Players) do
        if Player.PlayerData.job.name == jobName and Player.PlayerData.job.grade.level >= jobConfig.minGrade then
            print(string.format('[BOSSMENU SERVER] Sending refresh to player: %s (ID: %d)', Player.PlayerData.charinfo.firstname, Player.PlayerData.source))
            TriggerClientEvent('bossmenu:refreshEmployeesList', Player.PlayerData.source)
        end
    end
end

-- Ensure required tables exist
MySQL.ready(function()
    -- Create management_funds table if it doesn't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `management_funds` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `job_name` varchar(50) NOT NULL,
            `money` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`),
            UNIQUE KEY `job_name` (`job_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Create society_transactions table if it doesn't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `society_transactions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `society` varchar(50) DEFAULT NULL,
            `identifier` varchar(60) DEFAULT NULL,
            `type` varchar(50) DEFAULT NULL,
            `description` varchar(255) DEFAULT NULL,
            `amount` int(11) DEFAULT 0,
            `date` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `society` (`society`),
            KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Create duty_statuses table if it doesn't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `duty_statuses` (
            `identifier` varchar(60) NOT NULL,
            `job` varchar(50) NOT NULL,
            `status` varchar(50) NOT NULL DEFAULT 'off-duty',
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    print('[^2INFO^7] Boss Menu database tables ensured')
    
    -- Load saved duty statuses from database
    LoadDutyStatuses()
end)

-- Load duty statuses from database
function LoadDutyStatuses()
    local result = MySQL.query.await('SELECT * FROM duty_statuses')
    if result and #result > 0 then
        for _, row in ipairs(result) do
            dutyStatuses[row.identifier] = {
                job = row.job,
                status = row.status
            }
        end
        print('[^2INFO^7] Loaded ' .. #result .. ' duty statuses from database')
    end
end

-- Save duty status to database
function SaveDutyStatus(identifier, job, status)
    MySQL.insert('INSERT INTO duty_statuses (identifier, job, status) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE job = ?, status = ?', {
        identifier, job, status, job, status
    })
end

-- Request duty status event
RegisterNetEvent('bossmenu:requestDutyStatus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local identifier = Player.PlayerData.citizenid
    local status = "off-duty" -- Default status
    
    -- Check if we have a saved status
    if dutyStatuses[identifier] and dutyStatuses[identifier].job == Player.PlayerData.job.name then
        status = dutyStatuses[identifier].status
    else
        -- Set default status
        dutyStatuses[identifier] = {
            job = Player.PlayerData.job.name,
            status = status
        }
        
        -- Save to database
        SaveDutyStatus(identifier, Player.PlayerData.job.name, status)
    end
    
    -- Send status to client
    TriggerClientEvent('bossmenu:receiveDutyStatus', src, status)
end)

-- Update duty status event
RegisterNetEvent('bossmenu:updateDutyStatus', function(status)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local identifier = Player.PlayerData.citizenid
    local jobName = Player.PlayerData.job.name
    
    -- Update status
    dutyStatuses[identifier] = {
        job = jobName,
        status = status
    }
    
    -- Save to database
    SaveDutyStatus(identifier, jobName, status)
    
    -- Broadcast to all job members
    local Players = QBCore.Functions.GetQBPlayers()
    for _, xPlayer in pairs(Players) do
        if xPlayer.PlayerData.job.name == jobName then
            TriggerClientEvent('bossmenu:updateDutyStatus', xPlayer.PlayerData.source, identifier, status)
        end
    end
    
    -- Log status change
    local society = 'society_' .. jobName
    LogTransaction(identifier, society, 'duty', 'Changed status to ' .. status, 0)
end)

-- Change employee duty status event (for managers)
RegisterNetEvent('bossmenu:changeEmployeeDutyStatus', function(targetIdentifier, status)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local jobName = Player.PlayerData.job.name
    local jobConfig = Config.Jobs[jobName]
    
    -- Check if player has permission
    if not jobConfig or Player.PlayerData.job.grade.level < jobConfig.managePermission then
        TriggerClientEvent('bossmenu:notify', src, {
            type = 'error',
            title = 'Permission Denied',
            message = "You don't have permission to change duty status"
        })
        return
    end
    
    -- Update status
    if dutyStatuses[targetIdentifier] and dutyStatuses[targetIdentifier].job == jobName then
        dutyStatuses[targetIdentifier].status = status
        
        -- Save to database
        SaveDutyStatus(targetIdentifier, jobName, status)
        
        -- Broadcast to all job members
        local Players = QBCore.Functions.GetQBPlayers()
        for _, xPlayer in pairs(Players) do
            if xPlayer.PlayerData.job.name == jobName then
                TriggerClientEvent('bossmenu:updateDutyStatus', xPlayer.PlayerData.source, targetIdentifier, status)
            end
        end
        
        -- Find target player name
        local targetName = "Unknown"
        local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(targetIdentifier)
        if TargetPlayer then
            targetName = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname
            
            -- Notify the target player
            TriggerClientEvent('bossmenu:notify', TargetPlayer.PlayerData.source, {
                type = 'info',
                title = 'Status Updated',
                message = "Your duty status was changed to " .. status
            })
        else
            -- Try to get name from database
            local result = MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ?', { targetIdentifier })
            if result[1] then
                local charinfo = json.decode(result[1].charinfo)
                targetName = charinfo.firstname .. ' ' .. charinfo.lastname
            end
        end
        
        -- Log status change
        local society = 'society_' .. jobName
        LogTransaction(Player.PlayerData.citizenid, society, 'duty', 'Changed ' .. targetName .. "'s status to " .. status, 0)
        
        -- Notify the source player
        TriggerClientEvent('bossmenu:notify', src, {
            type = 'success',
            title = 'Status Updated',
            message = "Changed " .. targetName .. "'s status to " .. status
        })
    else
        TriggerClientEvent('bossmenu:notify', src, {
            type = 'error',
            title = 'Update Failed',
            message = "Player not found or not in your organization"
        })
    end
end)

-- Player disconnect handler - don't change duty status on disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        -- We don't change duty status on disconnect
        -- This way, if a player is on-duty when they disconnect, they'll still be on-duty when they reconnect
        print('[^2INFO^7] Player ' .. Player.PlayerData.charinfo.firstname .. ' disconnected. Duty status preserved.')
    end
end)