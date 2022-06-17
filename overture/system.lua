local PATH = (...):gsub("%.[^%.]+$", "")

local Configuration = require(PATH..".configuration")
local SystemProvider = require(PATH..".systemProvider")

local System = {}
local SystemMt = {
	__index = System,
}

local function new(systemName, poolDefinitions)
	local system = setmetatable({
		name = systemName,
		handlers = {},

		__isSystemPrototype = true,
	}, SystemMt)

	SystemProvider:register(systemName, system)

	return system
end

function System:on(eventName, handler)
	self.handlers[eventName] = handler

	return self
end

if (Configuration.doArgumentChecking) then

end

return setmetatable(System, {
	__call = function(_, ...) return new(...) end,
})