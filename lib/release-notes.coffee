shell = require 'shell'
ReleaseNotesView = null
ReleaseNoteStatusBar = require  './release-notes-status-bar'

releaseNotesUri = 'atom://release-notes'

createReleaseNotesView = (uri, version, releaseNotes) ->
  ReleaseNotesView ?= require './release-notes-view'
  new ReleaseNotesView(uri, version, releaseNotes)

deserializer =
  name: 'ReleaseNotesView'
  deserialize: ({uri, releaseVersion, releaseNotes}) ->
    createReleaseNotesView(uri, releaseVersion, releaseNotes)
atom.deserializers.add(deserializer)

module.exports =
  activate: ->
    if atom.isReleasedVersion()
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

      createStatusEntry = -> new ReleaseNoteStatusBar(previousVersion)

      if atom.workspaceView.statusBar?
        createStatusEntry()
      else
        atom.packages.once 'activated', ->
          createStatusEntry() if atom.workspaceView.statusBar?

    atom.workspaceView.command 'release-notes:show', ->
      if atom.isReleasedVersion()
        atom.workspaceView.open(releaseNotesUri)
      else
        shell.openExternal('https://atom.io/releases')
