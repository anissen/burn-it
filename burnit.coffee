
# Set up Express server
connectUtils = (require 'connect').utils
express      = require 'express'
underscore   = (require 'underscore')._

burnApp = express.createServer()

# Configuration
burnApp.configure ->
	burnApp.set 'views', "#{__dirname}/views"
	burnApp.set 'view engine', 'ejs'
	burnApp.use express.bodyParser()
	burnApp.use express.methodOverride()
	burnApp.use express.favicon()
	burnApp.use express.cookieParser()
	burnApp.use express.static "#{__dirname}/public"
	burnApp.use burnApp.router

# Environment-specific configuration
burnApp.configure 'development', ->
	burnApp.use express.errorHandler
		dumpExceptions: true
		showStack: true

burnApp.configure 'production', ->
	burnApp.use express.errorHandler()

# Static helpers - pre-populate css and js to avoid errors
burnApp.helpers
	css: []
	js:  []

# #######################
# Set up sockets
# #######################

###
sockets = (require 'socket.io').listen burnApp

# Configure for heroku
sockets.configure ->
	# Configure for heroku specifically, no websockets
	sockets.set 'transports', ['xhr-polling']
	sockets.set 'polling duration', 10
	sockets.set 'log level', 1
	sockets.set 'authorization', (handshakeData, callback) ->
		# If there is a cookie...
		if handshakeData.headers.cookie?
			sid = (connectUtils.parseCookie handshakeData.headers.cookie)[conf.session_config.key]
			conf.session_config.store.get sid, (err, session) ->
				handshakeData.readOnlySession = session ? {}
		callback null, true
###

# ###########################
# Set up apps with namespaces
# ###########################

# proposed apps:
# - service (API for post/get data)
# - app (uses the service to create/edit/delete data)
# - chart (uses the service to visualize data)

app = (require './apps/app')
	namespace: 'app'
	burnApp: burnApp
	underscore: underscore
	#socketio: sockets

service = (require './apps/service')
	namespace: 'service'
	burnApp: burnApp
	underscore: underscore

burnApp.get '/', (req, res) ->
	res.render 'index',
		title : 'Home'

# ###########################
# Launch server
# ###########################

burnApp.listen process.env.PORT or 3000
console.log "Server listening on port #{burnApp.address().port} in #{burnApp.settings.env} mode"
