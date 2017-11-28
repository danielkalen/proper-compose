Promise = require 'bluebird'
fs = require 'fs-jetpack'
indentString = require 'indent-string'
Path = require 'path'
stringReplace = require 'string-replace-async'
resovleExpressions = require './resolveExpressions'
IMPORT_REGEX = require('./regex').import

resolveImports = (content, composeFile)->
	context = Path.dirname composeFile

	stringReplace content, IMPORT_REGEX, (e, whitespace, path)->
		path += '.yml' if not path.endsWith('.yml') and not path.endsWith('.yaml')
		path = Path.join(context, path)
		
		Promise.resolve()
			.then ()-> fs.readAsync path
			.then (childContent)-> resovleExpressions childContent, path
			.then (childContent)-> resolveImports childContent, path
			.then (result)-> indentString(result, 1, indent:whitespace)



module.exports = resolveImports