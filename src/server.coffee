#===============================================================================
# Vanilla Example - Node Server
#===============================================================================
# This is a simple "hello world" Node server.
http = require "http"

vanilla = (request, response) ->
  response.writeHead(200)
  response.write("Hello World.\n")
  response.end()

# Launch Server
http.createServer(vanilla).listen 8080, () ->
  console.log "\nVanilla is online."
