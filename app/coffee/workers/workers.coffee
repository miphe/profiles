
Backbone = require 'backbone'
Mn       = require 'backbone.marionette'
_        = require 'underscore'
Radio =    require 'backbone.radio'
Btn      = require '../components/ui-buttons.coffee'
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

class Workers.Model.WorkerTitle extends Backbone.Model
  url: '../content/general.json'

# COLLECTION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Workers.Collection = {}

class Workers.Collection.Worker extends Backbone.Collection
  url: '../content/workers.json'
  model: Workers.Model.Worker
  initialize: (opts) ->
    @rawMemberIDs = opts.team or null
    @team = Boolean(opts.team)

  ###*
  # MemberIDs processes the URL ID string, separating each ID into an Array.
  # @returns Array of integers, member IDs.
  ###
  memberIDs: ->
    return null unless @rawMemberIDs
    _.map @rawMemberIDs.split(':'), (id) -> parseInt(id, 10)

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
  initialize: (opts) ->
    @team = if opts.team then true else false

  tagName: 'h2'
  className: 'prominent-heading content-section content-section-centered text-centered'
  template: tpl.workersTitle
  serializeData: ->
    isTeam: @team
    workers: @model.get('workers')
    team: @model.get('team')

class Workers.View.WorkerItemSelectable extends Mn.View
  tagName: 'li'
  className: 'profile-card'
  template: tpl.workersItem
  behaviors: [Selectable]

class Workers.View.WorkerItemDetails extends Mn.View
  tagName: 'li'
  className: 'profile-card'
  template: tpl.workersItem
  # TODO: write behavior for showing detailed profile
  # behaviors: []

class Workers.View.Worker extends Mn.CollectionView
  tagName: 'ul'
  className: 'workers cf content-section-centered'

  childView: ->
    return Workers.View.WorkerItemSelectable unless @collection.team
    return Workers.View.WorkerItemDetails if @collection.team

  filter: (cv, i, col) ->
    return true unless col.memberIDs()
    _.contains(col.memberIDs(), cv.get('id'))

class Workers.View.TeamItem extends Mn.View
  tagName: 'li'
  className: 'team-member'
  template: tpl.workersTeam

class Workers.View.Team extends Mn.CollectionView

  initialize: ->
    @listenTo @collection, 'all', @render
    @listenTo @collection, 'all', @broadcast

  tagName: 'ul'
  className: 'team-list'
  childView: Workers.View.TeamItem

  filter: (child, index, collection) ->
    child.get('selected')

  broadcast: (e, item) ->
    len = @collection.filter((worker) -> worker.get('selected')).length
    if len > 0
      Radio.channel('app').trigger('valid-team-selected')
    else
      Radio.channel('app').trigger('invalid-team-selected')

class Workers.View.WorkerLayout extends Mn.View

  initialize: (opts) ->
    @team = if opts.team? then true else false

  tagName: 'section'
  template: tpl.workersLayout

  onRender: ->
    workerTitleModel = new Workers.Model.WorkerTitle
    workerTitleModel.fetch().done ((res) ->
      workerTitleView = new Workers.View.WorkerTitle
        model: workerTitleModel
        team: @team

      @showChildView 'title', workerTitleView
    ).bind(@)

    workerCollection = new Workers.Collection.Worker({ team: @options.team })
    workerCollection.fetch().done ((res) ->

      workerView = new Workers.View.Worker
        collection: workerCollection
      @showChildView 'crew', workerView

      teamView = new Workers.View.Team
        collection: workerCollection
      @showChildView 'team', teamView

      teamButton = new Btn.View.Button
        collection: workerCollection
        text: 'View Team'
        className: 'btn btn-secondary btn-lg btn-centered is-hidden team-list-button'
      @showChildView 'teamBtn', teamButton

      ).bind(@)

  regions:
    title: '.crew-title'
    crew: '.crew-outer'
    team: '.crew-team'
    teamBtn: '.crew-team-button'

module.exports = Workers
