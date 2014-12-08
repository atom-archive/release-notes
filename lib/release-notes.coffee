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

      atom.commands.add 'atom-workspace', 'window:update-available', (event) ->
        [version, releaseNotes] = event.detail
        localStorage.setItem("release-notes:version", version)
        localStorage.setItem("release-notes:releaseNotes", releaseNotes)

      atom.workspace.registerOpener (filePath) ->
        return unless filePath is releaseNotesUri

        version = localStorage.getItem("release-notes:version")
        releaseNotes = localStorage.getItem("release-notes:releaseNotes")
        createReleaseNotesView(filePath, version, releaseNotes)

      createStatusEntry = -> new ReleaseNoteStatusBar(previousVersion)

      if document.querySelector('status-bar')
        createStatusEntry()
      else
        atom.packages.once 'activated', ->
          createStatusEntry() if document.querySelector('status-bar')

    atom.commands.add 'atom-workspace', 'release-notes:show', ->
      if atom.isReleasedVersion()
        atom.workspace.open(releaseNotesUri)
      else
        shell.openExternal('https://atom.io/releases')
