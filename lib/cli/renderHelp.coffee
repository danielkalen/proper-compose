Promise = require 'bluebird'

module.exports = ()->
	Promise.resolve()
		.then ()-> require('../').command.silent ['help']
		.then (docs)-> console.log "#{docs}\n#{require './docs'}"