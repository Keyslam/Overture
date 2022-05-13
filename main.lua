local Overture = require("overture")
local SparseSet = require("overture.sparseSet")

local Position = Overture.component("position", function(position, x, y)
	position.x = x
    position.y = y

	position.entities = SparseSet()
end)

local Velocity = Overture.component("velocity", function(velocity, x, y)
	velocity.x = x
    velocity.y = y
end)


local world = Overture.world()

local e1 = Overture.entity(world)
:give("position", 10, 20)
:give("velocity", 30, 40)

local e2 = Overture.entity(world)
:give("velocity", 30, 40)
:give("position", 10, 20)

-- local e2 = Overture.entity(world)
-- :give("position", 30, 40)

world:flush()
