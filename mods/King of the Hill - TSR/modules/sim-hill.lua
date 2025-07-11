
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

function Tick(config, thresholds, brains) 
    local processed = ProcessHill(config, brains) 
    local analysed = AnalyseHill(config, processed, thresholds)
    return processed, analysed
end

--- Computes the amount of mass, number of units and whether there is a 
-- commander on the hill for each provided brain.
-- @param config The configuration of the mod.
-- @param brains The brains / players we're interested in.
function ProcessHill(config, brains)

    local center = config.hillCenter 
    local radius = config.hillRadius

    local analyses = { }
    for k, brain in brains do

        -- don't compute for defeated brains
        if not brain:IsDefeated() then

            -- find all the units
            local cats = categories.ALLUNITS - (categories.STRUCTURE + categories.ENGINEER) + categories.COMMAND;
            local unitsOnHill = brain:GetUnitsAroundPoint(cats, center, radius, 'Ally');

            -- keep track of the brain
            local analysis = { }
            analysis.name = brain.Name
            analysis.identifier = brain:GetArmyIndex();
            analysis.massOnHill = 0
            analysis.unitsOnHill = 0 
            analysis.commanderOnHill = false 

            -- determine what is on the hill.
            if unitsOnHill and table.getn(unitsOnHill) > 0 then

                -- sum up the number of units and their mass values.
                for k, unit in unitsOnHill do
                    if not unit:IsDead() then
                        analysis.unitsOnHill = analysis.unitsOnHill + 1;

                        -- do not count in the mass value of the commander
                        if EntityCategoryContains(categories.COMMAND, unit) then
                            analysis.commanderOnHill = true;
                        else
                            analysis.massOnHill = analysis.massOnHill + unit:GetBlueprint().Economy.BuildCostMass
                        end
                    end
                end
            end

            table.insert(analyses, analysis);
        end
    end

    return analyses;
end

--- Computes the amount of mass, number of units and whether there is a 
-- commander on the hill for each provided brain.
-- @param config The configuration of the mod.
-- @param brains The brains / players we're interested in.
function AnalyseHill(config, analyses, thresholds)

    -- we assume the hill is abandoned.
    local state = { }
    state.active = true
    state.controlled = false
    state.contested = false
    state.commanderOnHill = false
    state.identifier = 0
    state.conquerers = { }
    state.contestants = { }

    -- determine if there is a commander on the hill
    for k, analysis in analyses do 
        state.commanderOnHill = state.commanderOnHill or analysis.commanderOnHill;
    end

    -- determine which armies can control and / or contest the hill
    conquerers = { }
    contestants = { }
    for k, analysis in analyses do 
        canControl = analysis.massOnHill >= thresholds.control or analysis.commanderOnHill
        if canControl then 
            table.insert(conquerers, analysis)
            table.insert(state.conquerers, analysis.identifier )
        end

        canContest = analysis.massOnHill >= thresholds.contest or analysis.commanderOnHill
        if canContest then
            table.insert(contestants, analysis)
            table.insert(state.contestants, analysis.identifier )
        end
    end

    -- determine the amount of commanders on the hill
    local commanderCount = 0
    local commanderIndices = { }
    for k, player in conquerers do 
        if player.commanderOnHill then
            commanderCount = commanderCount + 1
            table.insert(commanderIndices, player.identifier)
        end
    end

    -- determine if the hill is contested through commanders
    local commanderContested = false 
    if commanderCount > 1 then 
        for k, cia in commanderIndices do 
            for l, cib in commanderIndices do 
                if not (k == l) then
                    commanderContested = commanderContested or IsEnemy(cia, cib)
                end
            end
        end
    end

    -- daym, so many hostile commanders on that hill
    if commanderContested then 
        state.controlled = false
        state.contested = true
        state.identifier = 0
        return state
    end

    -- if there is only one commander on the hill, things are clear
    local controller = nil
    if commanderCount == 1 then 
        -- only take conquerers with commanders
        for k, player in conquerers do 
            if player.commanderOnHill then 
                controller = player 
            end
        end
    end

    -- if multiple (allied) commanders are on hill, take all conquerers with commanders on hill into account
    local potentials = { }
    if commanderCount > 1 and not controller then
        for k, player in conquerers do 
            if player.commanderOnHill then 
                table.insert(potentials, player)
            end
        end
    end

    -- if no commanders are on hill, take all conquerers into account
    if commanderCount == 0 and not controller then 
        for k, player in conquerers do 
            table.insert(potentials, player)
        end
    end

    -- at this point we know that either all the potentials have commanders on hill,
    -- or none of them do. Either case: the mass counts
    if not controller then 
        for k, player in potentials do 

            -- if we don't have any controller yet, take the first one
            if controller == nil then 
                controller = player
            end
    
            -- compare their mass values
            if player.massOnHill > controller.massOnHill then 
                controller = player
            end
        end
    end

    -- did we find anybody?
    if controller then 

        -- we assume we can control it!
        local contested = false 

        -- check alliances with other conquerers
        for k, other in conquerers do 
            if not (controller.identifier == other.identifier) then 
                contested = contested or IsEnemy(controller.identifier, other.identifier)
            end
        end

        -- check alliances with other contestants
        for k, other in contestants do 
            if not (controller.identifier == other.identifier) then 
                contested = contested or IsEnemy(controller.identifier, other.identifier)
            end
        end

        -- nahh!
        if contested then 
            state.controlled = false
            state.contested = true 
            state.identifier = 0
            return state
        -- yeah!
        else
            state.controlled = true
            state.contested = false
            state.identifier = controller.identifier
            return state 
        end
    end

    -- return the default state, no conquerers nor contesters!
    state.controlled = false
    state.contested = false 
    state.identifier = 0
    return state

end