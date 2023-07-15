local version, widget = 1, "CONFIG"
local CUI = LibStub and LibStub("CloudUI-1.0")
if not CUI or CUI:GetWidgetVersion(widget) >= version then
    return
end

-- Variables.
local DEFAULT_WIDTH = 300
local DEFAULT_HEIGHT = 400
local MAX_WIDTH = 1200
local MAX_HEIGHT = 800
local WIDGET_MARGIN = 50
local WIDGET_Y_START = -20
local WIDGET_X_START = 10
local currIndex = 1

-- Called when any widget is hovered over.
local function Widget_OnEnter(self)
    self.OnEnter(self)
end

-- Called when mouse leaves a widget.
local function Widget_OnLeave(self)
    self.OnLeave(self)
end

-- Called when the size of the frame changes.
local function OnSizeChanged(self)
    -- nyi
end

-- Called when the mouse is down on the frame.
local function OnMouseDown(self)
    self:StartMoving()
end

-- Called when the mouse has been released from the frame.
local function OnMouseUp(self)
    self:StopMovingOrSizing()
end

-- Called when the main frame is shown.
local function OnShow(self)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
end

-- Called when the main frame is hidden.
local function OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end

-- Called when the close button is clicked.
local function CloseButton_OnClick(self)
    self:GetParent():Hide()
end

-- Called when the resize button is held.
local function ResizeButton_OnMouseDown(self)
    self:GetParent():StartSizing()
end

-- Called when the resize button is released.
local function ResizeButton_OnMouseUp(self)
    self:GetParent():StopMovingOrSizing()
end

-- Add the given widgets to the frame.
local function AddWidgets(widgets)
    assert(type(widgets) == "table" and #widgets > 0, "CreateLinkButton: 'widgets' needs to be a non-empty table")
    local fontInstance = CUI:GetFontNormal()
    while (currIndex <= #widgets) do
        local widget = widgets[currIndex]
        if not widget:HookScript("OnEnter", Widget_OnEnter) then
            return
        end
        if not widget:HookScript("OnLeave", Widget_OnLeave) then
            return
        end
        local desc = widget:CreateFontString(nil, "BACKGROUND", fontInstance:GetName())
        desc:SetText(widget.desc)
        desc:SetPoint("TOPLEFT", widget:GetParent(), "TOPLEFT", WIDGET_X_START, -WIDGET_MARGIN * currIndex - WIDGET_Y_START)
        widget.fontString = desc
        widget:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 2, -4)
        currIndex = currIndex + 1
    end
end

-- Creates a config frame that will automatically add the given widgets to it in the order given. Will automatically resize all widgets.
function CUI:CreateConfig(parentFrame, frameName, titleText, closeButtonTexture)
    -- The scroll frame.
    local config = CreateFrame("ScrollFrame", frameName, parentFrame or UIParent)
    config:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT)
    config:SetResizeBounds(DEFAULT_WIDTH, DEFAULT_HEIGHT, MAX_WIDTH, MAX_HEIGHT)
    config:SetMovable(true)
    config:SetResizable(true)
    config:SetClampedToScreen(true)
    config:SetFrameStrata("HIGH")
    CUI:ApplyTemplate(config, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(config, CUI.templates.BackgroundFrameTemplate)
    config:HookScript("OnSizeChanged", OnSizeChanged)
    config:HookScript("OnMouseDown", OnMouseDown)
    config:HookScript("OnMouseUp", OnMouseUp)
    config:HookScript("OnShow", OnShow)
    config:HookScript("OnHide", OnHide)
    tinsert(UISpecialFrames, config:GetName())
    config:SetPoint("CENTER")
    config:SetBackgroundColor(0, 0, 0, 0.5)
    config.AddWidgets = AddWidgets

    -- Title fontstring.
    local title = config:CreateFontString(nil, "BACKGROUND", CUI:GetFontBig():GetName())
    title:SetText(titleText)
    title:SetPoint("TOPLEFT", 4, -3)

    -- Separator.
    local separator = config:CreateTexture(nil, "OVERLAY")
    separator:SetHeight(1)
    separator:SetColorTexture(1, 1, 1, 1)
    separator:SetPoint("TOPLEFT", 0, -20)
    separator:SetPoint("TOPRIGHT", 0, -20)

    -- Close button.
    if closeButtonTexture then
        local closeButton = CreateFrame("Button", frameName and frameName .. "CloseButton", config)
        CUI:ApplyTemplate(closeButton, CUI.templates.HighlightFrameTemplate)
        CUI:ApplyTemplate(closeButton, CUI.templates.PushableFrameTemplate)
        CUI:ApplyTemplate(closeButton, CUI.templates.BorderedFrameTemplate)
        closeButton:SetSize(20, 20)
        local texture = closeButton:CreateTexture(nil, "ARTWORK")
        texture:SetTexture(closeButtonTexture)
        texture:SetAllPoints()
        closeButton.texture = texture
        closeButton:SetPoint("TOPRIGHT")
        closeButton:HookScript("OnClick", CloseButton_OnClick)
    end

    -- Resize button.
    local resizeButton = CreateFrame("Button", frameName and frameName .. "ResizeButton", config)
    resizeButton:SetFrameLevel(3)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
    resizeButton:HookScript("OnMouseDown", ResizeButton_OnMouseDown)
    resizeButton:HookScript("OnMouseUp", ResizeButton_OnMouseUp)

    -- Child frame.
    local childFrame = CreateFrame("Frame", frameName, config)
    childFrame:SetAllPoints(region)
    config:SetScrollChild(childFrame)

    return config
end
