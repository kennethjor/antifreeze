exec = require("child_process").exec

files = [
	"src/init.coffee"
	"src/ObjectUtil.coffee"
	"src/Model.coffee"
	"src/Collection.coffee"
	"src/HelperBroker.coffee"
	"src/helpers/RivetsHelper.coffee"
	"src/View.coffee"
	"src/Presenter.coffee"
]

module.exports = (grunt) ->
	grunt.initConfig
		pkg: "<json:package.json>"

		coffee:
			all:
				expand: true
				cwd: ""
				src: ["src/**/*.coffee", "spec/**/*.coffee"]
				dest: "build/"
				ext: ".js"
			dist:
				files:
					"build/antifreeze.js": "build/antifreeze.coffee"

		concat:
			coffee:
				src: files
				dest: "build/antifreeze.coffee"
			dist:
				options:
					banner: "/*! <%= pkg.fullname %> <%= pkg.version %> - MIT license */\n"
					process: true
				src: ["build/antifreeze.js"]
				dest: "build/antifreeze.js"

		copy:
			dist:
				files:
					"antifreeze.js": "build/antifreeze.js"

		watch:
			files: ["src/**", "spec/**"]
			tasks: "default"

	# Load grunt plugins.
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-concat"
	grunt.loadNpmTasks "grunt-contrib-handlebars"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-less"
	grunt.loadNpmTasks "grunt-contrib-requirejs"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-notify"

	grunt.registerTask "jessie", "Runs Jasmine specs through Jessie.", ->
		done = @async()
		command = "./node_modules/jessie/bin/jessie build/spec"
		exec command, (err, stdout, stderr) ->
			console.log stdout
			if err
				grunt.warn err
				done false
			else
				done true

	# Default task.
	grunt.registerTask "default", [
		"coffee:all",
		"concat:coffee",
		"coffee:dist",
		"concat:dist",
		"coffee:dist",
		"jessie"
	]
