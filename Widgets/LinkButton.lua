local version, widget = 1, "LINKBUTTON"
local CUI = LibStub and LibStub("CloudUI-1.0")
if not CUI or CUI:GetWidgetVersion(widget) >= version then return end

-- Script handlers.

-- Called when the user clicks the given button.
local function Button_OnClick(self, button)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    local link = self:GetLink()
    if link and button == "LeftButton" and IsModifiedClick("CHATLINK") then
        ChatEdit_InsertLink(link)
    else
        local callbacks = self.callbacks
        if callbacks and #callbacks > 0 then
            for i = 1, #callbacks do
                callbacks[i](self, button)
            end
        end
    end
end

-- Called when the user's mouse enters the given frame.
local function Button_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local link = self:GetLink()
    if link then
        GameTooltip:SetHyperlink(link)
    end
    GameTooltip:Show()
end

-- Called when the user's mouse leaves the given frame.
local function Button_OnLeave(self)
    GameTooltip:Hide()
end

-- Template functions.

-- Set the given frame's callbacks.
local function SetCallbacks(self, callbacks)
    assert(callbacks and type(callbacks) == "table" and #callbacks > 0, "SetCallbacks: 'callbacks' needs to be a non-empty table")
    self.callbacks = callbacks
end

-- Register the given callback to the given frame.
local function RegisterCallback(self, callback)
    assert(callback and type(callback) == "table" and #callback > 0, "RegisterCallback: 'callback' needs to be a non-empty table")
    self.callbacks[#self.callbacks + 1] = callback
end

-- Unregisters the given callback from the given frame.
local function UnregisterCallback(self, callback)
    if self.callbacks and #self.callbacks > 0 then
        assert(callback and type(callback) == "function", "UnregisterCallback: 'callback' needs to be a function")
        for i = 1, #self.callbacks do
            if self.callbacks[i] == callback then
                table.remove(self.callbacks, i)
            end
        end
    end
end

-- Sets the link for the given frame.
local function SetLink(self, link)
    self.link = link
end

-- Gets the link for the given frame.
local function GetLink(self)
    return self.link
end

-- Sets the given frame's icon to the given texture.
local function SetIcon(self, texture)
    self.icon:SetTexture(texture)
    self.icon:Show()
end

-- Called by the game to update the tooltip whenever the given frame is being hovered.
local function UpdateTooltip(self)
    GameTooltip:SetHyperlink(self:GetLink())
end

function CUI:CreateLinkButton(parentFrame, frameName, callbacks, link)
    if callbacks then
        assert(type(callbacks) == "table" and #callbacks > 0, "CreateLinkButton: 'callbacks' needs to be a non-empty table")
    end
    local button = CreateFrame("Button", frameName, parentFrame or UIParent)
    button.callbacks = callbacks or {}
    if not CUI:ApplyTemplate(button, CUI.templates.BorderedFrameTemplate) then return false end
    if not CUI:ApplyTemplate(button, CUI.templates.HighlightFrameTemplate) then return false end
    if not CUI:ApplyTemplate(button, CUI.templates.PushableFrameTemplate) then return false end
    if not CUI:ApplyTemplate(button, CUI.templates.BackgroundFrameTemplate) then return false end
    button.icon = button:CreateTexture(frameName and frameName .. "CUILinkButtonIcon" or nil, "ARTWORK")
    button.icon:SetTexCoords(0.07, 0.93, 0.07, 0.93)
    button.icon:SetAllPoints(button)
    button:SetSize(34, 34) -- Default size.
    button.SetCallbacks = SetCallbacks
    button.RegisterCallback = RegisterCallback
    button.UnregisterCallback = UnregisterCallback
    button.SetLink = SetLink
    button.GetLink = GetLink
    button.SetIcon = SetIcon
    button.UpdateTooltip = UpdateTooltip
    if link then
        assert(type(link) == "string", "CreateLinkButton: 'link' needs to be a string")
        button:SetLink(link)
    end
    if not button:HookScript("OnClick", Button_OnClick) then return false end
    if not button:HookScript("OnEnter", Button_OnEnter) then return false end
    if not button:HookScript("OnLeave", Button_OnLeave) then return false end
    return button
end

CUI:RegisterWidgetVersion(widget, version)
