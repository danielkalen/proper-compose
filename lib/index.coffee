Promise = require('bluebird').config(warnings:false, longStackTraces:false)
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
				.then (parsed)-> require('./resolveServices')(parsed, composeFile)


exports.command = (args)->
	Promise.resolve()
		.then findComposeFile
		.tap (result)->
			result.env = require('./resolveEnv')(result.composeFile)
			Promise.resolve(result.composeFile)
				.then require './parseComposeFile'
				.then (parsed)-> result.parsed = parsed
				.return result
		
		.then ({cwd, env, composeFile, parsed})->
			Promise.resolve(parsed)
				.then require './tempComposeFile'
				.then (tempFile)->
					args = ['-f',tempFile,'--project-directory',cwd].concat(args)
					task = require('execa') compose, args, {cwd, env, stdio:'inherit'}
					
					Promise.resolve()
						.then ()-> require('p-event')(task, 'exit')
						.finally ()-> fs.removeAsync(tempFile)



