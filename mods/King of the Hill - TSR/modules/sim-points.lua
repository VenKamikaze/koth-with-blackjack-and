
import("/mods/king of the hill - tsr/modules/constants.lua")
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local simUtils = import("/mods/" .. kothConstants.path .. "/modules/sim-utils.lua")

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
--         name="ARMY_1",
--         nickname="Jip",
--         scoreAcc=0,
--         scoreSeq=0
--         }
--     },
-- }

-- analysedHill = {
--     active=true,
--     commanderOnHill=false,
--     contested=false,
--     controlled=false,
--     identifier=0
-- }

-- LOCAL STATE --

local function GetNicknameAsOwnershipNoun(playerNickname)
    local nick = playerNickname
    if (string.find(nick, "s", -1, true)) then
        nick = nick .. "'"
    else
        nick = nick .. "'s" 
    end
    return nick
end

-- called when we're ready to provide points
local function AddScore(playerTable, scoreAccThreshold)
    if playerTable.scoreAcc >= scoreAccThreshold then

        -- we started our final count down
        if playerTable.scoreSeq == 0 then 
            local nick = GetNicknameAsOwnershipNoun(playerTable.nickname)
            simUtils.SendAnnouncementWithVoice(
                nick .. " team have started their final countdown.",
                "A team started their final countdown",
                1,
                "KingOfTheHill",
                "Final" 
            );
        end 

        playerTable.scoreSeq = playerTable.scoreSeq + 1 
    else
        playerTable.scoreAcc = playerTable.scoreAcc + 1 
    end 
end

local function FindHighestScoreIndex(playerTables)
    local highest = 1
    local found = false
    for k, player in playerTables do 
        -- handles edge case with single human player
        if player.scoreAcc > 0 and not found then
            highest = k
            found = true
        end 
        if player.scoreAcc > playerTables[highest].scoreAcc then 
            highest = k 
        end
    end 

    return (found and highest or -1)
end 

-- called when hill control is switched to another team
local function RemoveSequentialScore(playerTables) 
    for k, playerTable in playerTables do  
        playerTable.scoreSeq = 0
    end 
end

-- information about the current controller
local controller = { }
controller.ticks = 0
controller.identifier = 0 

local tickCount = 30

function Tick(config, playerTables, analysedHill)

    -- is someone trying to control the hill?
    if analysedHill.controlled then 

        -- first capture, make sure it is never actually 0
        if controller.identifier == 0 then 
            controller.identifier = analysedHill.identifier
            LOG("We have our first hill controller! Identifier: " .. controller.identifier)
        end 

        -- did we switch king?
        if controller.identifier ~= analysedHill.identifier then 

            -- reset if the armies are not allied
            if not IsAlly(controller.identifier, analysedHill.identifier) then 
                -- remove the tick count
                controller.ticks = 0 

                -- remove potential sequential score
                RemoveSequentialScore(playerTables)
            end

            -- switch king
            controller.identifier = analysedHill.identifier
        end

        -- add a tick
        controller.ticks = controller.ticks + 1

        -- did we meet the tick theshold?
        if controller.ticks > tickCount then 
            -- for each undefeated army
            for k, playerTable in playerTables do 
                if not playerTable.isDefeated then
                    -- add points if king or allied to king
                    if analysedHill.identifier == playerTable.identifier or IsAlly(analysedHill.identifier, playerTable.identifier) then 

                        -- determine if we took the lead
                        local oldLeaderIdentifier = FindHighestScoreIndex(playerTables)
                        AddScore(playerTable, config.scoreAccThreshold)
                        local newLeaderIdentifier = FindHighestScoreIndex(playerTables)
                        -- LOG("oldLeader: " .. oldLeaderIdentifier .. " newLeader: " .. newLeaderIdentifier)

                        -- announce that there is a new leader (or first leader)
                        if oldLeaderIdentifier ~= newLeaderIdentifier then 
                            local nick = GetNicknameAsOwnershipNoun(playerTable.nickname)
                            LOG("Announcing new leader: " .. nick)
                            simUtils.SendAnnouncementWithVoice(
                                nick .. " team have taken the lead.",
                                "A team took the lead",
                                1,
                                "KingOfTheHill",
                                "Lead" 
                            );
                        end 


                    end
                end
            end

            -- reset the ticks
            controller.ticks = controller.ticks - tickCount
        end
    end 
end
