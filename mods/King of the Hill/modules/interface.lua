
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

local uiUtils = import('/mods/King of the Hill/modules/ui-utils.lua');

local Prefs = import('/lua/user/prefs.lua')
local pixelScaleFactor = Prefs.GetFromCurrentProfile('options').ui_scale or 1

local parent = false;
interface = { };

function CreateModUI(isReplay, _parent)

	parent = _parent

	-- get all the non-civilian armies.
	local armies = uiUtils.FindPlayersUI()

	BuildUI(armies)
	SetLayout(armies)
	CommonLogic(armies)

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

	interface.box.dividerTop = Bitmap(interface.box);
	interface.box.dividerBot = Bitmap(interface.box)
	interface.box.dividerExplain = Bitmap(interface.box)
	interface.box.dividerRestrictions = Bitmap(interface.box)

	interface.box.textContesting = UIUtil.CreateText(interface.box, 'Can contest: ...', 14, UIUtil.bodyFont)
	interface.box.textControlling = UIUtil.CreateText(interface.box, 'Can control: ...', 14, UIUtil.bodyFont)
	interface.box.textMassOnHill = UIUtil.CreateText(interface.box, 'Mass on hill: ...', 14, UIUtil.bodyFont)
	interface.box.textCommanderOnHill = UIUtil.CreateText(interface.box, 'Commander on hill: ...', 14, UIUtil.bodyFont)

	interface.box.text1 = UIUtil.CreateText(interface.box, 'One point is given for every ... ', 14, UIUtil.bodyFont);
	interface.box.text2 = UIUtil.CreateText(interface.box, 'consecutive seconds of hill control', 14, UIUtil.bodyFont);
	interface.box.text3 = UIUtil.CreateText(interface.box, 'The hill provides bonus resources', 14, UIUtil.bodyFont);
	interface.box.text4 = UIUtil.CreateText(interface.box, 'With a commander you get 50% more', 14, UIUtil.bodyFont);
	
	interface.box.restrictions1 = UIUtil.CreateText(interface.box, 'Tech restrictions are lifted over time', 14, UIUtil.bodyFont);
	interface.box.restrictions4 = UIUtil.CreateText(interface.box, 'Experimental tech: ... points', 14, UIUtil.bodyFont);
	interface.box.restrictions3 = UIUtil.CreateText(interface.box, 'Tech 3: ... points', 14, UIUtil.bodyFont);
	interface.box.restrictions2 = UIUtil.CreateText(interface.box, 'Tech 2: ... points', 14, UIUtil.bodyFont);

	--------------------------------------------------
	-- Make the individual player UI items.			--

	interface.box.armies = { }
	for k, army in armies do 
		local data = { }

		-- satalite data
		data.name = army.name;
		data.color = army.color;
		data.faction = army.faction;

		-- actual UI elements
		data.icon = Bitmap(interface.box);
		data.iconKing = Bitmap(interface.box);
		data.iconContesting = Bitmap(interface.box);
		data.iconBackground = Bitmap(interface.box);
		data.nickname = UIUtil.CreateText(interface.box, army.nickname, 14, UIUtil.bodyFont)
		data.pointsAcc = UIUtil.CreateText(interface.box, '.. / ..', 14, UIUtil.bodyFont)
		data.pointsSeq = UIUtil.CreateText(interface.box, '.. / ..', 14, UIUtil.bodyFont)
		table.insert(interface.box.armies, data);
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

	LayoutHelpers.SetHeight(interface.box.panel, 20 + 14 * table.getn(armies) + 20 * 14)
	LayoutHelpers.SetWidth(interface.box.panel, 312)
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
	interface.box.leftTopBracket.Left:Set(function () return interface.box.Left() - 12 * pixelScaleFactor end)

	interface.box.leftBottomBracket.Bottom:Set(function () return interface.box.Bottom() + 22 end)
	interface.box.leftBottomBracket.Left:Set(function () return interface.box.Left() - 12 * pixelScaleFactor end)

	interface.box.leftMiddleBracket.Top:Set(function () return interface.box.leftTopBracket.Bottom() end)
	interface.box.leftMiddleBracket.Bottom:Set(function() return math.max(interface.box.leftTopBracket.Bottom(), interface.box.leftBottomBracket.Top()) end)
	interface.box.leftMiddleBracket.Right:Set(function () return interface.box.leftTopBracket.Right() - 9 * pixelScaleFactor end)

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

	local offsetArmies = 14 * table.getn(armies)

	LayoutHelpers.AtLeftTopIn(interface.box.title, interface.box, 20, 11)
	interface.box.title:SetColor('ffffaa55')

	--interface.box.dividerTop:SetTexture(UIUtil.UIFile('/game/bracket-right-energy/bracket_bmp_m.dds'));
	interface.box.dividerTop:SetSolidColor('aaaaaaaa');
	LayoutHelpers.AtLeftTopIn(interface.box.dividerTop, interface.box, 20, 11 + 20 + offsetArmies + 1 * 14);
	interface.box.dividerTop.Width:Set(222);
	interface.box.dividerTop.Height:Set(1);

	-- personal information

	LayoutHelpers.AtLeftTopIn(interface.box.textControlling, interface.box, 20, 11 + 20 + offsetArmies + 1.5 * 14);
	interface.box.textControlling:SetColor('ffcccccc')
	LayoutHelpers.AtLeftTopIn(interface.box.textContesting, interface.box, 20, 11 + 20 + offsetArmies + 2.5 * 14);
	interface.box.textContesting:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.textMassOnHill, interface.box, 20, 11 + 20 + offsetArmies + 3.5 * 14);
	interface.box.textMassOnHill:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.textCommanderOnHill, interface.box, 20, 11 + 20 + offsetArmies + 4.5 * 14);
	interface.box.textCommanderOnHill:SetColor('ffcccccc')

	interface.box.dividerBot:SetSolidColor('aaaaaaaa');
	LayoutHelpers.AtLeftTopIn(interface.box.dividerBot, interface.box, 20, 11 + 20 + offsetArmies + 6 * 14);
	interface.box.dividerBot.Width:Set(222);
	interface.box.dividerBot.Height:Set(1);

	-- control / contest thresholds
	LayoutHelpers.AtLeftTopIn(interface.box.textConquer, interface.box, 20, 11 + 20 + offsetArmies + 6.5 * 14);
	interface.box.textConquer:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.textContest, interface.box, 20, 11 + 20 + offsetArmies + 7.5 * 14);
	interface.box.textContest:SetColor('ffcccccc')

	interface.box.dividerExplain:SetSolidColor('aaaaaaaa');
	LayoutHelpers.AtLeftTopIn(interface.box.dividerExplain, interface.box, 20, 11 + 20 + offsetArmies + 9 * 14);
	interface.box.dividerExplain.Width:Set(222);
	interface.box.dividerExplain.Height:Set(1);

	-- Point information
	LayoutHelpers.AtLeftTopIn(interface.box.text1, interface.box, 20, 11 + 20 + offsetArmies + 9.5 * 14);
	interface.box.text1:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.text2, interface.box, 20, 11 + 20 + offsetArmies + 10.5 * 14);
	interface.box.text2:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.text3, interface.box, 20, 11 + 20 + offsetArmies + 12.5 * 14);
	interface.box.text3:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.text4, interface.box, 20, 11 + 20 + offsetArmies + 13.5 * 14);
	interface.box.text4:SetColor('ffcccccc')

	-- Restriction information
	interface.box.dividerRestrictions:SetSolidColor('aaaaaaaa');
	LayoutHelpers.AtLeftTopIn(interface.box.dividerRestrictions, interface.box, 20, 11 + 20 + offsetArmies + 15 * 14);
	interface.box.dividerRestrictions.Width:Set(222);
	interface.box.dividerRestrictions.Height:Set(1);

	LayoutHelpers.AtLeftTopIn(interface.box.restrictions1, interface.box, 20, 11 + 20 + offsetArmies + 15.5 * 14);
	interface.box.restrictions1:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.restrictions2, interface.box, 20, 11 + 20 + offsetArmies + 16.5 * 14);
	interface.box.restrictions2:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.restrictions3, interface.box, 20, 11 + 20 + offsetArmies + 17.5 * 14);
	interface.box.restrictions3:SetColor('ffcccccc')

	LayoutHelpers.AtLeftTopIn(interface.box.restrictions4, interface.box, 20, 11 + 20 + offsetArmies + 18.5 * 14);
	interface.box.restrictions4:SetColor('ffcccccc')





	--------------------------------------------------
	-- Make the individual player UI items.			--

	for k, data in interface.box.armies do 

		data.isKing = false

		data.iconKing:SetTexture("/mods/King of the Hill/icons/king.png")
		data.iconKing.Width:Set(14)
		data.iconKing.Height:Set(14)
		LayoutHelpers.AtLeftTopIn(data.iconKing, interface.box, 20, 23 + k * 14)
		data.iconKing:Hide()

		data.iconContesting:SetTexture("/mods/King of the Hill/icons/swords.png")
		data.iconContesting.Width:Set(14)
		data.iconContesting.Height:Set(14)
		LayoutHelpers.AtLeftTopIn(data.iconContesting, interface.box, 20, 23 + k * 14)
		data.iconContesting:Hide()

		data.icon:SetTexture(UIUtil.UIFile(UIUtil.GetFactionIcon(data.faction)));
		data.icon.Width:Set(14);
		data.icon.Height:Set(14);
		LayoutHelpers.AtLeftTopIn(data.icon, interface.box, 40, 23 + k * 14)

		data.iconBackground:SetSolidColor(data.color);
		data.iconBackground.Width:Set(14);
		data.iconBackground.Height:Set(14);
		data.iconBackground.Depth:Set(data.icon.Depth() - 1);
		LayoutHelpers.AtLeftTopIn(data.iconBackground, interface.box, 40, 23 + k * 14)
		
		data.nickname:SetColor('ffffffff');
		LayoutHelpers.AtLeftTopIn(data.nickname, interface.box, 60, 22 + k * 14)

		data.pointsAcc:SetColor('ffffffff');
		LayoutHelpers.AtRightTopIn(data.pointsAcc, interface.box, 55, 22 + k * 14)

		data.pointsSeq:SetColor('ffffffff');
		LayoutHelpers.AtRightTopIn(data.pointsSeq, interface.box, 15, 22 + k * 14)
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
		for k, data in interface.box.armies do 
			data.icon:Show();
			data.iconKing:SetHidden(not data.isKing)
			data.iconContesting:SetHidden(not data.iconContesting)
			data.iconBackground:Show();
			data.nickname:Show();
			data.pointsAcc:Show();
			data.pointsSeq:Show();
		end
	else
		for k, data in interface.box.armies do 
			data.icon:Hide();
			data.iconKing:Hide();
			data.iconContesting:Hide(not data.iconContesting)
			data.iconBackground:Hide();
			data.nickname:Hide();
			data.pointsAcc:Hide();
			data.pointsSeq:Show();
		end
	end
end