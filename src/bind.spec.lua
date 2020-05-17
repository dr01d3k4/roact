return function()
	local bind = require(script.Parent.bind)

	it("should call the bound function", function()
		local wasCalled = false

		local function funcToBind()
			wasCalled = true
		end

		local boundFunc = bind(funcToBind)
		boundFunc()
		expect(wasCalled).to.equal(true)
	end)

	it("should pass parameters to bound function", function()
		local wasCalled = false

		local function funcToBind(a, b, c)
			wasCalled = true
			expect(a).to.equal("a")
			expect(b).to.equal("b")
			expect(c).to.equal("c")
		end

		local boundFunc = bind(funcToBind, "a", "b")
		boundFunc("c")
		expect(wasCalled).to.equal(true)
	end)

	it("should handle nil parameters", function()
		local wasCalled = false
		local function funcToBind(a, b, c, d, e, f, g, h, i, j)
			wasCalled = true

			expect(a).to.equal("a")
			expect(b).to.equal(nil)
			expect(c).to.equal(2)
			expect(d).to.equal(false)
			expect(e).to.equal(true)
			expect(f).to.equal("test")
			expect(g).to.equal("foo")
			expect(h).to.equal(nil)
			expect(i).to.equal("bar")
			expect(j).to.equal(nil)
		end

		local boundFunc = bind(funcToBind, "a", nil, 2, false, true, "test")
		boundFunc("foo", nil, "bar", nil)
		expect(wasCalled).to.equal(true)
	end)

	it("should handle extreme nil", function()
		local wasCalled = false
		local function funcToBind(a, b, c, d, e, f, g, h, i, j)
			wasCalled = true

			expect(a).to.equal(nil)
			expect(b).to.equal(nil)
			expect(c).to.equal(nil)
			expect(d).to.equal(nil)
			expect(e).to.equal(nil)
			expect(f).to.equal(nil)
			expect(g).to.equal(nil)
			expect(h).to.equal(nil)
			expect(i).to.equal(nil)
			expect(j).to.equal("hello")
		end

		local boundFunc = bind(funcToBind, nil, nil, nil, nil, nil, nil)
		boundFunc(nil, nil, nil, "hello")
		expect(wasCalled).to.equal(true)
	end)

	it("should return the value returned from the bound function", function()
		local function funcToBind()
			return 5
		end
		expect(bind(funcToBind)()).to.equal(5)
	end)
end
