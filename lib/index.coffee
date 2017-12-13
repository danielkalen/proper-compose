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
				.then (services)-> require('./filterServices')(services, options)


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

	stop = if options.force then 'kill' else 'stop'
	up = if options.daemon or options.silent then ['up','-d'] else ['up']
	command = if options.silent then exports.command.silent else exports.command
	
	Promise.resolve()
		.then ()-> command [stop].concat(targets)
		.then ()-> command [up...].concat(targets)


exports.status = (targets...)->
	Promise.resolve()
		.then ()-> exports.services({targets})
		.map (service)-> require('./getState')(service.id, service.nicename)


exports.online = (target)->
	Promise.resolve()
		.then ()-> exports.status(target)
		.then (result)-> result[0].status is 'online'


exports.command = require './command'



