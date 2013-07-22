_ = require "underscore"
sinon = require "sinon"
{Model} = require "../antifreeze"

describe "Model", ->
	model = null
	beforeEach ->
		model = new Model

	it "should be empty when first created", ->
		json = model.toJSON()
		expect(_.keys(json).join(",")).toEqual ""

	it "should set and get values", ->
		model.set "byString", "yes"
		model.set byObject: "also"
		model.set
			multiple: "awesome"
			values: "stuff"
		expect(model.get "byString").toBe "yes"
		expect(model.get "byObject").toBe "also"
		expect(model.get "multiple").toBe "awesome"
		expect(model.get "values").toBe "stuff"

	it "should accept initial values", ->
		model = new Model
			foo: "foo"
			bar: "bar"
		expect(model.get "foo").toBe "foo"
		expect(model.get "bar").toBe "bar"

	it "should accept default values", ->
		class Test extends Model
			defaults:
				foo: "foo"
				bar: "bar"
		model = new Test
			bar: "other"
		expect(model.get "foo").toBe "foo"
		expect(model.get "bar").toBe "other"

	it "should provide a list of keys", ->
		model = new Model
			foo: "FOO"
			bar: "BAR"
		keys = model.keys()
		expect(keys.length).toBe 2
		expect(_.contains(keys, "foo")).toBe true
		expect(_.contains(keys, "bar")).toBe true

	describe "change events", ->
		change = null
		changeEvent = null
		changeFoo = null
		changeFooEvent = null
		beforeEach ->
			# General change event.
			change = sinon.spy (event) -> changeEvent = event
			model.on "change", change
			changeEvent = null
			# Specific change event.
			changeFoo = sinon.spy (event) -> changeFooEvent = event
			model.on "change:foo", changeFoo
			changeFooEvent = null

		it "should should trigger specific and general change events with appropriate data", ->
			model.set foo: "bar"
			waitsFor (-> change.called and changeFoo.called), "Events not fired", 100
			runs ->
				expect(change.callCount).toBe 1
				expect(changeFoo.callCount).toBe 1
				expect(typeof changeEvent).toBe "object"
				expect(typeof changeFooEvent).toBe "object"
				expect(changeEvent.data.model).toBe model
				expect(changeFooEvent.data.model).toBe model
				expect(changeFooEvent.data.value).toBe "bar"

		it "should change all values before triggering events when multiple values are changed", ->
			model.set
				foo: "foo"
				bar: "bar"
			waitsFor (-> change.called), "Event not fired", 100
			runs ->
				expect(change.callCount).toBe 1

	describe "serialization", ->
		it "should serialize to a json object", ->
			model = new Model
				foo: "bar"
				abc: "def"
			json = model.toJSON()
			expect(json.foo).toBe "bar"
			expect(json.abc).toBe "def"

		it "should not recursively serialize models", ->
			model = new Model
				foo: "foo"
				bar: new Model
					qwerty: "zxcvbn"
			json = model.toJSON()
			expect(typeof json).toBe "object"
			expect(json.foo).toBe "foo"
			expect(json.bar instanceof Model).toBe true

		it "should serialize the explicitly set id value and ignore any values set with set()", ->
			model.set id: "invalid"
			expect(model.toJSON().id).toBe undefined
			model.id "valid"
			expect(model.toJSON().id).toBe "valid"
