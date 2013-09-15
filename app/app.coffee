# Modules
express = require 'express'
http = require 'http'
partials = require 'express-partials'
winston = require 'winston'
winston.remove winston.transports.Console
winston.add winston.transports.Console,
  level: 'debug'
  colorize: true
  json: true
  timestamp: false

expressWinston = require 'express-winston'
app = express()

MemoryStore = express.session.MemoryStore;

# Boot setup
require("#{__dirname}/../config/boot")(app)

# Configuration
app.configure ->
  port = process.env.PORT || 3000
  if process.argv.indexOf('-p') >= 0
    port = process.argv[process.argv.indexOf('-p') + 1]

  app.set 'port', port
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'ejs'
  app.use express.static("#{__dirname}/../public")
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.cookieSession
    secret: 'secret'
  # app.use express.session
  #   store: new MemoryStore()
  #   secret: 'secret'
  #   key: 'bla'
  app.use express.methodOverride()
  app.use partials()
  app.use require('connect-assets')(src: "#{__dirname}/assets")

  app.use expressWinston.logger
    transports: [winston.loggers.get('express')]
  app.use app.googleTokenMiddleware
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler()

# Routes
require("#{__dirname}/routes")(app)

module.exports = app
