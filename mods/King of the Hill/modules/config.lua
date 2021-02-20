
local configs = import("/mods/King Of The Hill/modules/map-specifics.lua").configs
local options = import("/mods/King Of The Hill/mod_options.lua").options

function Initialise(ScenarioInfo)

    local config = { }

    local function FindDefaultOption (options, key)
        local default = 1
        for k, option in options do 
            if option.key == key then 
                default = option.default
            end
        end
    
        return default
    end

    local function DefaultValues (config)
        -- whether or not t2 / t3 / t4 is restricted
        config.restrictedT2 = true
        config.restrictedT3 = true 
        config.restrictedT4 = true 

        -- when the restrictions on t2 / t3 / t4 are lifted 
        config.restrictionsT2LiftedAt = 10
        config.restrictionsT3LiftedAt = 22
        config.restrictionsT4LiftedAt = 34

        -- tech curve on when the restrictions should be lifted
        config.techCurveT2 = 0.2
        config.techCurveT3 = 0.4
        config.techCurveT4 = 0.6

        -- how long it takes for other players to get the new tech
        config.techIntroductionDelay = 120

        -- the delay before the hill becomes active
        config.hillActiveAt = 300;

        -- the radius of the hill
        config.hillRadius = 40

        -- the points needed to win
        config.hillPoints = 50

        -- the amount of ticks required before a point is given
        config.ticks = 30

        config.penaltyController = 0.8 
        config.penaltyAlly = 0.9

        -- add unit in the center
        -- 1 = no unit
        -- 2 = radar
        -- 3 = generator1
        -- 4 = shield
        -- 5 = stealth
        config.hillUnit = 1

        -- add center position
        -- 1 = center of map
        -- 2 = center of all spawns
        -- 3 = center of all players
        config.hillCenter = { 0, 0, 0 }
    end

    local function DefaultRawValues(config)
        -- the raw options data
        config.kingOfTheHillTechCurve = FindDefaultOption(options, "KingOfTheHillTechCurve")
        config.kingOfTheHillHillType = FindDefaultOption(options, "KingOfTheHillHillType")
        config.kingOfTheHillHillSize = FindDefaultOption(options, "KingOfTheHillHillSize")
        config.kingOfTheHillHillDelay = FindDefaultOption(options, "KingOfTheHillHillDelay")
        config.kingOfTheHillHillCenter = FindDefaultOption(options, "KingOfTheHillHillCenter")
        config.kingOfTheHillHillScore = FindDefaultOption(options, "KingOfTheHillHillScore")
        config.kingOfTheHillHillUnit = FindDefaultOption(options, "KingOfTheHillHillUnit")
        config.kingOfTheHillHillPenalty = FindDefaultOption(options, "KingOfTheHillHillPenalty")
        config.kingOfTheHillHillTechIntroductionDelay = FindDefaultOption(options, "KingOfTheHillHillTechIntroductionDelay")
    end

    DefaultValues(config)
    DefaultRawValues(config)
    ---- LOG("King of the Hill: Config initialisation")

    -- load in the actual options, if they exist / are set
    if ScenarioInfo.Options then 
        config.kingOfTheHillTechCurve = ScenarioInfo.Options.KingOfTheHillTechCurve or config.kingOfTheHillTechCurve
        config.kingOfTheHillHillType = ScenarioInfo.Options.KingOfTheHillHillType or config.kingOfTheHillHillType
        config.kingOfTheHillHillSize = ScenarioInfo.Options.KingOfTheHillHillSize or config.kingOfTheHillHillSize
        config.kingOfTheHillHillDelay = ScenarioInfo.Options.KingOfTheHillHillDelay or config.kingOfTheHillHillDelay
        config.kingOfTheHillHillCenter = ScenarioInfo.Options.KingOfTheHillHillCenter or config.kingOfTheHillHillCenter
        config.kingOfTheHillHillScore = ScenarioInfo.Options.KingOfTheHillHillScore or config.kingOfTheHillHillScore
        config.kingOfTheHillHillUnit = ScenarioInfo.Options.KingOfTheHillHillUnit or config.kingOfTheHillHillUnit
        config.kingOfTheHillHillPenalty = ScenarioInfo.Options.KingOfTheHillHillPenalty or config.kingOfTheHillHillPenalty
        config.kingOfTheHillHillTechIntroductionDelay = ScenarioInfo.Options.KingOfTheHillHillTechIntroductionDelay or config.kingOfTheHillHillTechIntroductionDelay
    end

    function InterpretTechCurve(kingOfTheHillTechCurve)

        local values = {
            { 0.2, 0.4, 0.6 },
            { 0.3, 0.55, 0.8 }
        }

        return unpack (values[kingOfTheHillTechCurve])
    end

    function InterpretSize(kingOfTheHillHillSize)

        local radia = { }
        radia[256] = 25
        radia[512] = 35
        radia[1024] = 45
        radia[2048] = 70
        radia[4096] = 95

        local size = ScenarioInfo.size
        local smallest = math.min(size[1], size[2])
        local radius = radia[smallest] or 256

        if kingOfTheHillHillSize == 1 then 
            radius = 0.8 * radius 
        end

        if kingOfTheHillHillSize == 3 then 
            radius = 1.2 * radius
        end

        return radius 
    end

    function InterpretDelay(kingOfTheHillHillDelay)
        return 5 --120 + 120 * kingOfTheHillHillDelay 
    end

    function InterpretCenter(kingOfTheHillHillCenter)

        -- 1 = center of map
        -- 2 = center of all spawns
        -- 3 = center of all players

        local center = { 0, 0, 0 }
        if kingOfTheHillHillCenter == 1 then 
            center = ComputeMiddleOfTheMap()
        end

        if kingOfTheHillHillCenter == 2 then 
            center = ComputeMiddleOfSpawns()
        end

        if kingOfTheHillHillCenter == 3 then 
            center = ComputeMiddleOfPlayers()
        end

        -- LOG(repr(center))
        return center
    end

    function InterpretScore(kingOfTheHillHillScore)
        return 10 + 10 * kingOfTheHillHillScore
    end

    function InterpretUnit(kingOfTheHillHillUnit)
        return kingOfTheHillHillUnit
    end

    function InterpretPenalty(kingOfTheHillHillPenalty)
        local king = 1 - (0.1 + 0.1 * kingOfTheHillHillPenalty)
        local ally = 1 - (0.05 + 0.05 * kingOfTheHillHillPenalty)
        return king, ally
    end

    function InterpretTechDelay(kingOfTheHillHillDelay)
        return 60 + 60 * kingOfTheHillHillDelay 
    end

    -- interpret the options set manually
    config.hillActiveAt = InterpretDelay(config.kingOfTheHillHillDelay)
    config.hillCenter = InterpretCenter(config.kingOfTheHillHillCenter)
    config.hillRadius = InterpretSize(config.kingOfTheHillHillSize)
    config.techIntroductionDelay = InterpretTechDelay(config.kingOfTheHillHillTechIntroductionDelay)
    config.hillPoints = InterpretScore(config.kingOfTheHillHillScore)
    config.techCurveT2, config.techCurveT3, config.techCurveT4 = InterpretTechCurve(config.kingOfTheHillTechCurve)
    config.restrictionsT2LiftedAt = math.floor(config.techCurveT2 * config.hillPoints)
    config.restrictionsT3LiftedAt = math.floor(config.techCurveT3 * config.hillPoints)
    config.restrictionsT4LiftedAt = math.floor(config.techCurveT4 * config.hillPoints)

    config.hillUnit = InterpretUnit(config.kingOfTheHillHillUnit)
    config.penaltyController, config.penaltyAlly = InterpretPenalty(config.kingOfTheHillHillPenalty)

    config.scoreAccThreshold = 20
    config.scoreSeqThreshold = 8

    -- attempt to override with map specific settings
    if config.kingOfTheHillHillType == 1 then 

        local temp = nil

        -- check out local mod information for maps
        if configs[ScenarioInfo.name] then 
            temp = configs[ScenarioInfo.name]
        end

        -- check for a koth file with the map
        local optionsFileName = string.sub(ScenarioInfo.name, 1, string.len(ScenarioInfo.name) - string.len("scenario.lua")) .. "koth.lua"
        if DiskGetFileInfo(optionsFileName) then
            local optionsEnv = {}
            doscript(optionsFileName, optionsEnv)
            if optionsEnv.config ~= nil then
                temp = optionsEnv.config
            end
        end

        if temp then 
            -- LOG("King of the hill: loading map specific hill")
            -- load in the map specific settings, if applicable
            config.hillCenter = temp.center
            config.hillRadius = temp.radius
        end

        -- LOG(repr(config))
        return config
    end

    -- LOG(repr(config))
    return config
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

