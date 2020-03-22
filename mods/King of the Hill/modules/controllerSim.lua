
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua');
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

local startupTime = 240;
local radius = 40;
local totalScoreRequiredToPwnAss = 36;

local scoreData = {
    totalScore = totalScoreRequiredToPwnAss,
    armyScores = { },
 };

local thresholds = {
    conquerThreshold = 800,
    contestThreshold = 400,
}

local hillState = {
    active = false;
    conquered = false,
    contested = false,
    commanderOnHill = false,
    brainThatConqueredHill = nil,
};

function OnStart()

    -- setup the initial score.
    local applicableBrains = FindApplicableBrains();
    for k, brain in applicableBrains do

        local data = { 
            isDefeated = false,
            armyIndex = brain:GetArmyIndex(), 
            armyScore = 0,
        };     

        table.insert(scoreData.armyScores, data);
    end

    local center = ComputeMiddleOfTheMap();

    -- early game message.
    ScenarioFramework.CreateTimerTrigger(
        function()
            ForkThread(ComputeTresholdsThread);            
            ForkThread(VisualizeHillThread, center);
            Sync.SendPlayerPointData = scoreData;

            Sync.SendAnnouncement = { title = "King of the hill", subTitle = "The hill will be active in " .. startupTime .. " seconds." };
        end,
        10,
        true
    );
    -- hill is about to begin message
    ScenarioFramework.CreateTimerTrigger(
        function()
            Sync.SendAnnouncement = { title = "King of the hill", subTitle = "The hill will be active in 60 seconds.." };
        end,
        startupTime - 60,
        true
    );

    -- whooo!! go get them!
    ScenarioFramework.CreateTimerTrigger(
        function()
            ForkThread(TickThread, center, radius);
            Sync.SendAnnouncement = { title = "King of the hill", subTitle = "The hill is active." };
        end,
        startupTime,
        true
    );

end

--------------------------------------------------
-- Retrieves all the armies that are controlled --
-- by a player. This is done in a similar       --
-- on the ui side.              				--

function FindApplicableBrains()

    local applicableBrains =  { };
    for k, brain in ArmyBrains do

        if not (brain.BrainType == "AI") then
            table.insert(applicableBrains, brain);
        end

    end

    return applicableBrains;
end

--------------------------------------------------
-- Slowly increases the conquer and contest     --
-- thresholds over time.                        --

function ComputeTresholdsThread()

    while true do

        -- compute the new values
        thresholds.conquerThreshold = 800 + 80 * math.floor(GetGameTimeSeconds() / 60);
        thresholds.contestThreshold = thresholds.conquerThreshold / 2;

        -- update the interface.
        Sync.SendThresholds = thresholds;

        WaitSeconds(60.0);
    end

end

--------------------------------------------------
-- The heart of the operation.                  --

function TickThread(center, radius)

    -- keep track of the state of affairs.
    local lastBrainOnHill = nil;
    local ticksOfBrainOfTheHill = 0;

    -- sync the initial data
    Sync.SendPlayerPointData = scoreData

    while true do

        -- keep track of the fallen brains.
        for k, scoreDatum in scoreData.armyScores do
           local brain = ArmyBrains[scoreDatum.armyIndex];
           if brain:IsDefeated() then
                scoreDatum.isDefeated = true;
           end 
        end

        -- do some analysis and process it according to the
        -- configurations provided by the options.
        local hillDataPerBrain = AnalyseHill(center, radius);
        hillState = ProcessAnalysisOfHill(hillDataPerBrain);

        -- if there is a brain that is on top of 
        -- the mountain
        if not hillState.contested and hillState.brainThatConqueredHill then

            -- if we already had someone on the hill.
            if lastBrainOnHill then
                -- and no coup happened
                if lastBrainOnHill.armyIndex == hillState.brainThatConqueredHill.armyIndex then
                    ticksOfBrainOfTheHill = ticksOfBrainOfTheHill + 1;
                -- or a coup did happen.
                else
                    ticksOfBrainOfTheHill = 0;
                end
            end

            -- we now have this brain on the hill!
            lastBrainOnHill = hillState.brainThatConqueredHill;
        
        else
            -- our hill is brainless!
            lastBrainOnHill = nil;
            ticksOfBrainOfTheHill = 0;
        end


        -- if this imperial and noble brain has been
        -- on the hill for a while, give it a point.
        if ticksOfBrainOfTheHill >= 25 then

            -- determine the amount of points we're giving.
            local numberOfPoints = 1;
            if lastBrainOnHill.commanderOnHill then
                numberOfPoints = 2;
            end

            -- throw them points!
            scoreData.armyScores[hillState.brainThatConqueredHill.armyIndex].armyScore = scoreData.armyScores[hillState.brainThatConqueredHill.armyIndex].armyScore + numberOfPoints;
            ticksOfBrainOfTheHill = 0;
        end

        -- check if someone has won, otherwise update the objectives.
        if CheckWinConditions(scoreData) then
            break;
        end

        -- sync with the UI.
        Sync.SendPlayerPointData = scoreData;

        WaitSeconds(1.0);
    end

end

--------------------------------------------------
-- Performs an analysis of the units on the     --
-- hill but it doesn't do anything with the     --  
-- computed data.                               --

function AnalyseHill(center, radius)

    local hillDataPerBrain = { }
    for k, brain in ArmyBrains do

        -- find all the units
        local cats = categories.ALLUNITS - (categories.AIR + categories.STRUCTURE + categories.ENGINEER) + categories.COMMAND;
        local unitsOnHill = brain:GetUnitsAroundPoint(cats, center, radius, 'Ally');

        -- determine what is on the hill.
        hillDataOfBrain = { }
        hillDataOfBrain.armyIndex = brain:GetArmyIndex();

        local amountOfMass = 0;
        local amountOfUnits = 0;
        local commanderPresent = false;
        if unitsOnHill and table.getn(unitsOnHill) > 0 then

            -- sum up the number of units and their mass values.
            for k, unit in unitsOnHill do
                if not unit:IsDead() then
                    amountOfUnits = amountOfUnits + 1;
                    amountOfMass = amountOfMass + unit:GetBlueprint().Economy.BuildCostMass

                    if EntityCategoryContains(categories.COMMAND, unit) then
                        commanderPresent = true;
                    end
                end
            end
        end

        -- keep track if there is a commander and of the 
        -- amount of mass and units.
        hillDataOfBrain.commanderOnHill = commanderPresent;
        hillDataOfBrain.massOnHill = amountOfMass;
        hillDataOfBrain.unitsOnHill = amountOfUnits;

        table.insert(hillDataPerBrain, hillDataOfBrain);
    end

    return hillDataPerBrain;
end

--------------------------------------------------
-- Visualizes the hill for the players.         --

function VisualizeHillThread(center)

    local hillColors = {
        '55ff5555',           -- (red)
        '5555ff55',           -- (green)
        '55aaaaaa',           -- (grey)
    }

    local radianOffset = 0.0;
    while true do

        radianOffset = radianOffset + 0.001;

        if hillState.active then

            -- determine the color of the inner circle.
            local hillColor = 3;
            if hillState.conquered then
                hillColor = 2;
            end

            if hillState.contested then
                hillColor = 1;
            end

            -- draw the regular circle and the inner circle.

            DrawCircle(center, radius - 0.25, 0 * radianOffset, '55ffffff', 30, 0);
            DrawCircle(center, radius - 1.25, -1 *radianOffset, hillColors[hillColor], 60, 1);

            if hillState.commanderOnHill then
                DrawCircle(center, radius - 2.25, 2 * radianOffset, '55f9e79f', 120, 2);
            end

        -- the hill is not yet active!
        else
            DrawCircle(center, radius - 0.25, 0 * radianOffset, '55999999', 30, 0);
        end

        WaitSeconds(0.10);
    end
end

function DrawCircle(center, radius, radianOffset, color, numberOfPieces, pieceOffset)

    -- computes a single point on the circle.
    function ComputePoint(center, radius, radians)
        return {
            center[1] + radius * math.cos(radians),
            center[2] + 0,
            center[3] + radius * math.sin(radians),
        };
    end

    -- computes all the points of the circle.
    local points = { }
    local twoPi = 3.14 * 2.0;
    for k = 1, numberOfPieces do
        local radians = (k - 1) / (numberOfPieces - 1) * twoPi;
        local point = ComputePoint(center, radius, radians + radianOffset);
        point[2] = GetSurfaceHeight(point[1], point[3]);
        table.insert(points, point);
    end

    -- draw out all the line segments
    for k = 1, numberOfPieces do

        local a = k;
        local b = k + 1;
        while b > numberOfPieces do
            b = b - numberOfPieces;
        end

        DrawLine(points[a], points[b], color);

        k = k + pieceOffset;
    end
end

--------------------------------------------------
-- Determines the final state of the hill. Take --
-- note that it returns all three variables:    --  
-- whether the hill is conquered, contested and --
-- if conquered by what player.                 --

function ProcessAnalysisOfHill(hillDataPerBrain)

    -- we assume the hill is abandoned.
    local hillState = { };
    hillState.active = true;
    hillState.conquered = false;
    hillState.contested = false;
    hillState.commanderOnHill = false;
    hillState.brainThatConqueredHill = nil;

    -- go through all the hill data we found. Determine
    -- if the hill is conquered / contested.
    for k, hillData in hillDataPerBrain do

        -- the hill is both conquered and
        -- contested. We do not need to
        -- look any further. Nothing more will
        -- happen.
        if hillState.contested then
            break;
        end

        if hillData.commanderOnHill then
            hillState.commanderOnHill = true;
        end
    
        -- I mean, of course we are contesting the
        -- hill if it is conquered. But we better 
        -- check to be sure.
        if hillState.conquered then

            if hillData.massOnHill >= thresholds.contestThreshold or hillData.commanderOnHill then
                hillState.contested = true;
                hillState.conquered = false;
                hillState.brainThatConqueredHill = nil;
            end

        -- determine if we are conquering the hill.
        else
            if hillData.massOnHill >= thresholds.conquerThreshold or hillData.commanderOnHill then
                hillState.brainThatConqueredHill = hillData;
                hillState.conquered = true;
            end
        end
    end

    -- if no brain conquered the hill, then this
    -- variable is nil. Otherwise, it contains a 
    -- brain table.
    return hillState;
end

--------------------------------------------------
-- Checks whether or not a player has victoir!  --

function CheckWinConditions(scoreData)

    winningArmies = { };
    for k, winningArmy in scoreData.armyScores do

        -- find all players that won!
        if winningArmy.armyScore >= totalScoreRequiredToPwnAss then
            table.insert(winningArmies, winningArmy);
        end
    end

    -- if we have winnnneerrrss!
    if table.getn(winningArmies) > 0 then

        -- go through all the armies.
        for k, losingArmy in scoreData.armyScores do

            -- find out of this army is a w-i-n-n-e-r!
            local isWinningArmy = false;
            for k, winningArmy in winningArmies do
                if winningArmy.armyIndex == losingArmy.armyIndex then
                    isWinningArmy = true;
                end
            end

            -- if the army is not a winner (boo!)
            if not isWinningArmy then
                local brain = ArmyBrains[losingArmy.armyIndex];
                brain:OnDefeat();
                ForkThread(DestroyAllUnitsThread, brain);
            end
        end

        Sync.SendAnnouncement = { title = "King of the hill", SubTitle = "Commander " .. winningArmies[1] .. " is the king of the hill!" };

        -- wait a wee bit, then end the game.
        ScenarioFramework.CreateTimerTrigger(
            function() 
                EndGame();
            end,
            5,
            true
        );

        return true

    end

    return false;
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

--------------------------------------------------
-- Find all spawn markers on the map and then   --
-- compute the average over them. The typical   --  
-- middle of a map is not always the middle.    --

function ComputeMiddleOfTheMap()

    local total = { 0, 0 };
    local markersFound = 0;

    local k = 1;
    local markerName = "ARMY_" .. k;
    local marker = ScenarioUtils.GetMarker(markerName);
    while marker do

        if marker then
            markersFound = markersFound  + 1;
            local markerPosition = marker.position;

            total[1] = total[1] + markerPosition[1];
            total[2] = total[2] + markerPosition[3];
        end

        k = k + 1;
        markerName = "ARMY_" .. k;
        marker = ScenarioUtils.GetMarker(markerName)
    end

    local center = { total[1] / markersFound, 0, total[2] / markersFound };
    center[2] = GetSurfaceHeight(center[1], center[3]);

    return center;
end