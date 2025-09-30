local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("nv_security_cam:server:checkJob")
AddEventHandler("nv_security_cam:server:checkJob",function()
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local playerJob = xPlayer.PlayerData.job.name
	for _,job in pairs(config.jobsThatCanOpenTablet) do
		if playerJob == job then
			TriggerClientEvent("nv_security_cam:client:setJob",source,true)
			break
		else
			TriggerClientEvent("nv_security_cam:client:setJob",source,false)
		end
	end

end)