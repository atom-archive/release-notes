{View} = require 'atom'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @span type: 'button', class: 'release-notes-status icon icon-squirrel inline-block'

  initialize: (previousVersion) ->
    @subscribe this, 'click', -> atom.workspaceView.open('atom://release-notes')
    @subscribe atom.workspaceView, 'window:update-available', => @attach()
    if process.platform is 'win32'
      @setTooltip('An Atom update is available, click the squirrel to learn more.')
    else
      @setTooltip('Click here to view the release notes')
    @attach() if previousVersion? and previousVersion != atom.getVersion()


  attach: ->
    tooltipCount = localStorage.getItem('release-notes:tooltip-count') ? 0
    if process.platform is 'win32' and tooltipCount <= 3
      localStorage.setItem('release-notes:tooltip-count', ++tooltipCount)
      setTimeout((=> @tooltip('show')), 2000)
    atom.workspaceView.statusBar.appendRight(this)
