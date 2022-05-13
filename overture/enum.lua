local Enum = {}

local EnumMt = {
	__index = function(key)
		return Enum[key] or error("Invalid enum") -- TODO
	end
}

function Enum.new(options)
	local enum = setmetatable({}, EnumMt)

	for _, option in ipairs(options) do
		enum[option] = option
	end

	return enum
end

return setmetatable(Enum, {
	__call = function(_, ...) return Enum.new(...) end,
})