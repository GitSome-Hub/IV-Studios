----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----
---
----             __     __                              _   _          _         
----             \ \   / /_ _ _ __   __ _  __ _ _ __ __| | | |    __ _| |__  ___ 
----              \ \ / / _` | '_ \ / _` |/ _` | '__/ _` | | |   / _` | '_ \/ __|
----               \ V / (_| | | | | (_| | (_| | | | (_| | | |__| (_| | |_) \__ \
----                \_/ \__,_|_| |_|\__, |\__,_|_|  \__,_| |_____\__,_|_.__/|___/
----                                |___/                                        
---- 
----                         VANGUARD LABS | CHRISTMAS GIFTS [ESX/QBCORE]
----
----               Thank you for purchasing our script; we greatly appreciate your preference.
----        If you have any questions or any modifications in mind, please contact us via Discord.
----
----                           Support and More: https://discord.gg/rq5yVBACTf
----                            if link is not working, add me: james_vanguard
----
----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----
----

-- Configuration settings
Config = {}

-- ===============================
--    General Settings
-- ===============================
Config.Mysql = "oxmysql" -- Check the manifest.lua when changed. | ghmattimysql / oxmysql / mysql-async
Config.OpenCommand = "rewards"
Config.PlayTime = true -- Does the player need to stay in the game for a certain amount of time to receive the reward?
Config.Time = 60 * 60000 -- 30 * 60000 = 30 minutes
Config.AFKCheck = true -- If the player is AFK for 10 minutes, the time they should have stayed in the game is reset
Config.StartDay = { day = 3, month = 12, year = 2024 } -- This is the start of the rewards, this is Day 3 - The rewards increase day by day from this date

-- ===============================
--    Rewards Settings
-- ===============================
Config.Rewards = {
    { day = 1, itemName = "money", itemLabel = "Gift #01", itemCount = 50, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 2, itemName = "money", itemLabel = "Gift #02", itemCount = 100, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 3, itemName = "money", itemLabel = "Gift #03", itemCount = 150, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 4, itemName = "money", itemLabel = "Gift #04", itemCount = 200, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 5, itemName = "money", itemLabel = "Gift #05", itemCount = 250, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 6, itemName = "money", itemLabel = "Gift #06", itemCount = 300, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 7, itemName = "money", itemLabel = "Gift #07", itemCount = 350, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 8, itemName = "money", itemLabel = "Gift #08", itemCount = 400, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 9, itemName = "money", itemLabel = "Gift #09", itemCount = 450, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 10, itemName = "money", itemLabel = "Gift #10", itemCount = 500, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 11, itemName = "money", itemLabel = "Gift #11", itemCount = 550, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 12, itemName = "money", itemLabel = "Gift #12", itemCount = 600, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 13, itemName = "money", itemLabel = "Gift #13", itemCount = 650, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 14, itemName = "money", itemLabel = "Gift #14", itemCount = 700, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 15, itemName = "money", itemLabel = "Gift #15", itemCount = 750, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 16, itemName = "money", itemLabel = "Gift #16", itemCount = 800, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 17, itemName = "money", itemLabel = "Gift #17", itemCount = 850, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 18, itemName = "money", itemLabel = "Gift #18", itemCount = 900, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 19, itemName = "money", itemLabel = "Gift #19", itemCount = 950, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 20, itemName = "money", itemLabel = "Gift #20", itemCount = 1000, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 21, itemName = "money", itemLabel = "Gift #21", itemCount = 1050, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 22, itemName = "money", itemLabel = "Gift #22", itemCount = 1100, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 23, itemName = "money", itemLabel = "Gift #23", itemCount = 1150, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 24, itemName = "money", itemLabel = "Gift #24", itemCount = 1200, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 25, itemName = "money", itemLabel = "Gift #25", itemCount = 1250, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 26, itemName = "money", itemLabel = "Gift #26", itemCount = 1300, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 27, itemName = "money", itemLabel = "Gift #27", itemCount = 1350, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 28, itemName = "money", itemLabel = "Gift #28", itemCount = 1400, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 29, itemName = "money", itemLabel = "Gift #29", itemCount = 1450, itemType = "item", unique = false, image = "./images/gift.png" },
    { day = 30, itemName = "money", itemLabel = "Gift #30", itemCount = 1500, itemType = "item", unique = false, image = "./images/gift.png" },
}


-- ===============================
--    Language Settings
-- ===============================
Config.Language = {
    title1 = "CHRISTMAS GIFTS",
    title2 = "STAY ONLINE!",
    leftDesc = " Stay online and get gifts!",
    nextReward = "FOR THE NEXT REWARD",
    collected = "COLLECTED!",
}