----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----
----
----             __     __                              _   _          _         
----             \ \   / /_ _ _ __   __ _  __ _ _ __ __| | | |    __ _| |__  ___ 
----              \ \ / / _` | '_ \ / _` |/ _` | '__/ _` | | |   / _` | '_ \/ __|
----               \ V / (_| | | | | (_| | (_| | | | (_| | | |__| (_| | |_) \__ \
----                \_/ \__,_|_| |_|\__, |\__,_|_|  \__,_| |_____\__,_|_.__/|___/
----                                |___/                                        
---- 
----                                 VAMNGUARD LABS | K9 SCRIPT [QBCore]
----
----               Thank you for purchasing our script; we greatly appreciate your preference.
----        If you have any questions or any modifications in mind, please contact us via Discord.
----
----                           Support and More: https://discord.gg/G5r3Qq2j4v
----
----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----
----
Config = {}

-- K9 Spawn Position
Config.K9Spawn = {
    {
        coords = vector3(447.0754, -1000.84, 30.735),  -- Coordinates for K9 spawn
        heading = 116.37  -- Heading for K9 spawn
    },
    {
        coords = vector3(439.5705, -1001.60, 30.719),  -- Another set of coordinates
        heading = 90.0  -- Another heading
    },
    -- Add more if you want.
}

-- List of jobs allowed to spawn and interact with the K9
Config.AllowedJobs = {'police'}  -- Only 'police' can spawn and interact with the K9.

-- List of jobs that K9 cannot attack
Config.ProtectedJobs = {'police'}  -- K9 cannot attack players with the 'police' job.

-- Sniffable Items 
Config.SniffableItems = {
    'weed',        -- Item example
    'coke',       
    'meth',       
}

Config.Controls = {
    k9MenuKey = 166  -- F5 key
}

-- Notification System Configuration: Choose your preferred notification system
-- Options: 'okokNotify', 'QBCore', 'wasabiNotify'
Config.NotificationSystem = 'okokNotify'

-- Customizable Messages
Config.Text = {
    -- K9 Menu
    k9MenuTitle = 'K9 Menu',
    k9MenuVehicle = 'Vehicle',
    k9MenuAttack = 'Attack',
    k9MenuSniff = 'Sniff',

    -- K9 Vehicle Menu
    k9VehicleMenuTitle = 'K9 Vehicle Menu',
    k9VehiclePlaceK9 = 'Place K9 in vehicle',
    k9VehicleRemoveK9 = 'Remove K9 from the vehicle',
    k9VehicleBackToMain = 'Back to the main menu',

    -- K9 Attack Menu
    k9AttackMenuTitle = 'K9 Attack Menu',
    k9AttackSelectTarget = 'Select Target',
    k9AttackStopAttack = 'Stop Attack',
    k9AttackAttackSelectedTarget = 'Attack Selected Target',
    k9AttackChangeTarget = 'Change Target',
    k9AttackBackToMain = 'Back to Main Menu',

    -- K9 Sniff Menu
    k9SniffMenuTitle = 'K9 Sniff Menu',
    k9SniffSelectTarget = 'Select Target',
    k9SniffChangeTarget = 'Change Target',
    k9SniffSniffTarget = 'Sniff Target',
    k9SniffBackToMain = 'Back to Main Menu',
}

Config.Notifications = {
    k9Spawned = "K9 has been spawned.",
    cannotSpawnK9 = "You cannot spawn a K9 right now.",
    k9Returned = "K9 has been returned.",
    targetSelected = "Target has been selected.",
    noNearbyPlayers = "No nearby players found.",
    k9AttackingTarget = "K9 is attacking the target!",
    cannotAttackProtectedPlayer = "You cannot attack this protected player.",
    noTargetToAttack = "No target to attack.",
    k9StoppedAttacking = "K9 has stopped attacking.",
    k9Waiting = "K9 is waiting.",
    k9Following = "K9 is following you.",
    k9MenuNotAvailable = "K9 menu is not available.",
    k9OnlyPolice = "This action is only available to police officers.",
    sniffedItemNotification = "Sniffed items found: ",
    noSniffableItemsFound = "No sniffable items found on the target.",
    noTargetSelectedToSniff = "No target selected to sniff.",
    k9PutInVehicle = "K9 has been placed in the vehicle.",
    k9OutVehicle = "K9 has been taken out of the vehicle.",
    Eyek9StayInPlace = "Stay in Place",
    Eyek9FollowMe = "Follow Me",
    Eyek9Deploy = "Deploy K9",
    Eyek9Return = "Return K9",
}
