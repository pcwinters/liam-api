_ = require 'underscore'
imap = require '../../lib/imap'
winston = require 'winston'

module.exports = (app) ->
	app.imap =

		# Create an instance of the imap service and connect using request credentials.
		connect: (req, callback) ->
			google = req.user.google
			service = new imap(app.config.google)

			winston.debug "Imap connect factory", {google}
			service.connect google.email, google.access_token, (err, service) ->
				if err? 
					winston.error "Imap connect factory error", {err}
					callback err
				callback null, service
