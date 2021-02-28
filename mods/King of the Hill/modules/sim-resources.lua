
local ScenarioFramework = import('/lua/ScenarioFramework.lua');
local bonusAsFractionOfAverageIncome = 0.5

-- playerTables = {
--     armies={
--         {
--         canContest=false,
--         canControl=false,
--         commanderOnHill=false,
--         identifier=1,
--         isAllyOfKing=false,
--         isDefeated=false,
--         isKing=false,
--         massOnHill=0,
--         strArmy="ARMY_1",
--         nickname="Jip",
--         scoreAcc=0,
--         scoreSeq=0
--         }
--     },
-- }

--- Counts the number of contesters that are alive
local function countContestants(playerTables)
    local contestants = 0
    for _, player in playerTables do
        if player.isContesting and (not player.isDefeated) then
            contestants = contestants + 1
        end
    end
    return contestants
end

--- Counts the number of kings that are alive
local function countKings(playerTables)
    local kings = 0
    for _, player in playerTables do
        if player.isKing and (not player.isDefeated) then
            kings = kings + 1
        end
    end
    return kings
end

--- Counts the total mass income over all players that are alive
local function countTotalMassIncome(playerTables)
    local total = 0
    for _, player in playerTables do
        if not player.isDefeated then
            total = total + GetArmyBrain(player.strArmy):GetEconomyIncome("MASS")
        end
    end
    return total
end

--- Counts the number of players that are alive
local function countAlivePlayers(playerTables)
    local playerCount = 0
    for _, player in playerTables do
        if not player.isDefeated then
            playerCount = playerCount + 1
        end
    end
    return playerCount
end

--- Computes the average mass income over all players that are alive
local function countAverageMassIncome(playerTables)
    return countTotalMassIncome(playerTables) / countAlivePlayers(playerTables)
end

--- Provides the bonus to each king that is alive
local function giveBonusToKings(playerTables, amountOfKings)
    local massBonus = countAverageMassIncome(playerTables) * bonusAsFractionOfAverageIncome / amountOfKings

    for _, player in playerTables do
        if player.isKing and (not player.isDefeated) then
            GetArmyBrain(player.strArmy):GiveResource('MASS', massBonus)
        end
    end
end

--- Provides a mass bonus to each contester that is alive
local function giveBonusToContestants(playerTables, amountOfContesters)
    local massBonus = countAverageMassIncome(playerTables) * bonusAsFractionOfAverageIncome / amountOfContesters

    for _, player in playerTables do
        if player.isContesting and (not player.isDefeated) then
            GetArmyBrain(player.strArmy):GiveResource('MASS', massBonus)
        end
    end
end

function Tick(playerTables)
    local amountOfKings = countKings(playerTables)
    local amountOfContesters = countContestants(playerTables)

    if amountOfKings > 0 then
        giveBonusToKings(playerTables, amountOfKings)
    elseif amountOfContesters > 0 then 
        giveBonusToContestants(playerTables, amountOfContesters)
    end
end