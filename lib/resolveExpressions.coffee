Promise = require 'bluebird'
Path = require 'path'
vm = require 'vm'
EXPRESSION_REGEX = /\{\{([\w\W]+?)\}\}/g
ENV_VAR_REGEX = /\$(\w+)/g


resolveExpressions = (content, composeFile)->
	env = require('./resolveEnv')(composeFile)
	meta = {env, composeFile}
	
	content.replace EXPRESSION_REGEX, (e,expression)->
		expression = expression.replace ENV_VAR_REGEX, (e, variable)-> "env.#{variable}"
		result = runExpression(expression, meta)
		if result is undefined then '' else result


runExpression = (expression, {composeFile, env})->
	(new vm.Script expression, {filename:composeFile})
		.runInNewContext {env}


module.exports = resolveExpressions