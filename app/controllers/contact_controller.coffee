_ = require 'underscore'
Google = require '../../lib/google'

module.exports = (app) ->
	class app.ContactController

		# Get /auth/identity
		@contacts = (req, res) ->
			app.google.factory req, (err, google) ->
				if err? then return res.json null
				google.contacts (err, contacts) ->
					if err? then throw err
					res.json contacts
