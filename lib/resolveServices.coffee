Promise = require('bluebird').config warnings:false, longStackTraces:false
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
			config = data.services[name]
			name = config.container_name or "#{basename}_#{name}"
			{name, id} = resolveContainer(name, containers)
			return {name, id, config}


resolveBasename = (composeFile)->
	dirname = Path.dirname(composeFile)
	dirname = Path.dirname(dirname) if composeFile.endsWith 'index.yml'
	return Path.basename(dirname)

resolveContainer = (name, containers)->
	match = containers.find (container)-> matchName(name, container)
	if match
		return {id:match.Id, name:normalizeName(match.Names[0])}
	else
		return {id:null, name}


matchName = (name, container)->
	nameRegex = new RegExp "^#{name}_\\d+$"
	
	container.Names.some (candidate)->
		candidate = normalizeName(candidate)
		return candidate is name or nameRegex.test(candidate)

normalizeName = (name)->
	name = name.slice(1) if name[0] is '/'
	return name
