module.exports = (app) ->
	# Helpers
	app.helpers = require "#{__dirname}/../app/helpers"

	# Controllers
	app.helpers.autoload "#{__dirname}/../app/controllers", app

	# App libs
	app.helpers.autoload "#{__dirname}/../app/lib", app
	
	config = () ->
		return require './default'

		# switch process.env.NODE_ENV
		#     when 'development':
		#         return {dev setting};

		#     case 'production':
		#         return {prod settings};

		#     default:
		#         return {error or other settings};

	app.config = config()
