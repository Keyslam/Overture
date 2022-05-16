local Overture = require("overture")

local a = {}

local position = Overture.component("position", {
	{name = "x", default = 0},
	{name = "y", default = 0},
	{name = "o", default = a},
	{name = "z", omitFromConstructor = true},
})

local p = position:new(nil, 20, nil, 40)
print(p, p.x, p.y, p.o, p.z)

-- Overture.helper("applyVelocity", function(e, dt)
-- 	local position = e.getMutableComponent("position")
-- 	local velocity = e.getComponent("velocity")

-- 	position.x = position.x + velocity.x * dt
-- 	position.y = position.y + velocity.y * dt
-- end)

-- function SomeCustomPool()

-- end

-- world:createEntity()
-- :addComponent("position")
-- :getComponent("velocity")
-- :getMutableComponent("velocity")


-- Overture.system("moveSystem", {
-- 	pool = Overture.pools.default({"position", "velocity"}, {
-- 		reactive = {"added", "removed", "mutated"}
-- 	}),
-- 	sortedByX = Overture.pools.sorted({"position"}, function(a, b)
-- 		return a.position.x > b.position.x
-- 	end),
-- 	custom = SomeCustomPool()
-- })
-- :on("update", function(world, pools, dt)
-- 	for _, e in pools.pool.entities() do -- All entities in pool
-- 		Overture.helpers:applyVelocity(e, dt)
-- 	end

-- 	for _, e in pools.pool.added() do -- All entities added to pool since last time this event was called

-- 	end

-- 	for _, e in pools.pool.removed() do -- All entities removed from pool since last time this event was called

-- 	end
-- end)
-- :on("draw", function(world, pools)

-- end)

-- local world = Overture.world()

-- local e1 = Overture.entity(world)
-- :give("position", 10, 20)

-- -- local e2 = Overture.entity(world)
-- -- :give("position", 30, 40)

-- world:flush()

-- print(e1.position.x, e1.position.y)
