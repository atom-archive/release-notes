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
    previousVersion = atom.config.get('release-notes.viewedVersion')
    atom.config.set('release-notes.viewedVersion', atom.getVersion())

    atom.workspaceView.on 'window:update-available', (event, version, releaseNotes) =>
      localStorage["release-notes:version"] = version
      localStorage["release-notes:releaseNotes"] = releaseNotes

    atom.project.registerOpener (filePath) ->
      return unless filePath is releaseNotesUri

      version = localStorage["release-notes:version"]
      releaseNotes = localStorage["release-notes:releaseNotes"]
      createReleaseNotesView(filePath, version, releaseNotes)

    atom.workspaceView.command 'release-notes:show', ->
      atom.workspaceView.open('atom://release-notes')

    createStatusEntry = ->
      new ReleaseNoteStatusBar(previousVersion)

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', ->
        createStatusEntry()
