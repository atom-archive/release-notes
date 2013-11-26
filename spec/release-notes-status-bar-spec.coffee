{_} = require 'atom'
ReleaseNotesStatusBar = require '../lib/release-notes-status-bar'
{WorkspaceView} = require 'atom'

describe "ReleaseNotesStatusBar", ->
  [releaseNotesStatus, releaseNotesStatusBar]  = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.packages.activatePackage('status-bar', immediate: true)
    pack = atom.packages.activatePackage('release-notes', immediate: true)
    pack.mainModule.updateVersion = null

  describe "with no viewed version", ->
    beforeEach ->
      atom.workspaceView.openSync('sample.js')
      advanceClock(10)

      releaseNotesStatus = atom.workspaceView.find('.release-notes-status .status')
      releaseNotesStatusBar = releaseNotesStatus.view()

    describe "with no pending update", ->
      it "renders", ->
        expect(releaseNotesStatus.is('display')).not.toBe 'none'

    describe "with a pending update", ->
      beforeEach -> atom.workspaceView.trigger 'window:update-available', 'v28.0.0'

      it "renders", ->
        expect(releaseNotesStatus.css('display')).not.toBe 'none'

  describe "with a viewed version", ->
    beforeEach ->
      spyOn(atom.config, 'get').andReturn('v27.0.0')

      atom.workspaceView.openSync('sample.js')
      advanceClock(10)

      releaseNotesStatus = atom.workspaceView.find('.release-notes-status .status')
      releaseNotesStatusBar = releaseNotesStatus.view()

    describe "with no pending update", ->
      it "doesn't render", ->
        expect(releaseNotesStatus.css('display')).toBe 'none'

    describe "with a pending update", ->
      beforeEach -> atom.workspaceView.trigger 'window:update-available', 'v28.0.0'

      it "renders", ->
        expect(releaseNotesStatus.css('display')).not.toBe 'none'

    describe "clicking on the status", ->
      [workspaceViewOpen] = []

      beforeEach ->
        workspaceViewOpen = spyOn(atom.workspaceView, 'open')
        releaseNotesStatus.trigger('click')

      it "opens the release notes view", ->
        expect(workspaceViewOpen.mostRecentCall.args[0]).toBe 'atom://release-notes'
