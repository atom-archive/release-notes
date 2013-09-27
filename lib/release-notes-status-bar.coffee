{View} = require 'space-pen'

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @div class: 'release-notes-status inline-block', =>
     @span outlet: 'status', type: 'button', class: 'status icon icon-rocket'

  initialize: (@session) ->
    @status.on 'click', =>
      rootView.open('atom://release-notes')
