local kargosiparisal = {}
local kargoaracblip = {}
local kargoyukleblip = {}
local isegiraktif = false
local aracspawnlandi = false
local itemibirakabilirmi = false
local nveh = nil
local l = 0
local stock = 0
local limitStock = 19
local prop
local area = 0
local veh
local HashKeyBox = 1405043423
local kutuprop = nil
local kutuprop2 = nil
local kutuprop3 = nil
local kutuprop4 = nil
local kutuprop5 = nil
local kutuprop6 = nil
local kutuprop7 = nil
local kutuprop8 = nil
local kutuprop9 = nil
local kutuprop10 = nil
local kutuprop11 = nil
local kutuprop12 = nil
local kutuprop13 = nil
local kutuprop14 = nil
local kutuprop15 = nil
local kutuprop16 = nil
local kutuprop17 = nil
local kutuprop18 = nil
local kutuprop19 = nil
local kutuprop20 = nil
local kutuprop21 = nil
local kapidurum = false
local teslimedilen = 0

local gorevler = {
	{ x = 67.25, y = -1399.04, z = 29.37},
	{ x = -699.92, y = -147.08, z = 37.85},
	{ x = -823.49, y = -1065.7, z = 11.66},
	{ x = -1180.96, y = -752.32, z = 19.55},
	{ x = -1444.57, y = -257.53, z = 46.21},
	{ x = 9.89, y = 6505.95, z = 31.54},
	{ x = 1700.36, y = 4815.89, z = 41.94},
	{ x = 121.64, y = -240.45, z = 53.36},
	{ x = -1128.51, y = 2691.9, z = 18.81},
	{ x = -3160.19, y = 1044.99, z = 20.85},
	{ x = 1184.69, y = 2721.75, z = 38.63},
	{ x = 619.15, y = 2784.92, z = 43.49}
}

function LocalPed()
	return GetPlayerPed(-1)
end

function kargoarac ()
	Citizen.CreateThread(function()
	  while doru2 do
		if IsControlJustReleased(0, 38) and aracspawnlandi == false and isegiraktif then
            aracspawnetgari()
            aracspawnlandi = true
		elseif  IsControlJustReleased(0, 38) and aracspawnlandi == true and isegiraktif then
			local ped =PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
				local getarac = GetVehiclePedIsIn(ped)
                local model = GetEntityModel(getarac)
                local plaka= GetVehicleNumberPlateText(getarac)
                if model == 65402552 then
					-- TriggerServerEvent('esx_kargo:araciadesi', plaka)
				end
			end
            
              
          
		end

		Wait(5)
		 
	   end
	end)
end


function blipyaz()



         local blip = AddBlipForCoord(vector3(707.26,-966.9,30.41))
 
         SetBlipSprite (blip, 67)
         SetBlipDisplay(blip, 4)
         SetBlipScale  (blip, 0.6)
         SetBlipColour (blip, 54)
         SetBlipAsShortRange(blip, true)
 
         BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Get Cargo Order')
         EndTextCommandSetBlipName(blip)
         table.insert(kargosiparisal,blip)
  
 
 end

RegisterNetEvent('esx_kargo:blipyaz')
AddEventHandler('esx_kargo:blipyaz', function()
    blipyaz()
end)

RegisterNetEvent('esx_kargo:aracsil')
AddEventHandler('esx_kargo:aracsil', function()
    local ped =PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local getarac = GetVehiclePedIsIn(ped)
        local model = GetEntityModel(getarac)
        local plaka= GetVehicleNumberPlateText(getarac)
        if model == 65402552 then
            -- local success = exports["vehicle-manager"]:DeleteVehicle(getarac, false)
	        QBCore.Functions.DeleteVehicle(getarac)

           TriggerServerEvent('esx_kargo:odulver', teslimedilen)
        
           for k, v in pairs(kargoaracblip) do
            RemoveBlip(v)
           end
           for k, v in pairs(kargoyukleblip) do
            RemoveBlip(v)
           end
		   RemoveBlip(blips)
		   SetWaypointOff()
		   visits = 1
		   teslimedilen = 0
		    isegiraktif = false
		    aracspawnlandi = false
		    itemibirakabilirmi = false
		    nveh = nil
		    l = 0
		    stock = 0
		    limitStock = 19
		    area = 0

			if DoesEntityExist(kutuprop) then
			DetachEntity(kutuprop,false,false)
			FreezeEntityPosition(kutuprop,false)
            DeleteEntity(kutuprop)
            kutuprop = nil
			end
			if DoesEntityExist(kutuprop2) then
				DetachEntity(kutuprop2,false,false)
				FreezeEntityPosition(kutuprop2,false)
				DeleteEntity(kutuprop2)
				kutuprop2 = nil
			end
			if DoesEntityExist(kutuprop3) then
				DetachEntity(kutuprop3,false,false)
				FreezeEntityPosition(kutuprop3,false)
				DeleteEntity(kutuprop3)
				kutuprop3 = nil
			end
			if DoesEntityExist(kutuprop4) then
				DetachEntity(kutuprop4,false,false)
				FreezeEntityPosition(kutuprop4,false)
				DeleteEntity(kutuprop4)
				kutuprop4 = nil
			end
			if DoesEntityExist(kutuprop5) then
				DetachEntity(kutuprop5,false,false)
				FreezeEntityPosition(kutuprop5,false)
				DeleteEntity(kutuprop5)
				kutuprop5 = nil
			end
			if DoesEntityExist(kutuprop6) then
				DetachEntity(kutuprop6,false,false)
				FreezeEntityPosition(kutuprop6,false)
				DeleteEntity(kutuprop6)
				kutuprop6 = nil
			end
			if DoesEntityExist(kutuprop7) then
				DetachEntity(kutuprop7,false,false)
				FreezeEntityPosition(kutuprop7,false)
				DeleteEntity(kutuprop7)
				kutuprop7 = nil
			end
			if DoesEntityExist(kutuprop8) then
				DetachEntity(kutuprop8,false,false)
				FreezeEntityPosition(kutuprop8,false)
				DeleteEntity(kutuprop8)
				kutuprop8 = nil
			end
			if DoesEntityExist(kutuprop9) then
				DetachEntity(kutuprop9,false,false)
				FreezeEntityPosition(kutuprop9,false)
				DeleteEntity(kutuprop9)
				kutuprop9 = nil
			end
			if DoesEntityExist(kutuprop10) then
				DetachEntity(kutuprop10,false,false)
				FreezeEntityPosition(kutuprop10,false)
				DeleteEntity(kutuprop10)
				kutuprop10 = nil
			end
			if DoesEntityExist(kutuprop11) then
				DetachEntity(kutuprop11,false,false)
				FreezeEntityPosition(kutuprop11,false)
				DeleteEntity(kutuprop11)
				kutuprop11 = nil
			end
			if DoesEntityExist(kutuprop12) then
				DetachEntity(kutuprop12,false,false)
				FreezeEntityPosition(kutuprop12,false)
				DeleteEntity(kutuprop12)
				kutuprop12 = nil
			end
			if DoesEntityExist(kutuprop13) then
				DetachEntity(kutuprop13,false,false)
				FreezeEntityPosition(kutuprop13,false)
				DeleteEntity(kutuprop13)
				kutuprop13 = nil
			end
			if DoesEntityExist(kutuprop14) then
				DetachEntity(kutuprop14,false,false)
				FreezeEntityPosition(kutuprop14,false)
				DeleteEntity(kutuprop14)
				kutuprop14 = nil
			end
			if DoesEntityExist(kutuprop15) then
				DetachEntity(kutuprop15,false,false)
				FreezeEntityPosition(kutuprop15,false)
				DeleteEntity(kutuprop15)
				kutuprop15 = nil
			end
			if DoesEntityExist(kutuprop16) then
				DetachEntity(kutuprop16,false,false)
				FreezeEntityPosition(kutuprop16,false)
				DeleteEntity(kutuprop16)
				kutuprop16 = nil
			end
			if DoesEntityExist(kutuprop17) then
				DetachEntity(kutuprop17,false,false)
				FreezeEntityPosition(kutuprop17,false)
				DeleteEntity(kutuprop17)
				kutuprop17 = nil
			end
			if DoesEntityExist(kutuprop18) then
				DetachEntity(kutuprop18,false,false)
				FreezeEntityPosition(kutuprop18,false)
				DeleteEntity(kutuprop18)
				kutuprop18 = nil
			end
			if DoesEntityExist(kutuprop19) then
				DetachEntity(kutuprop19,false,false)
				FreezeEntityPosition(kutuprop19,false)
				DeleteEntity(kutuprop19)
				kutuprop19 = nil
			end
			if DoesEntityExist(kutuprop20) then
				DetachEntity(kutuprop20,false,false)
				FreezeEntityPosition(kutuprop20,false)
				DeleteEntity(kutuprop20)
				kutuprop20 = nil
			end

        end
    end
end)

function startjob()
    isegiraktif = true
	area = 1
	if area == 1 then 
	l = math.random(1,12)
	end
	gorevblipleri(locs,selecionado)
end

RegisterNetEvent('els_family:mission:trailjob')
AddEventHandler('els_family:mission:trailjob', function()
    print('...')
    yournotify('You Started Your Cargo Duty.', 3000)
   

    createjobzone()
   
    Wait(1000)
    aracblipolustur()
    startjob()
  
end)


function createjobzone()



    kargoaraccikart = CircleZone:Create(vector3(711.16, -984.87, 24.12), 3.3,

    {
        name=kargoaraccikart,
        -- minZ=51.0,
        -- maxZ=62.0,
        debugGrid=true
        -- gridDivisions=25
    })

    kargoaraccikart:onPlayerInOut(function(isPointInside, point, dsss)
        if isPointInside then
        
            if isegiraktif then
                
				TriggerEvent('els_family:drawtexton', "[E] Take out a cargo vehicle")

                kargoarac()
                doru2 = true
            end
        else
            TriggerEvent('els_family:drawtextoff')
            doru = false
            doru2 = false
        end

    end)  
end


function aracblipolustur()
 
    local arackonum = AddBlipForCoord(vector3(711.16, -984.87, 24.12))
 
    SetBlipSprite (arackonum, 67)
    SetBlipDisplay(arackonum, 4)
    SetBlipScale  (arackonum, 0.4)
    SetBlipColour (arackonum, 54)
    SetBlipAsShortRange(arackonum, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Kargo Arac Cikart')
    EndTextCommandSetBlipName(arackonum)
    table.insert(kargoaracblip,arackonum)
    yournotify('Go to the desired region by removing a vehicle from outside.', 3000)
	Wait(1000)
    yournotify('You Can Get The Cargo Boxes From The Yellow Mark...', 3000)

   
    kargolariyukle()
end


function aracspawnetgari()
    local vehicleModel = "Youga"
    if not nveh then
       local plakasi = nil
        QBCore.Functions.SpawnVehicle(vehicleModel, function(vehicle)
            -- SetVehicleNumberPlateText(vehicle, data.vehicleplate)
            SetPedIntoVehicle(PlayerPedId(),vehicle, -1)
            SetEntityHeading(PlayerPedId(), 270.22)
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
            
        end, vector3(718.31, -984.84, 24.15))
    
    

    end
end




Citizen.CreateThread(function()
	while true do
		wait = 1000
	
	
		if isegiraktif then 		
			wait = 5
		
			if GetDistanceBetweenCoords(gorevler[l].x,gorevler[l].y,gorevler[l].z, GetEntityCoords(GetPlayerPed(-1))) < 30.0 then
				DrawMarker(21,gorevler[l].x, gorevler[l].y, gorevler[l].z,0,0,0,0.0,0,0,0.5,0.5,0.4,255,0,0,50,0,0,0,1)		
			end
			if GetDistanceBetweenCoords(gorevler[l].x,gorevler[l].y,gorevler[l].z, GetEntityCoords(GetPlayerPed(-1))) < 1.0 then
				if not IsInVehicle() and itemibirakabilirmi then
					drawTxt(" ~b~E~s~ Deliver with Key", 4,0.5,0.93,0.50,255,255,255,180)
					if (IsControlJustReleased(1, 38)) then
						deliverysucces()
					end
				end
			end
		end
		Citizen.Wait(wait)
	end
end)


Citizen.CreateThread(function()
	while true do
	wait = 1000
		local myCoords = GetEntityCoords(GetPlayerPed(-1))
		veh = getNearVeh(8)
		local model = GetEntityModel(veh)
		
		if model == 65402552 and isegiraktif and itemibirakabilirmi then	
			wait = 5
			coordsCar = GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.50, 0.0)	
			local distance = GetDistanceBetweenCoords(myCoords.x, myCoords.y, myCoords.z, coordsCar.x,coordsCar.y,coordsCar.z, true)
			if distance < 1.0 and isegiraktif and itemibirakabilirmi then
				yakinkargoaraci = true
				openMenuDeliveryCar(yakinkargoaraci)
			elseif distance >= 3.0 and isegiraktif and itemibirakabilirmi then
				yakinkargoaraci = false
				openMenuDeliveryCar(yakinkargoaraci)
			end
		end	
		
		if model == 65402552 and isegiraktif and not itemibirakabilirmi then
			wait = 5
			coordsCar2 = GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.50, 0.0)	
			local distance2 = GetDistanceBetweenCoords(myCoords.x, myCoords.y, myCoords.z, coordsCar2.x,coordsCar2.y,coordsCar2.z, true)
			if distance2 < 1.0 and isegiraktif and not itemibirakabilirmi then
				yakinkargoaraci2 = true
				getBoxOnCar(yakinkargoaraci2)
			elseif distance2 >= 3.0 and isegiraktif and not itemibirakabilirmi then
				yakinkargoaraci2 = false
				getBoxOnCar(yakinkargoaraci2)
			end
		end	
		Citizen.Wait(wait)		
	end	
end)

function getNearVeh(radius)
	local playerPed = GetPlayerPed(-1)
	local coordA = GetEntityCoords(playerPed, 1)
	local coordB = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, radius+0.00001, 0.0)
	local nearVehicle = getVehicleInDirection(coordA, coordB)

	if IsEntityAVehicle(nearVehicle) then
	    return nearVehicle
	else
		local x,y,z = table.unpack(coordA)
	    if IsPedSittingInAnyVehicle(playerPed) then
	        local veh = GetVehiclePedIsIn(playerPed, true)
	        return veh
	    else
	        local veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+0.0001, 0, 8192+4096+4+2+1)
	        if not IsEntityAVehicle(veh) then veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+0.0001, 0, 4+2+1) end
	        return veh
	    end
	end
end

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function IsInVehicle()
    local ply = GetPlayerPed(-1)
        if IsPedSittingInAnyVehicle(ply) then
            return true
        else
            return false
        end
end


function openMenuDeliveryCar(yakinkargoaraci)
	local ply = GetPlayerPed(-1)
	local veh = GetStockPosition(10)
	local coordsStock = GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.8, 0.0)
	local model = GetEntityModel(veh)
	if yakinkargoaraci and itemibirakabilirmi and kapidurum == true then
		if stock <= limitStock then
			drawTxt(" ~b~E~s~ tusu ile kutuyu koy", 4,0.5,0.93,0.50,255,255,255,180)
			if IsControlJustPressed(1, 38) then
				kutustoklari(veh,model)
				local pid = PlayerPedId()
				DetachEntity(prop, true, false)
				SetEntityCoords(prop, 0.0, 0.0, 0.0, false, false, false, true)
				itemibirakabilirmi = false
				RequestAnimDict("anim@heists@money_grab@briefcase")
				while (not HasAnimDictLoaded("anim@heists@money_grab@briefcase")) do
					Citizen.Wait(10) 
				end
				TaskPlayAnim(pid,"anim@heists@money_grab@briefcase","put_down_case",100.0, 200.0, 0.3, 120, 0.2, 0, 0, 0)
				Wait(2000)
				StopAnimTask(pid, "anim@heists@money_grab@briefcase","put_down_case", 1.0)
				stock = stock + 1	
			end
		else
			drawTxt("You can't carry any more full vehicles.", 4,0.5,0.93,0.50,255,255,255,180)
		end
	end
end


function GetStockPosition(radius)
	local ped = PlayerPedId()
	local coordsx = GetEntityCoords(ped, 1)
	local coordsy = GetOffsetFromEntityInWorldCoords(ped, 0.0, radius+0.00001, 0.0)
	local nearVehicle = GetStockDirection(coordsx, coordsy)
	if IsEntityAVehicle(nearVehicle) then
	    return nearVehicle
	else
		local x,y,z = table.unpack(coordsx)
	    if IsPedSittingInAnyVehicle(ped) then
	        local veh = GetVehiclePedIsIn(ped,true)
	        return veh
	    else
	        local veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001,radius+0.0001,0,8192+4096+4+2+1) 
	        if not IsEntityAVehicle(veh) then 
	        	veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001,radius+0.0001,0,4+2+1) 
	        end 
	        return veh
	    end
	end
end

function GetStockDirection(coordFrom,coordTo)
	local position = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local a,b,c,d,vehicle = GetRaycastResult(position)
	return vehicle
end


Citizen.CreateThread(function()
	while true do
		wait = 1000
		local veh = GetStockPosition(10)
		local coordsStock = GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.6, 0.0)
        local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),coordsStock.x,coordsStock.y,coordsStock.z,true)
        local model = GetEntityModel(veh)
      

		if distance <= 1.0 and not IsPedInAnyVehicle(PlayerPedId()) and isegiraktif then
			wait = 5
            
			if model == 65402552 then
              
			    if kapidurum == false then
                   
			        DrawText3Ds(coordsStock.x,coordsStock.y,coordsStock.z+0.95,"~b~[X] ~w~ Open Door")
				    if IsControlJustPressed(0,154) then
				        SetVehicleDoorOpen(veh, 3, false, false)
						SetVehicleDoorOpen(veh, 2, false, false)
				        kapidurum = true
				    end
                elseif kapidurum == true then
                   

	                DrawText3Ds(coordsStock.x,coordsStock.y,coordsStock.z+0.95,"~b~[X] ~w~Close Door")
				    if IsControlJustPressed(0,154) then
				        SetVehicleDoorShut(veh, 3, false)
						SetVehicleDoorShut(veh, 2, false)
				        kapidurum = false
					end
				end
            end
        end
		if distance <= 1.5 and not IsPedInAnyVehicle(PlayerPedId()) and isegiraktif then
			wait = 5
			if model ==  65402552  then
				DrawText3Ds(coordsStock.x,coordsStock.y,coordsStock.z+0.7,"  ~b~"..stock.."~w~  /  ~b~20    ")
			end
		end
		Citizen.Wait(wait)
    end
end)


function kutustoklari(veh,model)
	if stock <= limitStock then
		RequestModel(GetHashKey("prop_apple_box_01"))
        while not HasModelLoaded(GetHashKey("prop_apple_box_01")) do
            Citizen.Wait(10)
        end
	    local coords = GetOffsetFromEntityInWorldCoords(veh,0.0,0.0,-5.0)
		if stock == 0 and model ==  65402552 then
			kutuprop = nil
			kutuprop = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop,veh,0.0,-0.45,-2.2,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop,true)
		elseif stock == 1 and model ==  65402552 then
			kutuprop2 = nil
			kutuprop2 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop2,veh,0.0,0.0,-2.2,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop2,true)
		elseif stock == 2 and model ==  65402552 then
			kutuprop3 = nil
			kutuprop3 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop3,veh,0.0,0.45,-2.2,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop3,true)
		elseif stock == 3 and model ==  65402552 then
			kutuprop4 = nil
			kutuprop4 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop4,veh,0.0,-0.45,-1.8,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop4,true)
		elseif stock == 4 and model ==  65402552 then
			kutuprop5 = nil
			kutuprop5 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop5,veh,0.0,0.0,-1.8,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop5,true)
		elseif stock == 5 and model ==  65402552 then
			kutuprop6 = nil
			kutuprop6 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop6,veh,0.0,0.45,-1.8,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop6,true)
		elseif stock == 6 and model ==  65402552 then
			kutuprop7 = nil
			kutuprop7 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop7,veh,0.0,-0.45,-1.4,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop7,true)
		elseif stock == 7 and model ==  65402552 then
			kutuprop8 = nil
			kutuprop8 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop8,veh,0.0,0.0,-1.4,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop8,true)
		elseif stock == 8 and model ==  65402552 then
			kutuprop9 = nil
			kutuprop9 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop9,veh,0.0,0.45,-1.4,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop9,true)
		elseif stock == 9 and model ==  65402552 then
			kutuprop10 = nil
			kutuprop10 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop10,veh,0.0,-0.45,-1.0,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop10,true)
		elseif stock == 10 and model ==  65402552 then
			kutuprop11 = nil
			kutuprop11 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop11,veh,0.0,0.0,-1.0,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop11,true)
		elseif stock == 11 and model ==  65402552 then
			kutuprop12 = nil
			kutuprop12 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop12,veh,0.0,0.45,-1.0,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop12,true)
		elseif stock == 12 and model ==  65402552 then
			kutuprop13 = nil
			kutuprop13 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop13,veh,0.0,-0.45,-0.6,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop13,true)
		elseif stock == 13 and model ==  65402552 then
			kutuprop14 = nil
			kutuprop14 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop14,veh,0.0,0.0,-0.6,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop14,true)
		elseif stock == 14 and model ==  65402552 then
			kutuprop15 = nil
			kutuprop15 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop15,veh,0.0,0.45,-0.6,0.20,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop15,true)
		elseif stock == 15 and model ==  65402552 then
			kutuprop16 = nil
			kutuprop16 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop16,veh,0.0,-0.45,-0.6,0.45,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop16,true)
		elseif stock == 16 and model ==  65402552 then
			kutuprop17 = nil
			kutuprop17 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop17,veh,0.0,0.0,-0.6,0.45,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop17,true)
		elseif stock == 17 and model ==  65402552 then
			kutuprop18 = nil
			kutuprop18 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop18,veh,0.0,0.45,-0.6,0.45,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop18,true)
		elseif stock == 18 and model ==  65402552 then
			kutuprop19 = nil
			kutuprop19 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop19,veh,0.0,-0.45,-1.0,0.45,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop19,true)
		elseif stock == 19 and model ==  65402552 then
			kutuprop20 = nil
			kutuprop20 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop20,veh,0.0,0.0,-1.0,0.45,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop20,true)
		elseif stock == 20 and model ==  65402552 then
			kutuprop21 = nil
			kutuprop21 = CreateObject(GetHashKey("prop_apple_box_01"),coords.x,coords.y,coords.z,true,true,true)
			AttachEntityToEntity(kutuprop21,veh,0.0,0.45,-1.0,0.45,0.0,0.0,0.0,false,false,true,false,2,true)
			FreezeEntityPosition(kutuprop21,true)		
		end
	end
end


function getBoxOnCar(yakinkargoaraci2)
	if yakinkargoaraci2 and not itemibirakabilirmi and GetDistanceBetweenCoords(gorevler[l].x,gorevler[l].y,gorevler[l].z, GetEntityCoords(GetPlayerPed(-1))) < 20.0 and kapidurum == true then
		if stock >= 1 then
			drawTxt("~b~E~s~ tusu ile kutu al", 4,0.5,0.93,0.50,255,255,255,180)
			if (IsControlJustPressed(1, 38)) then
				Citizen.Wait(100)	
				itemibirakabilirmi = true
				Propsil()
			end				
			if itemibirakabilirmi then
				local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
				local prop = CreateObject(HashKeyBox, x+5.5, y+5.5, z+0.2,  true,  true, true)
				AttachEntityToEntity(prop, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 11816), -0.17, 0.38, -0.050, 15.0, 285.0, 270.0, true, true, false, true, 1, true)
				RequestAnimDict('anim@heists@box_carry@')
				while not HasAnimDictLoaded('anim@heists@box_carry@') do
					Wait(0)
				end
				TaskPlayAnim(GetPlayerPed(-1), 'anim@heists@box_carry@', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
				repeat
				Citizen.Wait(100)
				if itemibirakabilirmi == false then
					DeleteEntity(prop)
				end
				until(itemibirakabilirmi == false)	
			end
		else		
			drawTxt("Car is empty get more orders.", 4,0.5,0.93,0.50,255,255,255,180)
		end
	end
end

function DrawText3D(x,y,z, text, scl, font) 
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

	local scale = (1/dist)*scl
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
	if onScreen then
		SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 180)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
	end
end

function DrawText3Ds(x,y,z,text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.34, 0.34)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.001+ factor, 0.028, 0, 0, 0, 78)
end

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

Citizen.CreateThread(function()
	while true do
	wait = 1000
		local myCoords = GetEntityCoords(GetPlayerPed(-1))
		if isegiraktif then	
			wait = 5
			if GetDistanceBetweenCoords(myCoords.x, myCoords.y, myCoords.z, 751.45,-947.07,25.64, true) < 0.5 and isegiraktif then
				yakinkutufarm = true
				openMenuBox(yakinkutufarm)
			elseif GetDistanceBetweenCoords(myCoords.x, myCoords.y, myCoords.z, 751.45,-947.07,25.64, true) >= 0.5 and isegiraktif then
				yakinkutufarm = false
				openMenuBox(yakinkutufarm)
			end
		end		
		Citizen.Wait(wait)
	end	
end)


function openMenuBox(yakinkutufarm)
	if yakinkutufarm and isegiraktif then
		if stock <= limitStock then
			drawTxt(" ~b~E~s~ tusu ile kutu al", 4,0.5,0.93,0.50,255,255,255,180)
			if IsControlJustPressed(1, 38) then
				Citizen.Wait(100)	
				itemibirakabilirmi = true	
				-- vRP._DeletarObjeto()
			end
			if itemibirakabilirmi then
				local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
				local prop = CreateObject(HashKeyBox, x+5.5, y+5.5, z+0.2,  true,  true, true)
				AttachEntityToEntity(prop, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 11816), -0.17, 0.38, -0.050, 15.0, 285.0, 270.0, true, true, false, true, 1, true)
				RequestAnimDict('anim@heists@box_carry@')
				while not HasAnimDictLoaded('anim@heists@box_carry@') do
					Wait(0)
				end
				TaskPlayAnim(GetPlayerPed(-1), 'anim@heists@box_carry@', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
				repeat
				Citizen.Wait(100)
				if itemibirakabilirmi == false then
					DeleteEntity(prop)
				end
				until(itemibirakabilirmi == false)
			end
		else
			drawTxt("Car is full, make some deliveries", 4,0.5,0.93,0.50,255,255,255,180)
		end
	end
end

function Propsil()
	if stock == 1 then
        if DoesEntityExist(kutuprop) then
			DetachEntity(kutuprop,false,false)
			FreezeEntityPosition(kutuprop,false)
            DeleteEntity(kutuprop)
            kutuprop = nil
        end
	elseif stock == 2 then
		if DoesEntityExist(kutuprop2) then
			DetachEntity(kutuprop2,false,false)
			FreezeEntityPosition(kutuprop2,false)
            DeleteEntity(kutuprop2)
            kutuprop2 = nil
        end
	elseif stock == 3 then
		if DoesEntityExist(kutuprop3) then
			DetachEntity(kutuprop3,false,false)
			FreezeEntityPosition(kutuprop3,false)
            DeleteEntity(kutuprop3)
            kutuprop3 = nil
        end
	elseif stock == 4 then
		if DoesEntityExist(kutuprop4) then
			DetachEntity(kutuprop4,false,false)
			FreezeEntityPosition(kutuprop4,false)
            DeleteEntity(kutuprop4)

            kutuprop4 = nil
        end
	elseif stock == 5 then
		if DoesEntityExist(kutuprop5) then
			DetachEntity(kutuprop5,false,false)
			FreezeEntityPosition(kutuprop5,false)
            DeleteEntity(kutuprop5)

            kutuprop5 = nil
        end
	elseif stock == 6 then
		if DoesEntityExist(kutuprop6) then
			DetachEntity(kutuprop6,false,false)
			FreezeEntityPosition(kutuprop6,false)
            DeleteEntity(kutuprop6)
           
            kutuprop6 = nil
        end
    elseif stock == 7 then
		if DoesEntityExist(kutuprop7) then
			DetachEntity(kutuprop7,false,false)
			FreezeEntityPosition(kutuprop7,false)
            DeleteEntity(kutuprop7)

            kutuprop7 = nil
        end
    elseif stock == 8 then
		if DoesEntityExist(kutuprop8) then
			DetachEntity(kutuprop8,false,false)
			FreezeEntityPosition(kutuprop8,false)
            DeleteEntity(kutuprop8)

            kutuprop8 = nil
        end
    elseif stock == 9 then
		if DoesEntityExist(kutuprop9) then
			DetachEntity(kutuprop9,false,false)
			FreezeEntityPosition(kutuprop9,false)
            DeleteEntity(kutuprop9)

            kutuprop9 = nil
        end
    elseif stock == 10 then
		if DoesEntityExist(kutuprop10) then
			DetachEntity(kutuprop10,false,false)
			FreezeEntityPosition(kutuprop10,false)
            DeleteEntity(kutuprop10)

            kutuprop10 = nil
        end
    elseif stock == 11 then
		if DoesEntityExist(kutuprop11) then
			DetachEntity(kutuprop11,false,false)
			FreezeEntityPosition(kutuprop11,false)
            DeleteEntity(kutuprop11)

            kutuprop11 = nil
        end
    elseif stock == 12 then
		if DoesEntityExist(kutuprop12) then
			DetachEntity(kutuprop12,false,false)
			FreezeEntityPosition(kutuprop12,false)
            DeleteEntity(kutuprop12)

            kutuprop12 = nil
        end
    elseif stock == 13 then
		if DoesEntityExist(kutuprop13) then
			DetachEntity(kutuprop13,false,false)
			FreezeEntityPosition(kutuprop13,false)
            DeleteEntity(kutuprop13)

            kutuprop13 = nil
        end
    elseif stock == 14 then
		if DoesEntityExist(kutuprop14) then
			DetachEntity(kutuprop14,false,false)
			FreezeEntityPosition(kutuprop14,false)
            DeleteEntity(kutuprop14)

            kutuprop14 = nil
        end
    elseif stock == 15 then
		if DoesEntityExist(kutuprop15) then
			DetachEntity(kutuprop15,false,false)
			FreezeEntityPosition(kutuprop15,false)
            DeleteEntity(kutuprop15)

            kutuprop15 = nil
        end
	
	elseif stock == 16 then
		if DoesEntityExist(kutuprop16) then
			DetachEntity(kutuprop16,false,false)
			FreezeEntityPosition(kutuprop16,false)
            DeleteEntity(kutuprop16)

			kutuprop16 = nil
		end
	
	elseif stock == 17 then
		if DoesEntityExist(kutuprop17) then
			DetachEntity(kutuprop17,false,false)
			FreezeEntityPosition(kutuprop17,false)
            DeleteEntity(kutuprop17)

			kutuprop17 = nil
		end
	elseif stock == 18 then
		if DoesEntityExist(kutuprop18) then
			DetachEntity(kutuprop18,false,false)
			FreezeEntityPosition(kutuprop18,false)
            DeleteEntity(kutuprop18)

			kutuprop18 = nil
		end
	
	elseif stock == 19 then
		if DoesEntityExist(kutuprop19) then
			DetachEntity(kutuprop19,false,false)
			FreezeEntityPosition(kutuprop19,false)
            DeleteEntity(kutuprop19)

			kutuprop19 = nil
		end
	
	elseif stock == 20 then
		if DoesEntityExist(kutuprop20) then
			DetachEntity(kutuprop20,false,false)
			FreezeEntityPosition(kutuprop20,false)
            DeleteEntity(kutuprop20)

			kutuprop20 = nil
		end
	
	elseif stock == 21 then
		if DoesEntityExist(kutuprop20) then
			DetachEntity(kutuprop20,false,false)
			FreezeEntityPosition(kutuprop20,false)
            DeleteEntity(kutuprop20)

			kutuprop20 = nil
		end
	end
end



function gorevblipleri(locs,selecionado)
	blips = AddBlipForCoord(gorevler[l].x,gorevler[l].y,gorevler[l].z)
	SetBlipSprite(blips,1)
	SetBlipColour(blips,3)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Kargo Teslimat Gorevi")
	EndTextCommandSetBlipName(blips)
end

function kargolariyukle(locs,selecionado)
	local kargoyukle = AddBlipForCoord(vector3(751.25, -947.04, 25.63))
 
    SetBlipSprite (kargoyukle, 67)
    SetBlipDisplay(kargoyukle, 4)
    SetBlipScale  (kargoyukle, 0.4)
    SetBlipColour (kargoyukle, 5)
    SetBlipAsShortRange(kargoyukle, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Kargo Yukle')
    EndTextCommandSetBlipName(kargoyukle)
    table.insert(kargoyukleblip,kargoyukle)

end


function deliverysucces()
	
	StopAnimTask(GetPlayerPed(-1), 'anim@heists@box_carry@', 'idle', 1.0)
	DetachEntity(prop, true, false)
	SetEntityCoords(prop, 0.0, 0.0, 0.0, false, false, false, true)
	itemibirakabilirmi = false
	stock = stock - 1
	teslimedilen= teslimedilen + 1
	if stock == 0 then
         yournotify('Congratulations Box delivered!!', 3000)

		
		Wait(1000)
        yournotify('You Dont Have Another Box. Go Get Your Money!!', 3000)

		

	
	else
        yournotify('Congratulations. You can Go to New Mission or hand over the Vehicle and get your money!!', 3000)

		

		RemoveBlip(blips)
		startjob()
	end
end