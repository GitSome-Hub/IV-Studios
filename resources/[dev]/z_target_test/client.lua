-- Look at any PED and you should see this option
exports.ox_target:addGlobalPed({
    {
        name = 'hello_ped',
        label = 'Say hello',
        icon = 'fa-solid fa-hand',
        distance = 2.0,
        onSelect = function(data)
            -- data.entity is the ped you targeted
            lib.notify({
                description = 'Hello from ox_target!',
                type = 'success'
            })
        end
    }
})

-- Look at any VEHICLE and you should see this option
exports.ox_target:addGlobalVehicle({
    {
        name = 'open_hood',
        label = 'Pop hood',
        icon = 'fa-solid fa-car',
        distance = 2.5,
        onSelect = function(data)
            local veh = data and data.entity or 0
            if veh == 0 then
                -- Fallback to the vehicle you're in
                veh = GetVehiclePedIsIn(PlayerPedId(), false)
            end
            if veh ~= 0 then
                SetVehicleDoorOpen(veh, 4, false, false) -- 4 = hood
            end
        end
    }
})


