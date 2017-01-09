
Mn =       require 'backbone.marionette'
Backbone = require 'backbone'
$ =        require 'jquery'
_ =        require 'underscore'
Radio =    require 'backbone.radio'

tpl = require './templates/ui-buttons.html'

UIBtn = {}

# MODEL
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

UIBtn.Model = {}

# VIEW
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Requires model attribute 'selected'
class CanNavigateToTeam extends Mn.Behavior

  initialize: ->
    @listenTo Radio.channel('app'), 'valid-team-selected', @show, @
    @listenTo Radio.channel('app'), 'invalid-team-selected', @hide, @

  show: ->
    @view.$el.removeClass('is-hidden')

  hide: ->
    @view.$el.addClass('is-hidden')

  events:
    'click': 'navigate'

  currentSelection: ->
    selected = @view.collection.filter (worker) ->
      worker.get('selected')
    _.map selected, (worker) -> worker.id

  URLifyTeam: (teamIDs) ->
    teamIDs.join(':')

  navigate: ->
    teamIDs = @currentSelection()
    Radio.channel('navigate').trigger 'team/' + @URLifyTeam(teamIDs)

UIBtn.View = {}

# TODO: this should be more general, or moved.
class UIBtn.View.Button extends Mn.View
  template: tpl.teamButton
  tagName: 'button'
  className: 'btn btn-primary btn-lg'
  behaviors: [CanNavigateToTeam]
  serializeData: ->
    text: @options.text

module.exports = UIBtn
