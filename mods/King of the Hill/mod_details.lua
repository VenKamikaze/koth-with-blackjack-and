
local Mods = import('/lua/mods.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local Group = import('/lua/maui/group.lua').Group
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local MultiLineText = import('/lua/maui/multilinetext.lua').MultiLineText
local Popup = import('/lua/ui/controls/popups/popup.lua').Popup
local RadioButton = import('/lua/ui/controls/radiobutton.lua').RadioButton
local Prefs = import('/lua/user/prefs.lua')

-- this version of Checkbox allows scaling of checkboxes
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

function constructors()
    return {
        page1,
        page2,
        page3,
        page4,
        page5
    }
end

function page1(parent)

    local page = Group(parent)
    LayoutHelpers.FillParent(page, parent)

    -- title
    page.title = UIUtil.CreateText(page, 'hello information!', 20, UIUtil.titleFont)
    page.title:DisableHitTest()
    page.title:SetColor('B9BFB9')
    page.title:SetDropShadow(true)
    LayoutHelpers.AtVerticalCenterIn(page.title, page, 0)
    LayoutHelpers.AtLeftIn(page.title, page, 60, two) 

    return page
end

function page2(parent)
    local page = Group(parent)
    LayoutHelpers.FillParent(page, parent)

    -- title
    page.title = UIUtil.CreateText(page, 'hello information! 2', 20, UIUtil.titleFont)
    page.title:DisableHitTest()
    page.title:SetColor('B9BFB9')
    page.title:SetDropShadow(true)
    LayoutHelpers.AtVerticalCenterIn(page.title, page, 0)
    LayoutHelpers.AtLeftIn(page.title, page, 60) 

    return page 
end

function page3 (parent)
    local page = Group(parent)
    LayoutHelpers.FillParent(page, parent)

    -- title
    page.title = UIUtil.CreateText(page, 'hello information! 3', 20, UIUtil.titleFont)
    page.title:DisableHitTest()
    page.title:SetColor('B9BFB9')
    page.title:SetDropShadow(true)
    LayoutHelpers.AtVerticalCenterIn(page.title, page, 0)
    LayoutHelpers.AtLeftIn(page.title, page, 60) 

    return page 
end

function page4 (parent)
    local page = Group(parent)
    LayoutHelpers.FillParent(page, parent)

    -- title
    page.title = UIUtil.CreateText(page, 'hello information! 4', 20, UIUtil.titleFont)
    page.title:DisableHitTest()
    page.title:SetColor('B9BFB9')
    page.title:SetDropShadow(true)
    LayoutHelpers.AtVerticalCenterIn(page.title, page, 0)
    LayoutHelpers.AtLeftIn(page.title, page, 60) 

    return page 

end

function page5(parent)
    local page = Group(parent)
    LayoutHelpers.FillParent(page, parent)

    -- title
    page.title = UIUtil.CreateText(page, 'hello information! 5', 20, UIUtil.titleFont)
    page.title:DisableHitTest()
    page.title:SetColor('B9BFB9')
    page.title:SetDropShadow(true)
    LayoutHelpers.AtVerticalCenterIn(page.title, page, 0)
    LayoutHelpers.AtLeftIn(page.title, page, 60) 

    return page
end
