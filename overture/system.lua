local PATH = (...):gsub("%.[^%.]+$", "")

local SystemProvider = require(PATH..".systemProvider")

local System = {}
local SystemMt = {
	__index = System,
}

local function new(systemName, poolDefinition)
	local system = setmetatable({
		name = systemName,
		handlers = {},

		__isSystem = true,
	}, SystemMt)

	SystemProvider:register(systemName, system)

	return system
end

function System:onAdded(onAddedHandler)
	self.onAddedHandler = onAddedHandler

	return self
end

function System:onEmit(eventName, handler)
	self.handlers[eventName] = handler

	return self
end

function System:onMatch(onMatchHandler)
	self.onMatchHandler = onMatchHandler

	return self
end

function System:onUnmatch(onUnmatchHandler)
	self.onUnmatchHandler = onUnmatchHandler

	return self
end

return setmetatable(System, {
	__call = function(_, ...) return new(...) end,
})