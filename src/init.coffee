# Initialises the global object and ties into whatever loader is present.

root = this

# Load required libs which may or may not be already defined.
if typeof require is "function"
	_ = require "underscore"
	Calamity = require "calamity"
	Rivets = require "rivets"
else
	# Underscore.
	unless typeof root._ is "function"
		throw new Error "Failed to load underscore from global namespace"
	_ = root._
	# Calamity
	unless typeof root.Calamity is "object"
		throw new Error "Failed to load Calamity from global namespace"
	Calamity = root.Calamity
	# Rivets
	unless typeof root.rivets is "object"
		throw new Error "Failed to load Rivets from global namespace"
	Rivets = root.rivets

# Import underscore if necessary.
if typeof root._ is "undefined" and typeof require is "function"
	_ = require "underscore"
# Import calamity if necessary.
if typeof root.Calamity is "undefined" and typeof require is "function"
	Calamity = require "calamity"

# Init main object.
Antifreeze = version: "<%= pkg.version %>"

# CommonJS
if typeof exports isnt "undefined"
	exports = Antifreeze
else if typeof module isnt "undefined" and module.exports
	module.exports = Antifreeze
# AMD
else if typeof define is "function" and define.amd
	define ["antifreeze"], Antifreeze
# Browser
else
	root["Antifreeze"] = Antifreeze
