
Mn     = require 'backbone.marionette'
Radio  = require 'backbone.radio'
_      = require 'underscore'
config = require '../config.coffee'
Primary= require './primary.coffee'

tpl    = require './templates/app-views.html'

class AppView extends Mn.View
  template: tpl.app_view

  className: -> config.ROOTVIEWNAME + '-inner'

  initialize: ->

    # Event structure: 'VERB:WHAT', 'WHERE', VIEW
    # Examples: 'show:view', 'main', mainViewInstance
    #           'get:view', 'main'
    #           'destroy:view', 'footer'
    @listenTo Radio.channel('app'), 'show:view', @showView
    @listenTo Radio.channel('dialog'), 'open', @openDialog
    @listenTo Radio.channel('dialog'), 'close', @closeDialog

  showView: (region, view) ->
    @showChildView region, view

  openDialog: (view) ->
    @showChildView 'dialog', view

  closeDialog: (view) ->
    @getRegion('dialog').reset()

  onRender: ->

    # App logo rendering
    logoView = new Primary.View.Logo
    Radio.channel('app').trigger 'show:view', 'logo', logoView

    # App primary navigation rendering
    navView = new Primary.View.Nav
      collection: new Primary.Collection.Nav([
        { label: 'Crew', route: '' }
        { label: 'About Us', route: 'about' }
      ])
    Radio.channel('app').trigger 'show:view', 'nav', navView

  regions:
    main: '.inner'
    logo: '.logo-outer'
    nav: '.primary-nav-outer'
    footer: 'footer'
    dialog: '.dialog-content'

module.exports = AppView
