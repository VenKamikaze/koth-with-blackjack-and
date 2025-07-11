
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

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

function Tick(config, playerTables)

    -- check for each player the score
    for k, player in playerTables do 
        if player.scoreAcc >= config.scoreAccThreshold then 
            if player.scoreSeq >= config.scoreSeqThreshold then 

                -- call out the losers
                for k, other in playerTables do 
                    -- if this is not the king
                    if player.identifier ~= other.identifier then  
                        -- if this is an enemy of the king
                        if IsEnemy(player.identifier, other.identifier) then 
                            local brain = GetArmyBrain(other.strArmy)
                            brain.Defeated = true 
                            brain:OnDefeat()
                            WaitSeconds(1.0)
                        end 

                        -- if this is an ally that doesn't share our score
                        if IsAlly(player.identifier, other.identifier) then 
                            if player.scoreAcc ~= other.scoreAcc or player.scoreSeq ~= other.scoreSeq then 
                                local brain = GetArmyBrain(other.strArmy)
                                brain.Defeated = true 
                                brain:OnDefeat()
                                WaitSeconds(1.0)
                            end 
                        end 
                    end
                end

                -- call out the winners
                for k, other in playerTables do 
                    local brain = GetArmyBrain(other.strArmy)
                    if not brain.Defeated then 
                        brain:OnVictory()
                    end 
                end 

                -- wait a wee bit, then end the game.
                ScenarioFramework.CreateTimerTrigger(
                    function() 
                        isGameRunning = false 
                        EndGame()
                    end,
                    5,
                    true
                );

            end 
        end
    end
end