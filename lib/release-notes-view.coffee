shell = require 'shell'
{View} = require 'space-pen'
{Disposable} = require 'atom'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item native-key-bindings', tabindex: -1, =>
      @h1 class: 'section-heading', outlet: 'version'
      @div class: 'description', outlet: 'description'

      @div class: 'block', =>
        @button class: 'inline-block update-instructions btn btn-success', outlet: 'updateButton', 'Restart and update'
        @button class: 'inline-block download-instructions btn btn-success', outlet: 'downloadButton', 'Download new version'
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

  #TODO Remove both of these post 1.0
  onDidChangeTitle: -> new Disposable()
  onDidChangeModified: -> new Disposable()

  initialize: (@uri, @releaseVersion, @releaseNotes) ->
    @updateButton.hide()
    @downloadButton.hide()

    if @releaseNotes? and @releaseVersion?
      @description.html(@releaseNotes)
      @version.text(@releaseVersion)

      if @releaseVersion isnt atom.getVersion()
        if process.platform is 'win32'
            @downloadButton.show()
        else
          @updateButton.show()

    @updateButton.on 'click', ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'application:install-update')

    @viewReleaseNotesButton.on 'click', ->
      shell.openExternal('https://atom.io/releases')

    @downloadButton.on 'click', ->
      shell.openExternal('https://atom.io/download/windows')
