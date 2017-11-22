Path = require 'path'
extend = require 'extend'
memoize = require 'fast-memoize'

resolveEnv = (composeFile)->
	dirname = Path.dirname(composeFile)
	dirname = Path.dirname(dirname) if composeFile.endsWith 'index.yml'
	
	extend {}, process.env, require('mountenv').get(dirname)


module.exports = memoize(resolveEnv)