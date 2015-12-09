ReleaseNotesView = null

module.exports = ({uri, version, releaseNotes}) ->
  ReleaseNotesView ?= require './release-notes-view'
  new ReleaseNotesView(uri, version, releaseNotes)
