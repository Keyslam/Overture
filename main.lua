local Overture = require("overture")

-- Defining components
Overture.component("position", {
	{ name = "x", default = 0 },
	{ name = "y", default = 0 },
})

Overture.component("velocity", {
	{ name = "x", default = 0 },
	{ name = "y", default = 0 },
})

-- Systems
Overture.system("moveSystem", {
	pool = Overture.pools.default({ "position", "velocity" }),
})
:on("update", function(world, pools, dt)
	for _, e in pools.pool:entities() do -- All entities in pool
		print(e)
	end
end)


local world = Overture.world({
	"moveSystem"
})

-- Component manipulation
local e1 = world:newEntity()
:addComponent("position", 10, 20)

-- world:emit("update", 0)