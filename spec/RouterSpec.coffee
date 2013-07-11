sinon = require "sinon"
crossroads = require "crossroads"
{Router, Route} = require "../antifreeze"

# This is not a test of the Antifreeze Router, but just a quick test of Crossroads itself.
describe "Crossroads", ->
	it "should do basic things", ->
		router = crossroads.create()
		handler = sinon.spy ->
			#console.log @
			#console.log arguments
		router.addRoute "test/{id}", handler
		router.parse "test/7"
		waitsFor (-> handler.called), "Handler not called", 100
		runs ->
			expect(handler.callCount).toBe 1

describe "Router", ->
	router = null
	beforeEach ->
		router = new Router

	it "should accept string routes", ->
		route = router.add "test/{id}"
		expect(route instanceof Route).toBe true
		expect(route.pattern).toBe "test/{id}"

	it "should accept Route routes", ->
		route = new Route "test/{id}"
		expect(router.add route).toBe route


