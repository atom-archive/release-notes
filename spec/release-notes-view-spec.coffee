{$} = require 'atom-space-pen-views'

describe "ReleaseNotesView", ->
  beforeEach ->
    spyOn(atom, 'isReleasedVersion').andReturn(true)
    storage = {}
    spyOn(localStorage, 'setItem').andCallFake (key, value) -> storage[key] = value
    spyOn(localStorage, 'getItem').andCallFake (key) -> storage[key]

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

    it "serializes and deserializes the view", ->
      spyOn($, 'ajax').andCallFake ({success}) -> success([{tag_name: 'v0.3.0', body: 'a release'}])
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['0.3.0'])

      waitsForPromise ->
        atom.workspace.open('atom://release-notes')

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes').view()
        newReleaseNotes = atom.deserializers.deserialize(releaseNotes.serialize())
        expect(newReleaseNotes.text()).toBe releaseNotes.text()

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

    it "displays an error when downloading the release notes fails and tries to redownload them", ->
      spyOn($, 'ajax').andCallFake ({error, success}) ->
        if $.ajax.callCount is 1
          error(new Error())
        else
          success([{tag_name: 'v0.3.0', body: 'a release'}])

      atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['0.3.0'])

      waitsForPromise ->
        atom.workspace.open('atom://release-notes')

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        releaseNotesView = releaseNotes.view()
        expect(releaseNotes.find('h1').text()).toBe '0.3.0'
        expect(releaseNotes.find('.description').text().length).toBeGreaterThan 0

      waitsFor ->
        $.ajax.callCount is 2

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        releaseNotesView = releaseNotes.view()
        expect(releaseNotes.find('h1').text()).toBe '0.3.0'
        expect(releaseNotes.find('.description').text()).toContain "a release"

    it "tries to redownload them if they were previously empty", ->
      spyOn($, 'ajax').andCallFake ({error, success}) ->
        if $.ajax.callCount is 1
          success([])
        else
          success([{tag_name: 'v0.3.0', body: 'a release'}])

      atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['0.3.0'])

      waitsForPromise ->
        atom.workspace.open('atom://release-notes')

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        releaseNotesView = releaseNotes.view()
        expect(releaseNotes.find('h1').text()).toBe '0.3.0'
        expect(releaseNotes.find('.description').text().length).toBeGreaterThan 0

      waitsFor ->
        $.ajax.callCount is 2

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        releaseNotesView = releaseNotes.view()
        expect(releaseNotes.find('h1').text()).toBe '0.3.0'
        expect(releaseNotes.find('.description').text()).toContain "a release"

    describe "when scrolling with core:page-up and core:page-down", ->
      releaseNotesView = null

      beforeEach ->
        spyOn($, 'ajax').andCallFake ({success}) -> success([{tag_name: 'v0.3.0', body: 'a release'}])
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['0.3.0'])

        waitsForPromise ->
          atom.workspace.open('atom://release-notes')

        runs ->
          releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
          releaseNotesView = releaseNotes.view()

      it "handles core:page-down", ->
        spyOn(releaseNotesView, 'pageDown')
        atom.commands.dispatch(releaseNotesView.element, 'core:page-down')
        expect(releaseNotesView.pageDown).toHaveBeenCalled()

      it "handles core:page-up", ->
        spyOn(releaseNotesView, 'pageUp')
        atom.commands.dispatch(releaseNotesView.element, 'core:page-up')
        expect(releaseNotesView.pageUp).toHaveBeenCalled()
