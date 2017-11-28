Promise = require('bluebird')
Path = require 'path'
docker = require 'docker-promise'

module.exports = (data, composeFile)->
	basename = resolveBasename(composeFile)
	serviceNames = Object.keys(data.services)
	containers = null
	
	Promise.resolve()
		.then docker.containers
		.then (result)-> containers = result
		.return Object.keys(data.services)
		.map (name)->
			nicename = name
			config = data.services[name]
			name = config.container_name or "#{basename}_#{name}"
			{name, id} = resolveContainer(name, config, containers)
			return {name, nicename, id, config}


resolveBasename = (composeFile)->
	dirname = Path.dirname(composeFile)
	dirname = Path.dirname(dirname) if composeFile.endsWith 'index.yml'
	return Path.basename(dirname)

resolveContainer = (name, config, containers)->
	match = containers.find (container)-> matchName(name, container)
	output = {}
	if match
		output.id = match.Id
		output.name = normalizeName(match.Names[0])
	else
		output.name = config.container_name or "#{name}_1"
	return output


matchName = (name, container)->
	nameRegex = new RegExp "^#{name}_\\d+$"
	
	container.Names.some (candidate)->
		candidate = normalizeName(candidate)
		return candidate is name or nameRegex.test(candidate)

normalizeName = (name)->
	name = name.slice(1) if name[0] is '/'
	return name
