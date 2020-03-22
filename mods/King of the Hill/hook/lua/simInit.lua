

local path = 'King of the Hill'
local controllerSim = import('/mods/' .. path .. '/modules/controllerSim.lua');

local parentBeginSession = BeginSession
function BeginSession()

    -- dun break anything!
    parentBeginSession();

    -- run our own bit of the sim!
    controllerSim.OnStart();

end