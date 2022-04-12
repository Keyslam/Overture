local SpareSet = {}
local SpareSetMt = {
    __index = SpareSet
}

local function new()
    local spareSet = setmetatable({}, SpareSetMt)

    return spareSet
end

function SpareSet:add(element)
    local index = #self + 1

    self[index] = element
    self[element] = index

    return self
end

function SpareSet:remove(element)
    local index = self[element]
    local count = #self

    if (index == #self) then
        self[index] = nil
        self[element] = nil

        return self
    end

    local swappingElement = self[count]

    self[index] = swappingElement
    self[swappingElement] = index
    self[element] = nil
    self[count] = nil

    return self
end

function SpareSet:has(element)
    return self[element] and true or false
end

function SpareSet:indexOf(element)
    return self[element]
end

function SpareSet:elementAtIndex(index)
    return self[index]
end

return setmetatable(SpareSet, {
    __call = function(_, ...) return new(...) end,
})