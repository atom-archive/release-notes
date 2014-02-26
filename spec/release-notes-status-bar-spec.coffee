ReleaseNotesStatusBar = require '../lib/release-notes-status-bar'
{WorkspaceView} = require 'atom'

triggerUpdate = ->
  atom.workspaceView.trigger 'window:update-available', ['v22.0.0', "NOTES"]

describe "ReleaseNotesStatusBar", ->
  [releaseNotesStatus, releaseNotesStatusBar]  = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView

    waitsForPromise ->
      atom.packages.activatePackage('status-bar')

    waitsForPromise ->
      atom.packages.activatePackage('release-notes')

    atom.workspaceView.openSync('sample.js')

  describe "with no update", ->
    it "renders", ->
      expect(atom.workspaceView).not.toContain('.release-notes-status')

  describe "with an update", ->
    it "renders when the update is made available", ->
      triggerUpdate()
      expect(atom.workspaceView).toContain('.release-notes-status')

    describe "clicking on the status", ->
      [workspaceViewOpen] = []

      it "opens the release notes view", ->
        workspaceViewOpen = spyOn(atom.workspaceView, 'open')
        triggerUpdate()
        atom.workspaceView.find('.release-notes-status').trigger('click')
        expect(workspaceViewOpen.mostRecentCall.args[0]).toBe 'atom://release-notes'
