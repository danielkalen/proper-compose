Promise = require 'bluebird'
Path = require 'path'
fs = require 'fs-jetpack'
extend = require 'extend'
dotenv = require 'dotenv'
isInProduction = process.env.NODE_ENV is 'production'

module.exports = (composeFile)->
	envFiles = resolveEnvFilePaths(composeFile)
	shellEnv = extend {}, process.env

	Promise.resolve(envFiles)
		.mapSeries resolveEnvFile
		.reduce((total, env)->
			extend total, env
		, shellEnv)
	

resolveEnvFile = (envFile)->
	Promise.resolve()
		.then ()-> fs.readAsync envFile
		.then (content)-> dotenv.parse content


resolveEnvFilePaths = (composeFile)->
	dirname = Path.dirname(composeFile)
	dirname = Path.dirname(dirname) if composeFile.endsWith 'index.yml'
	baseFile = Path.join(dirname, '.env')
	output = []

	output.push(baseFile) if fs.exists(baseFile)
	output.push("#{baseFile}.prod") if fs.exists("#{baseFile}.prod") and isInProduction
	output.push("#{baseFile}.dev") if fs.exists("#{baseFile}.dev") and not isInProduction

	return output

