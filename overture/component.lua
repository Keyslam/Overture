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

local function new(componentName, componentDefinition)
	local componentPrototype = setmetatable({
        name = componentName,

		componentDefinition = componentDefinition,

		__isComponentPrototype = true,
    }, ComponentMt)

    ComponentProvider:register(componentName, componentPrototype)

    return componentPrototype
end

function Component:new(...)
    local componentInstance = {}
    componentInstance.__prototype = self
    componentInstance.__isComponent = true

    self:populate(componentInstance, ...)

    return componentInstance
end

function Component:populate(componentInstance, ...)
	for i, definition in ipairs(self.componentDefinition) do
		local value = select(i, ...)
		if (value == nil) then
			value = definition.default
		end

		componentInstance[definition.name] = value
	end
end

if (Configuration.doArgumentChecking) then
	local __new = new
	new = function(componentName, populateFunction)
		if (type(componentName) ~= "string") then
			error("") -- TODO: Define error message
		end

		if (type(populateFunction) ~= "function") then
			error("") -- TODO: Define error message
		end

		if (ComponentProvider:has(componentName)) then
			error("") -- TODO: Define error message
		end

		return __new(componentName, populateFunction)
	end

	local __onGiven = Component.onGiven
	function Component:onGiven(onGivenHandler)
		if (type(onGivenHandler) ~= "function") then
			error("") -- TODO: Define error message
		end

		return __onGiven(self, onGivenHandler)
	end

	local __onRemove = Component.onRemove
	function Component:onRemove(onRemoveHandler)
		if (type(onRemoveHandler) ~= "function") then
			error("") -- TODO: Define error message
		end

		return __onRemove(self, onRemoveHandler)
	end

	local __onGivenSingleton = Component.onGivenSingleton
	function Component:onGivenSingleton(onGivenSingletonHandler)
		if (type(onGivenSingletonHandler) ~= "function") then
			error("") -- TODO: Define error message
		end

		return __onGivenSingleton(self, onGivenSingletonHandler)
	end

	local __onRemoveSingleton = Component.onRemoveSingleton
	function Component:onRemoveSingleton(onRemoveSingletonHandler)
		if (type(onRemoveSingletonHandler) ~= "function") then
			error("") -- TODO: Define error message
		end

		return __onRemoveSingleton(self, onRemoveSingletonHandler)
	end
end

return setmetatable(Component, {
    __call = function(_, ...) return new(...) end,
})