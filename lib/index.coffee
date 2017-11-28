Promise = require('bluebird').config(warnings:false, longStackTraces:false)
fs = require 'fs-jetpack'

exports.getFile = ()->
	require('./findComposeFile')(null, false)

exports.services = (onlyActive)->
	Promise.resolve()
		.then require './findComposeFile'
		.then ({cwd, composeFile})->
			Promise.resolve(composeFile)
				.then require './parseComposeFile'
				.then (parsed)-> require('./resolveServices')(parsed, composeFile)
				.then (services)->
					return services if not onlyActive
					services.filter (service)-> service.id

exports.stats = (cb)->
	Promise.resolve()
		.then ()-> exports.services(true)
		.then (services)->
			require('./stats')(services).on 'update', (stats)-> cb?(stats)


exports.command = require './command'



