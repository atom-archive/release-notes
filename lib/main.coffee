{CompositeDisposable} = require 'atom'

releaseNotesUri = 'atom://release-notes'
ReleaseNotesView = null
subscriptions = null

module.exports =
  activate: ->
    subscriptions = new CompositeDisposable()

    if atom.isReleasedVersion()
      subscriptions.add atom.commands.add 'atom-workspace', 'window:update-available', (event) ->
        return unless Array.isArray(event?.detail)

        [version] = event.detail
        if version
          localStorage.setItem('release-notes:version', version)
          require('./release-notes').fetch(version)

      subscriptions.add atom.workspace.addOpener (uriToOpen) ->
        return unless uriToOpen is releaseNotesUri

        version = localStorage.getItem('release-notes:version')
        try
          releaseNotes = JSON.parse(localStorage.getItem('release-notes:releaseNotes')) ? []
        catch error
          releaseNotes = []
        ReleaseNotesView ?= require './release-notes-view'
        new ReleaseNotesView(releaseNotesUri, version, releaseNotes)

    subscriptions.add atom.commands.add 'atom-workspace', 'release-notes:show', ->
      if atom.isReleasedVersion()
        atom.workspace.open(releaseNotesUri)
      else
        require('shell').openExternal('https://atom.io/releases')

  deactivate: ->
    subscriptions.dispose()

  consumeStatusBar: (statusBar) ->
    return unless atom.isReleasedVersion()

    previousVersion = localStorage.getItem('release-notes:previousVersion')
    localStorage.setItem('release-notes:previousVersion', atom.getVersion())
    ReleaseNoteStatusBar = require './release-notes-status-bar'
    new ReleaseNoteStatusBar(statusBar, previousVersion)
