
import("/mods/king of the hill - tsr/modules/constants.lua")

local parentBeginSession = BeginSession
function BeginSession()

    -- dun break anything!
    parentBeginSession()

    -- run our own bit of sim!
    local sim = import('/mods/' .. kothConstants.path .. '/modules/sim-tick.lua')
    sim.KingOfTheHill()

end
