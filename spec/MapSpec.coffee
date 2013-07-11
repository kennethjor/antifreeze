_ = require "underscore"
sinon = require "sinon"
{Map} = require "../antifreeze"

describe "Map", ->
	it "should be empty when first created"
	it "should add new values"
	it "should overwrite existing values"
	it "should remove values"
	it "should accept initial Map values and make a copy"

	describe "change events", ->
		it "should trigger cahnge events when adding an element"
		it "should trigger change events when removing an element"
		it "should trigger change events on sub-models"
		it "should not trigger change events on detached sub-models"

	describe "serialization", ->
		it "should serialize to a json object"
		it "should complain if key objects cannot convert to strings"
		it "should not recursively serialize models"