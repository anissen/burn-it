# Set some globally accessible properties
properties =
  namespace: 'service'

# Internal variables
BurnModel = null
model = null
_ = null          # Underscore reference

# Experiment initialization
module.exports = (input) -> 
  properties.namespace = input.namespace               # Merge passed properties with built-in properties
  
  mongoose = require 'mongoose'
  mongoose.connect 'mongodb://localhost/test'

  # Declare schema for model
  Schema = mongoose.Schema
  BurnSchema = new Schema
    developer: 
      type: String
      required: true
      #unique: true
    availability:
      type: Number
      default: 1
    focus: Number
    burn: [Number]

  BurnModel = mongoose.model 'burn', BurnSchema

  # Configure routes
  input.burnApp.get "/#{properties.namespace}#{key}", route for key, route of getRoutes
  input.burnApp.post "/#{properties.namespace}#{key}", route for key, route of postRoutes
  input.burnApp.put "/#{properties.namespace}#{key}", route for key, route of putRoutes
  input.burnApp.delete "/#{properties.namespace}#{key}", route for key, route of deleteRoutes

  _ = input.underscore
  model = BurnModel #input.model

  # Return the namespace for use elsewhere
  properties

# Define routing information
getRoutes = 
  '' : (req, res) ->
    options = 
      title : 'Service API'
      css : []
      js : []
    
    res.render 'service', options

  '/burn' : (req, res) ->
    model.find (err, burn) ->
      if not err
        res.send burn
      else
        console.log "Error finding"
        console.log err

  '/burn/:id' : (req, res) -> 
    model.findById req.params.id, (err, burn) ->
      if not err
        res.send burn
      else
        console.log "Error finding by ID"
        console.log err

postRoutes = 
  '/burn' : (req, res) ->
    burn = undefined
    console.log "POST: "
    console.log req.body
    burn = new BurnModel(
      developer: req.body.developer
      availability: req.body.availability
      focus: req.body.focus
      burn: req.body.burn
    )
    burn.save (err) ->
      if not err
        console.log "Created"
      else
        console.log "Error creating"
        console.log err

    res.send burn

putRoutes =
  '/burn/:id' : (req, res) ->
    model.findById req.params.id, (err, burn) ->
      console.log "Attempting to update..."
      if err?
        console.log "Error finding entry to update"
        console.log err
        return
      console.log "Attempting to update 2..."
      burn.developer = req.body.developer
      burn.availability = req.body.availability
      burn.focus = req.body.focus
      burn.burn = req.body.burn
      burn.save (err) ->
        if not err
          console.log "Updated"
        else
          console.log "Error updating"
          console.log err
        res.send burn

deleteRoutes =
  '/burn/:id' : (req, res) ->
    model.findById req.params.id, (err, burn) ->
      if err
        console.log err
        return
      burn.remove (err) ->
        if not err
          console.log "Deleted"
        else
          console.log "Error deleting"
          console.log err