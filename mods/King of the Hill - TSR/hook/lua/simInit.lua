
local parentBeginSession = BeginSession
function BeginSession()

    -- dun break anything!
    parentBeginSession();

    -- run our own bit of sim!
    local sim = import('/mods/King of the Hill/modules/sim-tick.lua');
    sim.KingOfTheHill();

end