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


exports.reup = (args...)->
	if typeof args[0] is 'object'
		options = args[0]
		targets = args.slice(1)
	else
		options = {d:true}
		targets = args

	stop = if options.f or options.force then 'kill' else 'stop'
	up = if options.d then ['up','-d'] else ['up']
	
	Promise.resolve()
		.then ()-> require('./command') [stop].concat(targets)
		.then ()-> require('./command') [up...].concat(targets)


exports.command = require './command'



