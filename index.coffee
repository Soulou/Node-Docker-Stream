Writable = require('stream').Writable
require 'coffee-script'
express = require 'express'

app = express()
app.use express.bodyParser()
app.use require('connect-assets')()

http = require 'http'
server = http.createServer app
io = require('socket.io').listen server

docker = require('docker.io')({ socketPath: false, host: 'http://localhost', port: '4243'})

app.get '/', (req, res) ->
  docker.containers.list (err, containers) ->
    res.render 'index.jade', {container: containers[0].Id.substring(0, 10)}


streamToWebsocket = (stream, socket) ->
  stream._write = (chunk, enc, next) ->
    console.log chunk
    socket.emit 'logs', {data: chunk.toString()}
    next()

io.sockets.on 'connection', (s) ->
  docker.containers.list (err, containers) ->
    docker.containers.attach containers[0].Id, {stream:true, stderr: true, stdout: true, logs: true}, (err, attach) ->
      out = Writable() ; err = Writable()
      streamToWebsocket(out, s)
      streamToWebsocket(err, s)
      docker.demuxStream attach, out, err

server.listen(process.env.PORT || 3000)
