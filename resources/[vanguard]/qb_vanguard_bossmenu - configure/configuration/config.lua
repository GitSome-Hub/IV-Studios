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
----                                 VANGUARD LABS | MULTI JOBS BOSS MENU [QBCORE]
----
----               Thank you for purchasing our script; we greatly appreciate your preference.
----        If you have any questions or any modifications in mind, please contact us via Discord.
----
----                           Support and More: https://discord.gg/rq5yVBACTf
----
----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _   
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ 
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|  
----

Config = {}

-- ===============================
--    Command Configuration
-- ===============================
Config.Command = 'bossmenu'
Config.CloseKey = 200 -- ESC key
Config.EnableKeybind = true
Config.KeybindKey = 'F6'

-- ===============================
--    Animation Settings
-- ===============================
Config.EnableAnimations = true

-- ===============================
--    Transaction Limits
-- ===============================
Config.MaxWithdrawal = 100000
Config.MaxDeposit = 100000

-- ===============================
--    Duty Status Configuration
-- ===============================
Config.DutyStatuses = {
    "on-duty",
    "off-duty", 
    "patrolling", 
    "break", 
    "training", 
    "court"
}

-- ===============================
--    Job Configurations
-- ===============================
Config.Jobs = {
    police = {
        name = 'police',
        label = 'Los Santos Police Department',
        icon = 'fas fa-shield-alt',
        minGrade = 3, -- Minimum grade to access the menu
        hirePermission = 3, -- Minimum grade to hire employees
        firePermission = 3, -- Minimum grade to fire employees
        promotePermission = 3, -- Minimum grade to promote employees
        demotePermission = 3, -- Minimum grade to demote employees
        withdrawPermission = 4, -- Minimum grade to withdraw money
        depositPermission = 3, -- Minimum grade to deposit money
        managePermission = 4, -- Minimum grade to manage grades
        grades = {
            {
                grade = 0,
                label = 'Cadet',
                salary = 1500
            },
            {
                grade = 1,
                label = 'Officer',
                salary = 2000
            },
            {
                grade = 2,
                label = 'Sergeant',
                salary = 2500
            },
            {
                grade = 3,
                label = 'Lieutenant',
                salary = 3000
            },
            {
                grade = 4,
                label = 'Captain',
                salary = 3500
            },
            {
                grade = 5,
                label = 'Chief',
                salary = 4000
            }
        }
    },
    
    ambulance = {
        name = 'ambulance',
        label = 'Emergency Medical Services',
        icon = 'fas fa-ambulance',
        minGrade = 3,
        hirePermission = 3,
        firePermission = 3,
        promotePermission = 3,
        demotePermission = 3,
        withdrawPermission = 4,
        depositPermission = 3,
        managePermission = 4,
        grades = {
            {
                grade = 0,
                label = 'EMT',
                salary = 1500
            },
            {
                grade = 1,
                label = 'Paramedic',
                salary = 2000
            },
            {
                grade = 2,
                label = 'Doctor',
                salary = 2500
            },
            {
                grade = 3,
                label = 'Surgeon',
                salary = 3000
            },
            {
                grade = 4,
                label = 'Chief Medical Officer',
                salary = 3500
            }
        }
    },
    
    mechanic = {
        name = 'mechanic',
        label = 'Mechanic Shop',
        icon = 'fas fa-wrench',
        minGrade = 3,
        hirePermission = 3,
        firePermission = 3,
        promotePermission = 3,
        demotePermission = 3,
        withdrawPermission = 4,
        depositPermission = 3,
        managePermission = 4,
        grades = {
            {
                grade = 0,
                label = 'Trainee',
                salary = 1200
            },
            {
                grade = 1,
                label = 'Mechanic',
                salary = 1600
            },
            {
                grade = 2,
                label = 'Lead Mechanic',
                salary = 2000
            },
            {
                grade = 3,
                label = 'Supervisor',
                salary = 2500
            },
            {
                grade = 4,
                label = 'Manager',
                salary = 3000
            }
        }
    }
}

-- ===============================
--    Notification Texts
-- ===============================
Config.Texts = {
    -- ===============================
    --    Access Messages
    -- ===============================
    NoAccess = 'You do not have access to the boss menu.',
    KeybindHelpText = 'Open Boss Menu',
    
    -- ===============================
    --    Hiring Messages
    -- ===============================
    NoHirePermission = 'You do not have permission to hire employees.',
    PlayerNotFound = 'Player not found.',
    AlreadyEmployed = 'This player is already employed by your organization.',
    CannotHireHigherRank = 'You cannot hire someone at a higher rank than yourself.',
    HiredSuccess = 'You have hired %s.',
    YouWereHired = 'You have been hired by %s.',
    HiredLog = 'Hired %s',
    
    -- ===============================
    --    Firing Messages
    -- ===============================
    NoFirePermission = 'You do not have permission to fire employees.',
    NotAnEmployee = 'This player is not an employee of your organization.',
    CannotFireHigherRank = 'You cannot fire someone with a higher rank than yourself.',
    FiredSuccess = 'You have fired %s.',
    YouWereFired = 'You have been fired from your job.',
    FiredLog = 'Fired %s',
    FireFailed = 'Failed to fire employee.',
    EmployeeNotFound = 'Employee not found.',
    
    -- ===============================
    --    Promotion Messages
    -- ===============================
    NoPromotePermission = 'You do not have permission to promote employees.',
    CannotPromoteHigherRank = 'You cannot promote someone to a higher rank than yourself.',
    AlreadyHigherGrade = 'This employee is already at a higher grade.',
    InvalidGrade = 'Invalid grade.',
    PromotedSuccess = 'You have promoted %s to %s.',
    YouWerePromoted = 'You have been promoted to %s.',
    PromotedLog = 'Promoted %s to %s',
    PromoteFailed = 'Failed to promote employee.',
    
    -- ===============================
    --    Demotion Messages
    -- ===============================
    NoDemotePermission = 'You do not have permission to demote employees.',
    CannotDemoteHigherRank = 'You cannot demote someone with a higher rank than yourself.',
    AlreadyLowerGrade = 'This employee is already at a lower grade.',
    DemotedSuccess = 'You have demoted %s to %s.',
    YouWereDemoted = 'You have been demoted to %s.',
    DemotedLog = 'Demoted %s to %s',
    DemoteFailed = 'Failed to demote employee.',
    
    -- ===============================
    --    Money Transactions
    -- ===============================
    NoWithdrawPermission = 'You do not have permission to withdraw funds.',
    NoDepositPermission = 'You do not have permission to deposit funds.',
    InvalidAmount = 'Invalid amount.',
    MaxWithdrawal = 'Maximum withdrawal amount is $%s.',
    MaxDeposit = 'Maximum deposit amount is $%s.',
    NotEnoughMoney = 'There is not enough money in the account.',
    NotEnoughCash = 'You do not have enough cash.',
    WithdrewSuccess = 'You have withdrawn $%s from the company account.',
    DepositedSuccess = 'You have deposited $%s to the company account.',
    WithdrewLog = 'Withdrew $%s',
    DepositedLog = 'Deposited $%s',
    
    -- ===============================
    --    Other Messages
    -- ===============================
    InvalidJob = 'Invalid job configuration.',
    NoManagePermission = 'You do not have permission to manage grades.'
}