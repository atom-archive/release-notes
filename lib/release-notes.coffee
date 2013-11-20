ReleaseNotesView = null
ReleaseNoteStatusBar = require  './release-notes-status-bar'

releaseNotesUri = 'atom://release-notes'

createReleaseNotesView = (state) ->
  ReleaseNotesView ?= require './release-notes-view'
  new ReleaseNotesView(state)

deserializer =
  name: 'ReleaseNotesView'
  deserialize: (state) -> createReleaseNotesView(state)
atom.deserializers.add(deserializer)

module.exports =
  # Don't serialize this state, as it's only valid until the application restarts
  updateVersion: null

  activate: (state) ->
    atom.rootView.on 'window:update-available', (event, version) =>
      @updateVersion = version

    atom.project.registerOpener (filePath) ->
      createReleaseNotesView(uri: releaseNotesUri) if filePath is releaseNotesUri

    atom.rootView.command 'release-notes:show', ->
      atom.rootView.open('atom://release-notes')

    # The timeout is required, so that the status bar can initialize itself
    # before we attempt to locate the .status-bar-right area.
    setTimeout ->
      statusBarRight = atom.rootView.find('.status-bar-right')
      if statusBarRight.length > 0
        releaseNotesStatusBar = new ReleaseNoteStatusBar({@updateVersion})
        statusBarRight.append(releaseNotesStatusBar)
    , 10
