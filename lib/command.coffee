Promise = require('bluebird')
fs = require 'fs-jetpack'
compose = require('which').sync 'docker-compose'


prerequesites = ()->
	Promise.resolve()
		.then require './findComposeFile'
		.tap (result)->
			result.env = require('./resolveEnv')(result.composeFile)
			Promise.resolve(result.composeFile)
				.then require './parseComposeFile'
				.then (parsed)-> result.parsed = parsed
				.return result

command = (args)->
	Promise.resolve()
		.then prerequesites
		.then ({cwd, env, composeFile, parsed})->
			Promise.resolve(parsed)
				.then require './tempComposeFile'
				.then (tempFile)->
					args = ['-f',tempFile,'--project-directory',cwd].concat(args)
					task = require('execa') compose, args, {cwd, env, stdio:'inherit'}
					
					Promise.resolve()
						.then ()-> require('p-event')(task, 'exit')
						.finally ()-> fs.removeAsync(tempFile)


silentCommand = (args)->
	Promise.resolve()
		.then prerequesites
		.then ({cwd, env, composeFile, parsed})->
			Promise.resolve(parsed)
				.then require './tempComposeFile'
				.then (tempFile)->
					args = ['-f',tempFile,'--project-directory',cwd].concat(args)
					task = require('execa') compose, args, {cwd, env}
					
					Promise.resolve(task)
						.finally ()-> fs.removeAsync(tempFile)
						.then (result)-> "#{result.stderr}\n#{result.stdout}"



module.exports = command
module.exports.silent = silentCommand