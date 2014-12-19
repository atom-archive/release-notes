{$$, View} = require 'space-pen'
{Disposable} = require 'atom'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item native-key-bindings', tabindex: -1, =>
      @div class: 'block', =>
        @button class: 'inline-block update-instructions btn btn-success', outlet: 'updateButton', 'Restart and update'
        @button class: 'inline-block btn', outlet: 'viewReleaseNotesButton', 'View on atom.io'
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

      @addReleaseNotes()

      # Try to re-fetch release notes if the last fetch failed
      if @releaseNotes[0]?.error
        require('./release-notes').fetch @releaseVersion, (@releaseNotes) =>
          @addReleaseNotes()

    @updateButton.on 'click', ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'application:install-update')

    @viewReleaseNotesButton.on 'click', ->
      require('shell').openExternal('https://atom.io/releases')

  addReleaseNotes: ->
    @notesContainer.empty()

    for {date, notes, version} in @releaseNotes
      @notesContainer.append $$ ->
        if date?
          @h1 class: 'section-heading', =>
            @span class: 'text-highlight', "#{version} "
            @small new Date(date).toLocaleString()
        else
          @h1 class: 'section-heading text-highlight', version
        @div class: 'description', =>
          @raw notes
