winston = require 'winston'

module.exports = (app) ->

	# Sets up a user object with middleware
	app.googleTokenMiddleware = (req, res, next) ->
		req.user = 
			google:
				access_token: req.header('token')
				email: req.header('email')
		winston.debug "Google authorization", {user: req.user}
		next()

	app.ensureToken = (req, res, next) ->
		if not req.user?.google?.access_token? or not req.user?.google?.email?
			return app.error.unauthorized(res)
		next()