{View} = require 'space-pen'
{CompositeDisposable} = require 'atom'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @span type: 'button', class: 'release-notes-status icon icon-squirrel inline-block'

  initialize: (previousVersion) ->
    @subscriptions = new CompositeDisposable()

    @on 'click', -> atom.workspace.open('atom://release-notes')
    @subscriptions.add atom.commands.add 'atom-workspace', 'window:update-available', => @attach()

    @subscriptions.add atom.tooltips.add(@element, title: 'Click to view the release notes')
    @attach() if previousVersion? and previousVersion isnt atom.getVersion()

  attach: ->
    document.querySelector('status-bar').addRightTile(item: this, priority: -100)

  detached: ->
    @subsriptions?.dispose()
