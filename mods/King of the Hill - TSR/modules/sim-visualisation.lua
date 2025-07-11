
local radianOffset = 0.0;

-- colors of the hill
local circle = '55ffffff';
local commander = '55f9e79f';
local disabled = '55999999';

-- colors of the state of the hill
local idle = '55aaaaaa';
local controlled = '5555ff55';
local contested = '55ff5555';

--- Visualises the hill for all players using the debug drawing tools.
function Tick(config, analyses)
    -- rotate the hill slowly
    radianOffset = radianOffset + 0.001;

    local radius = config.hillRadius 
    local center = config.hillCenter

    if analyses.active then

        -- determine the color of the inner circle.
        local hillColor = idle
        if analyses.controlled then
            hillColor = controlled
        end

        if analyses.contested then
            hillColor = contested
        end

        -- draw the regular circle and the inner circle.
        DrawCircle(center, radius - 0.25, 0 * radianOffset, circle, 30, 0);
        DrawCircle(center, radius - 1.25, -1 *radianOffset, hillColor, 60, 1);

        -- if there is a commander, draw another special circle
        if analyses.commanderOnHill then
            DrawCircle(center, radius - 2.25, 2 * radianOffset, commander, 120, 2);
        end

    -- the hill is not yet active!
    else
        DrawCircle(center, radius - 0.25, 0 * radianOffset, disabled, 30, 0);
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