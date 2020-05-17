return function()
	local createTreeCache = require(script.Parent.createTreeCache)

	it("should work", function()
		local cache = createTreeCache()
		expect(cache:get("foo", "bar")).to.equal(nil)
		local value = {}
		cache:set(value, "foo", "bar")
		expect(cache:get("foo", "bar")).to.equal(value)
	end)

	it("should build the tree correctly", function()
		local cache = createTreeCache()

		local c = cache._cache
		expect(next(c)).to.never.be.ok()

		cache:set(1, "foo")
		cache:set(2, "foo", "bar")
		cache:set(3, "foo", "baz")
		cache:set(4, "foo", "baz", "test")

		expect(c.children).to.be.ok()
		expect(c.children.foo).to.be.ok()
		expect(c.children.foo.data).to.equal(1)
		expect(c.children.foo.children).to.be.ok()
		expect(c.children.foo.children.baz.data).to.equal(3)
		expect(c.children.foo.children.baz.children.test.data).to.equal(4)

		cache:set(5, "foo", "baz")
		expect(c.children.foo.children.baz.data).to.equal(5)
	end)

	it("should handle nil in the path", function()
		local cache = createTreeCache()
		expect(cache:get("foo", nil, "bar")).to.equal(nil)

		cache:set("", "foo")
		expect(cache:get("foo", nil, "bar")).to.equal(nil)

		cache:set("", "foo", "some other key")
		expect(cache:get("foo", nil, "bar")).to.equal(nil)

		local value = {}
		cache:set(value, "foo", nil)
		expect(cache:get("foo", nil)).to.equal(value)
		expect(cache:get("foo", nil, "bar")).to.equal(nil)

		value = {}
		cache:set(value, "foo", nil, "bar")
		expect(cache:get("foo", nil, "bar")).to.equal(value)
	end)

	it("should handle empty paths", function()
		local cache = createTreeCache()
		expect(cache:get()).to.equal(nil)
		cache:set("foo")
		expect(cache:get()).to.equal("foo")
	end)
end
