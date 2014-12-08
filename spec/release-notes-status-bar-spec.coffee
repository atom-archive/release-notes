{$} = require 'space-pen'
ReleaseNotesStatusBar = require '../lib/release-notes-status-bar'

triggerUpdate = ->
  atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['v22.0.0', "NOTES"])

describe "ReleaseNotesStatusBar", ->
  [releaseNotesStatus, releaseNotesStatusBar]  = []

  beforeEach ->
    spyOn(atom, 'isReleasedVersion').andReturn(true)

    jasmine.attachToDOM(atom.views.getView(atom.workspace))

    waitsForPromise ->
      atom.packages.activatePackage('status-bar')

    waitsForPromise ->
      atom.packages.activatePackage('release-notes')

    waitsForPromise ->
      atom.workspace.open('sample.js')

  describe "with no update", ->
    it "does not show view", ->
      expect(atom.views.getView(atom.workspace)).not.toContain('.release-notes-status')

  describe "with an update", ->
    it "show the view when the update is made available", ->
      triggerUpdate()
      expect(atom.views.getView(atom.workspace)).toContain('.release-notes-status')

    describe "clicking on the status", ->
      [workspaceOpen] = []

      it "opens the release notes view", ->
        workspaceOpen = spyOn(atom.workspace, 'open')
        triggerUpdate()
        $(atom.views.getView(atom.workspace)).find('.release-notes-status').trigger('click')
        expect(workspaceOpen.mostRecentCall.args[0]).toBe 'atom://release-notes'
