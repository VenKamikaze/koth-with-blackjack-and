
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

local utils = import('/mods/King of the Hill/modules/utils.lua');

-- config = {
--     debug=true,
--     hillActiveAt=360,
--     hillCenter={ 128, 17.5, 128 },
--     hillPoints=40,
--     hillRadius=25,
--     hillUnit=3,
--     kingOfTheHillHillCenter=1,
--     kingOfTheHillHillDelay=2,
--     kingOfTheHillHillPenalty=2,
--     kingOfTheHillHillScore=3,
--     kingOfTheHillHillSize=2,
--     kingOfTheHillHillTechIntroductionDelay=1,
--     kingOfTheHillHillType=1,
--     kingOfTheHillHillUnit=3,
--     kingOfTheHillTechCurve=1,
--     penaltyAlly=0.85000002384186,
--     penaltyController=0.69999998807907,
--     restrictedT2=true,
--     restrictedT3=true,
--     restrictedT4=true,
--     restrictionsT2LiftedAt=8,
--     restrictionsT3LiftedAt=16,
--     restrictionsT4LiftedAt=24,
--     scoreAccThreshold=20,
--     scoreSeqThreshold=5,
--     techCurveT2=0.20000000298023,
--     techCurveT3=0.40000000596046,
--     techCurveT4=0.60000002384186,
--     techIntroductionDelay=120,
--     ticks=30
-- }

-- playerTables = {
--     {
--         canContest=false,
--         canControl=false,
--         commanderOnHill=false,
--         identifier=1,
--         isDefeated=false,
--         isKing=false,
--         massOnHill=0,
--         nickname="Jip",
--         scoreAcc=0,
--         scoreSeq=0,
--         strArmy="ARMY_1"
--     }
-- }

-- processedHill = { 
--     { 
--         name = ARMY_1,
--         commanderOnHill=false, 
--         identifier=1, 
--         massOnHill=0, 
--         unitsOnHill=0 
--     } 
-- }

-- analysedHill = {
--     active=true,
--     commanderOnHill=false,
--     contested=false,
--     controlled=false,
--     identifier=0
-- }

--  thresholds = { 
--     contest=400, 
--     control=800 
-- }

local function IsAllyOfTable(i, t)
    for k, o in t do
        -- are we this?
        if o == i then 
            return true
        end

        -- are we allied to someone in this?
        if IsAlly(o, i) then 
            return true
        end
    end
end

function Tick(config, playerTable, processedHill, analysedHill, thresholds)

    local uiTable = { }

    -- set the data for the UI
    for k, player in playerTable do 

        local inf = { }

        -- find the corresponding information of the army
        local index = utils.FindByPredicate(processedHill, function(processedHill) return player.identifier == processedHill.identifier end)
        local hillInformation = processedHill[index]

        -- determine what to show in the UI
        local king = analysedHill.identifier
        inf.isKing = analysedHill.controlled and ((player.identifier == king) or IsAlly(player.identifier, king))
        inf.isContesting = analysedHill.contested and IsAllyOfTable(player.identifier, analysedHill.contestants)
        
        -- HACK FOR RESOURCES
        player.isKing = inf.isKing
        player.isContesting = inf.isContesting 

        inf.canControl = hillInformation.massOnHill > thresholds.control or hillInformation.commanderOnHill
        inf.canContest = hillInformation.massOnHill > thresholds.contest or hillInformation.commanderOnHill
        inf.massOnHill = hillInformation.massOnHill
        inf.commanderOnHill = hillInformation.commanderOnHill

        inf.strArmy = player.strArmy
        inf.scoreAcc = player.scoreAcc 
        inf.scoreSeq = player.scoreSeq 
        inf.identifier = player.identifier 

        table.insert(uiTable, inf)
    end     

    Sync.SendPlayerPointData = uiTable 
    Sync.SendThresholds = thresholds
end 