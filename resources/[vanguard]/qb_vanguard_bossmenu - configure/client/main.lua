local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}
local isBossMenuOpen = false
local playerDutyStatus = "off-duty" -- Default duty status

-- Initialize QBCore
CreateThread(function()
    while true do
        Wait(10)
        if LocalPlayer.state.isLoggedIn then
            PlayerData = QBCore.Functions.GetPlayerData()
            break
        end
    end
    
    -- Request initial duty status from server
    TriggerServerEvent('bossmenu:requestDutyStatus')
end)

-- Update player data when job changes
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    
    -- Close menu if job changes and no longer have access
    if isBossMenuOpen then
        local hasAccess = false
        local jobConfig = Config.Jobs[PlayerData.job.name]
        
        if jobConfig and PlayerData.job.grade.level >= jobConfig.minGrade then
            hasAccess = true
        end
        
        if not hasAccess then
            CloseBossMenu()
        end
    end
    
    -- If job changed, set status to off-duty by default
    if PlayerData.job.name then
        playerDutyStatus = "off-duty"
        TriggerServerEvent('bossmenu:updateDutyStatus', playerDutyStatus)
    end
end)

-- Update player data on login
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent('bossmenu:requestDutyStatus')
end)

-- Update duty status event from server
RegisterNetEvent('bossmenu:updateDutyStatus')
AddEventHandler('bossmenu:updateDutyStatus', function(identifier, status)
    -- If this is our own status, update the local variable
    if identifier == PlayerData.citizenid then
        playerDutyStatus = status
    end
    
    -- If boss menu is open, update the UI
    if isBossMenuOpen then
        SendNUIMessage({
            type = 'updateDutyStatus',
            identifier = identifier,
            status = status
        })
    end
end)

-- Receive initial duty status from server
RegisterNetEvent('bossmenu:receiveDutyStatus')
AddEventHandler('bossmenu:receiveDutyStatus', function(status)
    playerDutyStatus = status
end)

-- Event to refresh employees list
RegisterNetEvent('bossmenu:refreshEmployeesList')
AddEventHandler('bossmenu:refreshEmployeesList', function()
    print('[BOSSMENU CLIENT] Received refresh employees list event')
    
    if isBossMenuOpen then
        print('[BOSSMENU CLIENT] Boss menu is open, refreshing all data')
        RefreshAllBossMenuData()
    else
        print('[BOSSMENU CLIENT] Boss menu is not open, ignoring refresh')
    end
end)

-- New function to refresh all boss menu data
function RefreshAllBossMenuData()
    if not isBossMenuOpen or not PlayerData.job.name then return end
    
    local jobName = PlayerData.job.name
    
    print('[BOSSMENU CLIENT] Starting complete data refresh for job:', jobName)
    
    -- Get all updated data from server
    QBCore.Functions.TriggerCallback('bossmenu_' .. jobName .. ':getEmployees', function(employees)
        print('[BOSSMENU CLIENT] Got updated employees:', employees and #employees or 0)
        
        QBCore.Functions.TriggerCallback('bossmenu_' .. jobName .. ':getOnlineEmployees', function(onlineEmployees)
            print('[BOSSMENU CLIENT] Got online employees:', onlineEmployees and #onlineEmployees or 0)
            
            QBCore.Functions.TriggerCallback('bossmenu_' .. jobName .. ':getDutyStatuses', function(dutyStatuses)
                print('[BOSSMENU CLIENT] Got duty statuses:', dutyStatuses and table.count(dutyStatuses) or 0)
                
                QBCore.Functions.TriggerCallback('bossmenu_' .. jobName .. ':getSocietyMoney', function(money)
                    QBCore.Functions.TriggerCallback('bossmenu_' .. jobName .. ':getTransactions', function(transactions)
                        -- Send all updated data to UI
                        SendNUIMessage({
                            type = 'updateEmployees',
                            employees = employees
                        })
                        
                        SendNUIMessage({
                            type = 'updateOnlineEmployees',
                            onlineEmployees = onlineEmployees
                        })
                        
                        SendNUIMessage({
                            type = 'updateDutyStatuses',
                            dutyStatuses = dutyStatuses
                        })
                        
                        SendNUIMessage({
                            type = 'updateMoney',
                            money = money
                        })
                        
                        SendNUIMessage({
                            type = 'updateTransactions',
                            transactions = transactions
                        })
                        
                        print('[BOSSMENU CLIENT] All data refreshed successfully')
                    end)
                end)
            end)
        end)
    end)
end

-- Helper function to count table entries
function table.count(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Boss menu notification event
RegisterNetEvent('bossmenu:notify')
AddEventHandler('bossmenu:notify', function(data)
    if isBossMenuOpen then
        SendNUIMessage({
            type = 'notify',
            notificationType = data.type,
            title = data.title,
            message = data.message
        })
    else
        -- If boss menu is not open, use QBCore notification as fallback
        QBCore.Functions.Notify(data.message, data.type)
    end
end)

-- Open boss menu command
RegisterCommand(Config.Command, function()
    local hasAccess = false
    local jobConfig = nil
    
    if Config.Jobs[PlayerData.job.name] then
        jobConfig = Config.Jobs[PlayerData.job.name]
        if PlayerData.job.grade.level >= jobConfig.minGrade then
            hasAccess = true
        end
    end
    
    if hasAccess then
        OpenBossMenu(jobConfig)
    else
        QBCore.Functions.Notify(Config.Texts.NoAccess, 'error')
    end
end, false)

-- Register keybinding if enabled
if Config.EnableKeybind then
    RegisterKeyMapping(Config.Command, Config.Texts.KeybindHelpText, 'keyboard', Config.KeybindKey)
end

-- Open boss menu function
function OpenBossMenu(jobConfig)
    if isBossMenuOpen then return end
    
    isBossMenuOpen = true
    
    -- Request initial data
    QBCore.Functions.TriggerCallback('bossmenu_' .. jobConfig.name .. ':getSocietyMoney', function(money)
        QBCore.Functions.TriggerCallback('bossmenu_' .. jobConfig.name .. ':getEmployees', function(employees)
            QBCore.Functions.TriggerCallback('bossmenu_' .. jobConfig.name .. ':getTransactions', function(transactions)
                QBCore.Functions.TriggerCallback('bossmenu_' .. jobConfig.name .. ':getOnlineEmployees', function(onlineEmployees)
                    QBCore.Functions.TriggerCallback('bossmenu_' .. jobConfig.name .. ':getDutyStatuses', function(dutyStatuses)
                        -- Send data to NUI
                        SendNUIMessage({
                            type = 'open',
                            employees = employees,
                            money = money,
                            transactions = transactions,
                            onlineEmployees = onlineEmployees,
                            dutyStatuses = dutyStatuses,
                            playerStatus = playerDutyStatus,
                            grades = jobConfig.grades,
                            playerName = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname,
                            playerJob = {
                                name = PlayerData.job.name,
                                label = PlayerData.job.label,
                                grade = PlayerData.job.grade.level,
                                identifier = PlayerData.citizenid
                            },
                            config = {
                                jobName = jobConfig.name,
                                jobLabel = jobConfig.label,
                                jobIcon = jobConfig.icon,
                                minHireGrade = jobConfig.hirePermission,
                                minFireGrade = jobConfig.firePermission,
                                minPromoteGrade = jobConfig.promotePermission,
                                minDemoteGrade = jobConfig.demotePermission,
                                minWithdrawGrade = jobConfig.withdrawPermission,
                                minDepositGrade = jobConfig.depositPermission,
                                minManageGrade = jobConfig.managePermission,
                                dutyStatuses = Config.DutyStatuses or {
                                    "on-duty", 
                                    "off-duty", 
                                    "patrolling", 
                                    "break", 
                                    "training", 
                                    "court"
                                }
                            }
                        })
                        
                        -- Show cursor
                        SetNuiFocus(true, true)
                        
                        -- Play animation
                        PlayOpenMenuAnimation()
                    end)
                end)
            end)
        end)
    end)
end

-- Close boss menu function
function CloseBossMenu()
    if not isBossMenuOpen then return end
    
    isBossMenuOpen = false
    
    -- Hide cursor
    SetNuiFocus(false, false)
    
    -- Send close message to NUI
    SendNUIMessage({
        type = 'close'
    })
    
    -- Play animation
    PlayCloseMenuAnimation()
end

-- Play open menu animation
function PlayOpenMenuAnimation()
    local playerPed = PlayerPedId()
    
    if Config.EnableAnimations then
        if not IsEntityPlayingAnim(playerPed, "amb@world_human_seat_wall_tablet@female@base", "base", 3) then
            RequestAnimDict("amb@world_human_seat_wall_tablet@female@base")
            while not HasAnimDictLoaded("amb@world_human_seat_wall_tablet@female@base") do
                Wait(100)
            end
            
            TaskPlayAnim(playerPed, "amb@world_human_seat_wall_tablet@female@base", "base", 2.0, 2.0, -1, 51, 0, false, false, false)
        end
    end
end

-- Play close menu animation
function PlayCloseMenuAnimation()
    local playerPed = PlayerPedId()
    
    if Config.EnableAnimations then
        ClearPedTasks(playerPed)
    end
end

-- Get player identifier (utility function)
function GetPlayerIdentifier()
    return PlayerData.citizenid
end

-- NUI Callbacks

-- Close menu
RegisterNUICallback('close', function(data, cb)
    CloseBossMenu()
    cb('ok')
end)

-- Get employees
RegisterNUICallback('getEmployees', function(data, cb)
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':getEmployees', function(employees)
        cb({success = true, employees = employees})
    end)
end)

-- Get online employees
RegisterNUICallback('getOnlineEmployees', function(data, cb)
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':getOnlineEmployees', function(onlineEmployees)
        cb({success = true, onlineEmployees = onlineEmployees})
    end)
end)

-- Get duty statuses
RegisterNUICallback('getDutyStatuses', function(data, cb)
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':getDutyStatuses', function(dutyStatuses)
        cb({success = true, dutyStatuses = dutyStatuses})
    end)
end)

-- Update duty status
RegisterNUICallback('updateDutyStatus', function(data, cb)
    if not data.status then
        cb({success = false, message = 'Invalid status'})
        return
    end
    
    -- Update local variable
    playerDutyStatus = data.status
    
    -- Send to server
    TriggerServerEvent('bossmenu:updateDutyStatus', data.status)
    
    cb({success = true, message = 'Status updated'})
end)

-- Change another employee's duty status (for managers)
RegisterNUICallback('changeEmployeeDutyStatus', function(data, cb)
    if not data.identifier or not data.status then
        cb({success = false, message = 'Invalid data'})
        return
    end
    
    -- Send to server
    TriggerServerEvent('bossmenu:changeEmployeeDutyStatus', data.identifier, data.status)
    
    cb({success = true, message = 'Status updated'})
end)

-- Get finances
RegisterNUICallback('getFinances', function(data, cb)
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':getSocietyMoney', function(money)
        QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':getTransactions', function(transactions)
            cb({success = true, money = money, transactions = transactions})
        end)
    end)
end)

-- Get candidate info
RegisterNUICallback('getCandidateInfo', function(data, cb)
    local id = tonumber(data.id)
    if not id then
        cb({success = false, message = 'Invalid ID'})
        return
    end
    
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':getCandidateInfo', function(candidateData)
        if candidateData then
            -- Send to UI
            SendNUIMessage({
                type = 'candidateInfo',
                candidateData = candidateData
            })
            
            cb({success = true, candidateData = candidateData})
        else
            cb({success = false, message = 'Player not found'})
        end
    end, id)
end)

-- Update grade
RegisterNUICallback('updateGrade', function(data, cb)
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':updateGrade', function(success, message, config)
        cb({success = success, message = message, config = config})
    end, data.grade, data.newData)
end)

-- Hire employee
RegisterNUICallback('hire', function(data, cb)
    print('[BOSSMENU CLIENT] Hiring employee with ID:', data.identifier, 'Grade:', data.grade)
    
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':hireEmployee', function(success, message)
        print('[BOSSMENU CLIENT] Hire callback received - Success:', success, 'Message:', message)
        cb({success = success, message = message})
        
        if success then
            print('[BOSSMENU CLIENT] Hire successful, refreshing data in 2 seconds...')
            SetTimeout(2000, function()
                RefreshAllBossMenuData()
            end)
        end
    end, data.identifier, data.grade)
end)

-- Fire employee
RegisterNUICallback('fire', function(data, cb)
    print('[BOSSMENU CLIENT] Firing employee with identifier:', data.identifier)
    
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':fireEmployee', function(success, message)
        print('[BOSSMENU CLIENT] Fire callback received - Success:', success, 'Message:', message)
        cb({success = success, message = message})
        
        if success then
            print('[BOSSMENU CLIENT] Fire successful, refreshing data in 2 seconds...')
            SetTimeout(2000, function()
                RefreshAllBossMenuData()
            end)
        end
    end, data.identifier)
end)

-- Promote employee
RegisterNUICallback('promote', function(data, cb)
    print('[BOSSMENU CLIENT] Promoting employee with identifier:', data.identifier, 'to grade:', data.grade)
    
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':promoteEmployee', function(success, message)
        print('[BOSSMENU CLIENT] Promote callback received - Success:', success, 'Message:', message)
        cb({success = success, message = message})
        
        if success then
            print('[BOSSMENU CLIENT] Promote successful, refreshing data in 2 seconds...')
            SetTimeout(2000, function()
                RefreshAllBossMenuData()
            end)
        end
    end, data.identifier, data.grade)
end)

-- Demote employee
RegisterNUICallback('demote', function(data, cb)
    print('[BOSSMENU CLIENT] Demoting employee with identifier:', data.identifier, 'to grade:', data.grade)
    
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':demoteEmployee', function(success, message)
        print('[BOSSMENU CLIENT] Demote callback received - Success:', success, 'Message:', message)
        cb({success = success, message = message})
        
        if success then
            print('[BOSSMENU CLIENT] Demote successful, refreshing data in 2 seconds...')
            SetTimeout(2000, function()
                RefreshAllBossMenuData()
            end)
        end
    end, data.identifier, data.grade)
end)

-- Withdraw money
RegisterNUICallback('withdraw', function(data, cb)
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':withdrawMoney', function(success, message, newBalance)
        cb({success = success, message = message, balance = newBalance})
    end, data.amount)
end)

-- Deposit money
RegisterNUICallback('deposit', function(data, cb)
    QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':depositMoney', function(success, message, newBalance)
        cb({success = success, message = message, balance = newBalance})
    end, data.amount)
end)

-- Close menu on ESC key
CreateThread(function()
    while true do
        Wait(0)
        
        if isBossMenuOpen then
            if IsControlJustReleased(0, Config.CloseKey) then
                CloseBossMenu()
            end
        else
            Wait(500)
        end
    end
end)

-- Refresh duty statuses periodically when menu is open
CreateThread(function()
    while true do
        Wait(5000) -- Update every 5 seconds
        
        if isBossMenuOpen then
            QBCore.Functions.TriggerCallback('bossmenu_' .. PlayerData.job.name .. ':getDutyStatuses', function(dutyStatuses)
                SendNUIMessage({
                    type = 'updateDutyStatuses',
                    dutyStatuses = dutyStatuses
                })
            end)
        else
            Wait(1000)
        end
    end
end)