Promise = require 'bluebird'
Path = require 'path'

module.exports = (parsed, composeFile)->
	basename = resolveBasename(composeFile)
	serviceNames = Object.keys(data.services)
	
	Promise.map Object.keys(data.services), (name)->
		config = data.services[name]
		name = config.container_name or "#{basename}_#{name}_1"
		
		Promise.resolve(name)
			.then getID
			.then (id)-> {name, id, config}


getID = (name)->
	require('execa') 'docker', ['ps', '-a', '-q', '-f', "name=#{name}"]

resolveBasename = (composeFile)->
	dirname = Path.dirname(composeFile)
	dirname = Path.dirname(dirname) if composeFile.endsWith 'index.yml'
	return Path.basename(dirname)

