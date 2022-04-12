local PATH = (...):gsub("%.[^%.]+$", "")

local ComponentProvider = require(PATH..".componentProvider")

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

local function new()
	local entity = setmetatable({
		archetype = nil,
		components = {},
	}, EntityMt)

	return entity
end

function Entity:give(componentName, ...)
	local componentPrototype = ComponentProvider:get(componentName)

	if (not componentPrototype) then
		error("")
	end

	local componentInstance = componentPrototype(self, ...)
	self.components[componentName] = componentInstance

	if (componentPrototype.onGivenHandler) then
		componentPrototype.onGivenHandler(self)
	end

	return self
end

function Entity:giveInstance(componentInstance)
	local componentPrototype = componentInstance.__prototype

	local componentName = componentPrototype.name
	self.components[componentName] = componentInstance

	if (componentPrototype.onGivenHandler) then
		componentPrototype.onGivenHandler(self)
	end

	return self
end

function Entity:ensure(componentName, ...)
	if (self:has(componentName)) then
		return
	end

	self:give(componentName, ...)
end

function Entity:ensureInstance(componentInstance)

end

function Entity:remove(componentName)
	local componentInstance = self.components[componentName]
	local componentPrototype = componentInstance.__prototype

	if (componentPrototype.onRemovedHandler) then
		componentPrototype.onRemovedHandler(self)
	end

	self.components[componentName] = nil
end

function Entity:removeInstance(componentInstance)
	local componentName = componentInstance.__prototype.name
	local componentPrototype = componentInstance.__prototype

	if (componentPrototype.onRemovedHandler) then
		componentPrototype.onRemovedHandler(self)
	end

	self.components[componentName] = nil
end

function Entity:has(componentName)
	return self.components[componentName] and true or false
end

return setmetatable(Entity, {
	__call = function() return new() end,
})