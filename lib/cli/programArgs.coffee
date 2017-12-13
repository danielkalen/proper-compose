args = require('minimist')(process.argv.slice(2))
options = [
	['a','all']
	['s','simple']
	['s','silent']
	['f','force']
	['d','daemon']
	['j','json']
	['v','version']
	['h','help']
]

for [alias,option] in options
	if args[option] or args[alias]
		args[option] = args[alias] = args[option] or args[alias]


module.exports = args