Google = require '../../lib/google'

module.exports = (app) ->
	app.google =
		factory: (req, callback) ->
			accessToken = req.session?.user?.gauth?.access_token
			if not accessToken? 
				callback "No access token"
			else
				callback null, new Google(accessToken)
