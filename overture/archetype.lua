local PATH = (...):gsub("%.[^%.]+$", "")

local SparseSet = require(PATH..".sparseSet")

local Archetype = {}
local ArchetypeMt = {
    __index = Archetype,
}

local function new()
    local archetype = setmetatable({
		entities = SparseSet(),
		addTransitions = {},
		removeTransitions = {},
    }, ArchetypeMt)

    return archetype
end

function Archetype:add(entity)
	self.entities:add(entity)
end

function Archetype:remove(entity)
	self.entities:remove(entity)
end

return setmetatable(Archetype, {
    __call = function(_, ...) return new(...) end,
})