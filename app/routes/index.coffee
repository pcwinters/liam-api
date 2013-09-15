module.exports = (app) ->
  # Index
  app.get '/', app.ApplicationController.index

  app.all '/*', app.ensureToken
  
  app.get '/mailbox', app.MailboxController.list
  app.get '/mailbox/:folder', app.MailboxController.messages

  # Error handling (No previous route found. Assuming it’s a 404)
  app.get '/*', (req, res) ->
    app.error.notFound(res)
