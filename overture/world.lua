local PATH = (...):gsub("%.[^%.]+$", "")

local ComponentProvider = require(PATH..".componentProvider")

local World = {}
local WorldMt = {
	__index = World,
}

local function new()
	local world = setmetatable({
		components = {},
	}, WorldMt)

	return world
end

function World:giveSingleton(componentName, ...)
	local componentPrototype = ComponentProvider:get(componentName)

	if (not componentPrototype) then
		error("")
	end

	local componentInstance = componentPrototype(self, ...)
	self.components[componentName] = componentInstance

	if (componentPrototype.onGivenSingletonHandler) then
		componentPrototype.onGivenSingletonHandler(self)
	end

	return self
end

function World:giveSingletonInstance(componentInstance)
	local componentPrototype = componentInstance.__prototype

	local componentName = componentPrototype.name
	self.components[componentName] = componentInstance

	if (componentPrototype.onGivenSingletonHandler) then
		componentPrototype.onGivenSingletonHandler(self)
	end

	return self
end

function World:removeSingleton(componentName)

end

function World:removeSingletonInstance()

end

function World:has(componentName)
	return self.components[componentName] and true or false
end

return setmetatable(World, {
	__call = function() return new() end,
})