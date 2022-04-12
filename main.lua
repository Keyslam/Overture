local Overture = require("overture")
local SpareSet = require("overture.sparseSet")

local Position = Overture.component("position", function(position, x, y)
	position.x = x
    position.y = y

	position.entities = SpareSet()
end)
:onGiven(function(e)
	e.position.entities:add(e)
end)
:onRemoved(function(e)
	e.position.entities:remove(e)
end)
:onGivenSingleton(function(world)
	print("Given as singleton")
end)
:onRemovedSingleton(function(world)
	print("Removed as singleton")
end)

local position = Position()

local world = Overture.world()
world:giveSingletonInstance(position)
world:giveSingleton("position", 10, 10)

local e1 = Overture.entity()
:give("position", 10, 20)

local e2 = Overture.entity()
:giveInstance(e1.position)