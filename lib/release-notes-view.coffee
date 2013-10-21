{_, View} = require 'atom'

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
    if token
      @requestLatestReleaseNotes(token)
    else
      @authorization.show()
      @login.on 'click', =>
        rootView.trigger('github:sign-in')
        rootView.on('github-sign-in:succeeded', @onSuccessfulSignIn)
        false

  # Private
  onSuccessfulSignIn:  (event, token) =>
    @authorization.hide()
    @requestLatestReleaseNotes(token)
    rootView.off 'github-sign-in:succeeded', @onSuccessfulSignIn

  # Private
  getGithubToken: ->
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
    atom.config.set('release-notes.viewedVersion', latestRelease.tag_name)
    roaster latestRelease.body, (error, contents) =>
      @description.html(contents)
      @description.prepend("<h1>#{latestRelease.tag_name} - #{latestRelease.name}</h1>")
      @description.append('<br><p><span class="inline-block highlight-info">To update:</span> close Atom and reopen it.</p>')

  # Private
  findLatestRelease: (data) ->
    if @showUnreleased()
      data[0]
    else
      _.find(data, (r) -> !r.draft )
