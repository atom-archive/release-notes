{View} = require 'atom'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @span type: 'button', class: 'release-notes-status icon icon-squirrel inline-block'

  initialize: (previousVersion) ->
    @subscribe this, 'click', => atom.workspaceView.open('atom://release-notes')
    @subscribe atom.workspaceView, 'window:update-available', => @attach()
    @attach() if previousVersion? and previousVersion != atom.getVersion()

  attach: ->
    atom.workspaceView.statusBar.appendRight(this)
