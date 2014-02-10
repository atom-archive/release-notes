fs = require 'fs'
path = require 'path'

ReleaseNotesView = require '../lib/release-notes-view'
{WorkspaceView} = require 'atom'

describe "ReleaseNotesView", ->
  [releaseNotes, releaseNotesView, releasesRequest, token] = []

  beforeEach ->
    spyOn(ReleaseNotesView.prototype, 'initialize')
    releasesRequest = spyOn(ReleaseNotesView.prototype, 'requestLatestReleaseNotes').andCallFake ->
      data = fs.readFileSync(path.join(__dirname, 'fixtures', 'releases-response.json'))
      releaseNotesView.onReleaseNotesReceived(null, {}, data)

    atom.workspaceView = new WorkspaceView

    waitsForPromise ->
      atom.packages.activatePackage('release-notes')

    runs ->
      atom.workspaceView.openSync('atom://release-notes')
      releaseNotes = atom.workspaceView.find('.release-notes')
      releaseNotesView = releaseNotes.view()

  describe "with authorization", ->
    beforeEach ->
      spyOn(atom, 'getGitHubAuthToken').andReturn('token')

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
      spyOn(atom, 'getGitHubAuthToken').andReturn(null)
      releaseNotesView.fetch()

    it "prompts for authorization", ->
      expect(releaseNotes.find('.authorization').css('display')).not.toEqual 'none'
