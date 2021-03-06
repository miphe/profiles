
Mn       = require 'backbone.marionette'
_        = require 'underscore'
Radio    = require 'backbone.radio'

glob     = require './glob.coffee'
config   = require '../config.coffee'

class AppUtils extends Mn.Object

  ###*
  * Sets up listeners and callbacks to be invoked on Navigation events.
  * - Page title updates
  * - Intercom (production)
  * - Google Analytics (production)
  * @param {object} opts - Options
  ###
  initialize: (opts) ->
    navChannel = Radio.channel('navigate')
    @listenTo navChannel, 'all', @updatePageTitle
    @listenTo navChannel, 'all', @intercomUpdate if config.ENVIRONMENT.production
    @listenTo navChannel, 'all', @googleAnalyticsTracking if config.ENVIRONMENT.production

  ###*
  * Invokes the `Intercom` method on the global object (`window`) with the 'update' argument.
  * @param {object} e - Event
  ###
  intercomUpdate: (e) ->
    console.warn 'Intercom setup error.' unless window.Intercom
    window.Intercom 'update' if window.Intercom

  ###*
  * Tracks a page on Google Analytics,
  * replaces hash characters,
  * prepares a neat URL string,
  * updates tracking object for GA,
  * then sends tracking information to Google
  * @param {object} e - Event
  ###
  googleAnalyticsTracking: (e) ->

    # Prettify location hash (Pathify)
    path = location.hash.replace /^\/?#/g, '/'
    path = '/' if _.isEmpty(path)

    urlPtn = /^((http[s]?|ftp):\/\/)?(:([^\/]*))?((\/\w+)*\/)?([\w\-\.]?[^#?\s]+)(\?([^#]*))?(#(.*))?$/g
    url = urlPtn.exec location.href

    wwwPtn = /^(www\.){1}/g
    hostname = url[7].replace wwwPtn, ''

    trailingSlashPtn = /(\/)*$/g
    hostname = hostname.replace trailingSlashPtn, ''

    console.info 'Tracking page:', hostname, path

    # Update tracking object's page property
    ga 'set', 'page', path
    ga 'set', 'hostname', hostname

    # Send tracking information to Google
    ga 'send',
      'hitType': 'pageview'

  ###*
  * Invokes global `updatePageTitle`
  * @param {object} e - Event, corresponding with a title via a map lookup
  ###
  updatePageTitle: (e) ->
    glob.updatePageTitle e

module.exports = AppUtils
