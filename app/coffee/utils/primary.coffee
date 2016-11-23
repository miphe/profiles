
Backbone = require 'backbone'
Mn       = require 'backbone.marionette'
Radio    = require 'backbone.radio'
_        = require 'underscore'
$        = require 'jquery'
config   = require '../config.coffee'
tpl      = require './templates/primary.html'

Primary = {}

# MODEL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Primary.Model = {}

class Primary.Model.NavItem extends Backbone.Model
  defaults:
    route: '-'
    label: 'Cool link'

# COLLECTION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Primary.Collection = {}

class Primary.Collection.Nav extends Backbone.Collection
  model: Primary.Model.NavItem

# BEHAVIOR
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

###*
  # This behavior should be attached to a Collection View
  # When a childView receives the event 'activate:item'
  # this behavior will kick in.
  # @TODO
  # Move this to Marionette behaviors package.
  # @Example
  # CollectionView
  #   behaviors: [WithActiveBar]
  # ItemView
  #   triggers: {'click a': 'activate:item'}
###
class WithActiveBar extends Mn.Behavior

  onRender: ->
    @addBarEl()

  addBarEl: ->
    @$bar = $('<span />', { class: 'active-indicator' })
    @view.$el.append @$bar

  updateBarWidth: (childView) ->
    targetWidth = childView.$el.find('a').width()
    @$bar.css('width', targetWidth)

  updateBarPos: (childView) ->
    goTo = childView.$el.find('a').position().left
    @$bar.css('left', goTo)

  onChildviewActivateItem: (childView) ->
    @updateBarWidth childView
    @updateBarPos childView

###*
# Implements the behavior of a Primary navigation
# item. Meaning as follows.
# - When routing happens, checks this item's route for current
#   route, if they are the same, trigger 'activate:item' event.
# Dependencies:
# - Model of this view needs to have the 'route' property.
# - View needs to handle activation event 'activate:item'.
###
class PrimaryNavItem extends Mn.Behavior
  initialize: ->
    r = @view.options.model.get('route')
    Radio.channel('navigate').on r, @handleRoute, @

  events:
    'click @ui.link': 'navigate'

  ###*
  # Fires a route event on the 'navigate' channel
  # which will cause a Backbone route to occur.
  ###
  navigate: (e) ->
    e.preventDefault()
    r = @view.options.model.get('route')
    Radio.channel('navigate').trigger r

  handleRoute: ->
    @view.trigger 'activate:item', @view

# VIEW
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Primary.View = {}

class Primary.View.Logo extends Mn.View
  className: 'logo-inner'
  template: tpl.logo
  serializeData: ->
    name: config.APP_NAME
    tagline: config.APP_TAGLINE

class Primary.View.NavItem extends Mn.View
  tagName: 'li'
  template: tpl.nav_item
  ui: link: 'a'
  triggers: 'click @ui.link': 'activate:item'
  behaviors: [PrimaryNavItem]

class Primary.View.Nav extends Mn.CollectionView
  tagName: 'nav'
  className: 'horizontal with-active-bar'
  childView: Primary.View.NavItem
  behaviors: [WithActiveBar]

module.exports = Primary
