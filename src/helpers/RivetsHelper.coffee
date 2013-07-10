# Add Rivets adapter to work with our models.
Rivets.configure
	adapter:
		subscribe: (obj, keypath, callback) ->
			#console.log "Rivets subscribe :: keypath: \"#{keypath}\" obj: \"#{obj}\""
			obj.on "change:" + keypath, ->
				val = obj.get keypath
				callback val
			return undefined
		unsubscribe: (obj, keypath, callback) ->
			#console.log "Rivets unsubscribe :: keypath: \"#{keypath}\" obj: \"#{obj}\""
			obj.off "change:" + keypath, callback
			return undefined
		read: (obj, keypath) ->
			#console.log "Rivets read :: keypath: \"#{keypath}\" obj: \"#{obj}\""
			return obj.get keypath
		publish: (obj, keypath, value) ->
			#console.log "Rivets publish :: keypath: \"#{keypath}\" obj: \"#{obj}\" value: \"#{value}\""
			obj.set keypath, value
			return undefined

RivetsHelper = Antifreeze.RivetsHelper =
	# Auto-discovers all relevant elements on the view and attaches the model to them via Rivets.
	bind: () ->
		view = @view
		convertData = @helper.convertData
		# Prepare data
		data = convertData view.model()
		# Bind.
		if @rivetsView
			@rivetsView.unbind()
		@rivetsView = Rivets.bind view.element(), data

	# Prepares the model data in a format consumable by Rivets.
	# For all references, Rivets requires the initial level to be a plain object, thus single-level references are not
	# possible.
	convertData: (model) ->
		throw new Error "Model must be a Model" unless model instanceof Model
		data = {}
		for k in model.keys()
			data[k] = model.get k
		return data
