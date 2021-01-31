
local path = "King of the hill";
local interface = import('/mods/' .. path .. '/modules/interface.lua').interface;
local announcement = import('/lua/ui/game/announcement.lua');

local ModUtilities = import('/mods/King of the Hill/modules/utilities.lua');

function BoolToString(bool)
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
function ProcessPlayerPointData(data)

    -- -- LOG("King of the Hill: Received player point data")
    for k, information in data.armies do

        -- find the corresponding army related UI information
        local index = ModUtilities.FindByPredicate(interface.box.armies, function(army) return information.name == army.name end)
        local army = interface.box.armies[index]

        -- set the latest points
        army.points:SetText(string.format("%i / %i", information.score, data.scoreThreshold));

        -- set the latest king status
        army.isKing = information.isKing
        army.IsAllyOfKing = information.IsAllyOfKing
        army.iconKing:SetHidden(not information.isKing)
        army.iconAllyOfKing:SetHidden(not information.isAllyOfKing)

        -- set individual stats
        if information.identifier == GetFocusArmy() then 
            -- LOG("King of the Hill: Found focus army for player point data ")
            interface.box.textContesting:SetText(string.format("Can contest: %s", BoolToString(information.canContest)))
            interface.box.textControlling:SetText(string.format("Can control: %s", BoolToString(information.canControl)))
            interface.box.textMassOnHill:SetText(string.format("Mass on hill: %i", information.massOnHill))
            interface.box.textCommanderOnHill:SetText(string.format("Commander on hill: %s", BoolToString(information.commanderOnHill)))
            army.iconKing:SetHidden(not information.isKing and not information.isDefeated)
        end

        -- show defeated armies in grey
        if information.isDefeated then
            army.nickname:SetColor('ff999999');
        end
    end
end

-- {
--     title = string,
--     subTitle = string
-- }
function ProcessAnnouncement(data)
    announcement.CreateAnnouncement(data.title, interface.arrow, data.subTitle)
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