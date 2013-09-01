_ = require 'underscore'
imap = require '../../lib/imap'

module.exports = (app) ->
	app.imap =

		connect: (req, callback) ->
			user = req.session.user
			gauth = user.gauth
			service = new imap(app.config.google)
			service.connect user.email, gauth.access_token, (err, service) ->
				if err? then callback err
				callback null, service
