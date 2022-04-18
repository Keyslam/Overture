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

local function new(componentName, populateFunction)
    local componentPrototype = setmetatable({
        name = componentName,
        populate = populateFunction,

		__isComponentPrototype = true,
    }, ComponentMt)

    ComponentProvider:register(componentName, componentPrototype)

    return componentPrototype
end

function Component:new(...)
    local component = {}
    component.__prototype = self
    component.__isComponent = true

    self.populate(component, ...)

    return component
end

function Component:onGiven(onGivenHandler)
    self.onGivenHandler = onGivenHandler

    return self
end

function Component:onRemove(onRemoveHandler)
    self.onRemoveHandler = onRemoveHandler

    return self
end

function Component:onGivenSingleton(onGivenSingletonHandler)
    self.onGivenSingletonHandler = onGivenSingletonHandler

    return self
end

function Component:onRemoveSingleton(onRemoveSingletonHandler)
    self.onRemovedSingletonHandler = onRemoveSingletonHandler

    return self
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