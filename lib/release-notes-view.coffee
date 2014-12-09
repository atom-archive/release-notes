shell = require 'shell'
{$$, View} = require 'space-pen'
{Disposable} = require 'atom'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item native-key-bindings', tabindex: -1, =>
      @div class: 'block', =>
        @button class: 'inline-block update-instructions btn btn-success', outlet: 'updateButton', 'Restart and update'
        @button class: 'inline-block btn', outlet: 'viewReleaseNotesButton', 'View past release notes'

      @h2 class: 'inline-block', outlet: 'chocolateyText', =>
        @span 'Run '
        @code 'cup Atom'
        @span ' to install the latest Atom release.'

      @div class: 'block', =>
        @div outlet: 'notesContainer'

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

  #TODO Remove both of these post 1.0
  onDidChangeTitle: -> new Disposable()
  onDidChangeModified: -> new Disposable()

  initialize: (@uri, @releaseVersion, @releaseNotes) ->
    @updateButton.hide()

    if @releaseNotes? and @releaseVersion?
      @updateButton.show() if @releaseVersion isnt atom.getVersion()

      # Support old format
      if typeof @releaseNotes is 'string'
        @releaseNotes = [{version: @releaseVersion, notes: @releaseNotes}]

      for {version, notes} in @releaseNotes
        @notesContainer.append $$ ->
          @h1 class: 'section-heading', version
          @div class: 'description', =>
            @raw notes

    @updateButton.on 'click', ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'application:install-update')

    @viewReleaseNotesButton.on 'click', ->
      shell.openExternal('https://atom.io/releases')
