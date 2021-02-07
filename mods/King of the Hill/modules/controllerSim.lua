
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

local ModUtilities = import('/mods/King of the Hill/modules/utilities.lua');
local ModRestrictions = import('/mods/King of the Hill/modules/restrictions.lua');

-- load in the configurations / options
local config = { }

-- the set of brains that are valid for the game mode
local brains = { }

-- the viewable related state of the hill, needs to be global to allow updating across threads
local view = {
    active = false;
    controlled = false,
    contested = false,
    commanderOnHill = false,
};

-- the state of the game mode, as partially defined by ModUtilities.FindPlayersSim(...)
local state = {
    scoreThreshold = 0,
    armies = { }
};

-- the state of the thresholds, which need to be global because it is shared in a separate thread
local thresholds = {
    control = 800,
    contest = 400,
}

function OnStart()

    -- load in the config
    config = import('/mods/King of the Hill/modules/config.lua').InitialiseConfig(ScenarioInfo)
    
    -- retrieve the default army and brain information
    state.scoreThreshold = config.hillPoints
    state.armies, brains = ModUtilities.FindPlayersSim()

    -- add vision over the hill
    for k, brain in brains do
        ScenarioFramework.CreateVisibleAreaLocation(config.hillRadius + 10, config.hillCenter, -1, brain)
    end

    -- start computing the thresholds
    ForkThread(
        function() 
            ModUtilities.ComputeTresholdsThread(thresholds);
        end
    )

    -- start visualising the hill
    ForkThread(
        function() 
            ModUtilities.VisualizeHillThread(view, config.hillCenter, config.hillRadius);
        end
    )

    -- sync the initial data, wait one tick for the UI to build
    ForkThread(
        function()
            WaitSeconds(0)
            Sync.SendConfig = config;
            Sync.SendPlayerPointData = state;
        end
    )

    -- get every army, add in the restrictions
    local identifiers = { }
    for k, information in state.armies do 
        table.insert(identifiers, information.identifier)
    end

    ModRestrictions.InitializeRestrictions(config, identifiers)

    -- prepare to send out the initialisation announcements
    ModUtilities.SendAnnouncement(
        "King of the hill",                                                 -- title
        "The hill is activated in " .. config.hillActiveAt .. " seconds.",  -- subtitle
        10                                                                  -- delay
    )

    ModUtilities.SendAnnouncement(
        "King of the hill",
        "The hill is activated in " .. math.floor(0.5 * config.hillActiveAt) .. " seconds.",
        math.floor(0.5 * config.hillActiveAt)
    )

    ModUtilities.SendAnnouncement(
        "King of the hill",                                                 -- title
        "The hill is activated in 60 seconds.",                             -- subtitle
        config.hillActiveAt - 60                                            -- delay
    )

    ModUtilities.SendAnnouncement(
        "King of the hill",                                                 -- title
        "The hill is active.",                                              -- subtitle
        config.hillActiveAt - 2                                             -- delay
    )

    -- prepare the tick of the game mode
    ForkThread(
        function()
            WaitSeconds(config.hillActiveAt)
            TickThread(view, state, brains, config.hillCenter)
        end
    )

end


--------------------------------------------------
-- The heart of the operation.                  --

function TickThread(view, state, brains, center)

    -- the amount of ticks the current identifier and its allies have
    local ticks = 0;

    -- the identifier of the brain (number)
    local identifier = 0;

    -- whether or not the hill is being controlled
    local controlled = false

    -- whether or not the hill was being contested before
    local wasContested = false 

    while true do

        -- keep track of the fallen brains.
        for k, data in state.armies do
           local brain = brains[data.identifier];
           if brain:IsDefeated() then
                data.isDefeated = true;
           end 
        end

        -- contains the raw information per brain (mass / units / commander on hill)
        local analysis = ProcessHill(brains, center, config.hillRadius)        

        -- computes the final state of the hill
        local interpretation = ProcessState(analysis)   

        -- update the viewable related interpretation
        view.active = interpretation.active 
        view.contested = interpretation.contested
        view.controlled = interpretation.controlled
        view.commanderOnHill = interpretation.commanderOnHill

        -- do penalties checks
        ModUtilities.ComputePenalty(config, brains, interpretation)

        -- hill is contested or left alone, reset everything
        if interpretation.contested or not interpretation.controlled then 
             ticks = 0
             identifier = 0
             controlled = false

             if interpretation.contested and not wasContested then 
                wasContested = true
                -- send out an announcement
                ModUtilities.SendAnnouncement(
                    "King of the hill",
                    "The hill is contested.",
                    0
                )
             end
        end

        -- if one team is on the hill, start working!
        if interpretation.controlled then 
            wasContested = false
            if not controlled then 
                -- the hill is unoccupied
                ticks = 0 
                identifier = interpretation.identifier
                controlled = true

                -- send out an announcement
                ModUtilities.SendAnnouncement(
                    "King of the hill",
                    "The hill is controlled by " .. ArmyBrains[identifier].Nickname .. " and her / his allies.",
                    0
                )
            else
                -- the hill is occupied, check the changes
                if interpretation.identifier == identifier then 
                    -- the same brain holds the hill
                    ticks = ticks + 1
                else  
                    if IsAlly(interpretation.identifier, identifier) then 
                        -- an ally took over!
                        ticks = ticks + 1
                        identifier = interpretation.identifier
                    else
                        -- an enemy took over!
                        ticks = 0
                        identifier = interpretation.identifier
                    end
                end
            end
        end

        -- set the data for the UI
        for k, data in state.armies do 

            -- find the corresponding information of the army
            local index = ModUtilities.FindByPredicate(analysis, function(analysis) return data.identifier == analysis.identifier end)
            local hillInformation = analysis[index]

            -- go through the data, determine what to show in the UI
            data.isKing = controlled and (data.identifier == interpretation.identifier)
            data.isAllyOfKing = controlled and (not data.isKing) and IsAlly(data.identifier, interpretation.identifier)
            data.canControl = hillInformation.massOnHill > thresholds.control or hillInformation.commanderOnHill
            data.canContest = hillInformation.massOnHill > thresholds.contest or hillInformation.commanderOnHill
            data.massOnHill = hillInformation.massOnHill
            data.commanderOnHill = hillInformation.commanderOnHill
        end       

        -- do we give points?
        if controlled and ticks >= 30 then 

            -- determine the amount of points we're giving.
            local points = 1;
            if interpretation.commanderOnHill then
                points = 2;
            end

            -- throw points to the allies of the controller
            for k, data in state.armies do 
                if not data.isDefeated then
                    -- this is the controllee, give some points!
                    if identifier == data.identifier then 
                        data.score = data.score + points;
                    else
                        -- check if it is an ally to the controllee
                        if IsAlly(identifier, data.identifier) then 
                            data.score = data.score + points;
                        end
                    end
                end
            end

            -- reset the ticks
            ticks = ticks - 30;

        end

        -- sync with the UI.
        -- LOG("King of the Hill: Sending player point data")
        Sync.SendPlayerPointData = state;

        -- check whether we have a winner with us
        ForkThread(
            function() 
                -- add a little suspense
                WaitSeconds(5.0)
                CheckWinConditions(brains, state.armies, identifier)
            end
        )

        -- check whether we have a winner with us
        ForkThread(
            function() 
                -- add a little suspense
                WaitSeconds(5.0)
                ModRestrictions.CheckRestrictionConditions(config, state)
            end
        )

        WaitSeconds(1.0);
    end

end

--- Computes the amount of mass on the hill, the number of units on the hill and whether a commander is on the hill per brain.
-- @param center The center of the hill
function ProcessHill(brains, center)

    local analysis = { }
    for k, brain in brains do

        -- don't compute for defeated brains
        if not brain:IsDefeated() then

            -- find all the units
            local cats = categories.ALLUNITS - (categories.AIR + categories.STRUCTURE + categories.ENGINEER) + categories.COMMAND;
            local unitsOnHill = brain:GetUnitsAroundPoint(cats, center, config.hillRadius, 'Ally');

            -- keep track of the brain
            local information = { }
            information.identifier = brain:GetArmyIndex();

            -- determine what is on the hill.
            local massOnHill = 0;
            local unitCount = 0;
            local commanderPresent = false;
            if unitsOnHill and table.getn(unitsOnHill) > 0 then

                -- sum up the number of units and their mass values.
                for k, unit in unitsOnHill do
                    if not unit:IsDead() then
                        unitCount = unitCount + 1;

                        -- do not count in the mass value of the commander
                        if EntityCategoryContains(categories.COMMAND, unit) then
                            commanderPresent = true;
                        else
                            massOnHill = massOnHill + unit:GetBlueprint().Economy.BuildCostMass
                        end
                    end
                end
            end

            -- store it all
            information.commanderOnHill = commanderPresent;
            information.massOnHill = massOnHill;
            information.unitsOnHill = unitCount;

            table.insert(analysis, information);
        end
    end

    return analysis;
end

--- Given the information from ProcessHill(...), computes the king of the hill.
-- @param analysis The information from ProcessHill(...).
function ProcessState(analysis)

    -- we assume the hill is abandoned.
    local state = { }
    state.active = true
    state.controlled = false
    state.contested = false
    state.commanderOnHill = false

    state.identifier = 0

    -- determine if there is a commander on the hill
    for k, information in analysis do 
        state.commanderOnHill = state.commanderOnHill or information.commanderOnHill;
    end

    -- determine which armies can control and / or contest the hill
    conquerers = { }
    contesters = { }
    for k, information in analysis do 
        canControl = information.massOnHill >= thresholds.control or information.commanderOnHill
        if canControl then 
            table.insert(conquerers, information)
        end

        canContest = information.massOnHill >= thresholds.contest or information.commanderOnHill
        if canContest then
            table.insert(contesters, information)
        end
    end

    -- determine the amount of commanders on the hill
    local commanderCount = 0
    local commanderIndices = { }
    for k, information in conquerers do 
        if information.commanderOnHill then
            commanderCount = commanderCount + 1
            table.insert(commanderIndices, information.identifier)
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
        for k, information in conquerers do 
            if information.commanderOnHill then 
                controller = information 
            end
        end
    end

    -- if multiple (allied) commanders are on hill, take all conquerers with commanders on hill into account
    local potentials = { }
    if commanderCount > 1 and not controller then
        for k, information in conquerers do 
            if information.commanderOnHill then 
                table.insert(potentials, information)
            end
        end
    end

    -- if no commanders are on hill, take all conquerers into account
    if commanderCount == 0 and not controller then 
        for k, information in conquerers do 
            table.insert(potentials, information)
        end
    end

    -- at this point we know that either all the potentials have commanders on hill,
    -- or none of them do. Either case: the mass counts
    if not controller then 
        for k, information in potentials do 

            -- if we don't have any controller yet, take the first one
            if controller == nil then 
                controller = information
            end
    
            -- compare their mass values
            if information.massOnHill > controller.massOnHill then 
                controller = information
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

        -- check alliances with other contesters
        for k, other in contesters do 
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

--------------------------------------------------
-- Checks whether or not a player has victoir!  --

function CheckWinConditions(brains, armies, controller)

    -- somebody is on the hill
    if not (controller == 0) then
        
        -- for every bit of data on all the players
        for k, data in armies do 
            
            -- do this if we have the controller
            if data.identifier == controller then 
                
                -- their score is high enough
                if data.score >= config.hillPoints then 

                    -- loop over the other brains, make them win or lose with the controller
                    for l, brain in brains do 
                        local index = brain:GetArmyIndex()
                        if index == controller then
                            -- brain is of the controller
                            brain:OnVictory();
                        else
                            if IsAlly(index, controller) then 
                                -- brain is of ally of controller
                                brain:OnVictory()
                            else
                                -- all other brains are defeated
                                brain:OnDefeat()
                            end
                        end
                    end

                    -- wait a wee bit, then end the game.
                    ScenarioFramework.CreateTimerTrigger(
                        function() 
                            EndGame();
                        end,
                        5,
                        true
                    );
                end
            end
        end
    end
end

--------------------------------------------------
-- Destroys all the given units of the given    --
-- brain, excluding the commander.              --

function DestroyAllUnitsThread(brain)

    local units = brain:GetListOfUnits(categories.ALLUNITS - categories.COMMAND, false);

    for k, unit in units do

        if not unit:IsDead() then
            unit:Kill();
        end

        WaitSeconds(Random() * 0.25);
    end

end