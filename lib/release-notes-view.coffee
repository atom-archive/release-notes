{View} = require 'atom'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item native-key-bindings', tabindex: -1, =>
      @h1 class: 'section-heading', outlet: 'version'
      @div class: 'description', outlet: 'description'
      @div class: 'block', =>
        @button class: 'inline-block update-instructions btn btn-success', outlet: 'updateButton', 'Restart and update'
        @button class: 'inline-block btn', outlet: 'viewReleaseNotesButton', 'View past release notes'

  getTitle: ->
    'Release Notes'

  getIconName: ->
    'squirrel'

  getUri: ->
    @uri

  serialize: ->
    deserializer: @constructor.name
    uri: @uri
    releaseNotes: @releaseNotes
    releaseVersion: @releaseVersion

  initialize: (@uri, @releaseVersion, @releaseNotes) ->
    @description.html(@releaseNotes)
    @version.text(@releaseVersion)

    @subscribe @viewReleaseNotesButton, 'click', ->
      window.open('https://atom.io/releases', '_blank', '')

    if @releaseVersion == atom.getVersion()
      @updateButton.show()
      @subscribe @updateButton, 'click', ->
        atom.workspaceView.trigger('application:install-update')
