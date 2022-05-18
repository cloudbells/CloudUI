local _, ns = ...

-- Constants.
local MAJOR = "CloudUI-1.0"
local MINOR = "1"

-- Initializes stuff.
local function Init()
    assert(LibStub, MAJOR .. " requires LibStub")
    ns.CUI = LibStub:NewLibrary(MAJOR, MINOR)
    if not ns.CUI then return end -- Newer or same version already exists.
    ns.templates = ns:Enum({"DisableableFrameTemplate", "BackgroundFrameTemplate", "BorderedFrameTemplate", "HighlightFrameTemplate", "PushableFrameTemplate"})
    ns.CUI.templates = ns.templates
end

Init()
