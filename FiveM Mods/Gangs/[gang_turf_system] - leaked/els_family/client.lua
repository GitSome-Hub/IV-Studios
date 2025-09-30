

QBCore = exports['qb-core']:GetCoreObject()
local Familyss = {}
local waitingKey = false
local showMarker = false
local waitingKey1 = false
local showMarker1 = false
local waitingKey3 = false
local showMarker3 = false
local playeridisii = nil
local playtime = 0
local familyzone = nil
local inzone = false
local blips = {}
local createzonepart = {}
local item1 = nil
local item2 = nil

local allpolyzones = {}
dragStatus = {isDragged = false, carry_status = false}

local raidplayers = {}

local yeahload = false

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

-- if Config.needrestart then 
-- 	Citizen.CreateThread(function( )
-- 		TriggerServerEvent('els_family:loadfamilys')
-- 	end)
-- end

-- RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
   
-- 	TriggerServerEvent('els_family:loadfamilys')
-- end)

Citizen.CreateThread(function()
	while true do 

		if yeahload == false then
			TriggerServerEvent('els_family:loadfamilys')

		end

		if yeahload then
			break
		end

	  Citizen.Wait(1000)
	end
end)

RegisterNetEvent('els_family:client:getFamilys')
AddEventHandler('els_family:client:getFamilys', function(curdata, zone)


	Familyss = curdata

	playeridisii = QBCore.Functions.GetPlayerData().citizenid
	familyzone = zone
	setupzones(zone)
	yeahload = true;
   

	
end)
RegisterNetEvent('els_family:sendplayerzone')
AddEventHandler('els_family:sendplayerzone', function(zone)
	familyzone = zone
	setupzones(zone)
end)



function setupzones(data)
	local deneme = isthismember()
	

	if json.encode(deneme) ~= "[]" then
		
		for k,v in pairs(data) do
			
			if v.zoneown == "none" then
		
			    addfamilyzone(v.zonecoord,v.zonewidth,v.zoneheight,v.zonrerot, 0,k)
				addpolyzone(k,v)
			else
				if v.zoneown == deneme.familyiddsi then
					addfamilyzone(v.zonecoord,v.zonewidth,v.zoneheight,v.zonrerot, 2,k)
				else
					addfamilyzone(v.zonecoord,v.zonewidth,v.zoneheight,v.zonrerot, 1, k)
				end
				addpolyzone(k,v)
			end
		end
	end
end

function addpolyzone(k,v)
	local k = v.zonename
	
    k = PolyZone:Create({
		vector2(v.polyzone.koord1,v.polyzone.koord2),
		vector2(v.polyzone.koord3, v.polyzone.koord4),
		vector2(v.polyzone.koord5, v.polyzone.koord6),
		vector2(v.polyzone.koord7,v.polyzone.koord8)

	}, {
		name=k,
		-- minZ=51.0,
		-- maxZ=62.0,
		debugGrid=Config.debugzone
		-- gridDivisions=25
	})

	k:onPlayerInOut(function(isPointInside, point, dsss)
		if isPointInside then
           
		
			inzone = dsss

			genelplayerid = QBCore.Functions.GetPlayerData().citizenid

		else

			for i=1,#raidplayers do
				if raidplayers[i].zonename == inzone then
					if genelplayerid == raidplayers[i].playersteam then
						-- RemoveBlip(raidplayers[i].playerblip)
						removeraid(raidplayers[i].zonename, "out")
						TriggerServerEvent('els_family:raidplayerblipdelete', i)
						-- table.remove(raidplayers, i)
					
						break
						
					end
				end
			end
			inzone = false
		end

	end)  

	table.insert( allpolyzones, k )    
end


RegisterNetEvent('els_family:raidplayerblipdelete_client')
AddEventHandler('els_family:raidplayerblipdelete_client', function(deleteid)
    RemoveBlip(raidplayers[deleteid].playerblip)
	table.remove(raidplayers, deleteid)


end)


function removeraid(vipzonename, tip)
	if tip == "dead" then
	yournotify('You Dead Sorry  !!', 3000)

	else
	yournotify('You leave area sorry!!', 3000)

	end


	SendNUIMessage({
		message = "stopraid",
	    raidname = vipzonename



	})
end

function addfamilyzone(koords,width,height,rote,color,zonevalue)
	

	    local mzonevalue = AddBlipForArea(tonumber(koords.x), tonumber(koords.y), tonumber(koords.z), tonumber(width..".0"), tonumber(height..".0"))
		SetBlipDisplay(mzonevalue, 3)
		SetBlipRotation(mzonevalue, tonumber(rote..".0"))
		SetBlipColour(mzonevalue, tonumber(color))
		SetBlipAlpha( mzonevalue, 100)
		SetBlipAsShortRange(mzonevalue, true)
        table.insert( blips, {['blipname'] = zonevalue, ['blipkod'] = mzonevalue } )

	

end

function removeblipbeya()
	if json.encode(blips) ~= "[]" then
		for k,v in pairs(blips) do
			RemoveBlip(v.blipkod)
		end
	end
end




-- RegisterNetEvent('els_family:updatemission')
-- AddEventHandler('els_family:updatemission', function(data)
-- 	print(json.encode(data))
-- 	--code
-- end)



RegisterNetEvent('els_family:checkinzone')
AddEventHandler('els_family:checkinzone', function(veri)
	local bune = controlzone(veri.changeid)
	TriggerServerEvent('els_family:sendzoneinfo',veri, bune)
end)

RegisterNUICallback('removeraid', function(data)
	TriggerServerEvent('els_family:zonechange', data)

end)

RegisterNetEvent('els_family:zonechange:server')
AddEventHandler('els_family:zonechange:server', function(zone)

	familyzone = zone
end)


function controlzone(familyida)
	local pett = false
	for k,v in pairs(Familyss) do
		if v.familyid == familyida then
			for l,c in pairs(v.meta.zones) do
				if c.zonename == inzone then
					pett = true
					break
				end
			end
		end
	end	
	return pett
end
Citizen.CreateThread(function()
	for k,v in pairs(Config.CreateFamily) do
	local blip = AddBlipForCoord(v.createfamilycoord.x, v.createfamilycoord.y, v.createfamilycoord.z)

	SetBlipSprite(blip, 86)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, 5)

	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Family Create")
	EndTextCommandSetBlipName(blip)
	end
	
end)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait( 10 * 60 * 1000)
		local deneme = isthismember()
		
		if json.encode(deneme) ~= "[]" then
			TriggerServerEvent('els_family:server:updatetime',deneme)
		    
		end
	end
end)

function isthismember()
	local bune = {}
	for k,v in pairs(Familyss) do

		for l,c in pairs(v.meta.members) do
			if c.memberid == playeridisii then
				bune = {['membernm'] = l, ['familyiddsi'] = v.familyid, ['familyiddsi'] = v.familyid , ['memberrank'] = c.memberrank}
				break
			end
		end
	end
	return bune
end


RegisterNetEvent('els_family:client:newfamily')
AddEventHandler('els_family:client:newfamily', function(data)
	

	table.insert( Familyss,data)
	
end)
RegisterNetEvent('els_family:client:loadzones')
AddEventHandler('els_family:client:loadzones', function()
	

  setupzones(familyzone)

  TriggerEvent('els_family:notifyon' , "Family Created")
end)







RegisterCommand("familyraid", function()

	for k,v in pairs(Familyss) do

		for k,c in pairs(v.meta.members) do
		
			if c.memberid == QBCore.Functions.GetPlayerData().citizenid	then
			
				local topla = #v.meta.zones + 1

				-- print(topla)
			
			    if tonumber(Config.Maxraidlimit) > tonumber(topla) then
					
					raidyapabilirmi(v)
					break
					
				else
					yournotify('You have enough territory!!', 3000)
					
					
					break
				end
			
			end
		end
	end
     

end)

function raidyapabilirmi(d)

	for k,v in pairs(familyzone) do
		 
		if v.zonename == inzone then
		
			if v.zoneown == "none" then

				if v.zoneraid == false then
			
				   count(d.familyid, v.zonename)
				end
				-- TriggerServerEvent('els_family:zoneraid', d.familyid, k)
				break
			end
		end
	end

end

RegisterNUICallback('raidnow', function()
	for i=1,#raidplayers do
		if raidplayers[i].zonename == inzone then
			if genelplayerid == raidplayers[i].playersteam then
			
				TriggerServerEvent('els_family:raidplayerblipdelete', i)
				-- table.remove(raidplayers, i)
				break
		
			end
				
				
			
		end
	end


	TriggerServerEvent('els_family:zoneraid', item1, item2)
end)



function count(deger1, deger2)
	item1 = deger1
	item2 = deger2

    TriggerServerEvent('els_familyzone:raidupdate', deger2)
	SendNUIMessage({
		message = "opentime",
		raidtime = Config.raidtime

	

	})
	
end



function openthisbitc(data, playerid)
   
	SetNuiFocus(true, true)
    SendNUIMessage({
        message = "openfamilymenu",
        familydata = data,
		playerid = playerid,
		marketitems = Config.Markets

    })
end

RegisterNetEvent('els_family:client:updatechat')
AddEventHandler('els_family:client:updatechat', function(data1,data2)
	 for k,v in pairs(Familyss) do
		if v.familyid == data1 then
			v.familychat = data2
			SendNUIMessage({
				message = "refreshchat",
				newchat = v.familychat,
				chatplayerid = QBCore.Functions.GetPlayerData().citizenid
		
			})
			break
		end
	 end



end)
RegisterNetEvent('els_family:client:updatesettings')
AddEventHandler('els_family:client:updatesettings', function(data1,data2,data3)
	 for k,v in pairs(Familyss) do
		if v.familyid == data1 then
			v.meta.members[data2] = data3
			SendNUIMessage({
				message = "refreshsettings",
				playerid = QBCore.Functions.GetPlayerData().citizenid,
				newdata = v
			
		
			})
			break
		end
	 end



end)

RegisterNetEvent('els_family:client:updateinsertitem')
AddEventHandler('els_family:client:updateinsertitem', function(data1,data2)
	 for k,v in pairs(Familyss) do
		if v.familyid == data1 then
			v.meta = data2
			SendNUIMessage({
				message = "refreshvaults",
				newdata = v
			
		
			})
			break
		end
	 end

	 



end)


RegisterNetEvent('els_family:client:zonesupdate')
AddEventHandler('els_family:client:zonesupdate', function(data1,data2,data3)
	 for k,v in pairs(Familyss) do
		if v.familyid == data1 then
			v.meta = data2
			
			break
		end
	 end

	 for k,v in pairs(familyzone) do
		if v.zonename == data3 then
			v.zoneown = data1
			break 
		end
	 end
	 removeblipbeya()
	 resetupzones(familyzone)

end)

function resetupzones(data)
	local deneme = isthismember()
		
	if json.encode(deneme) ~= "[]" then
		
		for k,v in pairs(data) do
			if v.zoneown == "none" then
		  
			    addfamilyzone(v.zonecoord,v.zonewidth,v.zoneheight,v.zonrerot, 0,k)
				-- addpolyzone(k,v)
			else
			
				if v.zoneown == deneme.familyiddsi then
					addfamilyzone(v.zonecoord,v.zonewidth,v.zoneheight,v.zonrerot, 2,k)
				else
					addfamilyzone(v.zonecoord,v.zonewidth,v.zoneheight,v.zonrerot, 1, k)
				end
				-- addpolyzone(k,v)
			end
		end
	end
end




RegisterNetEvent('els_family:updateself')
AddEventHandler('els_family:updateself', function(data1,data2)
	 for k,v in pairs(Familyss) do
		if v.familyid == data1 then
			v.meta = data2
			SendNUIMessage({
				message = "refreshtoplist",
				newdata = v
			
		
			})
			break
		end
	 end



end)



RegisterNetEvent('els_family:startfamilyvalut')
AddEventHandler('els_family:startfamilyvalut', function(name)
	



end)



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
      
            local pedCoords = GetEntityCoords(PlayerPedId())
            local dist
            for k,v in pairs(Familyss) do
				for d,c in pairs(v.meta.garages) do
					
					dist = #(pedCoords - vector3(c.coordss.x,c.coordss.y,c.coordss.z))
					if dist < 3 then
						if not showMarker1 then
							showMarker1 = d
						
							ShowMarker1(d, vector3(c.coordss.x,c.coordss.y,c.coordss.z))
							TriggerEvent('els_family:drawtexton', "[E]".." "..c.garageid.." Garages")
							
						end
						if dist < 1.5 then
							if not waitingKey1 then
								waitingKey1 = d
								WaitingKeys1(d, c, v)
								
							end
						else 
							waitingKey1 = false
							
						end
					elseif showMarker1 == d then
						showMarker1 = false
						TriggerEvent('els_family:drawtextoff')
						
			
					end
				end
            end
       
    end
end)


function WaitingKeys1(destiniy,data , maindata)
    Citizen.CreateThread(function()
        while waitingKey1 == destiniy do
            Citizen.Wait(0)
            if IsControlJustPressed(0,38) then
				
				local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
			
				if closestDistance <= 2.0 and closestPlayer == -1 then
				
					if IsPedInAnyVehicle(PlayerPedId(), false) then
						local vehicle = GetVehiclePedIsIn(PlayerPedId(),false)
						local plate = GetVehicleNumberPlateText(vehicle)
						_, y = string.find(plate, maindata.familyid)
                       if _ == nil then
						yournotify('You can not put this vehicle!!', 3000)

						
					   else
						  TriggerServerEvent('els_family:removevehicle', plate,maindata.familyid, destiniy ,vehicle )
					   end
					else
						
						if json.encode(data.vehicles) == "[]" then
					    	yournotify('No Vehicle In Garage!!', 3000)

						
						else
							local deneme = isthismember()
							local denemes = string.sub(deneme.memberrank,5,6)
						     local denemes2 = string.sub(maindata.meta.staffss.garageaccess,5,6)
 
					
						   if tonumber(denemes) >= tonumber(denemes2) then
					

							opengarage(data.vehicles, maindata.familyid, destiniy)
						   else
					    	yournotify('No Access!!', 3000)

							
						    end
							
						end
					end
					
				
					
				end
            end
        end
    end)
end


function ShowMarker1(type, koord)
    Citizen.CreateThread(function()
        while showMarker1 == type do
            Citizen.Wait(1)
            DrawMarker(21, koord, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 255, 0,0, 100, false, true, 2, true, nil, nil, false)
        end
    end)
end


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if IsControlJustPressed(0, Keys['F7']) then
			for k,v in pairs(Familyss) do

				for k,c in pairs(v.meta.members) do
					if c.memberid == QBCore.Functions.GetPlayerData().citizenid then
					
						openthisbitc(v, QBCore.Functions.GetPlayerData().citizenid)
						break
					end
				end
			end
		end


		if IsControlJustPressed(0, Keys['F6']) then
			local deneme = controlf6()
			
		
			if json.encode(deneme) ~= "[]" then
                if deneme.f6clanperm then
					openf6menu()

				else
					yournotify('Your family dont have menu!!', 3000)

				end
			end
		end
	end
end)


function openf6menu()
	SetNuiFocus(true,true)
	SendNUIMessage({
		message = "openf6menu"
	

	})
end


function controlf6()
	local bune = {}
	for k,v in pairs(Familyss) do

		for l,c in pairs(v.meta.members) do
			if c.memberid == playeridisii then
				bune = {['membernm'] = l, ['familyiddsi'] = v.familyid, ['familyiddsi'] = v.familyid , ['memberrank'] = c.memberrank , ['f6clanperm'] = v.meta.f6perm }
				break
			end
		end
	end
	return bune
end

function opengarage(aracdata, maindata, hangigarage)
	SetNuiFocus(true,true)
	SendNUIMessage({
		message = "opengarage",
		aracdata = aracdata ,
		maindata = maindata,
		hangigarage = hangigarage
	
	

	})
end


RegisterNUICallback('vehicleout', function(data)
	local bune = nil
	for k,v in pairs(Familyss) do
		if v.familyid == data.changeid then
			bune = k
			break
		end
	end
	SetNuiFocus(false, false)
	if Familyss[bune].meta.garages[data.garageidsi].vehicles[(data.outvehicleid + 1)].vehiclestatus == "in" then
		
		TriggerServerEvent('els_family:vehicleout', data)
	end
end)




RegisterNUICallback('rejectplayer', function(data)
	TriggerServerEvent('els_family:rejectplayer', data)
end)

RegisterNetEvent('els_family:notifyon')
AddEventHandler('els_family:notifyon', function(text)
	SendNUIMessage({
		message = "notifyon",
		notifytext = text


	})
end)


RegisterNUICallback('acceptplayer', function(data)
	TriggerServerEvent('els_family:acceptplayer', data)
end)

RegisterNUICallback('closemenu', function()
	SetNuiFocus(false,false)
end)


RegisterNUICallback('joinfamily', function(data)
	local deneme = isthismember()
	
	if json.encode(deneme) == "[]" then
		TriggerServerEvent('els_family:joinnewfamily',data)
	
	else
		TriggerEvent('els_family:notifyon' , "You have already Family")
	end
end)


RegisterNUICallback('newfamilycreate', function(data)
	-- SetNuiFocus(false,false)
	local deneme = isthismember()
	if json.encode(deneme) == "[]" then

		SetNuiFocus(false,false)
		TriggerServerEvent('els_family:createnewfamily',data)
	
	else
		TriggerEvent('els_family:notifyon' , "You have already Family")
	end
end)




RegisterNetEvent('els_family:deletevehicle')
AddEventHandler('els_family:deletevehicle', function(entity)
	QBCore.Functions.DeleteVehicle(entity)

   
end)

RegisterNetEvent('els_family:spawnvehicle')
AddEventHandler('els_family:spawnvehicle', function(koords,data)

	QBCore.Functions.SpawnVehicle(data.vehiclename, function(vehicle)
		SetVehicleNumberPlateText(vehicle, data.vehicleplate)
		SetPedIntoVehicle(PlayerPedId(),vehicle, -1)
		GetEntityHeading(PlayerPedId())
		TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))

		if json.encode(data.vehiclemods) ~= "[]" then
			QBCore.Functions.SetVehicleProperties(vehicle, data.vehiclemods)
		end
        
	end, vector3(koords.x, koords.y, koords.z))
end)

-------------------------------------------------NAME CHANGE --------------------------------------------------------------------------------


RegisterNetEvent('els_family:openchangename')
AddEventHandler('els_family:openchangename', function(data)
	SetNuiFocus(true,true)
	SendNUIMessage({
		message = "openchangename",
		changenamedata = data

	})
end)


RegisterNetEvent('els_family:drawtexton')
AddEventHandler('els_family:drawtexton', function(text)
	SendNUIMessage({
		message = "drawtexton",
		drawtextext = text

	})
end)

RegisterNetEvent('els_family:drawtextoff')
AddEventHandler('els_family:drawtextoff', function(text)
	SendNUIMessage({
		message = "drawtextoff",
		drawtextext = text

	})
end)



---------------------------------------------------- INVENTORY ---------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
      
            local pedCoords = GetEntityCoords(PlayerPedId())
            local dist
            for k,v in pairs(Familyss) do
				for d,c in pairs(v.meta.inventorys) do
					
					dist = #(pedCoords - vector3(c.coordss.x,c.coordss.y,c.coordss.z))
					if dist < 3 then
						if not showMarker then
							showMarker = d
						
							ShowMarker(d, vector3(c.coordss.x,c.coordss.y,c.coordss.z))
							TriggerEvent('els_family:drawtexton', "[E]".." "..c.inventoryid.." Inventory")
							
						end
						if dist < 1.5 then
							if not waitingKey then
								waitingKey = d
								WaitingKeys(d, c, v)
								
							end
						else 
							waitingKey = false
							
						end
					elseif showMarker == d then
						showMarker = false
						TriggerEvent('els_family:drawtextoff')
					
					end
				end
            end
       
    end
end)


function WaitingKeys(type,data, maindata)
    Citizen.CreateThread(function()
        while waitingKey == type do
            Citizen.Wait(0)
            if IsControlJustPressed(0,38) then
				local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
				if closestPlayer == -1 and closestDistance <= 2.0 then
					-- if v.meta.staffss.inventoryaccess
					local deneme = isthismember()
		
		            if json.encode(deneme) ~= "[]" then
						local denemes = string.sub(deneme.memberrank,5,6)
						local denemes2 = string.sub(maindata.meta.staffss.inventoryaccess,5,6)

					
						if tonumber(denemes) >= tonumber(denemes2) then
					    --   TriggerServerEvent("esx_inventory:server:openprivate", {name = 'Family_'..data.inventoryid ,slots = tonumber(data.type), type = 'stash'})
						  inventorysystem(data.inventoryid, tonumber(data.type))
						else
					    	yournotify('No Access!!', 3000)

						
						end
					end
				end
            end
        end
    end)
end


function ShowMarker(type, koord)
    Citizen.CreateThread(function()
        while showMarker == type do
            Citizen.Wait(1)
            DrawMarker(21, koord, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 255, 255,0, 100, false, true, 2, true, nil, nil, false)
        end
    end)
end


function yournotify(text, time)
	if Config.notifytype == "qbnotify" then
		QBCore.Functions.Notify(text, "error", time)
	elseif Config.notifytype == "esxnotify" then
		ESX.ShowNotification(text, "info")
	elseif Config.notifytype == "costumnotify" then
		notifycustom(text,time)
	end
end


RegisterNUICallback('usingitem', function(data)
    TriggerServerEvent('els_family:usingitem', data)
end)





RegisterNUICallback('refreshinventorycoords', function(data)
    SetNuiFocus(false, false)
	local onbu = true
	local budata = data
	Citizen.CreateThread(function()
        while onbu do
            Citizen.Wait(1)
           
            if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then
				local bune = controlzone(data.changeid)
				if bune then
				TriggerServerEvent('els_family:refreshinventorycoords', data)
				onbu = false 
				SendNUIMessage({
					message = "closeinfodiv"
	
				})
			    else
					yournotify('Not your family zone!!', 3000)

				
					onbu = false 
					SendNUIMessage({
						message = "closeinfodiv"
		
					})
				end
				break
			end
		end
	end)
end)


RegisterNUICallback('refreshgaragecoords', function(data)
    SetNuiFocus(false, false)
	local onbu = true
	local budata = data
	Citizen.CreateThread(function()
        while onbu do
            Citizen.Wait(1)
           
            if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then
				TriggerServerEvent('els_family:refreshgaragecoords', data)
				onbu = false 
				SendNUIMessage({
					message = "closeinfodiv"
	
				})
				break
			end
		end
	end)
end)




RegisterNUICallback('deleteinventory', function(data)
    SetNuiFocus(false, false)
	TriggerServerEvent('els_family:deleteinventory', data)
end)

RegisterNUICallback('deletegarage', function(data)
    SetNuiFocus(false, false)
	TriggerServerEvent('els_family:deletegarage', data)
end)


RegisterNUICallback('changemembersettings', function(data)
    TriggerServerEvent('els_family:updatemember', data)
end)
RegisterNUICallback('informessage', function(data)
    TriggerServerEvent('els_family:informessage', data)
end)

RegisterNUICallback('informnewname', function(data)
	SetNuiFocus(false, false)
    TriggerServerEvent('els_family:informnewname', data)
end)



RegisterNUICallback('kickmember', function(data)
	for k,v in pairs(Familyss) do
		if v.familyid == data.changeid then
	    
			if v.meta.members[data.changememberid + 1].memberid ~= v.ownerid then
				TriggerServerEvent('els_family:kickmember', data)
				break
			end
		end
	end

end)

RegisterNUICallback('changeimage', function(data)
    TriggerServerEvent('els_family:changeimage', data)
end)

RegisterNUICallback('changeaccess', function(data)
    TriggerServerEvent('els_family:changeaccess', data)
end)

RegisterNUICallback('buyitem', function(data)
    TriggerServerEvent('els_family:buyitem', data)
end)

RegisterNUICallback('missinaccept', function(data)
	-- SetNuiFocus(false, false)
   TriggerServerEvent('els_family:correctmission', data)
end)




RegisterNetEvent('els_family:nopemission')
AddEventHandler('els_family:nopemission', function()
	TriggerEvent('els_family:notifyon',"This mission limit full")

end)

RegisterNetEvent('els_family:startmission')
AddEventHandler('els_family:startmission', function(heyheydata, familyid)
		SetNuiFocus(false, false)
	SendNUIMessage({
		message = "closemission"


	})
    startmissioninconfig(heyheydata, familyid)

end)

function startmission1()
end





RegisterNetEvent('els_family:client:updatename')
AddEventHandler('els_family:client:updatename', function(data1,data2)

	for k,v in pairs(Familyss) do
		if v.familyid == data1 then
			v.name = data2
			break
		end
	end

end)

RegisterNetEvent('els_family:client:updateimg')
AddEventHandler('els_family:client:updateimg', function(data1,data2)

	for k,v in pairs(Familyss) do

		if v.familyid == data1 then
			v.image = data2
			SendNUIMessage({
				message = "updateimg",
				familynew = v

			})
			break
		end
	end

end)



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
      
            local pedCoords = GetEntityCoords(PlayerPedId())
            local dist

			for k,v in pairs(Config.CreateFamily) do
	
	
				dist = #(pedCoords - v.createfamilycoord)
				if dist < 3 then
					if not showMarker3 then
						showMarker3 = k
						
						ShowMarker3(k, v.createfamilycoord)

						TriggerEvent('els_family:drawtexton', v.createfamilylabel)

					end
					if dist < 1.5 then
						if not waitingKey3 then
							waitingKey3 = k
							WaitingKeys3(k, v)
							
						end
					else 
						waitingKey3 = false
						
					end
				elseif showMarker3 == k then
					showMarker3 = false
					TriggerEvent('els_family:drawtextoff')
					
				end
			end
		
       
    end
end)


RegisterNetEvent('els_family:sendthis')
AddEventHandler('els_family:sendthis', function(data)
	SetNuiFocus(true,true)
	SendNUIMessage({
		message = "opencreate",
		createdata = data 

	})
end)




function WaitingKeys3(type,maindata)
    Citizen.CreateThread(function()
        while waitingKey3 == type do
            Citizen.Wait(0)
            if IsControlJustPressed(0,38) then

				TriggerServerEvent('els_family:getfamilysforcreate')
				
            end
        end
    end)
end


function ShowMarker3(type, koord)
    Citizen.CreateThread(function()
        while showMarker3 == type do
            Citizen.Wait(1)
            DrawMarker(21, koord, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 255, 255,255, 100, false, true, 2, true, nil, nil, false)
        end
    end)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Citizen.CreateThread(function()
-- 	while true do
-- 		Citizen.Wait(1000)
-- 		local deneme = isthismember()
		
-- 		if json.encode(deneme) ~= "[]" then
-- 			for k,v in pairs(familyzone) do
			
-- 				if GetDistanceBetweenCoords(v.zonecoord.x, v.zonecoord.y, v.zonecoord.z, GetEntityCoords(PlayerPedId())) < v.zoneradius then
--                    print(k)
-- 				end
			
-- 			end
-- 		end
-- 	end
-- end)

-- RegisterCommand("getcom", function(source, args, rawCommand)
-- 	local WaypointHandle = GetFirstBlipInfoId(8)
-- 	local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
-- 	local pedCoords = GetEntityCoords(PlayerPedId())
-- 	print(waypointCoords.x,waypointCoords.y)



  
-- end)
local startcraezoneon = false

RegisterCommand("adminzone", function()
	local perm = false

	for k,v in pairs(Config.adminzoneperm) do
		if v == playeridisii then
			perm = true 
			break
		end
	end

	if perm then

		SetNuiFocus(true,true)
		-- local test = {}
		-- table.insert( test, familyzone )
		SendNUIMessage({
			message = "adminzone",
			familyzone = familyzone 

		})
	else
		yournotify('You Dont Have Perm!!', 3000)


	end
	
	-- local deger1 = tonumber(args[1])
	-- local deger2 = tonumber(args[2])
	-- local deger3 = tonumber(args[3])

    --      if args[1] and args[2] and args[3] then
	
		
    --          if type(deger1) == "number" and type(deger2) == "number" then
	-- 			startcreatezone(deger1,deger2, deger3)
	-- 			startcraezoneon = true
	-- 		 end
			
	-- 	 end
end)


function startcreatezone(deger1,deger2, deger3)
	local first1, first2, first3 , first4 , first5 = false, false ,false , false, false
	local onbu = false
	local muhittin = {}

	Citizen.CreateThread(function()
        while startcraezoneon do
            Citizen.Wait(300)
            local WaypointHandle = GetFirstBlipInfoId(8)

        
                 if first1 == false then
					if DoesBlipExist(WaypointHandle) then
					
					    local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
						
					
						gecicizone = AddBlipForArea(tonumber(waypointCoords["x"]), tonumber(waypointCoords["y"]), tonumber(waypointCoords["z"]), tonumber(deger1..".0"), tonumber(deger2..".0"))
						SetBlipDisplay(gecicizone, 3)
						SetBlipRotation(gecicizone, tonumber(deger3))
						SetBlipColour(gecicizone, 0)
						SetBlipAlpha( gecicizone, 100)
						SetBlipAsShortRange(gecicizone, true)
		
						first1 = true
						DeleteWaypoint()
						muhittin.realkoord = {}
						muhittin.realkoord.x = waypointCoords["x"]
						muhittin.realkoord.y = waypointCoords["y"]
						muhittin.realkoord.z = waypointCoords["z"]
						muhittin.realkoord.rot = deger3
						muhittin.realkoord.width = deger1
						muhittin.realkoord.height = deger2
						



						
					end
					
				 end
			

				 if first1 == true and first2 == false then
					if DoesBlipExist(WaypointHandle) then
					    local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
						muhittin.koord1 = {}
						muhittin.koord1.x = waypointCoords["x"]
						muhittin.koord1.y = waypointCoords["y"]
						DeleteWaypoint()
						first2 = true
					end
					
				 end

				 if first1 == true and first2 == true and first3 == false then
					if DoesBlipExist(WaypointHandle) then
					    local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
						muhittin.koord2 = {}
						muhittin.koord2.x = waypointCoords["x"]
						muhittin.koord2.y = waypointCoords["y"]
						DeleteWaypoint()
						first3 = true
					end
				

				 end
				 
				 if first1 == true and first2 == true and first3 == true and first4 == false then
					if DoesBlipExist(WaypointHandle) then
					    local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
						muhittin.koord3 = {}
						muhittin.koord3.x = waypointCoords["x"]
						muhittin.koord3.y = waypointCoords["y"]
						DeleteWaypoint()
						first4 = true
					end
				

				 end

				 if first1 == true and first2 == true and first3 == true and first4 == true and first5 == false then
					if DoesBlipExist(WaypointHandle) then
					    local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
						muhittin.koord4 = {}
						muhittin.koord4.x = waypointCoords["x"]
						muhittin.koord4.y = waypointCoords["y"]
						DeleteWaypoint()
						first5 = true
						onbu = true
						SendNUIMessage({
							message = "openzoneinfodiv"
			
						})
					end
					
				 end
            if startcraezoneon == false then
				break
			end
	
        
		end
	end)



	Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)
            if onbu then
				if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then
					
					TriggerServerEvent('els_family:gotozonesave', muhittin)
					onbu = false 
					first1, first2, first3 , first4 , first5 = false, false ,false , false, false
					onbu = false
					muhittin = {}
					startcraezoneon= false
					RemoveBlip(gecicizone)
					SendNUIMessage({
						message = "closeinfodiv"
		
					})
					break
				end


				if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then
					onbu = false 
					first1, first2, first3 , first4 , first5 = false, false ,false , false, false
					onbu = false
					muhittin = {}
					startcraezoneon = false
					RemoveBlip(gecicizone)
					SendNUIMessage({
						message = "closeinfodiv"
		
					})
					break
				end
			
			end
		end
	end)
end


RegisterNetEvent('els_family:sendagainzones')
AddEventHandler('els_family:sendagainzones', function(zones ,direktzone)
	familyzone = zones
	removeblipbeya()
	resetupzones(zones)
    addnewpoly(direktzone)
end)

function destroyallzones( )
	for k,v in pairs(allpolyzones) do
		v:destroy()
	end
end

RegisterNetEvent('els_family:writenewzone')
AddEventHandler('els_family:writenewzone', function(zone)
	familyzone = zone
	destroyallzones()
	removeblipbeya()
	Wait(500)
	setupzones(familyzone)
	
end)


RegisterNetEvent('els_family:zonenewdata')
AddEventHandler('els_family:zonenewdata', function(zone, id, zonename, playersteamid)
	familyzone = zone
	local deneme = isthismember()
	if json.encode(deneme) ~= "[]" then
		local denemeplayer = GetPlayerPed(GetPlayerFromServerId(tonumber(id)))
		-- local newblip = AddBlipForEntity(denemeplayer)
		local blip, coord = addnewblip(denemeplayer)
		table.insert(raidplayers, {['playerid'] = id, ['zonename'] = zonename, ['playersteam'] = playersteamid , ['playerblip'] = blip, ['playercoord'] = coord})
	end
end)


function addnewblip(blipplayer)
	local coords = GetEntityCoords(blipplayer)
	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForCoord(coords.x, coords.y, coords.z)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(blipplayer))) -- update rotation

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Enemy") -- set blip's "name"
		EndTextCommandSetBlipName(blip)
		SetBlipScale(blip, 0.8) -- set scale
		
		SetBlipColour(blip,1)

		
		SetBlipAsShortRange(blip, true)
		return blip, coords
	end
end


function addnewblip2(blipplayer, coords)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForCoord(coords.x, coords.y, coords.z)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(blipplayer))) -- update rotation
		---SetBlipName(blip, isim)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Enemy") -- set blip's "name"
		EndTextCommandSetBlipName(blip)
		SetBlipScale(blip, 0.8) -- set scale

		SetBlipColour(blip,1)
	
		
		SetBlipAsShortRange(blip, true)
		return blip, coords
	end
end

Citizen.CreateThread(function()
   while true do
	if raidplayers ~= nil and json.encode(raidplayers) ~= "[]" then
		for i=1,#raidplayers do
			
			local denemeplayer =  GetPlayerPed(GetPlayerFromServerId(tonumber(raidplayers[i].playerid)))
	       
		
			if IsEntityDead(denemeplayer) then
				
				
					if raidplayers[i].zonename == inzone then
						if genelplayerid == raidplayers[i].playersteam then
							-- RemoveBlip(raidplayers[i].playerblip)
							removeraid(raidplayers[i].zonename, "dead")
					
							TriggerServerEvent('els_family:raidplayerblipdelete', i)
							-- table.remove(raidplayers, i)
						    break
					
						end
							
							
						
					end
			

			end



		end
	else
		Citizen.Wait(2000)
	end
	Citizen.Wait(1000)
   end
end)


Citizen.CreateThread(function()
	while true do
		if raidplayers ~= nil and json.encode(raidplayers) ~= "[]" then

			TriggerServerEvent('els_family:getnewcoords', raidplayers)
		end

		Citizen.Wait(8000)
	end
end)


RegisterNetEvent('els_family:setnewcoords')
AddEventHandler('els_family:setnewcoords', function(nsss)
	raidplayers = nsss

	rewriteblips()
end)

function rewriteblips()

	for k,v in pairs(raidplayers) do
		RemoveBlip(v.playerblip)
	end


	for k,v in pairs(raidplayers) do
		local denemeplayer = GetPlayerPed(GetPlayerFromServerId(tonumber(v.playerid)))
		-- local newblip = AddBlipForEntity(denemeplayer)
		local blip, coord = addnewblip2(denemeplayer, v.playercoord)

		v.playerblip = blip
	end


end


RegisterNUICallback('deletezone', function (data)
	for i=1,#familyzone do

		if familyzone[i].zoneown == "none" then
			if familyzone[i].zonename == data.zonename then
				local zonebitch = tostring(familyzone[i].zonename)
			
				table.remove( familyzone, i )
			
				TriggerServerEvent('els_family:deletezone', familyzone)
                SetNuiFocus(false, false)
				SendNUIMessage({
					message = "closeadminzone"
	
				})
				break
			end
		else
            TriggerEvent('els_family:notifyon' , "The zone that owns it cannot be deleted from here ")

			break

		end
	end
end)

RegisterNUICallback('startzone', function (data)

	SetNuiFocus(false,false)

	local deger1 = tonumber(data.data1)
	local deger2 = tonumber(data.data2)
	local deger3 = tonumber(data.data3)

      
	
		
		if type(deger1) == "number" and type(deger2) == "number" then
		startcreatezone(deger1,deger2, deger3)
		startcraezoneon = true
		end
	
		
end)




function addnewpoly(data)
	local deneme = isthismember()

		
	if json.encode(deneme) ~= "[]" then
		
		data.zonename = PolyZone:Create({
			vector2(data.polyzone.koord1,data.polyzone.koord2),
			vector2(data.polyzone.koord3, data.polyzone.koord4),
			vector2(data.polyzone.koord5, data.polyzone.koord6),
			vector2(data.polyzone.koord7,data.polyzone.koord8)
	
		}, {
			name=data.zonename,
			-- minZ=51.0,
			-- maxZ=62.0,
			debugGrid=Config.debugzone
			-- gridDivisions=25
		})


		
	
		data.zonename:onPlayerInOut(function(isPointInside, point, dsss)
			if isPointInside then
	
				inzone = dsss

				genelplayerid = QBCore.Functions.GetPlayerData().citizenid
			
			else

				for i=1,#raidplayers do
					if raidplayers[i].zonename == inzone then
						if genelplayerid == raidplayers[i].playersteam then
							-- RemoveBlip(raidplayers[i].playerblip)
					     	removeraid(raidplayers[i].zonename, "out")
							 TriggerServerEvent('els_family:raidplayerblipdelete', i)

							-- table.remove(raidplayers, i)
						
							break
							
							
						end
					end
				end

				inzone = false
			end
	
		end)  


		table.insert( allpolyzones, data.zonename )    
	end
end


RegisterNUICallback('getincar', function()
	local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 1.5 then
	   TriggerServerEvent("els_family:server:putInVehicle",GetPlayerServerId(closestPlayer))
	else
		yournotify('No players nearby!!', 3000)

	end
end)


RegisterNUICallback('getoutcar', function()
	local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 1.5 then
		TriggerServerEvent("els_family:server:putOutVehicle", GetPlayerServerId(closestPlayer))

	else
		yournotify('No players nearby!!', 3000)

	end
end)


RegisterNUICallback('ropeleg', function()
	local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 1.5 then
		TriggerEvent('els_family:client:useRope')

	else
		yournotify('No players nearby!!', 3000)

	end
end)

RegisterNUICallback('tapemouth', function()

   TriggerEvent('els_family:client:putMouth')

end)

RegisterNUICallback('moveplayer', function()
	local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()

	if closestPlayer ~= -1 and closestDistance <= 1.5 then
		TriggerServerEvent('els_family:server:dragPlayer', GetPlayerServerId(closestPlayer))
	else
		yournotify('No players nearby!!', 3000)
	end
end)


RegisterNUICallback('releaseplayer', function()
	local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()

	if closestPlayer ~= -1 and closestDistance <= 1.5 then
		TriggerServerEvent('els_family:server:dragPlayer', GetPlayerServerId(closestPlayer))
	else
		yournotify('No players nearby!!', 3000)
	end
end)


RegisterNetEvent('els_family:client:putMouth', function(tip)
	
	
		local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
		if closestPlayer ~= -1 and closestDistance <= 1.5 then
			TriggerServerEvent('els_family:server:putMouthtape', GetPlayerServerId(closestPlayer))
		else
			yournotify('No players nearby!!', 3000)
		end
	

end)

RegisterNetEvent('els_family:client:putInVehicle', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if IsAnyVehicleNearPoint(coords, 5.0) then
        local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

        if DoesEntityExist(vehicle) then
            local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

            for i = maxSeats - 1, 0, -1 do
                if IsVehicleSeatFree(vehicle, i) then
                    freeSeat = i
                    break
                end
            end

            if freeSeat then
                TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
                dragStatus.isDragged = false
            end
        end
    end
end)



RegisterNetEvent('els_family:client:useRope', function()

	

		local dict = "amb@prop_human_bum_bin@idle_a"
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			RequestAnimDict(dict)
			Citizen.Wait(0)
		end

		TaskPlayAnim(PlayerPedId(), dict, "idle_a", 8.0, 1.0, 3000, 1, 0, false, false, false)
		local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
		if closestPlayer ~= -1 and closestDistance <= 1.5 then
		   TriggerServerEvent('els_family:server:playerTieLegs', GetPlayerServerId(closestPlayer))
		else
			yournotify('No players nearby!!', 3000)
		end
		TriggerEvent('els_family:client:tieLegsAnim')

		Wait(3000)
			

end)

function loadModel(model)
    RequestModel(GetHashKey(model))
    while (not HasModelLoaded(GetHashKey(model))) do Wait(1) end
end

function loadDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(1)
    end
end



RegisterNetEvent('els_family:client:playerTieLegs', function()
	local playerPed = PlayerPedId()

    if not isLegsTied then 
		isLegsTied = true

		loadModel("prop_trevor_rope_01")
		loadDict("anim@heists@fleeca_bank@scope_out@return_case")
		loadDict("anim@amb@business@bgen@bgen_no_work@")

		TaskPlayAnim(playerPed, "anim@amb@business@bgen@bgen_no_work@", "sit_phone_phoneputdown_idle_nowork", 2.0, 2.0, 1.5, 2, 0, false, false, false)
		Wait(2000)
		
        FreezeEntityPosition(playerPed, true)
		Wait(2000)
		
        rope = CreateObject(GetHashKey("prop_trevor_rope_01"), playerPed, true, true, true);
		networkId = ObjToNet(rope)
		SetNetworkIdExistsOnAllMachines(networkId, true)
		SetNetworkIdCanMigrate(networkId, false)
		NetworkSetNetworkIdDynamic(networkId, true)
		AttachEntityToEntity(rope, playerPed, GetPedBoneIndex(playerPed, 36864), 0.55, 0.09, -0.13, 265.0, -10.0, 100.0, true, false, false, false, 0, true);
	else 
		ClearPedTasks(playerPed) 

		DeleteObject(rope)
		DeleteObject(handRope)

		isLegsTied = false

		FreezeEntityPosition(playerPed, false)
		ClearPedProp(playerPed, "prop_trevor_rope_01")
	end
end)


RegisterNetEvent('els_family:client:tieLegsAnim', function()
    local playerPed = PlayerPedId()

	if not IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	if isLegsTied == true then 
		return
	end

	local dict = "amb@prop_human_bum_bin@idle_a"
	RequestAnimDict(dict) 

	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(0)
	end

    TaskPlayAnim(playerPed, dict, "idle_a", 8.0, 1.0, 1500, 1, 0, false, false, false)


	loadModel("prop_trevor_rope_01")
	loadDict("anim@heists@fleeca_bank@scope_out@return_case")

	TaskPlayAnim(playerPed, "anim@heists@fleeca_bank@scope_out@return_case", "trevor_action", 2.0, 2.0, 1.5, 2, 0, false, false, false)
	Wait(2000)
	
    FreezeEntityPosition(playerPed, true)
	handRope = CreateObject(GetHashKey("prop_trevor_rope_01"), playerPed, true, true, true);

	networkId = ObjToNet(handRope)
	SetNetworkIdExistsOnAllMachines(networkId, true)
	SetNetworkIdCanMigrate(networkId, false)
	NetworkSetNetworkIdDynamic(networkId, true)

	AttachEntityToEntity(handRope, playerPed, GetPedBoneIndex(playerPed, 60309), 0.20, 0.0, 0.0, 265.0, -10.0, 100.0, true, false, false, false, 0, true);
 
	SetPedUsingActionMode(playerPed, false, -1, "DEFAULT_ACTION")
	SetPedMovementClipset(playerPed, 'move_ped_crouched', 0.55)
	SetPedStrafeClipset(playerPed, 'move_ped_crouched_strafing')
	TaskPlayAnim(playerPed, "mp_arresting", "a_uncuff", 2.0, 2.0, 1.5, 16, 0, false, false, false)
	Wait(2000)

	DeleteObject(handRope)
	FreezeEntityPosition(playerPed, false)
end)



RegisterNetEvent('els_family:client:putMouthtape', function(tip)
	DeleteObject(rope)
	DeleteObject(handProp)

	if isMouthTaped == true then 
        isMouthTaped = false
		mouthTapedText()
        return 
    end 

	loadModel("prop_anim_cash_note_b")
	handProp = CreateObject(GetHashKey("prop_anim_cash_note_b"), PlayerPedId(), true, true, true);
	AttachEntityToEntity(handProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 20178), 0.082, 0.0, -0.01, 0.0, 90.0, 0.0, true, false, false, false, 0, true);
	isMouthTaped = true
	mouthTapedText()
end)

function mouthTapedText()
	while isMouthTaped do
		local sleep = 1000
		local playerCoords = GetEntityCoords(PlayerPedId())

			sleep = 1

			local xPlayers = QBCore.Functions.GetPlayers()

			for i=1, #xPlayers, 1 do
				QBCore.Functions.DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z+0.7, Locales[Config.Language].mouth_taped_drawtext)


				local OtherPed = GetPlayerPed(xPlayers[i])
				if OtherPed ~= PlayerPedId() then
					local dist = #(GetEntityCoords(OtherPed) - playerCoords)
					
					if dist <= 5.0 then
						QBCore.Functions.DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z+0.7, Locales[Config.Language].mouth_taped_drawtext)

					end
				end
			end
	
		Wait(sleep)
	end
end


CreateThread(function()
    while true do
        local sleep = 1000

        local playerPed = PlayerPedId()

        if dragStatus.isDragged then
            sleep = 1

            local targetPed = GetPlayerPed(
                                  GetPlayerFromServerId(dragStatus.CopId))

            if not IsPedSittingInAnyVehicle(targetPed) then
                AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54,
                                     0.0, 0.0, 0.0, 0.0, false, false, false,
                                     false, 2, true)
            else
                dragStatus.isDragged = false
                DetachEntity(playerPed, true, false)
            end

            if IsPedDeadOrDying(targetPed, true) then
                dragStatus.isDragged = false
                DetachEntity(playerPed, true, false)
            end
        else
            if dragStatus.carry_status then
                dragStatus.carry_status = false
                DetachEntity(playerPed, true, false)
            end
        end

        Wait(sleep)
    end
end)



RegisterNetEvent('els_family:client:dragTarget', function(cop)


	-- return


	dragStatus.isDragged = not dragStatus.isDragged
	dragStatus.CopId = cop
	dragStatus.carry_status = true
end)



RegisterNUICallback('closeaction', function()
	SetNuiFocus(false, false)
end)
