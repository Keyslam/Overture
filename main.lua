local Overture = require("overture")
local SparseSet = require("overture.sparseSet")

local Position = Overture.component("position", function(position, x, y)
	position.x = x
    position.y = y

	position.entities = SparseSet()
end)

local world = Overture.world()

local e1 = Overture.entity(world)
:give("position", 10, 20)

-- local e2 = Overture.entity(world)
-- :give("position", 30, 40)

world:flush()

print(e1.position.x, e1.position.y)