{Route} = require "../antifreeze"

describe "Route", ->
	it "should work", ->
		expect(true).toBe true
		expect(typeof Route).toBe "function"
		route = new Route
		expect(route.hello()).toBe "hi"
