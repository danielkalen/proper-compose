Promise = require('bluebird').config(warnings:false, longStackTraces:false)
fs = require 'fs-jetpack'

exports.getFile = ()->
	require('./findComposeFile')(null, false)

exports.services = (options={})->
	options.nicename ?= true
	
	Promise.resolve()
		.then require './findComposeFile'
		.then ({cwd, composeFile})->
			Promise.resolve(composeFile)
				.then require './parseComposeFile'
				.then (parsed)-> require('./resolveServices')(parsed, composeFile)
				.then (services)->
					services.forEach((service)-> delete service.nicename) if not options.nicename
					services = services.filter((service)-> service.id) if options.onlyActive
					return services


exports.stats = (cb)->
	Promise.resolve()
		.then ()-> exports.services(onlyActive:true)
		.then (services)->
			require('./stats')(services).on 'update', (stats)-> cb?(stats)


exports.command = require './command'



