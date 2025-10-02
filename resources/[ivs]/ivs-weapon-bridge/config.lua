Config = {}

-- list the resources that contain your weapon metas
-- add all your weapon-pack resources here
Config.MetaResources = {
    'weaponspack',
  
      
}

-- dev "shop" settings
Config.EnableDevShop = true
Config.DevShopCommand = 'wepshop'     -- /wepshop opens a menu with all detected weapons
Config.GiveCommand    = 'givewep'     -- /givewep akm  (adds ox item weapon_akm)
Config.DefaultWeight  = 3000          -- weight assigned to generated items
Config.Price          = 0             -- price in dev shop (0 = free)
Config.AdminOnly      = true          -- restrict commands to admins (ACE 'group.admin')
