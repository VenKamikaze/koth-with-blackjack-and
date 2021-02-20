
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

local simUtils = import("/mods/King of the Hill/modules/sim-utils.lua")

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

-- the various restrictions for the various techs
local restrictionsT2 = categories.TECH2
local restrictionsT3 = categories.TECH3
local restrictionsT4 = categories.EXPERIMENTAL

-- the various enhancements for the various techs
local enhancementsT2 = { 'ResourceAllocation', 'AdvancedEngineering', 'LeftPod', 'RightPod', 'Shield', 'TacticalMissile', 'NaniteTorpedoTube', 'StealthGenerator', 'DamageStabilization', 'Missile', 'RegenAura'}
local enhancementsT3 = { 'ResourceAllocationAdvanced', 'T3Engineering', 'ShieldGeneratorField', 'TacticalNukeMissile', 'MicrowaveLaserGenerator', 'ShieldHeavy' , 'ShieldGeneratorField', 'AdvancedRegenAura', 'DamageStabilizationAdvanced' }
local enhancementsT4 = { 'Teleporter', 'CloakingGenerator', 'ChronoDampener', 'TacticalNukeMissile', 'BlastAttack'}

function InitializeRestrictions(config, brains)

    indices = { }
    for k, brain in brains do 
        table.insert(indices, brain:GetArmyIndex())
    end

    if config.restrictedT4 then 
        AddRestrictionsT4(indices)
    end

    if config.restrictedT3 then 
        AddRestrictionsT3(indices)
    end

    if config.restrictedT2 then
        AddRestrictionsT2(indices)
    end
end

function Tick(config, playerTables)

    --- Finds all armies that are enemies
    -- @param identifier The army index of the army to find its enemies for
    -- @param armies All the applicable armies
    function FindAllies(identifier, armies)
        local indices = { }
        for k, information in armies do 
            if not (identifier == information.identifier) then 
                if IsAlly(identifier, information.identifier) then 
                    table.insert(indices, information.identifier)
                end
            end
        end

        return indices;
    end

    --- Finds all armies that are allied
    -- @param identifier The army index of the army to find its allies for
    -- @param armies All the applicable armies
    function FindEnemies(identifier, armies)
        local indices = { }
        for k, information in armies do 
            if not (identifier == information.identifier) then 
                if IsEnemy(identifier, information.identifier) then 
                    table.insert(indices, information.identifier)
                end
            end
        end

        return indices;
    end

    -- check for tech 2
    for k, information in playerTables do 
        if config.restrictedT2 then 
            if information.scoreAcc + information.scoreSeq >= config.restrictionsT2LiftedAt then 
                config.restrictedT2 = false

                local identifier = information.identifier
                local toRemoveDirectly = FindAllies(identifier, playerTables)
                local toRemoveDelayed = FindEnemies(identifier, playerTables)
                table.insert(toRemoveDirectly, identifier)

                RemoveRestrictionsT2(toRemoveDirectly)
                RemoveRestrictionsT2Delayed(toRemoveDelayed, config.techIntroductionDelay)

                simUtils.SendAnnouncementWithVoice(
                    "Tech 2 introduced for " .. information.nickname .. " and her / his allies.",
                    "Other players will have tech 2 in " .. config.techIntroductionDelay .. " seconds.",
                    0,
                    "KingOfTheHill",
                    "T2-King"
                )

                simUtils.SendAnnouncementWithVoice(
                    "King of the Hill",
                    "Tech 2 is available to all players.",
                    config.techIntroductionDelay,
                    "KingOfTheHill",
                    "T2-All"
                )
                
            end
        end
    end

    -- check for tech 3
    for k, information in playerTables do 
        if config.restrictedT3 then 
            if information.scoreAcc + information.scoreSeq >= config.restrictionsT3LiftedAt then 
                config.restrictedT3 = false

                local identifier = information.identifier
                local toRemoveDirectly = FindAllies(identifier, playerTables)
                local toRemoveDelayed = FindEnemies(identifier, playerTables)
                table.insert(toRemoveDirectly, identifier)

                RemoveRestrictionsT3(toRemoveDirectly)
                RemoveRestrictionsT3Delayed(toRemoveDelayed, config.techIntroductionDelay)

                simUtils.SendAnnouncementWithVoice(
                    "Tech 3 introduced for " .. information.nickname .. " and her / his allies.",
                    "Other players will have tech 3 in " .. config.techIntroductionDelay .. " seconds.",
                    0,
                    "KingOfTheHill",
                    "T3-King"
                )

                simUtils.SendAnnouncementWithVoice(
                    "King of the Hill",
                    "Tech 3 is available to all players.",
                    config.techIntroductionDelay,
                    "KingOfTheHill",
                    "T3-All"
                )
                
            end
        end
    end

    -- check for experimental tech
    for k, information in playerTables do 
        if config.restrictedT4 then 
            if information.scoreAcc + information.scoreSeq >= config.restrictionsT4LiftedAt then 
                config.restrictedT4 = false

                local identifier = information.identifier
                local toRemoveDirectly = FindAllies(identifier, playerTables)
                local toRemoveDelayed = FindEnemies(identifier, playerTables)
                table.insert(toRemoveDirectly, identifier)

                RemoveRestrictionsT4(toRemoveDirectly)
                RemoveRestrictionsT4Delayed(toRemoveDelayed, config.techIntroductionDelay)

                simUtils.SendAnnouncementWithVoice(
                    "Experimental tech introduced for " .. information.nickname .. " and its allies.",
                    "Other players will have the experimental tech in " .. config.techIntroductionDelay .. " seconds.",
                    0,
                    "KingOfTheHill",
                    "Exp-King"
                )

                simUtils.SendAnnouncementWithVoice(
                    "King of the Hill",
                    "Experimental tech is available to all players.",
                    config.techIntroductionDelay,
                    "KingOfTheHill",
                    "Exp-All"
                )
                
            end
        end
    end

end

--- Adds the restriction of tech 2 units and certain enhancements for the commander to all the brains.
-- @param brains The brains to add the restrictions to.
function AddRestrictionsT2(indices)
    for k, index in indices do 
        local restrictions = restrictionsT2 + restrictionsT3 + restrictionsT4
        ScenarioFramework.AddRestriction(index, restrictions)
        local enhancements = table.concatenate(enhancementsT2, enhancementsT3, enhancementsT4)
        ScenarioFramework.RestrictEnhancements(enhancements)
    end
end

--- Adds the restriction of tech 2 units and certain enhancements for the commander to all the brains after a given delay. 
-- @param brains The brains to add the restrictions to.
-- @param delay The time in seconds before the new restrictions are applied.
function AddRestrictionsT2Delayed(indices, delay)
    ForkThread(
        function()
            WaitSeconds(delay)
            AddRestrictionsT2(indices)
        end
    )
end

--- Adds the restriction of tech 3 units and certain enhancements for the commander to all the brains.
-- @param brains The brains to add the restrictions to.
function AddRestrictionsT3(indices)
    for k, index in indices do 
        local restrictions = restrictionsT3 + restrictionsT4
        ScenarioFramework.AddRestriction(index, restrictions)
        local enhancements = table.concatenate(enhancementsT3, enhancementsT4)
        ScenarioFramework.RestrictEnhancements(enhancements)
    end
end

--- Adds the restriction of tech 3 units and certain enhancements for the commander to all the brains after a given delay.
-- @param brains The brains to add the restrictions to.
-- @param delay The time in seconds before the new restrictions are applied.
function AddRestrictionsT3Delayed(indices, delay)
    ForkThread(
        function()
            WaitSeconds(delay)
            AddRestrictionsT3(indices)
        end
    )
end

--- Adds the restriction of tech 4 units and certain enhancements for the commander to all the brains.
-- @param brains The brains to add the restrictions to.
function AddRestrictionsT4(indices)
    for k, index in indices do 
        local restrictions = restrictionsT4
        ScenarioFramework.AddRestriction(index, restrictions)
        local enhancements = table.concatenate(enhancementsT4)
        ScenarioFramework.RestrictEnhancements(enhancements)
    end
end

--- Adds the restriction of tech 4 units and certain enhancements for the commander to all the brains after a given delay.
-- @param brains The brains to add the restrictions to.
-- @param delay The time in seconds before the new restrictions are applied.
function AddRestrictionsT4Delayed(indices, delay)
    ForkThread(
        function()
            WaitSeconds(delay)
            AddRestrictionsT4(indices)
        end
    )
end

--- Removes the restriction of tech 2 units and certain enhancements for the commander to all the brains.
-- @param brains The brains to add the restrictions to.
function RemoveRestrictionsT2(indices)
    for k, index in indices do 
        local restrictions = restrictionsT2
        ScenarioFramework.RemoveRestriction(index, restrictions)
        local enhancements = table.concatenate(enhancementsT3, enhancementsT4)
        ScenarioFramework.RestrictEnhancements(enhancements)
    end
end

--- Removes the restriction of tech 2 units and certain enhancements for the commander to all the brains after a given delay.
-- @param brains The brains to add the restrictions to.
-- @param delay The time in seconds before the new restrictions are applied.
function RemoveRestrictionsT2Delayed(indices, delay)
    ForkThread(
        function()
            WaitSeconds(delay)
            RemoveRestrictionsT2(indices)
        end
    )
end

--- Removes the restriction of tech 3 units and certain enhancements for the commander to all the brains.
-- @param brains The brains to add the restrictions to.
function RemoveRestrictionsT3(indices)
    for k, index in indices do 
        local restrictions = restrictionsT2 + restrictionsT3
        ScenarioFramework.RemoveRestriction(index, restrictions)
        local enhancements = table.concatenate(enhancementsT4)
        ScenarioFramework.RestrictEnhancements(enhancements)
    end
end

--- Removes the restriction of tech 3 units and certain enhancements for the commander to all the brains after a given delay.
-- @param brains The brains to add the restrictions to.
-- @param delay The time in seconds before the new restrictions are applied.
function RemoveRestrictionsT3Delayed(indices, delay)
    ForkThread(
        function()
            WaitSeconds(delay)
            RemoveRestrictionsT3(indices)
        end
    )
end

--- Removes the restriction of tech 4 units and certain enhancements for the commander to all the brains.
-- @param brains The brains to add the restrictions to.
function RemoveRestrictionsT4(indices)
    for k, index in indices do 
        local restrictions = restrictionsT2 + restrictionsT3 + restrictionsT4
        ScenarioFramework.RemoveRestriction(index, restrictions)
        local enhancements = table.concatenate()
        ScenarioFramework.RestrictEnhancements(enhancements)
    end
end

--- Removes the restriction of tech 4 units and certain enhancements for the commander to all the brains after a given delay.
-- @param brains The brains to add the restrictions to.
-- @param delay The time in seconds before the new restrictions are applied.
function RemoveRestrictionsT4Delayed(indices, delay)
    ForkThread(
        function()
            WaitSeconds(delay)
            RemoveRestrictionsT4(indices)
        end
    )
end