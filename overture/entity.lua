local PATH = (...):gsub("%.[^%.]+$", "")

local Configuration = require(PATH..".configuration")
local Enum = require(PATH..".enum")
local ComponentProvider = require(PATH..".componentProvider")

local Entity = {}
local EntityMt = {
	__index = Entity,
}

local function new(world)
	local entity = setmetatable({
		archetype = nil,

		__addedComponents = {},
		__removedComponents = {},

		__components = {},
		__world = world,

		__isEntity = true,
	}, EntityMt)

	return entity
end

function Entity:addComponent(componentName, ...)
	local componentPrototype = ComponentProvider:get(componentName)
	local componentInstance = componentPrototype:new(...) -- TODO: Fetch from pool

	self.__components[componentName] = componentInstance
	self[componentName] = componentInstance

	return self
end

function Entity:removeComponent(componentName)
	local componentPrototype = ComponentProvider:get(componentName)
	local componentInstance = self.__components[componentName]

	componentPrototype:clear(componentInstance)

	self.__components[componentName] = nil
	self[componentName] = nil
	-- TODO: Return to pool
end

function Entity:getComponent(componentName)
	return self.__components[componentName]
end

function Entity:hasComponent(componentName)
	return self.__components[componentName] ~= nil
end

function Entity:getWorld()
	return self.__world
end

return setmetatable(Entity, {
	__call = function(_, ...) return new(...) end,
})