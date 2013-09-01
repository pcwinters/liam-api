xoauth2 = require 'xoauth2'
Imap = require 'imap'
winston = require 'winston'
_ = require 'underscore'
async = require 'async'

module.exports = class ImapService

	###
	client
		clientId
		clientSecret
		
	###
	constructor: (@client) ->

	# Search through the mailboxes and find the path that has the given flag
	_findBoxWithFlag: (flag, boxes) ->

		_find = (box, path) ->
			if _.contains box.attribs, flag then return path
			if box.children?
				for name in _.keys box.children
					childBox = box.children[name]
					subPath = if path then "#{path}/#{name}" else name
					found = _find childBox, subPath 
					if found then return found

		# bootstrap the recursive search
		path = _find({
			attribs: []
			children: boxes
			}, '')

		return path

	folders: (callback) =>
		imap = @imap
		imap.getSubscribedBoxes (err, boxes) =>
			if err? then callback err
			folders = [
				{
					name: 'inbox'
					path: 'INBOX'
				},	
				{
					name: 'starred'
					path: @_findBoxWithFlag '\\Flagged', boxes
				},
				{
					name: 'sent'
					path: @_findBoxWithFlag '\\Sent', boxes
				},
				{
					name: 'drafts'
					path: @_findBoxWithFlag "\\Drafts", boxes
				}
			]
			setStatus = (folder, callback) ->

				imap.status folder.path, (err, status) -> 
					if err? then callback err
					folder.status = status
					callback()

			async.each folders, setStatus, (err) ->
				if err? then callback err
				callback null, folders


	connect: (user, accessToken, callback) =>
		winston.info "Connect", {user}

		# TODO figure out how much is necessary
		xoauth2gen = xoauth2.createXOAuth2Generator
			user: user
			accessToken: accessToken
			clientId: @client.clientId
			clientSecret: @client.clientSecret
			refreshToken: "{refresh token}"

		xoauth2gen.getToken (err, token) =>
			if err? then callback err
			
			imap = new Imap
				user: user
				xoauth2: token
				host: 'imap.gmail.com'
				port: 993
				tls: true
				tlsOptions: { rejectUnauthorized: false }
				keepalive: false

			@imap = imap

			imap.once 'ready', () =>
				winston.debug "Connect ready", {user}
				callback null, @

			imap.once 'error', (err) ->
				winston.error "Connect error", {err}
				callback err

			imap.connect()

	end: () =>
		@imap.end()


	# Open up a message's stream and read the body
	bodies: (message, callback) =>
		bodies = []
		message.on 'body', (stream, info) =>
			winston.debug "Body", {info}
			@stream stream, info, (err, data) ->
				winston.debug "Body data", {data}
				bodies.push data
		message.once 'error', (err) ->
			winston.error "Body error", {err}
			callback err
		message.once 'end', () ->
			winston.debug "Body end", {bodies}
			callback null, bodies


	# Collect a stream's data and callback with Imap.parseHeader
	stream: (stream, info, callback) =>
		winston.debug "Stream start"
		buffer = '';
		stream.on 'data', (chunk) ->
			winston.debug "Stream chunk"
			buffer += buffer += chunk.toString('utf8')
		stream.once 'error', (err) ->
			winston.error 'Stream error', {err}
			callback err
		stream.once 'end', () ->
			data = if info.which is 'TEXT' then {body:buffer} else {headers:Imap.parseHeader buffer}
			data.info = info
			winston.debug 'Stream end', {data}
			callback null, data

	message: (message, callback) =>
		m = {}

		@bodies message, (err, bodies) ->
			winston.debug "Message bodies", {bodies}
			m.bodies = bodies

		message.once 'attributes', (attributes) ->
			winston.debug "Message attributes", {attributes}
			m.attributes = attributes

		message.once 'end', () -> 
			winston.debug "Message end", {message:m}
			callback null, m
	
	messages: (folderPath, callback) =>
		bodies = 'HEADER.FIELDS (FROM TO SUBJECT DATE)'
		imap = @imap
		imap.openBox folderPath, (err, box) =>
			if err? then callback err

			fetch = imap.seq.fetch '1:25',
				bodies: bodies
				struct: true

			messages = []

			fetch.on 'message', (msg, seqno) =>
				winston.info 'Fetch:message', {msg, seqno}
				@message msg, (err, message) ->
					if err? then callback err
					headerBody = message.bodies[0] # We only have one body so just get it
					messages.push _.extend _.omit(message, 'bodies'), headerBody

			fetch.once 'error', (err) ->
				callback err

			fetch.once 'end', () ->
				winston.info "Done fetching", {messages: messages.length}
				callback null, messages
