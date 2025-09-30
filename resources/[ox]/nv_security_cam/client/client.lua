local securityCameras = {}
local currentCameraIndex = 0
local camBefore = {}
local cam = nil
local inCam = false
local camItem = false
local tabletObject
local maxRotation = 60
local maxUp = 30
local oc = {mleft=0,mright=0,mup=0,mdown=0}
local newCamHP = 950
local haveJob = false

config.camModels = {
	'prop_cctv_cam_06a',
	'prop_cctv_cam_01b',
	'prop_cctv_cam_07a',
	'prop_cctv_cam_01a',
	'prop_cctv_cam_03a',
	'prop_cctv_cam_02a',
	'hei_prop_bank_cctv_01',
	'prop_cctv_cam_05a'
}

config.locationNames = {
	AIRP = "Los Santos International Airport",
	ALAMO = "Alamo Sea",
	ALTA = "Alta",
	ARMYB = "Fort Zancudo",
	BANHAMC = "Banham Canyon Dr",
	BANNING = "Banning",
	BEACH = "Vespucci Beach",
	BHAMCA = "Banham Canyon",
	BRADP = "Braddock Pass",
	BRADT = "Braddock Tunnel",
	BURTON = "Burton",
	CALAFB = "Calafia Bridge",
	CANNY = "Raton Canyon",
	CCREAK = "Cassidy Creek",
	CHAMH = "Chamberlain Hills",
	CHIL = "Vinewood Hills",
	CHU = "Chumash",
	CMSW = "Chiliad Mountain State Wilderness",
	CYPRE = "Cypress Flats",
	DAVIS = "Davis",
	DELBE = "Del Perro Beach",
	DELPE = "Del Perro",
	DELSOL = "La Puerta",
	DESRT = "Grand Senora Desert",
	DOWNT = "Downtown",
	DTVINE = "Downtown Vinewood",
	EAST_V = "East Vinewood",
	EBURO = "El Burro Heights",
	ELGORL = "El Gordo Lighthouse",
	ELYSIAN = "Elysian Island",
	GALFISH = "Galilee",
	GOLF = "GWC and Golfing Society",
	GRAPES = "Grapeseed",
	GREATC = "Great Chaparral",
	HARMO = "Harmony",
	HAWICK = "Hawick",
	HORS = "Vinewood Racetrack",
	HUMLAB = "Humane Labs and Research",
	JAIL = "Bolingbroke Penitentiary",
	KOREAT = "Little Seoul",
	LACT = "Land Act Reservoir",
	LAGO = "Lago Zancudo",
	LDAM = "Land Act Dam",
	LEGSQU = "Legion Square",
	LMESA = "La Mesa",
	LOSPUER = "La Puerta",
	MIRR = "Mirror Park",
	MORN = "Morningwood",
	MOVIE = "Richards Majestic",
	MTCHIL = "Mount Chiliad",
	MTGORDO = "Mount Gordo",
	MTJOSE = "Mount Josiah",
	MURRI = "Murrieta Heights",
	NCHU = "North Chumash",
	NOOSE = "N.O.O.S.E",
	OCEANA = "Pacific Ocean",
	PALCOV = "Paleto Cove",
	PALETO = "Paleto Bay",
	PALFOR = "Paleto Forest",
	PALHIGH = "Palomino Highlands",
	PALMPOW = "Palmer-Taylor Power Station",
	PBLUFF = "Pacific Bluffs",
	PBOX = "Pillbox Hill",
	PROCOB = "Procopio Beach",
	RANCHO = "Rancho",
	RGLEN = "Richman Glen",
	RICHM = "Richman",
	ROCKF = "Rockford Hills",
	RTRAK = "Redwood Lights Track",
	SANAND = "San Andreas",
	SANCHIA = "San Chianski Mountain Range",
	SANDY = "Sandy Shores",
	SKID = "Mission Row",
	SLAB = "Stab City",
	STAD = "Maze Bank Arena",
	STRAW = "Strawberry",
	TATAMO = "Tataviam Mountains",
	TERMINA = "Terminal",
	TEXTI = "Textile City",
	TONGVAH = "Tongva Hills",
	TONGVAV = "Tongva Valley",
	VCANA = "Vespucci Canals",
	VESP = "Vespucci",
	VINE = "Vinewood",
	WINDF = "Ron Alternates Wind Farm",
	WVINE = "West Vinewood",
	ZANCUDO = "Zancudo River",
	ZP_ORT = "Port of South Los Santos",
	ZQ_UAR = "Davis Quartz",
	PROL = "Prologue / North Yankton",
	ISHeist = "Cayo Perico Island"
}

RegisterNetEvent("nv_security_cam:client:setJob")
AddEventHandler("nv_security_cam:client:setJob",function(data)
	haveJob = data
end)

Citizen.CreateThread(function()
	DoScreenFadeIn(300)
	SetTimecycleModifier("default")
	scan_for_cameras()
end)

RegisterNetEvent("nv_security_cam:client:update_nui")
AddEventHandler("nv_security_cam:client:update_nui",function(data)
	SendNUIMessage(data)
end)


RegisterNetEvent("nv_security_cam:client:notify")
AddEventHandler("nv_security_cam:client:notify",function(msg)
	showNotification(msg)
end)


local model360 = {"prop_cctv_cam_07a"}
RegisterNUICallback("doCommand",function(data,cb)
	cb({status=true})
	if data.type == "mup" then
		local camHP = GetEntityHealth(camItem.entity)
		if camHP < newCamHP then
			return
		end
		local camRot = GetCamRot(cam)
		if oc.mup == maxUp then
			return
		end
		oc.mup += 1
		oc.mdown -= 1
		SetCamRot(cam,camRot.x+1, camRot.y, camRot.z)
		return
	end
	if data.type == "mdown" then
		local camHP = GetEntityHealth(camItem.entity)
		if camHP < newCamHP then
			return
		end
		local camRot = GetCamRot(cam)
		if oc.mdown == maxUp then
			return
		end
		oc.mdown += 1
		oc.mup -= 1
		SetCamRot(cam,camRot.x-1, camRot.y, camRot.z)
		return
	end

	if data.type == "mleft" then
		local camHP = GetEntityHealth(camItem.entity)
		if camHP < newCamHP then
			return
		end
		local camRot = GetCamRot(cam)
		if oc.mleft == maxRotation and not table.contains(model360, camItem.model) then
			return
		end
		oc.mleft += 1
		oc.mright -= 1
		SetCamRot(cam,camRot.x, camRot.y, camRot.z+1)
		return
	end
	if data.type == "mright" then
		local camHP = GetEntityHealth(camItem.entity)
		if camHP < newCamHP then
			return
		end
		local camRot = GetCamRot(cam)
		if oc.mright == maxRotation and not table.contains(model360, camItem.model) then
			return
		end
		oc.mright += 1
		oc.mleft -= 1
		SetCamRot(cam,camRot.x, camRot.y, camRot.z-1)
		return
	end

	if data.type == "left" then
		cam_join(currentCameraIndex-1)
		return
	end
	if data.type == "right" then
		cam_join(currentCameraIndex+1)
		return
	end
	if data.type == "zoomin" then
		local camHP = GetEntityHealth(camItem.entity)
		if camHP < newCamHP then
			return
		end
		local cFov = GetCamFov(cam)
		if cFov-1 <= 10 then
			return
		end
		SetCamFov(cam,cFov-1)
		return
	end
	if data.type == "zoomout" then
		local camHP = GetEntityHealth(camItem.entity)
		if camHP < newCamHP then
			return
		end
		local cFov = GetCamFov(cam)
		if cFov >= 80 then
			return
		end
		SetCamFov(cam,cFov+1)
		return
	end
	TriggerServerEvent("nv_security_cam:server:doCommand",data)
end)

function showNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	EndTextCommandThefeedPostMessagetext(config.notifyIcon, config.notifyIcon, true, 1, config.notifyName, config.notifyDesc)
	DrawNotification(true, false)
end


RegisterNetEvent("nv_security_cam:client:openCams")
AddEventHandler("nv_security_cam:client:openCams",function()
	scan_for_cameras()
	if 1 > #securityCameras then
		TriggerEvent("nv_security_cam:client:notify","There are no security cameras in this area.")
		return
	end
	local camera = securityCameras[1]
	if not camera then
		TriggerEvent("nv_security_cam:client:notify","That camera is not found.")
		return
	end

	local playerPed = PlayerPedId()

	RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@base")
	while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base") do
		Citizen.Wait(100)
	end
	
	TaskPlayAnim(playerPed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)
	
	local tabletModel = "prop_cs_tablet"
	local boneIndex = GetPedBoneIndex(playerPed, 60309)
	
	RequestModel(tabletModel)
	while not HasModelLoaded(tabletModel) do
		Citizen.Wait(100)
	end
	
	tabletObject = CreateObject(GetHashKey(tabletModel), 0, 0, 0, true, true, true)
	AttachEntityToEntity(tabletObject, playerPed, boneIndex, 0.03, 0.002, -0.02, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

	SetNuiFocus(true,true)
	cam_join(1)
	TriggerEvent("nv_security_cam:client:update_nui",{type="visible",data=true})
end)

RegisterCommand(config.command,function()
	TriggerServerEvent("nv_security_cam:server:checkJob")
	Wait(200)
	if not haveJob then
		TriggerEvent("nv_security_cam:client:notify",config.noJobMsg)
		return
	end 
	TriggerEvent('nv_security_cam:client:openCams')
end)

RegisterNUICallback("exit",function(data,cb)
	if tabletObject then
		DeleteObject(tabletObject)
	end
	ClearPedTasksImmediately(PlayerPedId())
	DoScreenFadeOut(300)
	Wait(300)
	cb({status=true})
	SetNuiFocus(false,false)
	TriggerEvent("nv_security_cam:client:update_nui",{type="visible",data=false})
	RenderScriptCams(false, false, 0, true, true)
	DestroyCam(cam, false)
	cam = nil
	currentCameraIndex = 0
	camItem = nil
	SetTimecycleModifier("default")
	DoScreenFadeIn(300)
	Wait(300)
end)

function scan_for_cameras()
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local radius = 200.0
	securityCameras = {}
	models = config.camModels

	local modelHashes = {}
	for _, model in ipairs(models) do
		table.insert(modelHashes, GetHashKey(model))
	end

	for _, obj in ipairs(GetGamePool('CObject')) do
		local objCoords = GetEntityCoords(obj)
		local model = GetEntityModel(obj)
		for _, hash in ipairs(modelHashes) do
			if model == hash then
				local modelName = nil
				for _, name in ipairs(models) do
					if hash == GetHashKey(name) then
						modelName = name
						break
					end
				end
				local broken = false
				local camHP = GetEntityHealth(obj)
				if camHP < newCamHP then
					broken = true
				end
				table.insert(securityCameras, {
					entity = obj,
					model = modelName,
					zoneCode = GetNameOfZone(objCoords),
					zone = config.locationNames[GetNameOfZone(objCoords)],
					coords = objCoords,
					heading = GetEntityHeading(obj),
					rotation = GetEntityRotation(obj),
					index = #securityCameras +1,
					broken = broken
				})
				FreezeEntityPosition(obj,true)
				break
			end
		end
	end
	return securityCameras
end

function cam_join(index)
	local camera = securityCameras[index]
	if not camera then
		return
	end

	DoScreenFadeOut(300)
	Wait(300)
	local broken = false
	local camHP = GetEntityHealth(camera.entity)
	if camHP < 950 then
		SetEntityHealth(camera.entity,0)
		broken = true
	end

	camItem = camera
	inCam = false
	oc = {mleft=0,mright=0,mup=0,mdown=0}
	if cam then
		DestroyCam(cam, false)
	end

	local entityCoords = camera.coords
    local entityHeading = camera.heading

	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	if camera.model == "prop_cctv_cam_06a" then
		local radianHeading = math.rad(entityHeading+180)
    	local offsetX = -0.0 * math.sin(radianHeading)
    	local offsetY = 0.0 * math.cos(radianHeading)
    	local targetCoords = vector3(entityCoords.x + offsetX, entityCoords.y + offsetY, entityCoords.z)
    	local position = targetCoords
		SetCamCoord(cam, position.x, position.y, position.z-0.5)
		SetCamRot(cam,camera.rotation.x-25, camera.rotation.y, camera.heading+180)

	elseif camera.model == "prop_cctv_cam_01b" then
		local radianHeading = math.rad(entityHeading+180)
    	local offsetX = -0.95 * math.sin(radianHeading)
    	local offsetY = 0.95 * math.cos(radianHeading)
    	local targetCoords = vector3(entityCoords.x + offsetX, entityCoords.y + offsetY, entityCoords.z)
    	local position = targetCoords
		SetCamCoord(cam, position.x, position.y, position.z+0.3)
		SetCamRot(cam,camera.rotation.x-25, camera.rotation.y, camera.heading+180)

	elseif camera.model == "prop_cctv_cam_07a" then
		SetCamCoord(cam, camera.coords.x, camera.coords.y, camera.coords.z-0.1)
		SetCamRot(cam,camera.rotation.x-25, camera.rotation.y, camera.heading-200)

	elseif camera.model == "prop_cctv_cam_05a" then
		local radianHeading = math.rad(entityHeading+180)
    	local offsetX = -0.4 * math.sin(radianHeading)
    	local offsetY = 0.4 * math.cos(radianHeading)
    	local targetCoords = vector3(entityCoords.x + offsetX, entityCoords.y + offsetY, entityCoords.z)
    	local position = targetCoords
		SetCamCoord(cam, position.x, position.y, position.z-0.4)
		SetCamRot(cam,camera.rotation.x-25, camera.rotation.y, camera.heading-140)

	elseif camera.model == "prop_cctv_cam_01a" then
		local radianHeading = math.rad(entityHeading+180)
    	local offsetX = -1.2 * math.sin(radianHeading)
    	local offsetY = 1.2 * math.cos(radianHeading)
    	local targetCoords = vector3(entityCoords.x + offsetX, entityCoords.y + offsetY, entityCoords.z)
    	local position = targetCoords
		SetCamCoord(cam, position.x, position.y, position.z+0.4)
		SetCamRot(cam,camera.rotation.x-25, camera.rotation.y, camera.heading-140)

	elseif camera.model == "prop_cctv_cam_02a" then
		local radianHeading = math.rad(entityHeading+180)
    	local offsetX = -0.3 * math.sin(radianHeading)
    	local offsetY = 0.3 * math.cos(radianHeading)
    	local targetCoords = vector3(entityCoords.x + offsetX, entityCoords.y + offsetY, entityCoords.z)
    	local position = targetCoords
		SetCamCoord(cam, position.x, position.y, position.z)
		SetCamRot(cam,camera.rotation.x-15, camera.rotation.y, camera.heading+208)

	elseif camera.model == "prop_cctv_cam_03a" then
		local radianHeading = math.rad(entityHeading+180)
    	local offsetX = -1.5 * math.sin(radianHeading)
    	local offsetY = 3.0 * math.cos(radianHeading)
    	local targetCoords = vector3(entityCoords.x + offsetX, entityCoords.y + offsetY, entityCoords.z)
    	local position = targetCoords

		SetCamCoord(cam, position.x, position.y, position.z+0.4)
		SetCamRot(cam,camera.rotation.x-10, camera.rotation.y, camera.rotation.z+130)

	elseif camera.model == "hei_prop_bank_cctv_01" then
		SetCamCoord(cam, camera.coords.x, camera.coords.y, camera.coords.z-0.3)
		SetCamRot(cam,camera.rotation.x-25, camera.rotation.y, camera.heading+180)

	else
		SetCamCoord(cam, camera.coords.x, camera.coords.y, camera.coords.z-0.1)
		SetCamRot(cam,camera.rotation.x-25, camera.rotation.y, camera.heading+180)
	end

	camBefore.rot = GetCamRot(cam)
	if not broken then
		SetTimecycleModifier("CAMERA_BW")
		SetTimecycleModifierStrength(1.0)
	else
		SetTimecycleModifier("CAMERA_secuirity_FUZZ")
		SetTimecycleModifierStrength(10.0)
	end
	TriggerEvent("nv_security_cam:client:update_nui",{type="visible",data=true})
	SetCamFov(cam, 80.0)
	RenderScriptCams(true, false, 0, true, true)
	camera.broken = broken
	TriggerEvent("nv_security_cam:client:update_nui",{type="cam",data=camera})
	currentCameraIndex = index
	DoScreenFadeIn(300)
	Wait(300)
end


function table.contains(tbl, item)
	for _, v in ipairs(tbl) do
		if v == item then
			return true
		end
	end
	return false
end