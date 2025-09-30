Config = {}


Config.Markets = {
    {['itemname'] = "largevalut", ['itemlevel'] = 1, ['itemlabel'] = "Large Valut", ['itemprice'] = 1000, ['itemexplanation'] = "Info: This Is Giving Family 40 slot Vault" ,['image'] = "https://www.pngall.com/wp-content/uploads/5/Money-Vault-PNG.png" , ['type'] = "inventory"},
    {['itemname'] = "mediumvalut",['itemlevel'] = 1, ['itemlabel'] = "Medium Valut", ['itemprice'] = 1000, ['itemexplanation'] = "Info: This Is Giving Family 20 slot Vault" ,['image'] = "https://pngimg.com/uploads/bank_vault/bank_vault_PNG41.png" , ['type'] = "inventory"},
    {['itemname'] = "changename", ['itemlevel'] = 5,['itemlabel'] = "Change Name", ['itemprice'] = 1000, ['itemexplanation'] = "Info: This Is Change your Family Name" ,['image'] = "https://onlineconvertfree.com/img/logo.png" , ['type'] = "others"},
    {['itemname'] = "mediumgarage", ['itemlevel'] = 1,['itemlabel'] = "Medium Garage", ['itemprice'] = 1000, ['itemexplanation'] = "Info: This Is Add Medium Garage Your Family" ,['image'] = "https://www.pngmart.com/files/7/Garage-Transparent-Background.png" , ['type'] = "garage"},
    {['itemname'] = "manana", ['itemlevel'] = 1,['itemlabel'] = "Manana Vehicle", ['itemprice'] = 1000, ['itemexplanation'] = "Info: This Is Vehicle For Your Family" ,['image'] = "manana.png" , ['type'] = "vehicle"},
    {['itemname'] = "sultanrs", ['itemlevel'] = 1,['itemlabel'] = "Sultan Vehicle", ['itemprice'] = 1000, ['itemexplanation'] = "Info: This Is Vehicle For Your Family" ,['image'] = "https://wiki.rage.mp/images/thumb/f/f4/Sultan.png/164px-Sultan.png" , ['type'] = "vehicle"},
    {['itemname'] = "tornado",['itemlevel'] = 6, ['itemlabel'] = "Tornado Vehicle", ['itemprice'] = 1000, ['itemexplanation'] = "Info: This Is Vehicle For Your Family" ,['image'] = "tornado.png" , ['type'] = "vehicle"},
    {['itemname'] = "familymenu",['itemlevel'] = 1, ['itemlabel'] = "Family Menu", ['itemprice'] = 1000, ['itemexplanation'] = "Info: This is menu for Your Family" ,['image'] = "menuresim.png" , ['type'] = "others"}



}

Config.needrestart = true


Config.debugzone = false


Config.Maxraidlimit = 5

Config.CreateFamily = {
    {['createfamilylabel'] = "[E] Create Family", ['createfamilycoord'] = vector3(394.87, -817.13 , 29.29), ['createfamilyblip'] = true,['createfamilyblipname'] = "Family Man"}
}


Config.notifytype = "qbnotify"    --- esxnotify, costumnotify


Config.raidtime = 50

Config.adminzoneperm = {
  -- "OUT48075"
} 


Config.levelinfo ={
  ["0"] = {['lowexp'] = 0, ['highexp'] = 1000 ,['level']= 1},
  ["1"] = {['lowexp'] = 1001, ['highexp'] = 3000,['level']= 2},
  ["2"] = {['lowexp'] = 3001, ['highexp'] = 6000,['level']= 3},
  ["3"] = {['lowexp'] = 6001, ['highexp'] = 10000,['level']= 4},
  ["4"] = {['lowexp'] = 10001, ['highexp'] = 15000,['level']= 5},
  ["5"] = {['lowexp'] = 15001, ['highexp'] = 20000,['level']= 6},
  ["6"] = {['lowexp'] = 20001, ['highexp'] = 27000,['level']= 7},
  ["7"] = {['lowexp'] = 27001, ['highexp'] = 35000,['level']= 8},
  ["8"] = {['lowexp'] = 35001, ['highexp'] = 42000,['level']= 9},
  ["9"] = {['lowexp'] = 42001, ['highexp'] = 50000,['level']= 10}


}


inventorysystem = function(inventoryid, slots)

end


notifycustom = function (text, time)
   print('ss')
end


startmissioninconfig = function(data, familyid)
  if data.missionvalue == "job1" then

    TriggerEvent('els_family:mission:trailjob', familyid)
  end
end