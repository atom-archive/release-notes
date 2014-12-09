{$} = require 'space-pen'

describe "ReleaseNotesView", ->
  beforeEach ->
    spyOn(atom, 'isReleasedVersion').andReturn(true)

    waitsForPromise ->
      atom.packages.activatePackage('release-notes')

    runs ->
      spyOn($, 'ajax').andCallFake ({success}) ->
        success([{tag_name: 'v0.3.0', body: 'a release'}])
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['0.3.0'])

  describe "when in release mode", ->
    it "renders the release notes for the current and previous releases", ->
      waitsForPromise ->
        atom.workspace.open('atom://release-notes')

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        expect(releaseNotes.find('h1').text()).toBe '0.3.0'
        expect(releaseNotes.find('.description').text()).toContain "a release"

    describe "when window:update-available is triggered without release details", ->
      it "ignores the event", ->
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available')

        waitsForPromise ->
          atom.workspace.open('atom://release-notes')

        runs ->
          releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
          expect(releaseNotes.find('h1').text()).toBe '0.3.0'
