local PATH = (...):gsub("%.[^%.]+$", "")

local SparseSet = require(PATH..".sparseSet")

local Archetype = {}
local ArchetypeMt = {
    __index = Archetype,
}

local function new()
    local archetype = setmetatable({
		entities = SparseSet(),
    }, ArchetypeMt)

    return archetype
end

function Archetype:add(entity)

end

return setmetatable(Archetype, {
    __call = function(_, ...) return new(...) end,
})