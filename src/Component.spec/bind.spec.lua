return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)

	local Component = require(script.Parent.Parent.Component)

	local noopReconciler = createReconciler(NoopRenderer)

	it("should call the bound function with the correct parameters", function()
		local ChildComponent = Component:extend("ChildComponent")

		function ChildComponent:init()
			self.props.onCallback("bar")
		end

		function ChildComponent:render()
			return nil
		end

		local MyComponent = Component:extend("MyComponent")

		local bindSpy = createSpy()
		MyComponent.callback = bindSpy.value

		-- To check that the bound callback is called with the correct "self"
		local expectedSelf = nil
		function MyComponent:init()
			expectedSelf = self
		end

		function MyComponent:render()
			return createElement(ChildComponent, {
				onCallback = self:bind(self.callback, "foo")
			})
		end

		local element = createElement(MyComponent, {})

		local hostParent = nil
		local key = "Some Component Key"
		noopReconciler.mountVirtualNode(element, hostParent, key)

		expect(bindSpy.callCount).to.equal(1)
		expect(function()
			bindSpy:assertCalledWith(expectedSelf, "foo", "bar")
		end).to.never.throw()
	end)

	it("should memoize the bound function", function()
		local MyComponent = Component:extend("MyComponent")

		local boundFunctionWithFooInRender = nil
		local boundFunctionWithBarInRender = nil

		local callCount = 0
		local calledWith = nil
		function MyComponent:callback(param)
			callCount = callCount + 1
			calledWith = param
		end

		function MyComponent:render()
			boundFunctionWithFooInRender = self:bind(self.callback, "foo")
			boundFunctionWithBarInRender = self:bind(self.callback, "bar")
			return nil
		end

		local element = createElement(MyComponent, {})

		local hostParent = nil
		local key = "Some Component Key"
		local node = noopReconciler.mountVirtualNode(element, hostParent, key)

		-- Bound parameters are different so functions should be different
		expect(boundFunctionWithFooInRender).to.never.equal(boundFunctionWithBarInRender)

		boundFunctionWithFooInRender()
		expect(callCount).to.equal(1)
		expect(calledWith).to.equal("foo")

		boundFunctionWithBarInRender()
		expect(callCount).to.equal(2)
		expect(calledWith).to.equal("bar")

		local origFoo = boundFunctionWithFooInRender
		local origBar = boundFunctionWithBarInRender

		noopReconciler.updateVirtualNode(node, createElement(MyComponent, {}))

		expect(boundFunctionWithFooInRender).to.never.equal(boundFunctionWithBarInRender)

		-- Bound functions from the second render should be the same functions as the first render
		expect(boundFunctionWithFooInRender).to.equal(origFoo)
		expect(boundFunctionWithBarInRender).to.equal(origBar)

		boundFunctionWithFooInRender()
		expect(callCount).to.equal(3)
		expect(calledWith).to.equal("foo")

		boundFunctionWithBarInRender()
		expect(callCount).to.equal(4)
		expect(calledWith).to.equal("bar")
	end)
end
