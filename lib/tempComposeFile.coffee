Promise = require 'bluebird'
fs = require 'fs-jetpack'
Path = require 'path'

module.exports = (parsed)->
	targetPath = Path.join require('os').tmpdir(), "#{random()}.yml"
	
	Promise.resolve(parsed)
		.then require './encodeComposeFile'
		.then (encoded)-> fs.writeAsync targetPath, encoded
		.return targetPath


random = ()-> Math.floor((1+Math.random()) * 1000000).toString(16)