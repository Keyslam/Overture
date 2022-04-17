local PATH = (...):gsub("%.[^%.]+$", "")

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
    }, ComponentMt)

    ComponentProvider:register(componentName, componentPrototype)

    return componentPrototype
end

function Component:new(...)
    local component = {}
    component.__prototype = self

    self.populate(component, ...)

    return component
end

function Component:onGiven(handler)
    self.onGivenHandler = handler

    return self
end

function Component:onRemove(handler)
    self.onRemoveHandler = handler

    return self
end

function Component:onGivenSingleton(handler)
    self.onGivenSingletonHandler = handler

    return self
end

function Component:onRemoveSingleton(handler)
    self.onRemovedSingletonHandler = handler

    return self
end

return setmetatable(Component, {
    __call = function(_, ...) return new(...) end,
})