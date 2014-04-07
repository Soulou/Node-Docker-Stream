socket = io.connect 'http://localhost:3000'
socket.on 'logs', (data) ->
  logs = document.getElementById("logs")
  logs.innerHTML += data.data + "<br>"
