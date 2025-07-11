
local configLoaded = false
local baseOnSync = OnSync

function OnSync()

    local controllerUI = import('/mods/King of the Hill/modules/controllerUI.lua');

    -- don't break anything!
	baseOnSync()

    -- send the player point data.
    if Sync.SendPlayerPointData then
        ForkThread(controllerUI.ProcessPlayerPointData, Sync.SendPlayerPointData)
    end

    -- send an announcement
    if Sync.SendAnnouncement then
        ForkThread(controllerUI.ProcessAnnouncement, Sync.SendAnnouncement)
    end

    -- send an announcement
    if Sync.SendThresholds then
        ForkThread(controllerUI.ProcessThresholds, Sync.SendThresholds)
    end

    -- send in the config, should happen only once!
    if Sync.SendConfig then 
        if configLoaded then 
            WARN("King of the Hill: Configuration has already been loaded.")
            return
        end

        configLoaded = true
        ForkThread(controllerUI.ProcessConfig, Sync.SendConfig)
    end
end 