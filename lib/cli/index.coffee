Promise = require('bluebird').config(warnings:false, longStackTraces:false)
table = require './table'
chalk = require 'chalk'
args = require('minimist')(process.argv.slice(2))
throttle = require 'sugar/function/throttle'
logUpdate = throttle require('log-update'), 100

isCommand = (target)-> switch target
	when 'help'
		((args.help or args.h) and args._.length is 0) or
		((args._[0] is 'help') and args._.length is 1) or
		(Object.keys(args).length is 1 and args._.length is 0)

	else args._[0] is target



switch
	when isCommand('help')
		require('./renderHelp')()
	
	
	when isCommand('services')
		Promise.resolve()
			.then ()-> require('../').services()
			.then (services)->
				if args.json then return console.dir services, colors:1, depth:99
				console.log table(services, ['NAME:nicename', 'ID:id', 'IMAGE:config.image', 'PORTS:config.ports'], [15, 14, 20, 20])
	
	when isCommand('enter')
		return require('./renderHelp')() if not args._[1]?
		require('../').command ['exec', args._[1], 'bash']


	
	when isCommand('stats')
		Promise.resolve()
			.then ()-> require('../').services(onlyActive:true)
			.then (services)->
				columns = ['NAME:nicename', 'ID:id', 'CPU %:cpuPercent', 'RAM %:ramPercent', 'RAM USAGE:ramUsage', 'NET:netio', 'FS:fsio', 'PIDS:pids']
				columnWidths = [16, 14, 8, 8, 20, 20, 20, 6]
				if args.simple or args.s
					table.removeColumn(columns, columnWidths, 1, 6, 7)
				
				require('../stats')(services).on 'update', (stats)->
					return console.log(JSON.stringify stats) if args.json
					stats.forEach (stat)->
						stat.rawname ?= stat.nicename
						stat.nicename = if stat.online then chalk.green(stat.nicename) else chalk.yellow(stat.nicename)
					
					unless args.a or args.all
						stats = stats.filter((stat)-> stat.online)
					
					stats = require('sugar/array/sortBy')(stats, 'name')
					logUpdate table(stats, columns, columnWidths)
	
	else
		require('../').command process.argv.slice(2)