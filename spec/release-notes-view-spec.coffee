{$} = require 'space-pen'

describe "ReleaseNotesView", ->
  beforeEach ->
    spyOn(atom, 'isReleasedVersion').andReturn(true)

    waitsForPromise ->
      atom.packages.activatePackage('release-notes')

    runs ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['v30.0.0', 'NOTES'])

  describe "when in release mode", ->
    it "renders the latest release's notes", ->
      waitsForPromise ->
        atom.workspace.open('atom://release-notes')

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        expect(releaseNotes.find('h1').text()).toBe 'v30.0.0'
        expect(releaseNotes.find('.description').text()).toContain "NOTES"

    describe "when window:update-available is triggered without release details", ->
      it "ignores the event", ->
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available')

        waitsForPromise ->
          atom.workspace.open('atom://release-notes')

        runs ->
          releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
          expect(releaseNotes.find('h1').text()).toBe 'v30.0.0'
