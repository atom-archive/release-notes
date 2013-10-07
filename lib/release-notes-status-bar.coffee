{View} = require 'atom'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @div class: 'release-notes-status inline-block', =>
     @span outlet: 'status', type: 'button', style: 'display:none', class: 'status icon icon-squirrel'

  initialize: ({@updateVersion}={})->
    @onlyShowIfNewerUpdate()

    @status.on 'click', =>
      rootView.open('atom://release-notes')

    rootView.command 'window:update-available', (event, version) =>
      @updateVersion = version
      @onlyShowIfNewerUpdate()

    atom.config.observe 'release-notes.viewedVersion', (version) =>
      @onlyShowIfNewerUpdate(version)

  onlyShowIfNewerUpdate: (viewedVersion) ->
    viewedVersion ?= @getViewedVersion()

    if (@updateVersion and @updateVersion != viewedVersion) or !viewedVersion
      @status.show()
    else
      @status.hide()

  getViewedVersion: -> atom.config.get('release-notes.viewedVersion')
