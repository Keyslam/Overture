local Archetype = {}
local ArchetypeMt = {
    __index = Archetype,
}

local function new()
    local archetype = setmetatable({

    }, ArchetypeMt)

    return archetype
end

return setmetatable(Archetype, {
    __call = function(_, ...) return new(...) end,
})