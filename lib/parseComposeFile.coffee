Promise = require 'bluebird'
fs = require 'fs-jetpack'

parseComposeFile = (composeFile)->
	Promise.resolve()
		.then ()-> fs.readAsync composeFile
		.then (content)-> require('./resolveExpressions')(content, composeFile)
		.then (content)-> require('./resolveImports')(content, composeFile)
		.then (content)-> require('js-yaml').safeLoad content
		.then (data)-> require('./resolveFlags')(data, composeFile)




module.exports = parseComposeFile