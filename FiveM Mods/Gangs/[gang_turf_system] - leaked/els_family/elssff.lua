
local resourceismi = tostring(GetCurrentResourceName())
local missions = json.decode(LoadResourceFile(resourceismi, "missions.json"))

function addfamily(familyid)

    local self = {}

    self.familyid = familyid
    self.source = 0
    self.saveFamily= function()
        MySQL.Sync.execute("UPDATE `els_familys` SET `family_meta` = @json WHERE `owner_id` = @owner_id AND `family_id` = @pid", {['@json'] = json.encode(self.meta), ['@owner_id'] = self.owner, ['@pid'] = self.familyid})
    end
    self.savechat= function()
        MySQL.Sync.execute("UPDATE `els_familys` SET `family_chat` = @chattt WHERE `owner_id` = @owner_id AND `family_id` = @pid", {['@chattt'] = json.encode(self.chat), ['@owner_id'] = self.owner, ['@pid'] = self.familyid})
    end

    self.savefamilyname= function()
        MySQL.Sync.execute("UPDATE `els_familys` SET `family_name` = @nameee WHERE `owner_id` = @owner_id AND `family_id` = @pid", {['@nameee'] = self.name, ['@owner_id'] = self.owner, ['@pid'] = self.familyid})
    end
    self.savefamilyimg= function()
        MySQL.Sync.execute("UPDATE `els_familys` SET `family_img` = @imageee WHERE `owner_id` = @owner_id AND `family_id` = @pid", {['@imageee'] = self.fimage, ['@owner_id'] = self.owner, ['@pid'] = self.familyid})
    end

    
    local familySQL = MySQL.Sync.fetchAll("SELECT * FROM `els_familys` WHERE `family_id` = @family_id", { ['@family_id'] = self.familyid})
    -- print(json.encode(familySQL))
    if familySQL[1] ~= nil then
        self.owner = familySQL[1].owner_id
        self.chat = json.decode(familySQL[1].family_chat)


        if familySQL[1].family_name ~= nil then
            self.name = familySQL[1].family_name
        else
            self.name = "Unnamed"
        end

        self.fimage = familySQL[1].family_img
  
        if familySQL[1].family_meta ~= nil then
            self.meta = json.decode(familySQL[1].family_meta)
            self.meta['missions'] = missions
        else
         
            self.meta = {}
            self.meta['inventorys'] = {}
            self.meta['allitems'] = {}
            self.meta['requests'] = {}
            self.meta['zones'] = {}
            self.meta['f6perm'] = false
            self.meta['garages'] = {}
            self.meta['staffss'] = {['inventoryaccess'] = "RANK1" , ['garageaccess'] = "RANK2" }
            self.meta['maininfos'] = {['familyexp'] = 50 , ['familylevel'] = 1 }
            self.meta['members'] = {{['memberid'] = familySQL[1].owner_id, ['membername'] = familySQL[1].owner_name, ['memberrank'] = "RANK5", ['membertime'] = 0, ['membersettings'] = {['permem'] = true, ['perinv'] = true, ['pergarage'] = true,['persettings']= true}} }
            self.meta['missions'] = missions

        
            self.saveFamily()
        end
      
    end



    local rTable = {}

    rTable.getName = function()
        return self.name
    end

    rTable.getAllMeta = function()
        return self.meta
    end

    rTable.getzones = function()
        return self.meta['zones']
    end

    rTable.getAllChat = function()
        return self.chat
    end
    
    rTable.getgarage = function()
        return self.meta["garages"]
    end

    rTable.getfamilyexp = function()
        return self.meta["maininfos"]
    end

    rTable.setfamilyexp = function(newdata)
        self.meta["maininfos"] = newdata
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end


    rTable.getvehiclebe = function(aracid,garageid)
        return self.meta["garages"][garageid].vehicles[aracid]
    end

    rTable.getmission = function(idsi)
        return self.meta["missions"][idsi]
    end
    rTable.updatemission = function(idsi)
        self.meta["missions"][idsi].dailyjobcount = self.meta["missions"][idsi].dailyjobcount - 1
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)
    end
    
    

    
    rTable.specificMeta = function(key)
        if self.meta[key] then
            return self.meta[key]
        else
            return nil
        end
    end
    

    rTable.insertraidzone = function(gelenzone)
   
        local bune = {['zonename'] = gelenzone}
        table.insert( self.meta.zones, bune )
        self.saveFamily()
        TriggerClientEvent('els_family:client:zonesupdate', -1, self.familyid, self.meta,gelenzone)
    end

    rTable.insertrequestplayer = function(playercid,playernames, yenisource)
   
        local bune = {['memberid'] = playercid, ['membername'] = playernames, ['memberrank'] = "RANK1", ['membertime'] = 0, ['membersettings'] = {['permem'] = false, ['perinv'] = false, ['pergarage'] = false,['persettings']= false , ['memberlastid'] = yenisource}}
        table.insert( self.meta.requests, bune )
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)
    end



    rTable.getplayerrequests = function()
       return self.meta.requests
    end
    -- rTable.insertnewplayer = function(playercid,playernames)
    --     local bune = {['memberid'] = playercid, ['membername'] = playernames, ['memberrank'] = "RANK1", ['membertime'] = 0, ['membersettings'] = {['permem'] = false, ['perinv'] = false, ['pergarage'] = false,['persettings']= false}}
    --     table.insert( self.meta.members, bune )
    --     TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)
    -- end

    
    rTable.changefamilyimg = function(newimg)
        self.fimage = newimg
        self.savefamilyimg()
        TriggerClientEvent('els_family:client:updateimg', -1, self.familyid, self.fimage)
    end
    rTable.changeaccessbeya = function(data1,data2)
        self.meta['staffss'].inventoryaccess = data1
        self.meta['staffss'].garageaccess = data2

        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)
    end
    

    rTable.changedataname = function(newname)
        self.name = newname
        self.savefamilyname()
        TriggerClientEvent('els_family:client:updatename', -1, self.familyid, self.name)
    end

    rTable.changemembertime = function(memberims)
        self.meta.members[memberims].membertime = self.meta.members[memberims].membertime + 10
        self.saveFamily()
    end

    rTable.acceptrequest = function(hey)
        table.insert( self.meta['members'], self.meta['requests'][hey] )
        table.remove( self.meta['requests'], hey )
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)
    end

    rTable.deleterequest = function(hey)
       table.remove( self.meta['requests'], hey )
       self.saveFamily()
       TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)
    end
    

    rTable.kickmemberbeya = function(key)

        if self.meta.members[key] then

            table.remove( self.meta.members, key )


            self.saveFamily()
        end
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)
    end
    

    rTable.changemembersettings = function(key, comingdata)

        if self.meta.members[key] then
            self.meta.members[key]["membersettings"]["permem"] = comingdata.mem
            self.meta.members[key]["membersettings"]["perinv"] = comingdata.inv
            self.meta.members[key]["membersettings"]["pergarage"] = comingdata.grg
            self.meta.members[key]["membersettings"]["persettings"] = comingdata.stt
            self.meta.members[key]["memberrank"] = comingdata.rank


            self.saveFamily()
        end
        TriggerClientEvent('els_family:client:updatesettings', -1, self.familyid, key, self.meta.members[key])
    end

    rTable.chatmessageinsert = function(message, playername, idsss)
      if self.chat == nil  or json.encode(self.chat) == "[]" then
       self.chat = {{['membername'] = playername , ['membermessage'] = message , ['memberid'] = idsss}}

      else
       self.chat[#self.chat + 1] = {['membername'] = playername , ['membermessage'] = message , ['memberid'] = idsss}
      
      end
      self.savechat()

      TriggerClientEvent('els_family:client:updatechat', -1, self.familyid, self.chat)
    end
    rTable.insertitem = function(item)
        table.insert(self.meta["allitems"] , item)
        
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end
    rTable.deleteitem = function(item, datsss, koord, comingvalue)
        table.remove(self.meta["allitems"] , item)
        local inventorydd = {['inventoryid'] = datsss, ['coordss'] = koord , ['type'] = comingvalue }
        table.insert(self.meta["inventorys"] , inventorydd)
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end


    rTable.deleteitemgarage = function(item, datsss, koord, comingvalue)
        table.remove(self.meta["allitems"] , item)
        local garagedd = {['garageid'] = datsss, ['coordss'] = koord , ['type'] = comingvalue, ['vehicles'] = {} }
        table.insert(self.meta["garages"] , garagedd)
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end
    rTable.deleteitemnamechange = function(item)
        table.remove(self.meta["allitems"] , item)
       
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end
    rTable.deleteitemmenu = function(item)
        table.remove(self.meta["allitems"] , item)
        self.meta["f6perm"] = true
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end

    

    

    rTable.insertvehicle = function(plate, model, garageidimiz, deleteitems)
        table.remove(self.meta["allitems"] , deleteitems)
        local vehicleingarage = {['vehiclename'] = model, ['vehicleplate'] = plate , ['vehiclemods'] ={} , ['vehiclestatus'] = "in" }
        table.insert(self.meta["garages"][garageidimiz].vehicles , vehicleingarage)
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end
    rTable.updatevehiclestatus = function(hangisibu, hangigarage)
    

      self.meta["garages"][hangigarage].vehicles[hangisibu].vehiclestatus = "out"
      self.saveFamily()
      TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end
    
    
    
    rTable.refreshinventorykoord = function(datass, coords)
       
        self.meta.inventorys[datass].coordss = coords
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end

    rTable.refreshgaragekoord = function(datass, coords)
       
        self.meta.garages[datass].coordss = coords
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end

    

    rTable.deleteinventoy = function(datass)

        table.remove( self.meta.inventorys, datass)
     
     
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end

    rTable.deletegarage = function(datass)

        table.remove( self.meta.garages, datass)
     
     
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end

    rTable.findandupdatevehicle = function(garageidisi, plaka, familyidisi)
       for k,v in pairs(self.meta["garages"][garageidisi].vehicles) do
     
        if v.vehicleplate == plaka then
            print('helpppp')
            self.meta["garages"][garageidisi].vehicles[k].vehiclestatus = "in"
            break
        end
       end
   
     
     
        self.saveFamily()
        TriggerClientEvent('els_family:client:updateinsertitem', -1, self.familyid, self.meta)

    end

    
    
  
    
    return rTable

end

