local Symbol = require(script.Parent.Symbol)

-- Use a symbol instead of "nil" in the path
local NilSymbol = Symbol.named("TreeCacheNil")

--[[
	Creates a tree-shaped cache object where the parameters are treated as a path of nodes.

	E.g.
		local cache = createTreeCache()
		cache:set("hello world", "foo")
		cache:set("test", "foo", "bar", "baz")
		cache:set("some other data")
	Creates a cache with the shape:
		cache = {
			children = {
				foo = {
					children = {
						bar = {
							children = {
								baz = {
									data = "test",
								},
							},
						},
					},
					data = "hello world",
				},
			},
			data = "some other data",
		}
]]
local function createTreeCache()
	local self = {
		_cache = {}
	}

	self.get = function(_, ...)
		local path = {...}
		local len = select("#", ...)

		local node = self._cache

		for i = 1, len, 1 do
			local pathPiece = path[i]
			if pathPiece == nil then
				pathPiece = NilSymbol
			end
			node = node.children and node.children[pathPiece]
			if not node then
				return nil
			end
		end

		return node.data
	end

	self.set = function(_, data, ...)
		local path = {...}
		local len = select("#", ...)

		local node = self._cache

		for i = 1, len, 1 do
			local pathPiece = path[i]
			if pathPiece == nil then
				pathPiece = NilSymbol
			end

			node.children = node.children or {}

			local nextNode = node.children[pathPiece] or {}
			node.children[pathPiece] = nextNode

			node = nextNode
		end

		node.data = data

		return data
	end

	return self
end

return createTreeCache

