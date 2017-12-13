Promise = require 'bluebird'
docker = require 'docker-promise'

module.exports = (id, name)->
	return {status:'undefined', name} if not id
	
	Promise.resolve(id)
		.then docker.containerInspect
		.then ({State})->
			output = {name}
			output.status = switch
				when State.Running then 'online'
				when State.Restarting then 'online'
				when State.Paused then 'paused'
				when State.Dead then 'offline'
				when State.OOMKilled then 'offline'
				else 'offline'

			output.pending = true if State.Restarting
			if output.status is 'offline' and State.Error
				output.error = code:State.ExitCode, message:State.Error

			date = new Date(if output.status is 'online' then State.StartedAt else State.FinishedAt)
			output.duration =
				ms: Date.now() - date.valueOf()
				label: require('sugar/date/relative')(date)

			return output

