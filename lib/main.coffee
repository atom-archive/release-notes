{CompositeDisposable} = require 'atom'
ReleaseNotesView = null
ReleaseNoteStatusBar = require  './release-notes-status-bar'

releaseNotesUri = 'atom://release-notes'

createReleaseNotesView = (uri, version, releaseNotes) ->
  ReleaseNotesView ?= require './release-notes-view'
  new ReleaseNotesView(uri, version, releaseNotes)

atom.deserializers.add
  name: 'ReleaseNotesView'
  deserialize: ({uri, releaseVersion, releaseNotes}) ->
    createReleaseNotesView(uri, releaseVersion, releaseNotes)

subscriptions = null

module.exports =
  activate: ->
    subscriptions = new CompositeDisposable()

    if atom.isReleasedVersion()
      previousVersion = localStorage.getItem('release-notes:previousVersion')
      localStorage.setItem('release-notes:previousVersion', atom.getVersion())

      subscriptions.add atom.commands.add 'atom-workspace', 'window:update-available', (event) ->
        return unless  Array.isArray(event?.detail)

        [version] = event.detail
        localStorage.setItem('release-notes:version', version)
        require('./release-notes').fetch(version)

      subscriptions.add atom.workspace.addOpener (uriToOpen) ->
        return unless uriToOpen is releaseNotesUri

        version = localStorage.getItem('release-notes:version')
        try
          releaseNotes = JSON.parse(localStorage.getItem('release-notes:releaseNotes')) ? []
        catch error
          releaseNotes = []
        createReleaseNotesView(releaseNotesUri, version, releaseNotes)

      createStatusEntry = -> new ReleaseNoteStatusBar(previousVersion)

      if document.querySelector('status-bar')
        createStatusEntry()
      else
        subscriptions.add atom.packages.onDidActivateAll ->
          createStatusEntry() if document.querySelector('status-bar')

    subscriptions.add atom.commands.add 'atom-workspace', 'release-notes:show', ->
      if atom.isReleasedVersion()
        atom.workspace.open(releaseNotesUri)
      else
        require('shell').openExternal('https://atom.io/releases')

  deactivate: ->
    subscriptions.dispose()
