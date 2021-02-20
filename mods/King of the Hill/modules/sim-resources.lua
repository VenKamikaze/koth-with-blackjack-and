
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

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
    
function Tick(playerTables)

    -- compute amount of contestants
    local contestants = 0
    for k, player in playerTables do 
        if player.isContesting then 
            contestants = contestants + 1
        end
    end

    -- compute amount of kings
    local kings = 0 
    for k, player in playerTables do 
        if player.isKing then 
            kings = kings + 1 
        end
    end

    -- determine total income
    local total = 0 
    for k, player in playerTables do 
        local brain = GetArmyBrain(player.strArmy)
        total = total + brain:GetEconomyIncome("MASS")
    end

    -- if there are any kings
    if kings > 0 then 
        for k, player in playerTables do 
            if player.isKing then 
                -- determine the amount
                local amount = (1.0 / kings) * 0.15 * total
    
                -- provide resources
                local brain = GetArmyBrain(player.strArmy)
                brain:GiveResource('MASS', amount)
            end
        end
    else 
        -- else, if there are any contestants
        if contestants > 0 then 
            for k, player in playerTables do 
                if player.isContesting then 
                    -- determine the amount
                    local amount = (1.0 / contestants) * 0.15 * total
    
                    -- provide resources
                    local brain = GetArmyBrain(player.strArmy)
                    brain:GiveResource('MASS', amount)
                end
            end
        end
    end
end