{View} = require 'atom'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @span outlet: 'status', type: 'button', class: 'release-notes-status icon icon-squirrel inline-block'

  initialize: ({@updateVersion}={})->
    @onlyShowIfNewerUpdate()

    @on 'click', =>
      atom.workspaceView.open('atom://release-notes')

    @subscribe atom.workspaceView, 'window:update-available', (event, version) =>
      @updateVersion = version
      @onlyShowIfNewerUpdate()

    @observeConfig 'release-notes.viewedVersion', (version) =>
      @onlyShowIfNewerUpdate(version)

  onlyShowIfNewerUpdate: (viewedVersion) ->
    viewedVersion ?= @getViewedVersion()

    if (@updateVersion and @updateVersion != viewedVersion) or !viewedVersion
      @show()
    else
      @hide()

  getViewedVersion: -> atom.config.get('release-notes.viewedVersion')
