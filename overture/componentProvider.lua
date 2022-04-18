local PATH = (...):gsub("%.[^%.]+$", "")

local Configuration = require(PATH..".configuration")

local ComponentProvider = {
    __components = {}
}

function ComponentProvider:register(componentName, componentPrototype)
    self.__components[componentName] = componentPrototype

	return self
end

function ComponentProvider:get(componentName)
    return self.__components[componentName]
end

function ComponentProvider:has(componentName)
    return self.__components[componentName] and true or false
end

if (Configuration.doArgumentChecking) then
	local __register = ComponentProvider.register
	function ComponentProvider:register(componentName, componentPrototype)
		if (type(componentName) ~= "string") then
			error("") -- TODO: Define error message
		end

		if (not componentPrototype.__isComponentPrototype) then
			error("") -- TODO: Define error message
		end

		if (self:has(componentName)) then
			error("") -- TODO: Define error message
		end

		return __register(self, componentName, componentPrototype)
	end

	local __get = ComponentProvider.get
	function ComponentProvider:get(componentName)
		if (type(componentName) ~= "string") then
			error("") -- TODO: Define error message
		end

		if (not self:has(componentName)) then
			error("") -- TODO: Define error message
		end

		return __get(self, componentName)
	end

	local __has = ComponentProvider.has
	function ComponentProvider:has(componentName)
		if (type(componentName) ~= "string") then
			error("") -- TODO: Define error message
		end

		return __has(self, componentName)
	end
end

return ComponentProvider