QBCore = exports['qb-core']:GetCoreObject()
registeredFamily = {}

local resourceismi = tostring(GetCurrentResourceName())
local zones = json.decode(LoadResourceFile(resourceismi, "zones.json"))


zonesave = function(data)

 
	
    local savebilgi = SaveResourceFile(resourceismi,  "zones.json", data, -1)

    return savebilgi

end

zoneget = function()



    local loadbilgi = LoadResourceFile(resourceismi, "zones.json")

    if loadbilgi then return loadbilgi else return nil end
end





CreateThread(function()
    MySQL.Async.fetchAll("SELECT * FROM `els_familys`", {}, function(FamilyLoad)
        if FamilyLoad[1] ~= nil then
            for i = 1, #FamilyLoad do
                local familyident = tonumber(FamilyLoad[i].family_id)
               
                registeredFamily[familyident] = addfamily(familyident)
             
            end
            
        end
    end)
   
end)






-- RegisterServerEvent('els_family:getadminzone')
-- AddEventHandler('els_family:getadminzone', function(src)
--     local src = source
--     local xPlayer = ESX.GetPlayerFromId(src)
--     local getzones = json.decode(zoneget)
-- end)

RegisterServerEvent('els_family:getnewcoords')
AddEventHandler('els_family:getnewcoords', function(data)
    local newdata = data
    for k,v in pairs(newdata) do
        local coords = GetEntityCoords(GetPlayerPed(v.playerid))
		v.playercoord = coords
    end

    TriggerClientEvent('els_family:setnewcoords', -1 ,newdata )

end)


RegisterServerEvent('els_family:loadfamilys')
AddEventHandler('els_family:loadfamilys', function(src)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM `els_familys`", {}, function(result)
            if result then
                local tempTable = {}

                for i = 1, #result do
                    tempTable[i] = {
                        ['ownerid'] = result[i].owner_id, 
                        ['name'] = result[i].family_name,
                        ['familyid'] = result[i].family_id,
                        ['familychat'] = json.decode(result[i].family_chat),
                        ['ownername'] = result[i].owner_name,
                        ['image'] = result[i].family_img,
                        ['meta'] = json.decode(result[i].family_meta)
                    
                    }
                end
                

                TriggerClientEvent('els_family:client:getFamilys', src, tempTable, zones)
            end
        end)
    end
end)


RegisterNetEvent('els_family:buyitem')
AddEventHandler('els_family:buyitem', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local bakiye = Player.Functions.GetMoney('cash')
    local item = nil 
    for k,v in pairs(Config.Markets) do
        if v.itemname == data.buyingitem then
            item = v
            break
        end
    end

    if tonumber(bakiye) > tonumber(item.itemprice) then
        registeredFamily[data.changeid].insertitem(item)
        Player.Functions.RemoveMoney('cash', tonumber(item.itemprice), 'familybuy')

        TriggerClientEvent('els_family:notifyon' ,src, "Item purchased")
    else
        TriggerClientEvent('els_family:notifyon' ,src, "You dont have money")
    end
    
end)
RegisterNetEvent('els_family:rejectplayer')
AddEventHandler('els_family:rejectplayer', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    registeredFamily[data.changeid].deleterequest((data.whichplayer + 1))
    
end)
RegisterNetEvent('els_family:acceptplayer')
AddEventHandler('els_family:acceptplayer', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newzone = json.decode(zoneget())
    -- local getplayerid

    registeredFamily[data.changeid].acceptrequest((data.whichplayer + 1))
    TriggerClientEvent('els_family:writenewzone', -1, newzone)
end)

RegisterNetEvent('els_family:zoneraid')
AddEventHandler('els_family:zoneraid', function(familyidne, zonenameb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local datamiz = json.decode(zoneget())
   for k,v in pairs(datamiz) do
      if v.zonename == zonenameb then
        v.zoneown = familyidne
        break
      end
   end
   zonesave(json.encode(datamiz))
    registeredFamily[familyidne].insertraidzone(zonenameb)
    
end)



RegisterNetEvent('els_family:sendzoneinfo')
AddEventHandler('els_family:sendzoneinfo', function(data,zoneinfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if zoneinfo then
        if data.itemname == "largevalut" then
        local coords = GetEntityCoords(GetPlayerPed(src))
        local bbbb = math.random( 1000, 9999 )
        registeredFamily[data.changeid].deleteitem((data.usingitem + 1) ,bbbb ,coords, 40)
        TriggerClientEvent('els_family:notifyon' , src,"Family inventory created")
        elseif data.itemname == "mediumvalut" then
            local coords = GetEntityCoords(GetPlayerPed(src))
            local bbbb = math.random( 1000, 9999 )
            registeredFamily[data.changeid].deleteitem((data.usingitem + 1) ,bbbb ,coords, 40)
            TriggerClientEvent('els_family:notifyon' , src,"Family inventory created")
        elseif data.itemname == "mediumgarage" then
            local coords = GetEntityCoords(GetPlayerPed(src))
            local bbbb = math.random( 10000, 99999 )
            registeredFamily[data.changeid].deleteitemgarage((data.usingitem + 1) ,bbbb ,coords, 10)
            TriggerClientEvent('els_family:notifyon' , src,"Family garage created")
        end
    else
        TriggerClientEvent('els_family:notifyon' , src,"You are not in the family zone")
    end
    
end)


RegisterNetEvent('els_family:gotozonesave')
AddEventHandler('els_family:gotozonesave', function(gotozonesave)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    local datamiz = json.decode(zoneget())
    
        local count = math.random( 1, 9999 )
       

        local thisdata = {["zonrerot"] = gotozonesave.realkoord.rot,["zoneheight"] = gotozonesave.realkoord.height,["zonecoord"] = {["x"] = gotozonesave.realkoord.x,["y"] = gotozonesave.realkoord.y,["z"] = gotozonesave.realkoord.z},["polyzone"] = {["koord3"] = gotozonesave.koord2.x,["koord2"] = gotozonesave.koord1.y,["koord5"] = gotozonesave.koord3.x,["koord6"] = gotozonesave.koord3.y,["koord1"] = gotozonesave.koord1.x ,["koord8"] = gotozonesave.koord4.y,["koord7"] = gotozonesave.koord4.x,["koord4"] = gotozonesave.koord2.y,["name"]= 'zone'..count+1},["zonename"] = 'zone'..count+1,["zonerank"] = 1,["zonewidth"] = gotozonesave.realkoord.width,["zoneown"] = "none", ["zoneraid"] = false}
       if datamiz == nil or json.encode(datamiz) == "[]" then
          datamiz = {}
          table.insert( datamiz, {["zonrerot"] = gotozonesave.realkoord.rot,["zoneheight"] = gotozonesave.realkoord.height,["zonecoord"] = {["x"] = gotozonesave.realkoord.x,["y"] = gotozonesave.realkoord.y,["z"] = gotozonesave.realkoord.z},["polyzone"] = {["koord3"] = gotozonesave.koord2.x,["koord2"] = gotozonesave.koord1.y,["koord5"] = gotozonesave.koord3.x,["koord6"] = gotozonesave.koord3.y,["koord1"] = gotozonesave.koord1.x ,["koord8"] = gotozonesave.koord4.y,["koord7"] = gotozonesave.koord4.x,["koord4"] = gotozonesave.koord2.y,["name"]= 'zone'..count+1},["zonename"] = 'zone'..count+1,["zonerank"] = 1,["zonewidth"] = gotozonesave.realkoord.width,["zoneown"] = "none" , ["zoneraid"] = false} )  
          
       else

        table.insert( datamiz, {["zonrerot"] = gotozonesave.realkoord.rot,["zoneheight"] = gotozonesave.realkoord.height,["zonecoord"] = {["x"] = gotozonesave.realkoord.x,["y"] = gotozonesave.realkoord.y,["z"] = gotozonesave.realkoord.z},["polyzone"] = {["koord3"] = gotozonesave.koord2.x,["koord2"] = gotozonesave.koord1.y,["koord5"] = gotozonesave.koord3.x,["koord6"] = gotozonesave.koord3.y,["koord1"] = gotozonesave.koord1.x ,["koord8"] = gotozonesave.koord4.y,["koord7"] = gotozonesave.koord4.x,["koord4"] = gotozonesave.koord2.y,["name"]= 'zone'..count+1},["zonename"] = 'zone'..count+1,["zonerank"] = 1,["zonewidth"] = gotozonesave.realkoord.width,["zoneown"] = "none" , ["zoneraid"] = false}  )

       end
     zonesave(json.encode(datamiz))
     TriggerClientEvent('els_family:sendagainzones', -1, datamiz , thisdata)
end)
RegisterNetEvent('els_family:deletezone')
AddEventHandler('els_family:deletezone', function(newzone)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
   
    zonesave(json.encode(newzone))

    TriggerClientEvent('els_family:writenewzone', -1, newzone)

end)




RegisterServerEvent('els_familyzone:raidupdate')
AddEventHandler('els_familyzone:raidupdate', function(zonename)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local datamiz = json.decode(zoneget())
    for k,v in pairs(datamiz) do
        if v.zonename == zonename then
            v.zoneraid = true
            
            
            break
        end
    end

    zonesave(json.encode(datamiz))
    TriggerClientEvent('els_family:zonenewdata', -1, datamiz, src, zonename, Player.PlayerData.citizenid)

end)

RegisterNetEvent('els_family:usingitem')
AddEventHandler('els_family:usingitem', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    if data.itemname == "largevalut" then
        local zoneler = registeredFamily[data.changeid].getzones()
        if json.encode(zoneler) ~= "[]" then
 
            TriggerClientEvent('els_family:checkinzone', src, data)
        else
            TriggerClientEvent('els_family:notifyon' , src,"You don't have family zone")
        end
  
    elseif data.itemname == "mediumvalut" then
        local zoneler = registeredFamily[data.changeid].getzones()
        if json.encode(zoneler) ~= "[]" then
 
            TriggerClientEvent('els_family:checkinzone', src, data)
        else
            TriggerClientEvent('els_family:notifyon' , src,"You don't have family zone")
        end
       
    elseif data.itemname == "mediumgarage" then
        local zoneler = registeredFamily[data.changeid].getzones()
        if json.encode(zoneler) ~= "[]" then
 
            TriggerClientEvent('els_family:checkinzone', src, data)
        else
            TriggerClientEvent('els_family:notifyon' , src,"You don't have family zone")
        end

    elseif data.itemtype == "vehicle" then
        local getgarage = registeredFamily[data.changeid].getgarage()
   
        if #getgarage > 0 then
           for i=1,#getgarage do
                if getgarage[i].type > #getgarage[i].vehicles then
                    local randimss = math.random( 10, 99)
                    local generetaplate = data.changeid .. randimss.."EX"
                    registeredFamily[data.changeid].insertvehicle(generetaplate, data.itemname,i,(data.usingitem + 1))
                    TriggerClientEvent('els_family:notifyon' , src,"Car put in garage")
                    break
                end
           end
        else
            TriggerClientEvent('els_family:notifyon' , src,"You Dont Have Garage in Your Family")
        end

    -- elseif data.type == "vehicle" then
    --     local getgarage = registeredFamily[data.changeid].getgarage()
   
    --     if #getgarage > 0 then
    --        for i=1,#getgarage do
    --             if getgarage[i].type > #getgarage[i].vehicles then
    --                 local randimss = math.random( 1, 999)
    --                 local generetaplate = data.changeid .. randimss.."QB"
    --                 registeredFamily[data.changeid].insertvehicle(generetaplate, data.itemname,i,(data.usingitem + 1))
    --                 TriggerClientEvent('els_family:notifyon' , src,"Car put in garage")
    --                 break
    --             end
    --        end
    --     else
    --         TriggerClientEvent('els_family:notifyon' , src,"You Dont Have Garage in Your Family")
    --     end
    elseif data.itemname == "changename" then
          registeredFamily[data.changeid].deleteitemnamechange((data.usingitem + 1))
          TriggerClientEvent('els_family:notifyon' , src,"Family name changed")
          TriggerClientEvent('els_family:openchangename', src, data)
      
    elseif data.itemname == "familymenu" then
        registeredFamily[data.changeid].deleteitemmenu((data.usingitem + 1))
        TriggerClientEvent('els_family:notifyon' , src,"F6 Menu Active")

    end
  
    
end)

function controlexpforlevel(dataexp)
    local this = 0
    for k,v in pairs(Config.levelinfo) do
      
        if tonumber(v.lowexp) <  tonumber(dataexp) and tonumber(dataexp) <  tonumber(v.highexp) then
            this = v.level
        end
    end
    return this

end


addfamilyexp = function(familyid, givinexp)

    if registeredFamily[familyid] ~= nil then
        local getfamilyexp = registeredFamily[familyid].getfamilyexp()

        getfamilyexp.familyexp = tonumber(getfamilyexp.familyexp) + tonumber(givinexp)
        local controlexp = controlexpforlevel(getfamilyexp.familyexp)

        getfamilyexp.familylevel = tonumber(controlexp)

        registeredFamily[familyid].setfamilyexp(getfamilyexp)
    end
    
end

RegisterNetEvent('els_family:informnewname')
AddEventHandler('els_family:informnewname', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
  
    registeredFamily[data.changeid].changedataname(data.newname)
    
  
    
end)

RegisterNetEvent('els_family:raidplayerblipdelete')
AddEventHandler('els_family:raidplayerblipdelete', function(deleteid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    TriggerClientEvent('els_family:raidplayerblipdelete_client', -1 , deleteid)
  

    
  
    
end)


RegisterNetEvent('els_family:zonechange')
AddEventHandler('els_family:zonechange', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local datamiz = json.decode(zoneget())
    for k,v in pairs(datamiz) do
       if v.zonename == data.name then
         v.zoneraid = false
         break
       end
    end

    zonesave(json.encode(datamiz))
    TriggerClientEvent('els_family:zonechange:server', -1, datamiz)

end)

RegisterNetEvent('els_family:joinnewfamily')
AddEventHandler('els_family:joinnewfamily', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local getrequest = registeredFamily[data.changeid].getplayerrequests()
    local playername = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    if getrequest == nil or json.encode(getrequest) == "[]" then
        registeredFamily[data.changeid].insertrequestplayer(Player.PlayerData.citizenid,playername, src)
        TriggerClientEvent('els_family:notifyon' , src,"Application sent successfully. Please stand by.")

    else
        local varevet = false
        for k,v in pairs(getrequest) do
            if v.memberid == Player.PlayerData.citizenid then
                varevet = true
                break
            end
        end

        if varevet == false then 
           registeredFamily[data.changeid].insertrequestplayer(Player.PlayerData.citizenid,playername, src)
           TriggerClientEvent('els_family:notifyon' , src,"Application sent successfully. Please stand by.")
        else
           TriggerClientEvent('els_family:notifyon' , src,"You have already applied here.")

        end
    end
    -- local playername = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    
end)

RegisterNetEvent('els_family:createnewfamily')
AddEventHandler('els_family:createnewfamily', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playername = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    -- local playername = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    local random = math.random( 1000, 9999)

    MySQL.Async.insert("INSERT INTO `els_familys` (`owner_id`, `family_id`, `family_name`, `family_img`,`owner_name`) VALUES (@owner_id, @family_id, @family_name, @family_img, @owner_name)", {['@owner_id'] = Player.PlayerData.citizenid, ['@family_id'] = random, ['@family_name'] = data.familyname, ['@family_img'] = data.familyimg ,['owner_name'] = playername }, function(fff)

        registeredFamily[random] = addfamily(random)    

        TriggerClientEvent('els_family:client:newfamily', -1, {['familyid'] = random,['ownerid'] = Player.PlayerData.citizenid, ['name'] = data.familyname, ['ownername'] = playername, ['image'] = data.familyimg, ['meta'] =  registeredFamily[random].getAllMeta() , ['familychat'] = registeredFamily[random].getAllChat()}) 

        Citizen.SetTimeout(1000, function()
            TriggerClientEvent('els_family:client:loadzones',src)
          end)
    end)

    
  
    
end)



RegisterNetEvent('els_family:correctmission')
AddEventHandler('els_family:correctmission', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local heyhey = registeredFamily[data.changeid].getmission((data.missionid + 1))
    if heyhey.dailyjobcount > 0 then
        registeredFamily[data.changeid].updatemission((data.missionid + 1))
        TriggerClientEvent('els_family:startmission', src, heyhey, data.changeid)
        
    else
        TriggerClientEvent('els_family:nopemission', src)
        
    end
    
  
    
end)



RegisterNetEvent('els_family:changeimage')
AddEventHandler('els_family:changeimage', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
  
    registeredFamily[data.changeid].changefamilyimg(data.imageurl)
    TriggerClientEvent('els_family:notifyon' , src,"Family picture changed")
  
    
end)




RegisterNetEvent('els_family:server:updatetime')
AddEventHandler('els_family:server:updatetime', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
  
    registeredFamily[data.familyiddsi].changemembertime(data.membernm)
    local meta = registeredFamily[data.familyiddsi].getAllMeta()
    TriggerClientEvent('els_family:updateself', src, data.familyiddsi,meta )
    
  
    
end)



RegisterNetEvent('els_family:refreshinventorycoords')
AddEventHandler('els_family:refreshinventorycoords', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    registeredFamily[data.changeid].refreshinventorykoord((data.rfress + 1) , coords)
 
    
  
    
end)

RegisterNetEvent('els_family:vehicleout')
AddEventHandler('els_family:vehicleout', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
 
    registeredFamily[data.changeid].updatevehiclestatus((data.outvehicleid + 1), data.garageidsi)
    local getvehicle = registeredFamily[data.changeid].getvehiclebe((data.outvehicleid + 1), data.garageidsi)
    TriggerClientEvent('els_family:spawnvehicle', src, coords,getvehicle)
 
    
  
    
end)
RegisterNetEvent('els_family:removevehicle')
AddEventHandler('els_family:removevehicle', function(data1,data2,data3 , entitiy)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
 
    registeredFamily[data2].findandupdatevehicle(data3, data1, data2)

    TriggerClientEvent('els_family:deletevehicle', src, entitiy)
 
    
  
    
end)




RegisterNetEvent('els_family:refreshgaragecoords')
AddEventHandler('els_family:refreshgaragecoords', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    registeredFamily[data.changeid].refreshgaragekoord((data.rfress + 1) , coords)
 
    
  
    
end)



RegisterNetEvent('els_family:deleteinventory')
AddEventHandler('els_family:deleteinventory', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    registeredFamily[data.changeid].deleteinventoy((data.deletetype + 1))
 
    
  
    
end)


RegisterNetEvent('els_family:deletegarage')
AddEventHandler('els_family:deletegarage', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    registeredFamily[data.changeid].deletegarage((data.deletetype + 1))


  
    
end)

RegisterServerEvent('els_family:kickmember')
AddEventHandler('els_family:kickmember', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    registeredFamily[data.changeid].kickmemberbeya((data.changememberid + 1))
    TriggerClientEvent('els_family:notifyon' , src,"Member Kicked !!")
end)

RegisterServerEvent('els_family:updatemember')
AddEventHandler('els_family:updatemember', function(datass)
  
    registeredFamily[datass.changeid].changemembersettings((datass.changememberid + 1), datass.infoss)


end)

RegisterServerEvent('els_family:changeaccess')
AddEventHandler('els_family:changeaccess', function(datass)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    registeredFamily[datass.changeid].changeaccessbeya(datass.inventoryst,datass.garagest)
    TriggerClientEvent('els_family:notifyon' , src,"Authorization has been updated")

end)


RegisterServerEvent('els_family:informessage')
AddEventHandler('els_family:informessage', function(datass)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playername = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    registeredFamily[datass.changeid].chatmessageinsert(datass.message,playername , Player.PlayerData.citizenid)


end)

RegisterServerEvent('els_family:getfamilysforcreate')
AddEventHandler('els_family:getfamilysforcreate', function(datass)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.Async.fetchAll("SELECT * FROM `els_familys`", {}, function(result)
        local tempTable = {}
        if result then
            for i = 1, #result do
                tempTable[i] = {
                    ['ownerid'] = result[i].owner_id, 
                    ['name'] = result[i].family_name,
                    ['familyid'] = result[i].family_id,
                    ['familychat'] = json.decode(result[i].family_chat),
                    ['ownername'] = result[i].owner_name,
                    ['image'] = result[i].family_img,
                    ['meta'] = json.decode(result[i].family_meta)
                
                }
            end
            TriggerClientEvent('els_family:sendthis', src, tempTable)
        else
            TriggerClientEvent('els_family:sendthis', src)
        end
       
    end)


end)


RegisterServerEvent('els_family:server:putInVehicle', function(target)
    TriggerClientEvent('els_family:client:putInVehicle', target)
end)


RegisterServerEvent('els_family:server:putOutVehicle', function(target)
    TriggerClientEvent('els_family:client:putOutVehicle', target)
end)


RegisterNetEvent('els_family:server:playerTieLegs', function(target)
    TriggerClientEvent('els_family:client:playerTieLegs', target)
end)


RegisterServerEvent('els_family:server:putMouthtape', function(target)
    TriggerClientEvent('els_family:client:putMouthtape', target)
end)


RegisterServerEvent('els_family:server:dragPlayer', function(target)
    local src = source

    TriggerClientEvent('els_family:client:dragTarget', target, src)
end)
-- RegisterCommand("addexptry", function(source, args, rawCommand)
    

--     addfamilyexp(2716, 3000)

-- end)


