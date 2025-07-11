
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

local info = import("/mods/King of the Hill/mod_info.lua")

local simUtils = import("/mods/King of the Hill/modules/sim-utils.lua")
local simThresholds = import("/mods/King of the Hill/modules/sim-thresholds.lua")
local simResources = import("/mods/King of the Hill/modules/sim-resources.lua")
local simHill = import("/mods/King of the Hill/modules/sim-hill.lua")
local simPoints = import("/mods/King of the Hill/modules/sim-points.lua")
local simRestrictions = import("/mods/King of the Hill/modules/sim-restrictions.lua")
local simSync = import("/mods/King of the Hill/modules/sim-sync.lua")
local simVictory = import("/mods/King of the Hill/modules/sim-victory.lua")
local simVisualisation = import("/mods/King of the Hill/modules/sim-visualisation.lua")

function KingOfTheHill() 
    ForkThread(KingOfTheHillThread)
end

function KingOfTheHillThread() 

    LOG("Version: " .. repr(info.version))
    LOG("UID: " .. repr(info.uid))

    WaitSeconds(0.1)

    -- initialise state of mod
    local config        = import ("/mods/King of the Hill/modules/config.lua")
    config              = config.Initialise(ScenarioInfo)
    local brains        = InitialiseBrains()

    config.debug = true 

    if config.debug then 
        LOG(repr(config))
    end 

    -- start off with sane defaults
    local thresholds                  = InitialiseThresholds()
    local playerTable                 = InitialisePlayerTables(brains)
    local processedHill, analysedHill = simHill.Tick(config, thresholds, brains)

    -- routines called once

    simRestrictions.InitializeRestrictions(config, brains)

    -- initial UI sync, make sure to wait one tick so that the
    -- UI actually exists
    ForkThread(
        function()
            WaitSeconds(1)
            Sync.SendConfig = config
            WaitSeconds(1)
            Sync.SendPlayerPointData = playerTable
            WaitSeconds(1)
            Sync.SendThresholds = thresholds
        end
    )

    simUtils.SendAnnouncementWithVoice(
        "King of the hill",                                                 -- title
        "The hill is activated in " .. config.hillActiveAt .. " seconds.",  -- subtitle
        10,                                                                 -- delay
        "KingOfTheHill",                                                    -- bank
        "King"                                                              -- cue
    )

    simUtils.SendAnnouncement(
        "King of the hill",
        "The hill is activated in " .. math.floor(0.5 * config.hillActiveAt) .. " seconds.",
        math.floor(0.5 * config.hillActiveAt)
    )

    simUtils.SendAnnouncementWithVoice(
        "King of the hill",
        "The hill is active.",
        config.hillActiveAt - 2,
        "KingOfTheHill",
        "Hill-Active" 
    )

    -- give all armies vision over the center
    for k, brain in ArmyBrains do 
        ScenarioFramework.CreateVisibleAreaLocation(config.hillRadius * 1.1, config.hillCenter, 0, brain)
    end

    WaitSeconds(config.hillActiveAt)

    -- start the clock
    local count = 0
    while true do 

        WaitSeconds(0.1) 

        count = count + 1 
        if count > 10 then  

            -- routines called every 10th tick

            -- update information
            processedHill, analysedHill = simHill.Tick(config, thresholds, brains)
            thresholds = simThresholds.Tick()

            -- apply information    
            simPoints.Tick(config, playerTable, analysedHill)
            simRestrictions.Tick(config, playerTable)
            simVictory.Tick(config,playerTable)
            simSync.Tick(config, playerTable, processedHill, analysedHill, thresholds)

            -- keep track of the fallen brains
            for k, player in playerTable do
                local brain = brains[player.identifier];
                player.isDefeated = brain:IsDefeated()
            end

            count = count - 10 
        end 

        -- routines called every tick

        simResources.Tick(playerTable)
        simVisualisation.Tick(config, analysedHill)

    end
end 

--- Initialises the player tables.
--@param brains A list of valid brains that we want to create such a table for.
function InitialisePlayerTables(brains)   

    local function CreatePlayerTable(identifier, brain)
        return {
            -- information for announcements
            nickname = brain.Nickname,

            -- information to match the army on the UI side
            strArmy = brain.Name,

            -- information to match the brain on the sim side
            identifier = identifier,

            -- hill data
            isKing = false,
            commanderOnHill = false,
            isDefeated = false,
            canContest = false,
            canControl = false,
            massOnHill = 0,
            scoreAcc = 0,   
            scoreSeq = 0,
        }
    end 

    --  stores the initial player tables
    local playerTables = { }

    -- populate the player table
    for k, brain in brains do
        -- do not take into account ai
        if not (brain.BrainType == "AI") then
            table.insert(playerTables, CreatePlayerTable(k, brain))
        end 
    end 

    return playerTables
end 

--- Initialises a default hill table.
function InitialiseHillTable()
    local hillTable = { } 
    hillTable.active=false
    hillTable.commanderOnHill=false
    hillTable.contested=false
    hillTable.controlled=false
    hillTable.identifier=0
    return hillTable 
end

--- Filters all the brains available to ensure only brains 
-- controlled by humans remain.
function InitialiseBrains()
    local brains = { }
    for k, brain in ArmyBrains do 
        if brain.BrainType ~= "AI" then
            table.insert(brains, brain)
        end 
    end 
    return brains
end

function InitialiseThresholds()
    return {
        control = 800,
        contest = 400,
    }
end 