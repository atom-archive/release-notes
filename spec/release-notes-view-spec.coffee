fs = require 'fs'
path = require 'path'

ReleaseNotesView = require '../lib/release-notes-view'
{WorkspaceView} = require 'atom'

describe "ReleaseNotesView", ->
  [releaseNotes, releaseNotesView] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView

    waitsForPromise ->
      atom.packages.activatePackage('release-notes')

  describe "when in release mode", ->
    it "renders the latest release's notes", ->
      atom.workspaceView.trigger 'window:update-available', ['v30.0.0', 'NOTES']
      waitsForPromise ->
        atom.workspaceView.open('atom://release-notes')

      runs ->
        releaseNotes = atom.workspaceView.find('.release-notes')
        releaseNotesView = releaseNotes.view()
        expect(releaseNotes.find('.description h1').text()).toBe 'v30.0.0'
        expect(releaseNotes.find('.description').text()).toContain "NOTES"
