ReleaseNotesStatusBar = require '../lib/release-notes-status-bar'
{RootView} = require 'atom'

describe "ReleaseNotesStatusBar", ->
  [releaseNotesStatus, releaseNotesStatusBar]  = []

  beforeEach ->
    window.rootView = new RootView
    atom.activatePackage('status-bar', immediate: true)
    atom.activatePackage('release-notes', immediate: true)
    rootView.open('sample.js')
    advanceClock(10)

    releaseNotesStatus = rootView.find('.release-notes-status .status')
    releaseNotesStatusBar = releaseNotesStatus.view()

  describe "with no pending update", ->
    it "renders without a highlight", ->
      expect(releaseNotesStatus.hasClass('update-available')).toBeFalsy()

  describe "with a pending update", ->
    beforeEach -> rootView.trigger 'window:update-available', 'v28.0.0'

    it "renders with a highlight", ->
      expect(releaseNotesStatus.hasClass('update-available')).toBeTruthy()

  describe "clicking on the status", ->
    [rootViewOpen] = []

    beforeEach ->
      rootViewOpen = spyOn(rootView, 'open')
      releaseNotesStatus.trigger('click')

    it "opens the release notes view", ->
      expect(rootViewOpen.mostRecentCall.args[0]).toBe 'atom://release-notes'
