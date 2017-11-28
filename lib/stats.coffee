EventEmitter = require 'events'
docker = require 'docker-promise'
throttle = require 'sugar/function/throttle'
bytes = require 'sugar/number/bytes'
formatNumber = require 'sugar/number/format'

class StatsWatcher extends EventEmitter
	constructor: (@config)->
		super
		@id = @config.id
		docker.stats @id, (data)=>
			@emit 'update', @formatData(data)

	formatData: (data)->
		output = Object.create(null)
		output.id = @id.slice(0,12)
		output.name = @config.nicename
		output.online = data.pids_stats.current?
		output.cpuPercent = cpuPercent(data)
		output.ramPercent = ramPercent(data)
		output.ramUsage = ramUsage(data)
		output.netio = netio(data)
		output.fsio = fsio(data)
		output.pids = data.pids_stats.current
		return output


watchStats = (services)->
	emitter = new EventEmitter
	stats = Object.create(null)

	services
		.filter (service)-> service.id
		.forEach (service)->
			watcher = new StatsWatcher(service)
			watcher.on 'update', (data)->
				stats[service.id] = data				
				emitter.emit 'update', stats

	return emitter


ramPercent = (stats)->
	used = stats.memory_stats.usage or 0
	total = stats.memory_stats.limit or 1
	percent = (used/total)*100
	return "#{formatNumber percent, 2}%"

ramUsage = (stats)->
	return "0 / 0" if not stats.memory_stats?.limit
	used = bytes stats.memory_stats.usage or 0,1
	total = bytes stats.memory_stats.limit or 0,1
	return "#{used} / #{total}"

netio = (stats)->
	return "0 / 0" if not stats.networks
	network = Object.keys(stats.networks)[0]
	input = bytes stats.networks[network].rx_bytes, 1
	output = bytes stats.networks[network].tx_bytes, 1
	return "#{input} / #{output}"

fsio = (stats)->
	return "0 / 0" if not stats.blkio_stats.io_service_bytes_recursive
	stats = stats.blkio_stats.io_service_bytes_recursive
	read = stats.find((entry)-> entry.op is 'Read')?.value or 0
	write = stats.find((entry)-> entry.op is 'Write')?.value or 0
	return "#{bytes read,1} / #{bytes write,1}"

cpuPercent = (stats)->
	percent = 0
	now = stats.cpu_stats
	old = stats.precpu_stats
	oldCpu = old.cpu_usage.total_usage
	oldSystem = old.system_cpu_usage
	cpuDelta = now.cpu_usage.total_usage - oldCpu
	systemDelta = now.system_cpu_usage - oldSystem
	
	if systemDelta > 0 and cpuDelta > 0
		percent = (cpuDelta/systemDelta) * now.cpu_usage.percpu_usage.length * 100

	return "#{formatNumber percent,2}%"


module.exports = watchStats