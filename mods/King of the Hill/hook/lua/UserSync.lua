

local path = 'King of the Hill'
local controllerUI = import('/mods/' .. path .. '/modules/controllerUI.lua');

local baseOnSync = OnSync

function OnSync()

    -- don't break anything!
	baseOnSync()

    -- send the player point data.
    if Sync.SendPlayerPointData then
        controllerUI.ProcessPlayerPointData(Sync.SendPlayerPointData);
    end

    -- send an announcement
    if Sync.SendAnnouncement then
        controllerUI.ProcessAnnouncement(Sync.SendAnnouncement);
    end

    -- send an announcement
    if Sync.SendThresholds then
        controllerUI.ProcessThresholds(Sync.SendThresholds);
    end
end 