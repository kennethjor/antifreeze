$ = require "jquery"
sinon = require "sinon"
{Model} = require "discrete"
{RivetsHelper, View, HelperBroker} = require "../../antifreeze"

class TestView extends View
	$: $

# http://rivetsjs.com/
describe "Rivets", ->
	view = null
	spanText = null
	data = null
	beforeEach ->
		HelperBroker.add "rivets", RivetsHelper
		element = $ "<div></div>"
		# Bound data.
		data = new Model
			text: new Model
				foo: "foo"
		# Bound elements.
		spanText = $ "<span data-text=\"text.foo\"></span>"

		element.append spanText
		view = new TestView
			element: element
			model: data

	afterEach ->
		HelperBroker.add "rivets", undefined

	it "should convert model data to a format consumable by Rivets, because Rivets is a bit dumb", ->
		model = new Model
			foo: new Model
				a: 1
				b: 2
			bar: new Model
				c: 3
				d: 4
		data = RivetsHelper.convertData model
		expect(typeof data).toBe "object"
		expect(data instanceof Model).toBe false
		expect(_.has data, "foo").toBe true
		expect(_.has data, "bar").toBe true
		expect(data.foo instanceof Model).toBe true
		expect(data.bar instanceof Model).toBe true

	it "should auto-bind to data-text elements", ->
		view.helpers.rivets.bind()
		waits 1
		runs ->
			expect(spanText.text()).toBe data.get("text").get("foo")
			data.get("text").set foo: "bar"
		waits 1
		runs -> expect(spanText.text()).toBe data.get("text").get("foo")

#	it "should auto-bind to data-html elements" # TODO
#	it "should auto-bind to data-value elements" # TODO
#	it "should auto-bind to data-show elements" # TODO
#	it "should auto-bind to data-hide elements" # TODO
#	it "should auto-bind to data-enabled elements" # TODO
#	it "should auto-bind to data-disabled elements" # TODO
#	it "should auto-bind to data-checked elements" # TODO
#	it "should auto-bind to data-unchecked elements" # TODO
#	it "should auto-bind to data-[attribute] elements" # TODO
#	it "should auto-bind to data-class-[class] elements" # TODO
#	it "should auto-bind to data-on-[event] elements" # TODO
#	it "should auto-bind to data-each-[item] elements" # TODO

	it "should not bind to elements which a sub-elements of the attached view, but technically belong to a sub-view"
