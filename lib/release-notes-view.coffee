shell = require 'shell'
{View} = require 'atom'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item native-key-bindings', tabindex: -1, =>
      @h1 class: 'section-heading', outlet: 'version'
      @div class: 'description', outlet: 'description'

      @div class: 'block', =>
        @h2 class: 'inline-block', outlet: 'chocolateyText', =>
          @span 'Run '
          @code 'cup Atom'
          @span ' to install the latest Atom release.'

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

  isChocolateyBuild: ->
    /chocolatey/i.test atom.getLoadSettings().resourcePath

  initialize: (@uri, @releaseVersion, @releaseNotes) ->
    @updateButton.hide()
    @downloadButton.hide()
    @chocolateyText.hide()

    if @releaseNotes? and @releaseVersion?
      @description.html(@releaseNotes)
      @version.text(@releaseVersion)

      if @releaseVersion != atom.getVersion()
        if process.platform is 'win32'
          if @isChocolateyBuild()
            @chocolateyText.show()
          else
            @downloadButton.show()
        else
          @updateButton.show()

    @subscribe @updateButton, 'click', ->
      atom.workspaceView.trigger('application:install-update')

    @subscribe @viewReleaseNotesButton, 'click', ->
      shell.openExternal('https://atom.io/releases')

    @subscribe @downloadButton, 'click', ->
      shell.openExternal('https://atom.io/download/windows')
