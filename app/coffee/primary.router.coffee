
Mn        = require 'backbone.marionette'
Radio     = require 'backbone.radio'
_         = require 'underscore'
PrimeCtrl = require './primary.ctrl.coffee'
Rt        = require './utils/routerTypes.coffee'

module.exports = Rt.Base.extend

  controller: PrimeCtrl

  initialize: ->
    Radio.channel('navigate').on 'all', @nav, @

  nav: (route) ->
    unless _.isString(route)
      console.warn 'Route:', route, typeof(route)
      throw new Error('Unqualified route:' + route)

    console.info 'PrimeRouter:Navigating:', route
    @navigate route, { trigger: true }

  appRoutes:
    ''          : 'index'
    'about'     : 'about'
    'team/:ids' : 'team'
