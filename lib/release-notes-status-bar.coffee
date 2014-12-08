{View} = require 'space-pen'
{CompositeDisposable} = require 'atom'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @span type: 'button', class: 'release-notes-status icon icon-squirrel inline-block', =>
      @a href: '#', class: 'text-info', outlet: 'upgradeText', " Upgrade"

  initialize: (previousVersion) ->
    @subscriptions = new CompositeDisposable()
    @upgradeText.hide()

    @on 'click', -> atom.workspace.open('atom://release-notes')
    @subscriptions.add atom.commands.add 'atom-workspace', 'window:update-available', =>
      @upgradeText.show() if process.platform is 'win32'
      @attach()

    @subscriptions.add atom.tooltips.add(@element, title: 'Click here to view the release notes')
    @attach() if previousVersion? and previousVersion isnt atom.getVersion()

  attach: ->
    document.querySelector('status-bar').appendRight(this)

  beforeRemove: ->
    @subsriptions.dispose()
