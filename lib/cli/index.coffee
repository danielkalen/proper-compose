Promise = require('bluebird').config(warnings:false, longStackTraces:false)
table = require './table'
chalk = require 'chalk'
args = require './programArgs'
throttle = require 'sugar/function/throttle'
logUpdate = throttle require('log-update'), 100

isCommand = (target)-> switch target
	when 'help'
		((args.help) and args._.length is 0) or
		((args._[0] is 'help') and args._.length is 1) or
		(Object.keys(args).length is 1 and args._.length is 0)

	else args._[0] is target


switch
	when args.version
		Promise.resolve()
			.then ()-> require('../').command.silent ['-v']
			.then (version)-> console.log "
				proper-compose version #{require('../../package.json').version}
				#{version}
			"
	
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

	
	when isCommand('logs')
		logArgs = process.argv.slice(2)
		logArgs.splice 1, 0, '--tail=10'
		require('../').command logArgs
	

	when isCommand('reup')
		targets = args._.slice(1)
		require('../').reup args, targets...


	when isCommand('online')
		targets = args._.slice(1)
		Promise.resolve(targets)
			.map require('../').online
			.then (statuses)->
				if targets.length is 1
					console.log statuses[0]
				else
					for status,index in statuses
						console.log "#{targets[index]}: #{status}"


	when isCommand('status')
		Promise.resolve()
			.then ()-> require('../').status(args._.slice(1)...)
			.then (statuses)->
				if args.json then return console.dir statuses, colors:1, depth:99
				columns = ['NAME:name', 'STATUS:status', 'SINCE:duration.label', 'NOTES:notes']
				columnAliases = 'name':'rawname'
				statuses.forEach (status)->
					status.rawname = status.name
					status.name = switch status.status
						when 'online' then chalk.green(status.name)
						when 'paused' then chalk.yellow(status.name)
						when 'offline' then chalk.red(status.name)
					status.notes = switch
						when status.pending then 'restarting'
						when status.error then "(#{status.error.code}) #{status.error.message}"

				console.log table(statuses, columns, [], columnAliases)
	

	when isCommand('stats')
		Promise.resolve()
			.then ()-> require('../').services(onlyActive:true)
			.then (services)->
				columns = ['NAME:nicename', 'ID:id', 'CPU %:cpuPercent', 'RAM %:ramPercent', 'RAM USAGE:ramUsage', 'NET:netio', 'FS:fsio', 'PIDS:pids']
				columnWidths = [16, 14, 8, 8, 20, 20, 20, 6]
				columnAliases = 'nicename':'rawname'
				if args.simple
					table.removeColumn(columns, columnWidths, 1, 6, 7)
				
				require('../stats')(services).on 'update', (stats)->
					return console.log(JSON.stringify stats) if args.json
					stats.forEach (stat)->
						stat.rawname ?= stat.nicename
						stat.nicename = if stat.online then chalk.green(stat.nicename) else chalk.yellow(stat.nicename)
					
					unless args.all
						stats = stats.filter((stat)-> stat.online)
					
					stats = require('sugar/array/sortBy')(stats, 'name')
					logUpdate table(stats, columns, columnWidths, columnAliases)
	
	else
		require('../').command process.argv.slice(2)











