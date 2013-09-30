fs = require 'fs'
path = require 'path'

ReleaseNotesView = require '../lib/release-notes-view'
{RootView} = require 'atom'

describe "ReleaseNotesView", ->
  [releaseNotes, releaseNotesView, releasesRequest, token] = []

  beforeEach ->
    spyOn(ReleaseNotesView.prototype, 'initialize')
    releasesRequest = spyOn(ReleaseNotesView.prototype, 'requestLatestReleaseNotes').andCallFake ->
      data = fs.readFileSync(path.join(__dirname, 'fixtures', 'releases-response.json'))
      releaseNotesView.onReleaseNotesReceived(null, {}, data)

    window.rootView = new RootView
    atom.activatePackage('release-notes', immediate: true)
    rootView.open('atom://release-notes')

    releaseNotes = rootView.find('.release-notes')
    releaseNotesView = releaseNotes.view()

  describe "with authorization", ->
    beforeEach ->
      spyOn(releaseNotesView, 'getLocalToken').andReturn('token')

    describe "when in devMode", ->
      beforeEach -> releaseNotesView.fetch()

      it "renders draft release notes", ->
        expect(releaseNotes.find('.description h1').text()).toBe 'v27.0.0 - Full Speed Ahead'

    describe "when in release mode", ->
      beforeEach ->
        spyOn(releaseNotesView, 'showUnreleased').andReturn(false)
        releaseNotesView.fetch()

      it "renders the latest release's notes", ->
        expect(releaseNotes.find('.description h1').text()).toBe 'v26.0.0 - Last Release'

  describe "without authorization", ->
    beforeEach ->
      spyOn(releaseNotesView, 'getLocalToken').andReturn(null)
      releaseNotesView.fetch()

    it "prompts for authorization", ->
      expect(releaseNotes.find('.authorization').css('display')).not.toEqual 'none'
