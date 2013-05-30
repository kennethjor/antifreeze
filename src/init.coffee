# Initialises the global object and ties into whatever loader is present.

# Import underscore if necessary.
if typeof _ is "undefined" and typeof require is "function"
	_ = require "underscore"

# Init main object.
Antifreeze = version: "<%= pkg.version %>"

root = this
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
