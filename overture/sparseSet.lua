local SparseSet = {}
local SparseSetMt = {
	__index = SparseSet
}

local function new()
	local sparseSet = setmetatable({

	}, SparseSetMt)

	return sparseSet
end

function SparseSet:add(element)
	local index = #self + 1

	self[index] = element
	self[element] = index

	return self
end

function SparseSet:remove(element)
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

function SparseSet:has(element)
	return self[element] and true or false
end

function SparseSet:indexOf(element)
	return self[element]
end

function SparseSet:elementAtIndex(index)
	return self[index]
end

return setmetatable(SparseSet, {
	__call = function(_, ...) return new(...) end,
})
