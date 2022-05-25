local _, ns = ...

-- Variables.
local CUI = ns.CUI
local dropdownButtons = {}
local framePool = {} -- Frame pool specifically for dropdown buttons (i.e. the buttons containing values).
local dropdown

-- Claim the given frame.
local function Lock(self)
    self.isUsed = true
end

-- Reclaim the given frame.
local function Unlock(self)
    self.isUsed = false
end

-- Returns true if the given frame is claimed, false otherwise.
local function IsLocked(self)
    return self.isUsed
end

-- Assigns the given value to the given frame.
local function SetValue(self, value)
    assert(value, "SetValue: 'value' can't be nil")
    self.value = value
end

-- Returns the given frame's value.
local function GetValue(self)
    return self.value
end

-- Called when the given dropdown button is clicked.
local function DropdownButton_OnClick(self)
    local dropdown = self:GetParent()
    dropdown:Hide()
    dropdown:GetParent():SetSelectedValue(self:GetText(), self.value, self.colorCode)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

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
    CUI:ApplyTemplate(button, CUI.templates.PushableFrameTemplate)
    local fontString = button:CreateFontString(nil, "ARTWORK", CUI:GetFontBig():GetName())
    fontString:SetJustifyH("LEFT")
    fontString:SetPoint("LEFT", 2, 0)
    button:SetFontString(fontString)
    button:SetHeight(20)
    button.value = ""
    button.SetValue = SetValue
    button.GetValue = GetValue
    button:HookScript("OnClick", DropdownButton_OnClick)
    button.Lock = Lock
    button.IsLocked = IsLocked
    button.Unlock = Unlock
    button:Lock()
    framePool[#framePool + 1] = button
    return button
end

-- Adds or removes buttons as appropriate and sets the value for each button.
local function AdjustDropdownButtons(dropdownParent)
    local lastButtonIndex = #dropdownButtons -- The "index" of the last button. There will always be at least one button so we only need to attach buttons to the bottom button.
    local newValues, newColorCodes = dropdownParent:GetValues()
    local newTexts = dropdownParent:GetTexts()
    local delta = #newValues - lastButtonIndex -- Add buttons if > 0, otherwise remove buttons.
    -- If delta is 0 we don't have to add or remove any buttons, only adjust values.
    if delta < 0 then
        for i = #newValues + 1, lastButtonIndex do
            dropdownButtons[i]:Hide()
            dropdownButtons[i]:Unlock()
            dropdownButtons[i] = nil
        end
    elseif delta > 0 then
        local startIndex = lastButtonIndex + 1 -- First button should never be adjusted.
        for i = startIndex == 1 and 2 or startIndex, #newValues do
            dropdownButtons[i] = GetDropdownButton(dropdown)
            -- Anchor it to the latest button.
            dropdownButtons[i]:SetPoint("TOPLEFT", dropdownButtons[i - 1], "BOTTOMLEFT")
            dropdownButtons[i]:SetPoint("BOTTOMRIGHT", dropdownButtons[i - 1], "BOTTOMRIGHT", 0, -dropdownParent:GetHeight())
            dropdownButtons[i]:Show()
        end
    end
    -- Adjust values.
    for i = 1, #dropdownButtons do
        dropdownButtons[i]:SetValue(newValues[i])
    end
    -- Adjust texts.
    for i = 1, #dropdownButtons do
        if newColorCodes and newColorCodes[i] then
            dropdownButtons[i]:SetText("|c" .. newColorCodes[i] .. newTexts[i] .. "|r")
        else
            dropdownButtons[i]:SetText(newTexts[i])
        end
    end
end

-- Script handlers.

-- Called when the dropdown parent is hidden.
local function DropdownParent_OnHide(self)
    dropdown:Hide()
end

-- Called when the dropdown parent is clicked.
local function DropdownParent_OnClick(self, button)
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
    end
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

-- Called when the dropdown is shown.
local function Dropdown_OnShow(self)
    self.timeSinceLast = 0
end

-- Called on every frame.
local function Dropdown_OnUpdate(self, elapsed)
    self.timeSinceLast = self.timeSinceLast + elapsed
    if self:IsMouseOver() then
        self.timeSinceLast = 0
    elseif self.timeSinceLast >= 2 then
        self.timeSinceLast = 0
        self:Hide()
    end
end

-- Template functions.

-- Registers the given function as a callback for the given frame.
local function RegisterCallback(self, callback)
    assert(callback and type(callback) == "function", "RegisterCallback: 'callback' needs to be a function")
    self.callbacks[#self.callbacks + 1] = callback
end

-- Unregisters the given function as a callback for the given frame.
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

-- Sets the values for the given frame.
local function SetValues(self, values)
    assert(values and type(values) == "table" and #values > 0, "SetValues: 'values' needs to be a non-empty table")
    self.values = values
    AdjustDropdownButtons(self)
end

-- Returns the given frame's values.
local function GetValues(self)
    return self.values, self.colorCodes
end

-- Adds the given value to the given frame's values.
local function AddValue(self, value)
    assert(value, "AddValue: 'value' can't be nil")
    self.values[#self.values + 1] = value
end

-- Removes the given value from the given frame's values.
local function RemoveValue(self, value)
    assert(value, "RemoveValue: 'value' can't be nil")
    for i = 1, #self.values do
        if self.values[i] == value then
            table.remove(self.values, i)
            return
        end
    end
end

-- Sets the given frame's value at the given index.
local function SetValueAt(self, index, value)
    assert(index and type(index) == "number" and index > 0, "SetValueAt: 'index' needs to be a non-negative number")
    assert(text, "SetValueAt: 'value' can't be nil")
    if self.values[index] then
        self.values[index] = value
    end
    AdjustDropdownButtons(self)
end

-- Sets the texts for the given frame.
local function SetTexts(self, texts)
    assert(texts and type(texts) == "table" and #texts > 0, "SetTexts: 'texts' needs to be a non-empty table")
    self.texts = texts
    AdjustDropdownButtons(self)
end

-- Returns the texts for the given frame.
local function GetTexts(self)
    return self.texts
end

-- Adds the given text to the given frame's texts.
local function AddText(self, text)
    assert(text and type(text) == "string" or type(text) == "number", "AddText: 'text' needs to be a number or a string")
    self.texts[#self.texts + 1] = text
end

-- Removes the given text from the given frame's texts.
local function RemoveText(self, text)
    assert(text and type(text) == "string" or type(text) == "number", "RemoveText: 'text' needs to be a number or a string")
    for i = 1, #self.texts do
        if self.texts[i] == text then
            table.remove(self.texts, i)
        end
    end
end

-- Sets the given frame's text at the given index.
local function SetTextAt(self, index, text)
    assert(index and type(index) == "number" and index > 0, "SetTextAt: 'index' needs to be a non-negative number")
    assert(text and type(text) == "string" or type(text) == "number", "SetTextAt: 'text' needs to be a number or a string")
    if self.texts[index] then
        self.texts[index] = text
    end
    AdjustDropdownButtons(self)
end

-- Sets the given frame's color codes.
local function SetColorCodes(self, colorCodes)
    assert(colorCodes and type(colorCodes) == "table" and #colorCodes > 0, "SetColorCodes: 'colorCodes' needs to be a non-empty table")
    self.colorCodes = colorCodes
    AdjustDropdownButtons(self)
end

-- Returns the given frame's color codes.
local function GetColorCodes(self)
    return self.colorCodes
end

-- Adds the given color code to the frame's color codes.
local function AddColorCode(self, colorCode)
    assert(colorCode and type(colorCode) == "string", "AddColorCode: 'colorCode' needs to be a string")
    self.colorCodes[#self.colorCodes + 1] = colorCode
end

-- Removes the given color code from the given frame's color codes.
local function RemoveColorCode(self, colorCode)
    assert(colorCode and type(colorCode) == "string", "RemoveColorCode: 'colorCode' needs to be a string")
    for i = 1, #self.colorCodes do
        if self.colorCodes[i] == colorCode then
            table.remove(self.colorCodes, i)
        end
    end
end

-- Sets the given frame's color code at the given index.
local function SetColorCodeAt(self, index, colorCode)
    assert(index and type(index) == "number" and index > 0, "SetColorCodeAt: 'index' needs to be a non-negative number")
    assert(colorCode and type(colorCode) == "string", "SetColorCodeAt: 'colorCode' needs to be a string")
    if self.colorCodes[index] then
        self.colorCodes[index] = colorCode
    end
    AdjustDropdownButtons(self)
end

-- Sets the selected value for the given frame as well as sets the text and color code of the frame.
local function SetSelectedValue(self, text, value, colorCode)
    assert(text and type(text) == "string" or type(text) == "number", "SetSelectedValue: 'text' needs to be a number or a string")
    assert(value, "SetSelectedValue: 'value' can't be nil")
    self.selectedValue = value
    if colorCode then
        assert(type(colorCode) == "string", "SetSelectedValue: 'colorCode needs to be a string")
        self:SetText(colorCode and "|c" .. colorCode .. text .. "|r")
    else
        self:SetText(text)
    end
    if self.callbacks and #self.callbacks > 0 then
        for i = 1, #self.callbacks do
            self.callbacks[i](self, self.selectedValue)
        end
    end
end

-- Returns the given frame's selected value.
local function GetSelectedValue(self)
    return self.selectedValue
end

-- Attaches the given frame to the given parent.
local function AttachTo(self, parent)
    local height = #parent.values * parent:GetHeight()
    self:SetHeight(height)
    self:SetParent(parent)
    local width = parent:GetWidth()
    local newLeftOffset, newBottomOffset = 0, 0
    local bottomOffset = parent:GetBottom() - self:GetHeight() - 4
    local leftOffset = parent:GetLeft()
    local screenWidth, screenHeight = UIParent:GetSize()
    if leftOffset <= 2 then -- If the dropdown would end up being outside the screen on the left side.
        newLeftOffset = -leftOffset + 2
    elseif leftOffset + width >= screenWidth - 2 then -- Right side.
        newLeftOffset = screenWidth - leftOffset - width - 2
    end
    if bottomOffset <= 2 then -- Bottom.
        newBottomOffset = -bottomOffset + height - 4
    elseif bottomOffset + height >= screenHeight + 2 then -- Above (this should never be possible).
        newBottomOffset = screenHeight - bottomOffset - height + 2
    end
    self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0 + newLeftOffset, -4 + newBottomOffset)
    self:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0 + newLeftOffset, -4 + newBottomOffset)
    self.timeSinceLast = 0
end

-- Returns true if the given frame is attached to the given parent.
local function IsAttachedTo(self, parent)
    return parent == self:GetParent()
end

-- Creates a dropdown with the given name in the given parent frame. If given, will register for the callbacks and call those functions whenever a value is selected in the dropdown.
-- A table of values is non-optional – button 1 will be given the value values[1] etc.
-- A table of texts is also non-optional and will be assigned same as above.
-- A table of color codes is optional and will also be assigned same as above.
-- Returns the dropdown if it's successfully created, false otherwise.
function CUI:CreateDropdown(parentFrame, frameName, callbacks, values, texts, colorCodes)
    if callbacks then
        assert(type(callbacks) == "table" and #callbacks > 0, "CreateDropdown: 'callbacks' needs to be a non-empty table")
    end
    assert(values and type(values) == "table" and #values > 0, "CreateDropdown: 'values' needs to be a non-empty table")
    assert(texts and type(texts) == "table" and #texts > 0, "CreateDropdown: 'texts' needs to be a non-empty table")
    if colorCodes then
        assert(type(colorCodes) == "table" and #colorCodes > 0, "CreateDropdown: 'colorCodes' needs to be a non-empty table")
    end
    -- Create the actual dropdown parent button (which opens/closes the dropdown itself).
    local dropdownParent = CreateFrame("Button", frameName, parentFrame or UIParent) -- If parentFrame is nil, the size will be fucked.
    CUI:ApplyTemplate(dropdownParent, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(dropdownParent, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(dropdownParent, CUI.templates.BackgroundFrameTemplate)
    CUI:ApplyTemplate(dropdownParent, CUI.templates.PushableFrameTemplate)
    dropdownParent:SetHeight(20) -- Just a default height which is obviously editable by the user.
    local fontString = dropdownParent:CreateFontString(nil, "ARTWORK", CUI:GetFontBig():GetName()) -- Can be retrieved and changed via :GetFontString()
    fontString:SetJustifyH("LEFT")
    fontString:SetPoint("LEFT", 2, 0)
    dropdownParent:SetFontString(fontString)
    dropdownParent.callbacks = callbacks or {}
    dropdownParent.texts = texts or {}
    dropdownParent.values = values or {}
    dropdownParent.colorCodes = colorCodes or {}
    dropdownParent.RegisterCallback = RegisterCallback
    dropdownParent.UnregisterCallback = UnregisterCallback
    dropdownParent.SetValues = SetValues
    dropdownParent.GetValues = GetValues
    dropdownParent.AddValue = AddValue
    dropdownParent.RemoveValue = RemoveValue
    dropdownParent.SetValueAt = SetValueAt
    dropdownParent.SetTexts = SetTexts
    dropdownParent.GetTexts = GetTexts
    dropdownParent.AddText = AddText
    dropdownParent.RemoveText = RemoveText
    dropdownParent.SetTextAt = SetTextAt
    dropdownParent.SetColorCodes = SetColorCodes
    dropdownParent.GetColorCodes = GetColorCodes
    dropdownParent.AddColorCode = AddColorCode
    dropdownParent.RemoveColorCode = RemoveColorCode
    dropdownParent.SetColorCodeAt = SetColorCodeAt
    dropdownParent.SetSelectedValue = SetSelectedValue
    dropdownParent.GetSelectedValue = GetSelectedValue
    if not dropdown then
        dropdown = WDBDropdown or CreateFrame("Frame", "WDBDropdown", UIParent) -- The actual dropdown is the collapsible frame (i.e. the child of the dropdown button).
        dropdown:Hide()
        CUI:ApplyTemplate(dropdown, CUI.templates.BorderedFrameTemplate)
        dropdown.AttachTo = AttachTo
        dropdown.IsAttachedTo = IsAttachedTo
        local success = true
        success = dropdown:HookScript("OnShow", Dropdown_OnShow)
        success = dropdown:HookScript("OnUpdate", Dropdown_OnUpdate)
        if not success then
            dropdown = nil
            return false
        end
        -- First button is a special case when it comes to anchors so create it here.
        dropdownButtons[1] = GetDropdownButton(dropdown)
        dropdownButtons[1]:SetValue(dropdownParent.values[1] or "")
        dropdownButtons[1]:SetPoint("TOPLEFT")
        dropdownButtons[1]:SetPoint("BOTTOMRIGHT", dropdown, "TOPRIGHT", 0, -dropdownParent:GetHeight())
        AdjustDropdownButtons(dropdownParent)
    end
    if not dropdownParent:HookScript("OnHide", DropdownParent_OnHide) then return false end
    if not dropdownParent:HookScript("OnClick", DropdownParent_OnClick) then return false end
    dropdownParent.selectedValue = dropdownParent.values[1]
    dropdownParent:SetText(dropdownParent.colorCodes[1] and "|c" .. dropdownParent.colorCodes[1] .. dropdownParent.texts[1] .. "|r" or dropdownParent.texts[1])
    return dropdownParent
end







-- temp, remove
local testdropdownUp = CUI:CreateDropdown(
    UIParent,                                           -- parentFrame
    "TestFrameDelete",                                  -- frameName
    {function(self, value)                              -- callbacks
        print(value)
    end},
    {"UP1", "UP2", "UP3", "UP4"},                       -- values
    {"UP1", "UP2", "UP3", "UP4"},                       -- texts
    {"FF00FFFF", "1A1000FF", "00FF00FF"})               -- colorCodes
testdropdownUp:SetWidth(200)
testdropdownUp:SetPoint("CENTER", 0, 520)


local testdropdownLeft = CUI:CreateDropdown(
    UIParent,                                           -- parentFrame
    "TestFrameDeletewww",                               -- frameName
    {function(self, value)                              -- callbacks
        print(value)
    end},
    {"LEFT1", "LEFT2", "LEFT3", "LEFT4"},               -- values
    {"LEFT1", "LEFT2", "LEFT3", "LEFT4"},               -- texts
    {"FF00FFFF", "1A1000FF", "00FF00FF"})               -- colorCodes
testdropdownLeft:SetWidth(200)
testdropdownLeft:SetPoint("CENTER", -850, 250)


local testdropdownDown = CUI:CreateDropdown(
    UIParent,                                           -- parentFrame
    "TestFrameDeletewwwww",                             -- frameName
    {function(self, value)                              -- callbacks
        print(value)
    end},
    {"DOWN1", "DOWN2", "DOWN3", "DOWN4"},               -- values
    {"DOWN1", "DOWN2", "DOWN3", "DOWN4"},               -- texts
    {"FF00FFFF", "1A1000FF", "00FF00FF"})               -- colorCodes
testdropdownDown:SetWidth(200)
testdropdownDown:SetPoint("CENTER", -700, -450)


local testdropdownRight = CUI:CreateDropdown(
    UIParent,                                           -- parentFrame
    "TestFrameDeletewwwwwwww",                          -- frameName
    {function(self, value)                              -- callbacks
        print(value)
    end},
    {"RIGHT1", "RIGHT2", "RIGHT3", "RIGHT4"},           -- values
    {"RIGHT1", "RIGHT2", "RIGHT3", "RIGHT4"},           -- texts
    {"FF00FFFF", "1A1000FF", "00FF00FF"})               -- colorCodes
testdropdownRight:SetWidth(200)
testdropdownRight:SetPoint("CENTER", 850, -450)






local frame = CreateFrame("Frame", "movableframetest", UIParent)
CUI:ApplyTemplate(frame, CUI.templates.BackgroundFrameTemplate)
CUI:ApplyTemplate(frame, CUI.templates.BorderedFrameTemplate)
frame:SetSize(64, 64)
frame:SetPoint("CENTER", -850, 250)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:HookScript("OnUpdate", function(self, elapsed)
    if self.isMoving then
        local left, bottom = self:GetRect()
        if bottom + 64 > UIParent:GetHeight() then
            print("OUTSIDE SCREEN: ".. UIParent:GetHeight() - bottom - 64 + 2)
        else
            print(("LEFT_OFFSET: %.4f    BOTTOM_OFFSET: %.4f"):format(left, bottom))
        end
    end
end)
frame:HookScript("OnMouseDown", function(self)
    self:StartMoving()
    self.isMoving = true
end)
frame:HookScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
    self.isMoving = false
end)
