local PATH = (...):gsub("%.[^%.]+$", "")

local Configuration = require(PATH..".configuration")
local ComponentProvider = require(PATH..".componentProvider")

local Component = {}
local ComponentMt = {
    __index = Component,
    __call = function(self, ...)
        return self:new(...)
    end
}

local ComponentInstanceMt = {
	__index = function(self, key)
		if (not self.__prototype.validFieldsLookup[key]) then
			error("Attempt to get invalid field")
		end

		return rawget(self, key)
	end,

	__newindex = function(self, key, value)
		if (not self.__prototype.validFieldsLookup[key]) then
			error("Attempt to set invalid field")
		end

		rawset(self, key, value)
	end
}

local function new(componentName, componentDefinition)
	local componentPrototype = setmetatable({
        name = componentName,

		componentDefinition = componentDefinition,
		validFieldsLookup = {},

		__isComponentPrototype = true,
    }, ComponentMt)

	for _, definition in ipairs(componentDefinition) do
		componentPrototype.validFieldsLookup[definition.name] = true
	end

    ComponentProvider:register(componentName, componentPrototype)

    return componentPrototype
end

function Component:new(...)
    local componentInstance = {
		__isComponent = true,
		__prototype = self,
	}

    self:populate(componentInstance, ...)

	if (true) then -- TODO: Make this configurable
		setmetatable(componentInstance, ComponentInstanceMt)
	end

    return componentInstance
end

function Component:populate(componentInstance, ...)
	local nextParamIndex = 1

	for _, definition in ipairs(self.componentDefinition) do
		if (definition.excludeConstructor) then
			componentInstance[definition.name] = nil
		else
			local value = select(nextParamIndex, ...)
			if (value == nil) then
				value = definition.default
			end

			componentInstance[definition.name] = value
			nextParamIndex = nextParamIndex + 1
		end
	end
end

function Component:clear(componentInstance)
	for _, definition in ipairs(self.componentDefinition) do
		componentInstance[definition.name] = nil
	end
end

return setmetatable(Component, {
    __call = function(_, ...) return new(...) end,
})