resolveFlags = (data)->
	Object.keys(data.services).forEach (name)->
		config = data.services[name]
		
		if config.production? then switch
			when config.production and process.env.NODE_ENV isnt 'production'
				return delete data.services[name]
		
			when not config.production and process.env.NODE_ENV is 'production'
				return delete data.services[name]

		if config.disabled
			return delete data.services[name]

		delete config.production
		delete config.disabled

	return data


module.exports = resolveFlags