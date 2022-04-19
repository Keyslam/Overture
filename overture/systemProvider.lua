local PATH = (...):gsub("%.[^%.]+$", "")

local Configuration = require(PATH..".configuration")

local SystemProvider = {
    __systems = {}
}

function SystemProvider:register(systemName, systemPrototype)
    self.__systems[systemName] = systemPrototype
end

function SystemProvider:get(systemName)
    return self.__systems[systemName]
end

function SystemProvider:has(systemName)
    return self.__systems[systemName] and true or false
end

if (Configuration.doArgumentChecking) then

end

return SystemProvider