-- todo:
-- 1. when changing slider size, change thumb size to match

local version, widget = 1, "SLIDER"
local CUI = LibStub and LibStub("CloudUI-1.0")
if not CUI or CUI:GetWidgetVersion(widget) >= version then return end

-- Script handlers.

-- Called when the slider is disabled.
local function Slider_OnDisable(self)
    self:GetThumbTexture():SetColorTexture(self.disableR, self.disableG, self.disableB, self.disableA)
end

-- Called when the slider is enabled.
local function Slider_OnEnable(self)
    self:GetThumbTexture():SetColorTexture(self.normalR, self.normalG, self.normalB, self.normalA)
end

-- Called when the slider value is changed.
local function Slider_OnValueChanged(self, value)
    -- Disable/enable buttons.
    local _, maxValue = self:GetMinMaxValues()
    if value <= self:GetMinMaxValues() then
        self.upButton:Disable()
        self.downButton:Enable()
    elseif value >= maxValue then
        self.downButton:Disable()
        self.upButton:Enable()
    else
        self.upButton:Enable()
        self.downButton:Enable()
    end
end

-- Called when a button is disabled.
local function Button_OnDisable(self)
    local parent = self:GetParent()
    local r, g, b, a
    if parent then
        r, g, b, a = parent.disableR, parent.disableG, parent.disableB, parent.disableA
    else
        r, g, b, a = 0.3, 0.3, 0.3, 1
    end
    self.texture:SetVertexColor(r, g, b, a)
end

-- Called when a button is enabled.
local function Button_OnEnable(self)
    local parent = self:GetParent()
    local r, g, b, a
    if parent then
        r, g, b, a = parent.normalR, parent.normalG, parent.normalB, parent.normalA
    else
        r, g, b, a = 1, 1, 1, 1
    end
    self.texture:SetVertexColor(r, g, b, a)
end

-- Called when the up button is clicked.
local function UpButton_OnClick(self)
    local slider = self:GetParent()
    slider:SetValue(slider:GetValue() - slider:GetValueStep())
end

-- Called when the down button is clicked.
local function DownButton_OnClick(self)
    local slider = self:GetParent()
    slider:SetValue(slider:GetValue() + slider:GetValueStep())
end

-- Template functions.

-- Sets the normal (enabled) color for the given frame to the given values.
local function SetNormalColor(self, r, g, b, a)
    self.normalR, self.normalG, self.normalB, self.normalA = r, g, b, a
    if not self:IsDisabled() then
        self:GetThumbTexture():SetColorTexture(r, g, b, a)
    end
end

-- Resets the normal (enabled) color for the given frame.
local function ResetNormalColor(self)
    self:SetNormalColor(1, 1, 1, 1)
end

-- Sets the disabled color for the given frame to the given values.
local function SetDisableColor(self, r, g, b, a)
    self.disabledR, self.disabledG, self.disabledB, self.disabledA = r, g, b, a
    if self:IsDisabled() then
        self:GetThumbTexture():SetColorTexture(r, g, b, a)
    end
end

-- Resets the disabled color for the given frame.
local function ResetDisableColor(self)
    self.disableR, self.disableG, self.disableB, self.disableA = 0.3, 0.3, 0.3, 1
end

-- temp, add comment
function CUI:CreateSlider(parentFrame, frameName, minValue, maxValue, obeyStep, thumbTexture, upTexture, downTexture, isHorizontal)
    assert(thumbTexture and type(thumbTexture) == "string", "CreateSlide: 'thumbTexture' needs to be a string")
    assert(upTexture and type(upTexture) == "string", "CreateSlide: 'upTexture' needs to be a string")
    assert(downTexture and type(downTexture) == "string", "CreateSlide: 'downTexture' needs to be a string")
    -- Slider.
    local slider = CreateFrame("Slider", frameName, parentFrame or UIParent)
    if not CUI:ApplyTemplate(slider, CUI.templates.DisableableFrameTemplate) then return false end
    if not CUI:ApplyTemplate(slider, CUI.templates.BackgroundFrameTemplate) then return false end
    if not CUI:ApplyTemplate(slider, CUI.templates.BorderedFrameTemplate) then return false end
    if isHorizontal then
        slider:SetOrientation("HORIZONTAL")
        slider:SetSize(168, 16)
    else
        slider:SetOrientation("VERTICAL")
        slider:SetSize(16, 168)
    end
    if minValue then
        assert(type(minValue) == "number", "CreateSlider: 'minValue' needs to be a number")
    else
        minValue = 1 -- Default.
    end
    if maxValue then
        assert(type(maxValue) == "number" and maxValue >= minValue, "CreateSlider: 'maxValue' needs to be a number >= 'minValue'")
    else
        maxValue = 10 -- Default.
    end
    slider:SetObeyStepOnDrag(obeyStep)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValue(minValue)
    slider:SetValueStep(1)
    slider:SetThumbTexture(thumbTexture)
    slider:GetThumbTexture():SetSize(16, 16)
    slider.disableR = 0.3
    slider.disableG = 0.3
    slider.disableB = 0.3
    slider.disableA = 1
    slider.normalR = 1
    slider.normalG = 1
    slider.normalB = 1
    slider.normalA = 1
    slider.SetNormalColor = SetNormalColor
    slider.ResetNormalColor = ResetNormalColor
    slider.SetDisableColor = SetDisableColor
    slider.ResetDisableColor = ResetDisableColor
    if not slider:HookScript("OnDisable", Slider_OnDisable) then return end
    if not slider:HookScript("OnEnable", Slider_OnEnable) then return end
    if not slider:HookScript("OnValueChanged", Slider_OnValueChanged) then return end
    -- Up button.
    local upButton = CreateFrame("Button", frameName and frameName .. "CUIUpButton", slider)
    if not CUI:ApplyTemplate(upButton, CUI.templates.HighlightFrameTemplate) then return end
    if not CUI:ApplyTemplate(upButton, CUI.templates.BorderedFrameTemplate) then return end
    if not CUI:ApplyTemplate(upButton, CUI.templates.PushableFrameTemplate) then return end
    upButton:SetSize(16, 16)
    local texture = upButton:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture(upTexture)
    texture:SetAllPoints(upButton)
    upButton.texture = texture
    upButton:SetPoint("BOTTOM", slider, "TOP", 0, 2)
    if not upButton:HookScript("OnDisable", Button_OnDisable) then return end
    if not upButton:HookScript("OnEnable", Button_OnEnable) then return end
    if not upButton:HookScript("OnClick", UpButton_OnClick) then return end
    upButton:Disable()
    slider.upButton = upButton
    -- Down button.
    local downButton = CreateFrame("Button", frameName and frameName .. "CUIDownButton", slider)
    if not CUI:ApplyTemplate(downButton, CUI.templates.HighlightFrameTemplate) then return end
    if not CUI:ApplyTemplate(downButton, CUI.templates.BorderedFrameTemplate) then return end
    if not CUI:ApplyTemplate(downButton, CUI.templates.PushableFrameTemplate) then return end
    downButton:SetSize(16, 16)
    texture = downButton:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture(downTexture)
    texture:SetAllPoints(downButton)
    downButton.texture = texture
    downButton:SetPoint("TOP", slider, "BOTTOM", 0, -2)
    if not downButton:HookScript("OnDisable", Button_OnDisable) then return end
    if not downButton:HookScript("OnEnable", Button_OnEnable) then return end
    if not downButton:HookScript("OnClick", DownButton_OnClick) then return end
    slider.downButton = downButton
    return slider
end

CUI:RegisterWidgetVersion(widget, version)
