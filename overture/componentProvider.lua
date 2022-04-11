local ComponentProvider = {
    __components = {}
}

function ComponentProvider:register(componentName, component)
    self.__components[componentName] = component
end

function ComponentProvider:get(componentName)
    return self.__components[componentName]
end

function ComponentProvider:has(componentName)
    return self.__components[componentName] and true or false
end

return ComponentProvider