{View} = require 'space-pen'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @div class: 'release-notes-status inline-block', =>
     @span outlet: 'status', type: 'button', class: 'status icon icon-squirrel'

  initialize: (options={}) ->
    @status.addClass('update-available') if options.updateVersion

    @status.on 'click', =>
      rootView.open('atom://release-notes')

    rootView.command 'window:update-available', (event, version) =>
      @status.addClass('update-available')
