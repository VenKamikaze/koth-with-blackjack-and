
import("/mods/king of the hill - tsr/modules/constants.lua")
local path = kothConstants.path

local parentBeginSession = BeginSession
function BeginSession()

    -- dun break anything!
    parentBeginSession();

    -- run our own bit of sim!
    local sim = import('/mods/' .. path .. '/modules/sim-tick.lua');
    sim.KingOfTheHill();

end
