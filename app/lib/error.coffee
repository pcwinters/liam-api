winston = require 'winston'

module.exports = (app) ->

	# Sets up a user object with middleware
	app.error = 
		unauthorized: (res) -> 
			winston.error "Unauthorized"
			res.send(401)
		general: (res) -> 
			winston.error "General"
			res.send(400)
		notFound: (res) ->
			winston.error "NotFound"
			res.send(404)
