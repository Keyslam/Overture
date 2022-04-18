local SystemProvider = {
    __systems = {}
}

function SystemProvider:register(systemName, system)
    self.__systems[systemName] = system
end

function SystemProvider:get(systemName)
    return self.__systems[systemName]
end

function SystemProvider:has(systemName)
    return self.__systems[systemName] and true or false
end

return SystemProvider