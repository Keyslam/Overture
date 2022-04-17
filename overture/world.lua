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

function World:ensureSingleton(componentName, ...)
	if (self:has(componentName)) then
		return self
	end

	self:give(componentName, ...)
end

function World:ensureSingletonInstance(componentInstance)
	local componentName = componentInstance.__prototype.name

	if (self:has(componentName)) then
		return self
	end

	self:giveInstance(componentInstance)
end

function World:removeSingleton(componentName)
	if (not self:has(componentName)) then
		error("")
	end

	local componentPrototype = self[componentName].__prototype

	if (componentPrototype.onRemovedSingletonHandler) then
		componentPrototype.onRemovedSingletonHandler(self)
	end

	self.components[componentName] = nil

	return self
end

function World:removeSingletonInstance(componentInstance)
	local componentName = componentInstance.__prototype.name
	local componentPrototype = componentInstance.__prototype

	if (componentPrototype.onRemoveHandler) then
		componentPrototype.onRemoveHandler(self)
	end

	self.components[componentName] = nil
end

function World:has(componentName)
	return self.components[componentName] and true or false
end

return setmetatable(World, {
	__call = function() return new() end,
})