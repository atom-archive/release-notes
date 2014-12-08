fs = require 'fs'
path = require 'path'
{$} = require 'space-pen'
ReleaseNotesView = require '../lib/release-notes-view'

describe "ReleaseNotesView", ->
  [releaseNotes, releaseNotesView] = []

  beforeEach ->
    spyOn(atom, 'isReleasedVersion').andReturn(true)

    waitsForPromise ->
      atom.packages.activatePackage('release-notes')

  describe "when in release mode", ->
    it "renders the latest release's notes", ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['v30.0.0', 'NOTES'])

      waitsForPromise ->
        atom.workspace.open('atom://release-notes')

      runs ->
        releaseNotes = $(atom.views.getView(atom.workspace)).find('.release-notes')
        releaseNotesView = releaseNotes.view()
        expect(releaseNotes.find('h1').text()).toBe 'v30.0.0'
        expect(releaseNotes.find('.description').text()).toContain "NOTES"
