ReleaseNotesView = null
ReleaseNoteStatusBar = require  './release-notes-status-bar'

releaseNotesUri = 'atom://release-notes'

createReleaseNotesView = (uri, version, releaseNotes) ->
  ReleaseNotesView ?= require './release-notes-view'
  new ReleaseNotesView(uri, version, releaseNotes)

deserializer =
  name: 'ReleaseNotesView'
  deserialize: ({uri, version, releaseNotes}) ->
    createReleaseNotesView(uri, version, releaseNotes)
atom.deserializers.add(deserializer)

module.exports =
  activate: ->
    return unless atom.isReleasedVersion()
    
    previousVersion = localStorage.getItem('release-notes:previousVersion')
    localStorage.setItem('release-notes:previousVersion', atom.getVersion())

    atom.workspaceView.on 'window:update-available', (event, version, releaseNotes) ->
      localStorage.setItem("release-notes:version", version)
      localStorage.setItem("release-notes:releaseNotes", releaseNotes)

    atom.workspace.registerOpener (filePath) ->
      return unless filePath is releaseNotesUri

      version = localStorage.getItem("release-notes:version")
      releaseNotes = localStorage.getItem("release-notes:releaseNotes")
      createReleaseNotesView(filePath, version, releaseNotes)

    atom.workspaceView.command 'release-notes:show', ->
      atom.workspaceView.open('atom://release-notes')

    createStatusEntry = -> new ReleaseNoteStatusBar(previousVersion)

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', ->
        createStatusEntry()
