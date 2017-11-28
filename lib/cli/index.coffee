Promise = require('bluebird').config(warnings:false, longStackTraces:false)
table = require './table'
args = require('minimist')(process.argv.slice(2))

isCommand = (target)-> switch target
	when 'help'
		((args.help or args.h) and args._.length is 0) or
		((args._[0] is 'help') and args._.length is 1) or
		(Object.keys(args).length is 1 and args._.length is 0)

	when 'services'
		args._.includes 'services'

	else false
		

switch
	when isCommand('help')
		Promise.resolve()
			.then ()-> require('../').command.silent ['help']
			.then (docs)-> console.log "#{docs}\n#{require './docs'}"
	
	when isCommand('services')
		Promise.resolve()
			.then ()-> require('../').services()
			.then (services)->
				if args.json then return console.dir services, colors:1, depth:99
				console.log table(services, ['NAME:nicename', 'ID:id', 'IMAGE:config.image', 'PORTS:config.ports'], [15, 14, 20, 20])

	else
		require('../').command process.argv.slice(2)