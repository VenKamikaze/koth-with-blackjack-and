
local path = 'King of the Hill'

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local GameMain = import('/lua/ui/game/gamemain.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local Prefs = import('/lua/user/prefs.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')

local parent = false;
interface = { };

function CreateModUI(isReplay, _parent)

	parent = _parent

	-- get all the non-civilian armies.
	local armies = FindApplicableArmies();

	BuildUI(armies)
	SetLayout(armies)
	CommonLogic(armies)

end

--------------------------------------------------
-- Retrieves all the armies that are controlled --
-- by a player. This is done in a similar       --
-- on the sim side.              				--

function FindApplicableArmies()

	-- an army needs to be human controlled in order
	-- to be applicable.
	local armies = GetArmiesTable().armiesTable;
	local applicableArmies = { };
	for k, army in armies do
		if army.human then
			table.insert(applicableArmies, army);
		end
	end

	return applicableArmies;

end

function BuildUI(armies)

	-- Create arrow checkbox
	interface.arrow = Checkbox(parent);

	-- Create group for main UI
	interface.box = Group(parent);
	
	-- create the panel.
	interface.box.panel = Bitmap(interface.box);

	interface.box.topPanel = Bitmap(interface.box);
	interface.box.middlePanel = Bitmap(interface.box);
	interface.box.bottomPanel = Bitmap(interface.box);

	-- Create the left bracket.
	interface.box.leftTopBracket = Bitmap(interface.box);
	interface.box.leftMiddleBracket = Bitmap(interface.box);
	interface.box.leftBottomBracket = Bitmap(interface.box);

	-- create the right 'bracket'.
	interface.box.rightGlowTop = Bitmap(interface.box);
	interface.box.rightGlowMiddle = Bitmap(interface.box);
	interface.box.rightGlowBottom = Bitmap(interface.box);
	
	interface.box.title = UIUtil.CreateText(interface.box, 'King of the hill', 16, UIUtil.bodyFont);
	interface.box.title:SetDropShadow(true);

	interface.box.textConquer = UIUtil.CreateText(interface.box, 'Conquer threshold: ... mass', 14, UIUtil.bodyFont);
	interface.box.textContest = UIUtil.CreateText(interface.box, 'Contest threshold: ... mass', 14, UIUtil.bodyFont);

	interface.box.divider = Bitmap(interface.box);

	interface.box.text1 = UIUtil.CreateText(interface.box, 'One point is given for every 25 ', 14, UIUtil.bodyFont);
	interface.box.text2 = UIUtil.CreateText(interface.box, 'consecutive seconds of hill control.', 14, UIUtil.bodyFont);
	interface.box.text3 = UIUtil.CreateText(interface.box, 'Commanders on the hill provide', 14, UIUtil.bodyFont);
	interface.box.text4 = UIUtil.CreateText(interface.box, 'double the amount of points.', 14, UIUtil.bodyFont);
	--------------------------------------------------
	-- Make the individual player UI items.			--

	interface.box.armyData = { }
	for k, army in armies do 
		local data = { }

		-- satalite data
		data.color = army.color;
		data.faction = army.faction;
		data.nickname = army.nickname;

		-- actual UI elements
		data.icon = Bitmap(interface.box);
		data.iconBackground = Bitmap(interface.box);
		data.nickname = UIUtil.CreateText(interface.box, army.nickname, 14, UIUtil.bodyFont)
		data.points = UIUtil.CreateText(interface.box, '.. / ..', 14, UIUtil.bodyFont)
		table.insert(interface.box.armyData, data);
	end
end

function SetLayout(armies)

	--------------------------------------------------
	-- Make the little arrow to show / hide the		--
	-- panel										--

	interface.arrow:SetTexture(UIUtil.UIFile('/game/tab-l-btn/tab-close_btn_up.dds'))
	interface.arrow:SetNewTextures(UIUtil.UIFile('/game/tab-l-btn/tab-close_btn_up.dds'),
		UIUtil.UIFile('/game/tab-l-btn/tab-open_btn_up.dds'),
		UIUtil.UIFile('/game/tab-l-btn/tab-close_btn_over.dds'),
		UIUtil.UIFile('/game/tab-l-btn/tab-open_btn_over.dds'),
		UIUtil.UIFile('/game/tab-l-btn/tab-close_btn_dis.dds'),
		UIUtil.UIFile('/game/tab-l-btn/tab-open_btn_dis.dds'))
		
	LayoutHelpers.AtLeftTopIn(interface.arrow, GetFrame(0), -3, 172)
	interface.arrow.Depth:Set(function() return interface.box.Depth() + 10 end)

	--------------------------------------------------
	-- Make the panel and set its height according	--
	-- to the number of players.					--

	--interface.box.panel:SetTexture(UIUtil.UIFile('/game/resource-panel/resources_panel_bmp.dds'))
	interface.box.panel.Height:Set(20 + 14 * table.getn(armies) + 11 * 14);
	interface.box.panel.Width:Set(262);
	LayoutHelpers.AtLeftTopIn(interface.box.panel, interface.box)

	interface.box.Height:Set(interface.box.panel.Height)
	interface.box.Width:Set(interface.box.panel.Width)
	LayoutHelpers.AtLeftTopIn(interface.box, parent, 16, 153)
	
	interface.box:DisableHitTest()

	--------------------------------------------------
	-- Construct the actual panel					--

	interface.box.topPanel:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_t.dds'));
	interface.box.middlePanel:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_m.dds'));
	interface.box.bottomPanel:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_b.dds'));

	interface.box.topPanel.Depth:Set(interface.box.Depth() - 2);
	interface.box.middlePanel.Depth:Set(interface.box.Depth() - 2);
	interface.box.bottomPanel.Depth:Set(interface.box.Depth() - 2);

	interface.box.topPanel.Top:Set(function () return interface.box.Top() + 8 end);
	interface.box.topPanel.Left:Set(function () return interface.box.Left() + 8 end);
	interface.box.topPanel.Right:Set(function () return interface.box.Right() end);

	interface.box.bottomPanel.Top:Set(function () return interface.box.Bottom() end);
	interface.box.bottomPanel.Left:Set(function () return interface.box.Left() + 8 end);
	interface.box.bottomPanel.Right:Set(function () return interface.box.Right() end);

	interface.box.middlePanel.Top:Set(function () return interface.box.topPanel.Bottom() end);
	interface.box.middlePanel.Bottom:Set(function() return math.max(interface.box.bottomPanel.Top(), interface.box.topPanel.Bottom()) end)
	interface.box.middlePanel.Left:Set(function () return interface.box.Left() + 8 end);
	interface.box.middlePanel.Right:Set(function () return interface.box.Right() end);

	--------------------------------------------------
	-- Construct the left bracket					--

	interface.box.leftTopBracket:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_t.dds'))
	interface.box.leftMiddleBracket:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_m.dds'))
	interface.box.leftBottomBracket:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_b.dds'))

	interface.box.leftTopBracket.Top:Set(function () return interface.box.Top() + 2 end)
	interface.box.leftTopBracket.Left:Set(function () return interface.box.Left() - 12 end)

	interface.box.leftBottomBracket.Bottom:Set(function () return interface.box.Bottom() + 22 end)
	interface.box.leftBottomBracket.Left:Set(function () return interface.box.Left() - 12 end)

	interface.box.leftMiddleBracket.Top:Set(function () return interface.box.leftTopBracket.Bottom() end)
	interface.box.leftMiddleBracket.Bottom:Set(function() return math.max(interface.box.leftTopBracket.Bottom(), interface.box.leftBottomBracket.Top()) end)
	interface.box.leftMiddleBracket.Right:Set(function () return interface.box.leftTopBracket.Right() - 9 end)

	--------------------------------------------------
	-- Construct the right bracket					--

	interface.box.rightGlowTop:SetTexture(UIUtil.UIFile('/game/bracket-right-energy/bracket_bmp_t.dds'))
	interface.box.rightGlowMiddle:SetTexture(UIUtil.UIFile('/game/bracket-right-energy/bracket_bmp_m.dds'))
	interface.box.rightGlowBottom:SetTexture(UIUtil.UIFile('/game/bracket-right-energy/bracket_bmp_b.dds'))

	interface.box.rightGlowTop.Top:Set(function () return interface.box.Top() + 5 end)
	interface.box.rightGlowTop.Left:Set(function () return interface.box.Right() - 10 end)

	interface.box.rightGlowBottom.Bottom:Set(function () return interface.box.Bottom() + 20 end)
	interface.box.rightGlowBottom.Left:Set(function () return interface.box.rightGlowTop.Left() end)

	interface.box.rightGlowMiddle.Top:Set(function () return interface.box.rightGlowTop.Bottom() end)
	interface.box.rightGlowMiddle.Bottom:Set(function () return math.max(interface.box.rightGlowTop.Bottom(), interface.box.rightGlowBottom.Top()) end)
	interface.box.rightGlowMiddle.Right:Set(function () return interface.box.rightGlowTop.Right() end)

	--------------------------------------------------
	-- Make the title, text and divider				--

	--interface.box.divider:SetTexture(UIUtil.UIFile('/game/bracket-right-energy/bracket_bmp_m.dds'));
	interface.box.divider:SetSolidColor('aaaaaaaa');
	LayoutHelpers.AtLeftTopIn(interface.box.divider, interface.box, 20, 11 + 20 + 14 * table.getn(armies) + 1 * 14);
	interface.box.divider.Width:Set(222);
	interface.box.divider.Height:Set(1);

	LayoutHelpers.AtLeftTopIn(interface.box.title, interface.box, 20, 11)
	interface.box.title:SetColor('ffffaa55')

	LayoutHelpers.AtLeftTopIn(interface.box.textConquer, interface.box, 20, 11 + 20 + 14 * table.getn(armies) + 2 * 14);
	interface.box.textConquer:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.textContest, interface.box, 20, 11 + 20 + 14 * table.getn(armies) + 3 * 14);
	interface.box.textContest:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.text1, interface.box, 20, 11 + 20 + 14 * table.getn(armies) + 5 * 14);
	interface.box.text1:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.text2, interface.box, 20, 11 + 20 + 14 * table.getn(armies) + 6 * 14);
	interface.box.text2:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.text3, interface.box, 20, 11 + 20 + 14 * table.getn(armies) + 8 * 14);
	interface.box.text3:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.text4, interface.box, 20, 11 + 20 + 14 * table.getn(armies) + 9 * 14);
	interface.box.text4:SetColor('ffcccccc')

	--------------------------------------------------
	-- Make the individual player UI items.			--

	for k, data in interface.box.armyData do 

		data.icon:SetTexture(UIUtil.UIFile(UIUtil.GetFactionIcon(data.faction)));
		data.icon.Width:Set(14);
		data.icon.Height:Set(14);
		LayoutHelpers.AtLeftTopIn(data.icon, interface.box, 20, 18 + k * 14)

		data.iconBackground:SetSolidColor(data.color);
		data.iconBackground.Width:Set(14);
		data.iconBackground.Height:Set(14);
		data.iconBackground.Depth:Set(data.icon.Depth() - 1);
		LayoutHelpers.AtLeftTopIn(data.iconBackground, interface.box, 20, 18 + k * 14)
		
		data.nickname:SetColor('ffffffff');
		LayoutHelpers.AtLeftTopIn(data.nickname, interface.box, 40, 18 + k * 14)

		data.points:SetColor('ffffffff');
		LayoutHelpers.AtRightTopIn(data.points, interface.box, 15, 18 + k * 14)
	end
end

function CommonLogic(armies)

	--  Button Actions
	interface.arrow.OnCheck = function(self, checked)
		TogglePanel()
	end
	
end


function TogglePanel(state)

	if import('/lua/ui/game/gamemain.lua').gameUIHidden and state != nil then
		return
	end

	if UIUtil.GetAnimationPrefs() then
		if state or interface.box:IsHidden() then
			PlaySound(Sound({Cue = "UI_Score_Window_Open", Bank = "Interface"}))
			interface.box:Show()
			ShowHideElements(true)
			interface.box:SetNeedsFrameUpdate(true)
			interface.box.OnFrame = function(self, delta)
				local newLeft = self.Left() + (1000*delta)
				if newLeft > parent.Left()+14 then
					newLeft = parent.Left()+14
					self:SetNeedsFrameUpdate(false)
				end
				self.Left:Set(newLeft)
			end
			interface.arrow:SetCheck(false, true)
		else
			PlaySound(Sound({Cue = "UI_Score_Window_Close", Bank = "Interface"}))
			interface.box:SetNeedsFrameUpdate(true)
			interface.box.OnFrame = function(self, delta)
				local newLeft = self.Left() - (1000*delta)
				if newLeft < parent.Left()-self.Width() then
					newLeft = parent.Left()-self.Width()
					self:SetNeedsFrameUpdate(false)
					self:Hide()
					ShowHideElements(false)
				end
				self.Left:Set(newLeft)
			end
			interface.arrow:SetCheck(true, true)
		end
	else
		if state or interface.box:IsHidden() then
			interface.box:Show()
			ShowHideElements(true)
			interface.arrow:SetCheck(false, true)
		else
			interface.box:Hide()
			ShowHideElements(false)
			interface.arrow:SetCheck(true, true)
		end
	end
end

function ShowHideElements(show)

	if show then
		for k, data in interface.box.armyData do 
			data.icon:Show();
			data.iconBackground:Show();
			data.nickname:Show();
			data.points:Show();
		end
	else

		for k, data in interface.box.armyData do 
			data.icon:Hide();
			data.iconBackground:Hide();
			data.nickname:Hide();
			data.points:Hide();
		end
	end
end