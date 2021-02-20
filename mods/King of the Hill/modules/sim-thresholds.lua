
-- thresholds = {
--     control = number 
--     contest = number
-- }

function Tick ()

    local thresholds = { }

    -- compute the new values
    thresholds.control = 800 + 80 * math.max(0, math.floor(GetGameTimeSeconds() / 60));
    thresholds.contest = thresholds.control / 2;

    -- update the interface.
    return thresholds

end