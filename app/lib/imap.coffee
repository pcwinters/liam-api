_ = require 'underscore'
imap = require '../../lib/imap'
winston = require 'winston'

module.exports = (app) ->
	app.imap =

		connect: (req, callback) ->
			user = req.session.user
			gauth = user.gauth
			service = new imap(app.config.google)

			winston.debug "Imap connect factory", {user}
			service.connect user.email, gauth.access_token, (err, service) ->
				if err? 
					winston.error "Imap connect factory error", {err}
					callback err
				callback null, service
