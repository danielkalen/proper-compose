Promise = require 'bluebird'
fs = require 'fs-jetpack'
compose = require('which').sync 'docker-compose'

findComposeFile = ()->
	Promise.resolve()
		.then require './findComposeFile'
		.tap ({found})-> throw new Error "compose file not found" if not found

exports.getFile = ()->
	require './findComposeFile'

exports.services = ()->
	Promise.resolve()
		.then findComposeFile
		.then ({cwd, composeFile})->
			Promise.resolve(composeFile)
				.then require './parseComposeFile'
				.then (parsed)-> Object.keys(parsed.services)


exports.command = (args)->
	Promise.resolve()
		.then findComposeFile
		.tap (result={composeFile})->
			Promise.resolve(composeFile)
				.then require './parseComposeFile'
				.then (parsed)-> result.parsed = parsed
				.return result
		
		.then ({cwd, composeFile, parsed})->
			Promise.resolve(parsed)
				.then require './tempComposeFile'
				.then (tempFile)->
					args = args.concat ['-f',tempFile]
					task = require('execa') compose, args, {cwd, stdio:'inherit'}
					
					Promise.resolve()
						.then ()-> require('p-event')(task, 'exit')
						.finally ()-> fs.removeAsync(tempFile)


