
Backbone = require 'backbone'
Mn       = require 'backbone.marionette'
_        = require 'underscore'
tpl      = require './templates/workers.html'

Workers = {}

# MODEL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Workers.Model = {}

class Workers.Model.Worker extends Backbone.Model
  defaults:
    id: null
    img: ''
    name: 'John Doe',
    title: 'Worker',
    roles: [],
    skills: []
    selected: false

# COLLECTION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Workers.Collection = {}

class Workers.Collection.Worker extends Backbone.Collection
  url: '../content/workers.json'
  model: Workers.Model.Worker

# BEHAVIOR
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Requires model attribute 'selected'
class Selectable extends Mn.Behavior

  events:
    'click': 'toggleModel'

  modelEvents:
    'change:selected': 'toggleSelect'

  toggleModel: ->
    val = @view.model.get 'selected'
    @view.model.set 'selected', !val

  isSelected: ->
    @view.$el.hasClass 'is-selected'

  toggleSelect: ->
    @view.$el.toggleClass 'is-selected'

  deselect: ->
    @view.$el.removeClass 'is-selected'

  select: ->
    @view.$el.addClass 'is-selected'

# VIEW
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Workers.View = {}

class Workers.View.WorkerTitle extends Mn.View
  tagName: 'h2'
  className: 'prominent-heading content-section content-section-centered text-centered'
  template: _.template('Keeper Solutions Crew')

class Workers.View.WorkerItem extends Mn.View
  tagName: 'li'
  className: 'profile-card'
  template: tpl.workersItem
  behaviors: [Selectable]

class Workers.View.Worker extends Mn.CollectionView
  tagName: 'ul'
  className: 'workers cf content-section-centered'
  childView: Workers.View.WorkerItem

class Workers.View.TeamItem extends Mn.View
  tagName: 'li'
  className: 'team-member'
  template: tpl.workersTeam

class Workers.View.Team extends Mn.CollectionView

  initialize: ->
    @listenTo @collection, 'all', @render

  tagName: 'ul'
  className: 'team-list'
  childView: Workers.View.TeamItem
  filter: (child, index, collection) ->
    child.get('selected')

class Workers.View.WorkerLayout extends Mn.View
  tagName: 'section'
  template: tpl.workersLayout

  onRender: ->
    workerTitleView = new Workers.View.WorkerTitle
    @showChildView 'title', workerTitleView

    workerCollection = new Workers.Collection.Worker
    workerCollection.fetch().done ((res) ->
      workerView = new Workers.View.Worker
        collection: workerCollection

      @showChildView 'crew', workerView

      teamView = new Workers.View.Team
        collection: workerCollection

      @showChildView 'team', teamView

      ).bind(@)

  regions:
    title: '.crew-title'
    crew: '.crew-outer'
    team: '.crew-team'

module.exports = Workers
