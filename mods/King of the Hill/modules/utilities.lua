
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua');
local ScenarioFramework = import('/lua/ScenarioFramework.lua');

--- Returns the index of the element in the table that matches the predicate or -1.
-- @param table The table to search through.
-- @param predicate The predicate that accepts one argument: an element from the table.
-- @return The index of the first element that matches the predicate or -1.
function FindByPredicate(table, predicate)
    if table then 
        for k, value in table do 
            if predicate(value) then 
                return k
            end
        end
    end

    return -1
end

--- Sends an announcement to all the players.
-- @param title The title of the announcement.
-- @param subtitle The subtitle of the announcement.
-- @param delay The amount of seconds to wait before the announcement should take place.
function SendAnnouncement(title, subtitle, delay)
    ScenarioFramework.CreateTimerTrigger(
        function() 
            -- LOG("Announcement at " .. GetGameTimeSeconds());
            -- LOG("Title: " .. title)
            -- LOG("Subtitle: " .. subtitle)
            Sync.SendAnnouncement = { title = title, subTitle = subtitle }; 
        end,
        delay,
        true
    );
end

--- Retrieves all the armies that are controlled by a player.
function FindPlayersSim()

    -- go over all the brains, check if they are an AI brain or not
    local state = { };
    local brains = { };
    local armies = ListArmies();
    for k, brain in ArmyBrains do
        if not (brain.BrainType == "AI") then
            -- retrieve all kinds of information
            local identifier = brain:GetArmyIndex();
            local name = armies[identifier]
            local information = {
                -- information for announcements
                nickname = brain.Nickname,

                -- information to match the army on the UI side
                name = name,

                -- information to match the brain on the sim side
                identifier = identifier,

                -- hill data
                isKing = false,
                commanderOnHill = false,
                isAllyOfKing = false,
                isDefeated = false,
                canContest = false,
                canControl = false,
                massOnHill = 0,
                score = 0,
            }
            
            -- store it nicely bundled
            table.insert(state, information);
            table.insert(brains, brain)
        end
    end

    return state, brains
end

--- Retrieves all the armies that are controlled by a player.
function FindPlayersUI()

	-- an army needs to be human controlled in order
	-- to be applicable.
	local armies = GetArmiesTable().armiesTable;
	local applicableArmies = { };
	for k, army in armies do
        if army.human then
            local information = {
                -- information to match the brain on the sim side
                name = army.name,
                color = army.color,
                nickname = army.nickname,
                faction = army.faction,
            }
			table.insert(applicableArmies, army);
		end
	end

	return applicableArmies;
end

--- Computes and updates the thresholds of conquering or contesting the hill every 60 seconds.
-- @param thresholds The table to constantly update over time.
function ComputeTresholdsThread(thresholds)

    while true do

        -- compute the new values
        thresholds.control = 800 + 80 * math.max(0, math.floor(GetGameTimeSeconds() / 60));
        thresholds.contest = thresholds.control / 2;

        -- update the interface.
        Sync.SendThresholds = thresholds;

        WaitSeconds(60.0);
    end

end

--- Computes the true center of the map, regardless of start locations.
function ComputeMiddleOfTheMap()
    local size = ScenarioInfo.size
    local center = { 0.5 * size[1], 0, 0.5 * size[2] } 
    center[2] = GetSurfaceHeight(center[1], center[3])
    return center
end

--- Computes the center of the start locations of all present players.
function ComputeMiddleOfPlayers()
    local total = { 0, 0 }

    -- go over all the applicable brains
    local state, brains = FindPlayersSim()
    for _, brain in brains do 
        -- keep track on their position to compute the average
        local x, z = brain:GetArmyStartPos()
        total[1] = total[1] + x
        total[2] = total[2] + z
    end

    -- compute the average
    local count = table.getn(brains)
    local center = { total[1] / count, 0, total[2] / count }
    center[2] = GetSurfaceHeight(center[1], center[3])
    
    return center
end

--- Computes the center based on the start locations of all players, even the ones that are not
-- in use.
function ComputeMiddleOfSpawns() 
    local total = { 0, 0 }
    local markersFound = 0

    -- go over all the army markers
    local k = 1
    local markerName = "ARMY_" .. k
    local marker = ScenarioUtils.GetMarker(markerName)
    while marker do
        -- keep track on how many we found
        markersFound = markersFound  + 1

        -- keep track on their position to compute the average
        local markerPosition = marker.position
        total[1] = total[1] + markerPosition[1]
        total[2] = total[2] + markerPosition[3]

        -- find the next marker, then go again
        k = k + 1
        markerName = "ARMY_" .. k
        marker = ScenarioUtils.GetMarker(markerName)
    end

    -- compute the average
    local center = { total[1] / markersFound, 0, total[2] / markersFound }
    center[2] = GetSurfaceHeight(center[1], center[3])

    return center
end

--- Computes the penalties players receive when they or their team controls the hill.
-- @param brains The applicable brains for the game mode
-- @param state The state of the hill, e.g., whether or not it is contested or controlled.
function ComputePenalty(config, brains, interpretation)

    -- sets the mass penalty on all mass producing units of the brain
    function SetPenalty(brain, value)
        local units = brain:GetListOfUnits(categories.MASSPRODUCTION, false)
        for k, unit in units do 
            local bp = unit:GetBlueprint()
            local production = bp.Economy.ProductionPerSecondMass
            unit:SetProductionPerSecondMass(value * production)
        end
    end

    -- reset all penalties
    for k, brain in brains do 
        SetPenalty(brain, 1.0)
    end

    -- if someone is controlling the hill: do the penalty!
    if interpretation.controlled then 
        -- change the production for every brain that is the king or allied to the king
        for k, brain in brains do 
            local identifier = brain:GetArmyIndex()

            -- are we the king?
            if identifier == interpretation.identifier then 
                SetPenalty(brain, config.penaltyController)
            else
                -- are we allied to the king?
                if IsAlly(identifier, interpretation.identifier) then
                    SetPenalty(brain, config.penaltyAlly)
                end
            end
        end
    end
end

--- Visualises the hill for all players using the debug drawing tools.
-- @param state The state of the hill, e.g., whether or not it is contested or controlled.
-- @param center The center of the hill.
-- @param radius The radius of the hill.
function VisualizeHillThread(state, center, radius)

    -- colors of the hill
    local circle = '55ffffff';
    local commander = '55f9e79f';
    local disabled = '55999999';

    -- colors of the state of the hill
    local idle = '55aaaaaa';
    local controlled = '5555ff55';
    local contested = '55ff5555';

    -- used to rotate the hill slowly
    local radianOffset = 0.0;

    while true do

        -- rotate the hill slowly
        radianOffset = radianOffset + 0.001;

        if state.active then

            -- determine the color of the inner circle.
            local hillColor = idle
            if state.controlled then
                hillColor = controlled
            end

            if state.contested then
                hillColor = contested
            end

            -- draw the regular circle and the inner circle.
            DrawCircle(center, radius - 0.25, 0 * radianOffset, circle, 30, 0);
            DrawCircle(center, radius - 1.25, -1 *radianOffset, hillColor, 60, 1);

            -- if there is a commander, draw another special circle
            if state.commanderOnHill then
                DrawCircle(center, radius - 2.25, 2 * radianOffset, commander, 120, 2);
            end

        -- the hill is not yet active!
        else
            DrawCircle(center, radius - 0.25, 0 * radianOffset, disabled, 30, 0);
        end

        WaitSeconds(0.10);
    end
end

--- Draws a circle using the debug drawing tools.
-- @param center The center of the circle.
-- @param radius The radius of the circle.
-- @param radianOffset An offset that can be defined to animate the circle.
-- @param color The color of the circle.
-- @param numberOfPieces The number of segments to construct the circle with.
-- @param pieceOffset The number of segments we skip to create partial circles.
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