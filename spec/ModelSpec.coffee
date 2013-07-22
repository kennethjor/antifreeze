_ = require "underscore"
sinon = require "sinon"
{Model, Persistor} = require "../antifreeze"

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
			id: "id:42"
			foo: "foo"
			bar: "bar"
		expect(model.id()).toBe "id:42"
		expect(model.get "id").toBe undefined
		expect(model.get "foo").toBe "foo"
		expect(model.get "bar").toBe "bar"

	describe "default values", ->
		class Test extends Model
			defaults:
				foo: "FOO"
				bar: "BAR"

		it "should be applied when creating the model", ->
			model = new Test
			expect(model.get "foo").toBe "FOO"
			expect(model.get "bar").toBe "BAR"

		it "should be overridden by initially supplied values", ->
			model = new Test
				bar: "other"
			expect(model.get "foo").toBe "FOO"
			expect(model.get "bar").toBe "other"

	it "should copy values when setting a whole model", ->
		other = new Model
			id: "id:42"
			foo: "FOO"
		model.set other
		expect(model.id()).toBe other.id()
		expect(model.get "foo").toBe other.get "foo"

	it "should provide a list of keys", ->
		model = new Model
			foo: "FOO"
			bar: "BAR"
		keys = model.keys()
		expect(keys.length).toBe 2
		expect(_.contains(keys, "foo")).toBe true
		expect(_.contains(keys, "bar")).toBe true

	it "should provide an iteration function", ->
		model.set
			foo: "FOO"
			bar: "BAR"
		i = 0
		model.each (key, val) ->
			switch i
				when 0
					expect(key).toBe "foo"
					expect(val).toBe "FOO"
				when 1
					expect(key).toBe "bar"
					expect(val).toBe "BAR"
			i++
		expect(i).toBe 2

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

	describe "cloning", ->
		beforeEach ->
			model = new Model
				id: "id:42"
				foo: "Foo"
				bar: "Bar"

		it "should clone all values", ->
			clone = model.clone()
			expect(clone).not.toBe model
			expect(clone.id()).toBe model.id()
			expect(clone.get "foo").toBe model.get "foo"
			expect(clone.get "bar").toBe model.get "bar"

		it "should not recursively clone values", ->
			model2 = new Model x:1
			model.set model2: model2
			clone = model.clone()
			expect(clone.get "model2").toBe model2

		it "should accept a base model object and clone into that rather than creating a new one", ->
			base = new Model()
			clone = model.clone base
			expect(clone).toBe base
			expect(clone).not.toBe model
			expect(clone.id()).toBe model.id()
			expect(clone.get "foo").toBe model.get "foo"
			expect(clone.get "bar").toBe model.get "bar"

	describe "persistence", ->
		save = null
		done = null

		class TestPersistor extends Persistor
		class TestModel extends Model
			persistor: TestPersistor

		beforeEach ->
			save = sinon.spy (callback, model) -> callback()
			TestPersistor.prototype.save = save
			done = sinon.spy()

		it "should complain if not persistor is defined", ->
			test = ->
				model.save()
			expect(test).toThrow "Persistor not defined"

		it "should auto-construct the persistor, but keep a single instance around"

		it "should delegate to the defined persistor, executing the supplied callback when complete", ->
			model = new TestModel id: "id:42"
			model.save(done)
			waitsFor (-> done.called), "Done never called", 100
			runs ->
				expect(save.callCount).toBe 1
				call = save.getCall 0
				expect(call.args[1]).toBe model
