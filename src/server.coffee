#===============================================================================
# Vanilla Example - Node Server
#===============================================================================
# This is a simple "hello world" Node server.

#==============
# Modules
#==============
http = require "http"

#====================
# Server Definition
#====================
vanilla = (request, response) ->
  response.writeHead(200)
  response.write("Hello World.\n")
  response.end()


# Launch Server
http.createServer(vanilla).listen(80, () ->
  console.log "\nVanilla is online."
)
