module.exports = (services, options)->
	output = []

	for service in services
		if options.onlyActive
			continue if not service.id

		if options.targets?.length
			continue if not options.targets.includes(service.nicename)

		if not options.nicename
			delete service.nicename

		output.push service

	return output

