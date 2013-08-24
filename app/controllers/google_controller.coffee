request = require 'request'

module.exports = (app) ->
	class app.GoogleController

		# GET /auth/google/callback
		@authCallback = (req, res) ->
			authResult = req.body
			request.get {url: "https://www.googleapis.com/oauth2/v1/userinfo?access_token=#{authResult.access_token}", json:true}, (err, response, body) ->
				if err? then return res.send err
				console.log "user: #{body.email}"
				user = body
				user.gauth = authResult
				req.session.user = user
				res.send(body)
