local _, ns = ...

-- Constants.
local MAJOR = "CloudUI-1.0"
local MINOR = "1"

-- Initialize the library.
local function Init()
    assert(LibStub, MAJOR .. " requires LibStub")
    local CUI = LibStub:NewLibrary(MAJOR, MINOR)
    if not CUI then return end -- Newer or same version already exists.
    ns.CUI = CUI
    ns.templates = ns:Enum({"DisableableFrameTemplate", "BackgroundFrameTemplate", "BorderedFrameTemplate", "HighlightFrameTemplate", "PushableFrameTemplate"})
    CUI.templates = ns.templates
end

-- Returns an enum with the given values.
function ns:Enum(t)
    for i = 1, #t do
        t[t[i]] = i
    end
    return t
end

Init()
