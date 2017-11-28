Promise = require 'bluebird'
fs = require 'fs-jetpack'
Path = require 'path'

resolveComposeFile = (cwd, throwUnfound=true)->
	cwd ?= process.env.COMPOSE_DIR or process.cwd()
	
	Promise.resolve()
		.then ()-> fs.listAsync(cwd)
		.then (listing)-> matchComposeFile(listing, cwd)
		.then (composeFile)->
			if composeFile
				return {cwd, composeFile, found:true}
			
			if (nextDir = Path.dirname(cwd)) is cwd # '/'
				return {found:false}
			else
				return resolveComposeFile(nextDir, throwUnfound)

		.tap ({found})-> if not found and throwUnfound
			throw new Error "compose file not found"


matchComposeFile = (listing, cwd)->
	if listing.includes('docker-compose.yml')
		return Path.join(cwd, 'docker-compose.yml')
	
	if not listing.includes('docker-compose')
		return

	composeFile = Path.join(cwd, 'docker-compose', 'index.yml')
	Promise.resolve()
		.then ()-> fs.existsAsync(composeFile)
		.then (exists)-> return composeFile if exists



module.exports = resolveComposeFile