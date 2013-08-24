request = require 'request'
xoauth2 = require 'xoauth2'
Imap = require 'imap'
_ = require 'underscore'

module.exports = (app) ->
	class app.MailboxController

		# GET /mailbox
		@list = (req, res) ->
			console.log 'mailbox'
			folder = req.body
			name = folder.name

			gauth = req.session.user.gauth


			xoauth2gen = xoauth2.createXOAuth2Generator
				user: req.session.user.email
				clientId: "1066133385516-fknpq8be830as60j87etq5vdujk0gv00.apps.googleusercontent.com"
				clientSecret: "d3PII-bfep_DZGgBDNALh2qb"
				refreshToken: "{User Refresh Token}"
				accessToken: gauth.access_token

			xoauth2gen.getToken (err, token) ->
				if err?
					console.log("err #{err}")
					res.send(err)
				console.log("AUTH XOAUTH2 #{token}")
				
				imap = new Imap
					user: req.session.user.email
					xoauth2: token
					host: 'imap.gmail.com'
					port: 993
					tls: true
					tlsOptions: { rejectUnauthorized: false }

				imap.once 'ready', () ->
					console.log 'ready'
					imap.getSubscribedBoxes (err, boxes) ->
						console.log "boxes err:#{err} boxes: #{boxes}"
						res.json _.keys(boxes)
				
				imap.once 'error', (err) ->
					console.log "connect error #{err}"
					res.send err

				imap.once 'end', () ->
					console.log "connect end #{err}"
					res.send 'end'

				imap.connect()
