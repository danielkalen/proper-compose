Promise = require 'bluebird'
fs = require 'fs-jetpack'
Path = require 'path'
stringReplace = require 'string-replace-async'
IMPORT_REGEX = require './importRegex'

parseComposeFile = (composeFile)->
	Promise.resolve()
		.then ()-> fs.readAsync composeFile
		.then (content)-> resolveImports(content, composeFile)
		.then (content)-> require('js-yaml').safeLoad content
		.then (data)-> require('./processComposeFile')(data, composeFile)


resolveImports = (content, composeFile)->
	context = Path.dirname composeFile
	
	stringReplace content, IMPORT_REGEX, (e, whitespace, path)->
		path += '.yml' if not path.endsWith('.yml') and not path.endsWith('.yaml')
		path = Path.join(context, path)
		
		Promise.resolve()
			.then ()-> fs.readAsync path
			.then (childContent)-> resolveImports childContent, path
			.then (result)->
				result
					.split '\n'
					.map (line)-> "#{whitespace}#{line}"
					.join '\n'


module.exports = parseComposeFile