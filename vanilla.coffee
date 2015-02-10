http = require "http"

server = (request, response) ->
  response.writeHead(200)
  response.write("Hello World.")
  response.end()

http.createServer(server).listen(80)
console.log "\nVanilla is online."
