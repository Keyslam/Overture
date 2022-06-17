local PATH = (...):gsub("%.init$", "")

local Pools = {}

Pools.default = require(PATH..".default")

return Pools