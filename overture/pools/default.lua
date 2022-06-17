local PATH = (...):gsub("%.[^%.]+$", "")

-- local SparseSet = require(PATH..".sparseSet")
local SparseSet = require("overture.sparseSet")

local DefaultPool = {}
local DefaultPoolMt = {
    __index = DefaultPool,
}

local function new(world, filter)
	local defaultPool = setmetatable({
		__entities = SparseSet(),
		__added = {},
		__removed = {},
	}, DefaultPoolMt)

	return defaultPool
end

function DefaultPool:add(e)
	self.__entities:add(e)
end

function DefaultPool:remove(e)
	self.__entities:remove(e)
end

function DefaultPool:has(e)
	return self.__entities:has(e)
end

function DefaultPool:entities()
	return ipairs(self.__entities)
end

function DefaultPool:added()
	return ipairs(self.__added)
end

function DefaultPool:removed()
	return ipairs(self.__removed)
end

function DefaultPool:flush()
	for i = 1, #self.__added do
		self.__added[i] = nil
	end

	for i = 1, #self.__removed do
		self.__removed[i] = nil
	end
end

return setmetatable(DefaultPool, {
	__call = function(_, filter)
		return function(world)
			return new(world, filter)
		end
	end,
})

