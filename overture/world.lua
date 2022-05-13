local PATH = (...):gsub("%.[^%.]+$", "")

local Configuration = require(PATH..".configuration")
local SparseSet = require(PATH..".sparseSet")
local ComponentProvider = require(PATH..".componentProvider")
local SystemProvider = require(PATH..".systemProvider")
local Entity = require(PATH..".entity")
local Archetype = require(PATH..".archetype")

local World = {}
local WorldMt = {
	__index = World,
}

local function new(systemNames)
	systemNames = systemNames or {}

	local world = setmetatable({
		entities = SparseSet(),
		components = {},

		__archetypes = {},

		__scheduledEmits = {},
		__scheduledEmitsIndex = 1,

		__isEmitting = false,
		__isWorld = true,
	}, WorldMt)

	local emptyArchetype = Archetype()
	world.__archetypes[0] = { emptyArchetype }
	world.__emptyArchetype = emptyArchetype

	for _, systemName in ipairs(systemNames) do
		if (not SystemProvider:has(systemName)) then
			error("")
		end

		local systemPrototype = SystemProvider:get(systemName)

		-- TODO: Build pools
	end

	return world
end

function World:giveEntity(entity)
	if (self:hasEntity(entity)) then
		return self
	end

	self.entities:add(entity)

	self.__emptyArchetype:add(entity)
	entity.archetype = self.__emptyArchetype

	return self
end

function World:removeEntity(entity)
	if (self:hasEntity(entity)) then
		return self
	end

	self.entities:remove(entity)

	return self
end

function World:hasEntity(entity)
	return self.entities:has(entity) and true or false
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

function World:hasSingleton(componentName)
	return self.components[componentName] and true or false
end

function World:__scheduleEmit(eventName, ...)
	local index = self.__scheduledEmitsIndex
	self.__scheduledEmits[index] = eventName

	local argumentsCount = select("#", ...)
	self.__scheduledEmits[index + 1] = argumentsCount

	for i = 1, argumentsCount do
		local argument = select(i, ...)
		self.__scheduledEmits[index + 1 + i] = argument
	end

	self.__scheduledEmitsIndex = index + argumentsCount + 2

	return self
end

function World:__emitRaw(eventName, ...)
	print(eventName, ...)

	if (eventName == "schedule") then
		self:emit("heyoi", 1, 2, 3)
	end

	if (eventName == "heyoi") then
		self:emit("heyoi2", "foo", "bar")
		self:emit("heyoi3", true)
	end

	print("done")
end

-- Emits may only be executed one at a time; nested emits can lead to issues with entity changes
-- Because of this, emits can be scheduled.
-- A variable number of arguments can be passed in, and these arguments need to be stored somewhere
-- If for each emit there is one table created, a lot of garbage will be created
-- Instead, one table is used that stores _all_ arguments
-- To unpack these arguments we can copy them over to an auxiliary table, and unpack()'ing it
-- To optimize further, a set of functions can be made that reads from this table and invokes the function directly

-- Container for recursively unpacking scheduled emits arguments
local argumentUnpackContainer = {}

-- Non-recursive alternative for unpacking scheduled emits arguments, up to 10 arguments
local argumentUnpackerFunctions = {
	[1] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset])
	end,
	[2] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset], data[2 + offset])
	end,
	[3] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset], data[2 + offset], data[3 + offset])
	end,
	[4] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset])
	end,
	[5] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset])
	end,
	[6] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset], data[6 + offset])
	end,
	[7] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset], data[6 + offset], data[7 + offset])
	end,
	[8] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset], data[6 + offset], data[7 + offset], data[8 + offset])
	end,
	[9] = function(world, eventName, data, offset)
		world:__emitRaw(eventName, data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset], data[6 + offset], data[7 + offset], data[8 + offset], data[9 + offset])
	end,
}

function World:emit(eventName, ...)
	if (self:isEmitting()) then
		self:__scheduleEmit(eventName, ...)
	else
		self.__isEmitting = true

		self:__emitRaw(eventName, ...)

		local index = 1
		while (index < self.__scheduledEmitsIndex) do
			local eventName = self.__scheduledEmits[index]
			local argumentsCount = self.__scheduledEmits[index + 1]

			local argumentUnpackerFunction = argumentUnpackerFunctions[argumentsCount]
			if (argumentUnpackerFunction) then
				argumentUnpackerFunction(self, eventName, self.__scheduledEmits, index + 1)
			else
				for i = 1, argumentsCount do
					argumentUnpackContainer[i] = self.__scheduledEmits[i + index + 1]
				end

				self:__emitRaw(eventName, unpack(argumentUnpackContainer))

				for i = 1, argumentsCount do
					argumentUnpackContainer[i] = nil
				end
			end

			index = index + 2 + argumentsCount
		end

		self.__isEmitting = false
	end

	return self
end

function World:flush()
	for _, entity in ipairs(self.entities) do
		if (entity.__isDirty) then
			entity:flush()
			entity.__isDirty = false
		end
	end
end

function World:isEmitting()
	return self.__isEmitting
end

function World:__onEntityGainedComponent(entity, componentName)
	local currentArchetype = entity.archetype
	local nextArchetype = currentArchetype.addTransitions[componentName]

	if (nextArchetype) then
		print("has transition")
	end

	if (not nextArchetype) then
		for _, archetype in ipairs(self.__archetypes[#entity.components]) do
			nextArchetype = archetype.addTransitions[componentName]

			if (nextArchetype) then
				print("found transition")

				currentArchetype.addTransitions[componentName] = nextArchetype
				nextArchetype.removeTransitions[componentName] = currentArchetype

				break
			end
		end
	end

	if (not nextArchetype) then
		print("created transition", componentName)

		nextArchetype = Archetype()

		currentArchetype.addTransitions[componentName] = nextArchetype
		nextArchetype.removeTransitions[componentName] = currentArchetype

		self.__archetypes[#entity.components] = self.__archetypes[#entity.components] or {}
		self.__archetypes[#entity.components][componentName] = nextArchetype
	end

	entity.archetype:remove(entity)
	entity.archetype = nextArchetype
	entity.archetype:add(entity)
end

function World:__onEntityLostComponent(entity, componentName)
	print(entity, "lost", componentName)
end

if (Configuration.doArgumentChecking) then

end

return setmetatable(World, {
	__call = function(_, ...) return new(...) end,
})