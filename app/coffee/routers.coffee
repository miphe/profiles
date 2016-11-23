
_           = require 'underscore'

# Routers
PrimeRouter = require './primary.router.coffee'

class Routers

  ###*
  # Array of router classes.
  ###
  routers: [
    PrimeRouter
  ]

  ###*
  # Array of router instances.
  ###
  routerInstances: []

  ###*
  # Set up router instances.
  # instantiates all routes found in this.routers
  # then puts each instance in this.routerInstances
  ###
  setup: ->
    _.each @routers, ((router) ->
      @routerInstances.push new router
    ).bind @

module.exports = Routers
