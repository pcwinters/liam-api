path = require 'path'

module.exports = (grunt) ->
	grunt.loadNpmTasks 'grunt-express'
	grunt.loadNpmTasks 'grunt-contrib-watch'

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'

		express:
			server:
				options:
					hostname: 'localhost'
					port: 3000
					server: path.resolve(__dirname, 'app/app.coffee')

		watch:
			src:
				files: ['**/*.coffee']
				tasks: ['express-restart']


	grunt.registerTask 'default', ['express', 'watch']
