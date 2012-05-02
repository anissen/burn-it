# Set some globally accessible properties
properties =
  namespace: 'service'

# Internal variables
SprintModel = null
SprintSchema = null
SprintDaySchema = null
DeveloperBurndownSchema = null
_ = null          # Underscore reference

# Experiment initialization
module.exports = (input) -> 
  properties.namespace = input.namespace               # Merge passed properties with built-in properties
  
  mongoose = require 'mongoose'
  mongoose.connect 'mongodb://localhost/burn'

  # Declare schema for model
  Schema = mongoose.Schema
  
  SprintSchema = new Schema
    startWeek: 
      type: Number
      required: true
    year:
      type: Number
      required: true
    duration:
      type: Number
      default: 2
    description: String
    days: [SprintDaySchema]

  SprintDaySchema = new Schema
    day: Number
    comment: String
    developerBurndown: [DeveloperBurndownSchema]

  DeveloperBurndownSchema = new Schema
    developer: 
      type: String
      required: true
      unique: true
    availability:
      type: Number
      default: 1
    focus: Number
    burndown: [Number]

  SprintModel = mongoose.model 'sprints', SprintSchema

  # Configure routes
  input.burnApp.get "/#{properties.namespace}#{key}", route for key, route of getRoutes
  input.burnApp.post "/#{properties.namespace}#{key}", route for key, route of postRoutes
  input.burnApp.put "/#{properties.namespace}#{key}", route for key, route of putRoutes
  input.burnApp.delete "/#{properties.namespace}#{key}", route for key, route of deleteRoutes

  _ = input.underscore

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

  '/sprint' : (req, res) ->
    SprintModel.find (err, sprint) ->
      if not err
        res.send sprint
      else
        console.log "Error finding"
        console.log err

  '/sprint/:id' : (req, res) -> 
    SprintModel.findById req.params.id, (err, sprint) ->
      if not err
        res.send sprint
      else
        console.log "Error finding by ID"
        console.log err
  ###
  '/sprint/:year/:week/add' : (req, res) -> 
    SprintModel.findById req.params.id, (err, sprint) ->
      if not err
        res.send sprint
      else
        console.log "Error finding by ID"
        console.log err
  ###

postRoutes = 
  '/sprint' : (req, res) ->
    sprint = undefined
    console.log "POST: "
    console.log req.body
    sprint = new SprintModel(
      startWeek: req.body.startWeek
      year: req.body.year
      days: req.body.days
    )
    sprint.save (err) ->
      if not err
        console.log "Created"
      else
        console.log "Error creating"
        console.log err

    res.send sprint

  ###
  jQuery.post("/service/sprint/2012/18/add-day", {
    "day": {
      "day": "1",
      "comment": "Nothing special",
      "developerBurndown": [{
        "developer": "ANNI",
        "focus": "5",
        "burndown": ["3","4"]
      }]
    }
  }, function(data, textStatus, jqXHR) {
      console.log("Post resposne:"); console.dir(data); console.log(textStatus); console.dir(jqXHR);
  });
  ###

  '/sprint/:year/:week/add-day' : (req, res) -> 
    SprintModel.findOne { year: req.params.year, startWeek: req.params.week }, (err, sprint) ->
      if err?
        console.log "Error finding by ID"
        console.log err
        return
      sprint.days.push req.body.day
      sprint.save (err) ->
        if not err
          console.log "Day added"
        else
          console.log "Error adding day"
          console.log err
        res.send sprint

putRoutes =
  '/sprint/:id' : (req, res) ->
    SprintModel.findById req.params.id, (err, sprint) ->
      if err?
        console.log "Error finding entry to update"
        console.log err
        return
      sprint.startWeek = req.body.startWeek
      sprint.year = req.body.year
      sprint.days = req.body.days
      sprint.save (err) ->
        if not err
          console.log "Updated"
        else
          console.log "Error updating"
          console.log err
        res.send sprint

deleteRoutes =
  '/sprint/:id' : (req, res) ->
    SprintModel.findById req.params.id, (err, sprint) ->
      if err
        console.log err
        return
      sprint.remove (err) ->
        if not err
          console.log "Deleted"
        else
          console.log "Error deleting"
          console.log err