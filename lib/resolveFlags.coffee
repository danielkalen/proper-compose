resolveFlags = (data)->
	allowed = require('./getAllowedServices')()
	
	Object.keys(data.services).forEach (name)->
		config = data.services[name]
		
		if config.production? then switch
			when config.production and process.env.NODE_ENV isnt 'production'
				delete data.services[name] unless allowed[name]
		
			when not config.production and process.env.NODE_ENV is 'production'
				delete data.services[name] unless allowed[name]

		if config.disabled
			delete data.services[name] unless allowed[name]

		delete config.production
		delete config.disabled

	return data



module.exports = resolveFlags