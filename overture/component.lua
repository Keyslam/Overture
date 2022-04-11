local PATH = (...):gsub("%.[^%.]+$", "")

local ComponentProvider = require(PATH..".componentProvider")

local Component = {}
local ComponentMt = {
    __index = Component,
}

local function new(name, populateFunction)
    local component = setmetatable({
        __name = name,
        __populate = populateFunction
    }, ComponentMt)

    ComponentProvider:register(name, component)

    return component
end

function Component:onGiven(func)
    self.onGivenHandler = func
end

function Component:onRemoved(func)
    self.onRemovedHandler = func
end

return setmetatable(Component, {
    __call = function(_, ...) return new(...) end,
})