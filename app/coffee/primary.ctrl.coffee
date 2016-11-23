
_        = require 'underscore'
Backbone = require 'backbone'
Radio    = require 'backbone.radio'

Workers  = require './workers/workers.coffee'
Primary  = require './utils/primary.coffee'

PrimeCtrl =

  index: ->
    console.log 'PrimeCtrl:index'
    workersLayout = new Workers.View.WorkerLayout
    Radio.channel('app').trigger 'show:view', 'main', workersLayout

  team: (ids) ->
    console.log 'PrimeCtrl:team', ids

  about: ->
    console.log 'PrimeCtrl:about'
    view = new Backbone.View
    Radio.channel('app').trigger 'show:view', 'main', view

  notFound: ->
    console.log 'PrimeCtrl:notFound'

module.exports = _.extend(PrimeCtrl, Backbone.Events)
