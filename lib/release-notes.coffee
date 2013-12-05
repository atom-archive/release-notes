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
    atom.workspaceView.on 'window:update-available', (event, version) =>
      @updateVersion = version

    atom.project.registerOpener (filePath) ->
      createReleaseNotesView(uri: releaseNotesUri) if filePath is releaseNotesUri

    atom.workspaceView.command 'release-notes:show', ->
      atom.workspaceView.open('atom://release-notes')

    createStatusEntry = ->
      view = new ReleaseNoteStatusBar(atom.workspaceView.statusBar)
      atom.workspaceView.statusBar.appendRight(view)

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', ->
        createStatusEntry()
