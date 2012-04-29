# Set some globally accessible properties
properties =
	namespace: 'service'

# Internal variables
_ = null 					# Underscore reference

# Experiment initialization
module.exports = (input) -> 
	properties.namespace = input.namespace               # Merge passed properties with built-in properties
	
	# Configure routes
	input.burnApp.get "/#{properties.namespace}#{key}", route for key, route of routes

	_ = input.underscore

	# Return the namespace for use elsewhere
	properties

# Define routing information
routes = 
	'' : (req, res) ->
		options = 
			title : 'Service API'
			css : []
			js : []
		
		res.render 'service', options
	'/:stuffs' : (req, res) ->
		options = 
			title : 'stuff'
			css : []
			js : []
		
		res.render 'service', options