request = require 'request'
winston = require 'winston'
module.exports = class Google

	constructor: (@accessToken) ->


	identity: (callback) =>
		request.get {json:true, url: "https://www.googleapis.com/oauth2/v1/userinfo?access_token=#{@accessToken}"}, (err, response, user) ->
			if err? then callback err
			winston.debug "Google identity", {user}
			callback null, user

	contacts: (callback) =>
			request.get {json:true, url: "https://www.google.com/m8/feeds/contacts/default/full?alt=json&access_token=#{@accessToken}"}, (err, response, contacts) ->
				if err? then callback err
				entries = contacts.feed.entry
				callback null, {contacts: entries}
