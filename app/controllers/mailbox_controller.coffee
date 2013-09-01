request = require 'request'
xoauth2 = require 'xoauth2'
_ = require 'underscore'
async = require 'async'
winston = require 'winston'

module.exports = (app) ->
	class app.MailboxController

		# TODO have an imap server factory helper method for connecting with google on app

		# GET /mailbox/:folder
		@messages = (req, res) ->
			app.imap.connect req, (err, imap) ->
				if err? then throw err
				folderName = req.params.folder
				imap.folders (err, folders) ->
					if err? then throw err
					folder = _.findWhere folders, {name:folderName}
					imap.messages folder.path, (err, messages) ->
						if err? then throw err
						res.json messages
						imap.end()



		# GET /mailbox
		@list = (req, res) ->
			app.imap.connect req, (err, imap) ->
				if err? then throw err
				imap.folders (err, folders) ->
					res.json folders
					imap.end()
