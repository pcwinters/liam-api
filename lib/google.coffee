request = require 'request'
winston = require 'winston'
module.exports = class Google

	constructor: (@accessToken) ->


	identity: (callback) =>
		request.get {url: "https://www.googleapis.com/oauth2/v1/userinfo?access_token=#{@accessToken}", json:true}, (err, response, user) ->
			if err? then callback err
			winston.debug "Google identity", {user}
			callback null, user