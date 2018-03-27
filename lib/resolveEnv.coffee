Path = require 'path'
extend = require 'extend'
memoize = require 'fast-memoize'

resolveEnv = (composeFile)->
	dirname = Path.dirname(composeFile)
	dirname = Path.dirname(dirname) if composeFile.endsWith 'index.yml'
	
	extend {}, require('mountenv').get(dirname, expand:true), process.env


module.exports = if process.env.NO_MEMOIZE then resolveEnv else memoize(resolveEnv)