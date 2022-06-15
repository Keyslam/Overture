-- local Overture = require("overture")

-- local world = Overture.world()

-- -- Defining components
-- Overture.component("position", {
-- 	{ name = "x", default = 0 },
-- 	{ name = "y", default = 0 },
-- })

-- Overture.component("test", {
-- 	{ name = "a", default = nil },
-- 	{ name = "b", default = nil, excludeConstructor = true },
-- 	{ name = "c", default = nil },
-- })

-- -- Component manipulation
-- local e1 = world:newEntity()
-- 	:addComponent("position", 10, 20)

-- local e2 = world:newEntity()
-- :position(10, 20)
-- :test("foo", "bar")

-- e2.position()
-- e2.position = nil

	-- :addComponent("position", 10, 20)
	-- :addComponent("test", "foo", "bar")

-- print(e2.test.a, e2.test.b, e2.test.c)



-- -- Custom pools
-- function SomeCustomPool()
-- 	return function(world)
-- 		return {
-- 			add = function(self, e) end,
-- 			remove = function(self, e) end,
-- 			has = function(self, e) return true end,

-- 			entities = function(self) return {} end,
-- 			added = function(self) return {} end,
-- 			removed = function(self) return {} end,

-- 			flush = function(self) end,
-- 		}
-- 	end
-- end

-- -- Systems
-- Overture.system("moveSystem", {
-- 	pool = Overture.pools.default({ "position", "velocity" }),
-- 	sortedByX = Overture.pools.sorted({ "position" }, function(a, b) -- Advanced pools
-- 		return a.position.x > b.position.x
-- 	end),
-- 	custom = SomeCustomPool()
-- })
-- 	:on("update", function(world, pools, dt)
-- 		for _, e in pools.pool.entities() do -- All entities in pool
-- 			Overture.helpers:applyVelocity(e, dt)
-- 		end

-- 		for _, e in pools.pool.added() do -- All entities added to pool since last time this event was called

-- 		end

-- 		for _, e in pools.pool.removed() do -- All entities removed from pool since last time this event was called

-- 		end
-- 	end)
-- 	:on("draw", function(world, pools)

-- 	end)


-- -- Singleton components
-- world:addSingletonComponent("position", 10, 20)


local DefaultPool = require("overture.pools.default")
local pool = DefaultPool()()
local t = {}

for i = 1, 10000000 do
	local o = {v = 0}
	pool:add(o)
	t[i] = o
end

local start1 = love.timer.getTime()
for e in pool:entities() do
	e.v = e.v + 1
end
local stop1 = love.timer.getTime()

local start3 = love.timer.getTime()
for _, e in ipairs(pool.__entities) do
	e.v = e.v + 1
end
local stop3 = love.timer.getTime()

print(stop1 - start1)
print(stop3 - start3)