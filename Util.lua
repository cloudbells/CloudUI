local _, ns = ...

-- Returns an enum with the given values.
function ns:Enum(t)
    for i = 1, #t do
        t[t[i]] = i
    end
    return t
end
