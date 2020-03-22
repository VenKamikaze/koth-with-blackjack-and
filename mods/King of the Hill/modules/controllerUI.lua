
local path = "King of the hill";
local interface = import('/mods/' .. path .. '/modules/interface.lua').interface;
local announcement = import('/lua/ui/game/announcement.lua');

-- { 
--      totalScore = number,
--      armyScores = {
--          { armyIndex = number, armyScore = number, isDefeated = bool },
--          { armyIndex = number, armyScore = number, isDefeated = bool },
--          { armyIndex = number, armyScore = number, isDefeated = bool },
--          ...,
--     }
-- }
function ProcessPlayerPointData(data)
    for k, individualScore in data.armyScores do
        interface.box.armyData[k].points:SetText(string.format("%i / %i", individualScore.armyScore, data.totalScore));

        if individualScore.isDefeated then
            interface.box.armyData[k].nickname:SetColor('ff999999');
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
--     conquerThreshold = number,
--     contestThreshold = number
-- }
function ProcessThresholds(data)
    interface.box.textConquer:SetText(string.format("Conquer threshold: %i mass", data.conquerThreshold));
    interface.box.textContest:SetText(string.format("Contest threshold: %i mass", data.contestThreshold));
end