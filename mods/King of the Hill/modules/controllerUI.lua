
local path = "King of the hill";
local interface = import('/mods/' .. path .. '/modules/interface.lua').interface;
local announcement = import('/lua/ui/game/announcement.lua');

local uiUtils = import('/mods/King of the Hill/modules/ui-utils.lua');

local function DetermineColor(value, maximum)

    local color = "ffffff"
    local fraction = value / maximum

    if fraction > 0.25 then 
        color = "71D4FF"
    end 

    if fraction > 0.5 then 
        color = "F4FF71"
    end 

    if fraction > 0.75 then 
        color = "70FF86"
    end 

    return color 

end 

local function BoolToString(bool)
    if bool then
        return "Yes"
    end
    return "No"
end

-- { 
--      scoreThreshold = number,
--      armies = {
--          { 
--              identifier = number, 
--              score = number, 
--              isDefeated = bool, 
--              isKing = bool, 
--              isAllyOfKing = bool, 
--              canControl = bool, 
--              canContest = bool, 
--              massOnHill = number, 
--              commanderOnHill = bool  
--          },
--          ...,
--     },
-- }
function ProcessPlayerPointData(playerTables)
    -- -- LOG("King of the Hill: Received player point playerTables")
    for k, player in playerTables do

        -- find the corresponding army related UI player
        local index = uiUtils.FindByPredicate(interface.box.armies, 
            function(army) 
                return player.strArmy == army.name 
            end
        )
        local army = interface.box.armies[index]

        -- set the latest points
        army.pointsAcc:SetText(string.format("%i / %i", player.scoreAcc, interface.config.scoreAccThreshold));
        army.pointsAcc:SetNewColor(DetermineColor(player.scoreAcc, interface.config.scoreAccThreshold))

        army.pointsSeq:SetText(string.format("%i / %i", player.scoreSeq, interface.config.scoreSeqThreshold));
        army.pointsSeq:SetNewColor(DetermineColor(player.scoreSeq, interface.config.scoreSeqThreshold))

        -- set the latest king status
        army.isKing = player.isKing
        army.iconKing:SetHidden(not player.isKing)
        army.iconContesting:SetHidden(not player.isContesting)

        -- set individual stats
        if player.identifier == GetFocusArmy() then 
            -- LOG("King of the Hill: Found focus army for player point playerTables ")
            interface.box.textContesting:SetText(string.format("Can contest: %s", BoolToString(player.canContest)))
            interface.box.textControlling:SetText(string.format("Can control: %s", BoolToString(player.canControl)))
            interface.box.textMassOnHill:SetText(string.format("Mass on hill: %i", player.massOnHill))
            interface.box.textCommanderOnHill:SetText(string.format("Commander on hill: %s", BoolToString(player.commanderOnHill)))
            army.iconKing:SetHidden(not player.isKing and not player.isDefeated)
            army.iconContesting:SetHidden(not player.isContesting and not player.isDefeated)
        end

        -- show defeated armies in grey
        if player.isDefeated then
            army.nickname:SetColor('ff999999');
            army.points:SetColor('ff999999');
        end
    end
end

-- {
--     title = string,
--     subTitle = string
--     sound = {
--        cue = string,
--        bank = string,
--    }
-- }
function ProcessAnnouncement(data)

    -- create an actual announcement
    announcement.CreateAnnouncement(data.title, interface.arrow, data.subTitle)

    -- if there is sound, add it 
    if data.sound then 
        ForkThread(
            function()
                WaitSeconds(1.0)
                local sound = Sound({Cue = data.sound.cue, Bank = data.sound.bank})
                PlaySound(sound)
            end
        )
    end
end

-- {
--     control = number,
--     contest = number
-- }
function ProcessThresholds(data)
    interface.box.textConquer:SetText(string.format("Conquer threshold: %i mass", data.control));
    interface.box.textContest:SetText(string.format("Contest threshold: %i mass", data.contest));
end

-- {
--     hillActiveAt=300,
--     hillCenter={ 0, 0, 0 },
--     hillPoints=50,
--     hillRadius=40,
--     hillUnit=1,
--     kingOfTheHillHillCenter=1,
--     kingOfTheHillHillDelay=1,
--     kingOfTheHillHillPenalty=1,
--     kingOfTheHillHillScore=1,
--     kingOfTheHillHillSize=1,
--     kingOfTheHillHillTechIntroductionDelay=1,
--     kingOfTheHillHillType=1,
--     kingOfTheHillHillUnit=1,
--     restrictedT2=true,
--     restrictedT3=true,
--     restrictedT4=true,
--     restrictionsT2LiftedAt=10,
--     restrictionsT3LiftedAt=22,
--     restrictionsT4LiftedAt=34,
--     techIntroductionDelay=120,
--     ticks=30
-- }
function ProcessConfig(data)
    interface.config = data

    -- change the corresponding pieces of text
    interface.box.text1:SetText('One point is given for every ' .. data.ticks)
	
	interface.box.restrictions4:SetText('Experimental tech: after ' .. data.restrictionsT4LiftedAt .. ' points')
	interface.box.restrictions3:SetText('Tech 3: after ' .. data.restrictionsT3LiftedAt .. ' points')
	interface.box.restrictions2:SetText('Tech 2: after ' .. data.restrictionsT2LiftedAt .. ' points')
end