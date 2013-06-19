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
	"src/Route.coffee"
]

module.exports = (grunt) ->
	grunt.initConfig
		pkg: "<json:package.json>"

		coffee:
			# Compiles all files to check for compilation errors
			all:
				expand: true
				cwd: ""
				src: ["src/**/*.coffee", "spec/**/*.coffee"]
				dest: "build/"
				ext: ".js"

			# Compiles the framework into a single JS file with source map
			framework:
				files:
					"build/antifreeze.js": files
				options:
					join: true
					sourceMap: true

			# Compiles the sample code
			sample:
				files:
					"build/sample/sample.js": "sample/sample.coffee"
				options:
					sourceMap: true

		concat:
			# Packages the final JS file with a header
			dist:
				options:
					banner: "/*! <%= pkg.fullname %> <%= pkg.version %> - MIT license */\n"
					process: true
				src: ["build/antifreeze.js"]
				dest: "build/antifreeze.js"

		copy:
			# Copies the built dist file to the root for npm packaging
			dist:
				files:
					"antifreeze.js": "build/antifreeze.js"

			# Copies appropriate files needed for the sample
			sample:
				files: [
					{ expand: true, flatten: true, src: ["build/antifreeze.*"], dest: "build/sample/" }
					{ src: "sample/index.html", dest: "build/sample/index.html" }
					{ src: "node_modules/calamity/calamity.js", dest: "build/sample/calamity.js" }
					{ src: "node_modules/underscore/underscore.js", dest: "build/sample/underscore.js" }
					{ src: "node_modules/rivets/lib/rivets.js", dest: "build/sample/rivets.js" }
				]

		watch:
			files: ["src/**", "spec/**", "sample/**"]
			tasks: "default"

	# Load grunt plugins.
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-concat"
	grunt.loadNpmTasks "grunt-contrib-handlebars"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-less"
	grunt.loadNpmTasks "grunt-contrib-requirejs"
	grunt.loadNpmTasks "grunt-contrib-watch"
	#grunt.loadNpmTasks "grunt-notify"

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

	# Build sample site
	grunt.registerTask "sample", ["coffee:sample", "copy:sample"]

	# Default task.
	grunt.registerTask "default", [
		"coffee:all",
		"coffee:framework",
		"concat:dist",
		"jessie",
		"sample"
	]
