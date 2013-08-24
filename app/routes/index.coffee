module.exports = (app) ->
  # Index
  app.get '/', app.ApplicationController.index
  app.post '/auth/google/callback', app.GoogleController.authCallback
  app.get '/mailbox', app.MailboxController.list

  # Error handling (No previous route found. Assuming it’s a 404)
  app.get '/*', (req, res) ->
    NotFound res


  NotFound = (res) ->
    res.render '404', status: 404, view: 'four-o-four'
