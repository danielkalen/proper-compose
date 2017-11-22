Promise = require 'bluebird'
Path = require 'path'
fs = require 'fs-jetpack'
convertToSpaces = require 'convert-to-spaces'


exports.lib = (dest, files)->
	if dest and not files
		files = dest
		dest = Path.resolve 'test','temp'
	
	Promise.resolve(Object.keys(files))
		.map (fileName)->
			content = files[fileName]
			
			if Array.isArray(content)
				config = content
				content = files[config[0]]
				content = config[1](content) if config.length > 1
			
			content = convertToSpaces(content) if fileName.endsWith '.yml'
			
			fs.writeAsync Path.join(dest, fileName), content
		
		.return(dest)




