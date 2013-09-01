_ = require 'underscore'
Google = require '../../lib/google'

module.exports = (app) ->
	class app.GoogleController

		# Get /auth/identity
		@identity = (req, res) ->
			app.google.factory req, (err, google) ->
				if err? then return res.json null
				google.identity (err, user) ->
					if err? then throw err
					res.json user


		# GET /auth/google/callback
		@authCallback = (req, res) ->
			authResult = req.body
			google = new Google(authResult.access_token)
			if err? then throw err
			google.identity (err, user) ->
				if err? then throw err
				safeUser = _.clone user
				user.gauth = authResult
				req.session.user = user
				res.json(safeUser)
