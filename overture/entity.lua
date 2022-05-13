local PATH = (...):gsub("%.[^%.]+$", "")

local Configuration = require(PATH..".configuration")
local Enum = require(PATH..".enum")
local ComponentProvider = require(PATH..".componentProvider")

local ComponentActions = Enum({
	"GIVE",
	"GIVE_INSTANCE",
	"ENSURE",
	"ENSURE_INSTANCE",
	"REMOVE",
	"REMOVE_INSTANCE",
})

local Entity = {}
local EntityMt = {
	__index = function(entity, key)
		return
			Entity[key] or
			entity.components[key] or
			-- entity.archetype.methods[key] or
			nil
	end,
}

local function new(world)
	local entity = setmetatable({
		archetype = nil,
		components = {},

		componentActions = {},
		componentActionsIndex = 1,

		__isDirty = false,
		__isEntity = true,
	}, EntityMt)

	if (world) then
		world:giveEntity(entity)
	end

	return entity
end

function Entity:give(componentName, ...)
	local argCount = select("#", ...)

	-- Format:
	-- "GIVE", #args, componentName, ..args
	self.componentActions[self.componentActionsIndex] = ComponentActions.GIVE
	self.componentActions[self.componentActionsIndex + 1] = argCount
	self.componentActions[self.componentActionsIndex + 1 + 1] = componentName

	for i = 1, argCount do
		self.componentActions[self.componentActionsIndex + 1 + 1 + i] = select(i, ...)
	end

	self.componentActionsIndex = self.componentActionsIndex + 1 + 1 + argCount

	self.__isDirty = true

	return self
end

function Entity:giveInstance(componentInstance)
	local componentPrototype = componentInstance.__prototype

	local componentName = componentPrototype.name
	self.components[componentName] = componentInstance

	if (componentPrototype.onGivenHandler) then
		componentPrototype.onGivenHandler(self)
	end

	self.__isDirty = true

	return self
end

function Entity:ensure(componentName, ...)
	if (self:has(componentName)) then
		return self
	end

	self:give(componentName, ...)
end

function Entity:ensureInstance(componentInstance)
	local componentName = componentInstance.__prototype.name

	if (self:has(componentName)) then
		return self
	end

	self:giveInstance(componentInstance)
end

function Entity:remove(componentName)
	local componentInstance = self.components[componentName]
	local componentPrototype = componentInstance.__prototype

	if (componentPrototype.onRemoveHandler) then
		componentPrototype.onRemoveHandler(self)
	end

	self.components[componentName] = nil

	self.__isDirty = true
end

function Entity:removeInstance(componentInstance)
	local componentName = componentInstance.__prototype.name
	local componentPrototype = componentInstance.__prototype

	if (componentPrototype.onRemoveHandler) then
		componentPrototype.onRemoveHandler(self)
	end

	self.components[componentName] = nil

	self.__isDirty = true
end

function Entity:has(componentName)
	return self.components[componentName] ~= nil
end

local argumentUnpackContainer = {}

local argumentUnpackerFunctions = {
	[1] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset])
	end,
	[2] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset], data[2 + offset])
	end,
	[3] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset], data[2 + offset], data[3 + offset])
	end,
	[4] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset])
	end,
	[5] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset])
	end,
	[6] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset], data[6 + offset])
	end,
	[7] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset], data[6 + offset], data[7 + offset])
	end,
	[8] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset], data[6 + offset], data[7 + offset], data[8 + offset])
	end,
	[9] = function(componentPrototype, data, offset)
		return componentPrototype(data[1 + offset], data[2 + offset], data[3 + offset], data[4 + offset], data[5 + offset], data[6 + offset], data[7 + offset], data[8 + offset], data[9 + offset])
	end,
}

function Entity:flush()
	local index = 1

	while (index ~= self.componentActionsIndex) do
		local componentAction = self.componentActions[index]

		if (componentAction == ComponentActions.GIVE) then
			local argumentsCount = self.componentActions[index + 1]
			local componentName = self.componentActions[index + 2]

			local componentPrototype = ComponentProvider:get(componentName)

			if (not componentPrototype) then
				error("")
			end

			local componentInstance = nil

			local argumentUnpackerFunction = argumentUnpackerFunctions[argumentsCount]
			if (argumentUnpackerFunction) then
				componentInstance = argumentUnpackerFunction(componentPrototype, self.componentActions, index + 2)
			else
				for i = 1, argumentsCount do
					argumentUnpackContainer[i] = self.componentActions[i + index + 2]
				end

				componentInstance = componentPrototype(unpack(argumentUnpackContainer))

				for i = 1, argumentsCount do
					argumentUnpackContainer[i] = nil
				end
			end

			self.components[componentName] = componentInstance

			if (componentPrototype.onGivenHandler) then
				componentPrototype.onGivenHandler(self)
			end

			index = index + 2 + argumentsCount
		end
	end
end

if (Configuration.doArgumentChecking) then

end

return setmetatable(Entity, {
	__call = function(_, ...) return new(...) end,
})