local _, ns = ...

local CUI = ns.CUI

-- Variables.
local dropdownButtons = {}
local framePool = {}
local dropdown

-- Returns (or creates if there is none available) a dropdown button from the pool.
local function GetDropdownButton(parent)
    for i = 1, #framePool do
        if not framePool[i]:IsLocked() then
            framePool[i]:Lock()
            return framePool[i]
        end
    end
    -- No available button was found, so create a new one and add it to the pool.
    local button = CreateFrame("Button", "CUIDropdownButton" .. #framePool + 1, parent)
    CUI:ApplyTemplate(button, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(button, CUI.templates.BackgroundFrameTemplate)
    button:SetNormalFontObject(CUI:GetFontNormal())
    button:SetHeight(20)
    -- temp, todo: set text offset to be x = 2 (Button:GetFontString()?)
    button.value = ""
    button.SetValue = function(self, value, colorCode)
        if value then
            self:SetText(colorCode and "|c" .. colorCode .. value .. "|r" or value)
            self.value = value
            self.colorCode = colorCode
        end
    end
    button.GetValue = function(self)
        return self.value
    end
    button:HookScript("OnClick", function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        local dropdown = self:GetParent()
        dropdown:Hide()
        dropdown:GetParent():SetSelectedValue(self.value, self.colorCode)
    end)
    button.Lock = function(self)
        self.isUsed = true
    end
    button.IsLocked = function(self)
        return self.isUsed
    end
    button.Unlock = function(self)
        self.isUsed = false
    end
    button:Lock()
    framePool[#framePool + 1] = button
    return button
end

-- Adds or removes buttons as appropriate and sets the value for each button.
local function AdjustDropdownButtons(dropdownParent)
    local lastButtonIndex = #dropdownButtons -- The "index" of the last button. There will always be at least one button so we only need to attach buttons to the bottom button.
    local newValues, newColorCodes = dropdownParent:GetValues()
    local delta = #newValues - lastButtonIndex -- Add buttons if > 0, otherwise remove buttons.
    -- If delta is 0 we don't have to add or remove any buttons, only adjust values.
    if delta < 0 then
        for i = #newValues + 1, lastButtonIndex do
            dropdownButtons[i]:Hide()
            dropdownButtons[i]:Unlock()
            dropdownButtons[i] = nil
        end
    elseif delta > 0 then
        for i = lastButtonIndex + 1, #newValues do
            dropdownButtons[i] = GetDropdownButton(dropdown)
            -- Anchor it to the latest button.
            if i ~= 1 then -- First button should never be adjusted.
                dropdownButtons[i]:SetPoint("TOPLEFT", dropdownButtons[i - 1], "BOTTOMLEFT")
                dropdownButtons[i]:SetPoint("BOTTOMRIGHT", dropdownButtons[i - 1], "BOTTOMRIGHT", 0, -dropdownParent:GetHeight())
            end
            dropdownButtons[i]:Show()
        end
    end
    -- Adjust values.
    for i = 1, #newValues do
        dropdownButtons[i]:SetValue(newValues[i], newColorCodes and newColorCodes[i] or nil)
    end
end

-- Creates a dropdown with the given name in the given parent frame, containing the given values and returns it. The dropdown will call the given callback function with the selected value whenever the
-- player clicks one. An optional table containing color codes may be given, and an optional initial value will set the initial value of the dropdown, otherwise the default is the first value found.
function CUI:CreateDropdown(parentFrame, frameName, callbacks, values, colorCodes, initialValue, initialColor)
    -- Create the actual dropdown parent button (which opens/closes the dropdown itself).
    local dropdownParent = CreateFrame("Button", frameName, parentFrame)
    dropdownParent:RegisterForClicks("LeftButtonUp, RightButtonUp")
    CUI:ApplyTemplate(dropdownParent, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(dropdownParent, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(dropdownParent, CUI.templates.BackgroundFrameTemplate)
    dropdownParent:SetHeight(20)
    dropdownParent:SetNormalFontObject(CUI:GetFontNormal())
    -- temp, todo: set text offset to be x = 2 (Button:GetFontString()?)
    dropdownParent.callbacks = callbacks or {}
    dropdownParent.values = values or {}
    dropdownParent.colorCodes = colorCodes or {}
    dropdownParent.initialValue = initialValue or values[1]
    dropdownParent.initialColor = initialColor or colorCodes[1]
    dropdownParent.selectedValue = ""
    dropdownParent.RegisterCallback = function(self, callback)
        self.callbacks[#self.callbacks + 1] = callback
    end
    dropdownParent.SetValues = function(self, values, colorCodes)
        self.values = values
        self.colorCodes = colorCodes or self.colorCodes
    end
    dropdownParent.GetValues = function(self)
        return self.values, self.colorCodes
    end
    dropdownParent.AddValue = function(self, value, colorCode)
        self.values[#self.values] = value
        colorCodes[#colorCodex + 1] = colorCode
    end
    dropdownParent.RemoveValue = function(self, value)
        for i = 1, #self.values do
            if self.values[i] == value then
                table.remove(self.values, i)
                if self.colorCodes[i] then
                    table.remove(self.colorCodes, i)
                end
                return
            end
        end
    end
    dropdownParent.SetSelectedValue = function(self, value, colorCode)
        if value then
            self.selectedValue = value
            self:SetText(colorCode and "|c" .. colorCode .. value .. "|r" or value)
            if self.callbacks and #self.callbacks > 0 then
                for i = 1, #self.callbacks do
                    self.callbacks[i](self.selectedValue)
                end
            end
        end
    end
    dropdownParent.GetSelectedValue = function(self)
        return self.selectedValue
    end
    dropdownParent.SetInitialValue = function(self, initialValue, initialColor)
        self.initialValue = initialValue
        self.selectedValue = initialValue
        self:SetText(initialColor and "|c" .. initialColor .. initialValue .. "|r" or initialValue)
    end
    dropdownParent.GetInitialValue = function(self)
        return self.initialValue
    end
    if not dropdown then
        dropdown = CreateFrame("Frame", "WDBDropdown", parentFrame) -- The actual dropdown is the collapsible frame (i.e. the child of the dropdown button).
        CUI:ApplyTemplate(dropdownParent, CUI.templates.BorderedFrameTemplate)
        dropdown.AttachTo = function(self, parent)
            self:SetSize(1, #parent.values * 20)
            self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -4)
            self:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, -4)
            self:SetParent(parent)
            self.timeSinceLast = 0
        end
        dropdown.IsAttachedTo = function(self, frame)
            return frame == self:GetParent()
        end
        dropdown:HookScript("OnShow", function(self)
            self.timeSinceLast = 0
        end)
        dropdown:HookScript("OnUpdate", function(self, elapsed)
            self.timeSinceLast = self.timeSinceLast + elapsed
            if self:IsMouseOver() then
                self.timeSinceLast = 0
            elseif self.timeSinceLast >= 2 then
                self.timeSinceLast = 0
                self:Hide()
            end
        end)
        -- First button is a special case when it comes to anchors so create it here.
        dropdownButtons[1] = GetDropdownButton(dropdown)
        dropdownButtons[1]:SetValue(values[1] or "")
        dropdownButtons[1]:SetPoint("TOPLEFT")
        dropdownButtons[1]:SetPoint("BOTTOMRIGHT", dropdown, "TOPRIGHT", 0, -dropdownParent:GetHeight())
        AdjustDropdownButtons(dropdownParent)
        -- Attach the dropdown frame to the first created dropdown parent so it is connected to something.
        dropdown:AttachTo(dropdownParent)
    end
    dropdownParent:HookScript("OnHide", function(self)
        dropdown:Hide()
    end)
    dropdownParent:HookScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if not dropdown:IsAttachedTo(self) then
                AdjustDropdownButtons(self)
                dropdown:AttachTo(self)
                dropdown:Show()
            elseif dropdown:IsVisible() then
                dropdown:Hide()
            else
                dropdown:Show()
            end
        else
            self:SetSelectedValue(self:GetInitialValue())
            dropdown:Hide()
        end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    return dropdownParent
end
