{View} = require 'space-pen'
{_} = require 'atom'

request = require 'request'
keytar = require 'keytar'
roaster = require 'roaster'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item', tabindex: -1, =>
      @div class: 'description', outlet: 'description'
      @div class: 'authorization', style: 'display:none', outlet: 'authorization', =>
        @h1 "Authorization Required"
        @p "You must be logged in to GitHub to access the release notes."
        @button "Sign into GitHub", class: 'btn', outlet: 'login'

  getTitle: -> 'Release Notes'

  deserialize: (options={}) ->
    new ReleaseNotesView(options)

  serialize: ->
    deserializer: @constructor.name

  initialize: (options={}) ->
    @fetch()

  fetch: ->
    token = @getGithubToken()
    @requestLatestReleaseNotes(token) if token

  # Private
  getGithubToken: ->
    token = @getLocalToken()
    unless token
      @authorization.show()
      @login.on 'click', ->
        rootView.trigger('github:sign-in')
        false
    token

  getLocalToken: ->
    keytar.getPassword('github.com', 'github')

  # Private
  showUnreleased: ->
    !!atom.getLoadSettings().devMode

  # Private
  requestLatestReleaseNotes: (token) ->
    request
      method: 'GET'
      url: "https://api.github.com/repos/atom/atom/releases?access_token=#{token}"
      headers:
        'Accept': 'application/vnd.github.manifold-preview'
    , @onReleaseNotesReceived

  # Private
  onReleaseNotesReceived: (error, response, body) =>
    return console.warn error if error

    data = JSON.parse(body)
    latestRelease = @findLatestRelease(data)
    roaster latestRelease.body, (error, contents) =>
      @description.html(contents)
      @description.prepend("<h1>#{latestRelease.tag_name} - #{latestRelease.name}</h1>")

  # Private
  findLatestRelease: (data) ->
    if @showUnreleased()
      data[0]
    else
      _.find(data, (r) -> !r.draft )
