{$} = require 'space-pen'

describe "ReleaseNotesView", ->
  beforeEach ->
    spyOn(atom, 'isReleasedVersion').andReturn(true)

    waitsForPromise ->
      atom.packages.activatePackage('release-notes')

  describe "when in release mode", ->
    it "renders the release notes for the current and previous releases", ->
      spyOn($, 'ajax').andCallFake ({success}) -> success([{tag_name: 'v0.3.0', body: 'a release'}])
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['0.3.0'])

      waitsForPromise ->
        atom.workspace.open('atom://release-notes')

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        expect(releaseNotes.find('h1').text()).toBe '0.3.0'
        expect(releaseNotes.find('.description').text()).toContain "a release"

    describe "when window:update-available is triggered without release details", ->
      it "ignores the event", ->
        spyOn($, 'ajax').andCallFake ({success}) -> success([{tag_name: 'v0.3.0', body: 'a release'}])
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['0.3.0'])
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available')

        waitsForPromise ->
          atom.workspace.open('atom://release-notes')

        runs ->
          releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
          expect(releaseNotes.find('h1').text()).toBe '0.3.0'

    it "displays an error when downloading the release notes fails", ->
      spyOn($, 'ajax').andCallFake ({error}) -> error(new Error())
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['0.3.0'])

      waitsForPromise ->
        atom.workspace.open('atom://release-notes')

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        releaseNotesView = releaseNotes.view()
        expect(releaseNotes.find('h1').text()).toBe '0.3.0'
        expect(releaseNotes.find('.description').text().length).toBeGreaterThan 0
