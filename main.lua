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
:onRemove(function(e)
	e.position.entities:remove(e)
end)
:onGivenSingleton(function(world)
	print("Given as singleton")
end)
:onRemoveSingleton(function(world)
	print("Removed as singleton")
end)

Overture.system("test", {"position"})
:onAdded(function(world)
	print("added to", world)
end)
:onMatch(function(world, pool, e)
	print("matched", pool)
end)
:onUnmatch(function(world, pool, e)
	print("unmatched", pool)
end)
:onEmit("update", function(world, pool, dt)
	for _, e in ipairs(pool) do
		print(e)
	end
end)


local position = Position()

local world = Overture.world({
	"test"
})
world:giveSingletonInstance(position)
-- world:giveSingleton("position", 10, 10)

local e1 = Overture.entity()
:give("position", 10, 20)

local e2 = Overture.entity()
:giveInstance(e1.position)

world:emit("schedule", 10, 20, nil, 30)