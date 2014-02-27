{View} = require 'atom'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item', tabindex: -1, =>
      @section class: 'description', outlet: 'description'

  getTitle: ->
    'Release Notes'

  getUri: ->
    @uri

  deserialize: ({uri, version, releaseNotes})->
    new ReleaseNotesView(uri, version, releaseNotes)

  serialize: ->
    deserializer: @constructor.name
    uri: @uri
    releaseNotes: @releaseNotes
    version: @version

  initialize: (@uri, @version, @releaseNotes) ->
    @description.html(releaseNotes)
    @description.prepend("<h1 class='section-heading'>#{@version}</h1>")

    if @version != atom.getVersion()
      @description.append('<br><p><span class="inline-block highlight-info">To update:</span> close Atom and reopen it.</p>')
