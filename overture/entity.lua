local PATH = (...):gsub("%.[^%.]+$", "")

local ComponentProvider = require(PATH..".componentProvider")

local Entity = {}
local EntityMt = {
    __index = function(entity, key)
        return
            Entity[key] or
            entity.components[key] or
            entity.archetype.methods[key] or
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

    local component = {}
    componentPrototype.__populate(self, ...)

    self.components[componentName] = component

    return self
end

function Entity:giveInstance(componentInstance)
    local componentName = componentInstance.__name
    self.components[componentName] = componentInstance

    return self
end

function Entity:ensure(componentName, ...)
    if (self:has(componentName)) then
        return
    end

    self:give(componentName, ...)
end

function Entity:has(componentName)
    return self.components[componentName] and true or false
end

function Entity:remove(componentName)
    self.components[componentName] = nil
end

return setmetatable(Entity, {
    __call = function() return new() end,
})