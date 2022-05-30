-- local _, ns = ...

-- -- todo:
-- -- 1. when changing slider size, change thumb size to match

-- local version, widget = 1, "SLIDER"
-- local CUI = LibStub and LibStub("CloudUI-1.0")
-- if not CUI or ns:GetWidgetVersion(widget) >= version then return end

-- -- Script handlers.

-- -- Called when the slider is disabled.
-- local function Slider_OnDisable(self)
    -- self:SetColorTexture(0.3, 0.3, 0.3, 1)
-- end


-- -- Template functions.

-- -- Sets the normal (enabled) color for the given frame to the given values.
-- local function SetNormalColor(self, r, g, b, a)
    -- self.normalR, self.normalG, self.normalB, self.normalA = r, g, b, a
    -- if not self:IsDisabled() then
        -- self:SetBackgroundColor(r, g, b, a)
    -- end
-- end

-- -- Resets the normal (enabled) color for the given frame.
-- local function ResetNormalColor(self)
    -- self:SetNormalColor(1, 1, 1, 1)
-- end

-- -- Sets the disabled color for the given frame to the given values.
-- local function SetDisableColor(self, r, g, b, a)
    -- self.disabledR, self.disabledG, self.disabledB, self.disabledA = r, g, b, a
    -- if self:IsDisabled() then
        -- self:SetBackgroundColor(r, g, b, a)
    -- end
-- end

-- -- Resets the disabled color for the given frame.
-- local function ResetDisableColor(self)
    -- self.disableR, self.disableG, self.disableB, self.disableA = 0.3, 0.3, 0.3, 1
-- end




-- function CUI:CreateSlider(parentFrame, frameName, isHorizontal)
    -- local slider = CreateFrame("Slider", frameName, parentFrame or UIParent)
    -- if not CUI:ApplyTemplate(slider, ns.templates.DisableableFrameTemplate) then return false end
    -- if not CUI:ApplyTemplate(slider, ns.templates.BackgroundFrameTemplate) then return false end
    -- if not CUI:ApplyTemplate(slider, ns.templates.BorderedFrameTemplate) then return false end
    -- if isHorizontal then
        -- slider:SetOrientation("HORIZONTAL")
        -- slider:SetSize(200, 16)
    -- else
        -- slider:SetOrientation("VERTICAL")
        -- slider:SetSize(16, 200)
    -- end
    -- slider:SetMinMaxValues(1, 10)
    -- slider:SetValueStep(1)
    -- slider:SetValue(1)
    -- local texture = slider:CreateTexture(nil, "BACKGROUND")
    -- texture:SetColorTexture(1, 1, 1, 1)
    -- texture:SetSize(14, 14)
    -- slider:SetThumbTexture(texture)
    -- slider.disableR = 0.3
    -- slider.disableG = 0.3
    -- slider.disableB = 0.3
    -- slider.disableA = 1
    -- slider.normalR = 1
    -- slider.normalG = 1
    -- slider.normalB = 1
    -- slider.normalA = 1
    -- slider.SetNormalColor = SetNormalColor
    -- slider.ResetNormalColor = ResetNormalColor
    -- slider.SetDisableColor = SetDisableColor
    -- slider.ResetDisableColor = ResetDisableColor
    -- local upButton = CUI:CreateButton(slider, frameName and frameName .. "CUIUpButton")
    -- -- upButton
    -- return slider
-- end

-- ns:RegisterWidgetVersion(widget, version)


-- -- temp, remove this
-- local slider = CUI:CreateSlider(UIParent, "awdawdadawdadawd")
-- slider:SetPoint("CENTER", -133, -200)

