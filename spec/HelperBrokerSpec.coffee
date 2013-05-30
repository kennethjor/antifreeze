$ = require "jquery"
sinon = require "sinon"
{HelperBroker, View} = require "../antifreeze"

class TestView extends View
	$: $

describe "HelperBroker", ->
	# Function helper.
	functionHelperContext = null
	functionHelper = sinon.spy -> functionHelperContext = @
	# Object helper.
	objectHelperContext1 = null
	objectHelperContext2 = null
	objectHelper =
		helper1: sinon.spy(-> objectHelperContext1 = @)
		helper2: sinon.spy(-> objectHelperContext2 = @)
	# Function + object helper.
	functionObjectHelperContext = null
	functionObjectHelperContext1 = null
	functionObjectHelperContext2 = null
	functionObjectHelper = sinon.spy -> functionObjectHelperContext = @
	functionObjectHelper.helper1 = sinon.spy(-> functionObjectHelperContext1 = @)
	functionObjectHelper.helper2 = sinon.spy(-> functionObjectHelperContext2 = @)
	# Broker and expected context
	view = null
	broker = null

	beforeEach ->
		functionHelperContext = null
		objectHelperContext1 = null
		objectHelperContext2 = null
		functionObjectHelperContext = null
		functionObjectHelperContext1 = null
		functionObjectHelperContext2 = null
		HelperBroker.add "functionHelper", functionHelper
		HelperBroker.add "objectHelper", objectHelper
		HelperBroker.add "functionObjectHelper", functionObjectHelper
		view = new TestView
		broker = HelperBroker.getForView view

		afterEach ->
			HelperBroker.add "functionHelper", undefined
			HelperBroker.add "objectHelper", undefined
			HelperBroker.add "functionObjectHelper", undefined


	it "should attach helpers", ->
		expect(typeof broker.functionHelper).toBe "function"
		expect(typeof broker.objectHelper).toBe "object"
		expect(typeof broker.objectHelper.helper1).toBe "function"
		expect(typeof broker.objectHelper.helper2).toBe "function"
		expect(typeof broker.functionObjectHelper).toBe "function"
		expect(typeof broker.functionObjectHelper.helper1).toBe "function"
		expect(typeof broker.functionObjectHelper.helper2).toBe "function"

	it "should bind all first and second level methods to the supplied context", ->
		broker.functionHelper()
		broker.objectHelper.helper1()
		broker.objectHelper.helper2()
		broker.functionObjectHelper()
		broker.functionObjectHelper.helper1()
		broker.functionObjectHelper.helper2()

		expect(functionHelper.callCount).toBe 1
		expect(objectHelper.helper1.callCount).toBe 1
		expect(objectHelper.helper2.callCount).toBe 1
		expect(functionObjectHelper.callCount).toBe 1
		expect(functionObjectHelper.helper1.callCount).toBe 1
		expect(functionObjectHelper.helper2.callCount).toBe 1

		expect(functionHelperContext.view).toBe view
		expect(objectHelperContext1.view).toBe view
		expect(objectHelperContext2.view).toBe view
		expect(functionObjectHelperContext.view).toBe view
		expect(functionObjectHelperContext1.view).toBe view
		expect(functionObjectHelperContext2.view).toBe view

		expect(functionHelperContext.helper).toBe broker.functionHelper
		expect(objectHelperContext1.helper).toBe broker.objectHelper
		expect(objectHelperContext2.helper).toBe broker.objectHelper
		expect(functionObjectHelperContext.helper).toBe broker.functionObjectHelper
		expect(functionObjectHelperContext1.helper).toBe broker.functionObjectHelper
		expect(functionObjectHelperContext2.helper).toBe broker.functionObjectHelper

	it "should be able to have multiple brokers exist as the same time", ->
		view2  = new TestView
		broker2 = HelperBroker.getForView view2
		expect(broker2).not.toBe broker
		expect(functionHelperContext).toBeNull()
		broker2.functionHelper()
		expect(functionHelperContext.view).toBe view2
		broker.functionHelper()
		expect(functionHelperContext.view).toBe view

	it "should have a bound context even for functions called inside the helper", ->
		view = new TestView
		context1 = null
		context2 = null
		internalHelper =
			helper1: ->
				context1 = @
				@helper.helper2()
			helper2: ->
				context2 = @
		HelperBroker.add "internalHelper", internalHelper
		broker = HelperBroker.getForView view
		broker.internalHelper.helper1()
		expect(context1).toBe context2
		expect(context1.view).toBe view
		expect(context2.view).toBe view
		HelperBroker.add "internalHelper", undefined

