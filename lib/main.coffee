{$} = require 'space-pen'
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

module.exports =
  activate: ->
    if atom.isReleasedVersion()
      previousVersion = localStorage.getItem('release-notes:previousVersion')
      localStorage.setItem('release-notes:previousVersion', atom.getVersion())

      atom.commands.add 'atom-workspace', 'window:update-available', (event) ->
        return unless  Array.isArray(event?.detail)

        [version] = event.detail
        localStorage.setItem('release-notes:version', version)
        downloadReleaseNotes(version)

      atom.workspace.addOpener (filePath) ->
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
        atom.packages.onDidActivateAll ->
          createStatusEntry() if document.querySelector('status-bar')

    atom.commands.add 'atom-workspace', 'release-notes:show', ->
      if atom.isReleasedVersion()
        atom.workspace.open(releaseNotesUri)
      else
        require('shell').openExternal('https://atom.io/releases')

downloadReleaseNotes = (version) ->
  $.ajax
    url: 'https://api.github.com/repos/atom/atom/releases'
    dataType: 'json'
    error: ->
      placeholderNotes = {version, notes: 'The release notes failed to download.'}
      localStorage.setItem('release-notes:releaseNotes', JSON.stringify(placeholderNotes))
    success: (releases=[]) ->
      releases.shift() while releases[0]? and releases[0].tag_name isnt "v#{version}"
      releaseNotes = releases.map ({tag_name, body}) -> {version: tag_name, notes: body}
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
