Promise = require 'bluebird'
Path = require 'path'
vm = require 'vm'
isInProduction = process.env.NODE_ENV is 'production'
EXPRESSION_REGEX = /\{\{(.+?)\}\}/g
ENV_VAR_REGEX = /\$(\w+)/g


module.exports = (data, composeFile)->
	env = require('./resolveEnv')(composeFile)
	meta = {env, composeFile}
	
	Object.keys(data.services).forEach (name)->
		config = data.services[name]
		
		if config.production? then switch
			when config.production and not isInProduction
				return delete data.services[name]
			when not config.production and isInProduction
				return delete data.services[name]

		if config.disabled
			return delete data.services[name]

		data.services[name] = resolveExpressions(config, meta)

	return data



resolveExpressions = (config, meta)->
	switch
		when Array.isArray(config)
			config.map (item)-> resolveExpressions(item, meta)
		
		when typeof config is 'object'
			output = {}
			output[key] = resolveExpressions(value, meta) for key,value of config
			return output
		
		when typeof config is 'number'
			return config
		
		when typeof config is 'string'
			return runAllExpressions(config, meta)
		
		else config


runAllExpressions = (string, meta)->
	string.replace EXPRESSION_REGEX, (e,expression)->
		expression = expression.replace ENV_VAR_REGEX, (e, variable)-> "env.#{variable}"
		runExpression(expression, meta)

runExpression = (expression, {composeFile, env})->
	(new vm.Script expression, {filename:composeFile})
		.runInNewContext {env}

