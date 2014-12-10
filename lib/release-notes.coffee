{$} = require 'space-pen'

module.exports =
  fetch: (version, callback) -> downloadReleaseNotes(version, callback)

downloadReleaseNotes = (version, callback) ->
  $.ajax
    url: 'https://api.github.com/repos/atom/atom/releases'
    dataType: 'json'
    error: ->
      placeholderNotes = [{version, notes: 'The release notes failed to download.', error: true}]
      localStorage.setItem('release-notes:releaseNotes', JSON.stringify(placeholderNotes))
      callback?(placeholderNotes)
    success: (releases) ->
      releases = [] unless Array.isArray(releases)

      # Skip any releases after the one that was just downloaded
      releases.shift() while releases[0]? and releases[0].tag_name isnt "v#{version}"

      releaseNotes = releases.map ({body, published_at, tag_name}) ->
        date: published_at
        notes: body
        version: tag_name.substring(1) # remove leading 'v'

      convertMarkdown releaseNotes, ->
        localStorage.setItem('release-notes:releaseNotes', JSON.stringify(releaseNotes))
        callback?(releaseNotes)

convertMarkdown = (releases, callback) ->
  releases = releases.slice()

  roaster = require 'roaster'
  options =
    sanitize: true
    breaks: true

  convert = (release) ->
    return callback() unless release?
    roaster release.notes, options, (error, html) =>
      release.notes = html unless error?
      convert(releases.pop())

  convert(releases.pop())
