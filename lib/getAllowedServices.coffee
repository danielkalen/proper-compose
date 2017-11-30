module.exports = ()->
	output = Object.create(null)
	allowed = process.env.ALLOWED or ''
	allowed = allowed.split /,\s*/

	for item in allowed
		output[item] = 1

	return output