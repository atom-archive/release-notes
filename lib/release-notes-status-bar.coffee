{View} = require 'atom'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @span type: 'button', class: 'release-notes-status icon icon-squirrel inline-block'

  initialize: (previousVersion) ->
    @subscribe this, 'click', -> atom.workspaceView.open('atom://release-notes')
    @subscribe atom.workspaceView, 'window:update-available', => @attach()
    if process.platform is 'win32'
      @setTooltip('A new version of Atom is available')
    else
      @setTooltip('Click here to view the release notes')
    @attach() if previousVersion? and previousVersion != atom.getVersion()


  attach: ->
    setTimeout((=> @tooltip('show')), 1000) if process.platform is 'win32'
    atom.workspaceView.statusBar.appendRight(this)
