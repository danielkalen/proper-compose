Promise = require('bluebird').config(warnings:false, longStackTraces:false)
fs = require 'fs-jetpack'

exports.getFile = ()->
	require('./findComposeFile')(null, false)

exports.services = ()->
	Promise.resolve()
		.then require './findComposeFile'
		.then ({cwd, composeFile})->
			Promise.resolve(composeFile)
				.then require './parseComposeFile'
				.then (parsed)-> require('./resolveServices')(parsed, composeFile)


exports.command = require './command'



