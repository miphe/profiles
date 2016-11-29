Backbone = require 'backbone'
Mn = require 'backbone.marionette'
Radio = require 'backbone.radio'

Routers = {}

# Base router
class Routers.Base extends Mn.AppRouter
  foo: {}

module.exports = Routers
