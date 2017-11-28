Promise = require('bluebird').config(warnings:false, longStackTraces:false)
table = require './table'
chalk = require 'chalk'
args = require('minimist')(process.argv.slice(2))
throttle = require 'sugar/function/throttle'
values = require 'sugar/object/values'

isCommand = (target)-> switch target
	when 'help'
		((args.help or args.h) and args._.length is 0) or
		((args._[0] is 'help') and args._.length is 1) or
		(Object.keys(args).length is 1 and args._.length is 0)

	when 'services'
		args._.includes 'services'
	
	when 'stats'
		args._.includes 'stats'

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

	
	when isCommand('stats')
		Promise.resolve()
			.then ()-> require('../').services(true)
			.then (services)->
				logUpdate = require 'log-update'
				columns = ['NAME:name', 'ID:id', 'CPU %:cpuPercent', 'RAM %:ramPercent', 'RAM USAGE:ramUsage', 'NET:netio', 'FS:fsio', 'PIDS:pids']
				columnWidths = [13, 14, 8, 8, 20, 20, 20, 6]
				require('../stats')(services).on 'update', (stats)->
					stats = values(stats)
					stats.forEach (stat)-> stat.name = if stat.online then chalk.green(stat.name) else chalk.yellow(stat.name)
					if args.a or args.all
						stats = require('sugar/array/sortBy')(stats, 'online', true)
					else
						stats = stats.filter((stat)-> stat.online)
					logUpdate table(stats, columns, columnWidths)
	
	else
		require('../').command process.argv.slice(2)