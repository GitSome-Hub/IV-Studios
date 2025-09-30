-- This file was mentioned to be left untouched
-- Send to jail
RegisterNetEvent('vanguard_policejob:sendToJail', function(target, time)
    -- Add your jail event trigger here? WILL BE ADDING BUILT IN JAIL SYSTEM SOON!
    -- 'target' = Server ID of target / 'time' minutes input for months
    print('Jailing '..target..' for '..time..' minutes')
end)

playerLoaded, isDead, isBusy, disableKeys, hasJob, cuffProp, isCuffed, inMenu, isRagdoll, cuffTimer, escorting, escorted = nil, nil, nil, nil, nil, nil, nil, nil, nil, {}, {}, {}