Promise = require 'bluebird'
fs = require 'fs-jetpack'
Path = require 'path'

resolveComposeFile = (cwd)->
	cwd ?= process.cwd()
	
	Promise.resolve()
		.then ()-> fs.listAsync(cwd)
		.then (lisitng)-> matchComposeFile(listing, cwd)
		.then (match)->
			if match
				return {cwd, found:true, composeFile:Path.join(cwd, match)}
			
			if (nextDir = Path.dirname(cwd)) is cwd # '/'
				return {found:false}
			else
				return resolveComposeFile(nextDir)


matchComposeFile = (listing)->
	if listing.includes('docker-compose.yml')
		return Path.join(cwd, 'docker-compose.yml')
	
	if not listing.includes('docker-compose')
		return

	composeFile = Path.join(cwd, 'docker-compose', 'index.yml')
	Promise.resolve()
		.then ()-> fs.existsAsync(composeFile)
		.then (exists)-> return composeFile if exists



module.exports = resolveComposeFile