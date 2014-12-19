{$} = require 'space-pen'

module.exports =
  fetch: (version, callback) -> downloadReleaseNotes(version, callback)

downloadReleaseNotes = (version, callback) ->
  $.ajax
    url: 'https://api.github.com/repos/atom/atom/releases'
    dataType: 'json'
    error: ->
      errorNotes = createErrorNotes(version)
      callback?(errorNotes)
    success: (releases) ->
      createReleaseNotes version, releases, (releaseNotes) ->
        callback?(releaseNotes)

createErrorNotes = (version) ->
  errorNotes = [{version, notes: 'The release notes failed to download.', error: true}]
  saveReleaseNotes(errorNotes)
  errorNotes

saveReleaseNotes = (releaseNotes) ->
  localStorage.setItem('release-notes:releaseNotes', JSON.stringify(releaseNotes))

createReleaseNotes = (version, releases, callback) ->
  releases = [] unless Array.isArray(releases)

  # Skip any releases after the one that was just downloaded
  releases.shift() while releases[0]? and releases[0].tag_name isnt "v#{version}"

  releaseNotes = releases.map ({body, published_at, tag_name}) ->
    date: published_at
    notes: body
    version: tag_name.substring(1) # remove leading 'v'

  convertMarkdown releaseNotes, ->
    saveReleaseNotes(releaseNotes)
    callback(releaseNotes)

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
