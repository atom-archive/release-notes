ReleaseNotesView = require '../lib/release-notes-view'
RootView = require 'root-view'

# This spec is focused because it starts with an `f`. Remove the `f`
# to unfocus the spec.
#
# Press meta-alt-ctrl-s to run the specs
fdescribe "ReleaseNotesView", ->
  releaseNotes = null

  beforeEach ->
    window.rootView = new RootView
    releaseNotes = atom.activatePackage('releaseNotes', immediate: true)

  describe "when the release-notes:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(rootView.find('.release-notes')).not.toExist()
      rootView.trigger 'release-notes:toggle'
      expect(rootView.find('.release-notes')).toExist()
      rootView.trigger 'release-notes:toggle'
      expect(rootView.find('.release-notes')).not.toExist()
