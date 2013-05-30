Antifreeze.Collection = class Collection
	toJSON: ->
		json = super
		for own val, key of json
			if val instanceof Model or val instanceof Collection
				json[key] = val.toJSON()
		return json
