_ = require "underscore"
sinon = require "sinon"
{Map} = require "../antifreeze"

describe "Map", ->
	map = null
	change = null
	key1 = key:1
	val1 = val:1
	val2 = val:2

	beforeEach ->
		map = new Map
		change = sinon.spy()

	it "should be empty when first created", ->
		expect(map.size()).toBe 0

	it "should add new values", ->
		expect(map.put key1, val1).toBe null
		expect(map.size()).toBe 1

	it "should overwrite existing values and return the old value when doing so", ->
		map.put key1, val1
		# Existing value should not change anything.
		expect(map.put key1, val1).toBe null
		# New value should return old one.
		expect(map.put key1, val2).toBe val1
		# Check size.
		expect(map.size()).toBe 1

	it "should remove values", ->
		map.put key1, val1
		expect(map.remove key1).toBe val1

	it "should accept initial Map values and make a copy"
	it "should allow iteration"

	describe "change events", ->
		it "should trigger cahnge events when adding an element"
		it "should trigger change events when removing an element"

	describe "serialization", ->
		it "should serialize to a json object"
		it "should complain if key objects cannot convert to strings"
		it "should not recursively serialize models"
