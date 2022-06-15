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

	defaultPool.__iteration = 0
	defaultPool.__iterator = function(a, v)
		defaultPool.__iteration = defaultPool.__iteration + 1
		return defaultPool.__entities[defaultPool.__iteration]
	end

	return defaultPool
end

function DefaultPool:entities(a)
	self.iteration = 1
	return self.__iterator, a, self.__entities[self.iteration]
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

