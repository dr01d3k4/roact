--[[
	Merges multiple arrays into 1. Supports nil values in the arrays.
	Expects given arrays to have n field for length.
	E.g.
		mergeArrays({n=4, "hello", nil, "world", nil}, {n=4, nil, nil, "foo", nil}, {n=0}, {n=1,nil})
		--> {n=9, "hello", nil, "world", nil, nil, nil, "foo", nil, nil}
]]
local function mergeArrays(...)
	local t = {n = 0}

	for sourceIndex = 1, select("#", ...), 1 do
		local source = select(sourceIndex, ...)
		for i = 1, source.n, 1 do
			t.n = t.n + 1
			t[t.n] = source[i]
		end
	end

	return t
end

local function bind(func, ...)
	local firstArgs = table.pack(...)

	return function(...)
		local secondArgs = table.pack(...)
		local merged = mergeArrays(firstArgs, secondArgs)
		return func(table.unpack(merged, 1, merged.n))
	end
end

return bind

