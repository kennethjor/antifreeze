_ = require "underscore"
sinon = require "sinon"
{Set} = require "../antifreeze"

describe "Set", ->
	it "should be empty when first created"
	it "should add new values given to it"
	it "should not accept the same value twice"
	it "should remove values"
	it "should accept initial array values"
	it "should accept initial Set values and make a copy"
	it "should accept initial Collection values, make a copy, and remove duplicates"
	it "should allow iteration"

	describe "change events", ->
		it "should trigger change events when adding an element"
		it "should not trigger change events when adding an element"
		it "should trigger change events when removing an element"

	describe "serialization", ->
		it "should serialize to a json array"
		it "should not recursively serialize models"
