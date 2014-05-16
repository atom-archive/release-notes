{View} = require 'atom'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item native-key-bindings', tabindex: -1, =>
      @h1 class: 'section-heading', outlet: 'version'
      @div class: 'description', outlet: 'description'
      @div class: 'update-instructions', outlet: 'updateInstructions', =>
        @span class: 'inline-block highlight-info', "To update"
        @span 'close and then reopen Atom.'

  getTitle: ->
    'Release Notes'

  getIconName: ->
    "squirrel"

  getUri: ->
    @uri

  deserialize: ({uri, releaseVersion, releaseNotes})->
    new ReleaseNotesView(uri, releaseVersion, releaseNotes)

  serialize: ->
    deserializer: @constructor.name
    uri: @uri
    releaseNotes: @releaseNotes
    releaseVersion: @releaseVersion

  initialize: (@uri, @releaseVersion, @releaseNotes) ->
    @description.html(@releaseNotes)
    @version.text(@releaseVersion)
    @updateInstructions.show() if @releaseVersion != atom.getVersion()
