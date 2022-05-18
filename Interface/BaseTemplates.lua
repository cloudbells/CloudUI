local _, ns = ...

-- Variables.
local CUI = ns.CUI

-- Applies the given template to the given frame. Returns true if successful, false otherwise.
function CUI:ApplyTemplate(frame, template)
    local success
    local frameName = frame:GetName()
    if template == ns.templates.DisableableFrameTemplate then
        if frame.disableableFrameTemplate then return false end -- We've already applied this template.
        success = frame:HookScript("OnDisable", function(self)
            self.isDisabled = true
            if self.CUIHighlightTexture then
                self.CUIHighlightTexture:Hide()
            end
            if self.CUIPushTexture then
                self.CUIPushTexture:Hide()
            end
        end)
        if not success then return false end
        success = frame:HookScript("OnEnable", function(self)
            self.isDisabled = false
            if self.CUIHighlightTexture then
                self.CUIHighlightTexture:Show()
            end
            if self.CUIPushTexture then
                self.CUIPushTexture:Show()
            end
        end)
        if not success then return false end
        frame.isDisabled = frame.IsEnabled and not frame:IsEnabled() or false -- Frame should be disableable regardless of if it's already enableable (buttons etc).
        frame.IsDisabled = function(self)
            return self.isDisabled
        end
        frame.disableableFrameTemplate = true
    elseif template == ns.templates.BackgroundFrameTemplate then
        if frame.backgroundFrameTemplate then return false end
        local CUIBackgroundTexture = frame:CreateTexture(frameName and frameName .. "CUIBackgroundTexture" or nil, "BACKGROUND")
        CUIBackgroundTexture:SetColorTexture(0, 0, 0, 1)
        CUIBackgroundTexture:SetAllPoints(frame)
        frame.CUIBackgroundTexture = CUIBackgroundTexture
        frame.SetBackgroundColor = function(self, r, g, b, a)
            self.CUIBackgroundTexture:SetColorTexture(r, g, b, a)
        end
        frame.ResetBackgroundColor = function(self)
            self:SetColorTexture(0, 0, 0, 1)
        end
        frame.backgroundFrameTemplate = true
    elseif template == ns.templates.BorderedFrameTemplate then
        if frame.borderedFrameTemplate then return false end
        local CUITopBorderTexture = frame:CreateTexture(frameName and frameName .. "CUITopBorderTexture" or nil, "BORDER")
        CUITopBorderTexture:SetColorTexture(1, 1, 1, 1)
        CUITopBorderTexture:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -1, 0)
        CUITopBorderTexture:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 1, 0)
        frame.CUITopBorderTexture = CUITopBorderTexture
        local CUIRightBorderTexture = frame:CreateTexture(frameName and frameName .. "CUIRightBorderTexture" or nil, "BORDER")
        CUIRightBorderTexture:SetColorTexture(1, 1, 1, 1)
        CUIRightBorderTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 0, -1)
        CUIRightBorderTexture:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 1)
        frame.CUIRightBorderTexture = CUIRightBorderTexture
        local CUIBottomBorderTexture = frame:CreateTexture(frameName and frameName .. "CUIBottomBorderTexture" or nil, "BORDER")
        CUIBottomBorderTexture:SetColorTexture(1, 1, 1, 1)
        CUIBottomBorderTexture:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -1, 0)
        CUIBottomBorderTexture:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 1, 0)
        frame.CUIBottomBorderTexture = CUIBottomBorderTexture
        local CUILeftBorderTexture = frame:CreateTexture(frameName and frameName .. "CUILeftBorderTexture" or nil, "BORDER")
        CUILeftBorderTexture:SetColorTexture(1, 1, 1, 1)
        CUILeftBorderTexture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, -1)
        CUILeftBorderTexture:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, 1)
        frame.CUILeftBorderTexture = CUILeftBorderTexture
        frame.SetBorderColor = function(self, r, g, b, a)
            self.CUITopBorderTexture:SetColorTexture(r, g, b, a)
            self.CUIRightBorderTexture:SetColorTexture(r, g, b, a)
            self.CUIBottomBorderTexture:SetColorTexture(r, g, b, a)
            self.CUILeftBorderTexture:SetColorTexture(r, g, b, a)
        end
        frame.ResetBorderColor = function(self)
            self:SetBorderColor(1, 1, 1, 1)
        end
        frame.borderedFrameTemplate = true
    elseif template == ns.templates.HighlightFrameTemplate then
        if frame.highlightFrameTemplate then return false end
        local CUIHighlightTexture = frame:CreateTexture(frameName and frameName .. "CUIHighlightTexture" or nil, "HIGHLIGHT")
        CUIHighlightTexture:SetColorTexture(1, 1, 1, 0.3)
        CUIHighlightTexture:SetAllPoints(frame)
        CUIHighlightTexture:Hide()
        frame.CUIHighlightTexture = CUIHighlightTexture
        frame.SetHighlightColor = function(self, r, g, b, a)
            self.CUIHighlightTexture:SetColorTexture(r, g, b, a)
        end
        frame.ResetHighlightColor = function(self)
            self.CUIHighlightTexture:SetColorTexture(1, 1, 1, 0.3)
        end
        success = frame:HookScript("OnEnter", function(self)
            if not self.isDisabled then
                self.CUIHighlightTexture:Show()
            end
        end)
        if not success then return false end
        success = frame:HookScript("OnLeave", function(self)
            self.CUIHighlightTexture:Hide()
        end)
        if not success then return false end
        frame.highlightFrameTemplate = true
    elseif template == ns.templates.PushableFrameTemplate then
        if frame.pushableFrameTemplate then return false end
        local CUIPushTexture = frame:CreateTexture(frameName and frameName .. "CUIPushTexture" or nil, "HIGHLIGHT")
        CUIPushTexture:SetColorTexture(1, 1, 1, 0.6)
        CUIPushTexture:SetAllPoints(frame)
        CUIPushTexture:Hide()
        frame.CUIPushTexture = CUIPushTexture
        frame.SetPushColor = function(self, r, g, b, a)
            self.CUIPushTexture:SetColorTexture(r, g, b, a)
        end
        frame.ResetPushColor = function(self)
            self.CUIPushTexture:SetColorTexture(1, 1, 1, 0.6)
        end
        success = frame:HookScript("OnMouseDown", function(self)
            if not self.isDisabled then
                if self.CUIHighlightTexture then
                    CUIHighlightTexture:Hide()
                end
                self.CUIPushTexture:Show()
            end
        end)
        if not success then return false end
        success = frame:HookScript("OnMouseUp", function(self)
            self.CUIPushTexture:Hide()
            if self.CUIHighlightTexture then
                CUIHighlightTexture:Show()
            end
        end)
        frame.pushableFrameTemplate = true
    end
    return true
end

-- Initializes the base templates.
local function Init()
    -- Fonts.
    local fontSmall = CreateFont("CUIFontSmallTemplate")
    fontSmall:SetFont("Fonts/FRIZQT__.ttf", 10, "OUTLINE")
    ns.fontSmall = fontSmall
    local fontNormal = CreateFont("CUIFontNormalTemplate")
    fontNormal:SetFont("Fonts/FRIZQT__.ttf", 12, "OUTLINE")
    ns.fontNormal = fontNormal
    local fontBig = CreateFont("CUIFontBigTemplate")
    fontBig:SetFont("Fonts/FRIZQT__.ttf", 14, "OUTLINE")
    ns.fontBig = fontBig
    local fontHuge = CreateFont("CUIFontHugeTemplate")
    fontHuge:SetFont("Fonts/FRIZQT__.ttf", 16, "OUTLINE")
    ns.fontHuge = fontHuge
    -- Frames.
    local disableableFrame = CreateFrame("Frame", "CUIDisableableFrameTemplate", UIParent)
end

-- Returns the small font.
function CUI:GetFontSmall()
    return ns.fontSmall
end

-- Returns the normal font.
function CUI:GetFontNormal()
    return ns.fontNormal
end

-- Returns the big font.
function CUI:GetFontBig()
    return ns.fontBig
end

-- Returns the huge font.
function CUI:GetFontHuge()
    return ns.fontHuge
end

Init()
