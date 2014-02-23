_ = require 'underscore-plus'
{View} = require 'atom'
request = require 'request'
roaster = require 'roaster'

module.exports =
class ReleaseNotesView extends View
  @content: ->
    @div class: 'release-notes padded pane-item', tabindex: -1, =>
      @section class: 'description', outlet: 'description'
      @section class: 'authorization', style: 'display:none', outlet: 'authorization', =>
        @h1 class: 'section-heading', "Authorization Required"
        @p "You must be logged in to GitHub to access the release notes."
        @button "Sign in to GitHub", class: 'btn', outlet: 'login'

  getTitle: -> 'Release Notes'

  getUri: -> @uri

  deserialize: ->
    new ReleaseNotesView(options)

  serialize: ->
    deserializer: @constructor.name

  initialize: ({@uri}={}) ->
    @fetch()

  fetch: ->
    token = atom.getGitHubAuthToken()
    if token
      @requestLatestReleaseNotes(token)
    else
      @authorization.show()
      @login.on 'click', =>
        atom.workspaceView.trigger('github:sign-in')
        atom.workspaceView.on('github-sign-in:succeeded', @onSuccessfulSignIn)
        false

  # Private
  onSuccessfulSignIn:  (event, token) =>
    @authorization.hide()
    @requestLatestReleaseNotes(token)
    atom.workspaceView.off 'github-sign-in:succeeded', @onSuccessfulSignIn

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
        'User-Agent': navigator.userAgent
    , @onReleaseNotesReceived

  # Private
  onReleaseNotesReceived: (error, response, body) =>
    return console.warn error if error

    data = JSON.parse(body)
    latestRelease = @findLatestRelease(data)
    if latestRelease
      atom.config.set('release-notes.viewedVersion', latestRelease.tag_name)
      roaster latestRelease.body, (error, contents) =>
        @description.html(contents)
        @description.prepend("<h1 class='section-heading'>#{latestRelease.tag_name} - #{latestRelease.name}</h1>")
        @description.append('<br><p><span class="inline-block highlight-info">To update:</span> close Atom and reopen it.</p>')
    else
      @description.prepend("<p>Error fetching release notes!</p>")

  # Private
  findLatestRelease: (data) ->
    if @showUnreleased()
      data[0]
    else
      _.find(data, (r) -> !r.draft )
