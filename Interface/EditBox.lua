local _, ns = ...

-- Variables.
local CUI = ns.CUI
local tabIndeces = {}
local tabIndecesReverse = {}
local tabCount = 0
local maxTabIndex = 0
local minTabIndex = 0
local currentTabIndex = 0

-- Register the given frame for tab order. Attempts to focus the EditBox whenever the player presses tab while in the frame.
-- Allows overwriting indeces already assigned, i.e. if two EditBoxes are given the same index, the last to be assigned gets the index.
function CUI:SetTabIndex(frame, tabIndex)
    assert(type(frame) == "table" and frame:GetObjectType() == "EditBox", "SetTabIndex: the frame has to be an EditBox")
    local newIndex
    if tabIndex then
        assert(type(tabIndex) == "number" and tabIndex <= 100 and tabIndex >= -100, "SetTabIndex: the tab index has to be a number between -100 and 100")
        newIndex = tabIndex
    else -- If no tab index is given, assign it whatever the maximum is + 1.
        newIndex = maxTabIndex + 1
    end
    -- If the given frame already has an index, remove that index so frames don't have double indeces.
    local oldIndex = tabIndecesReverse[frame]
    if oldIndex then
        tabIndeces[oldIndex] = nil
    else
        tabCount = tabCount + 1
    end
    maxTabIndex = tabCount == 1 and newIndex or newIndex > maxTabIndex and newIndex or maxTabIndex
    minTabIndex = tabCount == 1 and newIndex or newIndex < minTabIndex and newIndex or minTabIndex
    tabIndeces[newIndex] = frame
    tabIndecesReverse[frame] = newIndex
end

-- Returns an EditBox with the given frame as parent and with the given name.
-- Sets a default incremental tab index. Change using CUI:SetTabIndex(frame, index).
function CUI:CreateEditBox(parentFrame, frameName)
    local editBox = CreateFrame("EditBox", frameName, parentFrame)
    CUI:ApplyTemplate(editBox, ns.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(editBox, ns.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(editBox, ns.templates.BackgroundFrameTemplate)
    CUI:ApplyTemplate(editBox, ns.templates.DisableableFrameTemplate)
    editBox:SetAutoFocus(false)
    editBox:SetHeight(20)
    editBox:SetFontObject(self:GetFontBig())
    editBox:SetTextInsets(2, 0, 0, 0)
    CUI:SetTabIndex(editBox)
    editBox.disableR = 0.7
    editBox.disableG = 0.7
    editBox.disableB = 0.7
    editBox.disableA = 1
    editBox.normalR = 1
    editBox.normalG = 1
    editBox.normalB = 1
    editBox.normalA = 1
    editBox.SetNormalColor = function(self, r, g, b, a)
        self.normalR = r
        self.normalG = g
        self.normalB = b
        self.normalA = a
    end
    editBox.ResetNormalColor = function(self)
        self:SetNormalColor(1, 1, 1, 1)
    end
    editBox.SetDisableColor = function(self, r, g, b, a)
        self.disableR = r
        self.disableG = g
        self.disableB = b
        self.disableA = a
    end
    editBox.ResetDisableColor = function(self)
        self:SetDisableColor(0.7, 0.7, 0.7, 0.7)
    end
    editBox:HookScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    editBox:HookScript("OnTabPressed", function(self)
        if tabCount > 0 then
            local isShiftDown = IsShiftKeyDown()
            local incr = isShiftDown and -1 or 1
            for i = currentTabIndex, isShiftDown and minTabIndex or maxTabIndex, incr do
                -- If the next index is out of bounds, we reach around to the first frame again and vice versa.
                local nextIndex = i + incr > maxTabIndex and minTabIndex or i + incr < minTabIndex and maxTabIndex or i + incr
                if tabIndeces[nextIndex] then
                    currentTabIndex = nextIndex
                    tabIndeces[currentTabIndex]:SetFocus()
                    break
                end
            end
        end
    end)
    editBox:HookScript("OnEditFocusGained", function(self)
        currentTabIndex = tabIndecesReverse[self]
    end)
    editBox:HookScript("OnDisable", function()
        self:SetTextColor(self.disableR, self.disableG, self.disableB, self.disableA)
    end)
    editBox:HookScript("OnEnable", function()
        self:SetTextColor(self.normalR, self.normalG, self.normalB, self.normalA)
    end)
    return editBox
end

-- temp, test with tab groups too




-- local editBox = CUI:CreateEditBox(UIParent, "testdtawdaw")
-- editBox:SetWidth(200)
-- editBox:Show()
-- editBox:SetPoint("CENTER")

-- CUI:SetTabIndex(editBox, -100)

-- local editBox2 = CUI:CreateEditBox(UIParent, "testdtawdaww")
-- editBox2:SetWidth(200)
-- editBox2:Show()
-- editBox2:SetPoint("CENTER", 0, -40)

-- local editBox3 = CUI:CreateEditBox(UIParent, "testdtawdawww")
-- editBox3:SetWidth(200)
-- editBox3:Show()
-- editBox3:SetPoint("CENTER", 0, -80)

-- local editBox4 = CUI:CreateEditBox(UIParent, "testdtawdawwww")
-- editBox4:SetWidth(200)
-- editBox4:Show()
-- editBox4:SetPoint("CENTER", 0, -120)

-- CUI:SetTabIndex(editBox4, 10)
