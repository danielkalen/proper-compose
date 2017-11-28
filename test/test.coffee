Promise = require('bluebird').config(warnings:false, longStackTraces:false)
fs = require 'fs-jetpack'
Path = require 'path'
helpers = require './helpers'
compose = require '../'
{expect} = require 'chai'
TEMP = Path.resolve 'test', 'temp'


suite "proper-compose", ()->
	suiteTeardown ()->
		fs.remove TEMP
	suiteSetup ()->
		process.env.COMPOSE_DIR = TEMP
		process.env.NO_MEMOIZE = TEMP
		fs.dir TEMP, empty:true


	suite "file type support", ()->
		suiteSetup ()->
			helpers.lib
				'standard/docker-compose.yml': """
					version: '3'
					services:
						abc:
							image: abc
						def:
							image: def
				"""
				'dir/docker-compose/index.yml': ['standard/docker-compose.yml']
		

		test "standard", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/standard"
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'standard_abc_1'
						id: undefined
						config: {image:'abc'}
					,
						name: 'standard_def_1'
						id: undefined
						config: {image:'def'}
					]

		test "directory-style", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/dir"
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'dir_abc_1'
						id: undefined
						config: {image:'abc'}
					,
						name: 'dir_def_1'
						id: undefined
						config: {image:'def'}
					]


	suite "imports", ()->
		suiteSetup ()->
			helpers.lib
				'imports/docker-compose/index.yml': """
					import './version'
					services:
						import './services'
				"""
				'imports/docker-compose/services.yml': """
					abc:
						image: abc
						import './nested/type'
					def:
						image: def
						import './nested/type'
				"""
				'imports/docker-compose/version.yml': """
					version: '3'
				"""
				'imports/docker-compose/nested/type.yml': """
					type: 123
				"""
		

		test "standard", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/imports"
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'imports_abc_1'
						id: undefined
						config: {image:'abc', type:123}
					,
						name: 'imports_def_1'
						id: undefined
						config: {image:'def', type:123}
					]


	suite "disabled flag", ()->
		suiteSetup ()->
			helpers.lib
				'disabled/docker-compose.yml': """
					version: '3'
					services:
						abc:
							image: abc
							disabled: False
						def:
							image: def
							disabled: True
						ghi:
							image: ghi
				"""
		

		test "should omit disabled services", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/disabled"
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'disabled_abc_1'
						id: undefined
						config: {image:'abc'}
					,
						name: 'disabled_ghi_1'
						id: undefined
						config: {image:'ghi'}
					]


	suite "production flag", ()->
		suiteSetup ()->
			helpers.lib
				'production/docker-compose.yml': """
					version: '3'
					services:
						abc:
							image: abc
							production: False
						def:
							image: def
							production: True
						ghi:
							image: ghi
				"""


		test "should omit services with 'true' production flags when in development", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/production"
			process.env.NODE_ENV = 'development'
			
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'production_abc_1'
						id: undefined
						config: {image:'abc'}
					,
						name: 'production_ghi_1'
						id: undefined
						config: {image:'ghi'}
					]


		test "should omit services with 'false' production flags when in production", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/production"
			process.env.NODE_ENV = 'production'
			
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'production_def_1'
						id: undefined
						config: {image:'def'}
					,
						name: 'production_ghi_1'
						id: undefined
						config: {image:'ghi'}
					]


	suite "js evaluation", ()->
		suiteSetup ()->
			helpers.lib
				'eval1/docker-compose.yml': """
					version: '3'
					services:
						abc:
							image: {{'abc'.toUpperCase()}}
				"""
				'eval2/docker-compose.yml': """
					version: '3'
					services:
						abc:
							image: {{ if ($IMAGE) {$IMAGE.toUpperCase()} else {'defaultImage'} }}
							meta: {{$META ? $META : 'no-meta'}}
				"""
				'eval3/docker-compose.yml': """
					version: '3'
					services:
						abc:
							image: {{
								if ($IMAGE) {
									$IMAGE
								} else {
									'defaultImage'
								}
							}}
				"""
				'eval4/docker-compose/index.yml': """
					version: '3'
					services:
						abc:
							image: abc
							{{if ($INCLUDE_EXTRA) `import './extra'`}}
						
						{{if ($INCLUDE_EXTRA) `import './def'`}}
				"""
				'eval4/docker-compose/extra.yml': """
					extra:
						image: {{$INCLUDE_EXTRA ? 'abc' : 'ABC'}}
						meta: 'ABC'
				"""
				'eval4/docker-compose/def.yml': """
					def:
						image: def
						meta: DEF
				"""


		test "should evaluate any expressions inside double curly braces {{}}", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/eval1"
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'eval1_abc_1'
						id: undefined
						config: {image:'ABC'}
					]

		
		test "env vars inside expressions can be accessed via $VAR syntax", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/eval2"
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'eval2_abc_1'
						id: undefined
						config: {image:'defaultImage', meta:'no-meta'}
					]
				.then ()->
					process.env.IMAGE = 'customImage'
					process.env.META = 'custom-meta'
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'eval2_abc_1'
						id: undefined
						config: {image:'CUSTOMIMAGE', meta:'custom-meta'}
					]


		test "multiline expression support", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/eval3"
			process.env.IMAGE = 'customImage'
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'eval3_abc_1'
						id: undefined
						config: {image:'customImage'}
					]


		test "can be mixed with imports", ()->
			process.env.COMPOSE_DIR = "#{TEMP}/eval4"
			Promise.resolve()
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'eval4_abc_1'
						id: undefined
						config: {image:'abc'}
					]
				.then ()-> process.env.INCLUDE_EXTRA = true
				.then ()-> compose.services()
				.then (result)->
					expect(result).to.eql [
						name: 'eval4_abc_1'
						id: undefined
						config: {image:'abc', extra:{image:'abc', meta:'ABC'}}
					,
						name: 'eval4_def_1'
						id: undefined
						config: {image:'def', meta:'DEF'}
					]




