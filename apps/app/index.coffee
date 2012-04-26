# Set some globally accessible properties
properties =
	namespace: 'app'

# Internal variables
_ = null 					# Underscore reference

# Experiment initialization
module.exports = (input) -> 
	properties.namespace = input.namespace               # Merge passed properties with built-in properties
	
	# Configure routes
	input.burnApp.get "/#{properties.namespace}/#{key}", route for key, route of routes

	_ = input.underscore

	# Return the namespace for use elsewhere
	properties

# Define routing information
routes = 
	':appid?' : (req, res) ->
		options = 
			title : 'App'
			css : []
			js : []
		
		res.render 'app', options