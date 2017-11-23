Promise = require 'bluebird'
Path = require 'path'
vm = require 'vm'
indentString = require 'indent-string'
EXPRESSION_REGEX = require('./regex').expression
ENV_VAR_REGEX = require('./regex').env_var


resolveExpressions = (content, composeFile)->
	env = require('./resolveEnv')(composeFile)
	meta = {env, composeFile}
	
	content.replace EXPRESSION_REGEX, (e,whitespace,expression)->
		expression = expression.replace ENV_VAR_REGEX, (e, variable)-> "env.#{variable}"
		result = runExpression(expression, meta)
		result = if result is undefined then '' else result
		result = indentString(result,1,whitespace) if typeof result is 'string'
		return result


runExpression = (expression, {composeFile, env})->
	(new vm.Script expression, {filename:composeFile})
		.runInNewContext {env}


module.exports = resolveExpressions