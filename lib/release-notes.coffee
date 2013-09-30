ReleaseNotesView = null
ReleaseNoteStatusBar = require  './release-notes-status-bar'

releaseNotesUri = 'atom://release-notes'

createReleaseNotesView = (state) ->
  ReleaseNotesView ?= require './release-notes-view'
  new ReleaseNotesView(state)

deserializer =
  name: 'ReleaseNotesView'
  deserialize: (state) -> createReleaseNotesView(state)
registerDeserializer(deserializer)

eachStatusBarRightArea = (callback) ->
  rootView.eachPane (pane) ->
    # The timeout is required, so that the status bar can initialize itself
    # before we attempt to locate the .status-bar-right area.
    setTimeout ->
      statusBarRight = pane.find('.status-bar-right')
      callback(statusBarRight) if statusBarRight.length > 0
    , 10

# Don't serialize this state, as it's only valid until the application restarts
updateVersion = null

module.exports =
  activate: (state) ->
    rootView.on 'window:update-available', (event, version) ->
      updateVersion = version

    project.registerOpener (filePath) ->
      createReleaseNotesView(uri: releaseNotesUri) if filePath is releaseNotesUri

    eachStatusBarRightArea (statusBarRight) ->
      releaseNotesStatusBar = new ReleaseNoteStatusBar({updateVersion})
      statusBarRight.append(releaseNotesStatusBar)
