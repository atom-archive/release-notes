{$} = require 'space-pen'
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
        downloadReleaseNotes(version)

      subscriptions.add atom.workspace.addOpener (filePath) ->
        return unless filePath is releaseNotesUri

        version = localStorage.getItem('release-notes:version')
        try
          releaseNotes = JSON.parse(localStorage.getItem('release-notes:releaseNotes')) ? []
        catch error
          releaseNotes = []
        createReleaseNotesView(filePath, version, releaseNotes)

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

downloadReleaseNotes = (version) ->
  $.ajax
    url: 'https://api.github.com/repos/atom/atom/releases'
    dataType: 'json'
    error: ->
      placeholderNotes = [{version, notes: 'The release notes failed to download.'}]
      localStorage.setItem('release-notes:releaseNotes', JSON.stringify(placeholderNotes))
    success: (releases) ->
      releases = [] unless Array.isArray(releases)
      releases.shift() while releases[0]? and releases[0].tag_name isnt "v#{version}"
      releaseNotes = releases.map ({body, published_at, tag_name}) ->
        date: published_at
        notes: body
        version: tag_name.substring(1) # remove leading 'v'
      convertMarkdown releaseNotes, ->
        localStorage.setItem('release-notes:releaseNotes', JSON.stringify(releaseNotes))

convertMarkdown = (releases, callback) ->
  releases = releases.slice()

  roaster = require 'roaster'
  options =
    sanitize: false
    breaks: true

  convert = (release) ->
    return callback() unless release?
    roaster release.notes, options, (error, html) =>
      release.notes = html unless error?
      convert(releases.pop())

  convert(releases.pop())
