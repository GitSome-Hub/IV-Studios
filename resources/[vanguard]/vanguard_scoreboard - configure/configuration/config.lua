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
----                         VANGUARD LABS | SCOREBOARD SYSTEM [ESX/QBCORE/QBOX/CUSTOM]
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
Config, Locales = {}, {}

-- ===============================
--    General Settings
-- ===============================
Config.Locale = 'en' -- en / pt / es / fr / de

Config.Framework = GetResourceState('qb-core') == 'started' and 'qb' or GetResourceState('es_extended') == 'started' and 'esx' or GetResourceState('qbx_core') == 'started' and 'qbox' or 'custom' -- qb, esx, qbox or custom

Config.ScoreboardType = 'card' -- fullscreen or card

Config.ScoreboardCommand = 'openscoreboard' -- Command to open the scoreboard menu

Config.RegisterKeyMapping = true -- If you want to register a key mapping for the scoreboard, set this to true

Config.OpenScoreboardKey = 'F10' -- Key to open the scoreboard menu

Config.MaxServerPlayers = 2025 -- Max server players if you sv_maxclients on `server.cfg` is not set

Config.RefreshInterval = 10000 -- Refresh interval in milliseconds (increased to reduce spam)

-- ===============================
--    Display Settings
-- ===============================
Config.ShowOfflinePlayers = false -- Show offline players in the scoreboard

Config.ShowPlayerIds = true -- Show player IDs in the scoreboard

Config.ShowPlayerPing = true -- Show player ping in the scoreboard

Config.ShowPlayerJob = true -- Show player job in the scoreboard

Config.ShowAdminBadge = true -- Show admin badge for admins

-- ===============================
--    Testing Configuration
-- ===============================
-- FAKE PLAYERS FOR TESTING (DEVELOPER ONLY)
Config.EnableFakePlayers = true -- Set to true to enable fake players for testing
Config.FakePlayersCount = 40 -- Number of fake players to generate (max 50)

-- ===============================
--    Scoreboard Customization
-- ===============================
-- Scoreboard Title and Subtitle (configurable)
Config.ScoreboardTitle = 'SCOREBOARD'
Config.ScoreboardSubtitle = 'Vanguard Labs'

-- ===============================
--    Services Configuration
-- ===============================
Config.Services = {
    {
        icon = 'fa-solid fa-heart-pulse',
        name = 'ambulance',
        label = 'Medics',
        color = '#FF1F8B',
        iconColor = '#fff',
    },
    {
        icon = 'fa-solid fa-shield-halved',
        name = 'police',
        label = 'LSPD',
        color = '#007CFF',
        iconColor = '#fff',
    },
    {
        icon = 'fa-solid fa-wrench',
        name = 'mechanic',
        label = 'Mechanic',
        color = '#ffffff',
        iconColor = '#101217',
    },
    {
        icon = 'fa-solid fa-taxi',
        name = 'taxi',
        label = 'Taxi',
        color = '#3FC157',
        iconColor = '#fff',
    },
}

-- ===============================
--    Admin Groups Configuration
-- ===============================
Config.Admins = {
    {
        group = 'admin',
        color = '#FF0000',
        icon = 'fa-solid fa-shield-halved',
        label = 'Admin',
        type = 'admin'
    },
    {
        group = 'god',
        color = '#0e65f0',
        icon = 'fa-solid fa-crown',
        label = 'Founder',
        type = 'founder'
    },
    {
        group = 'mod',
        color = '#ebd728',
        icon = 'fa-solid fa-user-secret',
        label = 'Mod',
        type = 'moderator'
    },
}

-- ===============================
--    Localization System
-- ===============================
-- Locales
Locales['en'] = {
    ['scoreboard_title'] = Config.ScoreboardTitle,
    ['players_online'] = 'Players Online',
    ['player_name'] = 'Player Name',
    ['job'] = 'Job',
    ['rank'] = 'Rank',
    ['ping'] = 'Ping',
    ['exit'] = 'Exit',
}

Locales['pt'] = {
    ['scoreboard_title'] = 'PLACAR',
    ['players_online'] = 'Jogadores Online',
    ['player_name'] = 'Nome do Jogador',
    ['job'] = 'Trabalho',
    ['rank'] = 'Cargo',
    ['ping'] = 'Ping',
    ['exit'] = 'Sair',
}

Locales['es'] = {
    ['scoreboard_title'] = 'MARCADOR',
    ['players_online'] = 'Jugadores En Línea',
    ['player_name'] = 'Nombre del Jugador',
    ['job'] = 'Trabajo',
    ['rank'] = 'Rango',
    ['ping'] = 'Ping',
    ['exit'] = 'Salir',
}

Locales['fr'] = {
    ['scoreboard_title'] = 'TABLEAU DE BORD',
    ['players_online'] = 'Joueurs En Ligne',
    ['player_name'] = 'Nom du Joueur',
    ['job'] = 'Métier',
    ['rank'] = 'Grade',
    ['ping'] = 'Ping',
    ['exit'] = 'Sortir',
}

Locales['de'] = {
    ['scoreboard_title'] = 'ANZEIGETAFEL',
    ['players_online'] = 'Spieler Online',
    ['player_name'] = 'Spielername',
    ['job'] = 'Beruf',
    ['rank'] = 'Rang',
    ['ping'] = 'Ping',
    ['exit'] = 'Beenden',
}

-- ===============================
--    Utility Functions
-- ===============================
-- Function to get localized text
function GetLocale(key)
    return Locales[Config.Locale] and Locales[Config.Locale][key] or key
end