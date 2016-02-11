# Require the dependencies
fs = require 'fs'
util = require 'util'
domain = require 'domain'
restify = require 'restify'
{resolve} = require 'path'
{spawn} = require 'child_process'
socketio = require 'socket.io'

# Require the marko adapter
require('marko/node-require').install();

# Activate the domain
d = domain.create()
d.on 'error', (error) -> console.log error

# Create the web server and use middleware
server = restify.createServer name: 'Fidelius'
server.use restify.bodyParser()
server.pre restify.pre.sanitizePath()
server.use restify.CORS()
server.use restify.fullResponse()

io = socketio.listen server.server

# Serve widgets
server.get '/', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "text/html"}
	template = resolve 'admin', 'template.marko'
	view  = require template
	view.render {}, rs

server.get '/js', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "application/javascript"}
	file = fs.createReadStream resolve 'admin', 'index.js'
	file.pipe rs

server.get '/css', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "text/css"}
	file = fs.createReadStream resolve 'admin', 'styles.css'
	file.pipe rs

# Serve widgets
server.get '/dashboards', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "text/html"}
	template = resolve 'dashboard', 'template.marko'
	view  = require template
	view.render {}, rs

server.get '/dashboards/js', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "application/javascript"}
	file = fs.createReadStream resolve 'dashboard', 'index.js'
	file.pipe rs

server.get '/dashboards/css', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "text/css"}
	file = fs.createReadStream resolve 'dashboard', 'styles.css'
	file.pipe rs

# Serve widgets
server.get '/cockpit', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "text/html"}
	template = resolve 'cockpit', 'template.marko'
	view  = require template
	view.render {}, rs

server.get '/cockpit/js', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "application/javascript"}
	file = fs.createReadStream resolve 'cockpit', 'index.js'
	file.pipe rs

server.get '/cockpit/css', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "text/css"}
	file = fs.createReadStream resolve 'cockpit', 'styles.css'
	file.pipe rs

# Adapter setup here
# Placeholder
# Placeholder

# After each operation, log if there was an error
server.on 'after', (req, res, route, error) ->
	console.log "======= After call ======="
	console.log "Error: #{error}"
	console.log "=========================="

# Run the server under an active domain
d.run ->
	# Log when the web server starts up
	server.listen 8001, -> console.log "#{server.name}[#{process.pid}] online: #{server.url}"
	console.log "#{server.name} is starting..."